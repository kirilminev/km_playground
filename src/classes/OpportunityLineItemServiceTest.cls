/** Each unit test contained in this test class represents one of the test cases as described
in the wiki document that outlines the requirements for membership sales commissions. That wiki
can be found here: https://contextmedia.atlassian.net/wiki/display/PD/Commissions **/
@isTest
private class OpportunityLineItemServiceTest {

	private static final String opportunity1TestName = 'OpportunityOneTest';
	private static final String PRICEBOOK_NAME =  'Membership';

	@testsetup static void setup() {

		TestDataService.setupCommissionRateCardCustomSetting();
		//Sets up custom settings data for product qualifications and multipliers.
		TestDataService.setupQualificaitonsCustomSetting();
		TestDataService.setupCommissionAcceleratorThresholds();
		TestDataService.setupRoleTeamMaps();

		TestDataService.setupPriceBookWithProducts(PRICEBOOK_NAME);
		TestDataService.setupCommissionsCalculatorGlobalSettings();

		RecordType membershipRecordType = RecordTypeService.getByNameAndObjectType('Membership', 'Opportunity', new List<String>{'Id'});
		//Sets up generic account, contact, opportunity, and opportunity line item data.
		Account account = new Account(
			Name = 'Test Account',
			NumberOfQualifiedWaitingRooms__c = 0
		);
		insert account;
		List<Contact> contacts = new List<Contact> {
			new Contact(
				AccountId = account.Id,
				FirstName = 'Test',
				LastName = 'Contact',
				Qualification__c = 'Not Qualified'
			),
			new Contact(
				AccountId = account.Id,
				FirstName = 'Test',
				LastName = 'Contact'
			)
		};
		insert contacts;

		Opportunity opportunity1 = new Opportunity(
			AccountId = account.Id,
			CloseDate = System.Today(),
			DateScheduled__c = Date.Today().addDays(10),
			Name = opportunity1TestName,
			RecordTypeId = membershipRecordType.Id,
			StageName = 'Discovery'
		);
		insert opportunity1;

		System.assertNotEquals(null, opportunity1.Id);
	}

	@isTest
	private static void GetByOpportunityIds_IdsAreNull_ExceptionThrown() {
		//Tests that the query method to get line items by specific opportunity ids throws an IllegalArgumentException if no ids are passed in.
		try {
			List<OpportunityLineItem> lineItems = OpportunityLineItemService.getByOpportunityIds(null, new List<String> {'Id'});
			System.assert(false, 'IllegalArgumentException was not properly thrown.');
		}
		catch (IllegalArgumentException ex) {
			system.assert(true);
		}
	}

	@isTest
	private static void GetByOpportunityIds_OpportunityIdInIds_ReturnsOpportunityLineItems() {

		//Tests that if the opportunity id of the opportunity created in setup() is passed to getByOpportunityIds,
		//that the line item inserted is returned in the result set.
		Pricebook2 membership = [Select Id, (Select Id From PricebookEntries) From Pricebook2 Where Name = 'Membership'];
		Opportunity opportunity1 = [Select Id, RecordTypeId From Opportunity Where Name = :opportunity1TestName limit 1][0];

		OpportunityLineItem lineItem = new OpportunityLineItem(
			OpportunityId = opportunity1.Id,
			PricebookEntryId = membership.PricebookEntries[0].Id,
			Quantity = 1,
			TotalPrice = 0
		);
		insert lineItem;

		System.assert(ListUtils.isNotNullOrEmpty(OpportunityLineItemService.getByOpportunityIds(new List<Id> {opportunity1.Id}, new List<String> {'Id'})));
		
	}
	
	@isTest
	static void calculateCommissionAmountTest() {

		Account account1 = new Account(Name = 'Test Account 1');
		insert account1;

		Contact contact1 = new Contact(AccountId = account1.Id, LastName = 'LastName1', NPI__c = '1111111111', Qualification__c = 'Dermatology;General Health');
		Contact contact2 = new Contact(AccountId = account1.Id, LastName = 'LastName2', NPI__c = '2222222222', Qualification__c = 'Allergy');
		Contact contact3 = new Contact(AccountId = account1.Id, LastName = 'LastName3', NPI__c = '3333333333', Qualification__c = 'Not Qualified');
		Contact contact4 = new Contact(AccountId = account1.Id, LastName = 'LastName4', NPI__c = '4444444444', Qualification__c = null);

		insert new List<Contact>{contact1, contact2, contact3, contact4};

		Opportunity opportunity1 = [Select Id, RecordTypeId FROM Opportunity WHERE Name = :opportunity1TestName limit 1][0];
		opportunity1.AccountId = account1.Id;
		update opportunity1;
		
		opportunity1 = [Select Id, Qualification_Type__c FROM Opportunity WHERE Name = :opportunity1TestName limit 1][0];

		System.assertEquals('Specialty', opportunity1.Qualification_Type__c);

		Pricebook2 membership = [Select Id, (Select Id, Product2Id From PricebookEntries) From Pricebook2 Where Name = 'Membership'];
		
		List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();

		for (PricebookEntry pbe :membership.PricebookEntries) {
			opportunityLineItems.add(new OpportunityLineItem(
											OpportunityId = opportunity1.Id,
											PricebookEntryId = pbe.Id,
											Quantity = 1,
											TotalPrice = 0
										));
		}

		insert opportunityLineItems;

		List<String> opportunityLineItemIds = new List<String>();

		for (OpportunityLineItem opportunityLineItem :opportunityLineItems) {
			opportunityLineItemIds.add(opportunityLineItem.Id);
		}

		Map<Id, OpportunityLineItem> opportunityLineItemsMap = new Map<Id, OpportunityLineItem> (OpportunityLineItemService.getByIds(
																												opportunityLineItemIds, 
																												new List<String>{'Id', 'CommissionAmount__c'}));
		
		System.assertNotEquals(0, opportunityLineItemsMap.get(opportunityLineItems.get(0).Id).CommissionAmount__c);

		opportunityLineItems.get(0).ProductStage__c = 'Retracted';
		opportunityLineItems.get(0).RetractedDetails__c = 'test';
		update opportunityLineItems.get(0);

		opportunityLineItemsMap = new Map<Id, OpportunityLineItem> (OpportunityLineItemService.getByIds(
																						opportunityLineItemIds, 
																						new List<String>{'Id', 'CommissionAmount__c'}));

		System.assertEquals(0, opportunityLineItemsMap.get(opportunityLineItems.get(0).Id).CommissionAmount__c);

		Map<String, Role_Team_Map__c> roleTeamMap = Role_Team_Map__c.getAll();

		//this query will return one user of each role
		List<AggregateResult> userResults = [SELECT Max(Id),UserRoleId FROM User WHERE isActive = true AND UserRoleId IN :roleTeamMap.keySet() GROUP BY UserRoleId];

		
		for (AggregateResult userResult :userResults) {

			User testUser = new User(Id = (Id)userResult.get('expr0'));
			System.runAs(testUser){
				
				opportunity1.OwnerId = testUser.Id;
				update opportunity1;
			}
		}
		
	}

