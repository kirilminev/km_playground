/*******************************************************************************************************
* @description  Test Unit Coverage for OpportunityService class
* 
*/
@isTest
private class OpportunityServiceTest
{
	private static final String TEST_ACCOUNT_NAME_1 = 'TestAccount1';
	private static final String TEST_ACCOUNT_NAME_2 = 'TestAccount2';
	private static final String PRICEBOOK_NAME =  'Membership';

	@testSetup
	private static void setupData() {

		TestDataService.setupQualificaitonsCustomSetting();
		TestDataService.setupCommissionRateSpecialtyContacts();
		TestDataService.setupRoleTeamMaps();
		TestDataService.setupCommissionsCalculatorGlobalSettings();

		Account account1 = new Account(Name = TEST_ACCOUNT_NAME_1);
		Account account2 = new Account(Name = TEST_ACCOUNT_NAME_2);
		insert new List<Account>{account1, account2};

		RecordType membershipRecordType = RecordTypeService.getByNameAndObjectType('Membership', 'Opportunity', new List<String>{'Id'});

		Opportunity opportunity1 = new Opportunity(RecordTypeId = membershipRecordType.Id, Name = 'Test1', StageName = 'New', CloseDate = Date.Today().addDays(10), AccountId = account1.Id);
		Opportunity opportunity2 = new Opportunity(RecordTypeId = membershipRecordType.Id, Name = 'Test2', StageName = 'New', CloseDate = Date.Today().addDays(10), AccountId = account1.Id);
		Opportunity opportunity3 = new Opportunity(RecordTypeId = membershipRecordType.Id, Name = 'Test3', StageName = 'Closed Won', CloseDate = Date.Today().addDays(10), AccountId = account2.Id);
		Opportunity opportunity4 = new Opportunity(RecordTypeId = membershipRecordType.Id, Name = 'Test4', StageName = 'New', CloseDate = Date.Today().addDays(10), AccountId = account2.Id);
		Opportunity opportunity5 = new Opportunity(RecordTypeId = membershipRecordType.Id, Name = 'Test5', StageName = 'New', CloseDate = Date.Today().addDays(10), AccountId = account2.Id);
		Opportunity opportunity6 = new Opportunity(RecordTypeId = membershipRecordType.Id, Name = 'Test6', StageName = 'New', CloseDate = Date.Today().addDays(10), AccountId = account2.Id);

		insert new List<Opportunity>{opportunity1, opportunity2, opportunity3, opportunity4, opportunity5, opportunity6};

		TestDataService.setupPriceBookWithProducts(PRICEBOOK_NAME);
	}

	@isTest
	private static void getByIdTest() {
		Opportunity opportunityTest = [Select Id, Name From Opportunity limit 1];

		Opportunity opportunityById = OpportunityService.getById(opportunityTest.Id, new List<String>{'Id', 'Name'});

		System.assertEquals(opportunityTest.Name, opportunityById.Name);
	}

	@isTest
	private static void getByIdsTest() {

		Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>([Select Id, Name From Opportunity]);

		List<Opportunity> opportunitiesById = OpportunityService.getByIds(new List<Id>(opportunitiesMap.keySet()), new List<String>{'Id', 'Name'});

		for (Opportunity opportunity :opportunitiesById) {
			System.assertNotEquals(null, opportunitiesMap.get(opportunity.Id));
		}
	}	

	@isTest
	private static void getOpenOpportunitiesByAccountIdsTest(){

		Account account1 = [SELECT Id FROM Account WHERE Name = :TEST_ACCOUNT_NAME_1 LIMIT 1][0];
		List<String> accountIds = new List<String>{account1.Id};

		List<Opportunity> openOpportunities = OpportunityService.getOpenOpportunitiesByAccountIds(accountIds, 
													  	    new List<String>{'Id', 'Name', 'isClosed'});

		System.assertEquals(2, openOpportunities.size());

		Account account2 = [SELECT Id FROM Account WHERE Name = :TEST_ACCOUNT_NAME_2 LIMIT 1][0];
		accountIds = new List<String>{account2.Id};

		openOpportunities.clear();
		openOpportunities = OpportunityService.getOpenOpportunitiesByAccountIds(accountIds, 
													  	    new List<String>{'Id', 'Name', 'isClosed'});

		System.assertEquals(3, openOpportunities.size());
	}

