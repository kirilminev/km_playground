global with sharing class ShipmentTrackingBatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {				
		String query = (new SoqlBuilder()
                .selectx(new List<String> {'Id','Status__C', 'TrackingNumber__c'})
                .fromx('Shipmentpackage__c')
                .wherex(new AndCondition()
                        .add (new FieldCondition('Status__C').notequals('DELIVERED'))
                        .add (new FieldCondition('RequestedDateOfArrivalExt__C ').greaterThanOrEqualTo(new DateFormula().todayx()))
                       ).toSoql()); 
		ShipmentTrackingBatch colBatch = new ShipmentTrackingBatch(query);			 
		Id batchprocessid = Database.executeBatch(colBatch,1);		   	
	}
}