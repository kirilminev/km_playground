/*******************************************************************************************************
* @description   Unit Tests for LoggingUtil class
* 
*/
@isTest
public class LoggingUtilsTest {
    
	@testSetup
	private static void setupData() {

		TestDataService.setupSlackCustomSettings();
		TestDataService.setupRestEnvironmentProperties();
		TestDataService.setupLoggingCustomSettings();
		
	}

	
    private static testMethod void testExceptionLogToObject() {
    	
    	List<Exception_Log__c> exceptionLogs = [SELECT Id FROM Exception_Log__c];
    	System.assertEquals(0, exceptionLogs.size(), 'Exception Log object expected to be empty.');
    	
    	Test.startTest();
    	LoggingUtils.executeLog(new LoggingUtils.LogInfo(new UnitTestException('exception message')), true, false, false);
    	Test.stopTest();
    	exceptionLogs = [SELECT Id, Level__c, Line_Number__c, Trigger_Context__c, Type_Name__c FROM Exception_Log__c];
    	
    	System.assertEquals(1, exceptionLogs.size(), 'Exception Log object expected to have 1 record.');
    }


	private static testMethod void testExceptionLogToSlack() {

    	Slack_Integration_Configuration__c defaultCustomSetting = [SELECT Id FROM Slack_Integration_Configuration__c LIMIT 1][0];
    	defaultCustomSetting.Slack_Exceptions_Hashtag__c = '#myhashtag';
    	update defaultCustomSetting;

    	Logging_Configuration__c loggingSetting = [SELECT Id FROM Logging_Configuration__c LIMIT 1][0];
    	loggingSetting.Email_Subject__c = null;
    	update loggingSetting; 

    	Test.startTest();
    	Map<String, StagingProperties__c> stagingProperties = StagingProperties__c.getAll();
		for (String s : stagingProperties.keySet()){
			system.debug(s + ' ---- ' + stagingProperties.get(s));
		}
		
		Test.setMock(HttpCalloutMock.class, new SlackServiceMock(200));
    	LoggingUtils.executeLog(new LoggingUtils.LogInfo(new UnitTestException('exception message')), false, true, false);
    	Test.stopTest();
    	
    	List<Exception_Log__c> exceptionLogs = [SELECT Id FROM Exception_Log__c];
    	
    	System.assertEquals(0, exceptionLogs.size(), 'Exception Log object expected to have 0 records.');
    	
    	// TODO: Assert Slack component?
	}


	private static testMethod void testExceptionLogToEmail() {
    	Test.startTest();
    	LoggingUtils.log(new LoggingUtils.LogInfo(new UnitTestException('exception message')), false, false, true);
    	Test.stopTest();
    	
    	List<Exception_Log__c> exceptionLogs = [SELECT Id FROM Exception_Log__c];

    	System.assertEquals(0, exceptionLogs.size(), 'Exception Log object expected to have 0 records.');
    	// TODO: Assert email component?
    }

    
	private static testMethod void testLog() {
    	Test.startTest();
    	LoggingUtils.Log(new UnitTestException('exception message'));
    	Test.stopTest();
    	List<Exception_Log__c> exceptionLogs = [SELECT Id FROM Exception_Log__c];
    	System.assertEquals(1, exceptionLogs.size(), 'Exception Log object expected to have 1 record.');
    }


    private static testMethod void testExecuteLog() {
    	Test.startTest();
    	LoggingUtils.executeLog(new LoggingUtils.LogInfo(new UnitTestException('exception message')), true, false, false);
    	Test.stopTest();
    	List<Exception_Log__c> exceptionLogs = [SELECT Id FROM Exception_Log__c];
    	System.assertEquals(1, exceptionLogs.size(), 'Exception Log object expected to have 1 record.');
    }


    private static testMethod void testMatchedLogCountIsIncremented() {
		List<LoggingUtils.TriggerContextInfo> tci = new List<LoggingUtils.TriggerContextInfo>{new LoggingUtils.TriggerContextInfo(new LoggingService.TriggerContextTypes().IS_BEFORE, true)};

		ListException ex = new ListException();
		LoggingUtils.executeLog(new LoggingUtils.LogInfo(ex, new LoggingService.LoggingLevels().FATAL, null, null, tci, null), true, false, false);
   		List<Exception_Log__c> existingLogs = [SELECT Id, Cause__c, Count__c, Custom_Message__c, Message__c, Stack_Trace_String__c FROM Exception_Log__c];
		System.assertEquals(1, existingLogs.size(), 'Should only be 1 log record');
   		System.assertEquals(1, existingLogs[0].Count__c, 'Initial Exception record expected to have count of 1');
   		
 		LoggingUtils.executeLog(new LoggingUtils.LogInfo(ex, new LoggingService.LoggingLevels().FATAL, null, null, tci, null), true, false, false);
    	
    	List<Exception_Log__c> matchingLogs = [SELECT Id, Cause__c, Count__c, Custom_Message__c, Message__c, Stack_Trace_String__c FROM Exception_Log__c];
    	System.assertEquals(1, matchingLogs.size(), 'Should not have made another log record');
    	System.assertEquals(2, matchingLogs[0].Count__c, 'Matching Log Count__c expected to be incremented');
    }


