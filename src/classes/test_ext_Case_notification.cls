@isTest(SeeAllData=true)
public class test_ext_Case_notification{

static testMethod void myTest(){
Zip_Code_Data__c zcode=new Zip_Code_Data__c(Name='123',OFFSET_DST__c=-1,OFFSET_ST__c=-1,Timezone__c='Eastern');
insert zcode;
date myDate = date.newInstance(2014, 6, 1);
date newDate = mydate.addDays(2);
User usr=[select id,lastname,firstname from user where name like '%Travis Kemp%'];
ID usrid=UserInfo.getUserId(); 
Account acc=new Account(Name='Test Account',Ownerid=usr.id,DMA_Zip_Code__c=zcode.id,onboarding_specialist__c=usrid,Stage__c='WaitList',DateofInitialOperation__c=myDate ,Init_touch_Date__c=newDate );
insert acc;
List<recordtype> rt=[select id from recordtype where sobjecttype='Case' and name='Work Orders'];
Case testcase=new case(accountid=acc.id,Ownerid=usr.id,status='new',type='Repair',recordtypeid=rt[0].id);
insert testcase;
ApexPages.StandardController sc = new ApexPages.standardController(testcase);
ext_Case_notification myext = new ext_Case_notification(sc);

}

}