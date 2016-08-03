@isTest
public class TestDataService {

	public static Account getTestAccount(String network) {
		Account result = new Account();

		result.Name = 'Test Account';
		result.Network__c = network;
		result.Stage__c = 'Unconfirmed';
		result.DMA_Zip_Code__c = getZipCodeData().Id;
		result.Qualified_Physicians__c = 1;
		result.of_Waiting_Rooms__c = 1;
		result.LeadSource__c = 'Lead Source';

		insert result;
		return result;
	}

	public static List<Asset> getTestAssets(Id accountId) {
		List<Asset> result = new List<Asset>();

		Asset player = new Asset();
		player.Name = 'player';
		player.AccountId = accountId;
		player.Type__c = new Constants.AssetTypes().PLAYER;
		player.Installation_Status__c = new Constants.AssetInstallationStatuses().ACTIVE;
		result.add(player);

		Asset tablet = new Asset();
		tablet.Name = 'tablet';
		tablet.AccountId = accountId;
		tablet.Type__c = new Constants.AssetTypes().TABLET;
		tablet.Installation_Status__c = new Constants.AssetInstallationStatuses().ACTIVE;
		result.add(tablet);

		insert result;
		return result;
	}

	public static Campaign getTestCampaign(String category) {
		Campaign result = new Campaign();

		result.Name = 'Campaign Name';
		result.Type = new Constants.CampaignTypes().SPONSORSHIP;
		result.Status = new Constants.CampaignStatuses().PLANNED;
		result.Category__c = category;

		insert result;
		return result;
	}

	public static Contact getTestContact(Boolean isQualified, Id optionalAccountId) {
		Contact result = new Contact();

		result.FirstName = 'Hugh';
		result.LastName = 'Janus';
		result.Qualification__c = isQualified ? 'GI' : '';
		result.AccountId = optionalAccountId;

		insert result;
		return result;
	}

	public static List<ContextMedia_Product__c> getTestProducts(Id accountId) {
		List<ContextMedia_Product__c> result = new List<ContextMedia_Product__c>();

		ContextMedia_Product__c waitingRoomScreen = new ContextMedia_Product__c();
		waitingRoomScreen.Account__c = accountId;
		waitingRoomScreen.Product_Type__c = new Constants.ProductTypes().WAITING_ROOM_SCREEN;
		waitingRoomScreen.Product__c = new Constants.ProductSubTypes().DHN_2;
		waitingRoomScreen.Sales_Stage__c = new Constants.SalesStages().INITIAL_TOUCH;
		result.add(waitingRoomScreen);

		ContextMedia_Product__c examRoomTablet = new ContextMedia_Product__c();
		examRoomTablet.Account__c = accountId;
		examRoomTablet.Product_Type__c = new Constants.ProductTypes().TABLET;
		examRoomTablet.Product__c = new Constants.ProductSubTypes().EXAM_ROOM_TABLET_DHN;
		examRoomTablet.Sales_Stage__c = new Constants.SalesStages().INITIAL_TOUCH;
		result.add(examRoomTablet);

		insert result;
		return result;
	}

	public static Zip_Code_Data__c getZipCodeData() {
		Zip_Code_Data__c result = new Zip_Code_Data__c();

		result.Name = '60611';
		result.OFFSET_ST__c = 1;
		result.OFFSET_DST__c = 1;

		insert result;
		return result;
	}

	public static void setupGrowthSponsor(String campaignNames, String category) {
		GrowthSponsors__c growthSponsor = new GrowthSponsors__c();
		growthSponsor.Name = category;
		growthSponsor.Brand__c = campaignNames;
		insert growthSponsor;
	}

	public static void setupLoggingCustomSettings() {
		Logging_Configuration__c loggingSetting = new Logging_Configuration__c();
		
		loggingSetting.Email_Recipients__c = 'testmail1@contextmediainc.com,testmail2@contextmediainc.com';
		loggingSetting.Email_Subject__c = 'Test Exception Email Subject';
		insert loggingSetting;
	}

