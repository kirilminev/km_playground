trigger ContractTrigger on Contract (before delete, before insert, before update, after delete, after insert, after update) {

	TriggerFactory.createHandler(Contract.sObjectType);
}