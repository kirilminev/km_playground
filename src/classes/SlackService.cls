/*******************************************************************************************************
* @description      The purpose of this class to provide integration points for salesforce to post to 
*                   specified Slack channels. Each Slack channel has a webhook, which is just an endpoint
*                   configure on Slack and mapped to a single private or public channel. For or the purpose
*                   of this class channel and webhook endpoint is interchanable term.
*                   For more information on how to construct the message property for the Slack http request
*                   refer to the api documentation on Slack web site: slack api https://api.slack.com/
* @usage
* 
*/
global with sharing class SlackService {


    /*******************************************************************************************************
    * @description          This invocable method is intended to be used from workflow rules, process builder
    *                       flow etc. in  non-programatic declarative fashion, but still leverage the same 
    *                       code base for integrating SFDC to Slack
    * @param[List<SlackPayload> ]
    * @return               void
    * 
    */
    @InvocableMethod(label='Post to Slack Channel' description='Post message(s) to a given Slack channel.')
    public static void postToSlackInvocable(List<SlackPayload> messages) {
        for (SlackPayload message : messages) {
            postToSlack(message);    
        }
    }

    /*******************************************************************************************************
    * @description      Method posts to slack channel   
    * 
    */
	public static void postToSlack(SlackPayload message) {
        if (String.isEmpty(message.channel)) {
            postToSlack(message, Slack_Integration_Configuration__c.getInstance().Default_Channel__c);   
        } else {
            postToSlack(message, message.channel);   
        }
	}

    /*******************************************************************************************************
    * @description      This private method is used as common code where the rest of the public methods
    *                   call it to enque http request to the http async queue
    * @param [SlackPayload]
    * @param [String]
    * @return           void
    * 
    */
    @TestVisible
    private static void postToSlack(SlackPayload message, String channel) {
        
        if (Slack_Integration_Configuration__c.getInstance().Enabled__c){
            if (System.isQueueable() || System.isFuture()) {
                slackCall(EnvironmentUtils.getEnvironmentProperty(channel), 'POST', serializeSlackPayload(message));
            } else {
                System.enqueueJob(new QueueableSlackCall(EnvironmentUtils.getEnvironmentProperty(channel), 'POST', serializeSlackPayload(message)));
            }
        }
    }

    /*******************************************************************************************************
    * @description      The purpose of this method is to take payload value object and return json string
    *                   which should only have the properties that are not null in the SlackPayload object
    * 
    * @param[SlackPayload]
    * @return           JSON String with body payload for Slack Service
    * 
    */
    public static String serializeSlackPayload(SlackPayload slackPayload) {

        String serializedJsonResult = null;

        try {
            if (slackPayload == null) {
                return serializedJsonResult;
            } else {
                Map<String, Object> payloadMap = new Map<String, Object>();

                if (!String.isEmpty(slackPayload.text)) {
                    payloadMap.put('text', slackPayload.text);
                }
                if (!String.isEmpty(slackPayload.username)) {
                    payloadMap.put('username', slackPayload.username);
                }
                if (!String.isEmpty(slackPayload.icon_emoji)) {
                    payloadMap.put('icon_emoji', slackPayload.icon_emoji);   
                }
                if (!String.isEmpty(slackPayload.icon_url)) {
                    payloadMap.put('icon_url', slackPayload.icon_url); 
                }
                if (!String.isEmpty(slackPayload.type)) {
                    payloadMap.put('type', slackPayload.type); 
                }
                if (!String.isEmpty(slackPayload.customAttributeName) && !String.isEmpty(slackPayload.customAttributeValue)) {
                    payloadMap.put(slackPayload.customAttributeName, slackPayload.customAttributeValue); 
                }
                serializedJsonResult = JSON.serialize(payloadMap);
                return serializedJsonResult;
            }
        } catch (Exception ex) {
            return serializedJsonResult;
        }
    }


    /*******************************************************************************************************
    * @description      Calls http callouts for posting to Slack from an already Async context
    * 
    */
    public static void slackCall(String endPointUrl, String method, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPointUrl);
        req.setMethod(method);
        req.setBody(body);
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() >= 400) {
            String errorMessage = 'Slack Web Service Returned Error Code. \n' +
                                  'Status Code: ' + res.getStatusCode() + ' \n' + 
                                  'Error Message: ' + res.getBody();

            LoggingUtils.log(new LoggingUtils.LogInfo(new LoggingUtils.CustomException(errorMessage)), true, false, false); 
        }
    
    }

    /*******************************************************************************************************
    * @description  Calls http callouts in assyncronous fashion by adding requests to a async queue on salesforce
    *               which queue can be monitored via the apex monitoring utility
    * 
    * 
    */
	public class QueueableSlackCall implements System.Queueable, Database.AllowsCallouts {
         
        private final String endPointUrl;
        private final String method;
        private final String body;
         
        public QueueableSlackCall(String endPointUrl, String method, String body) {
            this.endPointUrl = endPointUrl;
            this.method = method;
            this.body = body;
        }
         
        public void execute(System.QueueableContext ctx) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPointUrl);
            req.setMethod(method);
            req.setBody(body);
            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() >= 400) {
                String errorMessage = 'Slack Web Service Returned Error Code. \n' +
                                      'Status Code: ' + res.getStatusCode() + ' \n' + 
                                      'Error Message: ' + res.getBody();

                LoggingUtils.log(new LoggingUtils.LogInfo(new LoggingUtils.CustomException(errorMessage)), true, false, false);  // TODO: reformat using level & message?

            }
        }
    }

    /*******************************************************************************************************
    * @description          This is only a value class to hold the payload for Slack Web Service
    * 
    */
    global class SlackPayload{

        @InvocableVariable(required=false)
        public String channel;// This should not be used in the payload, use custom name attribute instead
        @InvocableVariable(required=true)
        public String text;
        @InvocableVariable(required=false)
        public String username;
        @InvocableVariable(required=false)
        public String icon_emoji;
        @InvocableVariable(required=false)
        public String icon_url;
        @InvocableVariable(required=false)
        public String type;
        @InvocableVariable(required=false)
        public String customAttributeName;
        @InvocableVariable(required=false)
        public String customAttributeValue;

        public SlackPayload(){}
        
        public SlackPayload(String text){
            this.text = text;
        }

        public SlackPayload(String channel, String text){
            this.channel = channel;
            this.text = text;
        }

        public SlackPayload(String text, String username, String icon_emoji, String icon_url, String type){
            this.text = text;
            this.username = username;
            this.icon_emoji = icon_emoji;
            this.icon_url = icon_url;
            this.type = type;
        }

        public SlackPayload(String channel, String text, String username, String icon_emoji, String icon_url, String type){
            this.channel = channel;
            this.text = text;
            this.username = username;
            this.icon_emoji = icon_emoji;
            this.icon_url = icon_url;
            this.type = type;
        }

        public SlackPayload(String channel, String text, String username, String icon_emoji, String icon_url, String type, String customAttributeName, String customAttributeValue){
            this.channel = channel;
            this.text = text;
            this.username = username;
            this.icon_emoji = icon_emoji;
            this.icon_url = icon_url;
            this.type = type;
            this.customAttributeName = customAttributeName;
            this.customAttributeValue = customAttributeValue;
        }
    }
}