	public static void setupSlackCustomSettings() {
		Slack_Integration_Configuration__c defaultCustomSetting = new Slack_Integration_Configuration__c();
		defaultCustomSetting.Enabled__c = true;
		defaultCustomSetting.Default_Channel__c = 'SFDC_EXCEPTIONS_CHANNEL';
		defaultCustomSetting.Exception_Channel__c = 'SFDC_EXCEPTIONS_CHANNEL';
		defaultCustomSetting.Slack_Exceptions_Hashtag__c = '#dev-test-exceptions';

		insert defaultCustomSetting;
	}

	public static void setupRestEnvironmentProperties() {
		
		List<StagingProperties__c> stagingProperties = new List<StagingProperties__c>();
		List<ProductionProperties__c> productionProperties = new List<ProductionProperties__c>();

		insertEnvironmentProperty('REST_MDM_ENDPOINT', 'http://mdm.com', stagingProperties, productionProperties);
		insertEnvironmentProperty('REST_BROADSIGN_ENDPOINT', 'http://broadsign.com', stagingProperties, productionProperties);
		insertEnvironmentProperty('REST_ID_ENDPOINT', 'http://id.com', stagingProperties, productionProperties);
		insertEnvironmentProperty('REST_ID_CLIENTID', 'client id', stagingProperties, productionProperties);
		insertEnvironmentProperty('REST_ID_USERID', 'user id', stagingProperties, productionProperties);
		insertEnvironmentProperty('SFDC_EXCEPTIONS_CHANNEL', 'http://webhook', stagingProperties, productionProperties);
		insertEnvironmentProperty('REST_UPS_ENDPOINT', 'somevalue', stagingProperties, productionProperties);
		insertEnvironmentProperty('REST_UPS_AUTH_USERID', 'somevalue', stagingProperties, productionProperties);
		insertEnvironmentProperty('REST_UPS_AUTH_PWD', 'somevalue', stagingProperties, productionProperties);
		insertEnvironmentProperty('REST_UPS_AUTH_LICENSE_NUMBER', 'somevalue', stagingProperties, productionProperties);

		insert stagingProperties;
		insert productionProperties;
	}

	/*******************************************************************************************************
	* @description 			Utility method which takes property name and property value as strings and inserts
	*                 		them to Lists for both Staging_Properties__c and Production_Properties__c custom settings
	*                 		
	* @return 				void
	* 
	* @example				List<StagingProperties__c> stagingProperties = new List<StagingProperties__c>();
							List<ProductionProperties__c> productionProperties = new List<ProductionProperties__c>();

							insertEnvironmentProperty('REST_MDM_ENDPOINT', 'http://mdm.com', stagingProperties, productionProperties);

							insert stagingProperties;
							insert productionProperties;
	* 
	*/
	public static void insertEnvironmentProperty(String propertyName, 
										   String propertyValue, 
										   List<StagingProperties__c> stagingProperties, 
										   List<ProductionProperties__c> productionProperties) {

		StagingProperties__c tempStagingProperty = new StagingProperties__c();
		tempStagingProperty.Name = propertyName;
		tempStagingProperty.Value__c = propertyValue;
		stagingProperties.add(tempStagingProperty);

		ProductionProperties__c tempProductionProperty = new ProductionProperties__c();
		tempProductionProperty.Name = propertyName;
		tempProductionProperty.Value__c = propertyValue;
		productionProperties.add(tempProductionProperty);
	}

