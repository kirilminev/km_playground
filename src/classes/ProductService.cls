public with sharing class ProductService {
	private static final String PRICEBOOKENTRYx = 'PricebookEntry';
	private static final String PRODUCT2x = 'Product2';

	public static List<Product2> getByIsActive(Boolean isActive, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(PRODUCT2x)
						  .wherex(new FieldCondition('IsActive').equals(isActive))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Product2> getByPricebookId(Id pricebookId, List<String> fields) {
		Map<Id, Product2> allActiveProducts = new Map<Id, Product2>(getByIsActive(true, fields));
		List<PricebookEntry> pricebookEntries = PricebookService.getByPricebookId(pricebookId, new List<String> {'Product2Id'});

		List<Product2> result;
		if (ListUtils.isNotNullOrEmpty(pricebookEntries)) {
			result = new List<Product2>();
			for (PricebookEntry entry : pricebookEntries) {
				result.add(allActiveProducts.get(entry.Product2Id));
			}
		}
		return result;
	}

	public static List<PricebookEntry> getPricebookEntriesByPricebookId(Id pricebookId, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(PRICEBOOKENTRYx)
						  .wherex(new FieldCondition('Pricebook2Id').equals(pricebookId))
						  .toSoql();
		return Database.query(soql);
	}
}