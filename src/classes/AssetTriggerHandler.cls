public with sharing class AssetTriggerHandler implements ITrigger{
    public AssetTriggerHandler(){}

    public void bulkBefore(){}
    public void bulkAfter(){}

    public void beforeInsert(List<SObject> soList) {}

    public void beforeUpdate(Map<Id, SObject> oldSoMap, List<SObject> soList) {}

    public void beforeDelete(List<SObject> soList){}

    public void afterInsert(List<SObject> soList){}

    public void afterUpdate(Map<Id, SObject> oldSoMap, List<SObject> soList){}

    public void afterDelete(List<SObject> soList){}

    public void andFinally(){}

}