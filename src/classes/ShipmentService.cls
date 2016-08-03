public with sharing class ShipmentService {
	private static final String SHIPMENTx = 'Shipment__c';
	private static final String ASSETSx = 'Assets__r';
	private static final String SHIPMENTITEMSx = 'Shipment_Items__r';
	private static final String PRICEBOOKx = 'Pricebook2';
	private static final String PRICEBOOKENTRIESx = 'PricebookEntries';
	private static final String PRODUCTx = 'Product2';
	private static final String SHIPMENTPACKAGEx = 'ShipmentPackages__r';


	public static Shipment__c getWithShipmentItemsByOrderId(String orderId, List<String> shipmentFields, List<String> shipmentItemFields) {
		String soql = new SoqlBuilder()
						  .selectx(shipmentFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(shipmentItemFields)
						  		.fromx(SHIPMENTITEMSx))
						  .fromx(SHIPMENTx)
						  .wherex(new FieldCondition('OrderId__c').equals(orderId))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Shipment__c> getWithShipmentItemsAssetsShipmentPackagesByCaseId(Id caseId, List<String> shipmentFields, List<String> shipmentItemFields, List<String> assetFields, List<String> pkgFields) {
		String soql = new SoqlBuilder()
						  .selectx(shipmentFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(shipmentItemFields)
						  		.fromx(SHIPMENTITEMSx))
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(assetFields)
						  		.fromx(ASSETSx))
						   .selectx(
						  	new SoqlBuilder()
						  		.selectx(pkgFields)
						  		.fromx(SHIPMENTPACKAGEx))
						  .fromx(SHIPMENTx)
						  .wherex(new FieldCondition('RelatedWorkOrder__c').equals(caseId))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Shipment__c> getWithShipmentItemsAssetsShipmentPackagesByAccountIdOnly(Id accountId, List<String> shipmentFields, List<String> shipmentItemFields, List<String> assetFields,  List<String> pkgFields)  {
		String soql = new SoqlBuilder()
						  .selectx(shipmentFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(shipmentItemFields)
						  		.fromx(SHIPMENTITEMSx))
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(assetFields)
						  		.fromx(ASSETSx))
						   .selectx(
						  	new SoqlBuilder()
						  		.selectx(pkgFields)
						  		.fromx(SHIPMENTPACKAGEx))
						  .fromx(SHIPMENTx)
						  .wherex(new AndCondition()
						  			  .add(new FieldCondition('Account__c').equals(accountId))
						  			  .add(new FieldCondition('RelatedWorkOrder__c').equals(null)))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Product2> getActiveProducts(List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(PRODUCTx)
						  .wherex(new AndCondition()
						  			  .add(new FieldCondition('IsActive').equals(true))
						  			  .add(new FieldCondition('RecordType.Name').equals(new Constants.ProductRecordTypes().SUPPLY_CHAIN)))
						  .orderByx(new OrderBy('ProductCode').ascending())
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Pricebook2> getCustomPricebooksWithPricebookEntries(List<String> pricebookFields, List<String> pricebookEntryFields) {
		String soql = new SoqlBuilder()
						  .selectx(pricebookFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(pricebookEntryFields)
						  		.fromx(PRICEBOOKENTRIESx)
						  		.wherex(new FieldCondition('IsActive').equals(true)))
						  .fromx(PRICEBOOKx)
						  .wherex(new AndCondition()
						  			  .add(new FieldCondition('IsStandard').equals(false))
						  			  .add(new FieldCondition('IsActive').equals(true))
						  			  .add(new FieldCondition('RecordType.Name').equals(new Constants.ProductRecordTypes().SUPPLY_CHAIN)))
						  .orderByx(new OrderBy('PackageCode__c').ascending())
						  .toSoql();
		return Database.query(soql);
	}
	
	public static void save(Shipment shipment) {
		SavePoint savePoint = Database.setSavePoint();
		try {
			if (!shipment.shipmentItems.isEmpty() && shipment.shipment.RequestedDateOfArrival__c != null) {
				if (shipment.shipment.Id != null) {
					if (ListUtils.isNotNullOrEmpty(shipment.shipment.Shipment_Items__r)) {
						List<ShipmentItem__c> shipmentItemsToDelete = new List<ShipmentItem__c>();
						shipmentItemsToDelete.addAll(shipment.shipment.Shipment_Items__r);
						delete shipmentItemsToDelete;
					}
				}
				upsert shipment.shipment;
				List<ShipmentItem__c> shipmentItemsToInsert = new List<ShipmentItem__c>();
				for (Shipment.LineItem shipmentItem : shipment.shipmentItems.values()) {
					ShipmentItem__c shipmentItemToInsert = new ShipmentItem__c();
					shipmentItemToInsert.Name = shipmentItem.productCode;
					shipmentItemToInsert.Shipment__c = shipment.shipment.Id;
					shipmentItemToInsert.Product__c = shipmentItem.productId;
					shipmentItemToInsert.Quantity__c = shipmentItem.quantity;
					shipmentItemToInsert.Type__c = shipmentItem.type;
					shipmentItemsToInsert.add(shipmentItemToInsert);
				}
				List<Asset> assetsToUpdate;
				if (ListUtils.isNotNullOrEmpty(shipment.returnItems)) {
					assetsToUpdate = new List<Asset>();
					for (Shipment.ReturnItem returnItem : shipment.returnItems) {
						if (returnItem.returning && returnItem.asset.Shipment__c == null) {
							returnItem.asset.Shipment__c = shipment.shipment.Id;
							assetsToUpdate.add(returnItem.asset);
						}
						else if (!returnItem.returning && returnItem.asset.Shipment__c == shipment.shipment.Id) {
							returnItem.asset.Shipment__c = null;
							assetsToUpdate.add(returnItem.asset);
						}
					}
				}
				insert shipmentItemsToInsert;
				if (ListUtils.isNotNullOrEmpty(assetsToUpdate)) {
					update assetsToUpdate;
				}
			}
		}
		catch(DmlException ex) {
			Database.rollback(savePoint);
			throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_SAVE_ERROR + ex.getMessage() + ' - ' + ex.getStackTraceString() + ')');
		}
	}
	
	public static List<String> validate(Shipment shipment, Account account, Contact shipmentContact) {
		List<String> errors = new List<String>();
		if (shipment.shipment.isExpedited__c && shipment.shipment.ExpediteReason__c == null) {
			errors.add(new Constants.ShipmentValidationMessages().EXPEDITE_REASON);
		}
		if (shipment.shipment.RequestedDateOfArrival__c == null) {
			errors.add(new Constants.ShipmentValidationMessages().REQUESTED_DATE);
		}
		if (shipment.shipment.ShippingStreet__c == null || shipment.shipment.ShippingCity__c == null || shipment.shipment.ShippingState__c == null || shipment.shipment.ShippingPostalCode__c == null) {
			errors.add(new Constants.ShipmentValidationMessages().ADDRESS_INCOMPLETE);
		}
		if (ListUtils.isNullOrEmpty(shipment.shipmentItems.values())) {
			errors.add(new Constants.ShipmentValidationMessages().ITEMS_TO_RETURN);
		}
		if (shipment.shipment.Contact__c == null) {
			errors.add(new Constants.ShipmentValidationMessages().PRIMARY_CONTACT);
		}
		else {
			if (shipmentContact.Phone == null) {
				errors.add(new Constants.ShipmentValidationMessages().PHONE_NUMBER);
			}
		}
		if (account.CMHID__c == null) {
			errors.add(new Constants.ShipmentValidationMessages().CMH_ID);
		}
		if (account.DMA_Zip_Code__c == null) {
			errors.add(new Constants.ShipmentValidationMessages().DMA_ZIP);
		}
		if (String.isBlank(account.Time_Zone__c)) {
			errors.add(new Constants.ShipmentValidationMessages().DMA_TIMEZONE);
		}
		if (account.Network__c == null) {
			errors.add(new Constants.ShipmentValidationMessages().NETWORK);
		}
		for (Shipment.LineItem lineItem : shipment.shipmentItems.values()) {
			if (lineItem.quantity == 0) {
				errors.add(new Constants.ShipmentValidationMessages().LINE_ITEM_QUANTITY);
				break;
			}
		}

		return errors;
	}

	public static void sendShippedOrderAlert(Shipment__c shipment, List<ShipmentWebService.OrderItem> orderItems, Map<String, Integer> discrepancies) {
		String body = 'Order number ' + String.valueOf(shipment.OrderId__c) + ' has shipped but discrepancies were detected which require review.' + '<br/>' + '<br/>'
					+ 'It appears that assets should have been present for the following SKU(s) but were missing: ' + '<br/>';
		for (String productCode : discrepancies.keySet()) {
			if (discrepancies.get(productCode) > 0) {
				body += productCode + ' - ' + String.valueOf(discrepancies.get(productCode)) + '<br/>';
			}
		}
		body += '<br/>' + 'The following items were submitted with this shipment: ' + '<br/>';
		for (ShipmentItem__c item : shipment.Shipment_Items__r) {
			body += item.Product__r.Name + ' (' + item.Product__r.ProductCode + ') - ' + item.Quantity__c + '<br/>';
		}
		body += '<br/>' + 'The following assets were sent from iD: ' + '<br/>';
		for (ShipmentWebService.OrderItem orderItem : orderItems) {
			body += JSON.serializePretty(orderItem) + '<br/>';
		}

		string sEmailRecipients = EnvironmentUtils.getEnvironmentProperty('SHIPMENT_NOTIFICATION_RECIPIENTS');
		if (sEmailRecipients == 'Default'){sEmailRecipients = UserInfo.getUserEmail();}

		List<String> recipientsList = new list<string>();
		recipientslist= sEmailRecipients.split(',');
		EmailUtils.sendHTMLEmail(recipientsList, 'Shipped Assets Discrepancy', body);
	}
}