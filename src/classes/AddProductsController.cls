public with sharing class AddProductsController {
	public Opportunity opportunity {get;set;}
	public Account superParent {get;set;}

	public AddProductsController(ApexPages.StandardController standardController) {
		if (!Test.isRunningTest()) {
			standardController.addFields(new List<String> {'AccountId',
														   'Account.Name',
														   'CloseDate',
														   'Description',
														   'Name',
														   'Pricebook2Id',
														   'Pricebook2.Name',
														   'Probability',
														   'StageName'});
		}
		opportunity = (Opportunity)standardController.getRecord();
		//TODO: Default the opportunity's pricebook if there isn't one selected when this page is initialized.

		superParent = AccountService.getSuperParent(opportunity.AccountId, new List<String> {'Id', 'Name', 'ParentId'});
	}

	@RemoteAction
	public static Map<String, Object> getOptions(Id pricebookId) {
		Map<String, Object> result = new Map<String, Object>();

		List<String> specialtyValues = new List<String>();
		List<Schema.PicklistEntry> specialtyEntries = Contact.Specialty__c.getDescribe().getPicklistValues();
		for (Schema.PicklistEntry entry : specialtyEntries) {
			specialtyValues.add(entry.getValue());
		}
		result.put('specialties', specialtyValues);

		List<String> titleValues = new List<String>();
		List<Schema.PicklistEntry> titleEntries = Contact.Title__c.getDescribe().getPicklistValues();
		for (Schema.PicklistEntry entry : titleEntries) {
			titleValues.add(entry.getValue());
		}
		result.put('titles', titleValues);

		Map<String, String> productValues = new Map<String, String>();
		List<PricebookEntry> entries = ProductService.getPricebookEntriesByPricebookId(pricebookId, new List<String> {'Product2.ProductCode'});
		if (ListUtils.isNotNullOrEmpty(entries)) {
			for (PricebookEntry entry : entries) {
				productValues.put(entry.Product2.ProductCode, entry.Id);
			}
		}
		result.put('products', productValues);

		return result;
	}
}