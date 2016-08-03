public class SignupController {
	public String referenceNumber {
		get {
			return ApexPages.currentPage().getParameters().get('refnum');
		}
	}

	public String termsAndConditions {
		get {
			return '1. Yes, I would like to become a member and receive a free installation of the ContextMedia:Health service for my waiting room at the address listed above. \r\n'
				 + '2. I understand that the ContextMedia:Health devices and products are provided at no cost. \r\n'
				 + '3. I understand that ContextMedia:Health is responsible for all maintenance, replacement, and equipment liability for the systems. \r\n'
				 + '4. I understand that my practice will never be charged fees of any kind to be a member of ContextMedia:Health. \r\n'
				 + '5. I confirm that the data provided above is accurate for my practice to the best of my knowledge. \r\n'
				 + '6. I agree to playing the system(s) during all patient hours. \r\n'
				 + '7. I confirm that the ContextMedia:Health service will be the only TV system in the waiting room and, if applicable, the only tablet and/or digital wallboard in exam room(s). \r\n'
				 + '8. I agree not to remove, relocate, modify, or disrupt the ContextMedia:Health TV system components, tablets, wallboard, or WiFi without prior consent.';
		}
	}

	public String wifiTermsAndConditions {
		get {
			return 'ContextMedia:Health is happy to provide your patients a Wifi access service at your practice. We are sharing our terms and conditions for usage and require you to confirm agreement before we can activate the connection. Please feel free to reach out to your dedicated Member Services Executive at any time with questions. \r\n \r\n'
				 + '1. General \r\n \r\n'
				 + '1.1. These terms and conditions (“Terms”) govern the provision of Services by ContextMedia Health LLC (“ContextMedia”) to your physician practice (“Customer”). You agree that you have the authority to bind Customer to these Terms. “Services” includes the installation and removal of Equipment, the provision of wifi Services to individuals at or near Customer\'s premises, and the provision of any other related Services. \r\n \r\n'
				 + '1.2. Customer agrees that ContextMedia may install Equipment at Customer\'s facilities in order to provide the Services (the “Equipment”). ContextMedia at all times retains ownership of the Equipment. Upon termination of these Terms, Customer will allow ContextMedia to retrieve any the Equipment. \r\n \r\n'
				 + '1.3. Customer agrees that (i) ContextMedia may use Customer’s Internet connection in order to provide the Services and that Customer has all necessary rights to allow ContextMedia to use Customer\'s Internet connection in this manner, (ii) any individual using the Services may use Customer\'s Internet connection, and (iii) that anyone within range of the Equipment has the ability to use the Services. ContextMedia has the right, but no obligation, to control the type or amount of content that individual users of the service consume. ContextMedia has no liability to Customer or any other party for actions of users of the Services. \r\n \r\n'
				 + '1.4. Either ContextMedia or Customer may terminate these Terms at any time upon written notice. Upon termination of these Terms, ContextMedia will discontinue the Service no later than [60] days after notice of termination. \r\n \r\n'
				 + '2. Limited Warranties and Limited Liabilities. \r\n \r\n'
				 + '2.1. The Services and Equipment are furnished by ContextMedia and accepted by Customer “as is” and without any warranty whatsoever. ContextMedia makes no representations or warranties with respect to the foregoing, and ContextMedia disclaims all representations and warranties of any kind or nature, express or implied, arising out of or related to these Terms, the Services, and the Equipment, including, but not limited to, any warranties regarding accuracy, quality, correctness, completeness, comprehensiveness, currency, suitability, system availability, compatibility, merchantability, fitness for a particular purpose, title, non-infringement, or otherwise (irrespective of any course of dealing, custom or usage of trade). \r\n \r\n'
				 + '2.2. In no event shall ContextMedia or its directors, officers, employees, or agents, be liable to Customer for any claim arising from or is relating to these Terms or the Services, under any theory of tort, contract, strict liability or other legal or equitable theory, for (i) any lost profits, lost revenues, lost business opportunities or exemplary, punitive, special, incidental, indirect, consequential or similar damages, each of which is hereby excluded by agreement of the parties, regardless of whether such damages were foreseeable or whether a party has been advised of the possibility of such damages, or (ii) for direct damages in excess of $1,000 per router installed by ContextMedia at Customer\'s premises. \r\n \r\n'
				 + '3. Miscellaneous \r\n \r\n '
				 + 'These Terms are governed by and shall be construed in accordance with the substantive laws of the State of Illinois, without giving effect to the principles of conflict of law thereof. Each party agrees that any proceeding brought by it in any way arising out of these Terms must be brought in state or federal courts located in Cook County, Illinois and each party irrevocably submits to the sole and exclusive jurisdiction of these courts. These Terms constitute the entire agreement of the parties with respect to its subject matter.';
		}
	}

	public SignupController() {}

	@RemoteAction
	public static Map<String, Object> getOptions() {
		Map<String, Schema.SObjectField> accountFields = Schema.SObjectType.Account.fields.getMap();
		Map<String, PatientDemographics__c> demographicSettings = PatientDemographics__c.getAll();
		Map<String, Object> result = new Map<String, Object>();

		List<String> clinicSpecialties = new List<String> {};
		for (Schema.PicklistEntry entry : Schema.Account.Network__c.getDescribe().getPicklistValues()) {
			clinicSpecialties.add(entry.getLabel());
		}
		List<String> demographicOptions = new List<String>();
		for (Schema.PicklistEntry entry : Schema.Account.Under17__c.getDescribe().getPicklistValues()) {
			demographicOptions.add(entry.getLabel());
		}
		Map<String, List<Demographic>> demographics = new Map<String, List<Demographic>>();
		for (String specialty : clinicSpecialties) {
			List<Demographic> specialtyDemographics = new List<Demographic>();
			if (demographicSettings.get(specialty) != null) {
				for (String fieldName : demographicSettings.get(specialty).FieldNames__c.split(',')) {
					specialtyDemographics.add(new Demographic(accountFields.get(fieldName).getDescribe().getLabel(), fieldName, demographicOptions));
				}
			}
			demographics.put(specialty, specialtyDemographics);
		}
		List<Demographic> generalDemographics = new List<Demographic>();
		for (String fieldName : demographicSettings.get('All').FieldNames__c.split(',')) {
			generalDemographics.add(new Demographic(accountFields.get(fieldName).getDescribe().getLabel(), fieldName, demographicOptions));
		}
		demographics.put('All', generalDemographics);

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

		result.put('clinicSpecialty', clinicSpecialties);
		result.put('demographics', demographics);
		result.put('facilityType', facilityTypes);
		result.put('providerSpecialty', providerSpecialties);
		result.put('state', new List<String> {'Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','District Of Columbia','Florida','Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine','Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont','Virginia','Washington','West Virginia','Wisconsin','Wyoming'});
		result.put('title', titles);
		result.put('waitTimes', new List<String> {'1-10 Minutes', '11-20 Minutes', '21-30 Minutes', '>30 Minutes'});

		return result;
	}

	@RemoteAction
	public static String save(Account account, Contact contact, List<Provider> providers) {
		Map<String, Schema.RecordTypeInfo> accountRecordTypes = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName();
		if(account.Id == null) {
			account.RecordTypeId = accountRecordTypes.get(new Constants.AccountRecordTypes().MEMBER_OUTREACH).getRecordTypeId();
		}
		system.debug(account);
		system.debug(contact);
		system.debug(providers);
		List<Contact> contactsToInsert = new List<Contact>();
		try {
			account.BillingCountryCode = 'US';
			upsert account;
			contact.AccountId = account.Id;
			contactsToInsert.add(contact);
			for (Provider provider : providers) {
				contactsToInsert.add(new Contact(AccountId = account.Id, FirstName = provider.firstName, LastName = provider.lastName, Specialty__c = provider.specialty, Title__c = provider.title));
			}
			insert contactsToInsert;
		}
		catch(Exception ex) {
			LoggingUtils.log(new LoggingUtils.LogInfo(ex, new LoggingService.LoggingLevels().FATAL, 'Member Application Error'), true, true, true); // add account, contact, providers info?
			return ex.getMessage();
		}
		return 'Success!';
	}

	public class Demographic {
		public String label {get;set;}
		public String name {get;set;}
		public List<String> options {get;set;}
		public Demographic(String label, String name, List<String> options) {
			this.label = label;
			this.name = name;
			this.options = options;
		}
	}

	public class Provider {
		public String firstName {get;set;}
		public String lastName {get;set;}
		public String specialty {get;set;}
		public String title {get;set;}
	}
}