    private static testMethod void testEmailMuted()  {
		List<LoggingUtils.TriggerContextInfo> tci = new List<LoggingUtils.TriggerContextInfo>{new LoggingUtils.TriggerContextInfo(new LoggingService.TriggerContextTypes().IS_BEFORE, true)};

		ListException ex = new ListException();
		LoggingUtils.executeLog(new LoggingUtils.LogInfo(ex, new LoggingService.LoggingLevels().FATAL, null, null, tci, null), true, false, true);
		Exception_Log__c existingLog = [SELECT Id, Count__c, Mute_Email__c FROM Exception_Log__c].get(0);
		System.assertEquals(1, existingLog.Count__c, 'Existing Log Count__c not set correctly');
		System.assert(!existingLog.Mute_Email__c, 'Existing Log should not yet be muted for email');
		existingLog.Mute_Email__c = true;
		update existingLog;

		LoggingUtils.executeLog(new LoggingUtils.LogInfo(ex, new LoggingService.LoggingLevels().FATAL, null, null, tci, null), true, false, true);
		Exception_Log__c matchingLog = [SELECT Id, Count__c, Mute_Email__c FROM Exception_Log__c].get(0);
		System.assertEquals(2, matchingLog.Count__c, 'Matching log should be updated');
		System.assert(matchingLog.Mute_Email__c, 'Matching log should still be muted for email');
	}


	private static testMethod void testSlackMuted()  {
		Slack_Integration_Configuration__c defaultCustomSetting = [SELECT Id FROM Slack_Integration_Configuration__c LIMIT 1][0];
    	defaultCustomSetting.Slack_Exceptions_Hashtag__c = '#myhashtag';
    	update defaultCustomSetting;

    	Logging_Configuration__c loggingSetting = [SELECT Id FROM Logging_Configuration__c LIMIT 1][0];
    	loggingSetting.Email_Subject__c = null;
    	update loggingSetting; 
		Test.setMock(HttpCalloutMock.class, new SlackServiceMock(200));
    	Test.startTest();

		List<LoggingUtils.TriggerContextInfo> tci = new List<LoggingUtils.TriggerContextInfo>{new LoggingUtils.TriggerContextInfo(new LoggingService.TriggerContextTypes().IS_BEFORE, true)};

		ListException ex = new ListException();
		LoggingUtils.executeLog(new LoggingUtils.LogInfo(ex, new LoggingService.LoggingLevels().FATAL, null, null, tci, null), true, true, false);
		Exception_Log__c existingLog = [SELECT Id, Count__c, Mute_Slack__c FROM Exception_Log__c].get(0);
		System.assertEquals(1, existingLog.Count__c, 'Existing Log Count__c not set correctly');
		System.assert(!existingLog.Mute_Slack__c, 'Existing Log should not yet be muted for slack');
		existingLog.Mute_Slack__c = true;
		update existingLog;

		LoggingUtils.executeLog(new LoggingUtils.LogInfo(ex, new LoggingService.LoggingLevels().FATAL, null, null, tci, null), true, true, false);
		Test.stopTest();
		Exception_Log__c matchingLog = [SELECT Id, Count__c, Mute_Slack__c FROM Exception_Log__c].get(0);
		System.assertEquals(2, matchingLog.Count__c, 'Matching log should be updated');
		System.assert(matchingLog.Mute_Slack__c, 'Matching log should still be muted for slack');
	}


