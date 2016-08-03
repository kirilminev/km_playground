@RestResource(urlMapping='/assets/*')
global class AssetWebService {
	
	@HttpPut
	global static String updateReceivedOrder(List<String> assetIds) {
		RestRequest request = RestContext.request;
		RestResponse response = RestContext.response;
		if (request.headers.get('Authorization-UserId') != EnvironmentUtils.getEnvironmentProperty('REST_SHIPMENT_AUTH_USERID') || request.headers.get('Authorization-Token') != EnvironmentUtils.getEnvironmentProperty('REST_SHIPMENT_AUTH_TOKEN')) {
			response.statusCode = 401;
			return null;
		}
		if (ListUtils.isNullOrEmpty(assetIds)) {
			response.statusCode = 400;
			return null;
		}
		List<Asset> assets;
		try {
			assets = AssetService.getByNames(assetIds, new List<String> {'Name',
																		 'Status'});
			if (ListUtils.isNullOrEmpty(assets)) {
				response.statusCode = 404;
				return UPDATE_RECEIVED_ORDER_NOT_FOUND;
			}
		}
		catch (QueryException ex) {
			response.statusCode = 404;
			return UPDATE_RECEIVED_ORDER_NOT_FOUND + ' ' + ex.getMessage();
		}
		for (Asset asset : assets) {
			asset.Status = 'Returned';
		}
		try {
			update assets;
			response.statusCode = 200;
			return UPDATE_RECEIVED_ORDER_SUCCESS;
		}
		catch(DmlException ex) {
			response.statusCode = 409;
			return UPDATE_RECEIVED_ORDER_DML_EXCEPTION + ' ' + ex.getMessage();
		}
	}

	private static final String UPDATE_RECEIVED_ORDER_NOT_FOUND = 'These assets were not found.';
	private static final String UPDATE_RECEIVED_ORDER_DML_EXCEPTION = 'There was an unknown issue updating these assets.';
	private static final String UPDATE_RECEIVED_ORDER_SUCCESS = 'These assets have been successfully updated.';
}