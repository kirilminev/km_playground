/*******************************************************************************************************
* @description 		Class will execute the first of every month and it will reset all users 
*					field Number_of_Opp_Closed_Won_Current_Month__c to 0 for all users
* @example			You can use the below code snippet and execute in dev console to schedule job.
*            		
*            		String cronExpression = '0 0 0 1 1/1 ? *';//first of every month @12:00 AM
*  
*					System.Schedule('User Monthly Close Opportunities Reset Job', 
*									cronExpression, 
*					                new UserMonthlyClosedOpportunitiesReset());		          
* 
*/
global class UserMonthlyClosedOpportunitiesReset implements Schedulable {
	
	global void execute(SchedulableContext sc) {
		try {
			
			List<User> users = [Select Id, Number_of_Opp_Closed_Won_Current_Month__c FROM User WHERE isActive = true];

			for (User user :users) {
				user.Number_of_Opp_Closed_Won_Current_Month__c = 0;
			}

			update users;

		}catch (Exception ex) {
			LoggingUtils.log(ex, true, true, true);
		}
	}
}