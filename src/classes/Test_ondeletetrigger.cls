@isTest (SeeAllData=false)
public class Test_ondeletetrigger {
public static testMethod void method1(){
Product2 prd1=new Product2(isActive=true,name='testprd1',Number__c=10,Total_Count__c=10);
Product2 prd2=new Product2(isActive=true,name='testprd2',Number__c=10,Total_Count__c=10);
Product2 prd3=new Product2(isActive=true,name='testprd3',Number__c=10,Total_Count__c=10);
Product2 prd4=new Product2(isActive=true,name='testprd4',Number__c=10,Total_Count__c=10,common__c=true);
insert prd1;
insert prd2;
insert prd3;
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
Asset ast3=new Asset(name='test3',Model__c='20LS7DC',product2id=prd3.id,accountid=acc1.id);
insert ast3;
Asset ast4=new Asset(name='test4',Model__c='20LS7DC',product2id=prd4.id,accountid=acc1.id);
insert ast4;
list<recordtype> rt=new List<recordtype>();
rt=[select id from recordtype where sobjecttype='Case' and name='Work Orders'];
Case testcase=new case(account=acc,status='new',type='Repair',recordtypeid=rt[0].id);
insert testcase;
Date myDate = date.newinstance(2014,06,20);
List<Recordtype> rtype=[select id,name from recordtype where sobjecttype='Shipping_Order__c']; 
Id SOtype;
Id ROtype;
for(Recordtype iter  : rtype){
    if(iter.name=='Receiving Order'){
        ROtype=iter.id;
    }
    else if(iter.name=='Shipping Order'){
        SOtype=iter.id;
    } 
}
Shipping_order__c ShippingOrder = new Shipping_order__c (Account__c=acc.id,RecordTypeid=SOtype,Type__c='Shipping Order',RequestedDateofArrival__c=myDate,Related_Work_Order__c=testcase.id);
Shipping_order__c ReceivingOrder= new Shipping_order__c (Account__c=acc.id,RecordTypeid=ROtype,Type__c='Receiving Order',ReqDateofEquipPickup__c=myDate,ofgroundtagstobeissued__c=3,AddrforGroundTagPickUp__c='Yes',Related_Work_Order__c=testcase.id);
insert ShippingOrder ;
insert ReceivingOrder;

Line_Item__c soli1=new Line_Item__c(Shipping_order__c=ShippingOrder.id,Product__c=prd1.id,Quantity__c=1);
insert soli1;
Line_Item__c soli2=new Line_Item__c(Shipping_order__c=ShippingOrder.id,Product__c=prd3.id,Quantity__c=1);
insert soli2;
Line_Item__c roli=new Line_Item__c(Shipping_order__c=ReceivingOrder.id,Product__c=prd2.id,Quantity__c=1);
insert roli;
Line_Item__c roli2=new Line_Item__c(Shipping_order__c=ReceivingOrder.id,Product__c=prd4.id,Quantity__c=1);
insert roli2;
Part__c part1=new Part__c(Shipping_Order__c=ShippingOrder.id,Quantity__c=1,Asset__c=ast1.id);
insert part1;
Part__c part2=new Part__c(Shipping_Order__c=ReceivingOrder.id,Quantity__c=1,Asset__c=ast2.id);
Part__c part3=new Part__c(Shipping_Order__c=ReceivingOrder.id,Quantity__c=1,Asset__c=ast4.id);
insert part2;
Part__c part4=new Part__c(Shipping_Order__c=ReceivingOrder.id,Quantity__c=1,Asset__c=ast3.id);
insert part3;
delete part1;
delete part2;


    }// end of method.
}// end of class.