    private static testMethod void testCreateLogFromListException()  {
        List<LoggingUtils.LimitInfo> limits = LoggingUtils.getSystemLimits();

        List<LoggingUtils.TriggerContextInfo> triggerContext = new List<LoggingUtils.TriggerContextInfo>();
        triggerContext.add(new LoggingUtils.TriggerContextInfo('IsBefore', true));
        triggerContext.add(new LoggingUtils.TriggerContextInfo('IsUpdate', true));

        String customMessage = 'test custom message';

		Exception e = new ListException();
		String unitTestExceptionMessage = 'Unit Test Exception Message';
		UnitTestException ute = new UnitTestException(unitTestExceptionMessage, e);
		String level = new LoggingService.LoggingLevels().INFO;

		List<String> records = new List<String>{'123456789012345678'};

        LoggingUtils.LogInfo logInfo = new LoggingUtils.LogInfo(ute, level, records, limits, triggerContext, customMessage);
        Exception_Log__c result = loggingUtils.createLog(logInfo);

        String cause = e.getTypeName() + ': ' + e.getMessage();
        String stackTrace = ute.getStackTraceString();
        
        Exception_Log__c expected = new Exception_Log__c();
        expected.Cause__c = cause;
        expected.Cause_Beginning__c = cause;
        expected.Cause_Ending__c = cause;
        expected.Count__c = 1;
        expected.Custom_Message__c = customMessage;
        expected.DML_Info__c = null;
        expected.Level__c = level;
        expected.Limits__c = LoggingUtils.limitsInfoToString(limits);
        expected.Line_Number__c = ute.getLineNumber();
        expected.Message__c = unitTestExceptionMessage;
        expected.Message_Beginning__c = unitTestExceptionMessage;
        expected.Message_Ending__c = unitTestExceptionMessage;
        expected.Record_Id__c = records[0];
        expected.Stack_Trace_String__c = stackTrace;
        expected.Stack_Trace_Beginning__c = stackTrace;
        expected.Stack_Trace_Ending__c = stackTrace;
        expected.Trigger_Context__c = LoggingUtils.triggerContextInfoToString(triggerContext);
        
        System.assertEquals(expected.Cause__c, result.Cause__c, 'Cause__c should match');
        System.assertEquals(expected.Cause_Beginning__c, result.Cause_Beginning__c, 'Cause_Beginning__c should match');
		System.assertEquals(expected.Cause_Ending__c, result.Cause_Ending__c, 'Cause_Ending__c should match');
		System.assertEquals(expected.Count__c, result.Count__c, 'Count__c should match');
		System.assertEquals(expected.Custom_Message__c, result.Custom_Message__c, 'Count__c should match');
		System.assertEquals(expected.DML_Info__c, result.DML_Info__c, 'DML_Info__c should match');
		System.assertEquals(expected.Level__c, result.Level__c, 'Level__c should match');
		System.assertEquals(expected.Line_Number__c, result.Line_Number__c, 'Line_Number__c should match');
		System.assertEquals(expected.Message__c, result.Message__c, 'Message__c should match');
		System.assertEquals(expected.Message_Beginning__c, result.Message_Beginning__c, 'Message_Beginning__c should match');
		System.assertEquals(expected.Message_Ending__c, result.Message_Ending__c, 'Message_Ending__c should match');
		System.assertEquals(expected.Record_Id__c, result.Record_Id__c, 'Record_Id__c should match');
		System.assertEquals(expected.Stack_Trace_String__c, result.Stack_Trace_String__c, 'Stack_Trace_String__c should match');
		System.assertEquals(expected.Stack_Trace_Beginning__c, result.Stack_Trace_Beginning__c, 'Stack_Trace_Beginning__c should match');
		System.assertEquals(expected.Stack_Trace_Ending__c, result.Stack_Trace_Ending__c, 'Stack_Trace_Ending__c should match');
		System.assertEquals(expected.Trigger_Context__c, result.Trigger_Context__c, 'Trigger_Context__c should match');
	}


	private static testMethod void testCreateLogFromDmlExceptionOnUpdate()  {
		
		Account a = new Account(Name = 'Test Account');
		insert a;
		Account accountToUpdate = [SELECT Id, Name FROM Account][0];
		accountToUpdate.Name = null; // purposefully missing required fields (e.g. Name);
		Try {
			update accountToUpdate;
		} catch (Exception e) {
			LoggingUtils.LogInfo logInfo = new LoggingUtils.LogInfo(e);
			Exception_Log__c result = loggingUtils.createLog(logInfo);
			
			System.assertEquals('System.DmlException', result.Type_Name__c, 'Type_Name__c incorrectly set');
			System.assertEquals('Update failed. First exception on row 0 with id ', e.getMessage().left(48), 'Unexpected dml error message');
			System.assertEquals(accountToUpdate.Id, result.Record_Id__c, 'Record_Id__c incorrectly set');
		}
	}


