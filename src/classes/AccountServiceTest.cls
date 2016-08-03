@isTest
private class AccountServiceTest {
	private static final String ACCOUNTx = 'Account';

	private static String ZIP_CODE_1 = '11111';
	private static String ZIP_CODE_2 = '22222';

	@testSetup static void setup() {
		
		Zip_Code_Data__c zipCode1 = new Zip_Code_Data__c(Name = ZIP_CODE_1, OFFSET_DST__c = 1, OFFSET_ST__c = 1);
		Zip_Code_Data__c zipCode2 = new Zip_Code_Data__c(Name = ZIP_CODE_2, OFFSET_DST__c = 1, OFFSET_ST__c = 1);

		insert new List<Zip_Code_Data__c>{zipCode1, zipCode2};

		Account account1 = new Account(Name = 'Test Account 1', BillingPostalCode = ZIP_CODE_1);
		Account account2 = new Account(Name = 'Test Account 2', BillingPostalCode = ZIP_CODE_2);
		
		insert new List<Account>{account1, account2};		
	}

	private static testmethod void testGetById() {
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Account result = AccountService.getById(account.Id, new List<String> {'Name'});

		system.assert(result == account);
	}

	private static testmethod void testGetByIds() {
		List<Id> accountIds = new List<Id>();
		List<Account> accounts = new List<Account>();
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		accountIds.add(account.Id);
		accounts.add(account);
		List<Account> result = AccountService.getByIds(accountIds, new List<String> {'Name'});

		system.assert(result == accounts);
	}

	private static testmethod void testGetByNetwork() {
		List<Account> accounts = new List<Account>();
		Account account = new Account();
		account.Name = 'Account Name';
		account.Network__c = 'Diabetes';
		insert account;
		accounts.add(account);
		List<Account> result = AccountService.getByNetwork('Diabetes', new List<String> {'Name', 'Network__c'});

		system.assert(result == accounts);
	}

	private static testmethod void testGetWithProductsById() {
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		List<ContextMedia_Product__c> products = TestDataService.getTestProducts(account.Id);
		Account result = AccountService.getWithProductsById(account.Id, new List<String> {'Name'}, new List<String> {'Account__c'});

		system.assert(result.Name == account.Name);
		system.assert(ListUtils.isNotNullOrEmpty(result.Products1__r));
	}

	private static testmethod void testGetWithProductsByIds() {
		List<Id> accountIds = new List<Id>();
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		accountIds.add(account.Id);
		List<ContextMedia_Product__c> products = TestDataService.getTestProducts(account.Id);
		List<Account> result = AccountService.getWithProductsByIds(accountIds, new List<String> {'Name'}, new List<String> {'Account__c'});

		system.assert(result[0].Name == account.Name);
		system.assert(ListUtils.isNotNullOrEmpty(result[0].Products1__r));
	}

	private static testmethod void testGetWithQualifiedContactsAndProductsByIds() {
		List<Id> accountIds = new List<Id>();
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Contact contact = TestDataService.getTestContact(true, account.Id);
		List<ContextMedia_Product__c> products = TestDataService.getTestProducts(account.Id);
		accountIds.add(account.Id);
		List<Account> result = AccountService.getWithQualifiedContactsAndProductsByIds(accountIds, new List<String> {'Name'}, new List<String> {'Id'}, new List<String> {'Id'});

		system.assert(result[0].Name == account.Name);
		system.assert(ListUtils.isNotNullOrEmpty(result[0].Contacts));
		system.assert(ListUtils.isNotNullOrEmpty(result[0].Products1__r));
	}

	private static testmethod void testGetWithQualifiedContactsAndProductsByIds2() {
		List<Id> accountIds = new List<Id>();
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Contact contact = TestDataService.getTestContact(false, account.Id);
		List<ContextMedia_Product__c> products = TestDataService.getTestProducts(account.Id);
		accountIds.add(account.Id);
		List<Account> result = AccountService.getWithQualifiedContactsAndProductsByIds(accountIds, new List<String> {'Name'}, new List<String> {'Id'}, new List<String> {'Id'});

		system.assert(result[0].Name == account.Name);
		system.assert(ListUtils.isNullOrEmpty(result[0].Contacts));
		system.assert(ListUtils.isNotNullOrEmpty(result[0].Products1__r));
	}

	private static testmethod void testGetWithQualifiedContactsAndQualifiedContactRolesByIds() {
		List<Id> accountIds = new List<Id>();
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Contact contact = TestDataService.getTestContact(false, account.Id);
		List<ContextMedia_Product__c> products = TestDataService.getTestProducts(account.Id);
		accountIds.add(account.Id);
		List<Account> result = AccountService.getWithQualifiedCOntactsAndQualifiedContactRolesByIds(accountIds, new List<String> {'Name'}, new List<String> {'Id'}, new List<String> {'Id'});

		system.assert(ListUtils.isNullOrEmpty(result[0].Contacts));
	}

