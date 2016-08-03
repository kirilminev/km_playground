/*******************************************************************************************************
* @description 	The purpose of the class is to perform mock testing for the Slack Integration
*               http requests including pre-defined response
* 
*/
@isTest
global class SlackServiceMock implements HttpCalloutMock {

	private Integer statusCode {get;set;}
	global SlackServiceMock(Integer statusCode) { this.statusCode = statusCode; }

	global HttpResponse respond(HttpRequest request) {

		System.assertEquals('POST', request.getMethod());
		System.assertNotEquals(null, request.getBody());

		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setBody(request.getBody());
		response.setStatusCode(this.statusCode);

		return response;
	}
}