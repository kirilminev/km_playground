trigger ContactTrigger on Contact (before delete, before insert, before update, after delete, after insert, after update) {

	TriggerFactory.createHandler(Contact.sObjectType);
}