	public static void setupTestSupplyChainProductAndPackage() {
		Product2 label = new Product2();
		label.Name = 'Return Label';
		label.ProductCode = 'LAB101';

		label.IsActive = true;
		insert label;

		Product2 product = new Product2();
		product.Name = 'Product';
		product.ProductCode = 'Product';

		product.IsActive = true;
		insert product;

		Pricebook2 productPackage = new Pricebook2();
		productPackage.Name = 'Package';
		productPackage.PackageCode__c = 'Package';
		productPackage.IsActive = true;
		insert productPackage;

		PricebookEntry standardEntry = new PricebookEntry();
		standardEntry.IsActive = true;
		standardEntry.Pricebook2Id = Test.getStandardPricebookId();
		standardEntry.Product2Id = product.Id;
		standardEntry.UnitPrice = 0;
		standardEntry.Quantity__c = 1;
		insert standardEntry;

		PricebookEntry entry = new PricebookEntry();
		entry.IsActive = true;
		entry.Pricebook2Id = productPackage.Id;
		entry.Product2Id = product.Id;
		entry.UnitPrice = 0;
		entry.Quantity__c = 1;
		insert entry;
	}

	/*******************************************************************************************************
	* @description 	    Inserts custom setting for the Qualification__c 
	*  
	* @return 			void
	* 
	*/
	public static void setupQualificaitonsCustomSetting() {

		List<Qualification__c> listQualificaitons = new List<Qualification__c>();
		
		listQualificaitons.add(new Qualification__c(Name = 'Cardio',
														   Qualification_Type__c  = 'Specialty',
														   Qualification_Priority__c = 1));

		listQualificaitons.add(new Qualification__c(Name = 'Dermatology',
														   Qualification_Type__c  = 'Specialty',
														   Qualification_Priority__c = 1));

		listQualificaitons.add(new Qualification__c(Name = 'Allergy',
														   Qualification_Type__c  = 'PCP',
														   Qualification_Priority__c = 2));

		listQualificaitons.add(new Qualification__c(Name = 'General Health',
														   Qualification_Type__c  = 'General Health',
														   Qualification_Priority__c = 3));

		insert listQualificaitons;
	}

	/*******************************************************************************************************
	* @description 	Inserts Custom Settings Commission_Rate_Card__c Used in Unit Testings
	* 
	*/
	public static void setupCommissionRateCardCustomSetting () {
		
		List<Commission_Rate_Card__c> commissionRates = new List<Commission_Rate_Card__c>();
	
		commissionRates.add(new Commission_Rate_Card__c(
								Name = 'PES_Specialty___WIFI',
								Rate_Amount__c = 60.00,
								Inflated_Rate__c = 120.00,
								Inflated_Rate_Second_Stage__c = 0.00,
								Team__c = 'PES',
								Qualification_Type__c = 'Specialty',
								Product_Code__c = 'WIFI'));

		commissionRates.add(new Commission_Rate_Card__c(
								Name = 'PES_Specialty___Waiting_Room_Screen',
								Rate_Amount__c = 150.00,
								Inflated_Rate__c = 300.00,
								Inflated_Rate_Second_Stage__c = 0.00,
								Team__c = 'PES',
								Qualification_Type__c = 'Specialty',
								Product_Code__c = 'Waiting Room Screen'));

		commissionRates.add(new Commission_Rate_Card__c(
								Name = 'MSE_Specialty___WIFI',
								Rate_Amount__c = 60.00,
								Inflated_Rate__c = 80.00,
								Inflated_Rate_Second_Stage__c = 160.00,
								Team__c = 'MSE',
								Qualification_Type__c = 'Specialty',
								Product_Code__c = 'WIFI'));

		insert commissionRates;
	}

	/*******************************************************************************************************
	* @description 	Inserts Custom Settings Commission_Accelerator_Threshold__c Used in Unit Testings
	* 
	*/
	public static void setupCommissionAcceleratorThresholds() {

		List<Commission_Accelerator_Threshold__c> thresholdSettings = new List<Commission_Accelerator_Threshold__c>();

		thresholdSettings.add(new Commission_Accelerator_Threshold__c(Name = 'PES', Accelerator_Stage_1__c = '11-20'));
		thresholdSettings.add(new Commission_Accelerator_Threshold__c(Name = 'MSE', Accelerator_Stage_1__c = '31-60', Accelerator_Stage_2__c = '61-300'));

		insert thresholdSettings;
	}

