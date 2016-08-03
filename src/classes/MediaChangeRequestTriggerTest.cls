@isTest
private class MediaChangeRequestTriggerTest {
	
	@isTest
	static void testMediaChangeRequestTrigger(){
		Account account = new Account();
		account.Name = 'Test Account';
		insert account;
		MediaChangeRequest__c request = new MediaChangeRequest__c();
		request.Account__c = account.Id;
		request.NeverExpires__c = true;
		request.Submit__c = true;
		request.Subject__c = 'Subject';
		insert request;
	}

	@isTest
	static void testUpdateAge_NullDateAssigned() {
		Account account = new Account(Name = 'Test Account');
		insert account;
		MediaChangeRequest__c request = new MediaChangeRequest__c(Account__c = account.Id,
																  NeverExpires__c = true,
																  Subject__c = 'Subject');
		insert request;

		request.CompletedDate__c = System.now();
		try {
			update request;
			system.assert([Select Id, AgeInBusinessHours__c From MediaChangeRequest__c Where Id =: request.Id].AgeInBusinessHours__c == null);
		}
		catch (DmlException ex) {
			system.assert(false);
		}
	}

	@isTest
	static void testUpdateAge() {
		Account account = new Account(Name = 'Test Account');
		insert account;
		MediaChangeRequest__c request = new MediaChangeRequest__c(Account__c = account.Id,
																  DateAssigned__c = System.now(),
																  NeverExpires__c = true,
																  Subject__c = 'Subject');
		insert request;

		request.CompletedDate__c = System.now();
		try {
			update request;
			system.assert([Select Id, AgeInBusinessHours__c From MediaChangeRequest__c Where Id =: request.Id].AgeInBusinessHours__c != null);
		}
		catch (DmlException ex) {
			system.assert(false);
		}
	}
}