	@isTest
	private static void getByIdsWithOpportunityLineItemsTest() {

		Opportunity opportunityTest = [Select Id From Opportunity limit 1];

		List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();

		Pricebook2 membership = [Select Id, (Select Id From PricebookEntries) From Pricebook2 Where Name = :PRICEBOOK_NAME];

		opportunityLineItems.add(new OpportunityLineItem(
			OpportunityId = opportunityTest.Id,
			PricebookEntryId = membership.PricebookEntries[0].Id,
			Quantity = 1,
			TotalPrice = 0
		));

		opportunityLineItems.add(new OpportunityLineItem(
			OpportunityId = opportunityTest.Id,
			PricebookEntryId = membership.PricebookEntries[0].Id,
			Quantity = 1,
			TotalPrice = 0
		));

		insert opportunityLineItems;

		Map<Id, OpportunityLineItem> opportunityLineItemsMap = new Map<Id, OpportunityLineItem>(opportunityLineItems);

		List<Opportunity> opportunities = OpportunityService.getByIdsWithOpportunityLineItems(new List<Id>{opportunityTest.Id}, 
															new List<String>{'Id', 'Name'}, 
															new List<String>{'Id', 'Name'});

		System.assert(ListUtils.isNotNullOrEmpty(opportunities[0].OpportunityLineItems));

		for (OpportunityLineItem opportunityLineItem :opportunities[0].OpportunityLineItems) {
			System.assertNotEquals(null, opportunityLineItemsMap.get(opportunityLineItem.Id));
		}
	}

	@isTest
	private static void recalculateOpenOpportunityQualificationTypeTest() {

		String qualificationTypeString = 'Specialty';

		List<Account> accounts = [Select Id, Name FROM Account limit 2];
		List<Opportunity> opportunities = [Select Id, AccountId, Qualification_Type__c From Opportunity Where AccountId = :accounts[0].Id limit 1];

		System.assertNotEquals(null, accounts);
		System.assertNotEquals(null, opportunities);

		System.assertNotEquals(qualificationTypeString, opportunities[0].Qualification_Type__c);

		Map<String, CommissionUtils.QualificationTypeVo> accountToQualificationTypeMap = new Map<String, CommissionUtils.QualificationTypeVo>();

		CommissionUtils.QualificationTypeVo qualificationTypeVo1 = new CommissionUtils.QualificationTypeVo();

		qualificationTypeVo1.highestPriorityQualificationType = qualificationTypeString;
		qualificationTypeVo1.numberOfContactPerQualification = new Map<String, Integer>{'Cardio' => 12};

		accountToQualificationTypeMap.put(accounts[0].Id, qualificationTypeVo1);

		opportunities[0].Owner_Team__c = 'PES';
		opportunities[0].Owner_Specialty__c = 'Cardio';

		OpportunityService.recalculateOpenOpportunityQualificationType(accountToQualificationTypeMap, opportunities);
		
		Commission_Rate_Specialty_Contacts__c rateCard = Commission_Rate_Specialty_Contacts__c.getInstance(qualificationTypeString);

		System.assertNotEquals(null, rateCard);

		System.assertEquals(qualificationTypeString, opportunities[0].Qualification_Type__c);
		System.assertEquals(11, opportunities[0].Additional_Specialty_Contacts__c);
		System.assertEquals((11 * rateCard.Commission_Amount__c), opportunities[0].Specialty_Contacts_Bonus__c);

		opportunities[0].Accelerator_Stage_1__c = true;

		OpportunityService.recalculateOpenOpportunityQualificationType(accountToQualificationTypeMap, opportunities);

		System.assertEquals((11 * rateCard.Inflated_Rate__c), opportunities[0].Specialty_Contacts_Bonus__c);

		opportunities[0].Owner_Specialty__c = 'Dermatology';

		OpportunityService.recalculateOpenOpportunityQualificationType(accountToQualificationTypeMap, opportunities);

		System.assertEquals(0, opportunities[0].Specialty_Contacts_Bonus__c);


		accountToQualificationTypeMap.put(accounts[0].Id, new CommissionUtils.QualificationTypeVo());

		OpportunityService.recalculateOpenOpportunityQualificationType(accountToQualificationTypeMap, opportunities);

		System.assertEquals(0, opportunities[0].Specialty_Contacts_Bonus__c);
		System.assertEquals(0, opportunities[0].Additional_Specialty_Contacts__c);
	}

