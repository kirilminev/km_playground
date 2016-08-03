@isTest
private class ShipmentServiceTest {
	
	private static testMethod void testGetWithShipmentItemsByOrderId() {
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Shipment__c shipment = new Shipment__c();
		shipment.OrderId__c = '12345';
		shipment.Account__c = account.Id;
		insert shipment;
		ShipmentItem__c item = new ShipmentItem__c();
		item.Quantity__c = 1;
		item.Shipment__c = shipment.Id;
		insert item;

		Shipment__c result = ShipmentService.getWithShipmentItemsByOrderId('12345', new List<String> {'Account__c',
																									  'OrderId__c'}, new List<String> {'Quantity__c',
																									  								   'Shipment__c'});
		system.assert(result.Id == shipment.Id);
		system.assert(ListUtils.isNotNullOrEmpty(result.Shipment_Items__r));
	}

	private static testMethod void testGetWithShipmentItemsAndAssetsByCaseId() {
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Case workOrder = new Case();
		workOrder.AccountId = account.Id;
		insert workOrder;
		Shipment__c shipment = new Shipment__c();
		shipment.OrderId__c = '12345';
		shipment.Account__c = account.Id;
		shipment.RelatedWorkOrder__c = workOrder.Id;
		insert shipment;
		Asset asset = new Asset();
		asset.Name = 'Asset Name';
		asset.AccountId = account.Id;
		asset.Shipment__c = shipment.Id;
		insert asset;
		ShipmentItem__c item = new ShipmentItem__c();
		item.Quantity__c = 1;
		item.Shipment__c = shipment.Id;
		insert item;

		List<Shipment__c> results = ShipmentService.getWithShipmentItemsAssetsShipmentPackagesByCaseId(workOrder.Id, new List<String> {'Account__c',
																														 'OrderId__c',
																														 'RelatedWorkOrder__c'},
																									   new List<String> {'Quantity__c',
																									   					 'Shipment__c'},
																									   new List<String> {'AccountId',
																									   					 'Name'},
																									   new List<String> {'Id'});
		for (Shipment__c result : results) {
			system.assert(result.Id == shipment.Id);
			system.assert(ListUtils.isNotNullOrEmpty(result.Shipment_Items__r));
			system.assert(ListUtils.isNotNullOrEmpty(result.Assets__r));
		}
	}

	private static testMethod void testGetWithShipmentItemsAndAssetsByAccountIdOnly() {
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Case workOrder = new Case();
		workOrder.AccountId = account.Id;
		insert workOrder;
		Shipment__c shipment = new Shipment__c();
		shipment.OrderId__c = '12345';
		shipment.Account__c = account.Id;
		insert shipment;
		Asset asset = new Asset();
		asset.Name = 'Asset Name';
		asset.AccountId = account.Id;
		asset.Shipment__c = shipment.Id;
		insert asset;
		ShipmentItem__c item = new ShipmentItem__c();
		item.Quantity__c = 1;
		item.Shipment__c = shipment.Id;
		insert item;

		List<Shipment__c> results = ShipmentService.getWithShipmentItemsAssetsShipmentPackagesByAccountIdOnly(account.Id, new List<String> {'Account__c',
																															   'OrderId__c',
																															   'RelatedWorkOrder__c'},
																											 new List<String> {'Quantity__c',
																									   						   'Shipment__c'},
																											 new List<String> {'AccountId',
																									   						   'Name'},
																									   		 new List<String> {'Id'});
		for (Shipment__c result : results) {
			system.assert(result.Id == shipment.Id);
			system.assert(ListUtils.isNotNullOrEmpty(result.Shipment_Items__r));
			system.assert(ListUtils.isNotNullOrEmpty(result.Assets__r));
		}
	}

	private static testMethod void testGetActiveProducts() {
		List<Product2> products = ShipmentService.getActiveProducts(new List<String> {'ProductCode'});
	}

	private static testMethod void testGetCustomPricebooksWithPricebookEntries() {
		List<Pricebook2> pricebooks = ShipmentService.getCustomPricebooksWithPricebookEntries(new List<String> {'Id'}, new List<String> {'Id'});
	}

	private static testMethod void testValidate() {
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Contact contact = new Contact();
		contact.FirstName = 'First Name';
		contact.LastName = 'Last Name';
		contact.AccountId = account.Id;
		insert contact;
		Shipment shipment = new Shipment(account);
		shipment.shipment.isExpedited__c = true;

		List<String> result = ShipmentService.validate(shipment, account, contact);
		for(String s : result) {
			system.debug(s);
		}
		

		system.assert(ListUtils.isNotNullOrEmpty(result), 'Errors should have been generated');
		system.assertEquals(new Constants.ShipmentValidationMessages().EXPEDITE_REASON, result[0], 'Incorrect error message');
		system.assertEquals(new Constants.ShipmentValidationMessages().REQUESTED_DATE, result[1], 'Incorrect error message');
		system.assertEquals(new Constants.ShipmentValidationMessages().ADDRESS_INCOMPLETE, result[2], 'Incorrect error message');
		system.assertEquals(new Constants.ShipmentValidationMessages().ITEMS_TO_RETURN, result[3], 'Incorrect error message');
		system.assertEquals(new Constants.ShipmentValidationMessages().PRIMARY_CONTACT, result[4], 'Incorrect error message');
		system.assertEquals(new Constants.ShipmentValidationMessages().CMH_ID, result[5], 'Incorrect error message');
		system.assertEquals(new Constants.ShipmentValidationMessages().DMA_ZIP, result[6], 'Incorrect error message');
		system.assertEquals(new Constants.ShipmentValidationMessages().DMA_TIMEZONE, result[7], 'Incorrect error message');
		system.assertEquals(new Constants.ShipmentValidationMessages().NETWORK, result[8], 'Incorrect error message');


	}
}