public with sharing class SlingshotController {
	public SlingshotController() {}

	@RemoteAction
	public static Map<String, Object> getOptions(String referenceNumber) {
		Map<String, Schema.SObjectField> accountFields = Schema.SObjectType.Account.fields.getMap();
		Map<String, Object> result = new Map<String, Object>();

		List<String> clinicSpecialties = new List<String> {};
		for (Schema.PicklistEntry entry : Schema.Account.Network__c.getDescribe().getPicklistValues()) {
			clinicSpecialties.add(entry.getLabel());
		}
		List<String> demographicOptions = new List<String>();
		for (Schema.PicklistEntry entry : Schema.Account.Under17__c.getDescribe().getPicklistValues()) {
			demographicOptions.add(entry.getLabel());
		}
		List<String> facilityTypes = new List<String>();
		for (Schema.PicklistEntry entry : Schema.Account.OfficeType__c.getDescribe().getPicklistValues()) {
			facilityTypes.add(entry.getLabel());
		}
		List<String> providerSpecialties = new List<String>();
		for (Schema.PicklistEntry entry : Schema.Contact.Specialty__c.getDescribe().getPicklistValues()) {
			providerSpecialties.add(entry.getLabel());
		}
		List<String> titles = new List<String>();
		for (Schema.PicklistEntry entry : Schema.Contact.Title__c.getDescribe().getPicklistValues()) {
			titles.add(entry.getLabel());
		}

		Account account;
		if (referenceNumber == null || referenceNumber == '') {
			account = new Account();
		}
		else {
			account = [Select Name, (Select FirstName, LastName, Specialty__c, Title__c From Contacts Where Prescriber__c = true) From Account Where IdGenerator__c =: referenceNumber];
		}
		List<Account> clinics = new List<Account>();
		List<String> clinicFields = new List<String> {'COID__c',
													  'eCW__c',
													  'CompetitorRemoval__c',
													  'CompetitorRemovalNotes__c',
													  'BillingStreet',
													  'BillingState',
													  'BillingCity',
													  'BillingPostalCode',
													  'Clinic_Office_Hours__c',
													  'of_Waiting_Rooms__c',
													  'NumberOfExamRooms__c',
													  'SharedWaitingRoom__c',
													  'SignUpFormCompleted__c',
													  'SpecialContentRequest__c',
													  'Name',
													  'Parent.Name'};

		List<Account> children = AccountService.getWithPrescribersByParentIdsWithOrder(new List<Id> {account.Id}, clinicFields, new List<String> {'FirstName', 'LastName', 'Specialty__c', 'Title__c'}, 'Name');
		while (ListUtils.isNotNullOrEmpty(children)) {
			clinics.addAll(children);

			List<Id> childIds = new List<Id>();
			for (Account child : children) {
				childIds.add(child.Id);
			}
			children = AccountService.getWithPrescribersByParentIdsWithOrder(childIds, clinicFields, new List<String> {'FirstName', 'LastName', 'Specialty__c', 'Title__c'}, 'Name');
		}

		result.put('clinics', clinics);
		result.put('clinicSpecialties', clinicSpecialties);
		result.put('demographics', demographicOptions);
		result.put('facilityTypes', facilityTypes);
		result.put('providerSpecialties', providerSpecialties);
		result.put('quantities', new List<Integer> {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10});
		result.put('schedulableDays', new List<String> {'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'});
		result.put('states', new List<String> {'Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','District Of Columbia','Florida','Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine','Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont','Virginia','Washington','West Virginia','Wisconsin','Wyoming'});
		result.put('titles', titles);
		result.put('waitTimes', new List<String> {'1-10 Minutes', '11-20 Minutes', '21-30 Minutes', '>30 Minutes'});

		return result;
	}

	@RemoteAction
	public static void save(Account account, Contact contact, Case itapproval, Case workorder, List<Contact> providers, Map<String, Boolean> specialties, Map<String, String> scheduledDays) {
		Map<String, Schema.RecordTypeInfo> caseRecordTypes = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName();
		contact.AccountId = account.Id;

		itapproval.AccountId = account.Id;
		itapproval.RecordTypeId = caseRecordTypes.get('IT Approval').getRecordTypeId();
		itapproval.Subject = 'IT Approval';

		workorder.AccountId = account.Id;
		workorder.Product__c = 'TV & PC & Tablet';
		workorder.RecordTypeId = caseRecordTypes.get('Work Orders').getRecordTypeId();
		workorder.Service__c = 'Installation';
		workorder.Subject = '*HCA Installation*';
		workorder.Type = 'New Installation';

		if (scheduledDays != null) {
			String finalScheduledDays = '';
			for (String day : scheduledDays.keySet()) {
				finalScheduledDays += day + ': ' + scheduledDays.get(day) + '\n';
			}
			workorder.RequestedInstallDates__c = finalScheduledDays;
		}
		for (Contact provider : providers) {
			provider.AccountId = account.Id;
		}
		List<String> content = new List<String>();
		for (String specialty : specialties.keySet()) {
			if (specialties.get(specialty)) {
				content.add(specialty);
			}
		}
		if (ListUtils.isNotNullOrEmpty(content)) {
			account.Network__c = String.join(content, ';');
		}

		account.BillingCountryCode = 'US';
		account.SignUpFormCompleted__c = true;
		account.OpenCaptioning__c = true;
		account.Brochure_Shipment_Opt_Out__c = true;
		account.Stage__c = 'Confirmed Unscheduled';

		try {
			update account;

			providers.add(contact);
			upsert providers;

			List<Case> casesToInsert = new List<Case> {itapproval, workorder};
			insert casesToInsert;
		}
		catch(Exception ex) {
			system.debug('caught the exception...');
			system.debug(ex);
			throw ex;
		}
	}
}