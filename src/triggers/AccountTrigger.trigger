trigger AccountTrigger on Account (before delete, before insert, before update, after delete, after insert, after update) {

	TriggerFactory.createHandler(Account.sObjectType);
}