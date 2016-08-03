@isTest (SeeAllData=false)
public class Test_ProductUpdate {
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
Asset ast1=new Asset(name='test1',Model__c='20LS7DC',product2id=prd1.id,accountid=acc1.id,Location__c='Warehouse');
insert ast1;
Asset ast2=new Asset(name='test2',Model__c='20LS7DC',product2id=prd1.id,accountid=acc1.id,Location__c='Warehouse');
insert ast2;
list<recordtype> rt=new List<recordtype>();
List<Recordtype> rtype=[select id from recordtype where name='Shipping Order' and sobjecttype='Shipping_Order__c']; 
rt=[select id from recordtype where sobjecttype='Case' and name='Work Orders'];
Case testcase=new case(account=acc,status='new',type='Repair',recordtypeid=rt[0].id);
insert testcase;
Date myDate = date.newinstance(2014,07,20);
Shipping_order__c so = new Shipping_order__c (Account__c=acc.id,RecordTypeid=rtype[0].id,Type__c='Shipping Order',RequestedDateofArrival__c=myDate,Related_Work_Order__c=testcase.id);
Shipping_order__c so2 = new Shipping_order__c (Account__c=acc.id,RecordTypeid=rtype[0].id,Type__c='Shipping Order',RequestedDateofArrival__c=myDate,Related_Work_Order__c=testcase.id);
insert so2;
insert so;
ast2.accountid=acc.id;
ast2.Location__c='Retired';
ast2.Shipping_Order__c=so.id;
ast2.accountid=acc2.id;
update ast2;
ast2.accountid=acc2.id;
update ast2;
ast2.product2id=prd2.id;
update ast2;
ast2.Shipping_Order__c=so2.id;
update ast2;
ast2.Shipping_Order__c=null;
update ast2;
ast2.accountid=acc1.id;
update ast2;
ast1.product2id=prd2.id;
update ast1;
delete ast1;
ast2.accountid=acc.id;
update ast2;
delete ast2;



    }// end of method.
}// end of class.