	@isTest
	static void getByIdsTest() {

		Pricebook2 membership = [Select Id, (Select Id From PricebookEntries) From Pricebook2 Where Name = 'Membership'];
		Opportunity opportunity1 = [Select Id, RecordTypeId From Opportunity Where Name = :opportunity1TestName limit 1][0];

		List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();

		opportunityLineItems.add(new OpportunityLineItem(
			OpportunityId = opportunity1.Id,
			PricebookEntryId = membership.PricebookEntries[0].Id,
			Quantity = 1,
			TotalPrice = 0
		));

		opportunityLineItems.add(new OpportunityLineItem(
			OpportunityId = opportunity1.Id,
			PricebookEntryId = membership.PricebookEntries[0].Id,
			Quantity = 1,
			TotalPrice = 0
		));

		insert opportunityLineItems;

		Map<Id, OpportunityLineItem> opportunityLineItemsMap = new Map<Id, OpportunityLineItem>(opportunityLineItems);

		List<OpportunityLineItem> resultOpportunityLineItems = OpportunityLineItemService.getByIds(new List<Id>(opportunityLineItemsMap.keySet()), new List<String>{'Id'});

		for (OpportunityLineItem opportunityLineItem : resultOpportunityLineItems) {
			System.assertNotEquals(null, opportunityLineItemsMap.get(opportunityLineItem.Id));
		}

		Boolean queryExceptionThrown = false;
		//test with non-existing field
		try {
			OpportunityLineItemService.getByIds(new List<Id>(opportunityLineItemsMap.keySet()), new List<String>{'Id', 'BadField'});
		}catch (System.QueryException queryException) {
			queryExceptionThrown = true;
		} catch (Exception ex) {
			queryExceptionThrown = false;
		}
		System.assertEquals(true, queryExceptionThrown);
	}

	@isTest
	static void checkForDuplicatesTest() {
		
		Pricebook2 membership = [Select Id, (Select Id From PricebookEntries) From Pricebook2 Where Name = 'Membership'];
		Opportunity opportunity1 = [Select Id, RecordTypeId From Opportunity Where Name = :opportunity1TestName limit 1][0];


		List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();

		opportunityLineItems.add(new OpportunityLineItem(
			OpportunityId = opportunity1.Id,
			PricebookEntryId = membership.PricebookEntries[0].Id,
			Quantity = 1,
			TotalPrice = 0
		));

		opportunityLineItems.add(new OpportunityLineItem(
			OpportunityId = opportunity1.Id,
			PricebookEntryId = membership.PricebookEntries[0].Id,
			Quantity = 1,
			TotalPrice = 0
		));

		insert opportunityLineItems;

		List<Opportunity> opportunities = OpportunityService.getByIdsWithOpportunityLineItems(
														new List<String>{opportunity1.Id}, 
														new List<String> {
															'Accelerator_Stage_1__c',
									         				'Accelerator_Stage_2__c',
															'OwnerId',
															'Owner_Team__c',
											 				'Id',
									         				'Qualification_Type__c',
									         				'RecordTypeId'
									         				 },
								         				new List<String>{
								         					'Id',
								         					'ProductCode',
								         					'Product2Id'
								         				}
									         			);

		Set<Id> opportunityLineItemsIds = new Set<Id>();

		for (OpportunityLineItem opportunityLineItem :opportunityLineItems) {
			opportunityLineItemsIds.add(opportunityLineItem.Id);
		}

		opportunityLineItems = [Select Product2Id, Id, OpportunityId FROM OpportunityLineItem WHERE Id IN :opportunityLineItemsIds];

		Boolean duplicateException = false;

		try {
			OpportunityLineItemService.checkForDuplicates(opportunities, opportunityLineItems);
		}catch (Exception customException) {
			duplicateException = true;
		}

		System.assertEquals(true, duplicateException, 'Expected to throw duplicate exception.');

	}
}




