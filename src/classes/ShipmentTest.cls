@isTest
private class ShipmentTest {
	
	private static testMethod void testShipmentWithAccount() {
		Contact contact = new Contact();
		contact.FirstName = 'First Name';
		contact.LastName = 'Last Name';
		insert contact;
		Account account = new Account();
		account.Name = 'Account Name';
		account.Primary_Contact__c = contact.Id;
		insert account;

		Shipment shipment = new Shipment(account);

		system.assert(shipment.shipment.Account__c == account.Id);
		system.assert(shipment.shipment.RelatedWorkOrder__c == null);
	}

	private static testMethod void testShipmentWithAccountWithAssets() {
		Contact contact = new Contact();
		contact.FirstName = 'First Name';
		contact.LastName = 'Last Name';
		insert contact;
		Account account = new Account();
		account.Name = 'Account Name';
		account.Primary_Contact__c = contact.Id;
		insert account;
		Asset asset = new Asset();
		asset.AccountId = account.Id;
		asset.Name = 'Asset Name';
		asset.Status = 'Installed';
		insert asset;

		account = AccountService.getWithAssetsAndContactsById(account.Id, new List<String> {'BillingCity',
																							'BillingPostalCode',
																							'BillingState',
																							'BillingStateCode',
																							'BillingStreet',
																							'Name',
																							'Primary_Contact__c'}, new List<String> {'Name',
																																	 'Shipment__c',
																																	 'Status'}, new List<String> {'Id'});

		Shipment shipment = new Shipment(account);

		system.assert(shipment.shipment.Account__c == account.Id);
		system.assert(shipment.shipment.RelatedWorkOrder__c == null);
		system.assert(ListUtils.isNotNullOrEmpty(shipment.returnItems));
	}

	private static testMethod void testShipmentWithAccountAndCase() {
		Contact contact = new Contact();
		contact.FirstName = 'First Name';
		contact.LastName = 'Last Name';
		insert contact;
		Account account = new Account();
		account.Name = 'Account Name';
		account.Primary_Contact__c = contact.Id;
		insert account;
		Case workOrder = new Case();
		workOrder.AccountId = account.Id;
		insert workOrder;

		Shipment shipment = new Shipment(account, workOrder);

		system.assert(shipment.shipment.Account__c == account.Id);
		system.assert(shipment.shipment.RelatedWorkOrder__c == workOrder.Id);
	}

	private static testMethod void testLoadShipment() {
		Contact contact = new Contact();
		contact.FirstName = 'First Name';
		contact.LastName = 'Last Name';
		insert contact;
		Account account = new Account();
		account.Name = 'Account Name';
		account.Primary_Contact__c = contact.Id;
		insert account;
		Shipment__c shipmentToLoad = new Shipment__c();
 		shipmentToLoad.Account__c = account.Id;
 		shipmentToLoad.OrderId__c = '12345';
		insert shipmentToLoad;
		Product2 product = new Product2();
		product.IsActive = true;
		product.Name = 'Product Name';
		product.ProductCode = 'Product Code';
		insert product;
		ShipmentItem__c shipmentItem = new ShipmentItem__c();
		shipmentItem.Product__c = product.Id;
		shipmentItem.Quantity__c = 1;
		shipmentItem.Shipment__c = shipmentToLoad.Id;
		insert shipmentItem;

		Shipment shipment = new Shipment(account);
		system.assert(shipment.shipmentItems == null || shipment.shipmentItems.isEmpty());

		shipmentToLoad = ShipmentService.getWithShipmentItemsByOrderId('12345', new List<String> {'Account__c',
																								  'OrderId__c'}, new List<String> {'Product__c',
																								  								   'Product__r.Name',
																								  								   'Product__r.ProductCode',
																								  								   'Quantity__c',
																								  								   'TrackingNumber__c',
																								  								   'Type__c'});
		shipment.load(shipmentToLoad, null);
		system.assert(shipment.shipmentItems != null && !shipment.shipmentItems.isEmpty());
	}

