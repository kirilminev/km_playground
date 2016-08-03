public with sharing class ContactTriggerHandler implements ITrigger{
	public ContactTriggerHandler(){}

	public void bulkBefore(){}
	public void bulkAfter(){}

	public void beforeInsert(List<SObject> newContactList){
		ContactService.calculateQualificationType(newContactList);
	}

	public void beforeUpdate(Map<Id, SObject> oldContactMap, List<SObject> newContactList){
		ContactService.calculateQualificationType(newContactList);
	}

	public void beforeDelete(List<SObject> soList){}

	public void afterInsert(List<SObject> newContactList){
		OpportunityService.calculateQualificationTypeForContacts(newContactList, null);	
	}

	public void afterUpdate(Map<Id, SObject> oldContactMap, List<SObject> newContactList){
		OpportunityService.calculateQualificationTypeForContacts(newContactList, (Map<Id, Contact>)oldContactMap);
	}

	public void afterDelete(List<SObject> newContactList){
		OpportunityService.calculateQualificationTypeForContacts(newContactList, null);	
	}

	public void andFinally(){}
}