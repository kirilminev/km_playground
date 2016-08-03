public with sharing class ContractTriggerHandler implements ITrigger {
	public ContractTriggerHandler() {}

	public void bulkBefore(){}
	public void bulkAfter(){}

	public void beforeInsert(List<SObject> soListNew) {}

	public void beforeUpdate(Map<Id, SObject> oldSoMap, List<SObject> soListNew) {}

	public void beforeDelete(List<SObject> soList){}

	public void afterInsert(List<SObject> soList){}

	public void afterUpdate(Map<Id, SObject> oldSoMap, List<SObject> soList){
		ContractService.closeOpportunities((Map<Id, Contract>)oldSoMap, soList);
	}

	public void afterDelete(List<SObject> soList){}

	public void andFinally(){}
}