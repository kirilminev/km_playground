@isTest
public with sharing class LoggingServiceTest {
	private static testMethod void testGetMatchingLogs() {
    	Exception_Log__c existingLog1 = new Exception_Log__c(Level__c = new LoggingService.LoggingLevels().FATAL,
    														Line_Number__c = 808,
    														Trigger_Context__c = 'IsBefore: yes',
    														Type_Name__c = 'ListException');
    	insert existingLog1;

    	Exception_Log__c existingLog2 = new Exception_Log__c(Level__c = new LoggingService.LoggingLevels().INFO, // only difference is here
    														Line_Number__c = 808,
    														Trigger_Context__c = 'IsBefore: yes',
    														Type_Name__c = 'ListException');
    	insert existingLog2;

    	List<Exception_Log__c> matchingLogs = LoggingService.getMatchingLogs(new List<String>{'Id', 'Level__c', 'Line_Number__c', 'Trigger_Context__c', 'Type_Name__c'}, existingLog1);
    	System.assertEquals(existingLog1.Id, matchingLogs[0].Id, 'Matching Log Id expected to match Existing Log Id');
    	System.assertEquals(existingLog1.Level__c, matchingLogs[0].Level__c);
    	System.assertEquals(existingLog1.Line_Number__c, matchingLogs[0].Line_Number__c);
    	System.assertEquals(existingLog1.Trigger_Context__c, matchingLogs[0].Trigger_Context__c);
    	System.assertEquals(existingLog1.Type_Name__c, matchingLogs[0].Type_Name__c);
    }
}