/*******************************************************************************************************
* @description 		Class will be used to capture result of request and return back to the UI whether the
*                	request has failed (success=false) or succeded (success=true) along with a descriptive
*                	message as part of the resultMessage property to provide descriptive message to the user
*                	
* @example			
* 	
*/
global class HttpRequestResult {

	public Boolean success {set; get;}
	public String resultMessage {set; get;}
	public String userFriendlyResultMessage {set; get;}

	public HttpRequestResult(Boolean success, String resultMessage) {
		this.success = success;
		this.resultMessage = resultMessage;
	}

	public HttpRequestResult(Boolean success, String resultMessage, String userFriendlyResultMessage) {
		this.success = success;
		this.resultMessage = resultMessage;
		this.userFriendlyResultMessage = userFriendlyResultMessage;
	}
}