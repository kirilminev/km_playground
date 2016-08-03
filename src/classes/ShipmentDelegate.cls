/*******************************************************************************************************
* @description 	Inbound Web Service Integration with our OMS (Order Management System) partner "iD"
* 
*/
public with sharing class ShipmentDelegate {

	/* iD Web Service Cancel Order Valid Status Codes */
	public final static String NOT_FOUND = 'NotFound';
	public final static String ALREADY_PROCESSED = 'AlreadyProcessed';
	public final static String ALREADY_CANCELED = 'AlreadyCancelled';
	public final static String CANCELLED = 'Cancelled';

	public static ShipmentPackage__c getShipmentTrackingInfo(String sCarrier, String sTrackingNumber) {
		string sEndPoint = '';
		if (sCarrier == 'UPS'){
			 sEndPoint = EnvironmentUtils.getEnvironmentProperty('REST_UPS_ENDPOINT') + 'Track';
		}

		HttpRequest request = new HttpRequest();
		string sRequest = ShipmentEncoder.BuildTrackingRequest(sCarrier, sTrackingNumber); 

		request.setBody (sRequest);
		request.setEndpoint(sEndPoint); 
		request.setMethod('POST');

		Http http = new Http();
		HttpResponse response = new HttpResponse();
		response = http.send(request);

		ShipmentPackage__C shipmentPackage = new ShipmentPackage__C();

		if (response.getStatusCode() == 201 || response.getStatusCode() == 200) {

			String sStatusCode = ShipmentParser.ParseTrackingRequest(response, 'StatusCode');
		
			if ( sStatusCode == 'M' ){
				shipmentPackage.Status__c = ShipmentParser.ParseTrackingRequest(response, 'Status' );
				shipmentPackage.ActivityDate__c = Datetime.valueOf(ShipmentParser.ParseTrackingRequest(response, 'Date' ));
				}

			if ( sStatusCode == 'D' ){
				shipmentPackage.Status__c = ShipmentParser.ParseTrackingRequest(response, 'Status' );
				shipmentPackage.SignedForName__c = ShipmentParser.ParseTrackingRequest(response, 'SignedBy' );
				shipmentPackage.LeftAtLocation__c = ShipmentParser.ParseTrackingRequest(response, 'Location' );
				shipmentPackage.ActivityDate__c = Datetime.valueOf(ShipmentParser.ParseTrackingRequest(response, 'Date' ));
				
				}

			if (sStatusCode == 'I'){
				  shipmentPackage.Status__C = 'IN TRANSIT - ' +  ShipmentParser.ParseTrackingRequest(response, 'Message'); 
				  shipmentPackage.ActivityDate__c = Datetime.valueOf(ShipmentParser.ParseTrackingRequest(response, 'Date' ));
				  string sDelDate = ShipmentParser.ParseTrackingRequest(response,  'DelDate');
				  If (sDelDate!='') {
				  		shipmentPackage.ScheduledDeliveryDate__c = Date.valueOf(sDelDate);
				  }
			}

			if (sStatusCode == 'X'){
				  shipmentPackage.Status__C = 'EXEPTION'; 
			}

		}
		else {

			throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_UNKNOWN_ERROR + response.getStatusCode() + ': ' + response.getBody() + ')');
		}
		return shipmentPackage;
	}
	
	public static void putOrder(Shipment shipment, Account account, Contact shipmentContact) {
		String body = serializeShipment(shipment, account, shipmentContact);
		system.debug('Request Body: ' + body);

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setMethod('PUT');

		String endpoint = EnvironmentUtils.getEnvironmentProperty('REST_ID_ENDPOINT') + 'Orders/' + shipment.shipment.OrderId__c;
		request.setEndpoint(endpoint);
		system.debug('Endpoint: ' + endpoint);
		request.setBody(body);

		request.setTimeout(20000);
		
		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Accept', 'application/json');
		request.setHeader('X-IdComLog-ClientId', EnvironmentUtils.getEnvironmentProperty('REST_ID_CLIENTID'));
		request.setHeader('X-IdComLog-UserId', EnvironmentUtils.getEnvironmentProperty('REST_ID_USERID'));

		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 201) {
			//The order was created successfully.
		}
		else if (response.getStatusCode() == 400) {
			//The order object fails validation. A ValidationResult object describing errors in the order object will be returned.
			throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_BAD_REQUEST + ' (' + response.getBody() + ')');
		}
		else if (response.getStatusCode() == 401) {
			throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_UNAUTHORIZED);
		}
		else if (response.getStatusCode() == 409) {
			//An order with this ID already exists in the system. Orders can not be updated once initially PUT.
			throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_CONFLICT);
		}
		else if (response.getStatusCode() == 500) {
			throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_INTERNAL_SERVER_ERROR);
		}
		else {
			throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_UNKNOWN_ERROR + response.getStatusCode() + ': ' + response.getBody() + ')');
		}
	}

	public static void updateOrder(Shipment shipment, Account account, Contact shipmentContact) {
		String body = serializeShipment(shipment, account, shipmentContact);
		system.debug('Request Body: ' + body);

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setMethod('PUT');

		String endpoint = EnvironmentUtils.getEnvironmentProperty('REST_ID_ENDPOINT') + 'OrderUpdate/' + shipment.shipment.OrderId__c;
		request.setEndpoint(endpoint);
		system.debug('Endpoint: ' + endpoint);
		request.setBody(body);

		request.setTimeout(20000);

		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Accept', 'application/json');
		request.setHeader('X-IdComLog-ClientId', EnvironmentUtils.getEnvironmentProperty('REST_ID_CLIENTID'));
		request.setHeader('X-IdComLog-UserId', EnvironmentUtils.getEnvironmentProperty('REST_ID_USERID'));

		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 202) {
			//The order was updated successfully.
		}
		else if (response.getStatusCode() == 400) {
			//The order object fails validation. A ValidationResult object describing errors in the order object will be returned.
			system.debug('response body: ' + response.getBody());
			throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_BAD_REQUEST);
		}
		else if (response.getStatusCode() == 401) {
			throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_UNAUTHORIZED);
		}
		else if (response.getStatusCode() == 409) {
			//This order is already in production and no further modifications can be made.
			system.debug('response body: ' + response.getBody());
			throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_UPDATE_CONFLICT);
		}
		else if (response.getStatusCode() == 500) {
			throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_INTERNAL_SERVER_ERROR);
		}
		else {
			throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_UNKNOWN_ERROR + response.getStatusCode() + ': ' + response.getBody() + ')');
		}
	}

	/*******************************************************************************************************
	* @description 		Method accepts order id and check if order has been canceled on iD system and if so
	*                	it delete the order from Salesforce as well
	* @param[String] 	orderId (Salesforce generate 10 digit string/number)		
	* @return[HttpRequestResult] 	Return the status of the request along with a message of what happened
	* 
	*/
	public static HttpRequestResult cancelOrder(String orderId) {

		try {
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setMethod('POST');

			String endpoint = EnvironmentUtils.getEnvironmentProperty('REST_ID_ENDPOINT') + 'OrderCancellations';
			request.setEndpoint(endpoint);
			request.setBody(serializeOrderIds(orderId));
			request.setTimeout(20000);

			request.setHeader('Content-Type', 'application/json');
			request.setHeader('Accept', 'application/json');
			request.setHeader('X-IdComLog-ClientId', EnvironmentUtils.getEnvironmentProperty('REST_ID_CLIENTID'));
			request.setHeader('X-IdComLog-UserId', EnvironmentUtils.getEnvironmentProperty('REST_ID_USERID'));

			HttpResponse response = http.send(request);
			if (response.getStatusCode() == 200) {
				//The order was canceled successfully.
				List<Object> resultList = (List<Object>)JSON.deserializeUntyped(response.getBody());
				Map<String, Object> resultMap;
				if (ListUtils.isNotNullOrEmpty(resultList)) {
					resultMap = (Map<String, Object>)resultList[0];
				}
				String result = resultMap == null || (String)resultMap.get('Status') == null ? '' : (String)resultMap.get('Status');
				if (result == CANCELLED) {
					return new HttpRequestResult(true, 'This order was successfully canceled!', 'This order was successfully canceled!');
				}
				else if (result == ALREADY_CANCELED) {
					return new HttpRequestResult(true, 'This order has already been canceled!', 'This order has already been canceled!');
				}
				else if (result == NOT_FOUND) {
					throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_ORDER_NOT_FOUND);
				}
				else if (result == ALREADY_PROCESSED) {
					throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_ALREADY_PROCESSED);
				
				/* 	This condition is a temporary step in the process to allow for salesforce to mark orders as canceled
				 *  Exception will be still captured as well as a message to Slack channel so Salesforce team monitors 
				 *  the unexpected Status blank
				 *  Also an email will go out to the Operations tea (David Epstein and Eric West) to bring the order to their
				 *  attention and follow upon it.
				 *  Once we figure out what that status (blank "") means with ot iD / Integration partner this will be removed 
				 *  and handled properly
			     *
				*/
				} else if (result == '') { 
					//temporary logic
					handleCancelOrderManualProcess(orderId);
					return new HttpRequestResult(true, 'This order was successfully canceled!', 'This order was successfully canceled!');
				} else{//Unexpected status code received from iD/OMS Web Service
					throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_UNKNOWN_STATUS_CODE + resultMap);
				}
			}
			else if (response.getStatusCode() == 401) {
				throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_UNAUTHORIZED);
			}
			else if (response.getStatusCode() == 404) {
				//The order could not be found.
				throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_ORDER_NOT_FOUND);
			}
			else if (response.getStatusCode() == 409) {
				//The order was found but could not be canceled because it has already been processed.
				throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_ALREADY_PROCESSED);
			}
			else if (response.getStatusCode() == 500) {
				throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_INTERNAL_SERVER_ERROR);
			}
			else {
				throw new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_UNKNOWN_ERROR + response.getStatusCode() + ': ' + response.getBody() + ')');
			}
		} catch (ShipmentException shipmentException) {
			LoggingUtils.log(new LoggingUtils.LogInfo(shipmentException), true, true, true);
			return new HttpRequestResult(false, shipmentException.getMessage(), 'An error occurred while canceling this Shipment. Please try again or contact salesforce@contextmediainc.com for assistance.');
		} catch (Exception genericException) {
			LoggingUtils.log(new LoggingUtils.LogInfo(genericException), true, true, true);
			return new HttpRequestResult(false, genericException.getMessage(), 'An error occurred while canceling this Shipment. Please try again or contact salesforce@contextmediainc.com for assistance.');
		}
	}

	/* 	This condition is a temporary step in the process to allow for salesforce to mark orders as canceled
	 *  Exception will be still captured as well as a message to Slack channel so Salesforce team monitors 
	 *  the unexpected Status blank
	 *  Also an email will go out to the Operations tea (David Epstein and Eric West) to bring the order to their
	 *  attention and follow upon it.
	 *  Once we figure out what that status (blank "") means with ot iD / Integration partner this will be removed 
	 *  and handled properly
     *
	*/
	private static void handleCancelOrderManualProcess(String orderId) {
		
		LoggingUtils.log(new LoggingUtils.LogInfo(new ShipmentException(new Constants.ExceptionMessages().SHIPMENT_EXCEPTION_UNKNOWN_STATUS_CODE + 
																				' OrderId: ' + orderId + 
																				' canceled, but Status code return was blank!'))
																				, true, true, true);
						
		Shipment__c shipment = null;

		try {
			shipment = ShipmentService.getWithShipmentItemsByOrderId(orderId, 
																	 new List<String>{'Id',
												                            		  'Account__c',
																					  'Account__r.Name',
												                                	  'ShippingStreet__c',
												                                      'ShippingStreet2__c',
												                            	      'ShippingCity__c',
												                            		  'ShippingPostalCode__c',
												                            		  'ShippingState__c',
												                            	      'ShippedDate__c',
												                                      'EstimatedShipDate__c',
												                            	      'ShippedDate__c',
												                            		  'CmhId__c',
												                            		  'RequestedDateOfArrival__c'},
                	 
																	 new List<String>{'Id'});
		}catch (Exception ex) {
			LoggingUtils.log(new LoggingUtils.LogInfo(ex), true, true, true);
		}

		String emailBody = 'OrderId: ' + orderId + '\n';
		
		if (shipment != null) {
			emailBody +=  'AccountId: ' + shipment.Account__c + '\n' +
						  'Account Name: ' + shipment.Account__r.Name + '\n' +
						  'Shipping Address: ' + shipment.ShippingStreet__c + ', ' + 
						  						 shipment.ShippingCity__c + ', ' + 
						  						 shipment.ShippingState__c + ', ' +
						  						 shipment.ShippingPostalCode__c + '\n' +
  						  'User Id: ' + UserInfo.getUserId() + '\n' +
  						  'User Name: ' + UserInfo.getName() + '\n' +
  						  'Estimated Ship Date: ' + shipment.EstimatedShipDate__c + '\n' +
  						  'Requested Date of Arrival: ' + shipment.RequestedDateOfArrival__c + '\n' +
  						  'Shipped Date: ' + shipment.ShippedDate__c + '\n'; 
		}

		EmailUtils.sendTextEmail(new List<String>{'canceledorders@contextmediainc.com', 'kiril.minev@contextmediainc.com'}, 
								'This shipment failed to be canceled via API. Please cancel this order and Reply All to this email with confirmation.',
								emailBody);
	}

	@TestVisible 
	private static String serializeOrderIds(String orderId) {
		Map<String, List<String>> result = new Map<String, List<String>>();
		result.put('OrderIds', new List<String> {orderId});
		return JSON.serialize(result);
	}

	@TestVisible 
	private static String serializeShipment(Shipment shipment, Account account, Contact shipmentContact) {
		Map<String, Object> result = new Map<String, Object>();

		result.put('ShipToAddress', getAddress(account, shipment, shipmentContact));
		result.put('Items', getItems(shipment.shipmentItems.values()));
		result.put('Variables', getVariables(account, shipment));

		if (shipment.shipment.CmhId__c != null) {
			result.put('ReferenceID', String.valueOf(shipment.shipment.CmhId__c));
		}

		/** Variables currently unused and optional:
			-DateOrdered
			-CarrierId
			-Stream
			-BillToAddress
			-OrderedByAddress
			-OrderVariables
		**/
		return JSON.serialize(result);
	}

	@TestVisible
	private static Map<String, String> getAddress(Account account, Shipment shipment, Contact contact) {
		Map<String, String> result = new Map<String, String>();

		result.put('Name', contact.FirstName + ' ' + contact.LastName);
		result.put('Company', shipment.shipment.Company__c);
		result.put('Address1', shipment.shipment.ShippingStreet__c);
		result.put('Address2', shipment.shipment.ShippingStreet2__c);
		result.put('City', shipment.shipment.ShippingCity__c);
		result.put('StateOrProvince', shipment.shipment.ShippingState__c);
		result.put('PostalCode', shipment.shipment.ShippingPostalCode__c);
		result.put('PhoneNumber', contact.Phone);
		result.put('Email', contact.Email == null ? UserInfo.getUserEmail() : contact.Email);

		return result;
	}

	@TestVisible
	private static List<Object> getItems(List<Shipment.LineItem> shipmentItems) {
		List<Object> result = new List<Object>();

		for (Shipment.LineItem orderItem : shipmentItems) {
			Map<String, String> orderItemFields = new Map<String, String>();
			orderItemFields.put('OfferId', orderItem.productCode);
			orderItemFields.put('Quantity', String.valueOf(orderItem.quantity));
			result.add(orderItemFields);
		}

		return result;
	}

	@TestVisible
	private static List<Object> getVariables(Account account, Shipment shipment) {
		List<Object> result = new List<Object>();

		Map<String, String> variable = new Map<String, String>();
		variable.put('Name', 'ArrivalDate');
		variable.put('Value', String.valueOf(shipment.shipment.RequestedDateOfArrival__c));
		result.add(variable);

		if (shipment.shipment.RequestedPickupDate__c != null) {
			variable = new Map<String, String>();
			variable.put('Name', 'PickupDate');
			variable.put('Value', String.valueOf(shipment.shipment.RequestedPickupDate__c));
			result.add(variable);
		}

		variable = new Map<String, String>();
		variable.put('Name', 'Network');
		variable.put('Value', account.Network__c);
		result.add(variable);

		variable = new Map<String, String>();
		variable.put('Name', 'Timezone');
		variable.put('Value', account.Time_Zone__c);
		result.add(variable);

		variable = new Map<String, String>();
		variable.put('Name', 'CmhId');
		variable.put('Value', String.valueOf(account.CMHID__c));
		result.add(variable);

		variable = new Map<String, String>();
		variable.put('Name', 'AmDelivery');
		variable.put('Value', String.valueOf(shipment.shipment.AMDelivery__c));
		result.add(variable);

		return result;
	}
}