	@isTest
	private static void updateCommissionRateFieldsForOwnerTest() {
		
		Map<String, Role_Team_Map__c> rolesMap = Role_Team_Map__c.getAll();
		List<Opportunity> opportunities = [Select Id, RecordTypeId, AccountId, OwnerId, Qualification_Type__c From Opportunity limit 2];

		System.assertNotEquals(null, opportunities);
		System.assertEquals(2, opportunities.size());

		OpportunityService.updateCommissionRateFieldsForOwner(opportunities, null);

		List<Opportunity> opportunityOld = opportunities.deepClone(true, true, true);

		Set<Id> opportunityOwnerIds = new Set<Id>();

		for (Opportunity opportunity :opportunities) {
			opportunityOwnerIds.add(opportunity.OwnerId);
		}

		List<UserRole> userRoles = [SELECT Id From UserRole WHERE Id NOT IN :rolesMap.keySet() limit 2];
		Map<Id, UserRole> userRolesMap = new Map<Id, UserRole>(userRoles);
		List<User> users = [SELECT Id, UserRoleId FROM User Where isActive = true AND Id NOT IN :opportunityOwnerIds limit 2];

		System.assertEquals(2, users.size());
		
		opportunities[0].OwnerId = users[0].Id;
		opportunities[1].OwnerId = users[1].Id;
		
		OpportunityService.updateCommissionRateFieldsForOwner(opportunities, new Map<Id, Opportunity>(opportunityOld));	
	}

	@isTest
	private static void setOpportunityCommissionOwnerInfoTest() {
		
		Opportunity opportunity1 = [Select Id, AccountId, OwnerId, Owner_Team__c, Owner_Specialty__c, 
											Qualification_Type__c, Accelerator_Stage_1__c, Accelerator_Stage_2__c
											From Opportunity limit 1];

		Map<String, Role_Team_Map__c> rolesMap = Role_Team_Map__c.getAll();

		for (Role_Team_Map__c role :rolesMap.values()) {
			OpportunityService.setOpportunityCommissionOwnerInfo(role.Name, 0, opportunity1);

			System.assertEquals(role.Team__c, opportunity1.Owner_Team__c);
			System.assertEquals(role.Specialty__c, opportunity1.Owner_Specialty__c);
			System.assertEquals(false, opportunity1.Accelerator_Stage_1__c);
			System.assertEquals(false, opportunity1.Accelerator_Stage_2__c);
		}

		//test with non-existant role
		OpportunityService.setOpportunityCommissionOwnerInfo('test_role_id', 0, opportunity1);

		System.assertEquals('None', opportunity1.Owner_Team__c);
		System.assertEquals('None', opportunity1.Owner_Specialty__c);
	}

