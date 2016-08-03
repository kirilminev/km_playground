public with sharing class OpportunityTriggerHandler implements ITrigger {
	public OpportunityTriggerHandler() {}

	public void bulkBefore(){}
	public void bulkAfter(){}

	public void beforeInsert(List<SObject> soListNew) {
		OpportunityService.updateCommissionRateFieldsForOwner(soListNew, null);
		OpportunityService.calculateQualificationTypeForOpportunities(soListNew, null);
	}

	public void beforeUpdate(Map<Id, SObject> oldSoMap, List<SObject> soListNew) {
		OpportunityService.updateCommissionRateFieldsForOwner(soListNew, (Map<Id, Opportunity>)oldSoMap);
		OpportunityService.calculateQualificationTypeForOpportunities(soListNew, (Map<Id, Opportunity>)oldSoMap);
		OpportunityService.updateOpportunitiesCounterForUser(soListNew, (Map<Id, Opportunity>)oldSoMap);
		OpportunityService.syncContracts(soListNew, (Map<Id, Opportunity>)oldSoMap);
		OpportunityService.accountSquadAssignmentForClosedWonOpportunities(soListNew, (Map<Id, Opportunity>)oldSoMap);
	}

	public void beforeDelete(List<SObject> soList){}

	public void afterInsert(List<SObject> soListNew){
		CommissionService.updateCommissionEntries(soListNew, null);
	}

	public void afterUpdate(Map<Id, SObject> oldSoMap, List<SObject> soListNew){
		OpportunityLineItemService.calculateProductsCommissionAmount(soListNew);
		CommissionService.updateCommissionEntries(soListNew, (Map<Id, Opportunity>)oldSoMap);
	}

	public void afterDelete(List<SObject> soList){}

	public void andFinally(){}
}