trigger AssetTrigger on Asset (before delete, before insert, before update, after delete, after insert, after update) {

	TriggerFactory.createHandler(Asset.sObjectType);
}