public with sharing class OpportunityLineItemTriggerHandler implements ITrigger {

	private static Set<String> opportunityIdsNew;//Opportunity Ids related to line items
	private static List<Opportunity> opportunitiesNew;

	public OpportunityLineItemTriggerHandler(){}

	public void bulkBefore(){

		if (Trigger.new != null && opportunityIdsNew == null && opportunitiesNew == null) {

			opportunityIdsNew = OpportunityLineItemService.getOpportunityIdsForOpportunityLineItems(Trigger.new);

			opportunitiesNew = OpportunityService.getByIdsWithOpportunityLineItems(
																			new List<String>(opportunityIdsNew), 
																			new List<String> {
																					'Accelerator_Stage_1__c',
															         				'Accelerator_Stage_2__c',
																					'OwnerId', 'Owner_Team__c',
																	 				'Id', 'Qualification_Type__c', 
																	 				'RecordTypeId'
														         				 },
													         				new List<String>{
														         					'Id',
														         					'ProductCode',
														         					'Product2Id'
													         				}
											         					);
		}
	}

	public void bulkAfter(){}

	public void beforeInsert(List<SObject> soListNew) {
		OpportunityLineItemService.checkForDuplicates(opportunitiesNew, soListNew);
		OpportunityLineItemService.calculateProductsCommissionAmount(opportunitiesNew, soListNew);
	}

	public void beforeUpdate(Map<Id, SObject> oldSoMap, List<SObject> soNewList) {
		OpportunityLineItemService.calculateProductsCommissionAmount(opportunitiesNew, soNewList);
	}

	public void beforeDelete(List<SObject> soList){}

	public void afterInsert(List<SObject> soList){}

	public void afterUpdate(Map<Id, SObject> oldSoMap, List<SObject> soList){
		CommissionService.updateCommissionEntries(opportunitiesNew, null);
	}

	public void afterDelete(List<SObject> soList){}

	public void andFinally(){}
}