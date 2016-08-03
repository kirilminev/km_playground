/*******************************************************************************************************
* @description 	Test coverage for QualificaitonUtils
* 
*/
@isTest
private class CommissionUtilsTest
{
	@testSetup static void setup() {
		TestDataService.setupCommissionRateCardCustomSetting();
		TestDataService.setupQualificaitonsCustomSetting();
		TestDataService.setupCommissionAcceleratorThresholds();
		TestDataService.setupRoleTeamMaps();
		TestDataService.setupCommissionsCalculatorGlobalSettings();
	}

	@isTest
	private static void testFindHighestPriority() {
		System.assertEquals(1, CommissionUtils.getInstance().findHighestPriority(new List<String>{'Cardio', 'General Health'}));
		System.assertEquals(2, CommissionUtils.getInstance().findHighestPriority(new List<String>{'General Health', 'Allergy'}));
		System.assertEquals(3, CommissionUtils.getInstance().findHighestPriority(new List<String>{'General Health'}));
		System.assertEquals(-1, CommissionUtils.getInstance().findHighestPriority(new List<String>{'Not Qualified'}));
		System.assertEquals(-1, CommissionUtils.getInstance().findHighestPriority(new List<String>{'Not  A Valid Qualification'}));
		System.assertEquals(3, CommissionUtils.getInstance().findHighestPriority(new List<String>{'Not  A Valid Qualification', 'General Health'}));
	}

	@isTest
	private static void setPrioritiesTest() {
		System.assertEquals(3, CommissionUtils.getInstance().lowestPriority);
		System.assertEquals(1, CommissionUtils.getInstance().highestPriority);
	}

	@isTest
	private static void calculateQualificationsInformationForAccountTest() {
		
		Account account1 = new Account(Name = 'Account Name 1');
		insert account1;

		List<Contact> contacts = new List<Contact>();

		contacts.add(new Contact(AccountId = account1.Id, LastName = 'LastName1', NPI__c = '1111111111', Qualification__c = 'Dermatology;General Health')); 
		contacts.add(new Contact(AccountId = account1.Id, LastName = 'LastName2', NPI__c = '2222222222', Qualification__c = 'Allergy'));
		contacts.add(new Contact(AccountId = account1.Id, LastName = 'LastName3', NPI__c = '3333333333', Qualification__c = 'Not Qualified'));
		contacts.add(new Contact(AccountId = account1.Id, LastName = 'LastName4', NPI__c = '4444444444', Qualification__c = 'Cardio')); 
		contacts.add(new Contact(AccountId = account1.Id, LastName = 'LastName5', NPI__c = '4444444445', Qualification__c = 'None'));
		contacts.add(new Contact(AccountId = account1.Id, LastName = 'LastName6', NPI__c = '6666666666', Qualification__c = 'Dermatology;Cardio;General Health'));

		insert contacts;//contacts trigger will calculate qulificaiton type field

		contacts = ContactService.getByIds(new List<Id>(new Map<Id, Contact>(contacts).keySet()), new List<String>{'Id', 'Qualification__c', 'Qualification_Type__c', 'NPI__c'});

		CommissionUtils.QualificationTypeVo qualificationVo = CommissionUtils.getInstance().calculateQualificationsInformationForAccount(contacts);

		System.assertEquals('Specialty', qualificationVo.highestPriorityQualificationType);

		System.assertEquals(2, qualificationVo.numberOfContactPerQualification.get('Cardio'));
		System.assertEquals(2, qualificationVo.numberOfContactPerQualification.get('Dermatology'));
		System.assertEquals(1, qualificationVo.numberOfContactPerQualification.get('Allergy'));
	}

	@isTest
	private static void getCommissionCardRateAmountTest() {

		System.assertEquals(60, CommissionUtils.getInstance().getCommissionCardRateAmount('PES', 'Specialty', 'WIFI'));
		System.assertEquals(120, CommissionUtils.getInstance().getCommissionCardRateAmount('PES', 'Specialty', 'WIFI', 1));
		System.assertEquals(60, CommissionUtils.getInstance().getCommissionCardRateAmount('MSE', 'Specialty', 'WIFI'));
		System.assertEquals(80, CommissionUtils.getInstance().getCommissionCardRateAmount('MSE', 'Specialty', 'WIFI', 1));
		System.assertEquals(160, CommissionUtils.getInstance().getCommissionCardRateAmount('MSE', 'Specialty', 'WIFI', 2));

		Boolean invalidTeamFailed = false;
		Boolean invalidQualificationTypeFailed = false;

		try {
			CommissionUtils.getInstance().getCommissionCardRateAmount('XYZ', 'Specialty', 'WIFI', 2);
		}catch(Exception ex) {
			invalidTeamFailed = true;
		}

		System.assertEquals(true, invalidTeamFailed, 'When given a wrong membership team which does not exist, expected to throw an exception.');

		try {
			CommissionUtils.getInstance().getCommissionCardRateAmount('PES', 'XYZZZZ', 'WIFI', 2);
		}catch(Exception ex) {
			invalidQualificationTypeFailed = true;
		}

		System.assertEquals(true, invalidQualificationTypeFailed, 'When given a wrong qualificaiton type which does not exist, expected to throw an exception.');
	}

