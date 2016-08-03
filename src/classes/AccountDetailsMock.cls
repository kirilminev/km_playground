@isTest
global class AccountDetailsMock implements HttpCalloutMock {
	private Integer statusCode {get;set;}
	global AccountDetailsMock(Integer statusCode) {	this.statusCode = statusCode; }

	global HttpResponse respond(HttpRequest request) {
		HttpResponse response = new HttpResponse();
		if (request.getEndpoint().contains(EnvironmentUtils.getEnvironmentProperty('REST_MDM_ENDPOINT'))) {
			response.setHeader('Content-Type', 'application/json');
			response.setBody('{"devices":[{"Tablet":{"last_seen_at":"2015-05-05 15:59:20 -0500","device_status":"down","default_min_volume_in_percentage":1,"speciality":"Neurology"}}]}');
			response.setStatusCode(statusCode);
		}
		else if (request.getEndpoint().contains(EnvironmentUtils.getEnvironmentProperty('REST_BROADSIGN_ENDPOINT'))) {
			response.setHeader('Content-Type', 'application/json');
			response.setBody('{"Player":{"id":"29935837","name":"6580-2_12465 - Main WR","display_unit_id":"24922325","status":"1","lastpoll":"2015-08-18 12:52:24","nextpoll":"2015-08-18 13:10:51","LocalTime":"2015-08-18T13:52:22 (-04:00)","ClockSkew":"0 seconds","PlayerVersion":"10.2.0-171","AVVersion":"10.2.0","Issue":"Ubuntu 12.04.3 LTS","ScreenResolution":"1360x768","CurrentlyPlaying":"5","CurrentlyDownloading":"Nothing","NextAdToDownload":null,"CurrentLocation":"45.79.84.126","CurrentVolume":"100 %","loop":"CMH_Network_Diabetes_Playlist"}}');
			response.setStatusCode(statusCode);
		}
		else {
			system.assert(false);
		}
		return response;
	}
}