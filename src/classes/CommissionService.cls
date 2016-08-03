/*******************************************************************************************************
* @description 	CommissionService class' purpose to provide service calls related to commission caluculation
*               logic
* 
*/
public without sharing class CommissionService {
	
	private static final String BYPASS_MESSAGE = 'Bypass calling CommissionService.updateCommissionEntries(args...).\n';
	/*******************************************************************************************************
	* @description 			The importance of allreadyCalled flag is to prevent the method updateCommissionEntries to
	*                 		be called multiple time when for example Opportunity Line Item trigger is called and also
	*                   	due to roll up summary field updates trigger the Opportunity trigger which will result
	*                    	in duplicates and multiple executions
	*/
	private static Boolean alreadyCalled = false;
	/* 
		When an opportunity is closed won and then moved to closed lost both triggers will call the @future method updateCommissionEntriesFuture
		due to OpportunityLineItem trigger being called from Opportunity Trigger, to prevent this we will use this variable to by pass the duplicate
		update when recursion occurs
	*/
	public static Boolean bypassUpdateCommissionEntry = false;
	/* This flag will be set to true when opportunities are updated from contacts trigger */
	public static Boolean opportunitiesUpdatedFromContactTrigger = false;

	public static final String PRODUCT_STAGE_RETRACTED = 'Retracted';

	/*******************************************************************************************************
	* @description 					Mehtod takes a list of opportunities and it converts them to a set of
	*                   			opportunity ids which are later passed to an @future method which creates
	*                   			the corresponding commission entries for each commissionable event related
	*                   			to each opportunity
	* 
	* @param [List<Opportunity>] 		
	* 
	* @return 			void
	* 
	*/
	public static void updateCommissionEntries(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunityMap) {
		
		if (bypassUpdateCommissionEntry && !opportunitiesUpdatedFromContactTrigger) {
			System.Debug(BYPASS_MESSAGE + 'Bypass Reason: Opportunity moved to closed lost from closed won.');
			bypassUpdateCommissionEntry = false;//reset flag
			return; // exit from method
		}

		if (alreadyCalled) {
			System.Debug(BYPASS_MESSAGE + 'Bypass Reason: Method has already been called by another trigger.');
			return;
		} else {
			alreadyCalled = true;
		}

		if (ListUtils.isNotNullOrEmpty(opportunities)) {

			Set<Id> ids = new Set<Id>();
			List<Opportunity> eligibleOpportunities = CommissionUtils.getInstance().getEligibleOpportunitiesForCommission(opportunities);

			if (ListUtils.isNullOrEmpty(eligibleOpportunities)) {
				System.Debug('Did not find eligible opportunities, exiting method.');
				return;
			}

			ids = new Map<Id, Opportunity>(eligibleOpportunities).keySet();

			Map<Id, String> mapOldOpportunityIdToStage = null;

			if (oldOpportunityMap != null) {
				
				mapOldOpportunityIdToStage = new Map<Id, String>();

				for (Opportunity oldOpportunity :oldOpportunityMap.values()) {
					if (CommissionUtils.getInstance().isOpportunityRecordTypeIdEnabled(oldOpportunity.RecordTypeId)) { // Process Only Membership Opportunities
						mapOldOpportunityIdToStage.put(oldOpportunity.Id, oldOpportunity.StageName);
					}
				}
			}

			if (System.isFuture()) {
				updateCommissionEntries(new List<Id>(ids), mapOldOpportunityIdToStage);
			} else {
				updateCommissionEntriesFuture(new List<Id>(ids), mapOldOpportunityIdToStage);
			}
		}
	}

	/*******************************************************************************************************
	* @description 		Creates corresponding commission entries for each commissionable event for list of
	*                	opportunities in @future context
	* @param [List<Id>] 		
	* 
	* @return 			void
	* 
	*/
	@future(callout=true) /* Callout must be enabled so in the case of an exception which will be posted to Slack Web Service */
	public static void updateCommissionEntriesFuture(List<Id> opportunityIds, Map<Id, String> mapOldOpportunityIdToStage) {
		updateCommissionEntries(opportunityIds, mapOldOpportunityIdToStage);
	}

	/*******************************************************************************************************
	* @description 		Creates corresponding commission entries for each commissionable event for list of
	*                	opportunities in synchronous apex context
	* @param [List<Id>] 		
	* 
	* @return 			void
	* 
	*/
	public static void updateCommissionEntries(List<Id> opportunityIds, Map<Id, String> mapOldOpportunityIdToStage) {

		try {
			List<Opportunity> opportunities = OpportunityService.getByIdsWithOpportunityLineItemsAndCommissionEntries(opportunityIds, new List<String>{'Id', 'StageName', 'isClosed', 'isWon', 
																																					   'Specialty_Contacts_Bonus__c'},
																																	  new List<String>{'Id', 'OpportunityId', 'ProductStage__c',
																														 							   'Product2Id', 'CommissionAmount__c',
																														 							   'Opportunity.StageName', 'Opportunity.isClosed', 'Opportunity.isWon'},
																										 							  new List<String>{'Commission_Amount__c', 'Date_Calculated__c', 'Id', 
																										 							  					'Opportunity_Line_Item_Id__c', 'Opportunity__c', 
																																		   				'Paid_On_1st_round__c', 'Paid_On_2nd_round__c',
																																		   				'Product_Stage__c', 'Type__c', 'Total_Commission_Paid__c'}
																																	  );

			Map<String, List<Commission_Entry__c>> opportunityLineItemIdToCommissionEntryMap = populateOpportunityLineItemIdToCommissionEntryMap(opportunities);

			List<Commission_Entry__c> commissionEntriesToDelete = getCommissionEntriesToDelete(opportunities, opportunityLineItemIdToCommissionEntryMap);
			List<Commission_Entry__c> commissionEntriesToUpsert = getCommissionEntriesToUpsert(opportunities, opportunityLineItemIdToCommissionEntryMap, mapOldOpportunityIdToStage);

			try {
				delete commissionEntriesToDelete;
			}catch(DmlException dmlEx) {
				System.Debug('Exception dmlEx1: ' + dmlEx.getMessage() + ' - ' + dmlEx.getStackTraceString());
				LoggingUtils.log(dmlEx, true, true, true);
			}

			try {
				upsert commissionEntriesToUpsert;
			}catch(DmlException dmlEx) {
				System.Debug('Exception dmlEx2: ' + dmlEx.getMessage() + ' - ' + dmlEx.getStackTraceString());
				LoggingUtils.log(dmlEx, true, true, true);
			}

		}catch (Exception ex) {
			System.Debug('Exception ex: ' + ex.getMessage() + ' - ' + ex.getStackTraceString());
			LoggingUtils.log(ex, true, true, true);
		}
	}

	/*******************************************************************************************************
	* @description 	Method overrides and calls processCommissionEntriesForOpportunity(args) and it default 
	*               entireOrderCancelation flag to false
	* 
	*/
	@TestVisible
	private static void processCommissionEntriesForOpportunity(Opportunity opportunity, 
																   Map<String, List<Commission_Entry__c>> opportunityLineItemIdToCommissionEntryMap, 
																   List<Commission_Entry__c> commissionEntriesToUpsert) {
		processCommissionEntriesForOpportunity(opportunity, opportunityLineItemIdToCommissionEntryMap, commissionEntriesToUpsert, false);
	}

	/*******************************************************************************************************
	* @description 		Method process line items for a given opportunitu and it adds them to commissionEntriesToUpsert
	*                	list
	* 
	* @param 			[Opportunity opportunity] 
	* @param			[Map<String, Commission_Entry__c> opportunityLineItemIdToCommissionEntryMap]
	* @param			[List<Commission_Entry__c> commissionEntriesToUpsert]
	* @param			[Boolean entireOrderCancelation]
	* @return 			void
	* 
	*/
	@TestVisible
	private static void processCommissionEntriesForOpportunity(Opportunity opportunity, 
																   Map<String, List<Commission_Entry__c>> opportunityLineItemIdToCommissionEntryMap, 
																   List<Commission_Entry__c> commissionEntriesToUpsert,
																   Boolean entireOrderCancelation) {

		if (!entireOrderCancelation) {

			for (OpportunityLineItem opportunityLineItem :opportunity.OpportunityLineItems) {

				if (opportunityLineItemIdToCommissionEntryMap != null && opportunityLineItemIdToCommissionEntryMap.size() > 0) {			
					
					List<Commission_Entry__c> commissionEntryList = opportunityLineItemIdToCommissionEntryMap.get(opportunityLineItem.Id);

					if (commissionEntryList != null) {

						if (!opportunity.isClosed) { // Process Additions, Removals, and Update on opportunitu line items

							commissionEntryList[0].Product_Stage__c = opportunityLineItem.ProductStage__c;
							commissionEntryList[0].Date_Calculated__c = Datetime.now();
							commissionEntryList[0].Opportunity_Line_Item_Id__c = opportunityLineItem.Id;
							commissionEntryList[0].Commission_Amount__c = opportunityLineItem.CommissionAmount__c;
							assignCommissionEntryStatusForOpportunityStage(opportunity.StageName, commissionEntryList[0]);						

							commissionEntriesToUpsert.add(commissionEntryList[0]);

						} else if (opportunity.isWon && commissionEntryList.size() == 1 
							&& opportunityLineItem.ProductStage__c != null
							&& opportunityLineItem.ProductStage__c.equalsIgnoreCase(PRODUCT_STAGE_RETRACTED)) { // Process Retracted Opportunity Line Items for Closed Opportunity(s)

							Commission_Entry__c commissionEntryTemp = null;

							if (commissionEntryList[0].Total_Commission_Paid__c == null || commissionEntryList[0].Total_Commission_Paid__c == 0) {// Commission Entry Not Paid Out Yet
								
								commissionEntryTemp = commissionEntryList[0];

								commissionEntryTemp.Commission_Amount__c = opportunityLineItem.CommissionAmount__c;
								commissionEntryTemp.Product_Stage__c = opportunityLineItem.ProductStage__c;

							} else {
								commissionEntryTemp = new Commission_Entry__c();

								commissionEntryTemp.Opportunity_Line_Item_Id__c = opportunityLineItem.Id;
								commissionEntryTemp.Commission_Amount__c = commissionEntryList[0].Total_Commission_Paid__c * -1;
								commissionEntryTemp.Product_Stage__c = opportunityLineItem.ProductStage__c;
							}
							
							commissionEntryTemp.Opportunity__c = opportunity.Id;
							commissionEntryTemp.Product__c = opportunityLineItem.Product2Id;
							commissionEntryTemp.Date_Calculated__c = Datetime.now();
							commissionEntryTemp.Type__c = 'Product';
							assignCommissionEntryStatusForOpportunityStage(opportunity.StageName, commissionEntryTemp);

							commissionEntriesToUpsert.add(commissionEntryTemp);

						} else if (opportunity.isWon && commissionEntryList.size() == 1 &&
							(opportunityLineItem.ProductStage__c == null 
							|| opportunityLineItem.ProductStage__c == '' 
							|| !opportunityLineItem.ProductStage__c.equalsIgnoreCase(PRODUCT_STAGE_RETRACTED))) { // Catch All Process For Closed Won Opportunities without products being retracted

							commissionEntryList[0].Product_Stage__c = opportunityLineItem.ProductStage__c;
							commissionEntryList[0].Date_Calculated__c = Datetime.now();
							commissionEntryList[0].Opportunity_Line_Item_Id__c = opportunityLineItem.Id;
							commissionEntryList[0].Commission_Amount__c = opportunityLineItem.CommissionAmount__c;
							assignCommissionEntryStatusForOpportunityStage(opportunity.StageName, commissionEntryList[0]);						

							commissionEntriesToUpsert.add(commissionEntryList[0]);
						} else if (opportunity.isWon && commissionEntryList.size() > 1) {
							/* 
							This if else block handles when an opportunity line item has been moved from Retracted to another product stage
							and we need to remove the retracted commission entry (in getCommissionEntriesToDelete(args...) method) as well as 
							change the commission entry with positive amount to reflect the opportunity line item stage
							*/
							for (Commission_Entry__c commissionEntry :commissionEntryList) {
								if (commissionEntry.Product_Stage__c != null && !commissionEntry.Product_Stage__c.equalsIgnoreCase(PRODUCT_STAGE_RETRACTED)) {
									commissionEntry.Product_Stage__c = opportunityLineItem.ProductStage__c;
									commissionEntriesToUpsert.add(commissionEntry);
									break;
								}
							}
						}

					} else { // Commission Entry Not Found which would indicate the addition of a new Opportunity Line Item / Product to the Opportunity
						commissionEntriesToUpsert.add(convertOpportunityLineItemToCommissionEntry(opportunityLineItem));	
					}	
					
					
				} else { // Brand new opportunity insert
					commissionEntriesToUpsert.add(convertOpportunityLineItemToCommissionEntry(opportunityLineItem));
				}
			}
			//Add or Update Commission Entry for the opportunity such as Specialty Contacts Bonues etc.
			updateOpportunityHeaderCommissionEntry(opportunity, commissionEntriesToUpsert);

		} else { // Entire Order Canceled. Add all commission entries as retracted and mark as negative commission amounts on the commission entries
			
			for (OpportunityLineItem opportunityLineItem :opportunity.OpportunityLineItems) {

				List<Commission_Entry__c> commissionEntryListTemp = opportunityLineItemIdToCommissionEntryMap.get(opportunityLineItem.Id);

				if (ListUtils.isNotNullOrEmpty(commissionEntryListTemp) && commissionEntryListTemp.size() == 1) {

					if (commissionEntryListTemp[0].Total_Commission_Paid__c != null && commissionEntryListTemp[0].Total_Commission_Paid__c > 0) {
						
						commissionEntriesToUpsert.add(new Commission_Entry__c(
														Opportunity__c = opportunityLineItem.OpportunityId,
														Commission_Amount__c = commissionEntryListTemp[0].Total_Commission_Paid__c * -1,
														Opportunity_Line_Item_Id__c = opportunityLineItem.Id,
														Product_Stage__c = PRODUCT_STAGE_RETRACTED,
														Product__c = opportunityLineItem.Product2Id,
														Date_Calculated__c = Datetime.now(),
														Status__c = PRODUCT_STAGE_RETRACTED,
														Type__c = 'Product'
													));
					}
				}
			}
			// Check Commission_Entry__c with type Opportunity if paid and if so add a negative entry
			updateOpportunityHeaderCommissionEntry(opportunity, commissionEntriesToUpsert, true);
		}
	}

	/*******************************************************************************************************
	* @description 	Method will add Commission Entry object to commissionEntriesToUpsert list if the opportunity needs
	*               to have commission entry of a type Opportunity besides individual products
	* 
	* @param 		[Opportunity opportunity]
	* @param 		[List<Commission_Entry__c> commissionEntriesToUpsert]
	* @param		[Boolean orderCanceled] indicated when an opportunity is moved from Closed Won to Closed Lost e.g. canceled
	* @return 		void
	* 
	*/
	@TestVisible
	private static void updateOpportunityHeaderCommissionEntry(Opportunity opportunity, List<Commission_Entry__c> commissionEntriesToUpsert, Boolean orderCanceled) {
		
		Boolean hasCommissionWithTypeOpportunity = false;
		Commission_Entry__c opportunityCommissionEntry = null;

		for (Commission_Entry__c commissionEntry :opportunity.Commission_Entries__r) {
			if (commissionEntry.Type__c.equalsIgnoreCase('Opportunity')) {
				
				hasCommissionWithTypeOpportunity = true;
				
				if (orderCanceled) {
					opportunityCommissionEntry = commissionEntry;
					break;
				}else {
					assignCommissionEntryStatusForOpportunityStage(opportunity.StageName, commissionEntry);
					commissionEntry.Commission_Amount__c = opportunity.Specialty_Contacts_Bonus__c;
					commissionEntriesToUpsert.add(commissionEntry);
				}
				break;
			}
		}

		if (!hasCommissionWithTypeOpportunity) {

			Commission_Entry__c opportunityCommissionEntryTemp = new Commission_Entry__c();

			opportunityCommissionEntryTemp.Commission_Amount__c = opportunity.Specialty_Contacts_Bonus__c;
			opportunityCommissionEntryTemp.Opportunity__c = opportunity.Id;
			opportunityCommissionEntryTemp.Date_Calculated__c = Datetime.now();
			opportunityCommissionEntryTemp.Type__c = 'Opportunity';

			commissionEntriesToUpsert.add(opportunityCommissionEntryTemp);

		} else if (hasCommissionWithTypeOpportunity && orderCanceled && opportunityCommissionEntry != null && (opportunityCommissionEntry.Total_Commission_Paid__c != null && opportunityCommissionEntry.Total_Commission_Paid__c > 0)) {

			Commission_Entry__c opportunityCommissionEntryRetract = new Commission_Entry__c();

			opportunityCommissionEntryRetract.Commission_Amount__c = opportunity.Specialty_Contacts_Bonus__c * -1;
			opportunityCommissionEntryRetract.Opportunity__c = opportunity.Id;
			opportunityCommissionEntryRetract.Date_Calculated__c = Datetime.now();
			opportunityCommissionEntryRetract.Type__c = 'Opportunity';

			assignCommissionEntryStatusForOpportunityStage(opportunity.StageName, opportunityCommissionEntryRetract);

			commissionEntriesToUpsert.add(opportunityCommissionEntryRetract);
		}
	}

	/*******************************************************************************************************
	* @description 	Overrides method updateOpportunityHeaderCommissionEntry(Opportunity opportunity, List<Commission_Entry__c> commissionEntriesToUpsert, Boolean orderCanceled);
	*/
	@TestVisible
	private static void updateOpportunityHeaderCommissionEntry(Opportunity opportunity, List<Commission_Entry__c> commissionEntriesToUpsert) {
		updateOpportunityHeaderCommissionEntry(opportunity, commissionEntriesToUpsert, false);
	}

	/*******************************************************************************************************
	* @description 	 Determines commission entry table records for given list of opportunities to update/insert
	* 
	* @return 		 List<Commission_Entry__c> -> return list of Commission_Entry__c items to upsert
	* 
	*/
	@TestVisible
	private static List<Commission_Entry__c> getCommissionEntriesToUpsert(List<Opportunity> opportunities, 
																		  Map<String, List<Commission_Entry__c>> opportunityLineItemIdToCommissionEntryMap, 
																		  Map<Id, String> mapOldOpportunityIdToStage) {
		
		List<Commission_Entry__c> commissionEntriesToUpsert = new List<Commission_Entry__c>();

		for (Opportunity opportunity :opportunities) {

			if (!opportunity.isClosed) {

				processCommissionEntriesForOpportunity(opportunity, opportunityLineItemIdToCommissionEntryMap, commissionEntriesToUpsert);

			} else if (opportunity.isWon) {

				processCommissionEntriesForOpportunity(opportunity, opportunityLineItemIdToCommissionEntryMap, commissionEntriesToUpsert);	

			}else if (mapOldOpportunityIdToStage != null && opportunity.isClosed) { // When mapOldOpportunityIdToStage is null this would mean that this method has been executed from the opportunity line item trigger
				
				String oldOpportunityStageName =  mapOldOpportunityIdToStage.get(opportunity.Id);
				
				if (String.isNotBlank(oldOpportunityStageName) && oldOpportunityStageName.equalsIgnoreCase('Closed Won')) { // Opportunity moved from Closed Won to Closed Lost (cancelation)
					//entire order has been canceled
					processCommissionEntriesForOpportunity(opportunity, opportunityLineItemIdToCommissionEntryMap, commissionEntriesToUpsert, true);// boolean argument to truly indicate order cancelation
				}
			}
		}
		return commissionEntriesToUpsert;
	}

	/*******************************************************************************************************
	* @description 	 Determines commission entry table records that have to be deleted e.g. there are no line
	*                items associated to commission entries that already exists for given list of opportunites
	* 
	* @return 		 List<Commission_Entry__c> -> return list of Commission_Entry__c items to delete
	* 
	*/
	@TestVisible
	private static List<Commission_Entry__c> getCommissionEntriesToDelete(List<Opportunity> opportunities, Map<String, List<Commission_Entry__c>> opportunityLineItemIdToCommissionEntryMap) {
		
		List<Commission_Entry__c> commissionEntriesToDelete = new List<Commission_Entry__c>();
		
		for (Opportunity opportunity :opportunities) {

			/* if opportunity closed lost and previous stage was not Closed Won delete all commission entries */
			if (opportunity.isClosed && !opportunity.isWon) { 

				for (Commission_Entry__c commissionEntry :opportunity.Commission_Entries__r) {

					if (commissionEntry.Total_Commission_Paid__c == null || commissionEntry.Total_Commission_Paid__c == 0) {
						commissionEntriesToDelete.add(commissionEntry);
					}
				}
			} else { /*	check for deleted opportunity line items and delete corresponding commission entries. 
						Each Commission Entry record should have corresponding opportunity line item with the exception of Commission Entry with type Opportunity
					 */

				if (ListUtils.isNotNullOrEmpty(opportunity.OpportunityLineItems)) {
					
					Map<Id, OpportunityLineItem> opportunityLineItemsMap = new Map<Id, OpportunityLineItem>(opportunity.OpportunityLineItems);
					
					for (Commission_Entry__c commissionEntry :opportunity.Commission_Entries__r) {

						if (String.isNotEmpty(commissionEntry.Opportunity_Line_Item_Id__c) && !opportunityLineItemsMap.containsKey(commissionEntry.Opportunity_Line_Item_Id__c)) {
							commissionEntriesToDelete.add(commissionEntry);
						}
					}

					//clean up retracted commission entries which have been removed from retracted stage
					if (opportunityLineItemIdToCommissionEntryMap != null) {

						for (OpportunityLineItem opportunityLineItem :opportunityLineItemsMap.values()) {
							List<Commission_Entry__c> commissionEntryListTemp = opportunityLineItemIdToCommissionEntryMap.get(opportunityLineItem.Id);

							if (ListUtils.isNotNullOrEmpty(commissionEntryListTemp) && commissionEntryListTemp.size() > 1 && opportunityLineItem.ProductStage__c != PRODUCT_STAGE_RETRACTED) {
								for (Commission_Entry__c commissionEntryTemp :commissionEntryListTemp) {
									if (commissionEntryTemp.Product_Stage__c == PRODUCT_STAGE_RETRACTED) {
										commissionEntriesToDelete.add(commissionEntryTemp);
										break;
									}
								}
							}
						}
					}
				} else {
					for (Commission_Entry__c commissionEntry: opportunity.Commission_Entries__r) {
						if (commissionEntry.Type__c.equalsIgnoreCase('Product')) {
							commissionEntriesToDelete.add(commissionEntry);
						}
					}
				}
			}
		}
		return commissionEntriesToDelete;
	}

	/*******************************************************************************************************
	* @description 	Method will loop though Commission_Entry__c records related to each opportunity and it will 
	*               add each Commission_Entry__c records to a list related to an Opportunity Line Item Id
	* 
	* @param 		[List<Opportunity> opportunities] List of opportunities and related commission entries
	* @return 		[Map<String, List<Commission_Entry__c>>] -< key = Opportunity_Line_Item_Id__c, value = List<Commission_Entry__c> objects
	* 
	*/
	@TestVisible
	private static Map<String, List<Commission_Entry__c>> populateOpportunityLineItemIdToCommissionEntryMap(List<Opportunity> opportunities) {
 
		if (ListUtils.isNotNullOrEmpty(opportunities)) {
			Map<String, List<Commission_Entry__c>> resultMap = new Map<String, List<Commission_Entry__c>>();
			
			for (Opportunity opportunity :opportunities) {
				if (ListUtils.isNotNullOrEmpty(opportunity.Commission_Entries__r)) {
					List<CommissionEntryWrapper> commissionEntryWrapperList = convertToCommissionEntryWrapperList(opportunity.Commission_Entries__r);
					
					if (ListUtils.isNotNullOrEmpty(commissionEntryWrapperList)) {
						commissionEntryWrapperList.sort();//sort by Opportunity_Line_Item_Id__c

						String opportunityLineItemIdIProcess = commissionEntryWrapperList[0].commissionEntry.Opportunity_Line_Item_Id__c;
						resultMap.put(opportunityLineItemIdIProcess, new List<Commission_Entry__c>{commissionEntryWrapperList[0].commissionEntry});

						for (Integer i = 1; i < commissionEntryWrapperList.size(); i++) {
							if (opportunityLineItemIdIProcess.equals(commissionEntryWrapperList[i].commissionEntry.Opportunity_Line_Item_Id__c)) {
								resultMap.get(opportunityLineItemIdIProcess).add(commissionEntryWrapperList[i].commissionEntry);
							} else {
								opportunityLineItemIdIProcess = commissionEntryWrapperList[i].commissionEntry.Opportunity_Line_Item_Id__c;
								resultMap.put(opportunityLineItemIdIProcess, new List<Commission_Entry__c>{commissionEntryWrapperList[i].commissionEntry});
							}
						}
					}
					
				}
			}
			return resultMap;
		} else {
			return null;
		}
	}

	/*******************************************************************************************************
	* @description 				Return only entries that have value in Opportunity_Line_Item_Id__c field
	* 
	*/
	@TestVisible
	private static List<CommissionEntryWrapper> convertToCommissionEntryWrapperList(List<Commission_Entry__c> commissionEntries) {

		if (ListUtils.isNotNullOrEmpty(commissionEntries)) {
			List<CommissionEntryWrapper> commissionEntryWrapperList = new List<CommissionEntryWrapper>();
			for (Commission_Entry__c commissionEntry :commissionEntries) {
				if (String.isNotEmpty(commissionEntry.Opportunity_Line_Item_Id__c)) {
					commissionEntryWrapperList.add(new CommissionEntryWrapper(commissionEntry));
				}
			}
			return commissionEntryWrapperList;
		} else {
			return null;
		}
	}

	@TestVisible
	private static void assignCommissionEntryStatusForOpportunityStage(String opportunityStage, Commission_Entry__c commissionEntry) {
		if (String.isNotEmpty(opportunityStage)) {
			if (opportunityStage.contains('Closed')) {
				commissionEntry.Status__c = 'Closed';	
			} else {
				commissionEntry.Status__c = 'Open';
			}
		} 
	}

	@TestVisible
	private static Commission_Entry__c convertOpportunityLineItemToCommissionEntry(OpportunityLineItem opportunityLineItem) {
		
		Commission_Entry__c commissionEntry = new Commission_Entry__c(
													Opportunity__c = opportunityLineItem.OpportunityId,
													Opportunity_Line_Item_Id__c = opportunityLineItem.Id,
													Commission_Amount__c = opportunityLineItem.CommissionAmount__c,
													Product_Stage__c = opportunityLineItem.ProductStage__c,
													Product__c = opportunityLineItem.Product2Id,
													Date_Calculated__c = Datetime.now(),
													Type__c = 'Product'
												);

		assignCommissionEntryStatusForOpportunityStage(opportunityLineItem.Opportunity.StageName, commissionEntry);

		return commissionEntry;
	}

	/*******************************************************************************************************
	* @description 	Wrapper Class Used to Sort Commission Entry objects by Opportynity_Line_Item_Id__c field
	* 
	*/
	public class CommissionEntryWrapper implements Comparable {
		
		public Commission_Entry__c commissionEntry;

		public CommissionEntryWrapper(Commission_Entry__c commissionEntry) {
			this.commissionEntry = commissionEntry;
		}

		public Integer compareTo(Object compareTo) {

			CommissionEntryWrapper commissionEntryToCompare = (CommissionEntryWrapper) compareTo;
			// The return value of 0 indicates that both elements are equal.
			Integer compareResult = 0;

			 if (this.commissionEntry.Opportunity_Line_Item_Id__c > commissionEntryToCompare.commissionEntry.Opportunity_Line_Item_Id__c) {
	            // Set return value to a positive value.
	            compareResult = 1;
	        } else if (this.commissionEntry.Opportunity_Line_Item_Id__c < commissionEntryToCompare.commissionEntry.Opportunity_Line_Item_Id__c) {
	            // Set return value to a negative value.
	            compareResult = -1;
	        }

			return compareResult;
		}
	}
}