/*******************************************************************************************************
* @description  Service Class to expose services for the User object
* 
*/
public with sharing class UserService {
	
	private static final String USERx = 'User';

	public static List<User> getByIds(List<String> userIds, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(USERx)
						  .wherex(new SetCondition('Id').inx(userIds))
						  .toSoql();
		return Database.query(soql);
	}
}