	private static testMethod void testCreateLogFromDmlExceptionOnInsert()  {
		
		Account a = new Account(); // purposefully missing required fields (e.g. Name);
		Try {
			insert a;
		} catch (Exception e) {
			LoggingUtils.LogInfo logInfo = new LoggingUtils.LogInfo(e);
			Exception_Log__c result = loggingUtils.createLog(logInfo);
			
			System.assertEquals('System.DmlException', result.Type_Name__c, 'Type_Name__c incorrectly set');
			System.assertEquals('Insert failed. First exception on row 0', e.getMessage().left(39), 'Unexpected dml error message');
			System.assert(String.isEmpty(result.Record_Id__c), 'Record_Id__c incorrectly set');
		}
	}


	private static testMethod void testCreateLogFromDmlExceptionOnInsertWithinTestContext()  {
		Test.startTest();
		Account a = new Account(); // purposefully missing required fields (e.g. Name);
		Try {
			insert a;
		} catch (Exception e) {
			LoggingUtils.LogInfo logInfo = new LoggingUtils.LogInfo(e);
			Exception_Log__c result = loggingUtils.createLog(logInfo);
			
			System.assertEquals('System.DmlException', result.Type_Name__c, 'Type_Name__c incorrectly set');
			System.assertEquals('Insert failed. First exception on row 0', e.getMessage().left(39), 'Unexpected dml error message');
			System.assert(String.isEmpty(result.Record_Id__c), 'Record_Id__c incorrectly set');
		}
		Test.stopTest();
	}


	private static testMethod void testCreateLogFromLogMessage()  {
		String level = new LoggingService.LoggingLevels().INFO;
		String message = 'custom message';
		LoggingUtils.LogInfo logInfo = new LoggingUtils.LogInfo(level, message);
		Exception_Log__c result = loggingUtils.createLog(logInfo);

		System.assertEquals(level, result.Level__c, 'Level__c incorrectly set');
		System.assertEquals(message, result.Custom_Message__c, 'Custom_Message__c incorrectly set');
	}


	private static testMethod void testEmailRecipients()  {
		List<String> expected = new List<String>{'testmail1@contextmediainc.com','testmail2@contextmediainc.com'};

		List<String> result = LoggingUtils.emailRecipients();
		system.assertEquals(expected, result, 'Email Recipients should match Logging Configuration');
    }


	private static testMethod void testEmailRecipientsMissingShouldLogException()  {
		
        Logging_Configuration__c loggingSetting = [SELECT Id FROM Logging_Configuration__c].get(0);
		delete loggingSetting;
   		List<String> result = loggingUtils.emailRecipients();
   		system.assertEquals(null, result);

   		
   		Test.setMock(HttpCalloutMock.class, new SlackServiceMock(200));
   		Test.startTest();
   		LoggingUtils.log(new LoggingUtils.LogInfo('Fatal', 'test with no email recipients'), false, false, true);
   		Test.stopTest();

   		List<Exception_Log__c> loggedExceptions = [SELECT Id FROM Exception_Log__c];
   		system.assertEquals(1, loggedExceptions.size(), 'Missing email config should generate a logged exception');
    }

	
	private static testMethod void testEmailSubjectDefault()  {
		Logging_Configuration__c loggingSetting = [SELECT Id FROM Logging_Configuration__c].get(0);
		delete loggingSetting;

		String expected = 'Salesforce Exception Logged';
		String result = LoggingUtils.emailSubject();
		System.assertEquals(expected, result, 'Email subject not set correctly');
	}


	private static testMethod void testEmailSubjectFromLoggingConfiguration()  {
		String expected = Logging_Configuration__c.getInstance().Email_Subject__c;
		String result = LoggingUtils.emailSubject();
		System.assertEquals(expected, result, 'Email subject not set correctly');
	}
	

