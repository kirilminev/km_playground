/*******************************************************************************************************
* @description 		Test Coverage for AccountSquadAssignmentService
* 
*/
@isTest
private class AccountSquadAssignmentServiceTest
{	
	static final Id memberServicesProfileId = '00eC0000001KUaxIAG';
	static final Id networkHealthProfileId = '00eC0000001KgUrIAK';

	static final String zip3Code1 = '600';
	static final String zip3Code2 = '6';
	static final String zip3Code3 = '1';
	static final String zip3Code4 = '650';
	static final String zip3Code5 = '656';

	static final String billingZipCode1 = '60056';
	static final String billingZipCode2 = '00612';
	static final String billingZipCode3 = '00155';
	static final String billingZipCode4 = '65055';
	static final String billingZipCode5 = '65600';

	static final String specialtyDermatalogy = 'Dermatology';
	static final String specialtyOther = 'Other';

	static Id mseId1;
	static Id mseId2;
	static Id mseId3;
	static Id mseId4;
	static Id mseId5;

	static Id nhsId1;
	static Id nhsId2;
	static Id nhsId3;
	static Id nhsId4;
	static Id nhsId5;

	static RecordType membershipOpportunityRecordType;

	static { /* Using static block to persist staic variables for user ids. We are not using @TestSetup as it will clear the static vars for each unit test */

		membershipOpportunityRecordType = RecordTypeService.getByNameAndObjectType('Membership', 'Opportunity', new List<String>{'Id'});

		List<User> mseUsers = [Select Id From User WHERE isActive = true and ProfileId = :memberServicesProfileId limit 5];
		List<User> nhsUsers = [Select Id From User WHERE isActive = true and ProfileId = :networkHealthProfileId limit 5];

		System.assertNotEquals(null, mseUsers, 'No active MSE users were returned');
		System.assertEquals(5, mseUsers.size(), '5 MSE users expected');

		System.assertNotEquals(null, nhsUsers, 'No active NHS users were returned');
		System.assertEquals(5, nhsUsers.size(), '5 NHS users expected');

		mseId1 = mseUsers[0].Id;
		mseId2 = mseUsers[1].Id;
		mseId3 = mseUsers[2].Id;
		mseId4 = mseUsers[3].Id;
		mseId5 = mseUsers[4].Id;

		nhsId1 = nhsUsers[0].Id;
		nhsId2 = nhsUsers[1].Id;
		nhsId3 = nhsUsers[2].Id;
		nhsId4 = nhsUsers[3].Id;
		nhsId5 = nhsUsers[4].Id;
	}