	private static testmethod void testGetWithQualifiedContactsAndQualifiedContactRolesByIds2() {
		List<Id> accountIds = new List<Id>();
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Contact contact = TestDataService.getTestContact(true, account.Id);
		List<ContextMedia_Product__c> products = TestDataService.getTestProducts(account.Id);
		accountIds.add(account.Id);
		List<Account> result = AccountService.getWithQualifiedCOntactsAndQualifiedContactRolesByIds(accountIds, new List<String> {'Name'}, new List<String> {'Id'}, new List<String> {'Id'});

		system.assert(ListUtils.isNotNullOrEmpty(result[0].Contacts));
	}

	private static testmethod void testGetWithSponsorQualificationsByIds() {
		List<Id> accountIds = new List<Id>();
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		accountIds.add(account.Id);
		Campaign campaign = TestDataService.getTestCampaign('Category');
		SponsorQualification__c qualification = new SponsorQualification__c();
		qualification.Account__c = account.Id;
		qualification.Campaign__c = campaign.Id;
		insert qualification;
		List<Account> result = AccountService.getWithSponsorQualificationsByIds(accountIds, new List<String> {'Name'}, new List<String> {'Account__c', 'Campaign__c'});

		system.assert(result[0].Name == account.Name);
		system.assert(ListUtils.isNotNullOrEmpty(result[0].SponsorQualifications__r));
	}

	private static testmethod void testGetWithSponsorsById() {
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Campaign campaign = TestDataService.getTestCampaign('Category');
		AccountSponsor__c sponsor = new AccountSponsor__c();
		sponsor.Account__c = account.Id;
		sponsor.Campaign__c = campaign.Id;
		insert sponsor;
		account = AccountService.getWithSponsorsById(account.Id, new List<String> {'Id'}, new List<String> {'Account__c', 'Campaign__c'});

		system.assert(ListUtils.isNotNullOrEmpty(account.AccountSponsors__r));
	}

	private static testmethod void testAddGrowthSponsors() {
		TestDataService.setupGrowthSponsor('Other Campaign', 'Category');
		Account account = new Account();
		account.Name = 'Account Name';
		account.RecordTypeId = RecordTypeService.getByNameAndObjectType(new Constants.AccountRecordTypes().MEMBER_OUTREACH, ACCOUNTx, new List<String> {'Id'}).Id;
		insert account;
		Campaign campaign = TestDataService.getTestCampaign('Other Category');
		SponsorQualification__c qualification = new SponsorQualification__c();
		qualification.Account__c = account.Id;
		qualification.Campaign__c = campaign.Id;
		insert qualification;
		account.RecordTypeId = RecordTypeService.getByNameAndObjectType(new Constants.AccountRecordTypes().MEMBER_SERVICES, ACCOUNTx, new List<String> {'Id'}).Id;
		update account;
		account = AccountService.getWithSponsorsById(account.Id, new List<String> {'Id'}, new List<String> {'Account__c', 'Campaign__c'});

		system.assert(ListUtils.isNullOrEmpty(account.AccountSponsors__r));
	}

	private static testmethod void testAddGrowthSponsors2() {
		TestDataService.setupGrowthSponsor('Campaign Name', 'Category');
		Account account = new Account();
		account.Name = 'Account Name';
		account.RecordTypeId = RecordTypeService.getByNameAndObjectType(new Constants.AccountRecordTypes().MEMBER_OUTREACH, ACCOUNTx, new List<String> {'Id'}).Id;
		insert account;
		Campaign campaign = TestDataService.getTestCampaign('Category');
		SponsorQualification__c qualification = new SponsorQualification__c();
		qualification.Account__c = account.Id;
		qualification.Campaign__c = campaign.Id;
		insert qualification;
		account.RecordTypeId = RecordTypeService.getByNameAndObjectType(new Constants.AccountRecordTypes().MEMBER_SERVICES, ACCOUNTx, new List<String> {'Id'}).Id;
		update account;
		account = AccountService.getWithSponsorsById(account.Id, new List<String> {'Id'}, new List<String> {'Account__c', 'Campaign__c'});

		system.assert(ListUtils.isNotNullOrEmpty(account.AccountSponsors__r));
		for (AccountSponsor__c sponsor : account.AccountSponsors__r) {
			system.assert(sponsor.Campaign__c == campaign.Id);
		}
	}
	
