trigger CaseTrigger on Case (before delete, before insert, before update, after delete, after insert, after update) {

	TriggerFactory.createHandler(Case.sObjectType);
}