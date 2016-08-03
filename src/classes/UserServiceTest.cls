/*******************************************************************************************************
* @description 	Unit Tests for UserService class
* 
*/
@isTest
private class UserServiceTest {

	@isTest
	private static void getByIdsTest() {

		Integer numberOfUsers = 10;
		Map<Id, User> usersMap = new Map<Id, User>([Select Id, isActive From User Where isActive = true LIMIT :numberOfUsers]);

		System.assertEquals(numberOfUsers, UserService.getByIds(new List<Id> (usersMap.keySet()), new List<String>{'Id', 'isActive'}).size());

	}
}