	private static testMethod void testLoadShipmentWithAssets() {
		Contact contact = new Contact();
		contact.FirstName = 'First Name';
		contact.LastName = 'Last Name';
		insert contact;
		Account account = new Account();
		account.Name = 'Account Name';
		account.Primary_Contact__c = contact.Id;
		insert account;
		Asset asset = new Asset();
		asset.AccountId = account.Id;
		asset.Name = 'Asset Name';
		asset.Status = 'Installed';
		insert asset;
		Shipment__c shipmentToLoad = new Shipment__c();
 		shipmentToLoad.Account__c = account.Id;
 		shipmentToLoad.OrderId__c = '12345';
		insert shipmentToLoad;
		Product2 product = new Product2();
		product.IsActive = true;
		product.Name = 'Product Name';
		product.ProductCode = 'Product Code';
		insert product;
		ShipmentItem__c shipmentItem = new ShipmentItem__c();
		shipmentItem.Product__c = product.Id;
		shipmentItem.Quantity__c = 1;
		shipmentItem.Shipment__c = shipmentToLoad.Id;
		insert shipmentItem;

		Shipment shipment = new Shipment(account);
		system.assert(shipment.shipmentItems == null || shipment.shipmentItems.isEmpty());

		account = AccountService.getWithAssetsAndContactsById(account.Id, new List<String> {'BillingCity',
																							'BillingPostalCode',
																							'BillingState',
																							'BillingStateCode',
																							'BillingStreet',
																							'Name',
																							'Primary_Contact__c'}, new List<String> {'Name',
																																	 'Shipment__c',
																																	 'Status'}, new List<String> {'Id'});
		shipmentToLoad = ShipmentService.getWithShipmentItemsByOrderId('12345', new List<String> {'Account__c',
																								  'OrderId__c'}, new List<String> {'Product__c',
																								  								   'Product__r.Name',
																								  								   'Product__r.ProductCode',
																								  								   'Quantity__c',
																								  								   'TrackingNumber__c',
																								  								   'Type__c'});
		shipment.load(shipmentToLoad, new List<Asset> {asset});
		system.assert(shipment.shipmentItems != null && !shipment.shipmentItems.isEmpty());
		system.assert(ListUtils.isNotNullOrEmpty(shipment.returnItems));
	}

	private static testMethod void testClear() {
		Contact contact = new Contact();
		contact.FirstName = 'First Name';
		contact.LastName = 'Last Name';
		insert contact;
		Account account = new Account();
		account.Name = 'Account Name';
		account.Primary_Contact__c = contact.Id;
		insert account;
		Product2 product = new Product2();
		product.IsActive = true;
		product.Name = 'Product Name';
		product.ProductCode = 'Product Code';
		insert product;

		Shipment shipment = new Shipment(account);

		shipment.shipment.ShippingStreet__c = 'Second Street';
		shipment.shipment.ShippingCity__c = 'Second City';
		shipment.shipment.ShippingState__c = 'Second State';
		shipment.shipment.ShippingPostalCode__c = '12345';

		shipment.addProducts(new List<String> {'Product Code'});

		shipment.clear(account, null);

		system.assert(shipment.shipment.ShippingStreet__c != 'Second Street');
		system.assert(shipment.shipment.ShippingCity__c != 'Second City');
		system.assert(shipment.shipment.ShippingState__c != 'Second State');
		system.assert(shipment.shipment.ShippingPostalCode__c != '12345');
		system.assert(shipment.shipmentItems == null || shipment.shipmentItems.isEmpty());
	}

	private static testMethod void testClearWithReturnItems() {
		Contact contact = new Contact();
		contact.FirstName = 'First Name';
		contact.LastName = 'Last Name';
		insert contact;
		Account account = new Account();
		account.Name = 'Account Name';
		account.Primary_Contact__c = contact.Id;
		insert account;
		Asset asset = new Asset();
		asset.AccountId = account.Id;
		asset.Name = 'Asset Name';
		asset.Status = 'Installed';
		insert asset;
		Shipment__c shipmentToLoad = new Shipment__c();
 		shipmentToLoad.Account__c = account.Id;
 		shipmentToLoad.OrderId__c = '12345';
		insert shipmentToLoad;
		Product2 product = new Product2();
		product.IsActive = true;
		product.Name = 'Product Name';
		product.ProductCode = 'Product Code';
		insert product;
		ShipmentItem__c shipmentItem = new ShipmentItem__c();
		shipmentItem.Product__c = product.Id;
		shipmentItem.Quantity__c = 1;
		shipmentItem.Shipment__c = shipmentToLoad.Id;
		insert shipmentItem;

		account = AccountService.getWithAssetsAndContactsById(account.Id, new List<String> {'BillingCity',
																							'BillingPostalCode',
																							'BillingState',
																							'BillingStateCode',
																							'BillingStreet',
																							'Name',
																							'Primary_Contact__c'}, new List<String> {'Name',
																																	 'Shipment__c',
																																	 'Status'}, new List<String> {'Id'});
		Shipment shipment = new Shipment(account);
		system.assert(ListUtils.isNotNullOrEmpty(shipment.returnItems));
		for (Shipment.ReturnItem returnItem : shipment.returnItems) {
			returnItem.returning = true;
		}

		shipment.clear(account, null);
		for (Shipment.ReturnItem returnItem : shipment.returnItems) {
			system.assert(!returnItem.returning);
		}
	}

