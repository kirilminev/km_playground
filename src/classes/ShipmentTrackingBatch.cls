Global  with sharing class ShipmentTrackingBatch implements Database.Batchable<SObject>, Database.AllowsCallouts
{

  global final String Query;
      global ShipmentTrackingBatch(string q){       
        this.query = q;
      }

      global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
      }
    
     global void execute(Database.BatchableContext BC, List<ShipmentPackage__c>scope){
          List <ShipmentPackage__c> ShipmentPkgToUpdate = new list <ShipmentPackage__c>();
          for (ShipmentPackage__c pkg : scope){
              
              ShipmentPackage__c p = ShipmentDelegate.GetShipmentTrackingInfo('UPS', pkg.TrackingNumber__c); 
              if (p.Status__c<> null){pkg.Status__C  = p.Status__c.toUpperCase();}
              pkg.ActivityDate__c = p.ActivityDate__c;
              pkg.LeftAtLocation__c = p.LeftAtLocation__c;
              pkg.SignedForName__c = p.SignedForName__c;
              if (p.ScheduledDeliveryDate__c != null){
               pkg.ScheduledDeliveryDate__c = p.ScheduledDeliveryDate__c;
              }

              ShipmentPkgToUpdate.add(pkg);
            } 
            
            update(ShipmentPkgToUpdate);
     }
   
     global void finish(Database.BatchableContext BC){
         
     }
}