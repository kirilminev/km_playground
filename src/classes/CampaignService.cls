public with sharing class CampaignService {
	private static final String CAMPAIGNx = 'Campaign';
	private static final String QUALIFICATIONx = 'SponsorQualification__c';

	public static List<Campaign> getAll(List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(CAMPAIGNx)
						  .toSoql();
		return Database.query(soql);
	}

}