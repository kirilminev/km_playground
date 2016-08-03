/*******************************************************************************************************
* @description  Utility class to log exceptions to sobject, slack channel, and email
* 
*/

global class LoggingUtils {

    /*******************************************************************************************************
    * @description          Bypass sending to Slack when logging in test context unless specifically set
    *                       to do so in a test.  Avoids callout issues.
    */
    private static Boolean bypassSlackInTestContext = true;
    
    /*******************************************************************************************************
    * @description          Determine if context called is Queueable and calls the appropriate Log method
    * 
    * @param [Exception]    Exception caught
    * 
    * @return               void
    * 
    * @example              try {
    *                           //some code runs here and it fails
    *                       } catch (Exception ex) {
    *                           LoggingUtils.log(ex);
    *                       }
    * 
    */
    global static void log(Exception exceptionCaught) {
        if (System.isQueueable()) {
            executeLog(new logInfo(exceptionCaught), true, false, false);
        } else {
            System.enqueueJob(new QueueableLog(new logInfo(exceptionCaught), true, false, false));
        }
    }

    /*******************************************************************************************************
    * @description          Determine if context called is Queueable and calls the appropriate Log method
    * 
    * @param [Exception]    Exception caught
    * @param [Boolean]      Flag for logging to exception object
    * @param [Boolean]      Flag for logging to Slack
    * @param [Boolean]      Flag for logging to Email.
    * 
    * @return               void
    * 
    * @example              try {
    *                           //some code runs here and it fails
    *                       } catch (Exception ex) {
    *                           LoggingUtils.log(ex, true, true, true);
    *                       }
    * 
    */
    global static void log(Exception exceptionCaught, Boolean logToObject, Boolean logToSlack, Boolean logToEmail) {
        if (System.isQueueable()) {
            executeLog(new logInfo(exceptionCaught), logToObject, logToSlack, logToEmail);
        } else {
            System.enqueueJob(new QueueableLog(new logInfo(exceptionCaught), logToObject, logToSlack, logToEmail));
        }
    }

    /*******************************************************************************************************
    * @description          Determine if context called is Queueable and calls the appropriate Log method
    * 
    * @param [LogInfo]      Value class with logging info.
    * 
    * @return               void
    * 
    * @example              try {
    *                           //some code runs here and it fails
    *                       } catch (Exception ex) {
    *                           LoggingUtils.log(new LoggingUtils.LogInfo(ex));
    *                       }
    * 
    */
    global static void log(LogInfo logInfo) {
        if (System.isQueueable()) {
            executeLog(logInfo, true, false, false);
        } else {
            System.enqueueJob(new QueueableLog(logInfo, true, false, false));
        }
    }

    /*******************************************************************************************************
    * @description          Determine if context called is Queueable and calls the appropriate Log method
    * 
    * @param [LogInfo]      Value class with logging info.
    * @param [Boolean]      Flag for logging to exception object
    * @param [Boolean]      Flag for logging to Slack
    * @param [Boolean]      Flag for logging to Email.
    * 
    * @return               void
    * 
    * @example              try {
    *                           //some code runs here and it fails
    *                       } catch (Exception ex) {
    *                           LoggingUtils.log(new LoggingUtils.LogInfo(ex), true, true, true);
    *                       }
    * 
    */
    global static void log(LogInfo logInfo, Boolean logToObject, Boolean logToSlack, Boolean logToEmail) {
        if (System.isQueueable()) {
            executeLog(logInfo, logToObject, logToSlack, logToEmail);
        } else {
            System.enqueueJob(new QueueableLog(logInfo, logToObject, logToSlack, logToEmail));
        }
    }


    /*******************************************************************************************************
    * @description          Purpose of method is to accept Log Info and add to Async Queue
    * 
    * @param [LogInfo]      Value class with logging info.
    * @param [Boolean]      Flag for logging to exception object
    * @param [Boolean]      Flag for logging to Slack
    * @param [Boolean]      Flag for logging to Email.
    *
    * @return               void
    * 
    */
    public class QueueableLog implements Queueable, Database.AllowsCallouts {
    
        private LogInfo logInfo;
        private Boolean logToObject;
        private Boolean logToSlack;
        private Boolean logToEmail;

        public QueueableLog(LogInfo logInfo, Boolean logToObject, Boolean logToSlack, Boolean logToEmail){
            this.logInfo = logInfo;
            this.logToObject = logToObject;
            this.logToSlack = logToSlack;
            this.logToEmail = logToEmail;
        }

        public void execute(QueueableContext context) {
            executeLog(logInfo, logToObject, logToSlack, logToEmail);
        }
    }


    /*******************************************************************************************************
    * @description          Purpose of this method is to accept Log Info and post to 
    *                       Exception Log object, Slack, Email, or some combination thereof
    * 
    * @param [LogInfo]      Value class with logging info.
    * @param [Boolean]      Flag for logging to exception object
    * @param [Boolean]      Flag for logging to Slack
    * @param [Boolean]      Flag for logging to Email.
    * 
    * @return               void
    * 
    */
    @TestVisible
    private static void executeLog(LogInfo logInfo, Boolean logToObject, Boolean logToSlack, Boolean logToEmail) {

        logToSlack = (Test.isRunningTest() && bypassSlackInTestContext) ? false : logToSlack;
        
        Exception_Log__c logStaged = createLog(logInfo);
        
        List<Exception_Log__c> logsMatched = LoggingService.getMatchingLogs(new list<String>{  'Cause__c',
                                                                                'Cause_Beginning__c',
                                                                                'Cause_Ending__c',
                                                                                'Count__c',
                                                                                'Custom_Message__c',
                                                                                'Level__c',
                                                                                'Limits__c',
                                                                                'Line_Number__c',
                                                                                'Message__c',
                                                                                'Message_Beginning__c',
                                                                                'Message_Ending__c',
                                                                                'Mute_Email__c',
                                                                                'Mute_Slack__c',
                                                                                'Record_Id__c',
                                                                                'Stack_Trace_Beginning__c',
                                                                                'Stack_Trace_Ending__c',
                                                                                'Stack_Trace_String__c',
                                                                                'Trigger_Context__c',
                                                                                'Type_Name__c',
                                                                                'Id'},
                                                                                logStaged);

        
        Boolean dmlFailed = false;
        Boolean emailMuted = false;
        Boolean slackMuted = false;
        
        if (ListUtils.isNotNullOrEmpty(logsMatched)) {
            logStaged = logsMatched[0];

            emailMuted = logsMatched[0].Mute_Email__c;
            slackMuted = logsMatched[0].Mute_Slack__c;

            if (logStaged.Count__c == null) {
                logStaged.Count__c = 2;
            } else {
                logStaged.Count__c++;
            }
        }

        if (logToObject) {
            try {
                upsert logStaged;
            } catch (DmlException dmlException) {
                dmlFailed = true;
                logStaged.Message__c = logStaged.Message__c + '/n' + '*** failed to insert/update Exception Log ***';
            }
        }

        if (dmlFailed || logToEmail && !emailMuted) { // To make sure we have visibility to exceptions if dml failed send via an email by default
            logToEmail(logStaged);
        }

        if (logToSlack && !slackMuted) {
            logToSlack(logStaged);
        }
    }  

    

    /*******************************************************************************************************
    * @description          Create Exception Log record with relevant info
    * 
    * @param [LogInfo]      The LogInfo value class 
    *
    * @return               Exception_Log__c
    */
    @TestVisible
    private static Exception_Log__c createLog(LogInfo logInfo) {

        Exception_Log__c logStaged = new Exception_Log__c(Caught_At__c = logInfo.caughtAt, Count__c = 1);

        logStaged = processExceptionCaught(logInfo, logStaged);

        if (String.isNotEmpty(logInfo.level)) logStaged.Level__c = logInfo.level;
        if (String.isNotEmpty(logInfo.message)) logStaged.Custom_Message__c = logInfo.message;
        
        if (String.isEmpty(logStaged.Record_Id__c) &&  ListUtils.isNotNullOrEmpty(logInfo.recordIds)) {
            logStaged.Record_Id__c = recordsToString(logInfo.recordIds);
        }
        if (ListUtils.isNotNullOrEmpty(logInfo.limits)) {
            logStaged.Limits__c = limitsInfoToString(logInfo.limits);
        }
        if (ListUtils.isNotNullOrEmpty(logInfo.context)) {
            logStaged.Trigger_Context__c = triggerContextInfoToString(logInfo.context);
        }

        return logStaged;
    }


    /*******************************************************************************************************
    * @description                  Send exception to recipents list specified in custom setting
    *
    * @param [Exception_Log__c]     The Exception Log record with the info
    * 
    * @return                       void
    */
    @TestVisible
    private static void logToEmail(Exception_Log__c logStaged) {
        
        String [] recipients = emailRecipients();
        String subject = emailSubject();
        String body = emailBody(logStaged);

        EmailUtils.sendTextEmail(recipients, subject, body);
    }

    /*******************************************************************************************************
    * @description                  Get email recipients from custom setting.  If no custom setting found,
    *                               then default to all active admin users that have an email address.
    *
    * @return                       List<String>
    */
    @TestVisible
    private static List<String> emailRecipients () {
        try {
            if (!String.isEmpty(Logging_Configuration__c.getInstance().Email_Recipients__c)) {
                return Logging_Configuration__c.getInstance().Email_Recipients__c.split(','); 
            } else {
                log(new LogInfo(new LoggingService.LoggingLevels().FATAL, 'No email recipients found in Custom Settings'), true, true, false);
                return null;
            }
        } catch (exception ex) {
            log(new LogInfo(ex, new LoggingService.LoggingLevels().FATAL, 'No email recipients found in Custom Settings'), true, true, false);
            return null;
        }
    }

    /*******************************************************************************************************
    * @description              Get email subject from custom setting.  If no custom setting found,
    *                           then set a default subject.
    *
    * @return                   String
    */
    @TestVisible
    private static String emailSubject(){
        String emailSubject = '';
        if (!String.isEmpty(Logging_Configuration__c.getInstance().Email_Subject__c)) {
            return emailSubject = Logging_Configuration__c.getInstance().Email_Subject__c;
        } else {
            return emailSubject = 'Salesforce Exception Logged'; //default email subject if not specified in custom setting
        }
    }

    /*******************************************************************************************************
    * @description                  Format the email body
    *
    * @param [Exception_Log__c]     Object that has the relevant info to put into the email body
    * 
    * @return                       String
    */
    @TestVisible
    private static String emailBody(Exception_Log__c logStaged){
        String messageReturn = String.isEmpty(logStaged.Message__c) ? '' : '\n';
        String stackTraceReturn = String.isEmpty(logStaged.Stack_Trace_String__c) ? '' : '\n';
        String recordReturn = String.isEmpty(logStaged.Record_Id__c) ? '' : '\n';
        String limitsReturn = String.isEmpty(logStaged.Limits__c) ? '' : '\n';
        String contextReturn = String.isEmpty(logStaged.Trigger_Context__c) ? '' : '\n';
        String dmlReturn = String.isEmpty(logStaged.DML_Info__c) ? '' : '\n';

        String emailBody = '';
        emailBody += 'Salesforce Exception Occurred\n' + 
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
            emailBody += 'See Exception: ' + URL.getSalesforceBaseURL().toExternalForm() + '/' + logStaged.Id;
        }
        return emailBody;
    }


    
    /**************************************************************************************************************
    * @description                      Will accept exception information and it will convert to a Slack message, 
    *                                   then SlackService will post to the specified exception handling Slack channel
    *
    * @param [Exception_Log__c]         This param will hold Exception_Log__c object id so we can include link to the logged exception
    * 
    * @return                           void
    * 
    */
    @TestVisible
    private static void logToSlack(Exception_Log__c logStaged) {

        SlackService.SlackPayload slackPayload = new SlackService.SlackPayload();
        slackPayload.channel = Slack_Integration_Configuration__c.getInstance().Exception_Channel__c;
        slackPayload.text = slackMessage(logStaged);

        logToSlackFuture(EnvironmentUtils.getEnvironmentProperty(slackPayload.channel), SlackService.serializeSlackPayload(slackPayload));
    }

    /**************************************************************************************************************
    * @description                      Will accept exception information and it will format the Slack message
    *
    * @param [Exception_Log__c]         Exception_Log__c with info to include in the message
    * 
    * @return                           String
    * 
    */
    @TestVisible
    private static String slackMessage(Exception_Log__c logStaged) {
        String message = '';

        if (String.isNotEmpty(Slack_Integration_Configuration__c.getInstance().Slack_Exceptions_Hashtag__c)) {
            message += Slack_Integration_Configuration__c.getInstance().Slack_Exceptions_Hashtag__c + '\n';    
        }

        message +=  '*Salesforce ' + logStaged.Type_Name__c + ' Occurred* \n';
        if (String.isNotEmpty(logStaged.Cause__c)) message += '*Cause:* ' + logStaged.Cause__c + '\n';
        if (String.isNotEmpty(LogStaged.Custom_Message__c)) message += '*Message:* ' + logStaged.Custom_Message__c + '\n';
        if (String.isNotEmpty(LogStaged.Stack_Trace_String__c)) message += '*Stack Trace:* ' + logStaged.Stack_Trace_String__c + '\n';
        if (String.isNotEmpty(logStaged.Id)) message += '*<' + URL.getSalesforceBaseURL().toExternalForm() + '/' + logStaged.Id + '|See Exception>*';
        
        return message;
    }

    /**************************************************************************************************************
    * @description          Will enqueue the Slack request in a Future context to allow a callout
    *
    * @param [String]       Slack channel info
    * @param [String]       Slack message info
    * 
    * @return               void
    * 
    */
    @Future (callout=true)
    @TestVisible
    private static void logToSlackFuture(String channel, String message) {
        System.enqueueJob(new SlackService.QueueableSlackCall(channel, 'POST', message));
    }


    
    /*******************************************************************************************************
    * @description              Get all the info around system limits 
    *
    * @return                   List<LimitInfo>
    *
    */
    public static List<LimitInfo> getSystemLimits() {
        List<LimitInfo> limits = new List<LimitInfo>();

        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().AGGREGATE_QUERIES, 
                                    System.Limits.getAggregateQueries(),
                                    System.Limits.getLimitAggregateQueries()));
        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().CALLOUTS, 
                                    System.Limits.getCallouts(),
                                    System.Limits.getLimitCallouts()));
        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().CPU_TIME, 
                                    System.Limits.getCpuTime(),
                                    System.Limits.getLimitCpuTime()));
        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().DATABASE_TIME, 
                                    System.Limits.getDatabaseTime(),
                                    System.Limits.getLimitDatabaseTime()));
        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().DML_ROWS, 
                                    System.Limits.getDmlRows(),
                                    System.Limits.getLimitDmlRows()));
        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().DML_STATEMENTS, 
                                    System.Limits.getDmlStatements(),
                                    System.Limits.getLimitDmlStatements()));
        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().EMAIL_INVOCATIONS, 
                                    System.Limits.getEmailInvocations(),
                                    System.Limits.getLimitEmailInvocations()));
        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().FUTURE_CALLS, 
                                    System.Limits.getFutureCalls(),
                                    System.Limits.getLimitFutureCalls()));
        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().HEAP_SIZE, 
                                    System.Limits.getHeapSize(),
                                    System.Limits.getLimitHeapSize()));
        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().MOBILE_PUSH_APEX_CALLS, 
                                    System.Limits.getMobilePushApexCalls(),
                                    System.Limits.getLimitMobilePushApexCalls()));
        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().QUERIES, 
                                    System.Limits.getQueries(),
                                    System.Limits.getLimitQueries()));
        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().QUERY_LOCATOR_ROWS, 
                                    System.Limits.getQueryLocatorRows(),
                                    System.Limits.getLimitQueryLocatorRows()));
        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().QUERY_ROWS, 
                                    System.Limits.getQueryRows(),
                                    System.Limits.getLimitQueryRows()));
        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().QUEUEABLE_JOBS, 
                                    System.Limits.getQueueableJobs(),
                                    System.Limits.getLimitQueueableJobs()));
        limits.add(new LimitInfo(   new LoggingService.SystemLimitTypes().SOSL_QUERIES, 
                                    System.Limits.getSoslQueries(),
                                    System.Limits.getLimitSoslQueries()));

        return limits;
    }



    /*******************************************************************************************************
    * @description              Process Exception Caught onto an Exception Log record
    *
    * @param [LogInfo] 
    *
    * @return                   Exception_Log__c
    *
    */
    @TestVisible
    private static Exception_Log__c processExceptionCaught(LogInfo logInfo, Exception_Log__c logStaged) {
        if (logInfo.exceptionCaught != null) {
            logStaged.Cause__c = String.valueOf(logInfo.exceptionCaught.getCause());
            if (String.isNotEmpty(logStaged.Cause__c)) {
                StringSnippets snippets = new StringSnippets(logStaged.Cause__c);
                logStaged.Cause_Beginning__c = snippets.beginning;
                logStaged.Cause_Ending__c = snippets.ending;
            }
            if (String.isEmpty(logStaged.Level__c)) {
                logStaged.Level__c = new LoggingService.LoggingLevels().FATAL;  // Default Level value to FATAL
            }
            logStaged.Line_Number__c = logInfo.exceptionCaught.getLineNumber();
            logStaged.Message__c = logInfo.exceptionCaught.getMessage();
            if (String.isNotEmpty(logStaged.Message__c)) {
                StringSnippets snippets = new StringSnippets(logStaged.Message__c);
                logStaged.Message_Beginning__c = snippets.beginning;
                logStaged.Message_Ending__c = snippets.ending;
            }
            logStaged.Stack_Trace_String__c = logInfo.exceptionCaught.getStackTraceString();
            if (String.isNotEmpty(logStaged.Stack_Trace_String__c)) {
                StringSnippets snippets = new StringSnippets(logStaged.Stack_Trace_String__c); 
                logStaged.Stack_Trace_Beginning__c = snippets.beginning;
                logStaged.Stack_Trace_Ending__c = snippets.ending;
            }
            logStaged.Type_Name__c = logInfo.exceptionCaught.getTypeName();
            if (logStaged.Type_Name__c.endsWithIgnoreCase('DmlException')){
                // logStaged.DML_Info__c = dmlExceptionInfoToString(logInfo.exceptionCaught);  //Spring 2016 has problems with certain getDml methods
                if (String.isEmpty(logStaged.Record_Id__c)) {
                    logStaged.Record_Id__c = dmlExceptionRecordIdsToString(logInfo.exceptionCaught);
                }
            }
        } else {
            logStaged.Type_Name__c = 'Log';
        }
        return logStaged; 
    }

    /*******************************************************************************************************
    * @description           Compile dml exception info into a single string
    *
    * @param [Exception]     System.Exception
    *
    * @return                String
    *
    */
    @TestVisible
    private static String dmlExceptionInfoToString(Exception ex) {
        String dmlInfo = 'Count: ' + String.valueOf(ex.getNumDml()) + '\n';
        if (ex.getNumDml() != null && ex.getNumDml()>0) {
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                String fields = '';
                if(ex.getDmlFieldNames(i) != null && ex.getDmlFieldNames(i).size() > 0) {
                    fields = ex.getDmlFieldNames(i).size() == 1 ? ex.getDmlFieldNames(i)[0] : StringUtils.joinStrings(ex.getDmlFieldNames(i),'; ').removeEnd('; ');
                }
                dmlInfo +=  ex.getDmlId(i) + ' at row: ' + ex.getDmlIndex(i) + ', Fields: '  + fields + '\n' +
                            '  Type: ' + String.valueOf(ex.getDmlType(i)) + '  Msg: ' + ex.getDmlMessage(i) + '\n';
                
                // following methods are failing in queueable context in Spring '16':
                // system.debug(ex.getDmlFieldNames(i));
                // system.debug(String.valueOf(ex.getDmlType(i)));
                // system.debug(ex.getDmlMessage(i));
            }
        }
        return dmlInfo.removeEnd('\n');
    }

    /*******************************************************************************************************
    * @description           Compile dml exception record id info into a single string
    *
    * @param [Exception]     System.Exception
    *
    * @return                String
    *
    */
    @TestVisible
    private static String dmlExceptionRecordIdsToString(Exception ex) {

        String dmlRecordIds = '';
        for (Integer i = 0; i < ex.getNumDml(); i++) {
            if (String.isNotEmpty(ex.getDmlId(i))) {
                dmlRecordIds += ex.getDmlId(i) + '\n';
            }
        }
        return dmlRecordIds.removeEnd('\n');
    }


    /*******************************************************************************************************
    * @description              Convert a list of Records into a single string
    *
    * @param [List<String>] 
    *
    * @return                   String
    *
    */
    @TestVisible
    private static String recordsToString(List<String> records) {
        String ids = '';
            for (String s : records) {
                ids += s + '\n'; 
            }
        return ids.removeEnd('\n'); 
    }


    /*******************************************************************************************************
    * @description              Convert a list of LimitsInfo into a single string
    *
    * @param [List<LimitsInfo>] 
    *
    * @return                   String
    *
    */
    @TestVisible
    private static String limitsInfoToString(List<LimitInfo> limitsInfo) {
        String limits = '';
        for (LimitInfo li : limitsInfo) {
            if (li.limitAmount>0) limits += li.limitType + ': ' + li.limitAmount.format() + ' out of ' + li.limitMax.format() + '\n';
        }
        return limits.removeEnd('\n'); 
    }



    /*******************************************************************************************************
    * @description                          Convert a list of TriggerContextInfo into a single string
    *
    * @param [list<TriggerContextInfo>]     
    *
    * @return                               String
    *
    */
    @TestVisible
    private static String triggerContextInfoToString(List<TriggerContextInfo> context) {
        String contexts = '';
        for (TriggerContextInfo tci : context) {
            contexts += tci.contextName + ': ' + BooleanUtils.toStringYesNo(tci.contextSetting) + '\n';
        }
        return contexts.removeEnd('\n');
    }


    /*******************************************************************************************************
    * @description                  Value class to hold data useful for logging and 
    *                               either log to sobject, post to slack, or email or all of it at the same time.
    *
    * @param [exceptionCaught]              The exception object caught in the catch block.
    * @param [String]                       Severity level
    * @param [List<String>]                 List of records which the error was produced on
    * @param [List<LimitInfo>]              List of status of system limits 
    * @param [List<TriggerContextInfo>]     List of trigger contexts
    * @param [String]                       Custom message
    */

    global class LogInfo {
        
        public Datetime caughtAt {get; set;}  // since async job will create record sometime in the future instead of when the exception/log occurred.
        public Exception exceptionCaught {get; set;}
        public String level {get; set;}
        public List<String> recordIds {get; set;}
        public List<LimitInfo> limits {get; set;}
        public List<TriggerContextInfo> context {get; set;}
        public String message {get; set;}
        
        public logInfo() {}

        public logInfo(Exception exceptionCaught) {
            this(exceptionCaught, new LoggingService.LoggingLevels().FATAL, null, null, null, null);
        }

        public logInfo(Exception exceptionCaught, String level) {
            this(exceptionCaught, level, null, null, null, null);
        }

        public logInfo(Exception exceptionCaught, String level, String message) {
            this(exceptionCaught, level, null, null, null, message);
        }

        public logInfo(Exception exceptionCaught, String level, List<String> recordIds) {
            this(exceptionCaught, level, recordIds, null, null, null);
        }

        public logInfo(Exception exceptionCaught, String level, List<String> recordIds, List<LimitInfo> limits) {
            this(exceptionCaught, level, recordIds, limits, null, null);
        }

        public logInfo(Exception exceptionCaught, String level, List<String> recordIds, List<LimitInfo> limits, List<TriggerContextInfo> context) {
            this(exceptionCaught, level, recordIds, limits, context, null);
        }

        public logInfo(Exception exceptionCaught, String level, List<String> recordIds, List<LimitInfo> limits, List<TriggerContextInfo> context, String message) {
            this.caughtAt = system.now();
            this.exceptionCaught = exceptionCaught;
            this.level = level;
            this.recordIds = recordIds;
            this.limits = limits;
            this.context = context;
            this.message = message;
        }

        public logInfo(String level, String message) {
            this(null, level, null, null, null, message);
        }

    }

    
    /*******************************************************************************************************
    * @description      Value class to hold data about System Limits
    *
    */
    global class LimitInfo {
        public String limitType {get; set;}
        public Integer limitAmount {get; set;}
        public Integer limitMax {get; set;}

        public LimitInfo() {}

        public LimitInfo(String limitType, Integer limitAmount, Integer limitMax) {
            this.limitType = limitType;
            this.limitAmount = limitAmount;
            this.limitMax = limitMax;
        }
    }


    /*******************************************************************************************************
    * @description      Value class to hold data about the Trigger Context
    *
    */
    global class TriggerContextInfo{
        public String contextName {get; set;}
        public Boolean contextSetting {get; set;}

        public TriggerContextInfo(){}

        public TriggerContextInfo(String contextName, Boolean contextSetting) {
            this.contextName = contextName;
            this.contextSetting = contextSetting;
        }
    }

    /*******************************************************************************************************
    * @description      Value class to create beginning and ending snippets of a string
    *
    */
    global class StringSnippets{
        public String beginning {get; set;}
        public String ending {get; set;}

        public StringSnippets(String s) {
            this.beginning = s.left(255);
            this.ending = s.right(255);
        }
    }

    
    /*******************************************************************************************************
    * @description     Use this to specify custom exception or throw generic custom exception
    * 
    */
    global class CustomException extends Exception{}
    
}