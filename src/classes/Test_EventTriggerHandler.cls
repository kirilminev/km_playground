/*
 * Created By : Lister Technologies
 * Purpose : To Test the event trigger handler.
             

*/
@isTest (SeeAllData=true)
public class Test_EventTriggerHandler {

        public static testMethod void testMyController() {
        
        Account acct = new Account( Name = 'Test Account' );
        insert acct;
        
        Event evt=new Event(WhatId=acct.id,subject='Call',EndDateTime=Datetime.parse('12/31/2013 1:00 AM'),StartDateTime=Datetime.parse('12/31/2013 1:00 AM'));
        insert evt;
        
        }
        
}