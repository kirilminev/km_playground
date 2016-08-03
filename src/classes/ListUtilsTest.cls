@isTest
private class ListUtilsTest {
	
	private static testmethod void testIsNullOrEmpty() {
		List<String> nullStringList;
		System.assert(ListUtils.isNullOrEmpty(nullStringList));
		System.assert(!ListUtils.isNotNullOrEmpty(nullStringList));
		System.assert(ListUtils.isNullOrEmpty(new List<String> {}));
		System.assert(ListUtils.isNotNullOrEmpty(new List<String> { '' }));
		System.assert(!ListUtils.isNullOrEmpty(new List<String> { '' }));

		List<Id> nullIdList;
		System.assert(ListUtils.isNullOrEmpty(nullIdList));
		System.assert(!ListUtils.isNotNullOrEmpty(nullIdList));
		System.assert(ListUtils.isNullOrEmpty(new List<Id> {}));
		System.assert(ListUtils.isNotNullOrEmpty(new List<Id> { '001L000000VwwyH' }));
		System.assert(!ListUtils.isNullOrEmpty(new List<Id> {'001L000000VwwyH' }));

		List<Account> nullAccountList;
		Account account = new Account();
		System.assert(ListUtils.isNullOrEmpty(nullAccountList));
		System.assert(!ListUtils.isNotNullOrEmpty(nullAccountList));
		System.assert(ListUtils.isNullOrEmpty(new List<Account> {}));
		System.assert(ListUtils.isNotNullOrEmpty(new List<Account> { account }));
		System.assert(!ListUtils.isNullOrEmpty(new List<Account> { account }));

		List<Service_Date__c> nullServiceDateList;
		Service_Date__c serviceDate = new Service_Date__c();
		System.assert(ListUtils.isNullOrEmpty(nullServiceDateList));
		System.assert(!ListUtils.isNotNullOrEmpty(nullServiceDateList));
		System.assert(ListUtils.isNullOrEmpty(new List<Service_Date__c> {}));
		System.assert(ListUtils.isNotNullOrEmpty(new List<Service_Date__c> { serviceDate }));
		System.assert(!ListUtils.isNullOrEmpty(new List<Service_Date__c> { serviceDate }));

		List<Case> nullCaseList;
		Case workOrder = new Case();
		System.assert(ListUtils.isNullOrEmpty(nullCaseList));
		System.assert(!ListUtils.isNotNullOrEmpty(nullCaseList));
		System.assert(ListUtils.isNullOrEmpty(new List<Case> {}));
		System.assert(ListUtils.isNotNullOrEmpty(new List<Case> { workOrder }));
		System.assert(!ListUtils.isNullOrEmpty(new List<Case> { workOrder }));

		List<ContextMedia_Product__c> nullProductList;
		ContextMedia_Product__c product = new ContextMedia_Product__c();
		System.assert(ListUtils.isNullOrEmpty(nullProductList));
		System.assert(!ListUtils.isNotNullOrEmpty(nullProductList));
		System.assert(ListUtils.isNullOrEmpty(new List<ContextMedia_Product__c> {}));
		System.assert(ListUtils.isNotNullOrEmpty(new List<ContextMedia_Product__c> { product }));
		System.assert(!ListUtils.isNullOrEmpty(new List<ContextMedia_Product__c> { product }));
	}

	private static testmethod void testDeDuplicate() {
		List<String> stringListWithDuplicates = new List<String> { '1', '2', '3', '1' };
		stringListWithDuplicates = ListUtils.deDuplicate(stringListWithDuplicates);
		System.assert(stringListWithDuplicates.size() == 3);

		List<Id> idListWithDuplicates = new List<Id> { '001L000000VwwyH', '001L000000VwwyH', '001L000000Vwx0C' };
		idListWithDuplicates = ListUtils.deDuplicate(idListWithDuplicates);
		System.assert(idListWithDuplicates.size() == 2);
	}

	private static testmethod void testGetStringToQuantitiesMap() {
		Map<String, Integer> stringToQuantitiesMap;

		List<String> stringList;
		stringToQuantitiesMap = ListUtils.getStringToQuantitiesMap(stringList);
		System.assert(stringToQuantitiesMap == null);

		stringList = new List<String>();
		stringList.add('item');
		stringToQuantitiesMap = ListUtils.getStringToQuantitiesMap(stringList);
		System.assert(stringToQuantitiesMap.get('item') == 1);

		stringList.add('item');
		stringToQuantitiesMap = ListUtils.getStringToQuantitiesMap(stringList);
		System.assert(stringToQuantitiesMap.get('item') == 2);

		stringList.add('item ');
		stringToQuantitiesMap = ListUtils.getStringToQuantitiesMap(stringList);
		System.assert(stringToQuantitiesMap.get('item ') == 1);
	}
}