	private static testMethod void testEmailBodyComplete()  {
		
		Exception_Log__c logStaged = new Exception_Log__c(
			Caught_At__c = System.now(),
			Cause__c = 'test Cause',
			Count__c = 1,
			Custom_Message__c = 'test Custom Message',
			Level__c = new LoggingService.LoggingLevels().FATAL,
			Limits__c = 'test Limits',
			Message__c = 'test Message',
			Record_Id__c = 'test Record Id',
			Stack_Trace_String__c = 'test Stack Trace String',
			Trigger_Context__c = 'test Trigger Context',
			Type_Name__c = 'DmlException'
			);
		insert logStaged;

		String messageReturn = String.isEmpty(logStaged.Message__c) ? '' : '\n';
        String stackTraceReturn = String.isEmpty(logStaged.Stack_Trace_String__c) ? '' : '\n';
        String recordReturn = String.isEmpty(logStaged.Record_Id__c) ? '' : '\n';
        String limitsReturn = String.isEmpty(logStaged.Limits__c) ? '' : '\n';
        String contextReturn = String.isEmpty(logStaged.Trigger_Context__c) ? '' : '\n';
        String dmlReturn = String.isEmpty(logStaged.DML_Info__c) ? '' : '\n';

        String expected = '';
        expected += 'Salesforce Exception Occurred\n' + 
                    'Caught At: ' + String.valueOf(logStaged.Caught_At__c) + '\n' +
                    'Level: ' + logStaged.Level__c + '\n' +
                    'Exception Type: ' + logStaged.Type_Name__c + '\n' +
                    'Count: ' + logStaged.Count__c + '\n\n' +
                    'Cause: ' + logStaged.Cause__c + '\n\n' + 
                    'Custom Message: ' + logStaged.Custom_Message__c + '\n\n' +
                    'Exception Message: ' + messageReturn + logStaged.Message__c + '\n\n' + 
                    'Stack Trace: ' + stackTraceReturn + logStaged.Stack_Trace_String__c + '\n\n' +
                    'Record Id(s): ' + recordReturn + logStaged.Record_Id__c + '\n\n' +
                    'Limits: ' + limitsReturn + logStaged.Limits__c + '\n\n' +
                    'Context: ' + contextReturn + logStaged.Trigger_Context__c + '\n\n' +
                    'DML: ' + dmlReturn + logStaged.DML_Info__c + '\n\n';

        if (!String.isEmpty(logStaged.Id)) {
            expected += 'See Exception: ' + URL.getSalesforceBaseURL().toExternalForm() + '/' + logStaged.Id;
        }
        
        String result = LoggingUtils.emailBody(logStaged);
        System.assertEquals(expected, result, 'Email body not set correctly');
	}


	private static testMethod void testEmailBodyMinimal()  {
		
		Exception_Log__c logStaged = new Exception_Log__c(Caught_At__c = System.now(), Count__c = 1);

		String messageReturn = String.isEmpty(logStaged.Message__c) ? '' : '\n';
        String stackTraceReturn = String.isEmpty(logStaged.Stack_Trace_String__c) ? '' : '\n';
        String recordReturn = String.isEmpty(logStaged.Record_Id__c) ? '' : '\n';
        String limitsReturn = String.isEmpty(logStaged.Limits__c) ? '' : '\n';
        String contextReturn = String.isEmpty(logStaged.Trigger_Context__c) ? '' : '\n';
        String dmlReturn = String.isEmpty(logStaged.DML_Info__c) ? '' : '\n';

        String expected = '';
        expected += 'Salesforce Exception Occurred\n' + 
                    'Caught At: ' + String.valueOf(logStaged.Caught_At__c) + '\n' +
                    'Level: ' + logStaged.Level__c + '\n' +
                    'Exception Type: ' + logStaged.Type_Name__c + '\n' +
                    'Count: ' + logStaged.Count__c + '\n\n' +
                    'Cause: ' + logStaged.Cause__c + '\n\n' + 
                    'Custom Message: ' + logStaged.Custom_Message__c + '\n\n' +
                    'Exception Message: ' + messageReturn + logStaged.Message__c + '\n\n' + 
                    'Stack Trace: ' + stackTraceReturn + logStaged.Stack_Trace_String__c + '\n\n' +
                    'Record Id(s): ' + recordReturn + logStaged.Record_Id__c + '\n\n' +
                    'Limits: ' + limitsReturn + logStaged.Limits__c + '\n\n' +
                    'Context: ' + contextReturn + logStaged.Trigger_Context__c + '\n\n' +
                    'DML: ' + dmlReturn + logStaged.DML_Info__c + '\n\n';

        if (!String.isEmpty(logStaged.Id)) {
            expected += 'See Exception: ' + URL.getSalesforceBaseURL().toExternalForm() + '/' + logStaged.Id;
        }
        
        String result = LoggingUtils.emailBody(logStaged);
        System.assertEquals(expected, result, 'Email body not set correctly');
	}


