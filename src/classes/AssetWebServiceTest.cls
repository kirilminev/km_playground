@isTest (seeAllData=true)
private class AssetWebServiceTest {

	private static testMethod void testUpdateReceivedOrder400() {
		RestRequest request = new RestRequest();
		request.addHeader('Authorization-UserId', EnvironmentUtils.getEnvironmentProperty('REST_SHIPMENT_AUTH_USERID'));
		request.addHeader('Authorization-Token', EnvironmentUtils.getEnvironmentProperty('REST_SHIPMENT_AUTH_TOKEN'));
		RestResponse response = new RestResponse();

		RestContext.request = request;
		RestContext.response = response;

		String result = AssetWebService.updateReceivedOrder(null);

		system.assert(RestContext.response.statusCode == 400);
	}

	private static testMethod void testUpdateReceivedOrder401() {
		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();

		RestContext.request = request;
		RestContext.response = response;

		String result = AssetWebService.updateReceivedOrder(new List<String> {'12345'});

		system.assert(RestContext.response.statusCode == 401);
	}
	
	private static testMethod void testUpdateReceivedOrder404() {
		RestRequest request = new RestRequest();
		request.addHeader('Authorization-UserId', EnvironmentUtils.getEnvironmentProperty('REST_SHIPMENT_AUTH_USERID'));
		request.addHeader('Authorization-Token', EnvironmentUtils.getEnvironmentProperty('REST_SHIPMENT_AUTH_TOKEN'));
		RestResponse response = new RestResponse();

		RestContext.request = request;
		RestContext.response = response;

		String result = AssetWebService.updateReceivedOrder(new List<String> {'Invalid Asset Id'});

		system.assert(RestContext.response.statusCode == 404);
	}

	private static testMethod void testUpdateReceivedOrder200() {
		Account account = new Account();
		account.Name = 'Account Name';
		insert account;
		Asset asset = new Asset();
		asset.AccountId = account.Id;
		asset.Name = '12345';
		insert asset;

		RestRequest request = new RestRequest();
		request.addHeader('Authorization-UserId', EnvironmentUtils.getEnvironmentProperty('REST_SHIPMENT_AUTH_USERID'));
		request.addHeader('Authorization-Token', EnvironmentUtils.getEnvironmentProperty('REST_SHIPMENT_AUTH_TOKEN'));
		RestResponse response = new RestResponse();

		RestContext.request = request;
		RestContext.response = response;

		String result = AssetWebService.updateReceivedOrder(new List<String> {'12345'});

		system.assert(RestContext.response.statusCode == 200);
	}
}