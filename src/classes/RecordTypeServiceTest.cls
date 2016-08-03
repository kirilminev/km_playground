/*******************************************************************************************************
* @description  Test Unit Coverage for RecordTypeService class
* 
*/
@isTest
public class RecordTypeServiceTest {
	
	@isTest
	private static void getByNamesAndObjectTypeWithDescribeTest() {

		List<Exception_Log__c> exceptions = [Select Id From Exception_Log__c];

		System.assertEquals(0, exceptions.size(), 'Exception_Log__c table expected to be empty.');

		RecordType opportunityMembershipRecordType = RecordTypeService.getByNameAndObjectType('Membership', 'Opportunity', new List<String>{'Id'});

		List<String> opportunityRecordTypeNames = new List<String>{'Membership', 'Sponsorship', 'Junk Type'};

		Map<String, Id> recordTypesMap = RecordTypeService.getByNamesAndObjectTypeWithDescribe('Opportunity', opportunityRecordTypeNames);

		System.assertNotEquals(null, recordTypesMap, 'recordTypesMap expected to be non-null value');
		System.assertEquals(2, recordTypesMap.size(), 'Expected 2 record types to be returned, returned ' + recordTypesMap.size() + ' instead!');		
		System.assertEquals(opportunityMembershipRecordType.Id, recordTypesMap.get('Membership'), 'Expected membership record type id');
		System.assertNotEquals(null, recordTypesMap.get('Sponsorship'));
		System.assertEquals(null, recordTypesMap.get('Junk Type'));

		recordTypesMap = RecordTypeService.getByNamesAndObjectTypeWithDescribe('Opportunity', null);

		System.assertEquals(null, recordTypesMap);

		recordTypesMap = RecordTypeService.getByNamesAndObjectTypeWithDescribe('BadObjectName_zz_c', null);
		System.assertEquals(null, recordTypesMap);

		exceptions = [Select Id From Exception_Log__c];

		System.assertEquals(1, exceptions.size(), 'Previous method should have failed and logged an exception.');

	}

}