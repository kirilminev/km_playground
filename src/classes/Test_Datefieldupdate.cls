@isTest (SeeAllData=false)
public class Test_Datefieldupdate {
public static testMethod void method1(){
Product2 prd1=new Product2(name='testprd1');
Product2 prd2=new Product2(name='testprd2');
insert prd1;
insert prd2;
Zip_Code_Data__c zcode=new Zip_Code_Data__c(Name='123',OFFSET_DST__c=-1,OFFSET_ST__c=-1);
insert zcode;
Account acc=new Account(name='test',DMA_Zip_Code__c=zcode.id,stage__c='Waitlist',CMHID__c=1234);
insert acc;
Account acc1=new Account(name='ContextMedia Inventory',DMA_Zip_Code__c=zcode.id,stage__c='Waitlist',CMHID__c=1234);
insert acc1;
Account acc2=new Account(name='ContextMedia Retired Inventory',DMA_Zip_Code__c=zcode.id,stage__c='Waitlist',CMHID__c=1234);
insert acc2;
Asset ast1=new Asset(name='test1',Model__c='20LS7DC',product2id=prd1.id,accountid=acc1.id);
insert ast1;
Asset ast2=new Asset(name='test2',Model__c='20LS7DC',product2id=prd1.id,accountid=acc1.id);
insert ast2;
ast2.accountid=acc.id;
update ast2;
ast2.accountid=acc2.id;
update ast2;


    }// end of method.
}// end of class.