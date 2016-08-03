public class MdmDelegate {

	public static Map<String, Object> getMdmStatus(Asset asset) {

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setMethod('GET');

		String endpoint = EnvironmentUtils.getEnvironmentProperty('REST_MDM_ENDPOINT') + asset.Type__c.toLowerCase() + '/status/' + asset.Name;
		request.setEndpoint(endpoint);

		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Authorization', 'Token token=a82ffee717845ac42d291e6968cb2d');

		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 200) {
			return (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
		}
		else if (response.getStatusCode() == 404) {
			throw new MdmException(new Constants.ExceptionMessages().MDM_EXCEPTION_NOT_FOUND);
		}
		return null;
	}

	public static Map<String, Object> getMdmStatusesByClinicId(String clinicId) {

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setMethod('GET');

		String endpoint = EnvironmentUtils.getEnvironmentProperty('REST_MDM_ENDPOINT') + 'clinic_assets/' + clinicId;
		request.setEndpoint(endpoint);

		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Authorization', 'Token token=a82ffee717845ac42d291e6968cb2d');

		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 200) {
			return (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
		}
		else {
			throw new MdmException(new Constants.ExceptionMessages().MDM_EXCEPTION_NOT_FOUND + ' (' + response.getStatusCode() + ')');
		}
		return null;
	}

	@future(callout=true)
	public static void syncClinic(String body, String cmhId) {

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setMethod('POST');

		String endpoint = EnvironmentUtils.getEnvironmentProperty('REST_MDM_ENDPOINT') + cmhId + '/sync_clinic.json';
		request.setEndpoint(endpoint);

		system.debug(body);
		request.setBody(body);

		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Authorization', 'Token token=a82ffee717845ac42d291e6968cb2d');

		HttpResponse response = http.send(request);

		if (response.getStatusCode() != 200) {
			List<String> exceptionRecipients = EnvironmentUtils.getEnvironmentProperty('MDM_EXCEPTION_RECIPIENTS') == null
											 ? new List<String> {'matt.thomas@contextmediainc.com'}
											 : EnvironmentUtils.getEnvironmentProperty('MDM_EXCEPTION_RECIPIENTS').split(',');
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setToAddresses(exceptionRecipients);
			email.setSubject('Failed - Clinic Sync');
			email.setHtmlBody('Status: ' + response.getStatusCode()
							+ '<br/><br/>'
							+ 'POST <br/>'
							+ 'Endpoint: ' + endpoint + '<br/>'
							+ 'JSON Body: ' + body);

			Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email});
		}
	}
	
	public static void updateAssetInMdm(Map<String, String> fields, String type) {

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setMethod('POST');

		String endpoint = EnvironmentUtils.getEnvironmentProperty('REST_MDM_ENDPOINT') + type + '/sync/' + fields.get('asset_id');
		request.setEndpoint(endpoint);

		Map<String, Map<String, String>> device = new Map<String, Map<String, String>>();
		device.put('device', fields);

		String body = JSON.serialize(device);
		system.debug('Body: ' + body);
		request.setBody(body);

		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Authorization', 'Token token=a82ffee717845ac42d291e6968cb2d');

		HttpResponse response = http.send(request);

		if (response.getStatusCode() != 200) {
			List<String> exceptionRecipients = EnvironmentUtils.getEnvironmentProperty('MDM_EXCEPTION_RECIPIENTS') == null
								 ? new List<String> {'matt.thomas@contextmediainc.com'}
								 : EnvironmentUtils.getEnvironmentProperty('MDM_EXCEPTION_RECIPIENTS').split(',');
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setToAddresses(exceptionRecipients);
			email.setSubject('Failed - Asset Status Update');
			email.setHtmlBody('Status: ' + response.getStatusCode()
							+ '<br/><br/>'
							+ 'POST <br/>'
							+ 'Endpoint: ' + endpoint + '<br/>'
							+ 'JSON Body: ' + body);

			Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email});
		}
	}

	public static void updateClinicAssetsInMdm(Map<String, List<Map<String, String>>> devices, String clinicId) {

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setMethod('POST');

		String endpoint = EnvironmentUtils.getEnvironmentProperty('REST_MDM_ENDPOINT') + 'sync_clinic_assets/' + clinicId;
		request.setEndpoint(endpoint);

		String body = JSON.serialize(devices);
		system.debug('Body: ' + body);
		request.setBody(body);

		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Authorization', 'Token token=a82ffee717845ac42d291e6968cb2d');

		HttpResponse response = http.send(request);

		if (response.getStatusCode() != 200) {
			List<String> exceptionRecipients = EnvironmentUtils.getEnvironmentProperty('MDM_EXCEPTION_RECIPIENTS') == null
								 ? new List<String> {'matt.thomas@contextmediainc.com'}
								 : EnvironmentUtils.getEnvironmentProperty('MDM_EXCEPTION_RECIPIENTS').split(',');
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setToAddresses(exceptionRecipients);
			email.setSubject('Failed - Sync Clinic Assets');
			email.setHtmlBody('Status: ' + response.getStatusCode()
							+ '<br/><br/>'
							+ 'POST <br/>'
							+ 'Endpoint: ' + endpoint + '<br/>'
							+ 'JSON Body: ' + body);

			Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email});
			throw new MdmException(new Constants.ExceptionMessages().MDM_EXCEPTION_NOT_FOUND + ' (' + response.getStatusCode() + ': ' + response.getStatus() + ')');
		}
	}
}