	/*******************************************************************************************************
	* @description 	Inserts Custom Settings Role_Team_Map__c Used in Unit Testings
	* 
	*/
	public static void setupRoleTeamMaps() {

		List<Role_Team_Map__c> teamRoleMaps = new List<Role_Team_Map__c>();

		teamRoleMaps.add(new Role_Team_Map__c(Name = '00EC0000001XIK0', Team__c = 'PES', Specialty__c = 'Cardiology', Role_Name__c = 'Cardiology Healthcare Sales'));
		teamRoleMaps.add(new Role_Team_Map__c(Name = '00EC0000001QVpc', Team__c = 'MSE', Specialty__c = 'None', Role_Name__c = 'Member Services'));

		insert teamRoleMaps;
	}

	/*******************************************************************************************************
	* @description 	Inserts Custom Settings Commission_Rate_Specialty_Contacts__c Used in Unit Testings
	* 
	*/
	public static void setupCommissionRateSpecialtyContacts() {
		
		List<Commission_Rate_Specialty_Contacts__c> rateConfigs = new List<Commission_Rate_Specialty_Contacts__c>();

		rateConfigs.add(new Commission_Rate_Specialty_Contacts__c(Name = 'Specialty', Commission_Amount__c = 75.00, Inflated_Rate__c = 150.0));
		rateConfigs.add(new Commission_Rate_Specialty_Contacts__c(Name = 'PCP', Commission_Amount__c = 50.00, Inflated_Rate__c = 100.0));
		rateConfigs.add(new Commission_Rate_Specialty_Contacts__c(Name = 'General Health', Commission_Amount__c = 12.00, Inflated_Rate__c = 24.0));

		insert rateConfigs;
	}

	public static void setupCommissionsCalculatorGlobalSettings () {
		insert new Commissions_Calculator_Global__c(Enabled_Opportunity_Record_Type_Names__c = 'Membership, Sponsorship');
	}

	/*******************************************************************************************************
	* @description 		Utility Method inserts pricebook for a given name along with with some pre-defined
	*                	products and price book entries for unit testing purposes
	* 
	* @param 			[String priceBOokName] -> Name of the pricebook which will be inserted
	* 
	*/
	public static void setupPriceBookWithProducts(String priceBookName) {
		
		//Sets up product and pricebook data.
		List<Product2> products = new List<Product2> {
			new Product2(
				IsActive = true,
				Name = 'Waiting Room Screen',
				ProductCode = 'Waiting Room Screen'
			),
			new Product2(
				IsActive = true,
				Name = 'Tablet',
				ProductCode = 'Tablet (Standard)'
			),
			new Product2(
				IsActive = true,
				Name = 'Infusion Room Tablet',
				ProductCode = 'Tablet (Infusion)'
			),
			new Product2(
				IsActive = true,
				Name = 'WIFI',
				ProductCode = 'WIFI'
			)
		};
		insert products;

		Pricebook2 membership = new Pricebook2(
			Commission__c = true,
			IsActive = true,
			Name = priceBookName,
			PackageCode__c = priceBookName.toUpperCase()
		);
		insert membership;

		List<PricebookEntry> standardEntries = new List<PricebookEntry>();

		for (Product2 product : products) {
			standardEntries.add(
				new PricebookEntry(
					IsActive = true,
					Pricebook2Id = Test.getStandardPricebookId(),
					Product2Id = product.Id,
					Quantity__c = 1,
					UnitPrice = 0
				)
			);
		}
		insert standardEntries;
		List<PricebookEntry> entries = new List<PricebookEntry>();

		for (Product2 product : products) {
			entries.add(
				new PricebookEntry(
					CommissionAmount__c = 1,
					IsActive = true,
					Pricebook2Id = membership.Id,
					Product2Id = product.Id,
					Quantity__c = 1,
					UnitPrice = 0
				)
			);
		}
		insert entries;
	}
}