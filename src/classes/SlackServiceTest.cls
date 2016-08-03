/*******************************************************************************************************
* @description 	Class is testing the SlackService integration code
* 
*/
@isTest
private class SlackServiceTest {
	
	private static String slackChannelName = 'SFDC_EXCEPTIONS_CHANNEL';  // was slack_channel

	@testSetup
	private static void setupData() {
		Slack_Integration_Configuration__c defaultCustomSetting = new Slack_Integration_Configuration__c();

		defaultCustomSetting.Enabled__c = true;
		defaultCustomSetting.Default_Channel__c = slackChannelName;
		defaultCustomSetting.Exception_Channel__c = slackChannelName;

		insert defaultCustomSetting;

		TestDataService.setupRestEnvironmentProperties();
	}

	private static testMethod void testQueableSlackCall(){
		
		Test.startTest();  

		String payloadMessageTest = 'Test Message';
		String usernameTest = 'username_test';
		String iconEmojiTest = 'emoji_test';
		String iconUrlTest = 'icon_url_test';
		String typeTest = 'type_test';
		String customAttributeNameTest = 'custom_test_attribute_name';
		String customAttributeValueTest = 'custom_test_attribute_value';

		SlackService.SlackPayload slackPayload = new SlackService.SlackPayload(
			slackChannelName,
			payloadMessageTest,
			usernameTest,
			iconEmojiTest,
			iconUrlTest,
			typeTest,
			customAttributeNameTest,
			customAttributeValueTest
			);

		Test.setMock(HttpCalloutMock.class, new SlackServiceMock(200));
        SlackService.postToSlack(slackPayload, slackChannelName);
        
        Test.setMock(HttpCalloutMock.class, new SlackServiceMock(500));
        SlackService.postToSlack(slackPayload, slackChannelName);

        Test.stopTest();
	}

	private static testMethod void testPostMethods() {
		Test.startTest();

		String payloadMessageTest = 'Test Message';
		String usernameTest = 'username_test';
		String iconEmojiTest = 'emoji_test';
		String iconUrlTest = 'icon_url_test';
		String typeTest = 'type_test';

		SlackService.SlackPayload slackPayload = new SlackService.SlackPayload(
			payloadMessageTest,
			usernameTest,
			iconEmojiTest,
			iconUrlTest,
			typeTest
			);
		
		Test.setMock(HttpCalloutMock.class, new SlackServiceMock(200));
		SlackService.postToSlack(slackPayload);
		slackPayload.channel = slackChannelName;
		SlackService.postToSlack(slackPayload);
		SlackService.postToSlackInvocable(new List<SlackService.SlackPayload>{slackPayload});

		Test.stopTest();
	}
	
	private static testMethod void testSerializeSlackPayload() {

		String payloadMessageTest = 'Test Message';
		String usernameTest = 'username_test';
		String iconEmojiTest = 'emoji_test';
		String iconUrlTest = 'icon_url_test';
		String typeTest = 'type_test';
		String customAttributeNameTest = 'custom_test_attribute_name';
		String customAttributeValueTest = 'custom_test_attribute_value';

		String jsonTextTest = SlackService.serializeSlackPayload(new SlackService.SlackPayload(
			slackChannelName,
			payloadMessageTest,
			usernameTest,
			iconEmojiTest,
			iconUrlTest,
			typeTest,
			customAttributeNameTest,
			customAttributeValueTest
			));

		System.assertEquals(null, SlackService.serializeSlackPayload(null));

		System.assertEquals(payloadMessageTest, 
			((SlackService.SlackPayload)JSON.deserialize(jsonTextTest, SlackService.SlackPayload.class)).text, 
			'text property expected to be ' + payloadMessageTest);

		System.assertEquals(usernameTest, 
			((SlackService.SlackPayload)JSON.deserialize(jsonTextTest, SlackService.SlackPayload.class)).username, 
			'username property expected to be ' + usernameTest);
		
		System.assertEquals(iconEmojiTest, 
			((SlackService.SlackPayload)JSON.deserialize(jsonTextTest, SlackService.SlackPayload.class)).icon_emoji, 
			'icon_emoji property expected to be ' + iconEmojiTest);

		System.assertEquals(iconUrlTest, 
			((SlackService.SlackPayload)JSON.deserialize(jsonTextTest, SlackService.SlackPayload.class)).icon_url, 
			'icon_url property expected to be ' + iconUrlTest);

		System.assertEquals(typeTest, 
			((SlackService.SlackPayload)JSON.deserialize(jsonTextTest, SlackService.SlackPayload.class)).type, 
			'type property expected to be ' + typeTest);

		
		System.assertEquals(customAttributeValueTest, 
			((Map<String, Object>)JSON.deserializeUntyped(jsonTextTest)).get(customAttributeNameTest), 
			'custom attribute name property expected to be ' + customAttributeValueTest);
			
	}

	private static testMethod void testCoverConstructors() {

		SlackService.SlackPayload obj1 = new SlackService.SlackPayload(
			'slackChannelName',
			'payloadMessageTest',
			'usernameTest',
			'iconEmojiTest',
			'iconUrlTest',
			'typeTest'
			);

		SlackService.SlackPayload obj2 = new SlackService.SlackPayload(
			'payloadMessageTest',
			'usernameTest',
			'iconEmojiTest',
			'iconUrlTest',
			'typeTest'
			);

		SlackService.SlackPayload obj3 = new SlackService.SlackPayload(
			'slackChannelName',
			'payloadMessageTest'
			);
		SlackService.SlackPayload obj4 = new SlackService.SlackPayload(
			'payloadMessageTest'
			);

		SlackService.SlackPayload obj5 = new SlackService.SlackPayload();
	}
}