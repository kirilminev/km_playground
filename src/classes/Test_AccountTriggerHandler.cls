/*
 * Created By : Lister Technologies
 * Purpose : To Test the account trigger handler.
             

*/
@isTest (SeeAllData=true)
public class Test_AccountTriggerHandler {

        public static testMethod void testMyController1() {
        List<Recordtype> rtypelist=[Select id,name from recordtype where sobjecttype='Account'];
        id memberservice;
        id memberoutreach;
        for(recordtype iterRT : rtypelist){
                 if(iterRT.name=='Member Outreach')
                     memberoutreach=iterRT.id;
                 else if(iterRT.name=='Member Services')
                     memberservice=iterRT.id;    
        }
        ID usrid=UserInfo.getUserId(); 
        Zip_Code_Data__c zcode=new Zip_Code_Data__c(Name='123',OFFSET_DST__c=-1,OFFSET_ST__c=-1,Timezone__c='Eastern');
        insert zcode;
        date myDate = date.newInstance(2014, 6, 1);
        date newDate = mydate.addDays(2);
        Account acc=new Account(Name='Test Account',DMA_Zip_Code__c=zcode.id,recordtypeid=memberoutreach,onboarding_specialist__c=usrid,Stage__c='WaitList',DateofInitialOperation__c=myDate ,Init_touch_Date__c=newDate,Network__c='Diabetes');
        insert acc;
        Event evt=new Event(WhatId=acc.id,subject='Call',EndDateTime=Datetime.parse('12/31/2013 1:00 AM'),StartDateTime=Datetime.parse('12/31/2013 1:00 AM'));
        insert evt;

        /*
        List<RecordType> rtype=new List<RecordType>();
        rtype=[select id from recordtype where name='Member Services' and sobjecttype='Task'];
        if(!rtype.isEmpty()){
        Task tsk=new Task (WhatId=acc.id,subject='Call',status='Completed',priority='Normal',recordtypeid=rtype[0].id);
        insert tsk;
        }
        zcode.Timezone__c='Western';
        update zcode;
        */
        acc.name='Test Account Modified';
        acc.recordtypeid=memberservice;
        
        update acc;
        }
        
        
        
        public static testMethod void testMyController2() {
        List<Recordtype> rtypelist=[Select id,name from recordtype where sobjecttype='Account'];
        id memberservice;
        id memberoutreach;
        for(recordtype iterRT : rtypelist){
                 if(iterRT.name=='Member Outreach')
                     memberoutreach=iterRT.id;
                 else if(iterRT.name=='Member Services')
                     memberservice=iterRT.id;    
        }
        ID usrid=UserInfo.getUserId(); 
        Zip_Code_Data__c zcode=new Zip_Code_Data__c(Name='xyztest',OFFSET_DST__c=-1,OFFSET_ST__c=-1,Timezone__c='Eastern');
        insert zcode;
        date myDate = date.newInstance(2014, 6, 1);
        date newDate = mydate.addDays(2);
        Account acc=new Account(Name='Test CMH ID Account',DMA_Zip_Code__c=zcode.id,recordtypeid=memberoutreach,onboarding_specialist__c=usrid,Stage__c='WaitList',DateofInitialOperation__c=myDate ,Network__c='Rheumatoid'  );
        insert acc;
        acc.recordtypeid=memberservice;
        
        update acc;
        List <Case> cselist=[select id from case where accountid=:acc.id ];
        delete cselist;
        
        delete acc;
          
        
        }
        public static testMethod void testMyController3() {
        List<Recordtype> rtypelist=[Select id,name from recordtype where sobjecttype='Account'];
        id memberservice;
        id memberoutreach;
        for(recordtype iterRT : rtypelist){
                 if(iterRT.name=='Member Outreach')
                     memberoutreach=iterRT.id;
                 else if(iterRT.name=='Member Services')
                     memberservice=iterRT.id;    
        }
        ID usrid=UserInfo.getUserId(); 
        Zip_Code_Data__c zcode=new Zip_Code_Data__c(Name='xyztest',OFFSET_DST__c=-1,OFFSET_ST__c=-1,Timezone__c='Eastern');
        insert zcode;
        date myDate = date.newInstance(2014, 6, 1);
        date newDate = mydate.addDays(2);
        Account acc=new Account(Name='Test CMH ID Account',DMA_Zip_Code__c=zcode.id,recordtypeid=memberoutreach,onboarding_specialist__c=usrid,Stage__c='WaitList',DateofInitialOperation__c=myDate ,Network__c='GI'  );
        insert acc;
        acc.recordtypeid=memberservice;
        
        update acc;
        List <Case> cselist=[select id from case where accountid=:acc.id ];
        delete cselist;
        
        delete acc;
          
        
        }
        
