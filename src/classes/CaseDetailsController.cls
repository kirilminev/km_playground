public with sharing class CaseDetailsController extends CaseDetailsActions {
	private static final String CASEx = 'Case';
	public Case thisCase {get;set;}
	public Account account {get;set;}

	public Shipment shipment {get;set;}
	public Contact shipmentContact {get;set;}
	public List<Shipment__c> shipments {get;set;}

	//View related things.
	public Boolean hasErrors { get { return ApexPages.hasMessages(ApexPages.Severity.ERROR);} }
	public Boolean showReceivingItems { get { return ListUtils.isNotNullOrEmpty(shipment.returnItems);} }
	public Boolean showShipments { get { return thisCase.RecordType.Name == new Constants.CaseRecordTypes().WORK_ORDERS && thisCase.AccountId != null;} }
	public Boolean showShipmentItems { get { return shipment.shipmentItems!= null && !shipment.shipment.Shipped__c && !shipment.shipmentItems.isEmpty();} }
	public Boolean showShipmentPackages { get { return shipment.shipment != null && shipment.shipment.Shipped__c;} }
	public Boolean showShipmentMissingTrackingItems { get { return shipment.shipmentItems != null && shipment.shipment.Shipped__c && !shipment.shipmentItems.isEmpty();} }
	public Boolean showShipmentHistory { get { return ListUtils.isNotNullOrEmpty(shipments);} }
	public String selectedPackage {get;set;}
	public List<String> selectedProducts {get;set;}
	public List<String> productCodesToHighlight {get;set;}
	public Integer leadTimeInDays {get;set;}
	public List<String> availableDays {get;set;}
	public List<String> expediteDays {get;set;}
	public String serializedDays { get { return JSON.serialize(availableDays); } }
	public String serializedExpediteDays { get { return JSON.serialize(expediteDays); } }
	public String serializedCodes { get { return JSON.serialize(productCodesToHighlight);} }

	public CaseDetailsController(ApexPages.StandardController standardController) {
		standardController.addFields(new List<String> {'AccountId',
													   'CaseNumber',
													   'ContactId',
													   'Id',
													   'LatestServiceDateEnd__c',
													   'Product__c',
													   'RecordType.Name',
													   'Service__c',
													   'Status',
													   'Subject',
													   'Type'});
		thisCase = (Case)standardController.getRecord();
		if (showShipments) {
			account = AccountService.getWithAssetsAndContactsById(thisCase.AccountId, new List<String> {'BillingCity',
																										'BillingPostalCode',
																										'BillingState',
																										'BillingStateCode',
																									 	'BillingStreet',
																									 	'CMHID__c',
																									 	'DMA_Zip_Code__c',
																										'Id',
																										'Name',
																										'Network__c',
																									 	'Time_Zone__c'},
																					  new List<String> {'Id',
																				   						'Installation_Status__c',
																				   						'InstalledDate__c',
																				  						'Name',
																				  						'Product2.Box__r.ProductCode',
																				  						'Shipment__c',
																				  						'Status',
																				  					 	'Type__c'},
																					  new List<String> {'Email',
																				  						'FirstName',
																				  						'Id',
																				  						'LastName',
																				  						'Phone',
																				  						'Primary_Contact__c'});
			shipment = new Shipment(account, thisCase);
			refreshContact();
			loadShipments();
			Map<String, Lead_Time__c> leadTimes = Lead_Time__c.getAll();
			if (account.BillingPostalCode == null) {

			}
			else {
				leadTimeInDays = leadTimes.get(account.BillingPostalCode.split('-')[0]) == null ? 1 : Integer.valueOf(leadTimes.get(account.BillingPostalCode.split('-')[0]).Lead_Time__c);
				system.debug('lead time: ' + leadTimeInDays);
				system.debug('the time: ' + Datetime.now().hour());
				if (Datetime.now().hour() >= 17) {
					leadTimeInDays = leadTimeInDays + 1;
					system.debug('new lead time: ' + leadTimeInDays);
				}
			}
			availableDays = BusinessHoursService.getAvailableShippingDays(180);
			expediteDays = new List<String>();
			for (Integer i = 0; i < leadTimeInDays; i++) {
				expediteDays.add(availableDays[i]);
			}
		}
	}

	public void loadShipments() {
		shipments = ShipmentService.getWithShipmentItemsAssetsShipmentPackagesByCaseId(thisCase.Id, new List<String> {'Account__c',
																													  'AccountName__c',
																													  'AMDelivery__c',
																													  'CmhId__c',
																													  'Company__c',
																													  'Contact__c',
																													  'CreatedDate',
																													  'ExpediteReason__c',
																													  'Id',
																													  'isExpedited__c',
																													  'Name',
																													  'OrderId__c',
																													  'RequestedDateOfArrival__c',
																													  'RequestedPickupDate__c',
																													  'Shipped__c',
																													  'ShippedDate__c',
																													  'ShippingCity__c',
																													  'ShippingPostalCode__c',
																													  'ShippingState__c',
																													  'ShippingStreet__c',
																													  'ShippingStreet2__c',
																													  'TrackingNumber__c'},
																								    new List<String> {'Name',
																								  					  'Product__c',
																								  					  'Product__r.Name',
																								  					  'Product__r.ProductCode',
																													  'Quantity__c',
																													  'TrackingNumber__c',
																													  'Type__c'},
																								    new List<String> {'Id',
																							   						  'Installation_Status__c',
																							   						  'InstalledDate__c',
																							  						  'Name',
																							  						  'Product2.Box__r.ProductCode',
																							  						  'Shipment__c',
																							  						  'Status',
																							  					 	  'Type__c'},
																						  		    new List<String> {'ActivityDate__c',
																										  		   	  'Id',
																										  		   	  'LeftAtLocation__c',
																						  		   					  'ProductCode__c',
																						  		   					  'ScheduledDeliveryDate__c',
																						  		   					  'SignedForName__c',
																						  							  'Status__C',
																						  							  'TrackingNumber__c'});
	}

	public void addBox() {
		String boxId = ApexPages.currentPage().getParameters().get('product');
		productCodesToHighlight = new List<String>();
		if (boxId == '') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The appropriate box for this asset was unable to be determined. Please add the box and a receiving label manually.'));
		}
		else {
			productCodesToHighlight = shipment.addProducts(new List<String> {boxId, 'LAB101'});
		}
	}

	public void addPackage() {
		productCodesToHighlight = new List<String>();
		if (selectedPackage == null || selectedPackage == '') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a package.'));
		}
		else {
			productCodesToHighlight = shipment.addPackage(selectedPackage);
		}
	}

	public void addProducts() {
		productCodesToHighlight = new List<String>();
		if (ListUtils.isNullOrEmpty(selectedProducts)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select one or more products.'));
		}
		else {
			productCodesToHighlight = shipment.addProducts(selectedProducts);
		}
	}

	public void refreshContact() {
		if (shipment.shipment.Contact__c != null) {
			try {
				shipmentContact = ContactService.getById(shipment.shipment.Contact__c, new List<String> {'Email',
																										 'FirstName',
																										 'LastName',
																										 'Phone'});
			}
			catch(QueryException ex) {
				shipmentContact = null;
			}
		}
		else {
			shipmentContact = null;
		}
	}

	public void removeProduct() {
		String productId = ApexPages.currentPage().getParameters().get('product');
		try {
			shipment.remove(productId);
		}
		catch(Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}

	public void saveShipment() {
		try {
			if (shipment.shipment.Contact__c != null) {
				shipmentContact = ContactService.getById(shipment.shipment.Contact__c, new List<String> {'Email',
																										 'FirstName',
																										 'LastName',
																										 'Phone'});
			}
			List<String> errors = ShipmentService.validate(shipment, account, shipmentContact);
			if (ListUtils.isNotNullOrEmpty(errors)) {
				for (String error : errors) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
				}
			}
			else {
				shipment.shipment.EstimatedShipDate__c = BusinessHoursService.getEstimatedShipDate(shipment.shipment, leadTimeInDays);
				if (shipment.shipment.OrderId__c == null) {
					//Increment the return label SKU if it exists and add 1 if it doesn't.
					if (shipment.shipmentItems.get(new Constants.ProductCodes().RETURN_LABEL) != null) {
						shipment.shipmentItems.get(new Constants.ProductCodes().RETURN_LABEL).quantity++;
					}
					else {
						shipment.addProducts(new List<String> {new Constants.ProductCodes().RETURN_LABEL});
					}
					
					Long orderId = Crypto.getRandomLong();
					shipment.shipment.OrderId__c = String.valueOf(orderId < 0 ? orderId * -1 : orderId);
					ShipmentDelegate.putOrder(shipment, account, shipmentContact);
					ShipmentService.save(shipment);
					shipments.add(shipment.shipment);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The order was saved successfully!'));
				}
				else {
					ShipmentDelegate.updateOrder(shipment, account, shipmentContact);
					ShipmentService.save(shipment);
					shipments.add(shipment.shipment);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The order was updated successfully!'));
				}
				loadShipments();
				clearShipment();
				shipment.refreshReturnItems(AssetService.getByAccountId(account.Id, new List<String> {'Id',
																			   						  'Installation_Status__c',
																			   						  'InstalledDate__c',
																			  						  'Name',
																			  						  'Product2.Box__r.ProductCode',
																			  						  'Shipment__c',
																			  						  'Status',
																			  					 	  'Type__c'}));
			}
		}
		catch(Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}

	public void editShipment() {
		String orderId = ApexPages.currentPage().getParameters().get('orderId');
		system.debug('Order Id: ' + orderId);
		for (Shipment__c order : shipments) {
			if (order.Id == orderId) {
				shipment.load(order, account.Assets);
				refreshContact();
			}
		}
	}

	public void cancelShipment() {
		String orderId = ApexPages.currentPage().getParameters().get('orderId');
		try {
			if (orderId != null && orderId != '') {
				HttpRequestResult cancelRequestResult = ShipmentDelegate.cancelOrder(orderId);
				if (cancelRequestResult.success) {
					for (Integer i = 0; i < shipments.size(); i++) {
						if (shipments[i].OrderId__c == orderId) {
							delete shipments[i];
							shipments.remove(i);
							shipment.refreshReturnItems(AssetService.getByAccountId(account.Id, new List<String> {'Id',
																						   						  'Installation_Status__c',
																						   						  'InstalledDate__c',
																						  						  'Name',
																						  						  'Product2.Box__r.ProductCode',
																						  						  'Shipment__c',
																						  						  'Status',
																						  					 	  'Type__c'}));
							break;
						}
					}
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, cancelRequestResult.userFriendlyResultMessage));
				} else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, cancelRequestResult.userFriendlyResultMessage));
				}
			}
		}
		catch(Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}

	public void clearShipment() {
		shipment.clear(account, thisCase);
	}
}