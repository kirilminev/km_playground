@isTest
private class CaseServiceTest {
	
	private static testmethod void testGetById() {
		Case test = new Case();
		insert test;
		Case result = CaseService.getById(test.Id, new List<String> {'Id'});

		system.assert(test == result);
	}

	private static testmethod void testGetByIds() {
		List<Id> caseIds = new List<Id>();
		List<Case> cases = new List<Case>();
		Case test = new Case();
		insert test;
		caseIds.add(test.Id);
		cases.add(test);
		List<Case> result = CaseService.getByIds(caseIds, new List<String> {'Id'});

		system.assert(result == cases);
	}

	private static testmethod void testGetWithServiceDatesById() {
		Case test = new Case();
		insert test;
		Service_Date__c serviceDate = new Service_Date__c();
		serviceDate.Related_Work_Order__c = test.Id;
		insert serviceDate;
		Case result = CaseService.getWithServiceDatesById(test.Id, new List<String> {'Id'}, new List<String> {'Id'});

		system.assert(test.Id == result.Id);
		system.assert(result.Service_Dates__r.size() == 1);
	}

	private static testmethod void testGetWithServiceDatesByIds() {
		List<Id> caseIds = new List<Id>();
		Case test = new Case();
		insert test;
		Service_Date__c serviceDate = new Service_Date__c();
		serviceDate.Related_Work_Order__c = test.Id;
		insert serviceDate;
		caseIds.add(test.Id);
		List<Case> result = CaseService.getWithServiceDatesByIds(caseIds, new List<String> {'Id'}, new List<String> {'Id'});

		system.assert(result[0].Id == test.Id);
		system.assert(result[0].Service_Dates__r.size() == 1);
	}

	private static testmethod void testGetScopeOfWork() {
		Case workOrder = new Case();
		workOrder.TVs_Being_Installed__c = '1';
		workOrder.Players_Being_Installed__c = '1';
		workOrder.Tablets_Being_Installed__c = '1';
		workOrder.Routers_Being_Installed__c = '1';
		insert workOrder;
		Case installationApproval = new Case();
		installationApproval.IT_Contact_Name__c = 'Bob';
		installationApproval.IT_Phone_Number__c = '1234567890';
		installationApproval.IT_Email_Address__c = 'bob@bob.bob';

		Constants.ScopesOfWork scope = new Constants.ScopesOfWork();
		String scopeOfWork = CaseService.getScopeOfWork('1234', workOrder, installationApproval, 'Special Instructions');

		system.assert(scopeOfWork.contains(scope.IT_CONTACT_NAME));
		system.assert(scopeOfWork.contains(scope.IT_CONTACT_EMAIL));
		system.assert(scopeOfWork.contains(scope.IT_CONTACT_PHONE));
		system.assert(scopeOfWork.contains(scope.SCOPE_SCREENS));
		system.assert(scopeOfWork.contains(scope.SCOPE_PLAYERS));
		system.assert(scopeOfWork.contains(scope.SCOPE_TABLETS));
		system.assert(scopeOfWork.contains(scope.SCOPE_ROUTERS));
		system.assert(scopeOfWork.contains(scope.SPECIAL_INSTRUCTIONS));
	}
}