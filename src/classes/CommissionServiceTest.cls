/*******************************************************************************************************
* @description 	Unit Test for CommissionService class
* 
*/
@isTest
private class CommissionServiceTest
{	
	private static final String PRICEBOOK_NAME =  'Membership';

	@testSetup static void setup() {

		TestDataService.setupCommissionRateCardCustomSetting();
		TestDataService.setupQualificaitonsCustomSetting();
		TestDataService.setupCommissionAcceleratorThresholds();
		TestDataService.setupRoleTeamMaps();
		TestDataService.setupCommissionsCalculatorGlobalSettings();

		Account account1 = new Account(Name = 'Test Account 1');
		insert account1;

		Contact contact1 = new Contact(AccountId = account1.Id, LastName = 'LastName1', NPI__c = '1111111111', Qualification__c = 'Dermatology;General Health');
		Contact contact2 = new Contact(AccountId = account1.Id, LastName = 'LastName2', NPI__c = '2222222222', Qualification__c = 'Allergy');
		Contact contact3 = new Contact(AccountId = account1.Id, LastName = 'LastName3', NPI__c = '3333333333', Qualification__c = 'Not Qualified');
		Contact contact4 = new Contact(AccountId = account1.Id, LastName = 'LastName4', NPI__c = '4444444444', Qualification__c = null);

		insert new List<Contact>{contact1, contact2, contact3, contact4};

		TestDataService.setupPriceBookWithProducts(PRICEBOOK_NAME);

	}

	@isTest
	static void updateCommissionEntriesWithoutLineItemsTest() {
		Account account1 = [Select Id From Account limit 1];

		RecordType membershipRecordType = RecordTypeService.getByNameAndObjectType('Membership', 'Opportunity', new List<String>{'Id'});

		Opportunity opportunity1 = new Opportunity(
			AccountId = account1.Id,
			CloseDate = System.Today(),
			DateScheduled__c = Date.Today().addDays(10),
			Name = 'Test Opportunity 1',
			RecordTypeId = membershipRecordType.Id,
			StageName = 'Discovery'
		);
		insert opportunity1;

		System.assert(ListUtils.isNullOrEmpty([Select Id From Commission_Entry__c]));

		Test.startTest();
		CommissionService.updateCommissionEntries(new List<Opportunity> {opportunity1}, new Map<Id, Opportunity>{opportunity1.Id => opportunity1});
		Test.stopTest();

		List<Commission_Entry__c> commissionEntries = [Select Id, Opportunity__c, Type__c, Opportunity_Line_Item_Id__c, Commission_Amount__c 
																	FROM Commission_Entry__c];
		System.assertNotEquals(null, commissionEntries);
		System.assertEquals(1, commissionEntries.size());

		System.assertEquals('Opportunity', commissionEntries.get(0).Type__c);
	}

	@isTest
	static void updateCommissionEntriesWithLineItemsTest() {

		Account account1 = [Select Id From Account limit 1];

		RecordType membershipRecordType = RecordTypeService.getByNameAndObjectType(PRICEBOOK_NAME, 'Opportunity', new List<String>{'Id'});

		Opportunity opportunity1 = new Opportunity(
			AccountId = account1.Id,
			CloseDate = System.Today(),
			DateScheduled__c = Date.Today().addDays(10),
			Name = 'Test Opportunity 1',
			RecordTypeId = membershipRecordType.Id,
			StageName = 'Discovery'
		);
		insert opportunity1;

		Pricebook2 membership = [Select Id, (Select Id From PricebookEntries) From Pricebook2 Where Name = :PRICEBOOK_NAME];

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

		System.assert(ListUtils.isNullOrEmpty([Select Id From Commission_Entry__c]));

		Test.startTest();
		CommissionService.updateCommissionEntries(new List<Opportunity> {opportunity1}, new Map<Id, Opportunity>{opportunity1.Id => opportunity1});
		Test.stopTest();

		List<Commission_Entry__c> commissionEntries = [Select Id, Opportunity__c, Opportunity_Line_Item_Id__c, Commission_Amount__c 
																	FROM Commission_Entry__c];
		System.assertNotEquals(null, commissionEntries);
		System.assertEquals(3, commissionEntries.size());
		
	}

