public without sharing class ContactService {

	private static final String ACCOUNTCONTACTROLEx = 'AccountContactRole';
	private static final String CONTACTx = 'Contact';
	private static final String ACCOUNTx = 'Account';
	private static final String CONTACTSx = 'Contacts';

	public static Contact getById(Id contactId, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(CONTACTx)
						  .wherex(new FieldCondition('Id').equals(contactId))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Contact> getByIds(List<Id> contactIds, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(CONTACTx)
						  .wherex(new SetCondition('Id').inx(contactIds))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<AccountContactRole> getAccountContactRolesByContactId(Id contactId, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(ACCOUNTCONTACTROLEx)
						  .wherex(new FieldCondition('ContactId').equals(contactId))
						  .toSoql();
		return Database.query(soql);
	}

	/*******************************************************************************************************
	* @description   Return a map of accountId as the key and a list of related Accounts with NPI contacts as the list
	* 
	* @return 		[Map<Id, Account>]
	* 
	*/
	public static Map<Id, Account> getNpiContactForAccountIds(List<Id> accountIds, List<String> accountFields, List<String> contactFields){
		
		String soql = new SoqlBuilder()
						    .selectx(accountFields)
					    	.selectx(
						        new SoqlBuilder()
						        	.selectx(contactFields)
						    		.fromx(CONTACTSx))
						    		.wherex(new FieldCondition('Npi__c').notEquals(null))
						    .fromx(ACCOUNTx)
						    .wherex(new SetCondition('Id').inx(accountIds))
						    .toSoql();
		
		List<Account> accounts = Database.query(soql);

		if (ListUtils.isNotNullOrEmpty(accounts)) {
			return new Map<Id, Account>(accounts);
		}
		return null;
	}

	/*******************************************************************************************************
	* @description 		Method updates Contact.Qualification_Type__c picklist field based on the ; delimitted
	*                	values in the Contact.Qualification__c field. It determines what qualification type
	*                	is by the mappings in Custom Setting Qualificaiton__c where we also have priorities
	*                	setup for each qualification and qualificaiton type
	* 
	* @param 			[List<Contact>] List of contacts source from before insert/update trigger context 
	* @return 			void
	* 
	*/
	public static void calculateQualificationType(List<Contact> newContactsList) {
		for (Contact contact :newContactsList) {
			if (contact.NPI__c != null && String.isNotEmpty(contact.Qualification__c)) {
				setQualificationTypeForContact(contact, contact.Qualification__c.split(';'));
			}
		}
	}

	/*******************************************************************************************************
	* @description 		Method sets the Qualification Type field for given list of qulificaitons and a contact
	* 
	*/
	@TestVisible
	private static void setQualificationTypeForContact(Contact contact, List<String> qualifications) {
		Integer highestPriority = CommissionUtils.getInstance().findHighestPriority(qualifications);
		contact.Qualification_Type__c = CommissionUtils.getInstance().priorityToQualificationTypeMap.get(highestPriority);
	}
}