@isTest
private class SignupTest {

	private static testmethod void testSignup() {
		SignupController controller = new SignupController();
		String terms = controller.wifiTermsAndConditions;
	}

	private static testmethod void testSignup2() {
		PatientDemographics__c demographics = new PatientDemographics__c(Name = 'All', FieldNames__c = 'Under17__c');
		insert demographics;
		Map<String, Object> options = SignupController.getOptions();
	}

	private static testmethod void testSignup3() {
		SignupController.save(new Account(Name = 'WHATEVER'), new Contact(FirstName = 'Name', LastName = 'Name', Title__c = 'Title', Specialty__c = 'Specialty'), new List<SignupController.Provider>{});
	}
}