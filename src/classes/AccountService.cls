public class AccountService {
	private static final String ACCOUNTx = 'Account';
	private static final String ACCOUNTCONTACTROLESx = 'AccountContactRoles';
	private static final String ACCOUNTSPONSORSx = 'AccountSponsors__r';
	private static final String ASSETSx = 'Assets';
	private static final String CASEx = 'Case';
	private static final String CASESx = 'Cases';
	private static final String CONTACTSx = 'Contacts';
	private static final String OPPORTUNITIESx = 'Opportunities';
	private static final String PRODUCTSx = 'Products1__r';
	private static final String SPONSORQUALIFICATIONSx = 'SponsorQualifications__r';

	public static Account getById(Id accountId, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(ACCOUNTx)
						  .wherex(new FieldCondition('Id').equals(accountId))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Account> getByIds(List<Id> accountIds, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(ACCOUNTx)
						  .wherex(new SetCondition('Id').inx(accountIds))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Account> getByIdsWithOrder(List<Id> accountIds, List<String> fields, String orderByField) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(ACCOUNTx)
						  .wherex(new SetCondition('Id').inx(accountIds))
						  .orderByx(new OrderBy(orderByField).ascending())
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Account> getByParentIdsWithOrder(List<Id> accountIds, List<String> fields, String orderByField) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(ACCOUNTx)
						  .wherex(new SetCondition('ParentId').inx(accountIds))
						  .orderByx(new OrderBy(orderByField).ascending())
						  .toSoql();
		return Database.query(soql);
	}

	/*******************************************************************************************************
	* @description This method is used in slingshot to get all of the child accounts to 
					the given reference number. Those with specific stages are ignored,
					since they are already at a specific point in the process and slingshot
					would not apply to them.
	*/
	public static List<Account> getWithPrescribersByParentIdsWithOrder(List<Id> accountIds, List<String> accountFields, List<String> contactFields, String orderByField) {
		String soql = new SoqlBuilder()
						  .selectx(accountFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(contactFields)
						  		.fromx(CONTACTSx)
						  		.wherex(new FieldCondition('Prescriber__c').equals(true)))
						  .fromx(ACCOUNTx)
						  .wherex(
						  	new AndCondition()
						  		.add(new SetCondition('ParentId').inx(accountIds))
						  		.add(new NotCondition(new SetCondition('Stage__c').inx(new List<String> {'Installed',
						  																				 'Partial install plays content',
						  																				 'Partial install no content',
						  																				 'Pending repair - playing content',
						  																				 'Scheduled',
						  																				 'Scheduled - competitor removal'}))))
						  .orderByx(new OrderBy(orderByField).ascending())
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Account> getByNetwork(String network, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(ACCOUNTx)
						  .wherex(new FieldCondition('Network__c').equals(network))
						  .toSoql();
		return Database.query(soql);
	}

	public static Account getSuperParent(Id parentId, List<String> fields) {
		Account account;
		while (parentId != null) {
			account = getById(parentId, fields);
			parentId = account.ParentId;
		}
		return account;
	}

	public static Account getWithAssetsAndContactsById(Id accountId, List<String> accountFields, List<String> assetFields, List<String> contactFields) {
		String soql = new SoqlBuilder()
						  .selectx(accountFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(assetFields)
						  		.fromx(ASSETSx))
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(contactFields)
						  		.fromx(CONTACTSx))
						  .fromx(ACCOUNTx)
						  .wherex(new FieldCondition('Id').equals(accountId))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Account> getWithCasesByIdsAndCaseRecordTypeId(List<Id> accountIds, Id caseRecordTypeId, List<String> accountFields, List<String> caseFields) {
		String soql = new SoqlBuilder()
						  .selectx(accountFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(caseFields)
						  		.fromx(CASESx)
						  		.wherex(new FieldCondition('RecordTypeId').equals(caseRecordTypeId)))
						  .fromx(ACCOUNTx)
						  .wherex(new SetCondition('Id').inx(accountIds))
						  .toSoql();
		return Database.query(soql);
	}

	public static Account getWithOpportunitiesAndContactsById(Id accountId, List<String> accountFields, List<String> opportunityFields, List<String> contactFields) {
		String soql = new SoqlBuilder()
						  .selectx(accountFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(opportunityFields)
						  		.fromx(OPPORTUNITIESx))
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(contactFields)
						  		.fromx(CONTACTSx))
						  .fromx(ACCOUNTx)
						  .wherex(new FieldCondition('Id').equals(accountId))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Account> getWithOpportunitiesAndContactsByIds(List<Id> accountIds, List<String> accountFields, List<String> opportunityFields, List<String> contactFields) {
		String soql = new SoqlBuilder()
						  .selectx(accountFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(opportunityFields)
						  		.fromx(OPPORTUNITIESx))
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(contactFields)
						  		.fromx(CONTACTSx))
						  .fromx(ACCOUNTx)
						  .wherex(new SetCondition('Id').inx(accountIds))
						  .toSoql();
		return Database.query(soql);
	}

	public static Account getWithProductsById(Id accountId, List<String> accountFields, List<String> productFields) {
		String soql = new SoqlBuilder()
						  .selectx(accountFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(productFields)
						  		.fromx(PRODUCTSx))
						  .fromx(ACCOUNTx)
						  .wherex(new FieldCondition('Id').equals(accountId))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Account> getWithProductsByIds(List<Id> accountIds, List<String> accountFields, List<String> productFields) {
		String soql = new SoqlBuilder()
						  .selectx(accountFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(productFields)
						  		.fromx(PRODUCTSx))
						  .fromx(ACCOUNTx)
						  .wherex(new SetCondition('Id').inx(accountIds))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Account> getWithQualifiedContactsAndProductsByIds(List<Id> accountIds, List<String> accountFields, List<String> contactFields, List<String> productFields) {
		String soql = new SoqlBuilder()
						  .selectx(accountFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(contactFields)
						  		.fromx(CONTACTSx)
						  		.wherex(
						  			new AndCondition()
						  				.add(new FieldCondition('Qualification__c').notEquals(''))
						  				.add(new FieldCondition('Qualification__c').notEquals(new Constants.ContactQualifications().NOT_QUALIFIED))
						  				.add(new FieldCondition('Qualification__c').notEquals(new Constants.ContactQualifications().NPI_MISSING_UNKNOWN))
						  				.add(new FieldCondition('RecordType.Name').equals(new Constants.ContactRecordTypes().MEMBER_PRACTICE))))
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(productFields)
						  		.fromx(PRODUCTSx))
						  .fromx(ACCOUNTx)
						  .wherex(new SetCondition('Id').inx(accountIds))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Account> getWithQualifiedContactsAndQualifiedContactRolesByIds(List<Id> accountIds, List<String> accountFields, List<String> contactFields, List<String> contactRoleFields) {
		String soql = new SoqlBuilder()
						  .selectx(accountFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(contactFields)
						  		.fromx(CONTACTSx)
						  		.wherex(
						  			new AndCondition()
						  				.add(new FieldCondition('Qualification__c').notEquals(''))
						  				.add(new FieldCondition('Qualification__c').notEquals(new Constants.ContactQualifications().NOT_QUALIFIED))
						  				.add(new FieldCondition('Qualification__c').notEquals(new Constants.ContactQualifications().NPI_MISSING_UNKNOWN))
						  				.add(new FieldCondition('RecordType.Name').equals(new Constants.ContactRecordTypes().MEMBER_PRACTICE))))
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(contactRoleFields)
						  		.fromx(ACCOUNTCONTACTROLESx)
						  		.wherex(
						  			new AndCondition()
						  				.add(new FieldCondition('Contact.Qualification__c').notEquals(''))
						  				.add(new FieldCondition('Contact.Qualification__c').notEquals(new Constants.ContactQualifications().NOT_QUALIFIED))
						  				.add(new FieldCondition('Contact.Qualification__c').notEquals(new Constants.ContactQualifications().NPI_MISSING_UNKNOWN))
						  				.add(new FieldCondition('Contact.RecordType.Name').equals(new Constants.ContactRecordTypes().MEMBER_PRACTICE))))
						  .fromx(ACCOUNTx)
						  .wherex(new SetCondition('Id').inx(accountIds))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Account> getWithSponsorQualificationsByIds(List<Id> accountIds, List<String> accountFields, List<String> qualificationFields) {
		String soql = new SoqlBuilder()
						  .selectx(accountFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(qualificationFields)
						  		.fromx(SPONSORQUALIFICATIONSx))
						  .fromx(ACCOUNTx)
						  .wherex(new SetCondition('Id').inx(accountIds))
						  .toSoql();
		return Database.query(soql);
	}

	public static Account getWithSponsorsById(Id accountId, List<String> accountFields, List<String> sponsorFields) {
		String soql = new SoqlBuilder()
						  .selectx(accountFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(sponsorFields)
						  		.fromx(ACCOUNTSPONSORSx))
						  .fromx(ACCOUNTx)
						  .wherex(new FieldCondition('Id').equals(accountId))
						  .toSoql();
		return Database.query(soql);
	}

	public static void addGrowthSponsors(Map<Id, Account> oldSoMap, List<Account> soList) {
		Map<Id, Schema.RecordTypeInfo> recordTypes = Schema.getGlobalDescribe().get(ACCOUNTx).getDescribe().getRecordTypeInfosById();
		List<Id> accountIds = new List<Id>();
		for (Account account : soList) {
			if (recordTypes.get(account.RecordTypeId).getName() == new Constants.AccountRecordTypes().MEMBER_SERVICES && recordTypes.get(oldSoMap.get(account.Id).RecordTypeId).getName() == new Constants.AccountRecordTypes().MEMBER_OUTREACH) {
				accountIds.add(account.Id);
			}
		}
		if (ListUtils.isNotNullOrEmpty(accountIds)) {
			Map<String, GrowthSponsors__c> growthSponsors = GrowthSponsors__c.getAll();
			Map<Id, Campaign> campaigns = new Map<Id, Campaign>(CampaignService.getAll(new List<String> {'Category__c',
																										 'Id',
																				 						 'Name'}));
			Map<String, Campaign> nameToCampaign = new Map<String, Campaign>();
			for (Campaign campaign : campaigns.values()) {
				nameToCampaign.put(campaign.Name, campaign);
			}
			List<Account> accountsToProcess = getWithSponsorQualificationsByIds(accountIds, new List<String> {'Id'}, new List<String> {'Account__c',
																																	   'Campaign__c'});
			List<AccountSponsor__c> accountSponsorsToInsert = new List<AccountSponsor__c>();
			for (Account account : accountsToProcess) {
				Set<String> campaignNames = new Set<String>();
				for (SponsorQualification__c qualification : account.SponsorQualifications__r) {
					if (campaigns.get(qualification.Campaign__c) != null && growthSponsors.get(campaigns.get(qualification.Campaign__c).Category__c) != null) {
						campaignNames.addAll(growthSponsors.get(campaigns.get(qualification.Campaign__c).Category__c).Brand__c.split(','));
					}
				}
				for (String campaignName : campaignNames) {
					if (nameToCampaign.get(campaignName) != null) {
						AccountSponsor__c accountSponsor = new AccountSponsor__c();
						accountSponsor.Account__c = account.Id;
						accountSponsor.Campaign__c = nameToCampaign.get(campaignName).Id;
						accountSponsorsToInsert.add(accountSponsor);
					}
				}
			}
			if (ListUtils.isNotNullOrEmpty(accountSponsorsToInsert)) {
				try {
					insert accountSponsorsToInsert;
				}
				catch (Exception ex) {
					EmailUtils.sendTextEmail(new List<String> { 'matt.t@contextmediainc.com' }, 'AccountService Exception in addGrowthSponsors', ex.getMessage() + ' - ' + ex.getStackTraceString());
				}
			}
		}
	}

	public static void createInstallationApprovals(Map<Id, Account> oldSoMap, List<Account> soList) {
		Map<String, RecordType> accountRecordTypes = new Map<String, RecordType>();
		List<RecordType> accountRecordTypeList = RecordTypeService.getByObjectType(ACCOUNTx, new List<String> {'Id',
																											   'Name'});
		for (RecordType recordType : accountRecordTypeList) {
			accountRecordTypes.put(recordType.Name, recordType);
		}
		RecordType ItApproval = RecordTypeService.getByNameAndObjectType('IT Approval', CASEx, new List<String> {'Id',
																												 'Name'});
		List<Id> accountIds = new List<Id>();
		for (Account account : soList) {
			accountIds.add(account.Id);
		}
		List<Account> accounts = getWithCasesByIdsAndCaseRecordTypeId(accountIds, ItApproval.Id, new List<String> {'Id',
																												   'OwnerId',
																												   'RecordTypeId'},
																								 new List<String> {'Id'});
		List<Case> casesToInsert = new List<Case>();
		for (Account account : accounts) {
			if (ListUtils.isNullOrEmpty(account.Cases) && oldSoMap.get(account.Id).RecordTypeId == accountRecordTypes.get('Member Outreach').Id && account.RecordTypeId == accountRecordTypes.get('Member Services').Id) {
				Case installationApproval = new Case();
				installationApproval.AccountId = account.Id;
				installationApproval.OwnerId = account.OwnerId;
				installationApproval.Status = 'New';
				installationApproval.Subject = 'IT Approval';
				installationApproval.RecordTypeId = ItApproval.Id;
				installationApproval.Type = 'IT Approval';
				casesToInsert.add(installationApproval);
			}
		}

		if (ListUtils.isNotNullOrEmpty(casesToInsert)) {
			insert casesToInsert;
		}
	}

	public static Map<String, Object> getSyncClinicBody(Account account, List<Map<String, String>> assets) {
		Map<String, Object> fields = new Map<String, Object>();

		fields.put('cmh_id', String.valueOf(account.CMHID__c));
		fields.put('facility_name', account.Name);
		fields.put('specialities', account.Network__c == null ? new List<String>() : account.Network__c.split(';'));
		fields.put('city', account.BillingCity);
		fields.put('state', account.BillingState);
		fields.put('timezone', account.Time_Zone__c);
		fields.put('waiting_room_count', String.valueOf(account.of_Waiting_Rooms__c));
		fields.put('screen_count', String.valueOf(account.NumberOfScreensInstalled__c));
		fields.put('exam_room_count', String.valueOf(account.NumberOfExamRooms__c));
		fields.put('tablet_count', String.valueOf(account.NumberOfTabletsInstalled__c));
		fields.put('ip_address', account.IPAddress__c);
		fields.put('assets', assets);
		fields.put('open_captioning_enabled', account.OpenCaptioning__c);
		Map<String, Object> result = new Map<String, Object>();
		result.put('clinic', fields);

		return result;
	}

	/*******************************************************************************************************
	* @description 					The purpose of this method is to build a map with each billing zip code 
	* 								from a list of accounts and return a Map with the key being the DMA Zip 
	* 								Code and the value the Id of the DMA Zip Code record
	* 
	* @param[accounts] 				List<Accounts>
	* @return 						Map<String, Id>
	* 
	*/
	public static Map<String, Id> getDmaZipCodeMapForAccountBillingCodes(List<Account> accounts) {
		
		Map<String, Id> zipCodeNameToId = new Map<String, Id>();
		if (ListUtils.isNullOrEmpty(accounts)) return zipCodeNameToId; /* return empty map if not accounts passed */
		Set<String> billingZipCodeSet = new Set<String>();

		for (Account account : accounts) {
			billingZipCodeSet.add(StringUtils.parse5DigitZipCode(account.BillingPostalCode));
		}

		if (SetUtils.isNotNullOrEmpty(billingZipCodeSet)) {
			for (Zip_Code_Data__c zipCodeDataItem : [SELECT Id, Name FROM Zip_Code_Data__c WHERE Name IN :billingZipCodeSet]) {
				zipCodeNameToId.put(zipCodeDataItem.Name, zipCodeDataItem.Id);
			}
		}
		return zipCodeNameToId;
	}

	/*******************************************************************************************************
	* @description					The purpose of the method is to auto-populate DMA Zip Code Lookup field on the Account
	* 								object if account has a billing zip code and the method finds a valid DMA Zip Code
	* 								record by the given Account Billing Zip Code
	* 								
	* @param[accounts] 				List<Accounts> passed in the beforeUpdate/Insert trigger context
	* @param[zipCodeNameToId] 		Map<String, Id> this variable should be processed in the bulkBefore method
	* @return 						void
	* 
	*/
	public static void populateDmaZipCode(List<Account> accounts, Map<String, Id> zipCodeNameToId) {
		
		if (ListUtils.isNotNullOrEmpty(accounts)) {

			for (Account account :accounts) {
				String zipCode = StringUtils.parse5DigitZipCode(account.BillingPostalCode);
				if (!String.isEmpty(zipCode)) {
					account.DMA_Zip_Code__c = zipCodeNameToId.get(zipCode);
				} else {
					/* Setting DMA Zip Code to blank, if zip code is not found below the prefered result is to have blank */
					account.DMA_Zip_Code__c = null;
				}
			}
		}
	}
}