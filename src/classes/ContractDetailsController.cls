/*******************************************************************************************************
* @description Controller for ContractDetails.page which overrides the view on Contract.
* 
* 
*/
public with sharing class ContractDetailsController {
	public Contract contract {get;set;}


	public Decimal totalAmount {get;set;}
	public Date startDate {get;set;}
	public Date endDate {get;set;}

	public Map<String, OpportunityLineItem> products {get;set;}

	public ContractDetailsController(ApexPages.StandardController standardController) {
		if (!Test.isRunningTest()) {
			standardController.addFields(new List<String> {'AccountId',
														   'ContractAmount__c',
														   'ContractEndDate__c',
														   'Name',
														   'RecordType.Name',
														   'StartDate'});
		}
		contract = (Contract)standardController.getRecord();

		List<Contract> incrementals = [Select Id, StartDate, ContractAmount__c, ContractEndDate__c
										From Contract Where ParentContract__c =: contract.Id];
		
		products = new Map<String, OpportunityLineItem>();
		totalAmount = contract.ContractAmount__c == null ? 0 : contract.ContractAmount__c;
		startDate = contract.StartDate;
		endDate = contract.ContractEndDate__c;

		List<Id> contractIds = new List<Id>{contract.Id};
		for (Contract incremental : incrementals) {
			endDate = incremental.ContractEndDate__c > endDate ? incremental.ContractEndDate__c : endDate;
			totalAmount += incremental.ContractAmount__c == null ? 0 : incremental.ContractAmount__c;

			contractIds.add(incremental.Id);
		}
		List<Opportunity> opportunities = [Select Id,
											(Select Id, Product2.Name, Quantity, TotalPrice, UnitPrice, ProductCode, NumberOfDevices__c From OpportunityLineItems)
												From Opportunity Where ContractId IN: contractIds];



		for (Opportunity opportunity : opportunities) {
			for (OpportunityLineItem lineItem : opportunity.OpportunityLineItems) {
				if (products.get(lineItem.ProductCode) == null) {
					products.put(lineItem.ProductCode, lineItem);
				}
				else {
					OpportunityLineItem existingLineItem = products.get(lineItem.ProductCode);
					Decimal totalAmount = existingLineItem.TotalPrice + lineItem.TotalPrice;
					existingLineItem.Quantity += lineItem.Quantity;
					existingLineItem.NumberOfDevices__c += lineItem.NumberOfDevices__c;
					existingLineItem.UnitPrice = totalAmount / existingLineItem.Quantity;
					existingLineItem.TotalPrice = totalAmount;
					products.put(lineItem.ProductCode, existingLineItem);
				}
			}
		}
	}

	public PageReference addAddendum() {
		Map<String, Schema.RecordTypeInfo> contractRecordTypes = Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByName();
		Map<String, Schema.RecordTypeInfo> opportunityRecordTypes = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName();

		Contract incremental = new Contract(
			AccountId = contract.AccountId,
			Name = contract.Name.split(' - ')[0] + ' - Addendum',
			OwnerId = UserInfo.getUserId(),
			ParentContract__c = contract.Id,
			RecordTypeId = contractRecordTypes.get('Addendum Contract').getRecordTypeId()
		);

		try {
			insert incremental;
		}
		catch (DmlException ex) {
			LoggingUtils.log(ex, true, true, true);
		}

		Opportunity opportunity = new Opportunity(
			AccountId = contract.AccountId,
			CloseDate = System.today(),
			ContractId = incremental.Id,
			Name = contract.Name.split(' - ')[0] + ' - Addendum',
			OwnerId = UserInfo.getUserId(),
			RecordTypeId = opportunityRecordTypes.get('Sponsorship').getRecordTypeId(),
			StageName = 'Open'
		);

		try {
			insert opportunity;
			PageReference result = new ApexPages.StandardController(opportunity).view();
			result.setRedirect(true);
			return result;
		}
		catch (DmlException ex) {
			LoggingUtils.log(ex, true, true, true);
		}

		return null;
	}
}