	private static testMethod void testSlackMessageComplete()  {
		Exception_Log__c logStaged = new Exception_Log__c(
			Type_Name__c = 'DmlException',
			Cause__c = 'test Cause',
			Custom_Message__c = 'test Custom Message',
			Stack_Trace_String__c = 'test Stack Trace String'
			);
		insert logStaged;

		String expected = '';
		if (String.isNotEmpty(Slack_Integration_Configuration__c.getInstance().Slack_Exceptions_Hashtag__c)) {
            expected += Slack_Integration_Configuration__c.getInstance().Slack_Exceptions_Hashtag__c + '\n';    
        }

        expected +=  '*Salesforce ' + logStaged.Type_Name__c + ' Occurred* \n';
        if (String.isNotEmpty(logStaged.Cause__c)) expected += '*Cause:* ' + logStaged.Cause__c + '\n';
        if (String.isNotEmpty(LogStaged.Custom_Message__c)) expected += '*Message:* ' + logStaged.Custom_Message__c + '\n';
        if (String.isNotEmpty(LogStaged.Stack_Trace_String__c)) expected += '*Stack Trace:* ' + logStaged.Stack_Trace_String__c + '\n';
        if (String.isNotEmpty(logStaged.Id)) expected += '*<' + URL.getSalesforceBaseURL().toExternalForm() + '/' + logStaged.Id + '|See Exception>*';
		
		String result = LoggingUtils.slackMessage(logStaged);
		System.assertEquals(expected, result, 'Slack message not set correctly');
	}


	private static testMethod void testSlackMessageMinimal()  {
		Exception_Log__c logStaged = new Exception_Log__c(
			Type_Name__c = 'DmlException'
			);

		String expected = '';
		if (String.isNotEmpty(Slack_Integration_Configuration__c.getInstance().Slack_Exceptions_Hashtag__c)) {
            expected += Slack_Integration_Configuration__c.getInstance().Slack_Exceptions_Hashtag__c + '\n';    
        }

        expected +=  '*Salesforce ' + logStaged.Type_Name__c + ' Occurred* \n';
        
		String result = LoggingUtils.slackMessage(logStaged);
		System.assertEquals(expected, result, 'Slack message not set correctly');
	}


