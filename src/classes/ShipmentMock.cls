@isTest
global class ShipmentMock implements HttpCalloutMock {
	private Integer statusCode {get; set;}
	global ShipmentMock(Integer statusCode) { this.statusCode = statusCode; }

	global HttpResponse respond(HttpRequest request) {
		HttpResponse response = new HttpResponse();
		if (request.getEndpoint().contains('Orders')) {
			response.setStatusCode(statusCode);
			response.setStatus('Created');
		}
		else if (request.getEndpoint().contains('OrderUpdate')) {
			response.setStatusCode(statusCode);
			response.setStatus('Updated');
		}
		else if (request.getEndpoint().contains('OrderCancellations')) {
			response.setStatusCode(statusCode);
			response.setStatus('Canceled');
			response.setBody('[{"OrderId":"12345","Status":"Cancelled"}]');
		}
		else {
			system.assert(false);
		}
		return response;
	}
}