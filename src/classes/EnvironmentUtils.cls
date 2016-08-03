public class EnvironmentUtils {

	public static String getEnvironmentProperty(String key) {
		if (UserInfo.getOrganizationId() == new Constants.OrganizationIds().PRODUCTION_ID) {
			Map<String, ProductionProperties__c> productionProperties = ProductionProperties__c.getAll();
			return productionProperties.get(key).Value__c;
		}
		else {
			Map<String, StagingProperties__c> stagingProperties = StagingProperties__c.getAll();
			return stagingProperties.get(key).Value__c;
		}
	}
}