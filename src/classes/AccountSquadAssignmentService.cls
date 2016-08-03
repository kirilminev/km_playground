/*******************************************************************************************************
* @description   Logic to assign squad member to an account based on zip code
* 
*/
public without sharing class AccountSquadAssignmentService {

	private static final String ACCOUNT_SQUAD_ASSIGNMENTx = 'Account_Squad_Assignment__c';

	public static List<Account_Squad_Assignment__c> getByZip3Codes(List<String> zip3Codes, List<String> fields) {
		
		String soql = new SoqlBuilder()
						    .selectx(fields)
						    .fromx(ACCOUNT_SQUAD_ASSIGNMENTx)
						    .wherex(new AndCondition()
						    	.add(new SetCondition('Zip_3__c').inx(zip3Codes))
						    	)
						    .toSoql();

	    return Database.query(soql);
	}
	
	public static void assignSquadsForAccounts(Set<Id> opportunityIds) {
		if (System.isFuture()) {
			assignSquadsForAccountsSynchronous(opportunityIds);
		} else {
			assignSquadsForAccountsFuture(opportunityIds);
		}
	}

	@TestVisible
	private static void assignSquadsForAccountsSynchronous(Set<Id> opportunityIds) {
		
		List<Opportunity> opportunities = OpportunityService.getByIds(new List<Id>(opportunityIds), 
																	  new List<String>{'Id', 'Owner_Specialty__c', 
																	  				   'AccountId', 
																	  				   'Account.BillingPostalCode'});

		Set<Id>accountIds = new Set<Id>();
		Set<Integer> zip3Codes = new Set<Integer>();

		for (Opportunity opportunity :opportunities) {
			if (opportunity.Account != null && String.isNotEmpty(opportunity.Account.BillingPostalCode)) {
				zip3Codes.add(Integer.valueOf(opportunity.Account.BillingPostalCode.left(3)));
			}
		}

		if (zip3Codes != null && zip3Codes.size() > 0) {
			Map<String, Account_Squad_Assignment__c> squadAssignmentMap = getSquadAssignmentMapForZip3Codes(new List<Integer>(zip3Codes));

			if (squadAssignmentMap != null && squadAssignmentMap.size() > 0) {
				Map<Id, Account> accountsToUpdate = new Map<Id, Account>();

				for (Opportunity opportunity :opportunities) {

					Account_Squad_Assignment__c accountSquadAssignment = getAccountSquadAssignmentByKey(Integer.valueOf(opportunity.Account.BillingPostalCode.left(3)), 
																										opportunity.Owner_Specialty__c,
																										squadAssignmentMap);

					if (accountSquadAssignment != null) {
						accountsToUpdate.put(opportunity.AccountId, new Account(Id = opportunity.AccountId, 
																				MSE__c = accountSquadAssignment.MSE_User__c, 
																				Network_Health_Specialist__c = accountSquadAssignment.NHS_User__c));	
					}
				}
				if (accountsToUpdate != null && accountsToUpdate.values().size() > 0) {
					update accountsToUpdate.values();
				}

			}  else {
				LoggingUtils.log(new LoggingUtils.CustomException('Account_Squad_Assignment__c object is empty and therefore the Account Squad Assignment functionality will not work properly!'), true, true, true);
			}
		}
	}

	@future(callout=false)
	private static void assignSquadsForAccountsFuture(Set<Id> opportunityIds) {
		assignSquadsForAccountsSynchronous(opportunityIds);
	}

	/*******************************************************************************************************
	* @description 		Method take a list of 3 digits or less zip codes (just the first 3 digits of the zip)
	*                	and it will query against the Account_Squad_Assignment__c for all available records
	*                 	With the queried records it will build a map which will have the value as the Account_Squad_Assignment__c
	*                 	record and the key following this convention: Zip3Code + '___' + Specialty__c
	*                 	key example: 600___Dermatology or 001 will be 1___Dermatology        	
	* @param 			[List<Integer> zip3Codes]
	* @return 			[Map<String, Account_Squad_Assignment__c>]
	* 
	*/
	@TestVisible
	private static Map<String, Account_Squad_Assignment__c>  getSquadAssignmentMapForZip3Codes(List<Integer> zip3Codes) {

		Map<String, Account_Squad_Assignment__c> mapResult = new Map<String, Account_Squad_Assignment__c>();

		List<String> zip3CodesStrings = new List<String>();

		for (Integer zip3Integer :zip3Codes) {
			zip3CodesStrings.add(String.valueOf(zip3Integer));
		}

		List<Account_Squad_Assignment__c> squadAssignmentData = getByZip3Codes(zip3CodesStrings, new List<String>{'MSE_User__c', 
																												  'NHS_User__c', 
																											   	  'Specialty__c',
																											   	  'Zip_3__c'});
		if (squadAssignmentData != null) {
			for (Account_Squad_Assignment__c accountSquadAssignmentObject :squadAssignmentData) {
				mapResult.put(accountSquadAssignmentObject.Zip_3__c + '___' + accountSquadAssignmentObject.Specialty__c, accountSquadAssignmentObject);
			}
		}
		return mapResult;
	}

	/*******************************************************************************************************
	* @description 		Builds up a key for given map of squads to follow key naming convention and returns
	*                	Account_Squad_Assignment__c object for the given variables that make up the key.
	*                	When squad is not found for given specialty it will try with specialty Other as fall-back
	*                	scenario
	* 
	*/
	@TestVisible
	private static Account_Squad_Assignment__c getAccountSquadAssignmentByKey(Integer zip3Code, 
																			  String opportunityOwnerSpecialty, 
																			  Map<String, Account_Squad_Assignment__c> squadAssignmentMap) {
		if (squadAssignmentMap != null) {
			
			String squadAssignmentKey = null;

			if (String.isNotEmpty(opportunityOwnerSpecialty)) {

				if(opportunityOwnerSpecialty.equalsIgnoreCase('None') 
					|| opportunityOwnerSpecialty.equalsIgnoreCase('Other')) {
					squadAssignmentKey = zip3Code + '___' + 'Other';
				} else {
					squadAssignmentKey = zip3Code + '___' + opportunityOwnerSpecialty;	
				}
			} else {
				squadAssignmentKey = zip3Code + '___' + 'Other';
			}

			Account_Squad_Assignment__c squadTemp = squadAssignmentMap.get(squadAssignmentKey);

			if (squadTemp == null) { //fall-back scenario, try with specialty other
				squadTemp = squadAssignmentMap.get(zip3Code + '___' + 'Other');
			}

			return squadTemp;
		} else {
			return null;		
		}
	}
}