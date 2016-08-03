trigger ServiceDateTrigger on Service_Date__c (before delete, before insert, before update, after delete, after insert, after update) {

	TriggerFactory.createHandler(Service_Date__c.sObjectType);
}