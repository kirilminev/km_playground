trigger MediaChangeRequestTrigger on MediaChangeRequest__c (before delete, before insert, before update, after delete, after insert, after update) {

	TriggerFactory.createHandler(MediaChangeRequest__c.sObjectType);
}