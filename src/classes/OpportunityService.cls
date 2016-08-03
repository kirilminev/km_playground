public without sharing class OpportunityService {

	private static final String OPPORTUNITYx = 'Opportunity';
	private static final String OPPORTUNITYLINEITEMSx = 'OpportunityLineItems';
	private static final String USERx = 'User';
	private static final String COMMISSIONENTRYx = 'Commission_Entry__c';
	private static final String OPPORTUNITYCOMMISSIONENTRIESx = 'Commission_Entries__r';
	

	public static List<Opportunity> getByIdsWithOpportunityLineItemsAndCommissionEntries(List<Id> opportunityIds, 
																						 List<String> opportunityFields, 
																						 List<String> opportunityLineItemFields,
																						 List<String> commissionEntryFields) {
		String soql = new SoqlBuilder()
						  .selectx(opportunityFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(opportunityLineItemFields)
						  		.fromx(OPPORTUNITYLINEITEMSx))
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(commissionEntryFields)
						  		.fromx(OPPORTUNITYCOMMISSIONENTRIESx))
						  .fromx(OPPORTUNITYx)
						  .wherex(new SetCondition('Id').inx(opportunityIds))
						  .toSoql();
		return Database.query(soql);
	}

	public static Opportunity getById(Id opportunityId, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(OPPORTUNITYx)
						  .wherex(new FieldCondition('Id').equals(opportunityId))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Opportunity> getByIds(List<Id> opportunityIds, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(OPPORTUNITYx)
						  .wherex(new SetCondition('Id').inx(opportunityIds))
						  .toSoql();
		return Database.query(soql);
	}

	/*******************************************************************************************************
	* @description 	Query for opportunities for given list of ids and the opportunity's corresponding line items
	* 
	*/
	public static List<Opportunity> getByIdsWithOpportunityLineItems(List<Id> opportunityIds, List<String> opportunityFields, List<String>opportunityLineItemFields) {
		
		String soql = new SoqlBuilder()
						  .selectx(opportunityFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(opportunityLineItemFields)
						  		.fromx(OPPORTUNITYLINEITEMSx))
						  .fromx(OPPORTUNITYx)
						  .wherex(new SetCondition('Id').inx(opportunityIds))
						  .toSoql();
		return Database.query(soql);
	}

	/*******************************************************************************************************
	* @description 	Return a list of users for given list of opportunities. Each opportunit owner user id 
	*               will be included in the query and returned from this method
	* 
	*/
	public static List<User> getOpportunityOwners(List<Opportunity> opportunities, List<String> userFields) {
		
		if (ListUtils.isNullOrEmpty(opportunities) || ListUtils.isNullOrEmpty(userFields)) {
			return null;
		}

		List<String> userIds = new List<String>();

		for (Opportunity opportunity :opportunities) {
			userIds.add(opportunity.OwnerId);
		}

		String soql = new SoqlBuilder()
							.selectx(userFields)
							.fromx(USERx)
							.wherex(new SetCondition('Id').inx(userIds))
							.toSoql();

		return Database.query(soql);
	}

	/*******************************************************************************************************
	* @description 		Query for open opportunities for given list of account ids
	* 
	* @return 			[List<Opportunity>] -> Open Opportunities for each account passed in the accountIds
	* 
	*/
	public static List<Opportunity> getOpenOpportunitiesByAccountIds(List<String> accountIds, List<String> opportunityFields) {

		String soql = new SoqlBuilder()
						    .selectx(opportunityFields)
						    .fromx(OPPORTUNITYx)
						    .wherex(new AndCondition()
						    	.add(new FieldCondition('isClosed').equals(false))
						    	.add(new SetCondition('AccountId').inx(accountIds))
						    	)
						    .toSoql();

	    return Database.query(soql);
	}

	public static List<Opportunity> getOpenOpportunitiesByAccountIdsAndOpportunityRecordTypeIds(List<String> accountIds, List<String> opportunityRecordTypeIds, List<String> opportunityFields) {

		String soql = new SoqlBuilder()
						    .selectx(opportunityFields)
						    .fromx(OPPORTUNITYx)
						    .wherex(new AndCondition()
						    	.add(new FieldCondition('isClosed').equals(false))
						    	.add(new SetCondition('AccountId').inx(accountIds))
						    	.add(new SetCondition('RecordTypeId').inx(opportunityRecordTypeIds))
						    	)
						    .toSoql();
	    return Database.query(soql);
	}

	/*******************************************************************************************************
	* @description 		Method updates Opportunity.Qualification_Type__c when contact.accountId changes or a new
	*                	contact is added to an account
	* 
	* @param 			
	* @return 			void
	* 
	*/
	public static void calculateQualificationTypeForContacts(List<Contact> newContactsList, Map<Id, Contact> oldContactsMap) {
		
		Set<String> accountIdsToRecalculate = new Set<String>();
		
		if (oldContactsMap != null) {
			for (Contact contact :newContactsList) {
				/* If Contact's Account or Qualificaiton has changed include for recalculation for all
				 * open opportunities related to the given contact
				 */ 
				if (contact.AccountId != oldContactsMap.get(contact.Id).AccountId ||
					contact.Qualification__c != oldContactsMap.get(contact.Id).Qualification__c ||
					contact.NPI__c != oldContactsMap.get(contact.Id).NPI__c) {

					accountIdsToRecalculate.add(contact.AccountId);
					accountIdsToRecalculate.add(oldContactsMap.get(contact.Id).AccountId);
				}
			}
		} else {
			for (Contact contact :newContactsList) {
				if (contact.AccountId != null) {
					accountIdsToRecalculate.add(contact.AccountId);
				}
			}
		}

		List<String> eligibleOpportunityRecordTypes = new List<String>();

		// convert Set<Id> to List<Strings> 
		if (CommissionUtils.getInstance().enabledOpportunityRecordTypeIds != null) {
			for (Id recordTypeIdTemp :CommissionUtils.getInstance().enabledOpportunityRecordTypeIds) {
				eligibleOpportunityRecordTypes.add(recordTypeIdTemp);
			}
		}

		if (SetUtils.isNotNullOrEmpty(accountIdsToRecalculate) && ListUtils.isNotNullOrEmpty(eligibleOpportunityRecordTypes)) {
			
			Map<String, CommissionUtils.QualificationTypeVo> accountToQualificationTypeMap = getQualificationTypeByAccountIds(accountIdsToRecalculate);

			if (accountToQualificationTypeMap != null && accountToQualificationTypeMap.size() > 0) {

				List<Opportunity> openOpportunities = getOpenOpportunitiesByAccountIdsAndOpportunityRecordTypeIds(
																					   new List<String>(accountIdsToRecalculate), 
																					   eligibleOpportunityRecordTypes,
																		 			   new List<String>{'Id', 
																		 			   					'AccountId', 
																		 			   					'Owner_Team__c',
																		 			   					'Owner_Specialty__c',
																		 			   					'Qualification_Type__c', 
																		 			   					'RecordTypeId'}
																		 			   					);
					
				recalculateOpenOpportunityQualificationType(accountToQualificationTypeMap, openOpportunities);

				if (ListUtils.isNotNullOrEmpty(openOpportunities)) {
					CommissionService.opportunitiesUpdatedFromContactTrigger = true;
					update openOpportunities;
				}
			}
		}
	}

	/*******************************************************************************************************
	* @description 		Method updates Opportunity.Qualification_Type__c when contact.accountId changes or a new
	*                	contact is added to an account
	*                				
	* @return 			void
	* 
	*/
	public static void calculateQualificationTypeForOpportunities(List<Opportunity> newOpportunitiesList, Map<Id, Opportunity> oldOpportunitiesMap) {
		
		Set<String> accountIds = new Set<String>();
		List<Opportunity> eligibleOpportunities = null;

		if (ListUtils.isNotNullOrEmpty(newOpportunitiesList)) {
			eligibleOpportunities = CommissionUtils.getInstance().getEligibleOpportunitiesForCommission(newOpportunitiesList);
		} else {
			return;
		}

		if (oldOpportunitiesMap != null && eligibleOpportunities != null) {

 			for (Opportunity opportunity :eligibleOpportunities) {// before update trigger
 				if (!opportunity.isClosed) {
	 				Opportunity opportunityOld = oldOpportunitiesMap.get(opportunity.Id);
	 				if (opportunityOld != null && 
	 					(opportunity.AccountId != opportunityOld.AccountId || 
	 						opportunity.OwnerId != opportunityOld.OwnerId)) {
	 					accountIds.add(opportunity.AccountId);	
	 				}
 				}
 			}
		} else if (eligibleOpportunities != null) {

			for (Opportunity opportunity :eligibleOpportunities) {//insert trigger
				if (!opportunity.isClosed) {
					accountIds.add(opportunity.AccountId);
				}
			}
		}

		if (accountIds.size() > 0) {
			Map<String, CommissionUtils.QualificationTypeVo> accountToQualificationTypeMap = getQualificationTypeByAccountIds(accountIds);
			if (accountToQualificationTypeMap != null && accountToQualificationTypeMap.size() > 0) {
				recalculateOpenOpportunityQualificationType(accountToQualificationTypeMap, eligibleOpportunities);
			}
		}
 	}

 	/*******************************************************************************************************
 	* @description 		Accepts a map with accountId to QualificaitonType mapping and it updates Opportunity
 	*                	QualificationType field with the corresponding qualificaiton type for given accountId
 	*
 	* @return 			void
 	* 
 	*/
	@TestVisible
	private static void recalculateOpenOpportunityQualificationType(Map<String, CommissionUtils.QualificationTypeVo> accountToQualificationTypeMap, List<Opportunity> openOpportunities) {
		
		if (!CommissionUtils.getInstance().validMembershipTeams.contains(new Constants.Teams().PES)){
			throw new LoggingUtils.CustomException('An unexpected error occured in OpportunityService.recalculateOpenOpportunityQualificationType. Please contact your administrator including the below message!\n' + 
													 'Message: Membership team' + new Constants.Teams().PES + ' not a valid option!');
		}

		for (Opportunity opportunity :openOpportunities) {

			opportunity.Qualification_Type__c = accountToQualificationTypeMap.get(opportunity.AccountId).highestPriorityQualificationType;

			// Specialty Contact Bonus Only Available for PES Team
			if (opportunity.Owner_Team__c != new Constants.Teams().PES) {
				continue;
			} else {
				Map<String, Integer> numberOfContactPerQualificationMap = accountToQualificationTypeMap.get(opportunity.AccountId).numberOfContactPerQualification;

				if (numberOfContactPerQualificationMap != null) {
					
					Integer numberOfCommisionableContacts = numberOfContactPerQualificationMap.get(opportunity.Owner_Specialty__c);

					if (numberOfCommisionableContacts != null && numberOfCommisionableContacts > 0) {

						opportunity.Additional_Specialty_Contacts__c = (numberOfCommisionableContacts - 1);
						Commission_Rate_Specialty_Contacts__c rateConfig = Commission_Rate_Specialty_Contacts__c.getInstance(opportunity.Qualification_Type__c);


						if (rateConfig != null) {
							Decimal specialtyContactsBonusRate = rateConfig.Commission_Amount__c;

							if (opportunity.Accelerator_Stage_1__c) {
								specialtyContactsBonusRate = rateConfig.Inflated_Rate__c;
							}

							opportunity.Specialty_Contacts_Bonus__c = opportunity.Additional_Specialty_Contacts__c * specialtyContactsBonusRate;
						}else {
							opportunity.Specialty_Contacts_Bonus__c = 0.00;
						}
					} else {
						opportunity.Additional_Specialty_Contacts__c = 0;
						opportunity.Specialty_Contacts_Bonus__c = 0.00;
					}
				} else {
					opportunity.Additional_Specialty_Contacts__c = 0;
					opportunity.Specialty_Contacts_Bonus__c = 0.00;
				}
			}
		}
	}

	/*******************************************************************************************************
	* @description 	 Calculates qualificaitons type for each accountId given in the accountIdsToRecalculate
	*                param and it return a map with the key being the account id and the value being the 
	*                Qualificaiton Type Value Object which contains the highest priority qualification type
	*                as well as the number of qualifications for the given account
	*
	* @return 		 void
	* 
	*/
	@TestVisible
	private static Map<String, CommissionUtils.QualificationTypeVo> getQualificationTypeByAccountIds(Set<String> accountIdsToRecalculate) {
	
		if (SetUtils.isNullOrEmpty(accountIdsToRecalculate)) return null;

		Map<Id, Account> accountWithContactsMap = ContactService.getNpiContactForAccountIds(new List<String>(accountIdsToRecalculate), 
																					   new List<String>{'Id'}, 
																					   new List<String>{'Id', 'NPI__c', 
																					   					'Qualification_Type__c', 
																					   					'Qualification__c'});

		Map<String, CommissionUtils.QualificationTypeVo> accountToQualificationTypeMap = new Map<String, CommissionUtils.QualificationTypeVo>();

		for (String accountId :accountWithContactsMap.keySet()) {
			
			CommissionUtils.QualificationTypeVo qualificationType = CommissionUtils.getInstance()
																.calculateQualificationsInformationForAccount(
																accountWithContactsMap.get(accountId)
															);													
			accountToQualificationTypeMap.put(accountId, qualificationType);
		}
		return accountToQualificationTypeMap;
	}

	/*******************************************************************************************************
	* @description 			Method will update the Owner's Team field on Opportunity which is mapped and used 
	*                 		for commissions calculation though custom settings
	* 
	* @param 				[Map<Id, Opportunity> oldOpportunitiesMa]
	* @param 				[List<Opportunity> opportunitiesNew]
	* @return 				void
	* 
	*/
	public static void updateCommissionRateFieldsForOwner(List<Opportunity> opportunitiesNew, Map<Id, Opportunity> oldOpportunitiesMap) {
		
		List<Opportunity> opportunitiesEligbleForCommissionCalculation = null; // list of opportunities with the enabled record type

		if (ListUtils.isNullOrEmpty(opportunitiesNew)) {
			return;// exit method nothing to process
		} else {
			opportunitiesEligbleForCommissionCalculation = CommissionUtils.getInstance().getEligibleOpportunitiesForCommission(opportunitiesNew);
		}

		if (oldOpportunitiesMap == null && ListUtils.isNotNullOrEmpty(opportunitiesEligbleForCommissionCalculation)) { // Handle Insert Trigger(s)

            Map<Id, User> opportunityOwnersMap = new Map<Id, User>(getOpportunityOwners(opportunitiesEligbleForCommissionCalculation, new List<String>{'Id', 'UserRoleId', 'Number_of_Opp_Closed_Won_Current_Month__c'}));
			
			for (Opportunity opportunity :opportunitiesEligbleForCommissionCalculation) {
				User opportunityOwner = opportunityOwnersMap.get(opportunity.OwnerId);
				setOpportunityCommissionOwnerInfo(opportunityOwner.UserRoleId, (Integer)opportunityOwner.Number_of_Opp_Closed_Won_Current_Month__c, opportunity);
			}
		} else if (ListUtils.isNotNullOrEmpty(opportunitiesEligbleForCommissionCalculation)) { // Handle Update Trigger(s)
			List<Opportunity> opportunitiesWithChangedOwner = new List<Opportunity>();

			for (Opportunity opportunity :opportunitiesEligbleForCommissionCalculation) {
				if (!StringUtils.equalsIgnoreCase(
						opportunity.OwnerId, oldOpportunitiesMap.get(opportunity.Id).OwnerId
					)) {
				
					opportunitiesWithChangedOwner.add(opportunity);
				}
			}
			if (ListUtils.isNotNullOrEmpty(opportunitiesWithChangedOwner)) {
				Map<Id, User> opportunityOwnersMap = new Map<Id, User>(getOpportunityOwners(opportunitiesEligbleForCommissionCalculation, new List<String>{'Id', 'UserRoleId', 'Number_of_Opp_Closed_Won_Current_Month__c'}));
				for (Opportunity opportunityChanged :opportunitiesWithChangedOwner) {
					User opportunityOwner = opportunityOwnersMap.get(opportunityChanged.OwnerId);
					setOpportunityCommissionOwnerInfo(opportunityOwner.UserRoleId, (Integer)opportunityOwner.Number_of_Opp_Closed_Won_Current_Month__c, opportunityChanged);
				}
			}
		}
	}

	/*******************************************************************************************************
	* @description  Checks updated Opportunities to determine whether or not Contracts
	*				should be created. If the opportunity in question is updated to the
	*				'In Contracting' stage and doesn't yet have a contract assigned,
	*				one will be created.
	* @param 		trigger.oldMap
	* @param 		trigger.new
	* @return 		void
	* @example		
	* 
	*/
	public static void syncContracts(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunities) {
		Map<Id, Contract> contracts = new Map<Id, Contract>();
		for (Opportunity opportunity : opportunities) {
			Opportunity oldOpportunity = oldOpportunities.get(opportunity.Id);
			if (opportunity.StageName == 'In Contracting'
				&& (opportunity.Amount != oldOpportunity.Amount
					|| oldOpportunity.StageName != 'In Contracting')) {
				contracts.put(
					opportunity.Id,
					new Contract(
						Id = opportunity.ContractId,
						AccountId = opportunity.AccountId,
						Agency__c = opportunity.Agency__c,
						ContractAmount__c = opportunity.Amount,
						CountryCode__c = opportunity.CountryCode__c,
						Name = opportunity.Name + (opportunity.ContractId == null ? ' - Master' : '')
					)
				);
			}
		}

		if (!contracts.isEmpty()) {
			try {
				upsert contracts.values();
			}
			catch (DmlException ex) {
				LoggingUtils.log(ex, true, true, false);
			}

			for (Opportunity opportunity : opportunities) {
				if (contracts.get(opportunity.Id) != null) {
					opportunity.ContractId = contracts.get(opportunity.Id).Id;
				}
			}
		}
	}
	
	/*******************************************************************************************************
	* @description 	Method will take UserRoleId and an Opportunity and will set the opportunity fields: 
	*               Owner_Team__c, Owner_Specialty__c based on Role_Team_Map__c custom setting mapping related
	*               to commission calculation logic
	* 
	* @param 		[String opportunityOwnerRoleId]		opportunity owner's role which is mapped to a specialty and team in Role_Team_Map__c custom setting
	* @param 		[Opportunity opportunity]			The Opportunity which will have its Owner_Team__c and Owner_Specialty__c 
	*                       							fields updated based on the custom setting mapping
	* @return 		void
	* 
	*/
	@TestVisible
	private static void setOpportunityCommissionOwnerInfo(String opportunityOwnerRoleId, Integer ownerClosedOpportunities, Opportunity opportunity) {
		Role_Team_Map__c ownerTeamRole = CommissionUtils.getInstance().getUserRoleTeamInfo(opportunityOwnerRoleId);

		if(ownerTeamRole != null) {
			opportunity.Owner_Team__c = ownerTeamRole.Team__c;
			opportunity.Owner_Specialty__c = ownerTeamRole.Specialty__c;
		} else {
			opportunity.Owner_Team__c = 'None';
			opportunity.Owner_Specialty__c = 'None';
		}
		CommissionUtils.getInstance().assignAcceleratorStageToOpportunity(opportunity.Owner_Team__c, ownerClosedOpportunities, opportunity);
	}

	/*******************************************************************************************************
	* @description 	Updates user counter field(s) for closed won opportunities
	* 
	*/
	public static void updateOpportunitiesCounterForUser(List<Opportunity> opportunities, Map<Id, Opportunity> opportunitiesOldMap) {
		
		List<Opportunity> eligibleOpportunities = null;

		if (ListUtils.isNotNullOrEmpty(opportunities)) {
			eligibleOpportunities = CommissionUtils.getInstance().getEligibleOpportunitiesForCommission(opportunities);
		} else {
			return; // nothing to process, 
		}

		if (ListUtils.isNullOrEmpty(eligibleOpportunities) || (opportunitiesOldMap == null || opportunitiesOldMap.size() < 1)) {
			return;
		} else { // Process Only Eligible Opportunities
			List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

			Set<String> opportunitiesClosedWonIds = new Set<String>();
			Set<String> opportunitiesPaidIds = new Set<String>();
			Set<String> opportunitiesOwnerIds = new Set<String>();

			for (Opportunity opportunity :eligibleOpportunities) {
				
				Opportunity oldOpportunity = opportunitiesOldMap.get(opportunity.Id);
				// incerement counter
				if (oldOpportunity != null & opportunity.StageName != oldOpportunity.StageName
					&& opportunity.StageName.equalsIgnoreCase('Closed Won')) {

					opportunitiesOwnerIds.add(opportunity.OwnerId);
					opportunitiesClosedWonIds.add(opportunity.Id);
					opportunitiesToUpdate.add(opportunity);

				//decrement counter for paid opportunities
				} else if (oldOpportunity != null & opportunity.PaidOn__c != oldOpportunity.PaidOn__c
					&& opportunity.PaidOn__c != null) {

					opportunitiesOwnerIds.add(opportunity.OwnerId);
					opportunitiesPaidIds.add(opportunity.Id);
					opportunitiesToUpdate.add(opportunity);
				}
			}

			if (ListUtils.isNotNullOrEmpty(opportunitiesToUpdate)) {

				Map<Id, User> opportunityOwnersMap = new Map<Id, User>(UserService.getByIds(new List<String>(opportunitiesOwnerIds), 
																							new List<String>{'Id', 'Number_Of_Opportunities_Closed_Unpaid__c',
																					 						 'Number_of_Opp_Closed_Won_Current_Month__c'}));

				for (Opportunity opportunity :opportunitiesToUpdate) {
					
					User userTemp = opportunityOwnersMap.get(opportunity.OwnerId);
					
					if (userTemp != null) {

						if (opportunitiesClosedWonIds.contains(opportunity.Id)) {
							
							userTemp.Number_Of_Opportunities_Closed_Unpaid__c ++;
							userTemp.Number_of_Opp_Closed_Won_Current_Month__c ++;
							CommissionUtils.getInstance().assignAcceleratorStageToOpportunity(opportunity.Owner_Team__c, (Integer)userTemp.Number_of_Opp_Closed_Won_Current_Month__c, opportunity);
							
						} else if (opportunitiesPaidIds.contains(opportunity.Id)) {
							userTemp.Number_Of_Opportunities_Closed_Unpaid__c --;
						}
					}
				}
				update opportunityOwnersMap.values();
			}
		}
	}

	/*******************************************************************************************************
	* @description 	Method determine opportunities which have been moved to Close Won and it gathers their Ids
	*               which will be used to assign squads in AccountSquadAssignmentService class
	* @param 		[List<Opportunity> opportunitiesListNew] -> New Opportunities from Opportunity Trigger
	* @param 		[Map<Id, Opportunity> opportunitiesMapOld] -> Old Opportunities Map from Opportunity Trigger
	* @return 		void
	* 
	*/
	public static void accountSquadAssignmentForClosedWonOpportunities(List<Opportunity> opportunitiesListNew, Map<Id, Opportunity> opportunitiesMapOld) {
		
		Set<Id> opportunityIds = new Set<Id>();

		for (Opportunity opportunity :opportunitiesListNew) {

			if(opportunitiesMapOld.containsKey(opportunity.id) && 
				opportunity.isWon && 
				!opportunitiesMapOld.get(opportunity.id).isWon) {
				opportunityIds.add(opportunity.Id);
			}
		}
		if (opportunityIds.size() > 0) {
			AccountSquadAssignmentService.assignSquadsForAccounts(opportunityIds);
		}
	}
}