	@isTest
	static void commissionEntriesSortTest() {
		List<CommissionService.CommissionEntryWrapper> commissionEntries = new List<CommissionService.CommissionEntryWrapper>();
		//Opportunity_Line_Item_Id__c is irrelevant as we are not saving to db for this test so we are just going to hard-code random strings
		String olId1 = '0064B000003rlCBAAA';
		String olId2 = '0064B000003rlCBBBB';
		String olId3 = '0064B000003rlCBCCC';
		
		commissionEntries.add(new CommissionService.CommissionEntryWrapper(new Commission_Entry__c(Opportunity_Line_Item_Id__c = olId3)));
		commissionEntries.add(new CommissionService.CommissionEntryWrapper(new Commission_Entry__c(Opportunity_Line_Item_Id__c = olId3)));
		commissionEntries.add(new CommissionService.CommissionEntryWrapper(new Commission_Entry__c(Opportunity_Line_Item_Id__c = olId3)));

		commissionEntries.add(new CommissionService.CommissionEntryWrapper(new Commission_Entry__c(Opportunity_Line_Item_Id__c = olId1)));
		commissionEntries.add(new CommissionService.CommissionEntryWrapper(new Commission_Entry__c(Opportunity_Line_Item_Id__c = olId1)));
		commissionEntries.add(new CommissionService.CommissionEntryWrapper(new Commission_Entry__c(Opportunity_Line_Item_Id__c = olId1)));

		commissionEntries.add(new CommissionService.CommissionEntryWrapper(new Commission_Entry__c(Opportunity_Line_Item_Id__c = olId2)));
		commissionEntries.add(new CommissionService.CommissionEntryWrapper(new Commission_Entry__c(Opportunity_Line_Item_Id__c = olId2)));
		commissionEntries.add(new CommissionService.CommissionEntryWrapper(new Commission_Entry__c(Opportunity_Line_Item_Id__c = olId2)));

		commissionEntries.add(new CommissionService.CommissionEntryWrapper(new Commission_Entry__c(Opportunity_Line_Item_Id__c = null)));
		commissionEntries.add(new CommissionService.CommissionEntryWrapper(new Commission_Entry__c(Opportunity_Line_Item_Id__c = '')));

		//test before sorting
		System.assertNotEquals(olId1, commissionEntries[0].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertNotEquals(olId1, commissionEntries[1].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertNotEquals(olId1, commissionEntries[2].commissionEntry.Opportunity_Line_Item_Id__c);

		System.assertEquals(olId3, commissionEntries[0].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertEquals(olId3, commissionEntries[1].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertEquals(olId3, commissionEntries[2].commissionEntry.Opportunity_Line_Item_Id__c);

		System.assertEquals(olId2, commissionEntries[6].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertEquals(olId2, commissionEntries[7].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertEquals(olId2, commissionEntries[8].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertEquals(null, commissionEntries[9].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertEquals('', commissionEntries[10].commissionEntry.Opportunity_Line_Item_Id__c);

		commissionEntries.sort();
		//after sorting
		System.assertEquals(null, commissionEntries[0].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertEquals('', commissionEntries[1].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertEquals(olId1, commissionEntries[2].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertEquals(olId1, commissionEntries[3].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertEquals(olId1, commissionEntries[4].commissionEntry.Opportunity_Line_Item_Id__c);

		System.assertEquals(olId2, commissionEntries[5].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertEquals(olId2, commissionEntries[6].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertEquals(olId2, commissionEntries[7].commissionEntry.Opportunity_Line_Item_Id__c);

		System.assertEquals(olId3, commissionEntries[8].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertEquals(olId3, commissionEntries[9].commissionEntry.Opportunity_Line_Item_Id__c);
		System.assertEquals(olId3, commissionEntries[10].commissionEntry.Opportunity_Line_Item_Id__c);
	}

	@isTest
	static void populateOpportunityLineItemIdToCommissionEntryListMapTest() {

		RecordType membershipRecordType = RecordTypeService.getByNameAndObjectType('Membership', 'Opportunity', new List<String>{'Id'});

		Account account1 = new Account(Name = 'Test Account');
		insert account1;
		String olId1 = '0064B000003rlCBAAA';
		String olId2 = '0064B000003rlCBBBB';
		String olId3 = '0064B000003rlCBCCC';
		String olId4 = '0064B000003rlCBDDD';
		String olId5 = '0064B000003rlCBEEE';

		List<Opportunity> opportunities = new List<Opportunity>();

		Opportunity opportunity1 = new Opportunity(Name = 'Test1', StageName = 'New', 
												   CloseDate = Date.Today(),
												   RecordTypeId = membershipRecordType.Id, 
												   AccountId = account1.Id);
		insert opportunity1;
		
		List<Commission_Entry__c> commissionEntriesList1 = new List<Commission_Entry__c>();
		
		commissionEntriesList1.add(new Commission_Entry__c(Opportunity__c = opportunity1.Id, Opportunity_Line_Item_Id__c = olId1));
		commissionEntriesList1.add(new Commission_Entry__c(Opportunity__c = opportunity1.Id, Opportunity_Line_Item_Id__c = olId1));
		commissionEntriesList1.add(new Commission_Entry__c(Opportunity__c = opportunity1.Id, Opportunity_Line_Item_Id__c = olId1));

		commissionEntriesList1.add(new Commission_Entry__c(Opportunity__c = opportunity1.Id, Opportunity_Line_Item_Id__c = olId2));
		commissionEntriesList1.add(new Commission_Entry__c(Opportunity__c = opportunity1.Id, Opportunity_Line_Item_Id__c = olId2));

		commissionEntriesList1.add(new Commission_Entry__c(Opportunity__c = opportunity1.Id, Opportunity_Line_Item_Id__c = olId3));

		commissionEntriesList1.add(new Commission_Entry__c(Opportunity__c = opportunity1.Id, Opportunity_Line_Item_Id__c = null));		

		insert commissionEntriesList1;

		opportunity1 = [SELECT Id, 
						(Select Id, Opportunity_Line_Item_Id__c FROM Commission_Entries__r) 
							FROM Opportunity WHERE Id = :opportunity1.Id limit 1];
		System.assertEquals(7, opportunity1.Commission_Entries__r.size());

		opportunities.add(opportunity1);

		Opportunity opportunity2 = new Opportunity(Name = 'Test2', StageName = 'New', 
												   CloseDate = Date.Today(), 
												   RecordTypeId = membershipRecordType.Id,
												   AccountId = account1.Id);
		insert opportunity2;

		List<Commission_Entry__c> commissionEntriesList2 = new List<Commission_Entry__c>();
		
		commissionEntriesList2.add(new Commission_Entry__c(Opportunity__c = opportunity2.Id, Opportunity_Line_Item_Id__c = olId4));
		commissionEntriesList2.add(new Commission_Entry__c(Opportunity__c = opportunity2.Id, Opportunity_Line_Item_Id__c = olId4));
		commissionEntriesList2.add(new Commission_Entry__c(Opportunity__c = opportunity2.Id, Opportunity_Line_Item_Id__c = olId4));	
		commissionEntriesList2.add(new Commission_Entry__c(Opportunity__c = opportunity2.Id, Opportunity_Line_Item_Id__c = olId4));
		commissionEntriesList2.add(new Commission_Entry__c(Opportunity__c = opportunity2.Id, Opportunity_Line_Item_Id__c = olId5));

		insert commissionEntriesList2;

		opportunity2 = [SELECT Id, 
						(Select Id, Opportunity_Line_Item_Id__c FROM Commission_Entries__r) 
							FROM Opportunity WHERE Id = :opportunity2.Id limit 1];
		System.assertEquals(7, opportunity1.Commission_Entries__r.size());

		opportunities.add(opportunity2);

		Map<String, List<Commission_Entry__c>> opportunityLineItemIdToCommissionEntryMap = CommissionService.populateOpportunityLineItemIdToCommissionEntryMap(opportunities);
		
		System.assertEquals(3, opportunityLineItemIdToCommissionEntryMap.get(olId1).size());
		System.assertEquals(2, opportunityLineItemIdToCommissionEntryMap.get(olId2).size());
		System.assertEquals(1, opportunityLineItemIdToCommissionEntryMap.get(olId3).size());
		System.assertEquals(4, opportunityLineItemIdToCommissionEntryMap.get(olId4).size());
		System.assertEquals(1, opportunityLineItemIdToCommissionEntryMap.get(olId5).size());
	}
	
	@isTest
	static void processCommissionEntriesForOpportunityTest() {

		Test.startTest();
		RecordType membershipRecordType = RecordTypeService.getByNameAndObjectType(PRICEBOOK_NAME, 'Opportunity', new List<String>{'Id'});
		Account account1 = new Account(Name = 'Test Account');
		insert account1;
		
		List<Opportunity> opportunities = new List<Opportunity>();

		Opportunity opportunity1 = new Opportunity(Name = 'Test1', StageName = 'New', 
												   CloseDate = Date.Today(), 
												   AccountId = account1.Id,
												   RecordTypeId = membershipRecordType.Id);
		insert opportunity1;

		Pricebook2 membership = [Select Id, (Select Id, Product2Id From PricebookEntries) From Pricebook2 Where Name = :PRICEBOOK_NAME];
		
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

		Test.stopTest();//stop test here because Commission_Entry__c object are inserted by the triggger in @future context

		opportunity1 = OpportunityService.getByIdsWithOpportunityLineItemsAndCommissionEntries(new List<Id>{opportunity1.Id}, 
																							   new List<String>{'Id', 'isClosed', 'Specialty_Contacts_Bonus__c', 'StageName', 'CloseDate', 'RecordTypeId', 'AccountId'},
																							   new List<String>{'Id', 'ProductStage__c', 'Product2Id', 'CommissionAmount__c'},
																							   new List<String>{'Id', 'Paid_On__c', 'Opportunity_Line_Item_Id__c', 'Commission_Amount__c', 'Opportunity__c', 'Type__c'})[0];

		Map<String, List<Commission_Entry__c>> opportunityLineItemIdToCommissionEntryMap =  CommissionService.populateOpportunityLineItemIdToCommissionEntryMap(new List<Opportunity>{opportunity1});

		System.assertNotEquals(null, opportunityLineItemIdToCommissionEntryMap);
		System.assertEquals(opportunityLineItems.size() + 1, opportunity1.Commission_Entries__r.size(), 'Expecting ' + opportunityLineItems.size() + ' commission entries for opportunity plus 1 for the Opportunity type');

		
		opportunityLineItems[0].ProductStage__c = CommissionService.PRODUCT_STAGE_RETRACTED;
		opportunityLineItems[0].RetractedDetails__c = 'Test';
		update opportunityLineItems[0];

		List<Commission_Entry__c> commissionEntrieToUpsert = new List<Commission_Entry__c>();

		CommissionService.processCommissionEntriesForOpportunity(opportunity1, opportunityLineItemIdToCommissionEntryMap, commissionEntrieToUpsert);

		for (Commission_Entry__c commissionEntry :commissionEntrieToUpsert) {
			if (commissionEntry.Product_Stage__c != null && commissionEntry.Product_Stage__c.equalsIgnoreCase(CommissionService.PRODUCT_STAGE_RETRACTED)) {
				System.assertEquals(0, commissionEntry.Commission_Amount__c, 'Commission Amount expected to be 0 for Retracted products.');
			}
		}

		opportunity1.StageName = 'Closed Won';
		update opportunity1;

		commissionEntrieToUpsert = new List<Commission_Entry__c>();

		opportunityLineItems[1].ProductStage__c = CommissionService.PRODUCT_STAGE_RETRACTED;
		opportunityLineItems[1].RetractedDetails__c = 'Test2';
		update opportunityLineItems[1];

		opportunity1 = OpportunityService.getByIdsWithOpportunityLineItemsAndCommissionEntries(new List<Id>{opportunity1.Id}, 
																							   new List<String>{'Id', 'isClosed', 'Specialty_Contacts_Bonus__c', 'StageName', 'isWon', 'CloseDate', 'RecordTypeId', 'AccountId'},
																							   new List<String>{'Id', 'ProductStage__c', 'Product2Id', 'CommissionAmount__c'},
																							   new List<String>{'Id', 'Paid_On__c', 'Opportunity_Line_Item_Id__c', 'Commission_Amount__c', 'Opportunity__c', 'Type__c'})[0];
		
		CommissionService.processCommissionEntriesForOpportunity(opportunity1, opportunityLineItemIdToCommissionEntryMap, commissionEntrieToUpsert);

		Integer numberOfRetractedEntries = 0;

		for (Commission_Entry__c commissionEntry :commissionEntrieToUpsert) {
			if (commissionEntry.Product_Stage__c != null && commissionEntry.Product_Stage__c.equalsIgnoreCase(CommissionService.PRODUCT_STAGE_RETRACTED)) {
				numberOfRetractedEntries ++;
				System.assertEquals(0, commissionEntry.Commission_Amount__c, 'Commission Amount expected to be 0 for Retracted products.');
			}
		}

		System.assertEquals(2, numberOfRetractedEntries, 'Expecting 2 Retracted commission entries.');

		for (Commission_Entry__c commissionEntry :commissionEntrieToUpsert) {
			if (commissionEntry.Opportunity_Line_Item_Id__c.equals(opportunityLineItems[2].Id)) {
				commissionEntry.Paid_On__c = Date.Today();
				update commissionEntry;
				break;
			}
		}

		opportunityLineItems[2].ProductStage__c = CommissionService.PRODUCT_STAGE_RETRACTED;
		opportunityLineItems[2].RetractedDetails__c = 'Test2';
		update opportunityLineItems[2];

		opportunity1 = OpportunityService.getByIdsWithOpportunityLineItemsAndCommissionEntries(new List<Id>{opportunity1.Id}, 
																							   new List<String>{'Id', 'isClosed', 'isWon', 'Specialty_Contacts_Bonus__c', 'StageName', 'CloseDate', 'RecordTypeId', 'AccountId'},
																							   new List<String>{'Id', 'ProductStage__c', 'Product2Id', 'CommissionAmount__c'},
																							   new List<String>{'Id', 'Paid_On__c', 'Opportunity_Line_Item_Id__c', 'Commission_Amount__c', 'Opportunity__c', 'Type__c'})[0];

		commissionEntrieToUpsert = new List<Commission_Entry__c>();
		CommissionService.processCommissionEntriesForOpportunity(opportunity1, opportunityLineItemIdToCommissionEntryMap, commissionEntrieToUpsert);

		for (Commission_Entry__c commissionEntry :commissionEntrieToUpsert) {
			if (commissionEntry.Opportunity_Line_Item_Id__c.equals(opportunityLineItems[2].Id)) {
				if (commissionEntry.Commission_Amount__c > 0) {
					System.assert(false, 'Commission Entry commission amount expected to be negative amount for entries that have been retracted and paid.');
				}
				break;
			}
		}

		opportunity1.StageName = 'Closed Lost';
		update opportunity1;

		opportunity1 = OpportunityService.getByIdsWithOpportunityLineItemsAndCommissionEntries(new List<Id>{opportunity1.Id}, 
																							   new List<String>{'Id', 'isClosed', 'Specialty_Contacts_Bonus__c', 'StageName', 'CloseDate', 'RecordTypeId', 'AccountId'},
																							   new List<String>{'Id', 'OpportunityId', 'ProductStage__c', 'Product2Id', 'CommissionAmount__c'},
																							   new List<String>{'Id', 'Paid_On__c', 'Opportunity_Line_Item_Id__c', 'Commission_Amount__c', 'Opportunity__c', 'Total_Commission_Paid__c', 'Type__c'})[0];

		commissionEntrieToUpsert = new List<Commission_Entry__c>();
		//Cancel Entire Order e.g. Opportunity Stage from Closed Won to Closed Lost
		CommissionService.processCommissionEntriesForOpportunity(opportunity1, opportunityLineItemIdToCommissionEntryMap, commissionEntrieToUpsert, true);
		
		if (commissionEntrieToUpsert[0].Commission_Amount__c > 0) {
			System.assert(false, 'Commission Item Amount expected to be negative amount.');
		}
		System.assertEquals(1, commissionEntrieToUpsert.size());
		

	}

	@isTest
	static void updateOpportunityHeaderCommissionEntryTest() {

		RecordType membershipRecordType = RecordTypeService.getByNameAndObjectType(PRICEBOOK_NAME, 'Opportunity', new List<String>{'Id'});
		Account account1 = new Account(Name = 'Test Account');
		insert account1;
		
		List<Opportunity> opportunities = new List<Opportunity>();

		Opportunity opportunity1 = new Opportunity(Name = 'Test1', StageName = 'New', 
												   CloseDate = Date.Today(), 
												   AccountId = account1.Id,
												   RecordTypeId = membershipRecordType.Id);
		insert opportunity1;

		List<Commission_Entry__c> commissionEntriesUpsert = new List<Commission_Entry__c>();

		List<Commission_Entry__c> opportunityCommissionEntry = [Select Id, Opportunity__c From Commission_Entry__c WHERE Type__c = 'Opportunity' AND Opportunity__c = :opportunity1.Id];

		System.assertEquals(0, opportunityCommissionEntry.size(), 'Commission Entry with Type__c opportunity and opportunity__c Id: ' + opportunity1.Id + ' not expected.');

		CommissionService.updateOpportunityHeaderCommissionEntry(opportunity1, commissionEntriesUpsert);

		System.assertEquals(1, commissionEntriesUpsert.size(), 'Expecting Commission_Entry__c object in list of objects to be upsert.');

		commissionEntriesUpsert[0].Commission_Amount__c = 1000.00;
		upsert commissionEntriesUpsert;

		opportunityCommissionEntry = [Select Id, Opportunity__c From Commission_Entry__c WHERE Type__c = 'Opportunity' AND Opportunity__c = :opportunity1.Id];

		System.assertEquals(1, opportunityCommissionEntry.size(), 'Commission Entry with Type__c opportunity and opportunity__c Id: ' + opportunity1.Id + ' not expected.');

		opportunityCommissionEntry[0].Paid_On__c = Date.Today();//set paid date so the updateOpportunityHeaderCommissionEntry will add a negative commission entry for paid items when canceled
		update opportunityCommissionEntry[0];

		commissionEntriesUpsert = new List<Commission_Entry__c>();

		opportunity1 = OpportunityService.getByIdsWithOpportunityLineItemsAndCommissionEntries(new List<Id>{opportunity1.Id}, 
																							   new List<String>{'Id', 'Specialty_Contacts_Bonus__c', 'StageName', 'CloseDate', 'RecordTypeId', 'AccountId'},
																							   new List<String>{'Id'},
																							   new List<String>{'Id', 'Paid_On__c', 'Commission_Amount__c', 'Opportunity__c', 'Total_Commission_Paid__c', 'Type__c'})[0];

		CommissionService.updateOpportunityHeaderCommissionEntry(opportunity1, commissionEntriesUpsert, true);//cancel order

		System.assertEquals(1, commissionEntriesUpsert.size(), 'Exepcting 1 Commission_Entry__c object with negative commission amount entry.');

		if (commissionEntriesUpsert[0].Commission_Amount__c > 0) {
			System.assert(false, 'Commission Amount for canceled and paid order expected to be negative.');
		}

		upsert commissionEntriesUpsert;

		opportunityCommissionEntry = [Select Id, Opportunity__c From Commission_Entry__c WHERE Type__c = 'Opportunity' AND Opportunity__c = :opportunity1.Id];

		System.assertEquals(2, opportunityCommissionEntry.size(), 'Commission Entry with Type__c opportunity and opportunity__c Id: ' + opportunity1.Id + ' not expected.');

	}
}