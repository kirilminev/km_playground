public with sharing class CaseTriggerHandler implements ITrigger{
	public CaseTriggerHandler(){}

    public void bulkBefore(){}
    public void bulkAfter(){}

    public void beforeInsert(List<SObject> soList){}

    public void beforeUpdate(Map<Id, SObject> oldSoMap, List<SObject> soList){}

    public void beforeDelete(List<SObject> soList){}

    public void afterInsert(List<SObject> soList){
        CaseService.getDeinstallApproval(soList);
    }

    public void afterUpdate(Map<Id, SObject> oldSoMap, List<SObject> soList){
        CaseService.getDeinstallApproval((Map<Id, Case>)oldSoMap, soList);
    }

    public void afterDelete(List<SObject> soList){}

    public void andFinally(){}
}