public class BroadsignDelegate {
	
	public static Map<String, Object> getBroadsignStatus(String assetId) {

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setMethod('GET');

		String endpoint = EnvironmentUtils.getEnvironmentProperty('REST_BROADSIGN_ENDPOINT') + 'playerBSOnlineStatusText/' + assetId;
		system.debug ('Broadsign endpoint: ' + endpoint);
		request.setEndpoint(endpoint);

		HttpResponse response = http.send(request);
		system.debug('response body: ' + response.getBody());
		if (response.getStatusCode() == 200) {
			try {
				return (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
			}
			catch (Exception ex) {
				throw new BroadsignException(new Constants.ExceptionMessages().BROADSIGN_EXCEPTION_NOT_FOUND + ex.getMessage() + ')');
			}
		}
		else {
			throw new BroadsignException(new Constants.ExceptionMessages().BROADSIGN_EXCEPTION_NOT_FOUND + ' (' + response.getStatusCode() + ')');
		}
		return null;
	}

	public static Map<String, Object> getBroadsignStatusesByClinicId(String clinicId) {
	/* http://smtdev.contextmediainc.com/apis/playerBSOnlineStatusbyClinicIdText/{clinicid} */
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setMethod('GET');

		String endpoint = EnvironmentUtils.getEnvironmentProperty('REST_BROADSIGN_ENDPOINT') + 'playerBSOnlineStatusbyClinicIdText/' + clinicId;
		system.debug('Broadsign endpoint: ' + endpoint);
		request.setEndpoint(endpoint);

		HttpResponse response = http.send(request);
		system.debug('response body: ' + response.getBody());
		if (response.getStatusCode() == 200) {
			try {
				return (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
			}
			catch (Exception ex) {
				throw new BroadsignException(new Constants.ExceptionMessages().BROADSIGN_EXCEPTION_NOT_FOUND + ex.getMessage() + ')');
			}
		}
		else {
			throw new BroadsignException(new Constants.ExceptionMessages().BROADSIGN_EXCEPTION_NOT_FOUND + response.getStatusCode() + ')');
		}
		return null;
	}
}