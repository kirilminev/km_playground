@RestResource(urlMapping='/shipments/*')
global class ShipmentWebService {

	@HttpGet
	global static OrderItem getAssetInformation() {
		RestRequest request = RestContext.request;
		RestResponse response = RestContext.response;
		if (request.headers.get('Authorization-UserId') != EnvironmentUtils.getEnvironmentProperty('REST_SHIPMENT_AUTH_USERID') || request.headers.get('Authorization-Token') != EnvironmentUtils.getEnvironmentProperty('REST_SHIPMENT_AUTH_TOKEN')) {
			response.statusCode = 401;
			return null;
		}

		String assetId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
		try {
			Asset asset = AssetService.getByName(assetId, new List<String> {'Cost_of_Equipment__c',
																			'Invoice_Number__c',
																			'LAN_MAC_Address__c',
																			'Make__c',
																			'Model__c',
																			'Name',
																			'Product2.ProductCode',
																			'PurchaseDate',
																			'SerialNumber',
																			'Type__c',
																			'Vendor__c'});
			OrderItem orderItem = new OrderItem();
			orderItem.assetId = asset.Name;
			orderItem.cost = String.valueOf(asset.Cost_of_Equipment__c);
			orderItem.invoiceNumber = asset.Invoice_Number__c;
			orderItem.macAddress = asset.LAN_MAC_Address__c;
			orderItem.make = asset.Make__c;
			orderItem.model = asset.Model__c;
			orderItem.productCode = asset.Product2.ProductCode;
			orderItem.purchaseDate = String.valueOf(asset.PurchaseDate);
			orderItem.type = asset.Type__c;
			orderItem.vendor = asset.Vendor__c;
			return orderItem;
		}
		catch(QueryException ex) {
			response.statusCode = 404;
			return null;
		}
	}
	
	@HttpPut
	global static String updateShippedOrder(Order order, String shippedDate) {
		RestRequest request = RestContext.request;
		RestResponse response = RestContext.response;
		if (request.headers.get('Authorization-UserId') != EnvironmentUtils.getEnvironmentProperty('REST_SHIPMENT_AUTH_USERID') || request.headers.get('Authorization-Token') != EnvironmentUtils.getEnvironmentProperty('REST_SHIPMENT_AUTH_TOKEN')) {
			sendFailureNotification(request, order, 401, UNAUTHORIZED_REQUEST, 'updateShippedOrder');
			response.statusCode = 401;
			return UNAUTHORIZED_REQUEST;
		}
		Account account;
		Shipment__c shipment;
		
		List<ShipmentItem__c> shipmentItemsToUpdate = new List<ShipmentItem__c>();
		try {
			shipment = ShipmentService.getWithShipmentItemsByOrderId(order.orderId, new List<String> {'Account__c',
																									  'AccountName__c',
																									  'CmhId__c',
																									  'Contact__c',
																									  'CreatedDate',
																									  'Id',
																									  'OrderId__c',
																									  'RelatedWorkOrder__c',
																									  'RequestedDateOfArrival__c',
																									  'Shipped__c',
																									  'ShippedDate__c',
																									  'ShippingCity__c',
																									  'ShippingPostalCode__c',
																									  'ShippingState__c',
																									  'ShippingStreet__c',
																									  'TrackingNumber__c'},
																					new List<String> {'Name',
																									  'Product__c',
																									  'Product__r.Name',
																									  'Product__r.ProductCode',
																									  'Quantity__c',
																									  'Type__c'});
			account = AccountService.getById(shipment.Account__c, new List<String> {'BillingCity',
																					'BillingState',
																					'CMHID__c',
																					'IPAddress__c',
																					'Name',
																					'Network__c',
																					'NumberOfExamRooms__c',
																					'NumberOfScreensInstalled__c',
																					'NumberOfTabletsInstalled__c',
																					'of_Waiting_Rooms__c',
																					'OpenCaptioning__c',
																					'Time_Zone__c'});
		}
		catch(QueryException ex) {
			sendFailureNotification(request, order, 404, ex.getMessage(), 'updateShippedOrder');
			response.statusCode = 404;
			return UPDATE_SHIPPED_ORDER_NOT_FOUND + ' ' + ex.getMessage();
		}

		try {
			Map<String, Product2> products = new Map<String, Product2>();
			List<Product2> activeProducts = ShipmentService.getActiveProducts(new List<String> {'Assetized__c',
																								'Family',
																								'Hidden__c',
																								'Id',
																								'Name',
																								'ProductCode'});
			for (Product2 product : activeProducts) {
				products.put(product.ProductCode, product);
			}

			Map<String, Set<String>> trackingNumberToProductCode = new Map<String, Set<String>>();
			for (String productCode : order.trackingNumbers.keySet()) {
			    for (String trackingNumber : order.trackingNumbers.get(productCode).split(',')) {
			        if (trackingNumberToProductCode.get(trackingNumber) == null) {
			            trackingNumberToProductCode.put(trackingNumber, new Set<String> {productCode});
			        }
			        else {
			            set <string> setProdCode = trackingNumberToProductCode.get(trackingNumber);
			            setProdCode.add (productCode);
			            trackingNumberToProductCode.put(trackingNumber, setProdCode);
			        }
			    }
			}



			List<ShipmentPackage__c> shipmentPackagesToInsert = new List<ShipmentPackage__c>();
			ShipmentPackage__c shipmentPackage = new ShipmentPackage__c();

			for (String trackingNumber : trackingNumberToProductCode.keyset()){
				shipmentPackage = new ShipmentPackage__c();
				shipmentPackage.Shipment__c = shipment.Id;
				shipmentPackage.TrackingNumber__c = trackingNumber;
				shipmentPackage.ProductCode__c = String.join(new List<String>(trackingNumberToProductCode.get(trackingNumber)), ',');

				shipmentPackagesToInsert.add(shipmentPackage);
			}

			insert shipmentPackagesToInsert;

			Map<String, Integer> assetizedProductCodeToQuantity = new Map<String, Integer>();
			for (ShipmentItem__c item : shipment.Shipment_Items__r) {

				if (products.get(item.Product__r.ProductCode) != null && products.get(item.Product__r.ProductCode).Assetized__c) {
					assetizedProductCodeToQuantity.put(item.Product__r.ProductCode, Integer.valueOf(item.Quantity__c));
				}
			}

			if (!shipment.Shipped__c) {
				List<Map<String, String>> assetsToSync = new List<Map<String, String>>();
				List<Asset> assetsToInsert = new List<Asset>();
				for (ShipmentWebService.OrderItem asset : order.assets) {
					/** Wifi are special cases, since iD sends the value needed for mac_address
						in the serialNumber prop sans colons, so special treatment is needed.
						In additions, the "AccessPoint" type is expected. **/
					if (asset.type == 'Wifi Hotspot') {
						String mac_address = asset.serialNumber != null
											 ? String.join(asset.serialNumber.split('(?<=\\G..)'), ':')
											 : '';
						assetsToSync.add(new Map<String, String> {'id' => asset.assetId,
																  'mac_address' => mac_address,
																  'type' => 'AccessPoint'});
					}
					else {
						assetsToSync.add(new Map<String, String> {'id' => asset.assetId,
																  'mac_address' => asset.macAddress,
																  'type' => asset.type});
					}
					
					if (asset.assetId == null) {
						sendFailureNotification(request, order, 400, UPDATE_SHIPPED_ORDER_ERROR_MISSING_ID, 'updateShippedOrder');
						response.statusCode = 400;
						return UPDATE_SHIPPED_ORDER_ERROR_MISSING_ID;
					}
					if (assetizedProductCodeToQuantity.get(asset.productCode) != null) {
						Integer quantity = assetizedProductCodeToQuantity.get(asset.productCode);
						assetizedProductCodeToQuantity.put(asset.productCode, quantity - 1);
					}

					Asset newAsset = new Asset();
					newAsset.AccountId = shipment.Account__c;
					newAsset.Name = asset.assetId;
					newAsset.Cost_of_Equipment__c = Decimal.valueOf(asset.cost);
					newAsset.Invoice_Number__c = asset.invoiceNumber;
					newAsset.LAN_MAC_Address__c = asset.macAddress;
					newAsset.Make__c = asset.make;
					newAsset.Model__c = asset.model;
					newAsset.Product2Id = products.get(asset.productCode) == null ? null : products.get(asset.productCode).Id;
					newAsset.PurchaseDate = Date.valueOf(asset.purchaseDate);
					newAsset.RelatedWorkOrder__c = shipment.RelatedWorkOrder__c;
					newAsset.SerialNumber = asset.serialNumber;
					newAsset.Status = 'Shipped';
					newAsset.Type__c = asset.type;
					newAsset.Vendor__c = asset.vendor;

					assetsToInsert.add(newAsset);
				}
				insert assetsToInsert;

				for (Integer assetizedQuantity : assetizedProductCodeToQuantity.values()) {
					if (assetizedQuantity > 0) {
						ShipmentService.sendShippedOrderAlert(shipment, order.assets, assetizedProductCodeToQuantity);
					}
				}
			

				shipment.Shipped__c = true;
				shipment.ShippedDate__c = Date.valueOf(shippedDate);
				update shipment;

				MdmDelegate.syncClinic(JSON.serialize(AccountService.getSyncClinicBody(account, assetsToSync)), String.valueOf(account.CMHID__c));
			}

			response.statusCode = 200;
			return UPDATE_SHIPPED_ORDER_SUCCESS;
		}
		catch (Exception ex) {
			sendFailureNotification(request, order, 500, ex.getMessage(), 'updateShippedOrder');
			response.statusCode = 500;
			return ex.getMessage();
		}
	}

	global class Order {
		String orderId;
		Map<String, String> trackingNumbers;
		List<OrderItem> assets;
	}
	
	global class OrderItem {
		String assetId;
		String cost;
		String invoiceNumber;
		String macAddress;
		String make;
		String model;
		String productCode;
		String purchaseDate;
		String serialNumber;
		String type;
		String vendor;

	}

	private static void sendFailureNotification(RestRequest request, Order order, Integer statusCode, String reason, String context) {
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setToAddresses(EnvironmentUtils.getEnvironmentProperty('SHIPMENT_NOTIFICATION_RECIPIENTS').split(','));
		email.setSubject('ShipmentWebService Failed: ' + context);
		email.setHtmlBody(
				'An HttpRequest was made to ' + context + ' but failed (' + String.valueOf(statusCode) + ': ' + reason + '). <br/><br/>'
			+ 	'<strong>Headers:</strong> ' + JSON.serialize(request.headers) + '<br/>'
			+ 	'<strong>Method:</strong> ' + request.httpMethod + '<br/>'
			+ 	'<strong>Params:</strong> ' + JSON.serialize(request.params) + '<br/>'
			+ 	'<strong>IP Address:</strong> ' + request.remoteAddress + '<br/>'
			+ 	'<strong>Body:</strong> ' + JSON.serialize(order) + '<br/>'
			+ 	'<strong>Request URI:</strong> ' + request.requestURI + '<br/>'
			+ 	'<strong>Resource Path:</strong> ' + request.resourcePath
		);
		Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { email });
	}

	private static final String GET_ASSET_INFORMATION_NOT_FOUND = 'This asset was not found.';
	private static final String UNAUTHORIZED_REQUEST = 'You are not authorized to access this endpoint.';
	private static final String UPDATE_SHIPPED_ORDER_ERROR_MISSING_ID = 'assetId is required.';
	private static final String UPDATE_SHIPPED_ORDER_ERROR_TRACKING = 'At least one tracking number is required.';
	private static final String UPDATE_SHIPPED_ORDER_ERROR_SHIPPED = 'This order has already been shipped.';
	private static final String UPDATE_SHIPPED_ORDER_NOT_FOUND = 'The order was not found.';
	private static final String UPDATE_SHIPPED_ORDER_SUCCESS = 'This order has been successfully updated.';
}