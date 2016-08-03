public class LoggingService {
	
	private static final String EXCEPTION_LOG_OBJECT = 'Exception_Log__c';

	/*******************************************************************************************************
    * @description                  Query for matching Exception Log records
    *
    * @param [List<String>]         Fields of interest from the Exception_Log__c object 
    * @param [Exception_Log__c]     The new Exception Log record to match against
    *
    * @return                       List<Exception_Log__c>
    */
    
    public static List<Exception_Log__c> getMatchingLogs(List<String> exceptionLogFields, Exception_Log__c logStaged) {
        String soql = new SoqlBuilder()
                            .selectx(exceptionLogFields)
                            .fromx(EXCEPTION_LOG_OBJECT)
                            .wherex(new AndCondition()
                                // **** NOTE: cannot include long text areas in WHERE clause, such as Cause__c, Message__c, Stack_Trace_String__c ****
                                .add(new FieldCondition('Cause_Beginning__c').equals(logStaged.Cause_Beginning__c))
                                .add(new FieldCondition('Cause_Ending__c').equals(logStaged.Cause_Ending__c))
                                .add(new FieldCondition('Custom_Message__c').equals(logStaged.Custom_Message__c))
                                .add(new FieldCondition('Level__c').equals(logStaged.Level__c))
                                .add(new FieldCondition('Line_Number__c').equals(logStaged.Line_Number__c))
                                .add(new FieldCondition('Message_Beginning__c').equals(logStaged.Message_Beginning__c))
                                .add(new FieldCondition('Message_Ending__c').equals(logStaged.Message_Ending__c))
                                .add(new FieldCondition('Stack_Trace_Beginning__c').equals(logStaged.Stack_Trace_Beginning__c))
                                .add(new FieldCondition('Stack_Trace_Ending__c').equals(logStaged.Stack_Trace_Ending__c))
                                .add(new FieldCondition('Trigger_Context__c').equals(logStaged.Trigger_Context__c))
                                .add(new FieldCondition('Type_Name__c').equals(logStaged.Type_Name__c)))
                            .orderByx(new OrderBy('CreatedDate').descending())
                            .toSoql();
        return Database.query(soql);
    }


    public class LoggingLevels {
		public final String DEBUG = 'Debug';
		public final String INFO = 'Info';
		public final String ERROR = 'Error';
		public final String WARN = 'Warn';
		public final String FATAL = 'Fatal';
		public final String ALL = 'All';
	}


	public class SystemLimitTypes {
		public final String AGGREGATE_QUERIES = 'Aggregate Queries';
		public final String ASYNC_CALLS = 'Async Calls';  // reserved for future use
		public final String CALLOUTS = 'Callouts';
		public final String CPU_TIME = 'CPU Time';
		public final String DATABASE_TIME = 'Database Time';
		public final String DML_ROWS = 'DML Rows';
		public final String DML_STATEMENTS = 'DML Statements';
		public final String EMAIL_INVOCATIONS = 'Email Invocations';
		public final String FIND_SIMILAR_CALLS = 'Find Similar Calls';  // Deprecated... use SOSL Queries instead
		public final String FUTURE_CALLS = 'Future Calls';
		public final String HEAP_SIZE = 'Heap Size';
		public final String MOBILE_PUSH_APEX_CALLS = 'Mobile Push Apex Calls';
		public final String QUERIES = 'Queries';
		public final String QUERY_LOCATOR_ROWS = 'Query Locator Rows';
		public final String QUERY_ROWS = 'Query Rows';
		public final String QUEUEABLE_JOBS = 'Queueable Jobs';
		public final String SOSL_QUERIES = 'Sosl Queries';
	}


    public class TriggerContextTypes {
		public final String IS_AFTER = 'IsAfter';
		public final String IS_BEFORE = 'IsBefore';
		public final String IS_DELETE = 'IsDelete';
		public final String IS_EXECUTING = 'IsExecuting';
		public final String IS_INSERT = 'IsInsert';
		public final String IS_UNDELETE = 'IsUndelete';
		public final String IS_UPDATE = 'IsUpdate';
	}
}