	@isTest
	static void assignSquadsForAccountsTest() {

		List<Account_Squad_Assignment__c> accountSquadAssignmentList = new List<Account_Squad_Assignment__c>();

		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code1, 
									  							      					MSE_User__c = mseId1,
									  							      					NHS_User__c = nhsId1,
									  							      					Specialty__c = specialtyDermatalogy));
		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code1, 
									  							      					MSE_User__c = mseId1,
									  							      					NHS_User__c = nhsId1,
									  							      					Specialty__c = specialtyOther));

		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code2, 
									  							      					MSE_User__c = mseId2,
									  							      					NHS_User__c = nhsId2,
									  							      					Specialty__c = specialtyDermatalogy));
		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code2, 
									  							      					MSE_User__c = mseId2,
									  							      					NHS_User__c = nhsId2,
									  							      					Specialty__c = specialtyOther));

		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code3, 
									  							      					MSE_User__c = mseId3,
									  							      					NHS_User__c = nhsId3,
									  							      					Specialty__c = specialtyDermatalogy));
		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code3, 
									  							      					MSE_User__c = mseId3,
									  							      					NHS_User__c = nhsId3,
									  							      					Specialty__c = specialtyOther));

		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code4, 
									  							      					MSE_User__c = mseId4,
									  							      					NHS_User__c = nhsId4,
									  							      					Specialty__c = specialtyDermatalogy));
		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code4, 
									  							      					MSE_User__c = mseId4,
									  							      					NHS_User__c = nhsId4,
									  							      					Specialty__c = specialtyOther));

		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code5, 
									  							      					MSE_User__c = mseId5,
									  							      					NHS_User__c = nhsId5,
									  							      					Specialty__c = specialtyDermatalogy));
		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code5, 
									  							      					MSE_User__c = mseId5,
									  							      					NHS_User__c = nhsId5,
									  							      					Specialty__c = specialtyOther));

		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code5, 
									  							      					MSE_User__c = mseId5,
									  							      					NHS_User__c = nhsId5,
									  							      					Specialty__c = 'Cardiology'));


		insert accountSquadAssignmentList;

		Account account1 = new Account(Name = 'Test Account 1', BillingPostalCode = billingZipCode1);
		Account account2 = new Account(Name = 'Test Account 2', BillingPostalCode = billingZipCode2);
		Account account3 = new Account(Name = 'Test Account 3', BillingPostalCode = billingZipCode3);
		Account account4 = new Account(Name = 'Test Account 4', BillingPostalCode = billingZipCode4);
		Account account5 = new Account(Name = 'Test Account 5', BillingPostalCode = billingZipCode5);

		List<Account> accounts = new List<Account>{account1, account2, account3, account4, account5};
		insert accounts;

		accounts = [Select Id, BillingPostalCode, MSE__c, Network_Health_Specialist__c FROM Account WHERE Id in :new Map<Id, Account>(accounts).keySet()];

		for (Account account :accounts) { //make sure MSE__c and Network_Health_Specialist__c have not been set by any other trigger
			System.assertEquals(null, account.MSE__c);
			System.assertEquals(null, account.Network_Health_Specialist__c);
			System.assertNotEquals(null, account.BillingPostalCode);
		}

		Opportunity opportunity1 = new Opportunity(RecordTypeId = membershipOpportunityRecordType.Id,
												   Name = 'Opportunity Test 1',
												   StageName = 'New',
												   AccountId = account1.Id,
												   Owner_Specialty__c = 'Dermatology',
												   CloseDate = Date.Today().addDays(30));

		Opportunity opportunity2 = new Opportunity(RecordTypeId = membershipOpportunityRecordType.Id,
												   Name = 'Opportunity Test 2',
												   StageName = 'New',
												   AccountId = account2.Id,
												   Owner_Specialty__c = 'Dermatology',
												   CloseDate = Date.Today().addDays(30));

		Opportunity opportunity3 = new Opportunity(RecordTypeId = membershipOpportunityRecordType.Id,
												   Name = 'Opportunity Test 3',
												   StageName = 'New',
												   AccountId = account3.Id,
												   Owner_Specialty__c = 'None',
												   CloseDate = Date.Today().addDays(30));

		Opportunity opportunity4 = new Opportunity(RecordTypeId = membershipOpportunityRecordType.Id,
												   Name = 'Opportunity Test 4',
												   StageName = 'New',
												   AccountId = account4.Id,
												   Owner_Specialty__c = 'Dermatology',
												   CloseDate = Date.Today().addDays(30));
		
		Opportunity opportunity5 = new Opportunity(RecordTypeId = membershipOpportunityRecordType.Id,
												   Name = 'Opportunity Test 5',
												   StageName = 'New',
												   Owner_Specialty__c = 'Cardiology',
												   AccountId = account5.Id,
												   CloseDate = Date.Today().addDays(30));
		
		List<Opportunity> opportunities = new List<Opportunity>{opportunity1, opportunity2, opportunity3, opportunity4, opportunity5};

		insert opportunities;

		Test.startTest();
		AccountSquadAssignmentService.assignSquadsForAccounts(new Map<Id, Opportunity>(opportunities).keySet());
		Test.stopTest();

		Map<Id, Account> accountsMap = new Map<Id, Account>([Select Id, BillingPostalCode, MSE__c, Network_Health_Specialist__c FROM Account WHERE Id in :new Map<Id, Account>(accounts).keySet()]);

		System.assertEquals(mseId1, accountsMap.get(account1.Id).MSE__c);
		System.assertEquals(nhsId1, accountsMap.get(account1.Id).Network_Health_Specialist__c);

		System.assertEquals(mseId2, accountsMap.get(account2.Id).MSE__c);
		System.assertEquals(nhsId2, accountsMap.get(account2.Id).Network_Health_Specialist__c);

		System.assertEquals(mseId3, accountsMap.get(account3.Id).MSE__c);
		System.assertEquals(nhsId3, accountsMap.get(account3.Id).Network_Health_Specialist__c);

		System.assertEquals(mseId4, accountsMap.get(account4.Id).MSE__c);
		System.assertEquals(nhsId4, accountsMap.get(account4.Id).Network_Health_Specialist__c);

		System.assertEquals(mseId5, accountsMap.get(account5.Id).MSE__c);
		System.assertEquals(nhsId5, accountsMap.get(account5.Id).Network_Health_Specialist__c);

		for (Account account :accounts) { // clear assigned squad so we can test the Opportunity trigger as well
			account.MSE__c = null;
			account.Network_Health_Specialist__c = null;
		}

		update accounts;

		accounts = [Select Id, MSE__c, Network_Health_Specialist__c, BillingPostalCode From Account Where Id in:new Map<Id, Account>(accounts).keySet()];

		for (Account account :accounts) { // check if after trigger all accounts squad members have been cleared
			System.assertEquals(null, account.MSE__c, 'MSE Squad Member expceted to be unassigned/blank.');
			System.assertEquals(null, account.Network_Health_Specialist__c, 'NHS Squad Member expceted to be unassigned/blank.');
		}
	}

	@isTest
	static void assignSquadsForAccountsOpportunityTriggerTest() {

		List<Account_Squad_Assignment__c> accountSquadAssignmentList = new List<Account_Squad_Assignment__c>();

		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code1, 
									  							      					MSE_User__c = mseId1,
									  							      					NHS_User__c = nhsId1,
									  							      					Specialty__c = specialtyDermatalogy));
		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code1, 
									  							      					MSE_User__c = mseId1,
									  							      					NHS_User__c = nhsId1,
									  							      					Specialty__c = specialtyOther));

		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code2, 
									  							      					MSE_User__c = mseId2,
									  							      					NHS_User__c = nhsId2,
									  							      					Specialty__c = specialtyDermatalogy));
		accountSquadAssignmentList.add(new Account_Squad_Assignment__c(Zip_3__c = zip3Code2, 
									  							      					MSE_User__c = mseId2,
									  							      					NHS_User__c = nhsId2,
									  							      					Specialty__c = specialtyOther));
		insert accountSquadAssignmentList;

		Account account1 = new Account(Name = 'Test Account 1', BillingPostalCode = billingZipCode1);
		Account account2 = new Account(Name = 'Test Account 2', BillingPostalCode = billingZipCode2);

		List<Account> accounts = new List<Account>{account1, account2};
		insert accounts;

		Map<Id, Account> accountsMap = new Map<Id, Account>(accounts);

		accounts = [Select Id, MSE__c, Network_Health_Specialist__c, BillingPostalCode From Account Where Id in:new Map<Id, Account>(accounts).keySet()];

		for (Account account :accounts) { // check if after trigger all accounts squad members have been cleared
			System.assertEquals(null, account.MSE__c, 'MSE Squad Member expceted to be unassigned/blank.');
			System.assertEquals(null, account.Network_Health_Specialist__c, 'NHS Squad Member expceted to be unassigned/blank.');
		}

		Opportunity opportunity1 = new Opportunity(RecordTypeId = membershipOpportunityRecordType.Id,
												   Name = 'Opportunity Test 1',
												   StageName = 'New',
												   AccountId = account1.Id,
												   Owner_Specialty__c = 'Dermatology',
												   CloseDate = Date.Today().addDays(30));

		Opportunity opportunity2 = new Opportunity(RecordTypeId = membershipOpportunityRecordType.Id,
												   Name = 'Opportunity Test 2',
												   StageName = 'New',
												   AccountId = account2.Id,
												   CloseDate = Date.Today().addDays(30));

		List<Opportunity> opportunities = new List<Opportunity>{opportunity1, opportunity2};

		insert opportunities;

		accounts = [Select Id, MSE__c, Network_Health_Specialist__c, BillingPostalCode From Account Where Id in:new Map<Id, Account>(accounts).keySet()];

		for (Account account :accounts) { // check if after trigger all accounts squad members have been cleared
			System.assertEquals(null, account.MSE__c, 'MSE Squad Member expceted to be unassigned/blank.');
			System.assertEquals(null, account.Network_Health_Specialist__c, 'NHS Squad Member expceted to be unassigned/blank.');
		}

		opportunity1.StageName = 'Closed Won';
		opportunity2.StageName = 'Closed Won';

		Test.startTest();
		update new List<Opportunity>{opportunity1, opportunity2};
		Test.stopTest();

		accountsMap = new Map<Id, Account>([Select Id, MSE__c, Network_Health_Specialist__c, BillingPostalCode From Account Where Id in:accountsMap.keySet()]);

		System.assertEquals(mseId1, accountsMap.get(account1.Id).MSE__c);
		System.assertEquals(nhsId1, accountsMap.get(account1.Id).Network_Health_Specialist__c);
		System.assertEquals(mseId2, accountsMap.get(account2.Id).MSE__c);
		System.assertEquals(nhsId2, accountsMap.get(account2.Id).Network_Health_Specialist__c);
	}
}