	@isTest
	private static void updateOpportunitiesCounterForUser() {

		Account account1 = [SELECT Id FROM Account WHERE Name = :TEST_ACCOUNT_NAME_1 LIMIT 1][0];
		RecordType membershipRecordType = RecordTypeService.getByNameAndObjectType('Membership', 'Opportunity', new List<String>{'Id'});

		Map<String, Role_Team_Map__c> rolesMap = Role_Team_Map__c.getAll();

		List<User> users = [SELECT Id, UserRoleId, Number_of_Opp_Closed_Won_Current_Month__c, Number_Of_Opportunities_Closed_Unpaid__c 
														FROM User Where isActive = true AND UserRoleId IN :rolesMap.keySet() limit 5];
		Set<Id> userIds = new Set<Id>();

		List<Opportunity> opportunities = new List<Opportunity>();

		for (User user :users) {
			user.Number_Of_Opportunities_Closed_Unpaid__c = 0;
			user.Number_of_Opp_Closed_Won_Current_Month__c = 0;

			opportunities.add(new Opportunity(RecordTypeId = membershipRecordType.Id, 
												Name = 'Test1', StageName = 'New', 
												Owner_Team__c = 'PES',
												Owner_Specialty__c = 'Cardiology',
												CloseDate = Date.Today().addDays(10), 
												AccountId = account1.Id,
												OwnerId = user.Id));
			userIds.add(user.Id);
		}

		insert opportunities;
		update users;

		List<Opportunity> oldOpportunities = opportunities.deepClone(true, true, true);

		// Any opportunity that is being closed will increment the user fileds: Number_of_Opp_Closed_Won_Current_Month__c, Number_Of_Opportunities_Closed_Unpaid__c
		for (Opportunity opportunity :opportunities) {
			opportunity.StageName = 'Closed Won';
		}

		OpportunityService.updateOpportunitiesCounterForUser(opportunities, new Map<Id, Opportunity>(oldOpportunities));

		users = [SELECT Id, UserRoleId, Number_of_Opp_Closed_Won_Current_Month__c, 
						Number_Of_Opportunities_Closed_Unpaid__c 
						FROM User Where Id IN :userIds];

		for (User user :users) {
			System.assertEquals(1, user.Number_of_Opp_Closed_Won_Current_Month__c);
			System.assertEquals(1, user.Number_Of_Opportunities_Closed_Unpaid__c);
		}

		//decrement user counter for paid opportunities
		oldOpportunities = null;
		oldOpportunities = opportunities.deepClone(true, true, true);

		for (Opportunity opportunity :opportunities) {
			opportunity.PaidOn__c = Date.today();
			opportunity.PaidAmount__c = 1;
		}

		OpportunityService.updateOpportunitiesCounterForUser(opportunities, new Map<Id, Opportunity>(oldOpportunities));

		users = [SELECT Id, UserRoleId, Number_of_Opp_Closed_Won_Current_Month__c, 
						Number_Of_Opportunities_Closed_Unpaid__c 
						FROM User Where Id IN :userIds];

		for (User user :users) {
			System.assertEquals(1, user.Number_of_Opp_Closed_Won_Current_Month__c);
			System.assertEquals(0, user.Number_Of_Opportunities_Closed_Unpaid__c);
		}
	}

