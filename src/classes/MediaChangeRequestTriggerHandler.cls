
public with sharing class MediaChangeRequestTriggerHandler implements ITrigger {
    public MediaChangeRequestTriggerHandler(){}

    public void bulkBefore(){}
    public void bulkAfter(){}

    public void beforeInsert(List<SObject> soList){}

    public void beforeUpdate(Map<Id, SObject> oldSoMap, List<SObject> soList){
        MediaChangeRequestService.updateAge(soList, (Map<Id, MediaChangeRequest__c>)oldSoMap);
    }

    public void beforeDelete(List<SObject> soList){}

    public void afterInsert(List<SObject> soList){
        MediaChangeRequestService.submitRequests(soList);
    }

    public void afterUpdate(Map<Id, SObject> oldSoMap, List<SObject> soList){}

    public void afterDelete(List<SObject> soList){}

    public void andFinally(){}
}