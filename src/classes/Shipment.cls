public with sharing class Shipment {
	
	public Shipment__c shipment {get;set;}
	public Map<String, LineItem> shipmentItems {get;set;}
	public List<LineItem> shipmentItemsList { get { return shipmentItems.values(); } }
	public List<ReturnItem> returnItems {get;set;}

	public Map<String, Product2> products {get;set;}
	public List<SelectOption> productOptions {get;set;}
	public Map<String, Pricebook2> packages {get;set;}
	public List<SelectOption> packageOptions {get;set;}
	public List<SelectOption> expediteReasons {
		get {
			List<SelectOption> result = new List<SelectOption> { new SelectOption('', '--') };
			for (Schema.PicklistEntry entry : Schema.Shipment__c.ExpediteReason__c.getDescribe().getPicklistValues()) {
				result.add(new SelectOption(entry.getValue(), entry.getLabel()));
			}
			return result;
		}
	}
    
    public Map<id, List<LineItem>>  shipmentPackages {get;set;}

	public Shipment(Account account){ this(account, null); }
	public Shipment(Account account, Case thisCase) {
		clear(account, thisCase);
		
		List<Pricebook2> packageList = ShipmentService.getCustomPricebooksWithPricebookEntries(new List<String> {'Name',
																												 'PackageCode__c'},
																							   new List<String> {'Product2Id',
																							   					 'ProductCode',
																												 'Quantity__c'});
		packages = new Map<String, Pricebook2>();
		packageOptions = new List<SelectOption>();
		for (Pricebook2 thePackage : packageList) {
			packages.put(thePackage.PackageCode__c, thePackage);
			packageOptions.add(new SelectOption(thePackage.PackageCode__c, thePackage.Name));
		}
		List<Product2> productList = ShipmentService.getActiveProducts(new List<String> {'Box__c',
																						 'Box__r.ProductCode',
																						 'Family',
																						 'Hidden__c',
																						 'Id',
																						 'Name',
																						 'ProductCode'});
		products = new Map<String, Product2>();
		productOptions = new List<SelectOption>();
		for (Product2 product : productList) {
			if (product.Hidden__c) {
				if (PermissionUtils.hasPermissionSet('ProductAdministrator', UserInfo.getUserId())) {
					products.put(product.ProductCode, product);
					productOptions.add(new SelectOption(product.ProductCode, product.ProductCode + ' - ' + product.Name));
				}
			}
			else {
				products.put(product.ProductCode, product);
				productOptions.add(new SelectOption(product.ProductCode, product.ProductCode + ' - ' + product.Name));
			}
		}
		if (ListUtils.isNotNullOrEmpty(account.Assets)) {
			returnItems = new List<ReturnItem>();
			for (Asset asset : account.Assets) {
				if (asset.Status == 'Installed' || asset.Status == 'Shipped') {
					ReturnItem returnItem = new ReturnItem();
					returnItem.asset = asset;
					returnItem.returning = asset.Shipment__c != null;
					returnItems.add(returnItem);
				}
			}
		}
	}

	public void load(Shipment__c shipmentToLoad, List<Asset> assets) {
		shipment = shipmentToLoad;
		shipmentItems = new Map<String, LineItem>();
		for (ShipmentItem__c shipmentItem : shipmentToLoad.Shipment_Items__r) {
			LineItem lineItem = new LineItem();
			lineItem.productId = shipmentItem.Product__c;
			lineItem.productCode = shipmentItem.Product__r.ProductCode;
			lineItem.productName = shipmentItem.Product__r.Name;
			lineItem.quantity = Integer.valueOf(shipmentItem.Quantity__c);
			lineItem.type = shipmentItem.Type__c;
			shipmentItems.put(lineItem.productCode, lineItem);
		}

		shipmentPackages = new map<id,List<LineItem>>();
		for (ShipmentPackage__c shipPackage : shipment.ShipmentPackages__r) {
			List<String> productCodes = shipPackage.ProductCode__c.split(',');
			 
			List<LineItem> packageContents = new List<LineItem>();
			for (String code : productCodes) {
				packageContents.add(shipmentItems.get(code));
			}
			shipmentPackages.put(shipPackage.Id, packageContents);
		}

		for (ShipmentPackage__c shipPackage : shipment.ShipmentPackages__r) {
			List<String> productCodes = shipPackage.ProductCode__c.split(',');
			for (String code : productCodes) {
				shipmentItems.remove(code);
			}
		}

		if (ListUtils.isNotNullOrEmpty(assets)) {
			refreshReturnItems(assets);
		}
	}

	public void refreshReturnItems(List<Asset> assets) {
		if (ListUtils.isNotNullOrEmpty(assets)) {
			returnItems = new List<ReturnItem>();
			for (Asset asset : assets) {
				if (asset.Status == 'Installed') {
					ReturnItem returnItem = new ReturnItem();
					returnItem.asset = asset;
					returnItem.returning = asset.Shipment__c != null;
					returnItems.add(returnItem);
				}
			}
		}
	}

	public void clear(Account account, Case thisCase) {
		shipment = new Shipment__c();
		shipmentItems = new Map<String, LineItem>();

		shipment.Account__c = account.Id;
		shipment.Company__c = account.Name;
		shipment.Contact__c = thisCase == null ? account.Primary_Contact__c : thisCase.ContactId;
		if (shipment.ShippingStreet__c == null) {
			if (account.BillingStreet != null) {
				List<String> streetAddress = account.BillingStreet.split('\n');
				shipment.ShippingStreet__c = streetAddress[0];
				if (streetAddress.size() > 1) {
					shipment.ShippingStreet2__c = streetAddress[1];
				}
			}
			shipment.ShippingCity__c = account.BillingCity;
			shipment.ShippingState__c = account.BillingStateCode;
			shipment.ShippingPostalCode__c = account.BillingPostalCode;
		}
		if (thisCase != null) {
			shipment.RelatedWorkOrder__c = thisCase.Id;
		}
		if (ListUtils.isNotNullOrEmpty(returnItems)) {
			for (ReturnItem returnItem : returnItems) {
				if (returnItem.asset.Shipment__c == null) {
					returnItem.returning = false;
				}
			}
		}
	}

	public List<String> addPackage(String packageCode) {
		List<String> existingProducts = new List<String>();
		Pricebook2 thePackage = packages.get(packageCode);
		for (PricebookEntry entry : thePackage.PriceBookEntries) {
			if (shipmentItems.get(entry.ProductCode) == null) {
				LineItem lineItem = new LineItem();
				lineItem.productId = products.get(entry.ProductCode).Id;
				lineItem.productName = products.get(entry.ProductCode).Name;
				lineItem.productCode = entry.ProductCode;
				lineItem.quantity = Integer.valueOf(entry.Quantity__c == null ? 1 : entry.Quantity__c);
				shipmentItems.put(entry.ProductCode, lineItem);
			}
			else {
				shipmentItems.get(entry.ProductCode).quantity += Integer.valueOf(entry.Quantity__c);
				existingProducts.add(entry.ProductCode);
			}
		}
		return existingProducts;
	}

	public List<String> addProducts(List<String> productCodes) {
		List<String> existingProducts = new List<String>();
		if (ListUtils.isNotNullOrEmpty(productCodes)) {
			for (String productCode : productCodes) {
				if (productCode != null && shipmentItems.get(productCode) == null) {
					LineItem lineItem = new LineItem();
					lineItem.productId = products.get(productCode).Id;
					lineItem.productName = products.get(productCode).Name;
					lineItem.productCode = productCode;
					lineItem.type = products.get(productCode).Family;
					lineItem.quantity = 1;
					shipmentItems.put(productCode, lineItem);
				}
				else {
					shipmentItems.get(productCode).quantity++;
					existingProducts.add(productCode);
				}
			}
		}
		return existingProducts;
	}

	public void remove(String productCode) {
		shipmentItems.remove(productCode);
	}

	public class LineItem {
		public Id productId {get;set;}
		public String productCode {get;set;}
		public String productName {get;set;}
		public String type {get;set;}
		public Integer quantity {get;set;}
	}

	public class ReturnItem {
		public Boolean returning {get;set;}
		public Asset asset {get;set;}
	}
}