	@isTest
	private static void calculateQualificationTypeTest() {

		RecordType membershipRecordType = RecordTypeService.getByNameAndObjectType('Membership', 'Opportunity', new List<String>{'Id'});
		Account account1 = [SELECT Id, Name From Account WHERE Name = :TEST_ACCOUNT_NAME_1 limit 1];
		Account account2 = [SELECT Id, Name From Account WHERE Name = :TEST_ACCOUNT_NAME_2 limit 1];

		System.assertEquals(TEST_ACCOUNT_NAME_1, account1.Name);

		List<String> accountIds = new List<String>{account1.Id};

		Contact contact1 = new Contact(AccountId = account1.Id, LastName = 'LastName1', NPI__c = '1111111111', Qualification__c = 'Allergy');
		Contact contact2 = new Contact(AccountId = account1.Id, LastName = 'LastName2', NPI__c = '2222222222', Qualification__c = 'General Health');
		Contact contact3 = new Contact(AccountId = account1.Id, LastName = 'LastName3', NPI__c = '3333333333', Qualification__c = 'Not Qualified');
		Contact contact4 = new Contact(AccountId = account1.Id, LastName = 'LastName4', NPI__c = '4444444444', Qualification__c = 'Not Valid');
		
		List<Contact> contacts = new List<Contact>{ contact1,
													contact2,
													contact3,
													contact4
												  };

		insert contacts;

		contacts = [Select Id, AccountId, Qualification__c, LastName, Qualification_Type__c, NPI__c FROM Contact];
		
		System.assertEquals(4, contacts.size());
		System.assertNotEquals('PCP', contact1.Qualification_Type__c);
		System.assertNotEquals('Specialty', contact2.Qualification_Type__c);
		System.assertNotEquals('None', contact3.Qualification_Type__c);
		System.assertNotEquals('None', contact4.Qualification_Type__c);

		OpportunityService.calculateQualificationTypeForContacts(contacts, null);
		
		for (Opportunity opportunity :OpportunityService.getOpenOpportunitiesByAccountIds(accountIds, 
													  	    new List<String>{'Id', 'Name', 'isClosed', 'Qualification_Type__c'})) {
			System.assertEquals('PCP', opportunity.Qualification_Type__c);
		}

		Map<Id, Contact> contactsOldMap = new Map<Id, Contact>();

		for (Contact contact :contacts) {
			contactsOldMap.put(contact.Id, contact);
		}

		contact1.AccountId = account2.Id;// test if ipportunity qualification type will change upon contact.accoiuntId change
		update contact1;

		OpportunityService.calculateQualificationTypeForContacts(contacts, contactsOldMap);
		
		for (Opportunity opportunity :OpportunityService.getOpenOpportunitiesByAccountIds(accountIds, 
													  	    new List<String>{'Id', 'Name', 'isClosed', 'Qualification_Type__c'})) {
			System.assertEquals('General Health', opportunity.Qualification_Type__c);
		}

		contact1.AccountId = account1.Id;
		contact1.Qualification__c = 'Cardio;Allergy';
		update contact1;

		contact1 = [Select Id, Qualification_Type__c, Qualification__c FROM Contact where Id = :contact1.Id limit 1];

		System.assertEquals('Specialty', contact1.Qualification_Type__c);

		OpportunityService.calculateQualificationTypeForContacts(contacts, contactsOldMap);
		
		for (Opportunity opportunity :OpportunityService.getOpenOpportunitiesByAccountIds(accountIds, 
													  	    new List<String>{'Id', 'Name', 'isClosed', 'Qualification_Type__c'})) {
			System.assertEquals('Specialty', opportunity.Qualification_Type__c);
		}

		Opportunity opportunity1 = new Opportunity(RecordTypeId = membershipRecordType.Id, 
												   Name = 'Opportunity Test 1', 
												   StageName = 'New', 
												   CloseDate = Date.Today().addDays(10), 
												   AccountId = account1.Id);
		
		Opportunity opportunity2 = new Opportunity(RecordTypeId = membershipRecordType.Id, 
												   Name = 'Opportunity Test 2', 
												   StageName = 'New', 
												   CloseDate = Date.Today().addDays(10), 
												   AccountId = account1.Id);
		Opportunity opportunity3 = new Opportunity(RecordTypeId = membershipRecordType.Id, 
												   Name = 'Opportunity Test 2', 
												   StageName = 'New', 
												   CloseDate = Date.Today().addDays(10), 
												   AccountId = account2.Id);

		insert new List<Opportunity>{opportunity1, opportunity2, opportunity3};

		Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>([SELECT Id, Qualification_Type__c 
																				FROM Opportunity 
																					WHERE Id IN :new Set<String>{opportunity1.Id, opportunity2.Id, opportunity3.Id}]);

		System.assertEquals('Specialty', opportunitiesMap.get(opportunity1.Id).Qualification_Type__c);
		System.assertEquals('Specialty', opportunitiesMap.get(opportunity2.Id).Qualification_Type__c);
		System.assertEquals('None', opportunitiesMap.get(opportunity3.Id).Qualification_Type__c);

		//change contact qulification and check if opportunity qulification type has changed
		contact1.Qualification__c = 'General Health';
		contact2.Qualification__c = 'General Health';

		update new List<Contact>{contact1, contact2};

		opportunitiesMap = new Map<Id, Opportunity>([SELECT Id, Qualification_Type__c 
																				FROM Opportunity 
																					WHERE Id IN :new Set<String>{opportunity1.Id, opportunity2.Id}]);

		System.assertEquals('General Health', opportunitiesMap.get(opportunity1.Id).Qualification_Type__c);
		System.assertEquals('General Health', opportunitiesMap.get(opportunity2.Id).Qualification_Type__c);

	}

	@isTest
	static void testSyncContracts() {
		List<Opportunity> opportunities = [Select Id From Opportunity];

		for (Opportunity opportunity : opportunities) {
			opportunity.StageName = 'In Contracting';
		}

		try {
			update opportunities;
		}
		catch(DmlException ex) {
			system.assert(false);
		}

		opportunities = [Select Id, ContractId From Opportunity];

		for (Opportunity opportunity : opportunities) {
			system.assert(opportunity.ContractId != null);
		}
	}
}