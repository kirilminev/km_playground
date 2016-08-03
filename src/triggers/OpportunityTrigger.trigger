trigger OpportunityTrigger on Opportunity (before delete, before insert, before update, after delete, after insert, after update) {

	TriggerFactory.createHandler(Opportunity.sObjectType);
}