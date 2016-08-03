public without sharing class OpportunityLineItemService {

	private static final String OPPORTUNITYLINEITEMx = 'OpportunityLineItem';

	public static List<OpportunityLineItem> getByIds(List<Id> opportunityLineItemIds, List<String> fields) {
			
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(OPPORTUNITYLINEITEMx)
						  .wherex(new SetCondition('Id').inx(opportunityLineItemIds))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<OpportunityLineItem> getByOpportunityIds(List<Id> opportunityIds, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(OPPORTUNITYLINEITEMx)
						  .wherex(new SetCondition('OpportunityId').inx(opportunityIds))
						  .toSoql();
		return Database.query(soql);
	}

	public static Set<String> getOpportunityIdsForOpportunityLineItems(List<OpportunityLineItem> opportunityLineItems) {

		Set<String> setOpportunityIds = new Set<String>();

		for (OpportunityLineItem opportunityLineItem :opportunityLineItems) {
			setOpportunityIds.add(opportunityLineItem.OpportunityId);
		}
		return setOpportunityIds;
	}

	/*******************************************************************************************************
	* @description 	Method calculates commission amount for each opportunity line item based on calculated 
	*               reference fields housed on the related Opportunity
	* 
	* @param 		[List<Opportunity> ]
	* @return 		void
	* 
	*/
	public static void calculateProductsCommissionAmount(List<Opportunity> opportunities) {
		
		if (ListUtils.isNullOrEmpty(opportunities)) {
			return;
		}

		List<Opportunity> eligibleOpportunities = CommissionUtils.getInstance().getEligibleOpportunitiesForCommission(opportunities);
		List<Id> opportunityIds = null;

		if (ListUtils.isNotNullOrEmpty(eligibleOpportunities)) {
			opportunityIds = new List<Id>(new Map<Id, SObject>(eligibleOpportunities).keySet());
		}

		if (ListUtils.isNotNullOrEmpty(opportunityIds)) { // Insert trigger will not pass any ids in the list
			List<OpportunityLineItem> opportunityLineItems = getByOpportunityIds(opportunityIds,
																				 new List<String>{'Id', 'ProductStage__c',
																				 				  'OpportunityId', 
																				 				  'CommissionAmount__c',
																				 				  'ProductCode'});
			calculateProductsCommissionAmount(eligibleOpportunities, opportunityLineItems, true);
		}
	}

	/*******************************************************************************************************
	* @description 	Method calculates commission amount for each opportunity line item based on calculated 
	*               reference fields housed on the related Opportunity
	* 
	* @param 		[List<OpportunityLineItem> ]
	* @return 		void
	* 
	*/
	public static void calculateProductsCommissionAmount(List<Opportunity> opportunities, List<OpportunityLineItem> newOpportunityLineItems, Boolean updateOpportunityLineItems) {
		
		if (ListUtils.isNullOrEmpty(opportunities)) {
			return;
		}

		List<Opportunity> eligibleOpportunities = CommissionUtils.getInstance().getEligibleOpportunitiesForCommission(opportunities);

		if (ListUtils.isNotNullOrEmpty(eligibleOpportunities)) {

			Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>(eligibleOpportunities);

			for (OpportunityLineItem opportunityLineItem :newOpportunityLineItems) {
				
				if (StringUtils.equalsIgnoreCase(opportunityLineItem.ProductStage__c, 'Retracted')) {
					opportunityLineItem.CommissionAmount__c = 0.00;
				} else {

					Integer acceleratorStage = CommissionUtils.NO_ACCELERATOR;

					if (opportunitiesMap.get(opportunityLineItem.OpportunityId).Accelerator_Stage_2__c) {
						acceleratorStage = CommissionUtils.ACCELERATOR_STAGE_2;
					} else if (opportunitiesMap.get(opportunityLineItem.OpportunityId).Accelerator_Stage_1__c) {
						acceleratorStage = CommissionUtils.ACCELERATOR_STAGE_1;
					}
					opportunityLineItem.CommissionAmount__c = CommissionUtils.getInstance()
																.getCommissionCardRateAmount(
																	opportunitiesMap.get(opportunityLineItem.OpportunityId).Owner_Team__c,
																	opportunitiesMap.get(opportunityLineItem.OpportunityId).Qualification_Type__c,
																	opportunityLineItem.ProductCode,
																	acceleratorStage);
				}
			}

			if (updateOpportunityLineItems) {
				CommissionService.bypassUpdateCommissionEntry = true;
				update newOpportunityLineItems;
			}
		}
	}
	/*******************************************************************************************************
	* @description 	Method calculates commission amount for each opportunity line item based on calculated 
	*               reference fields housed on the related Opportunity
	* 
	* @param 		[List<OpportunityLineItem> ]
	* @return 		void
	* 
	*/
	public static void calculateProductsCommissionAmount(List<Opportunity> opportunities, List<OpportunityLineItem> newOpportunityLineItems) {
		calculateProductsCommissionAmount(opportunities, newOpportunityLineItems, false);	
	}

	/*******************************************************************************************************
	* @description 		Prevent multiple opportunity line items with the same product to be inserted for
	*                	related opportunity
	* 
	*/
	public static void checkForDuplicates(List<Opportunity> opportunities, List<OpportunityLineItem> opportunityLineItemsNew) {
		
		Set<String> productIdToOpportunityLineItemSet = new Set<String>();

		for (Opportunity opportunity :opportunities) {
			for (OpportunityLineItem opportunityLineItem :opportunity.OpportunityLineItems) {
				productIdToOpportunityLineItemSet.add(opportunityLineItem.Product2Id);
			}
		}

		for (OpportunityLineItem oportunityLineItem : opportunityLineItemsNew) {
			if (productIdToOpportunityLineItemSet.contains(oportunityLineItem.Product2Id)) {
				throw new LoggingUtils.CustomException('Duplicate products are not allowed! Instead adjust the quantity field.');
			}
		}
	}
}
