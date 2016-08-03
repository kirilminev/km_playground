public with sharing class AccountDetailsController {
	public Account account {get;set;}
	public List<Asset> players {get;set;}
	public Map<Id, Asset> initialTablets {get;set;}
	public List<Asset> tablets {get;set;}

	public Map<Id, BroadsignBo> assetIdToBroadsignData {get;set;}
	public Map<Id, MdmBo> assetIdToMdmData {get;set;}

	public Shipment shipment {get;set;}
	public Contact shipmentContact {get;set;}
	public List<Shipment__c> shipments {get;set;}
	public List<Case> workOrders {get;set;}

	//View related things.
	public Boolean showAssets { get { return account.RecordType.Name == new Constants.AccountRecordTypes().MEMBER_SERVICES && (ListUtils.isNotNullOrEmpty(players) || ListUtils.isNotNullOrEmpty(tablets));} }
	public Boolean hasErrors { get { return ApexPages.hasMessages(ApexPages.Severity.ERROR);} }
	public Boolean showPlayers { get { return ListUtils.isNotNullOrEmpty(players);} }
	public Boolean showTablets { get { return ListUtils.isNotNullOrEmpty(tablets);} }
	public Boolean showShipmentItems { get { return shipment.shipmentItems != null && !shipment.shipment.Shipped__c && !shipment.shipmentItems.isEmpty();} }
	public Boolean showShipmentPackages { get { return shipment.shipment != null && shipment.shipment.Shipped__c ;} }
	public Boolean showShipmentMissingTrackingItems { get { return shipment.shipmentItems != null && shipment.shipment.Shipped__c && !shipment.shipmentItems.isEmpty();} }
	public Boolean showShipmentHistory { get { return ListUtils.isNotNullOrEmpty(shipments);} }
	public Boolean showShipments { get { return account.RecordType.Name == new Constants.AccountRecordTypes().MEMBER_SERVICES;} }
	public Boolean showWorkOrders { get { return ListUtils.isNotNullOrEmpty(workOrders);} }
	public String selectedPackage {get;set;}
	public List<String> selectedProducts {get;set;}
	public List<String> productCodesToHighlight {get;set;}
	public Integer leadTimeInDays {get;set;}
	public List<String> availableDays {get;set;}
	public List<String> expediteDays {get;set;}
	public String serializedDays { get { return JSON.serialize(availableDays); } }
	public String serializedExpediteDays { get { return JSON.serialize(expediteDays); } }
	public String serializedCodes { get { return JSON.serialize(productCodesToHighlight);} }

	public AccountDetailsController(ApexPages.StandardController standardController) {
		if (!Test.isRunningTest()) {
			standardController.addFields(new List<String> {'BillingCity',
													       'BillingCountry',
													       'BillingPostalCode',
													       'BillingState',
													       'BillingStateCode',
													       'BillingStreet',
													       'CMHID__c',
													       'DMA_Zip_Code__c',
													       'Id',
													       'Name',
													       'Network__c',
													       'Primary_Contact__c',
													       'RecordType.Name',
													       'Stage__c',
													       'Time_Zone__c'});
		}
		account = (Account)standardController.getRecord();
		List<Asset> assets = AssetService.getByAccountId(account.Id, new List<String> {'ClinicExamRoom__c',
																					   'Id',
																					   'Installation_Status__c',
																					   'InstalledDate__c',
																					   'MountType__c',
																					   'Name',
																					   'Shipment__c',
																					   'Speciality__c',
																					   'Status',
																					   'Type__c',
																					   'Volume__c'});
		players = new List<Asset>();
		initialTablets = new Map<Id, Asset>();
		tablets = new List<Asset>();
		for (Asset asset : assets) {
			if (asset.Shipment__c == null) {
				if (asset.Type__c == new Constants.AssetTypes().PLAYER) {
					players.add(asset);
				}
				else if (asset.Type__c == new Constants.AssetTypes().TABLET) {
					initialTablets.put(asset.Id, asset.clone());
					tablets.add(asset);
				}
			}
		}
		if (ListUtils.isNotNullOrEmpty(players)) {
			getBroadsignData();
		}
		if (ListUtils.isNotNullOrEmpty(tablets)) {
			getMdmData();
		}
		if (showShipments) {
			workOrders = CaseService.getWorkOrdersWithShipmentsByAccountId(account.Id, new List<String> {'CaseNumber',
																										 'Field_Partner_Contact__r.Name',
																										 'Id',
																										 'LatestServiceDateEnd__c',
																										 'Product__c',
																										 'Service__c',
																										 'Status',
																										 'Subject',
																										 'Type'},
																					   new List<String> {'CreatedDate',
																										 'Id',
																										 'Name',
																										 'OrderId__c',
																										 'RequestedDateOfArrival__c',
																										 'Shipped__c',
																										 'ShippedDate__c',
																										 'TrackingNumber__c'});
			shipment = new Shipment(account);
			refreshContact();
			loadShipments();
			Map<String, Lead_Time__c> leadTimes = Lead_Time__c.getAll();
			if (account.BillingPostalCode == null) {

			}
			else {
				leadTimeInDays = leadTimes.get(account.BillingPostalCode.split('-')[0]) == null ? 1 : Integer.valueOf(leadTimes.get(account.BillingPostalCode.split('-')[0]).Lead_Time__c);
			}
			availableDays = BusinessHoursService.getAvailableShippingDays(180);
			expediteDays = new List<String>();
			for (Integer i = 0; i < leadTimeInDays; i++) {
				expediteDays.add(availableDays[i]);
			}
		}
	}

	public void getBroadsignData() {
		Map<String, Object> broadsignResponse = new Map<String, Object>();
		try {
			broadsignResponse = BroadsignDelegate.getBroadsignStatusesByClinicId(String.valueOf(Integer.valueOf(account.CMHID__c)));
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, new Constants.ExceptionMessages().CALLOUT_EXCEPTION_GENERIC + ex.getMessage() + ')'));
		}
		if (broadsignResponse.get('error') != null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, new Constants.ExceptionMessages().BROADSIGN_EXCEPTION_NOT_FOUND + broadsignResponse.get('error') + ')'));
		}
		else {
			assetIdToBroadsignData = new Map<Id, BroadsignBo>();
			for (Asset player : players) {
				if (broadsignResponse.get(player.Name) != null) {
					Map<String, Object> playerResponse = (Map<String, Object>)broadsignResponse.get(player.Name);
					
					BroadsignBo broadsignBo = new BroadsignBo();
					broadsignBo.avVersion = (String)playerResponse.get('AVVersion');
					broadsignBo.clockSkew = (String)playerResponse.get('ClockSkew');
					broadsignBo.currentLocation = (String)playerResponse.get('CurrentLocation');
					broadsignBo.currentlyDownloading = (String)playerResponse.get('CurrentlyDownloading');
					broadsignBo.currentlyPlaying = (String)playerResponse.get('CurrentlyPlaying');
					broadsignBo.currentVolume = (String)playerResponse.get('CurrentVolume');
					broadsignBo.displayUnitId = (String)playerResponse.get('display_unit_id');
					broadsignBo.issue = (String)playerResponse.get('Issue');
					broadsignBo.lastPoll = (String)playerResponse.get('lastpoll');
					broadsignBo.localTime = (String)playerResponse.get('LocalTime');
					broadsignBo.loopx = (String)playerResponse.get('loop');
					broadsignBo.name = (String)playerResponse.get('name');
					broadsignBo.nextAdToDownload = (String)playerResponse.get('NextAdToDownload');
					broadsignBo.nextPoll = (String)playerResponse.get('nextpoll');
					broadsignBo.playerId = (String)playerResponse.get('id');
					broadsignBo.playerVersion = (String)playerResponse.get('PlayerVersion');
					broadsignBo.screenResolution = (String)playerResponse.get('ScreenResolution');
					broadsignBo.status = (String)playerResponse.get('status');

					assetIdToBroadsignData.put(player.Id, broadsignBo);
				}
				else {
					BroadsignBo unknownStatus = new BroadsignBo();
					unknownStatus.status = 'Unknown';
					unknownStatus.playerId = player.Name;

					assetIdToBroadsignData.put(player.Id, unknownStatus);
				}
			}
		}
	}

	public void getMdmData() {
		Map<String, Object> mdmResponse = new Map<String, Object>();
		try {
			mdmResponse = MdmDelegate.getMdmStatusesByClinicId(String.valueOf(Integer.valueOf(account.CMHID__c)));
		}
		catch(Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
		assetIdToMdmData = new Map<Id, MdmBo>();
		Map<String, Object> devices = new Map<String, Object>();

		Object devicesObject = mdmResponse.get('devices');
		system.debug('devices: ' + devicesObject);
		if (devicesObject != null) {
			List<Object> devicesObjects = (List<Object>)devicesObject;
			for (Object device : devicesObjects) {
				Map<String, Object> deviceMap = (Map<String, Object>)device;
				for (String value : deviceMap.keySet()) {
					devices.put(value, deviceMap.get(value));
				}
			}
		}
		for (Asset tablet : tablets) {
			Map<String, Object> tabletResponse;
			if (devices.get(tablet.Name) != null) {
				tabletResponse = (Map<String, Object>)devices.get(tablet.Name);
			}
			else if (devices.get(tablet.Name.toUpperCase()) != null) {
				tabletResponse = (Map<String, Object>)devices.get(tablet.Name.toUpperCase());
			}
			else if (devices.get(tablet.Name.toLowerCase()) != null) {
				tabletResponse = (Map<String, Object>)devices.get(tablet.Name.toLowerCase());
			}
			
			if (tabletResponse != null) {
				MdmBo mdmBo = new MdmBo();

				mdmBo.status = (String)tabletResponse.get('device_status');
				mdmBo.lastSeen = (String)tabletResponse.get('last_seen_at') == null || (String)tabletResponse.get('last_seen_at') == '' ? '' : DateTime.valueOf((String)tabletResponse.get('last_seen_at')).format('MM/dd/yyyy hh:mm a');
				mdmBo.speciality = (String)tabletResponse.get('speciality');
				mdmBo.volume = (Integer)tabletResponse.get('default_min_volume_in_percentage');
				tablet.Volume__c = Decimal.valueOf(mdmBo.volume);
				tablet.Speciality__c = mdmBo.speciality;

				assetIdToMdmData.put(tablet.Id, mdmBo);
				initialTablets.put(tablet.Id, tablet.clone());
			}
			else {
				MdmBo unknownStatus = new MdmBo();
				unknownStatus.status = 'Unknown';

				assetIdToMdmData.put(tablet.Id, unknownStatus);
			}
		}
	}

	private Boolean isChanged(Asset initialTablet, Asset tablet) {
		system.debug('initial: ' + initialTablet);
		system.debug('now: ' + tablet);
		if (initialTablet.ClinicExamRoom__c != tablet.ClinicExamRoom__c
		||  initialTablet.InstalledDate__c != tablet.InstalledDate__c
		||  initialTablet.Installation_Status__c != tablet.Installation_Status__c
		||  initialTablet.Speciality__c != tablet.Speciality__c
		||  initialTablet.Volume__c != tablet.Volume__c) {
			return true;
		}
		else {
			return false;
		}
	}

	public void saveTablets() {
		try {
			List<Map<String, String>> deviceFields = new List<Map<String, String>>();
			for (Asset tablet : tablets) {
				if (assetIdToMdmData.get(tablet.Id).status != 'Unknown' && isChanged(tablet, initialTablets.get(tablet.Id))) {
					Map<String, String> fields = new Map<String, String>();
					fields.put('asset_id', tablet.Name);
					fields.put('clinic_id', String.valueOf(account.CMHID__c));
					fields.put('clinic_exam_room', tablet.ClinicExamRoom__c);
					fields.put('installed_date', String.valueOf(tablet.InstalledDate__c));
					fields.put('mount_type', tablet.MountType__c == null ? tablet.MountType__c : tablet.MountType__c.toLowerCase());
					fields.put('speciality', tablet.Speciality__c);
					fields.put('status', tablet.Installation_Status__c);
					fields.put('default_min_volume_in_percentage', String.valueOf(tablet.Volume__c));
					deviceFields.add(fields);
					initialTablets.put(tablet.Id, tablet.clone());
				}
			}
			if (ListUtils.isNotNullOrEmpty(deviceFields)) {
				Map<String, List<Map<String, String>>> devices = new Map<String, List<Map<String,String>>>();
				devices.put('devices', deviceFields);
				MdmDelegate.updateClinicAssetsInMdm(devices, String.valueOf(Integer.valueOf(account.CMHID__c)));
				update tablets;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, new Constants.SuccessMessages().MDM_SUCCESSFUL_CLINIC_SYNC));
			}
		}
		catch(MdmException ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
		catch(Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			EmailUtils.sendTextEmail(new List<String> { 'matt.t@contextmediainc.com' }, 'AccountDetails Exception', ex.getMessage() + ' - ' + ex.getStackTraceString());
		}
	}

	public void loadShipments() {
		shipments = ShipmentService.getWithShipmentItemsAssetsShipmentPackagesByAccountIdOnly(account.Id, new List<String> {'Account__c',
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
		shipment.remove(productId);
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
				system.debug('Estimated Ship: ' + shipment.shipment.EstimatedShipDate__c);
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
				shipment.load(order, null);
			}
		}
	}

	public void cancelShipment() {
		String orderId = ApexPages.currentPage().getParameters().get('orderId');
		system.debug('Order Id: ' + orderId);
		try {
			if (orderId != null && orderId != '') {
				
				HttpRequestResult cancelRequestResult = ShipmentDelegate.cancelOrder(orderId);

				if (cancelRequestResult.success) {
					for (Integer i = 0; i < shipments.size(); i++) {
						if (shipments[i].OrderId__c == orderId) {
							delete shipments[i];
							shipments.remove(i);
							break;
						}
					}
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, cancelRequestResult.userFriendlyResultMessage));
				}else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, cancelRequestResult.userFriendlyResultMessage));
				}
			}
		}
		catch(Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}

	public void clearShipment() {
		shipment.clear(account, null);
	}
}