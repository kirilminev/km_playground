/*
 * Created By : Lister Technologies
 * Purpose : To Test the task trigger handler.
             

*/
@isTest (SeeAllData=true)
public class Test_TaskTriggerHandler {

        public static testMethod void testMyController() {
        
        Account acct = new Account( Name = 'Test Account',DateofInitialOperation__c=Date.parse('12/10/2013'));
        insert acct;
        system.debug('date>>>>>>>>>>>>>'+acct.DateofInitialOperation__c);
        List<RecordType> rtype=new List<RecordType>();
        rtype=[select id from recordtype where name='Member Services' and sobjecttype='Task'];
        if(!rtype.isEmpty()){
            Task tsk=new Task (WhatId=acct.id,subject='Call',status='Completed',recordtypeid=rtype[0].id,Activity_Note__c='Test Note',ActivityDate=date.newInstance(2014,03,24));
            insert tsk;
            
            Task temp=[select status from task where id=:tsk.id];
            temp.status='Completed';
            update temp;
       }
        }
        
}