@isTest
private class AccountDetailsControllerTest {

	private static Account setup() {
		TestDataService.setupRestEnvironmentProperties();
		TestDataService.setupTestSupplyChainProductAndPackage();
		Map<String, Schema.RecordTypeInfo> accountRecordTypes = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName();
		Map<String, Schema.RecordTypeInfo> caseRecordTypes = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName();

		Contact contact = new Contact();
		contact.FirstName = 'Contact';
		contact.LastName = 'Contact';
		contact.Email = 'contact@email.edu';
		contact.Phone = '1234567890';
		insert contact;

		Account account = new Account();
		account.Name = 'Test Account';
		account.CMHID__c = 12345;
		account.Network__c = 'Network';
		account.BillingPostalCode = '60611';
		account.Primary_Contact__c = contact.Id;
		account.RecordTypeId = accountRecordTypes.get(new Constants.AccountRecordTypes().MEMBER_SERVICES).getRecordTypeId();
		insert account;

		Case workOrder = new Case();
		workOrder.AccountId = account.Id;
		workOrder.RecordTypeId = caseRecordTypes.get(new Constants.CaseRecordTypes().WORK_ORDERS).getRecordTypeId();
		insert workOrder;

		List<Asset> assets = new List<Asset>();
		Asset player = new Asset();
		player.Name = 'Player';
		player.Type__c = 'Player';
		player.AccountId = account.Id;
		assets.add(player);
		Asset unknownPlayer = new Asset();
		unknownPlayer.Name = 'Unknown Player';
		unknownPlayer.Type__c = 'Player';
		unknownPlayer.AccountId = account.Id;
		assets.add(unknownPlayer);
		Asset tablet = new Asset();
		tablet.Name = 'Tablet';
		tablet.Type__c = 'Tablet';
		tablet.AccountId = account.Id;
		assets.add(tablet);
		Asset unknownTablet = new Asset();
		unknownTablet.Name = 'Unknown Tablet';
		unknownTablet.Type__c = 'Tablet';
		unknownTablet.AccountId = account.Id;
		assets.add(unknownTablet);
		insert assets;

		return AccountService.getWithAssetsAndContactsById(account.Id, new List<String> {'BillingCity',
																						 'BillingCountry',
																						 'BillingPostalCode',
																						 'BillingState',
																						 'BIllingStateCode',
																						 'BillingStreet',
																						 'CMHID__c',
																						 'Id',
																						 'Name',
																						 'Network__c',
																						 'Owner.Name',
																						 'Primary_Contact__c',
																						 'RecordType.Name',
																						 'Stage__c',
																						 'Time_Zone__c'}, new List<String> {'ClinicExamRoom__c',
																														    'Id',
																														    'Installation_Status__c',
																														    'InstalledDate__c',
																														    'MountType__c',
																														    'Name',
																														    'Shipment__c',
																														    'Speciality__c',
																														    'Status',
																														    'Type__c',
																														    'Volume__c'}, new List<String> {'Id'});
	}
	
	private static testmethod void testAccountDetailsControllerConstructor() {
		Account account = setup();
		
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AccountDetailsMock(200));
		AccountDetailsController controller = new AccountDetailsController(new ApexPages.StandardController(account));
		Test.stopTest();

		system.assert(controller.account.Name == 'Test Account');
		system.assert(ListUtils.isNotNullOrEmpty(controller.players));
		system.assert(ListUtils.isNotNullOrEmpty(controller.tablets));
		system.assert(controller.showAssets);
		system.assert(controller.showPlayers);
		system.assert(controller.showShipments);
		system.assert(controller.showTablets);
		system.assert(controller.showWorkOrders);

