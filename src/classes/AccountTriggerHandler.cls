public with sharing class AccountTriggerHandler implements ITrigger{
    public AccountTriggerHandler(){}

    private Map<String, Id> zipCodeNameToId = new Map<String, Id>();

    public void bulkBefore(){
        if (Trigger.isInsert || Trigger.isUpdate) {
            this.zipCodeNameToId = AccountService.getDmaZipCodeMapForAccountBillingCodes(Trigger.new);    
        }
    }
    public void bulkAfter(){}

    public void beforeInsert(List<SObject> newSoList){
        AccountService.populateDmaZipCode((List<Account>)newSoList, this.zipCodeNameToId);
    }

    public void beforeUpdate(Map<Id, SObject> oldSoMap, List<SObject> newSoList){
        AccountService.populateDmaZipCode((List<Account>)newSoList, this.zipCodeNameToId);
    }

    public void beforeDelete(List<SObject> soList){}

    public void afterInsert(List<SObject> noldSoList){}

    public void afterUpdate(Map<Id, SObject> oldSoMap, List<SObject> soList){
        AccountService.addGrowthSponsors((Map<Id, Account>)oldSoMap, (List<Account>)soList);
        AccountService.createInstallationApprovals((Map<Id, Account>)oldSoMap, (List<Account>)soList);
    }

    public void afterDelete(List<SObject> soList){}

    public void andFinally(){}
}