
/*******************************************************************************************************
* @description  Unit test Coverage for UserMonthlyClosedOpportunitiesReset schedulable class
* 
* 
*/
@isTest
public class UserMonthlyClosedOpportunitiesResetTest {
	
	/* first of every month @12:00 AM, for unit test this will execute afet Test.stopTest() method */
	private static String cronExpression = '0 0 0 1 1/1 ? *';


	@isTest
	private static void testExecute() {
		
		Test.startTest();

		List<User> users = [Select Id, Number_of_Opp_Closed_Won_Current_Month__c From User Where isActive = true];

		for (User user :users) {
			user.Number_of_Opp_Closed_Won_Current_Month__c = 10;
		}

		update users;

		users = [Select Id, Number_of_Opp_Closed_Won_Current_Month__c From User Where isActive = true];

		for (User user :users) {
			System.assertEquals(10, user.Number_of_Opp_Closed_Won_Current_Month__c);
		}

		String jobId = System.Schedule('User Monthly Close Opportunities Reset Job', 
						cronExpression, 
		                new UserMonthlyClosedOpportunitiesReset());	
		
      	CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

   
      	System.assertEquals(cronExpression, cronTrigger.CronExpression);

		Test.stopTest();

		users = [Select Id, Number_of_Opp_Closed_Won_Current_Month__c From User Where isActive = true];

		for (User user :users) {
			System.assertEquals(0, user.Number_of_Opp_Closed_Won_Current_Month__c);
		}

	}
}