	private static testMethod void testAddPackage() {
		Contact contact = new Contact();
		contact.FirstName = 'First Name';
		contact.LastName = 'Last Name';
		insert contact;
		Account account = new Account();
		account.Name = 'Account Name';
		account.Primary_Contact__c = contact.Id;
		insert account;
		Product2 product = new Product2();
		product.IsActive = true;
		product.Name = 'Product Name';
		product.ProductCode = 'Product Code';
		insert product;
		Pricebook2 productPackage = new Pricebook2();
		productPackage.IsActive = true;
		productPackage.Name = 'Product Package';
		productPackage.PackageCode__c = 'Package Code';
		insert productPackage;
		PricebookEntry standardEntry = new PricebookEntry();
		standardEntry.Pricebook2Id = Test.getStandardPricebookId();
		standardEntry.Product2Id = product.Id;
		standardEntry.Quantity__c = 1;
		standardEntry.IsActive = true;
		standardEntry.UnitPrice = 0;
		insert standardEntry;
		PricebookEntry entry = new PricebookEntry();
		entry.Pricebook2Id = productPackage.Id;
		entry.Product2Id = product.Id;
		entry.Quantity__c = 1;
		entry.IsActive = true;
		entry.UnitPrice = 0;
		insert entry;

		Shipment shipment = new Shipment(account);
		shipment.addPackage('Package Code');

		system.assert(shipment.shipmentItems != null && !shipment.shipmentItems.isEmpty());
	}

	private static testMethod void testAddPackage2() {
		Contact contact = new Contact();
		contact.FirstName = 'First Name';
		contact.LastName = 'Last Name';
		insert contact;
		Account account = new Account();
		account.Name = 'Account Name';
		account.Primary_Contact__c = contact.Id;
		insert account;
		Product2 product = new Product2();
		product.IsActive = true;
		product.Name = 'Product Name';
		product.ProductCode = 'Product Code';
		insert product;
		Pricebook2 productPackage = new Pricebook2();
		productPackage.IsActive = true;
		productPackage.Name = 'Product Package';
		productPackage.PackageCode__c = 'Package Code';
		insert productPackage;
		PricebookEntry standardEntry = new PricebookEntry();
		standardEntry.Pricebook2Id = Test.getStandardPricebookId();
		standardEntry.Product2Id = product.Id;
		standardEntry.Quantity__c = 1;
		standardEntry.IsActive = true;
		standardEntry.UnitPrice = 0;
		insert standardEntry;
		PricebookEntry entry = new PricebookEntry();
		entry.Pricebook2Id = productPackage.Id;
		entry.Product2Id = product.Id;
		entry.Quantity__c = 1;
		entry.IsActive = true;
		entry.UnitPrice = 0;
		insert entry;

		Shipment shipment = new Shipment(account);

		shipment.addProducts(new List<String> {'Product Code'});
		shipment.addPackage('Package Code');

		system.assert(shipment.shipmentItems.get('Product Code').quantity == 2);
	}

	private static testMethod void testAddProducts() {
		Contact contact = new Contact();
		contact.FirstName = 'First Name';
		contact.LastName = 'Last Name';
		insert contact;
		Account account = new Account();
		account.Name = 'Account Name';
		account.Primary_Contact__c = contact.Id;
		insert account;
		Product2 product = new Product2();
		product.IsActive = true;
		product.Name = 'Product Name';
		product.ProductCode = 'Product Code';
		insert product;

		Shipment shipment = new Shipment(account);

		shipment.addProducts(new List<String> {'Product Code'});
		system.assert(shipment.shipmentItems.get('Product Code') != null);

		shipment.addProducts(new List<String> {'Product Code'});
		system.assert(shipment.shipmentItems.get('Product Code').quantity == 2);
	}

	private static testMethod void testRemoveProduct() {
		Contact contact = new Contact();
		contact.FirstName = 'First Name';
		contact.LastName = 'Last Name';
		insert contact;
		Account account = new Account();
		account.Name = 'Account Name';
		account.Primary_Contact__c = contact.Id;
		insert account;
		Product2 product = new Product2();
		product.IsActive = true;
		product.Name = 'Product Name';
		product.ProductCode = 'Product Code';
		insert product;

		Shipment shipment = new Shipment(account);

		shipment.addProducts(new List<String> {'Product Code'});
		shipment.remove('Product Code');

		system.assert(shipment.shipmentItems.get('Product Code') == null);
		system.assert(ListUtils.isNullOrEmpty(shipment.shipmentItemsList));
	}
}