        public static testMethod void testMyController4() {
        List<Recordtype> rtypelist=[Select id,name from recordtype where sobjecttype='Account'];
        id memberservice;
        id memberoutreach;
        for(recordtype iterRT : rtypelist){
                 if(iterRT.name=='Member Outreach')
                     memberoutreach=iterRT.id;
                 else if(iterRT.name=='Member Services')
                     memberservice=iterRT.id;    
        }
        ID usrid=UserInfo.getUserId(); 
        Zip_Code_Data__c zcode=new Zip_Code_Data__c(Name='xyztest',OFFSET_DST__c=-1,OFFSET_ST__c=-1,Timezone__c='Eastern');
        insert zcode;
        date myDate = date.newInstance(2014, 6, 1);
        date newDate = mydate.addDays(2);
        Account acc=new Account(Name='Test CMH ID Account',DMA_Zip_Code__c=zcode.id,recordtypeid=memberoutreach,onboarding_specialist__c=usrid,Stage__c='WaitList',DateofInitialOperation__c=myDate ,Network__c='Diabetes'  );
        insert acc;
        acc.recordtypeid=memberservice;
        
        update acc;
        List <Case> cselist=[select id from case where accountid=:acc.id ];
        delete cselist;
        
        delete acc;
          
        
        }
        public static testMethod void testMyController5() {
        List<Recordtype> rtypelist=[Select id,name from recordtype where sobjecttype='Account'];
        id memberservice;
        id memberoutreach;
        for(recordtype iterRT : rtypelist){
                 if(iterRT.name=='Member Outreach')
                     memberoutreach=iterRT.id;
                 else if(iterRT.name=='Member Services')
                     memberservice=iterRT.id;    
        }
        ID usrid=UserInfo.getUserId(); 
        Zip_Code_Data__c zcode=new Zip_Code_Data__c(Name='xyztest',OFFSET_DST__c=-1,OFFSET_ST__c=-1,Timezone__c='Eastern');
        insert zcode;
        date myDate = date.newInstance(2014, 6, 1);
        date newDate = mydate.addDays(2);
        Account acc=new Account(Name='Test CMH ID Account',DMA_Zip_Code__c=zcode.id,recordtypeid=memberoutreach,onboarding_specialist__c=usrid,Stage__c='WaitList',DateofInitialOperation__c=myDate ,Network__c='Neurology'  );
        insert acc;
        acc.recordtypeid=memberservice;
        
        update acc;
        List <Case> cselist=[select id from case where accountid=:acc.id ];
        delete cselist;
        
        delete acc;
          
        
        }
       
       
       public static testMethod void testMyController6() {
        

        User silivia=[select name,id,email from user where name='Silvia Velazquez'];
        User nonsilivia=[select name,id,email from user where name<>'Silvia Velazquez' and IsActive=true limit 1];
        Account acc=new Account(Name='Test Account',Stage__c='WaitList',Network__c='Diabetes',ownerid=nonsilivia.id);
        insert acc;
        
        acc.name='Test Account Modified';
        acc.ownerid=silivia.id;
        update acc;
        acc.ownerid=nonsilivia.id;
        update acc;
        }
       
}