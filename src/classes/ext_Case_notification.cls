public with sharing class ext_Case_notification {
    public Case cse {get;set;}
    public List<Case> caselist{get;set;}
    public ext_Case_notification (ApexPages.StandardController controller) {
       caselist=new List<Case>();
       this.cse = (Case)controller.getRecord();
       case CurrentCase=[select id,accountid from case where id=:cse.id];
       caselist=[select id,type,subject,casenumber,lastmodifieddate,createddate,Tablets_Impacted__c from case where accountid=:CurrentCase.accountid and isclosed=false and id <> :cse.id];
       
       } 

}