	@isTest
	private static void getUserRoleTeamInfoTest() {
		String roleId = '111111111111111222';//18 chars

		Role_Team_Map__c teamRole = new Role_Team_Map__c(Name = StringUtils.left(roleId, 15), Team__c = 'PES', Specialty__c = 'Cardiology', Role_Name__c = 'Cardiology Healthcare Sales');
		insert teamRole;

		System.assertNotEquals(null, CommissionUtils.getInstance().getUserRoleTeamInfo(roleId + '12343423'));
		System.assertEquals(null, CommissionUtils.getInstance().getUserRoleTeamInfo('12343423'));
	}

	@isTest
	private static void assignAcceleratorStageToOpportunityTest() {

		Opportunity opportunityTest = new Opportunity(Accelerator_Stage_1__c = false, Accelerator_Stage_2__c = false);

		CommissionUtils.getInstance().assignAcceleratorStageToOpportunity('PES', 10, opportunityTest);

		System.assertEquals(false, opportunityTest.Accelerator_Stage_1__c);

		CommissionUtils.getInstance().assignAcceleratorStageToOpportunity('PES', 11, opportunityTest);

		System.assertEquals(true, opportunityTest.Accelerator_Stage_1__c);
		System.assertEquals(false, opportunityTest.Accelerator_Stage_2__c);

		CommissionUtils.getInstance().assignAcceleratorStageToOpportunity('MSE', 200, opportunityTest);

		System.assertEquals(false, opportunityTest.Accelerator_Stage_1__c);
		System.assertEquals(true, opportunityTest.Accelerator_Stage_2__c);
	}

	@isTest
	private static void populateEnabledRecordTypeIdsTest() {

		RecordType opportunityMembershipRecordType = RecordTypeService.getByNameAndObjectType('Membership', 'Opportunity', new List<String>{'Id'});
		System.assertNotEquals(null, opportunityMembershipRecordType);
		RecordType opportunitySponsorshipRecordType = RecordTypeService.getByNameAndObjectType('Sponsorship', 'Opportunity', new List<String>{'Id'});
		System.assertNotEquals(null, opportunitySponsorshipRecordType);

		CommissionUtils.getInstance().populateEnabledRecordTypeIds();

		System.assertNotEquals(null, CommissionUtils.getInstance().enabledOpportunityRecordTypeIds);
		System.assertEquals(true, CommissionUtils.getInstance().isOpportunityRecordTypeIdEnabled(opportunityMembershipRecordType.Id), 'Membership record type id expected to be in the list');
		System.assertEquals(true, CommissionUtils.getInstance().isOpportunityRecordTypeIdEnabled(opportunitySponsorshipRecordType.Id), 'Sponsorship record type id expected to be in the list');

		// test with single value in custom setting
		Commissions_Calculator_Global__c customSetting = [Select Id, Enabled_Opportunity_Record_Type_Names__c FROM Commissions_Calculator_Global__c limit 1];
		customSetting.Enabled_Opportunity_Record_Type_Names__c = 'Membership';
		update customSetting;

		CommissionUtils.getInstance().populateEnabledRecordTypeIds();

		System.assertNotEquals(null, CommissionUtils.getInstance().enabledOpportunityRecordTypeIds);
		System.assertNotEquals(0, CommissionUtils.getInstance().enabledOpportunityRecordTypeIds.size());
		System.assertEquals(true, CommissionUtils.getInstance().isOpportunityRecordTypeIdEnabled(opportunityMembershipRecordType.Id), 'Membership record type id expected to be in the list');
	}

	@isTest
	private static void getEligibleOpportunitiesForCommissionTest() {
		
		Account account1 = new Account(Name = 'TEST_ACCOUNT_NAME_1');
		insert account1;

		// test with single value in custom setting
		Commissions_Calculator_Global__c customSetting = [Select Id, Enabled_Opportunity_Record_Type_Names__c FROM Commissions_Calculator_Global__c limit 1];
		customSetting.Enabled_Opportunity_Record_Type_Names__c = 'Membership';
		update customSetting;

		RecordType opportunityMembershipRecordType = RecordTypeService.getByNameAndObjectType('Membership', 'Opportunity', new List<String>{'Id'});
		System.assertNotEquals(null, opportunityMembershipRecordType);
		RecordType opportunitySponsorshipRecordType = RecordTypeService.getByNameAndObjectType('Sponsorship', 'Opportunity', new List<String>{'Id'});
		System.assertNotEquals(null, opportunitySponsorshipRecordType);

		Integer numberOfOpportunitiesToCreate = 10;
		List<Opportunity> opportunities = new List<Opportunity>();

		for (Integer i =0; i < numberOfOpportunitiesToCreate; i++) {
			opportunities.add(new Opportunity(RecordTypeId = opportunityMembershipRecordType.Id, Name = 'Test1', StageName = 'New', CloseDate = Date.Today().addDays(10), AccountId = account1.Id));
		}
		for (Integer i =0; i < numberOfOpportunitiesToCreate; i++) {
			opportunities.add(new Opportunity(RecordTypeId = opportunitySponsorshipRecordType.Id, Name = 'Test1', StageName = 'New', CloseDate = Date.Today().addDays(10), AccountId = account1.Id));
		}
		System.assertEquals(20, opportunities.size());
		System.assertEquals(10, CommissionUtils.getInstance().getEligibleOpportunitiesForCommission(opportunities).size());
	}
}