	private static testMethod void testGetSystemLimits() {
		list<LoggingUtils.LimitInfo> expected = new List<LoggingUtils.LimitInfo>();

		expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().AGGREGATE_QUERIES, 
                                    			System.Limits.getAggregateQueries(),
                                    			System.Limits.getLimitAggregateQueries()));
        expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().CALLOUTS, 
                                    			System.Limits.getCallouts(),
                                    			System.Limits.getLimitCallouts()));
        expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().CPU_TIME, 
                                    			System.Limits.getCpuTime(),
                                    			System.Limits.getLimitCpuTime()));
        expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().DATABASE_TIME, 
                                    			System.Limits.getDatabaseTime(),
                                    			System.Limits.getLimitDatabaseTime()));
        expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().DML_ROWS, 
                                    			System.Limits.getDmlRows(),
                                    			System.Limits.getLimitDmlRows()));
        expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().DML_STATEMENTS, 
                                    			System.Limits.getDmlStatements(),
                                    			System.Limits.getLimitDmlStatements()));
        expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().EMAIL_INVOCATIONS, 
                                    			System.Limits.getEmailInvocations(),
                                    			System.Limits.getLimitEmailInvocations()));
        expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().FUTURE_CALLS, 
                                    			System.Limits.getFutureCalls(),
                                    			System.Limits.getLimitFutureCalls()));
        expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().HEAP_SIZE, 
                                    			System.Limits.getHeapSize(),
                                    			System.Limits.getLimitHeapSize()));
        expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().MOBILE_PUSH_APEX_CALLS, 
                                    			System.Limits.getMobilePushApexCalls(),
                                    			System.Limits.getLimitMobilePushApexCalls()));
        expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().QUERIES, 
                                    			System.Limits.getQueries(),
                                    			System.Limits.getLimitQueries()));
        expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().QUERY_LOCATOR_ROWS, 
                                    			System.Limits.getQueryLocatorRows(),
                                    			System.Limits.getLimitQueryLocatorRows()));
        expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().QUERY_ROWS, 
                                    			System.Limits.getQueryRows(),
                                    			System.Limits.getLimitQueryRows()));
        expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().QUEUEABLE_JOBS, 
                                    			System.Limits.getQueueableJobs(),
                                    			System.Limits.getLimitQueueableJobs()));
        expected.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().SOSL_QUERIES, 
                                    			System.Limits.getSoslQueries(),
                                    			System.Limits.getLimitSoslQueries()));

		list<LoggingUtils.LimitInfo> result = loggingUtils.getSystemLimits();

		System.assertEquals(expected.size(), result.size(), 'list of LimitInfo getSystemLimits should be the same');
		
		Set<String> variableLimits = new Set<String> {new LoggingService.SystemLimitTypes().CPU_TIME, new LoggingService.SystemLimitTypes().DATABASE_TIME, new LoggingService.SystemLimitTypes().HEAP_SIZE};
		for (Integer i = 0; i<expected.size(); i++) {
			if (!variableLimits.contains(expected[i].limitType)) {
				System.assertEquals(expected[i].limitType, result[i].limitType);
				System.assertEquals(expected[i].limitAmount, result[i].limitAmount);
				System.assertEquals(expected[i].limitMax, result[i].limitMax);	
			}
		}
	}


	private static testMethod void testProcessExceptionCaught() {
		ListException e = new ListException();
		LoggingUtils.LogInfo logInfo = new LoggingUtils.LogInfo(new UnitTestException('Unit Test Exception', e));
		Exception_Log__c logStaged = new Exception_Log__c();

		logStaged = LoggingUtils.processExceptionCaught(logInfo, logStaged);

		 System.assert(String.isNotEmpty(logStaged.Cause__c), 'Cause__c should have info');
		 System.assertEquals('System.ListException: Script-thrown exception', LogStaged.Cause__c, 'Cause__c not set correctly');
		 System.assertEquals('Fatal', LogStaged.Level__c, 'Level__c not defaulted to Fatal');
		 System.assertEquals('Unit Test Exception', LogStaged.Message__c, 'Message__c not set correctly');
		 System.assertEquals('LoggingUtilsTest.UnitTestException', LogStaged.Type_Name__c, 'Type_Name__c not set correctly');
		 System.assertEquals(null, logStaged.DML_Info__c, 'DML_Info__c should be null');
	}


	private static testMethod void testProcessExceptionCaughtNull() {
		LoggingUtils.LogInfo logInfo = new LoggingUtils.LogInfo('Info', 'testMessage');
		System.assert(logInfo.exceptionCaught == null, 'Should not have an Exception Caught');

		Exception_Log__c logStaged = new Exception_Log__c();

		logStaged = LoggingUtils.processExceptionCaught(logInfo, logStaged);

		System.assertEquals('Log', logStaged.Type_Name__c, 'Type_Name_c not set correctly');
		System.assert(String.isEmpty(logStaged.Cause__c));
		System.assert(String.isEmpty(logStaged.Message__c));
		System.assert(String.isEmpty(logStaged.Stack_Trace_String__c));
		System.assert(String.isEmpty(logStaged.DML_Info__c));
	}


	private static testMethod void testRecordsToString() {
		List<String> records = new List<String>{'test1', 'test2', 'test3'};
		String expected = 'test1\ntest2\ntest3';
		String result = LoggingUtils.recordsToString(records);
		System.assertEquals(expected, result, 'records to String not rendered correctly');
	}


	private static testMethod void testLimitsInfoToString() {
		List<LoggingUtils.LimitInfo> limitsInfo = new List<LoggingUtils.LimitInfo>();
		limitsInfo.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().CPU_TIME, 5, 5000));
		limitsInfo.add(new LoggingUtils.LimitInfo(new LoggingService.SystemLimitTypes().QUERIES, 0, 20)); 

		String result = LoggingUtils.limitsInfoToString(limitsInfo);
		
		system.assertEquals('CPU Time: 5 out of 5,000', result, 'limitsInfo to String not rendered correctly, should not print entries with 0');
	}


	private static testMethod void testTriggerContextToString() {
		List<LoggingUtils.TriggerContextInfo> triggerContextInfos = new List<LoggingUtils.TriggerContextInfo>();
		triggerContextInfos.add(new LoggingUtils.TriggerContextInfo(new LoggingService.TriggerContextTypes().IS_BEFORE, true));
		triggerContextInfos.add(new LoggingUtils.TriggerContextInfo(new LoggingService.TriggerContextTypes().IS_AFTER, false));
		triggerContextInfos.add(new LoggingUtils.TriggerContextInfo(new LoggingService.TriggerContextTypes().IS_INSERT, true));
		triggerContextInfos.add(new LoggingUtils.TriggerContextInfo(new LoggingService.TriggerContextTypes().IS_UPDATE, false));

		String result = LoggingUtils.triggerContextInfoToString(triggerContextInfos);
		
		String expected = new LoggingService.TriggerContextTypes().IS_BEFORE + ': ' + 'yes' + '\n';
		expected += new LoggingService.TriggerContextTypes().IS_AFTER + ': ' + 'no' + '\n';
		expected += new LoggingService.TriggerContextTypes().IS_INSERT + ': ' + 'yes' + '\n';
		expected += new LoggingService.TriggerContextTypes().IS_UPDATE + ': ' + 'no';
		
		system.assertEquals(expected, result, 'triggerContextInfo to String not rendered correctly');
	}


	private static testMethod void testDmlExceptionInfoToString() {
		Test.startTest();
		Account a = new Account();
		try {
			insert a;
		} catch (Exception ex) {
			String result = LoggingUtils.dmlExceptionInfoToString(ex);
			system.debug(result);

			String expected = 'Count: 1\n';
			expected += 'null at row: 0, Fields: Name\n';
			expected += '  Type: REQUIRED_FIELD_MISSING  Msg: Required fields are missing: [Name]';

			System.assertEquals(expected, result, 'dmlExecptionInfo to String not rendered correctly');
		}
		Test.stopTest();
	}


	private static testMethod void testDmlMultipleExceptionInfoToString() {
		Test.startTest();
		List<Account> accounts = new List<Account> {new Account(), new Account()};
		try {
			insert accounts;
		} catch (Exception ex) {
			String result = LoggingUtils.dmlExceptionInfoToString(ex);
			system.debug(result);

			String expected = 'Count: 2\n';
			expected += 'null at row: 0, Fields: Name\n';
			expected += '  Type: REQUIRED_FIELD_MISSING  Msg: Required fields are missing: [Name]\n';
			expected += 'null at row: 1, Fields: Name\n';
  			expected += '  Type: REQUIRED_FIELD_MISSING  Msg: Required fields are missing: [Name]';

			System.assertEquals(expected, result, 'dmlExecptionInfo to String not rendered correctly');

		}
		Test.stopTest();
	}


	private static testMethod void testLogInfoConstructors() {
		LoggingUtils.LogInfo obj1 = new LoggingUtils.LogInfo(
			new UnitTestException(''),
			'levelTest',
			null,  // List<String> recordIds
			null,  // List<LimitInfo> limits
			null,  // List<TriggerContextInfo> context
			'testMessage'
			);

		LoggingUtils.LogInfo obj2 = new LoggingUtils.LogInfo(
			new UnitTestException(''),
			'levelTest',
			null,  // List<String> recordIds
			null,  // List<LimitInfo> limits
			null  // List<TriggerContextInfo> context
			);

		LoggingUtils.LogInfo obj3 = new LoggingUtils.LogInfo(
			new UnitTestException(''),
			'levelTest',
			null,  // List<String> recordIds
			null  // List<LimitInfo> limits
			);

		LoggingUtils.LogInfo obj4 = new LoggingUtils.LogInfo(
			new UnitTestException(''),
			'levelTest',
			new List<String>()
			);

		LoggingUtils.LogInfo obj5 = new LoggingUtils.LogInfo(
			new UnitTestException(''),
			'levelTest',
			'customMessage'
			);

		LoggingUtils.LogInfo obj6 = new LoggingUtils.LogInfo(
			new UnitTestException(''),
			'levelTest'
			);

		LoggingUtils.LogInfo obj8 = new LoggingUtils.LogInfo(
			new UnitTestException('')
			);

		LoggingUtils.LogInfo obj9 = new LoggingUtils.LogInfo();

		LoggingUtils.LogInfo obj10 = new LoggingUtils.LogInfo(
			'levelTest',
			'levelMessage'
        	);

    }


	private static testMethod void testLimitInfoConstructors() {
		LoggingUtils.LimitInfo obj1 = new LoggingUtils.LimitInfo();
		LoggingUtils.LimitInfo obj2 = new LoggingUtils.LimitInfo('limitType', 0, 10);
	}


	private static testMethod void testTriggerContextInfoConstructors() {
		LoggingUtils.TriggerContextInfo obj1 = new LoggingUtils.TriggerContextInfo();
		LoggingUtils.TriggerContextInfo obj2 = new LoggingUtils.TriggerContextInfo('context', true);
	}

	
	private static testMethod void testStringSnippetsConstructors() {
		String longBeginning = '';
		Integer beginningLength = 255;

		for (Integer i=0; i<beginningLength; i++) {
			longBeginning += 'a';
		}

		String longEnding = '';
		Integer endingLength = 255;
		for (Integer i=0; i<endingLength; i++) {
			longEnding += 'b';
		}
		String longString = longBeginning + longEnding;

		LoggingUtils.StringSnippets snippets = new LoggingUtils.StringSnippets(longString);
		System.assertEquals(beginningLength, snippets.beginning.length());
		System.assertEquals(longBeginning, snippets.beginning);
		System.assertEquals(endingLength, snippets.ending.length());
		System.assertEquals(longEnding, snippets.ending);
	}


    class UnitTestException extends Exception{}
 	   
}