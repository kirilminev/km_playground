public class PricebookService {
	private static final String PRICEBOOKENTRYx = 'PricebookEntry';
	
	public static List<PricebookEntry> getByPricebookId(Id pricebookId, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(PRICEBOOKENTRYx)
						  .wherex(
						  	new AndCondition()
						  		.add(new FieldCondition('Pricebook2Id').equals(pricebookId))
						  		.add(new FieldCondition('IsActive').equals(true)))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<PricebookEntry> getAllCommissionEligibleEntries(List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(PRICEBOOKENTRYx)
						  .wherex(
						  	new AndCondition()
						  		.add(new FieldCondition('IsActive').equals(true))
						  		.add(new FieldCondition('Pricebook2.Commission__c').equals(true)))
						  .toSoql();
		return Database.query(soql);
	}
}