	/*******************************************************************************************************
	* @description 			Unit Test for AccountService.getDmaZipCodeMapForAccountBillingCodes(args...) method
	* 
	* @return 				void
	*/
	private static testMethod void testGetDmaZipCodeMapForAccountBillingCodes() {
		
		List<Account> accounts = [SELECT Id, Name, BillingPostalCode FROM Account];
		System.assertNotEquals(accounts, null);
		accounts.add(new Account(Name = 'Test Account', BillingPostalCode = '33333'));//add account with billing 

		Map<String, Id> zipCodeNameToId = AccountService.getDmaZipCodeMapForAccountBillingCodes(null);
		System.assertNotEquals(zipCodeNameToId, null, 'Even if account list is empty map should not be null.');
		zipCodeNameToId = AccountService.getDmaZipCodeMapForAccountBillingCodes(accounts);
		System.assertEquals(zipCodeNameToId.size(), 2);
		System.assertNotEquals(zipCodeNameToId.get(ZIP_CODE_1), null);
		String zipCodeNineDigits = '77777-7777';
		Zip_Code_Data__c zipCodeTest = new Zip_Code_Data__c(Name = StringUtils.left(zipCodeNineDigits, 5), OFFSET_DST__c = 1, OFFSET_ST__c = 1);
		insert zipCodeTest;
		accounts.add(new Account(Name = 'test account', BillingPostalCode = zipCodeNineDigits));
		zipCodeNameToId = AccountService.getDmaZipCodeMapForAccountBillingCodes(accounts);
		System.assertEquals(zipCodeTest.Id, zipCodeNameToId.get(StringUtils.left(zipCodeNineDigits, 5)));
	}

	/*******************************************************************************************************
	* @description 		Unit Test for AccountService.populateDmaZipCode(args...) method
	* 
	* @return 			void
	* 
	*/	
	private static testMethod void testPopulateDmaZipCode() {

		List<Account> accounts = [SELECT Id, Name, BillingPostalCode FROM Account];
		System.assertNotEquals(accounts, null);
		String billingZipCode3 = '12345-1111';
		Account account1 = new Account(Name = 'Test Account', BillingPostalCode = billingZipCode3, DMA_Zip_Code__c = [SELECT Id FROM Zip_Code_Data__c LIMIT 1][0].Id);
		accounts.add(account1);//add account with billing 
		System.assertNotEquals(account1.DMA_Zip_Code__c, null);

		Map<String, Id> zipCodeNameToId = AccountService.getDmaZipCodeMapForAccountBillingCodes(accounts);
		System.assertEquals(zipCodeNameToId.size(), 2);

		AccountService.populateDmaZipCode(accounts, zipCodeNameToId);
		System.assertEquals(null, account1.DMA_Zip_Code__c, 'Account dma zip code expected to be blank.');
		Zip_Code_Data__c zipCodeObject1 = new Zip_Code_Data__c(Name = StringUtils.left(billingZipCode3, 5), OFFSET_DST__c = 1, OFFSET_ST__c = 1);
		insert zipCodeObject1;
		zipCodeNameToId.put(StringUtils.left(billingZipCode3, 5), zipCodeObject1.Id);
		AccountService.populateDmaZipCode(accounts, zipCodeNameToId);
		System.assertEquals(zipCodeObject1.Id, account1.DMA_Zip_Code__c);
		//test the insert trigger
		Account account2 = new Account(Name = 'Test Account', BillingPostalCode = billingZipCode3, DMA_Zip_Code__c = null);
		insert account2;

		account2 = [SELECT Id, BillingPostalCode, DMA_Zip_Code__c FROM Account where Id = :account2.Id limit 1][0];

		System.assertEquals(billingZipCode3, account2.BillingPostalCode);
		System.assertEquals(zipCodeObject1.Id, account2.DMA_Zip_Code__c, 'Account before insert trigger failed to set the DMA Zip Code.');
		//testing update trigger
		account2.BillingPostalCode = '00000';
		update account2;
		account2 = [SELECT Id, BillingPostalCode, DMA_Zip_Code__c FROM Account where Id = :account2.Id limit 1][0];
		System.assertEquals(null, account2.DMA_Zip_Code__c, 'Account before update trigger faield ot set the DMA zip to blank');
		account2.BillingPostalCode = billingZipCode3;
		update account2;
		account2 = [SELECT Id, BillingPostalCode, DMA_Zip_Code__c FROM Account where Id = :account2.Id limit 1][0];
		System.assertEquals(zipCodeObject1.Id, account2.DMA_Zip_Code__c, 'Account before update trigger failed to set the DMA Zip Code.');
	}
}