		system.assert(!controller.showShipmentPackages);
		system.assert(!controller.showShipmentMissingTrackingItems);
		system.assert(!controller.showShipmentHistory);
	}

	private static testmethod void testSaveTablets() {
		Account account = setup();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AccountDetailsMock(200));
		AccountDetailsController controller = new AccountDetailsController(new ApexPages.StandardController(account));
		controller.saveTablets();
		Test.stopTest();
	}

	private static testmethod void testSaveTablets2() {
		Account account = setup();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AccountDetailsMock(200));
		AccountDetailsController controller = new AccountDetailsController(new ApexPages.StandardController(account));
		for (Asset tablet : controller.tablets) {
			tablet.Volume__c = 99;
		}
		controller.saveTablets();
		Test.stopTest();
	}

	private static testmethod void testAddProducts() {
		Account account = setup();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AccountDetailsMock(200));
		AccountDetailsController controller = new AccountDetailsController(new ApexPages.StandardController(account));

		controller.addProducts();
		Test.stopTest();

		system.assert(controller.hasErrors);
	}

	private static testmethod void testAddProducts2() {
		Account account = setup();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AccountDetailsMock(200));
		AccountDetailsController controller = new AccountDetailsController(new ApexPages.StandardController(account));
		
		controller.selectedProducts = new List<String> {'Product'};
		controller.addProducts();
		Test.stopTest();

		system.assert(controller.showShipmentItems);
	}

	private static testmethod void testAddPackage() {
		Account account = setup();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AccountDetailsMock(200));
		AccountDetailsController controller = new AccountDetailsController(new ApexPages.StandardController(account));

		controller.addPackage();
		Test.stopTest();

		system.assert(controller.hasErrors);
	}

	private static testmethod void testAddPackage2() {
		Account account = setup();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AccountDetailsMock(200));
		AccountDetailsController controller = new AccountDetailsController(new ApexPages.StandardController(account));

		controller.selectedPackage = 'Package';
		controller.addPackage();
		Test.stopTest();

		system.assert(controller.showShipmentItems);
	}

	private static testmethod void testRemoveProduct() {
		Account account = setup();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AccountDetailsMock(200));
		AccountDetailsController controller = new AccountDetailsController(new ApexPages.StandardController(account));
		
		controller.selectedProducts = new List<String> {'Product'};
		controller.addProducts();

		ApexPages.currentPage().getParameters().put('product', 'Product');
		controller.removeProduct();
		Test.stopTest();

		system.assert(controller.shipment.shipmentItems.isEmpty());
	}

	private static testmethod void testCreateShipment() {
		Account account = setup();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AccountDetailsMock(200));
		AccountDetailsController controller = new AccountDetailsController(new ApexPages.StandardController(account));
		
		controller.shipment.shipment.RequestedDateOfArrival__c = System.today();
		controller.shipment.shipment.ShippingStreet__c = '330 N Wabash';
		controller.shipment.shipment.ShippingCity__c = 'Chicago';
		controller.shipment.shipment.ShippingState__c = 'IL';
		controller.shipment.shipment.ShippingPostalCode__c = '60611';
		controller.selectedPackage = 'Package';
		controller.addPackage();

		Test.setMock(HttpCalloutMock.class, new ShipmentMock(201));
		controller.saveShipment();
		Test.stopTest();
	}

	private static testmethod void testUpdateShipment() {
		Account account = setup();
		Shipment__c shipment = new Shipment__c();
		shipment.Account__c = account.Id;
		shipment.OrderId__c = '12345';
		shipment.RequestedDateOfArrival__c = System.today();
		shipment.ShippingStreet__c = '330 N Wabash';
		shipment.ShippingCity__c = 'Chicago';
		shipment.ShippingState__c = 'IL';
		shipment.ShippingPostalCode__c = '60611';
		insert shipment;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AccountDetailsMock(200));
		AccountDetailsController controller = new AccountDetailsController(new ApexPages.StandardController(account));
		
		controller.selectedPackage = 'Package';
		controller.addPackage();

		Test.setMock(HttpCalloutMock.class, new ShipmentMock(202));
		ApexPages.currentPage().getParameters().put('orderId', shipment.Id);
		controller.editShipment();
		controller.selectedPackage = 'Package';
		controller.addPackage();
		controller.saveShipment();
		Test.stopTest();
	}

	private static testmethod void testCancelShipment() {
		Account account = setup();
		Shipment__c shipment = new Shipment__c();
		shipment.Account__c = account.Id;
		shipment.OrderId__c = '12345';
		shipment.RequestedDateOfArrival__c = System.today();
		shipment.ShippingStreet__c = '330 N Wabash';
		shipment.ShippingCity__c = 'Chicago';
		shipment.ShippingState__c = 'IL';
		shipment.ShippingPostalCode__c = '60611';
		insert shipment;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AccountDetailsMock(200));
		AccountDetailsController controller = new AccountDetailsController(new ApexPages.StandardController(account));
		
		controller.selectedPackage = 'Package';
		controller.addPackage();

		Test.setMock(HttpCalloutMock.class, new ShipmentMock(200));
		ApexPages.currentPage().getParameters().put('orderId', shipment.Id);
		controller.cancelShipment();
		Test.stopTest();
	}
}