@isTest
private class ContactServiceTest {
	
	@testSetup static void setup() {
		TestDataService.setupQualificaitonsCustomSetting();
	}

	private static testMethod void testGetById() {
		Contact contact = new Contact();
		contact.LastName = 'Contact Name';
		insert contact;
		Contact result = ContactService.getById(contact.Id, new List<String> {'LastName'});

		system.assert(result == contact);
	}

	private static testMethod void testGetByIds() {
		List<Id> contactIds = new List<Id>();
		List<Contact> contacts = new List<Contact>();
		Contact contact = new Contact();
		contact.LastName = 'Contact Name';
		insert contact;
		contactIds.add(contact.Id);
		contacts.add(contact);
		List<Contact> result = ContactService.getByIds(contactIds, new List<String> {'LastName'});

		system.assert(result == contacts);
	}

	private static testMethod void testSetContactQualificationType() {
		
		Account account1 = new Account(Name = 'Account Name 1');
		insert account1;

		Contact contact1 = new Contact(AccountId = account1.Id, LastName = 'LastName1', NPI__c = '1111111111', Qualification__c = 'Dermatology;General Health');
		Contact contact2 = new Contact(AccountId = account1.Id, LastName = 'LastName2', NPI__c = '2222222222', Qualification__c = 'Allergy');
		Contact contact3 = new Contact(AccountId = account1.Id, LastName = 'LastName3', NPI__c = '3333333333', Qualification__c = 'Not Qualified');
		Contact contact4 = new Contact(AccountId = account1.Id, LastName = 'LastName4', NPI__c = '4444444444', Qualification__c = null);

		insert new List<Contact>{contact1, contact2, contact3, contact4};

		Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, Qualification_Type__c FROM Contact]);

		System.assertEquals('Specialty', contactsMap.get(contact1.Id).Qualification_Type__c);
		System.assertEquals('PCP', contactsMap.get(contact2.Id).Qualification_Type__c);
		System.assertEquals('None', contactsMap.get(contact3.Id).Qualification_Type__c);
	}

	private static testMethod void testGetAccountContactRolesByContactId() {

		Contact contact1 = new Contact(LastName = 'LastName1');
		insert contact1;

		Account account1 = new Account(Name = 'TestAccount');
		insert account1;

		AccountContactRole accountContactRole1 = new AccountContactRole(AccountId = account1.Id, 
																		ContactId = contact1.Id,
																		Role = 'TestRole123');
		insert accountContactRole1;

		List<AccountContactRole> accountContactRolesList = ContactService.getAccountContactRolesByContactId(contact1.Id, new List<String> {'AccountId',
													                                                                              'ContactId',
													                                                                              'Role'});
		
		System.assertNotEquals(null, accountContactRolesList);											                                                                              
		System.assertEquals(1, accountContactRolesList.size());
		System.assertEquals('TestRole123', accountContactRolesList.get(0).Role);
	}
}