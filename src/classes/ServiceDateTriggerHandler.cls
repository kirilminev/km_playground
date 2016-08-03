public class ServiceDateTriggerHandler implements ITrigger{
    public ServiceDateTriggerHandler(){}

    public void bulkBefore(){}
    public void bulkAfter(){}

    public void beforeInsert(List<SObject> soList){
        ServiceDateService.checkInstallBlackoutDates(soList);
    }

    public void beforeUpdate(Map<Id, SObject> oldSoMap, List<SObject> soList){
        ServiceDateService.checkInstallBlackoutDates((Map<Id, Service_Date__c>) oldSoMap, soList);
    }

    public void beforeDelete(List<SObject> soList){}

    public void afterInsert(List<SObject> soList){
        ServiceDateService.updateFurthestServiceDateInformation(soList);
    }

    public void afterUpdate(Map<Id, SObject> oldSoMap, List<SObject> soList){
        ServiceDateService.updateFurthestServiceDateInformation(soList);
        //ServiceDateService.checkTechnicianStatus((Map<Id, Service_Date__c>) oldSoMap, soList);

    }

    public void afterDelete(List<SObject> soList){
        ServiceDateService.updateFurthestServiceDateInformation(soList);
    }

    public void andFinally(){}
}
