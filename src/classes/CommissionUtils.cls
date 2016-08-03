/*******************************************************************************************************
* @description 		Purpose of this class is to provide utility and helper methods for the commissions 
*                	functionality
* @usage
* 
*/
public without sharing class CommissionUtils {
	
	private static CommissionUtils instance = null;
	
	public static final Integer NO_ACCELERATOR = -1;
	public static final Integer ACCELERATOR_STAGE_1 = 1;
	public static final Integer ACCELERATOR_STAGE_2 = 2;

	public static final String COMMISSION_RATE_CARD_KEY_DELIMITER = '_';
	public Integer lowestPriority {private set; get;}
	public Integer highestPriority {private set; get;}
	public Map<Integer, String> priorityToQualificationTypeMap {private set; get;}
	public Map<String, Integer> qualificationTypeToPriorityMap {private set; get;}
	public Set<String> validMembershipTeams {private set; get;}
	public Set<String> validQualificationTypes {private set; get;}
	//Property is set to private, because the key could be 18 or 15 characters and 
	//therefore we will handle this in util get method
	@TestVisible
	private Map<String, Role_Team_Map__c> roleTeamMap;
	public Map<String, Commission_Rate_Card__c> commissionRatesMap {private set; get;}
	/* 
		Enabled Opportunity Record Type Names will be managed in custom setting Commissions_Calculator_Global__c.Enabled_Opportunity_Record_Type_Names__c 
		based on the comma delimited record type names we will generate the set with record type ids
	*/
	@TestVisible
	public Set<Id> enabledOpportunityRecordTypeIds {
		private set;
		public get;
	}

	private CommissionUtils() {
		setPriorities();
		setPriorityToQualificationTypeMap();
		populateSetWithAvailableQualificationTypes();
		populateSetWithAvailableMembershipTeams();
		roleTeamMap = Role_Team_Map__c.getAll();
		populateCommissionRatesMap();
		populateEnabledRecordTypeIds();
	}

	public static CommissionUtils getInstance() {
		if(instance == null) instance = new CommissionUtils();
        return instance;
	}

	/*******************************************************************************************************
	* @description 						  Helper method to return commission rate amount for given team,
	*                      				  qualification type and product code. The map is housed in 
	*                      				  Commission_Rate_Card__c custom setting
	*                      				  
	* 
	* @param [String membershipTeam]
	* 
	* @param [String qualificationType]   qualificaiton types should alway allign with the qualification type
	*                					  global picklist value
	* @param [String productCode]		  productCode related to opportunity line item's related product
	* 
	* @return 							  Decimal -> Commission Rate Amount 
	*                          			  0 return will indicate that rate card was not found
	*/
	public Decimal getCommissionCardRateAmount(String membershipTeam, String qualificationType, String productCode, Integer acceleratorStage) {
		
		if (!this.validQualificationTypes.contains(qualificationType)) {
			throw new LoggingUtils.CustomException('Qualification Type: [' + qualificationType + '] not a valid option.\n' + 
													 'Please contact your Salesforce Support Team and take a screenshot of this error message.');
		}

		if (!this.validMembershipTeams.contains(membershipTeam)) {
			throw new LoggingUtils.CustomException('Membership Team: [' + membershipTeam + '] not a valid option.\n' + 
													 'Please contact your Salesforce Support Team and take a screenshot of this error message.');
		}

		Commission_Rate_Card__c commissionRateCard = commissionRatesMap.get(membershipTeam + COMMISSION_RATE_CARD_KEY_DELIMITER +
																			qualificationType + COMMISSION_RATE_CARD_KEY_DELIMITER +
																			productCode);

		Decimal commissionAmount = 0.00;

		if (commissionRateCard != null) {
			if (acceleratorStage == 2 && commissionRateCard.Inflated_Rate_Second_Stage__c != 0) {
	 			commissionAmount = commissionRateCard.Inflated_Rate_Second_Stage__c;
			} else if (acceleratorStage == 1 && commissionRateCard.Inflated_Rate__c != 0) {
				commissionAmount = commissionRateCard.Inflated_Rate__c;
			} else if (acceleratorStage == -1) {
				commissionAmount = commissionRateCard.Rate_Amount__c;
			} else {
				commissionAmount = commissionRateCard.Rate_Amount__c;
			}
		}	
		return commissionAmount;
	}

	/*******************************************************************************************************
	* @description 						  Helper method to return commission rate amount for given team,
	*                      				  qualification type and product code. The map is housed in 
	*                      				  Commission_Rate_Card__c custom setting
	*                      				  
	* 
	* @param [String membershipTeam]
	* 
	* @param [String qualificationType]   qualificaiton types should alway allign with the qualification type
	*                					  global picklist value
	* @param [String productCode]		  productCode related to opportunity line item's related product
	* 
	* @return 							  Decimal -> Commission Rate Amount 
	*                          			  0 return will indicate that rate card was not found
	*/
	public Decimal getCommissionCardRateAmount(String membershipTeam, String qualificationType, String productCode) {
		return getCommissionCardRateAmount(membershipTeam, qualificationType, productCode, NO_ACCELERATOR);
	}

	/*******************************************************************************************************
	* @description 		Return custom setting object Role_Team_Map__c for given UserRoleId
	* 
	* @param 			[String] userRoleId
	* @return 			[Role_Team_Map__c]
	* 
	* 
	*/
	public Role_Team_Map__c getUserRoleTeamInfo(String userRoleId){
		return roleTeamMap.get(StringUtils.left(userRoleId, 15));
	}

	/*******************************************************************************************************
	* @description 	Method will check list of opportunities and it will return a list with the opportunities
	*               which match RecordTypeIds specified in Commissions_Calculator_Global__c.Enabled_Opportunity_Record_Type_Names__c
	* 
	* @param 		[List<Opportunity> opportunities]
	* @return 		[List<Opportunity>] -> List of opportunities with RecordTypeIds that are specified in
	*               custom setting Commissions_Calculator_Global__c
	* 
	*/
	public List<Opportunity> getEligibleOpportunitiesForCommission(List<Opportunity> opportunities) {
		
		if (ListUtils.isNotNullOrEmpty(opportunities)) {

			List<Opportunity> eligibleOpportunities = new List<Opportunity>();
			
			for (Opportunity opportunityTemp :opportunities) {
				if(isOpportunityRecordTypeIdEnabled(opportunityTemp.RecordTypeId)) {
					eligibleOpportunities.add(opportunityTemp);
				}
			}
			return eligibleOpportunities;
		} else {
			return null;
		}
	}

	/*******************************************************************************************************
	* @description 		Method will check if given Opportunity Record Type Id has been enabled for commission
	*                	calculator though global custom setting Commissions_Calculator_Global__c
	* 
	* @param 			Id opportunityRecordTypeId -> Opportunity Record Type Id
	* @return 			Boolean
	* 
	*/
	public Boolean isOpportunityRecordTypeIdEnabled(Id opportunityRecordTypeId) {
		return this.enabledOpportunityRecordTypeIds.contains(opportunityRecordTypeId);
	}

	/*******************************************************************************************************
	* @description 		Based on the number of closed won opportunities and custom setting thresholds it will
	*                	mark the give opportunity as stage 1 or stage 2 accelerator
	* 
	*/
	public void assignAcceleratorStageToOpportunity(String opportunityOwnerTeam, Integer numberOfOpportunitiesClosedWon, Opportunity opportunity) {
		
		if (String.isEmpty(opportunityOwnerTeam)) {
			throw new LoggingUtils.CustomException('Opportunity Owner Team must have a valid value.');
		}

		Commission_Accelerator_Threshold__c commissionAccelerator = Commission_Accelerator_Threshold__c.getInstance(opportunityOwnerTeam);

		if (commissionAccelerator != null) {
			if (String.isNotEmpty(commissionAccelerator.Accelerator_Stage_2__c) 
				&& (numberOfOpportunitiesClosedWon >= 
					Integer.valueOf(commissionAccelerator.Accelerator_Stage_2__c.split('-').get(0)))) {
				
				opportunity.Accelerator_Stage_1__c = false;
				opportunity.Accelerator_Stage_2__c = true;

			} else if (String.isNotEmpty(commissionAccelerator.Accelerator_Stage_1__c) 
				&& (numberOfOpportunitiesClosedWon >= 
					Integer.valueOf(commissionAccelerator.Accelerator_Stage_1__c.split('-').get(0)))) {
				
				opportunity.Accelerator_Stage_1__c = true;
				opportunity.Accelerator_Stage_2__c = false;
			}
		}
	}

	/*******************************************************************************************************
	* @description 		Return highest priority qualification type for given account with Contacts along with a
	*                	map containing the number of qualifications for given contacts list 
	* 
	*/
	public QualificationTypeVo calculateQualificationsInformationForAccount(Account account) {
		return calculateQualificationsInformationForAccount(account.Contacts);
	}

	/*******************************************************************************************************
	* @description 		Return highest priority qualification type for given list of contacts along with a
	*                	map containing the number of qualifications for given contacts list 
	* 
	*/
	public QualificationTypeVo calculateQualificationsInformationForAccount(List<Contact> contacts) {

		QualificationTypeVo computedQualificationTypeResult = new QualificationTypeVo();

		computedQualificationTypeResult.highestPriorityQualificationType = 'None';

		if (ListUtils.isNotNullOrEmpty(contacts)) {

			Map<String, Integer> numberOfContactsPerQualification = new Map<String, Integer>();
			List<Integer> contactsPriorities = new List<Integer>();

			for (Contact contact :contacts) {
				updateNumberOfContactsPerQualification(numberOfContactsPerQualification, contact);
				Integer tempPriority = CommissionUtils.getInstance().qualificationTypeToPriorityMap.get(contact.Qualification_Type__c);
				if (tempPriority > 0) {
					contactsPriorities.add(tempPriority);
				}
			}

			if (ListUtils.isNotNullOrEmpty(contactsPriorities)) {
				contactsPriorities.sort();
				computedQualificationTypeResult.highestPriorityQualificationType = CommissionUtils.getInstance()
													  .priorityToQualificationTypeMap
													  .get(contactsPriorities.get(0));
			}
			computedQualificationTypeResult.numberOfContactPerQualification = numberOfContactsPerQualification;
		}
		return computedQualificationTypeResult;
	}

	/*******************************************************************************************************
	* @description 			For given list of qualifications return what is the highest priority based on mapping
	*                 		in custom setting Qualification__c
	* 
	*/
	public Integer findHighestPriority(List<String> qualifications) {
		
		Integer highestPriorityResult = -1;
		
		try {
			if (ListUtils.isNotNullOrEmpty(qualifications)) {

				List<Integer> qualificationPriorities = new List<Integer>();

				for (String qualification :qualifications) {
					if (!'Not Qualified'.equalsIgnoreCase(qualification)) {
						try {
							qualificationPriorities.add(Integer.valueOf(Qualification__c.getInstance(qualification).Qualification_Priority__c));	
						}catch (NullPointerException nullEx) {
							//todo: re-enable exception when we have LoggingUtils feature to mark known
							//exception as acknowledged and prevent noise on Slack Channel
							//LoggingUtils.log(nullEx, true, true, false);
							continue;
						}
					}					
				}
				if (ListUtils.isNotNullOrEmpty(qualificationPriorities)) {
					qualificationPriorities.sort();
					highestPriorityResult = qualificationPriorities.get(0);
				}
			}
		} catch (Exception ex) {
			LoggingUtils.log(ex, true, true, true);
		}
		return highestPriorityResult;
	}

	/*******************************************************************************************************
	* @description  Build a map with the following key/value pairs for commission rate cards
	*               key Team + '_' + Qualification_Type__c + '_' + Product_Code__c
	*               
	* @example 		PES_Specialty_WIFI => value of map will be decimal rate amount
	*/
	@TestVisible
	private void populateCommissionRatesMap() {
		commissionRatesMap = new Map<String, Commission_Rate_Card__c>();

		for (Commission_Rate_Card__c commissionRateCard : Commission_Rate_Card__c.getAll().values()) {
			//build map key Team + '_' + Qualification_Type__c + '_' + Product_Code__c
			//example: PES_Specialty_WIFI => value of map will be decimal rate amount
			commissionRatesMap.put(commissionRateCard.Team__c + //key
								   '_' 
								   + commissionRateCard.Qualification_Type__c + 
								   '_' 
								   + commissionRateCard.Product_Code__c,
								   commissionRateCard);//Commission Rate Card
		}
	}

	/*******************************************************************************************************
	* @description 	Populate enabledOpportunityRecordTypeIds with Opportunity Record Type Ids based on record
	*               type names house in custom setting Commissions_Calculator_Global__c.Enabled_Opportunity_Record_Type_Names__c 
	* 
	*/
	@TestVisible
	private void populateEnabledRecordTypeIds() {
		
		this.enabledOpportunityRecordTypeIds = new Set<Id>();

		String enabledRecordTypeNames = Commissions_Calculator_Global__c.getInstance().Enabled_Opportunity_Record_Type_Names__c;
		
		if (String.isNotEmpty(enabledRecordTypeNames)) {
			
			List<String> recordTypeNames = enabledRecordTypeNames.deleteWhitespace().split(',');
			Map<String, Id> recordTypesResultMap = RecordTypeService.getByNamesAndObjectTypeWithDescribe('Opportunity', recordTypeNames);
			
			if (recordTypesResultMap != null && recordTypesResultMap.size() > 0) {
				this.enabledOpportunityRecordTypeIds = new Set<Id>(recordTypesResultMap.values());	
			} else {
				LoggingUtils.log(new LoggingUtils.CustomException('Failed to retrieve Opportunity Record Type Ids in CommissionUtils setup logic!'), true, true, true);	
			}
		} else {
			LoggingUtils.log(new LoggingUtils.CustomException('Commissions_Calculator_Global__c.getInstance().Enabled_Opportunity_Record_Type_Names__c must have value!'), true, true, true);
		}
	}

	/*******************************************************************************************************
	* @description 		Retrieve membership teams from global pick list
	*  
	* @return 			void
	*/
	@TestVisible
	private void populateSetWithAvailableMembershipTeams() {
		List<SelectOption> pickListOptions = PickListUtils.getPickListOptions('Opportunity', 'Owner_Team__c');
		this.validMembershipTeams = new Set<String>();

		for (SelectOption option :pickListOptions) {
			this.validMembershipTeams.add(option.getValue());
		}
	}

	/*******************************************************************************************************
	* @description 		Retrieve  qualification types from global pick list
	*  
	* @return 			void
	*/
	@TestVisible
	private void populateSetWithAvailableQualificationTypes() {
		
		List<SelectOption> pickListOptions = PickListUtils.getPickListOptions('Contact', 'Qualification_Type__c');
		this.validQualificationTypes = new Set<String>();

		for (SelectOption option :pickListOptions) {
			this.validQualificationTypes.add(option.getValue());
		}
	}

	/*******************************************************************************************************
	* @description 
	* 
	* @assumptions		Assuming there is one-to-one mapping in custom setting between priority and qualificaiton type
	* 
	*/
	@TestVisible
	private void setPriorityToQualificationTypeMap() {

		this.priorityToQualificationTypeMap = new Map<Integer, String>();
		this.qualificationTypeToPriorityMap = new Map<String, Integer>();

		priorityToQualificationTypeMap.put(-1, 'None');//Not Qualified
		qualificationTypeToPriorityMap.put('None', -1);
		qualificationTypeToPriorityMap.put('Not Qualified', -1);

		for (Qualification__c qualification : Qualification__c.getAll().values()) {
			priorityToQualificationTypeMap.put(Integer.valueOf(qualification.Qualification_Priority__c), qualification.Qualification_Type__c);
			qualificationTypeToPriorityMap.put(qualification.Qualification_Type__c, Integer.valueOf(qualification.Qualification_Priority__c));
		}
	}

	/*******************************************************************************************************
	* @description 		Setup maps based on Qualification__c custom setting to represent mapping of priorities
	*                	to qualification type and vice versa
	* 
	*/
	@TestVisible
	private void setPriorities() {
		Map<String, Qualification__c> qualificationSettings = Qualification__c.getAll();

		if (qualificationSettings != null && ListUtils.isNotNullOrEmpty(qualificationSettings.values())) {
			Integer max = Integer.valueOf(qualificationSettings.values().get(0).Qualification_Priority__c);
			Integer min = Integer.valueOf(qualificationSettings.values().get(0).Qualification_Priority__c);

			for (Integer i = 1; i < qualificationSettings.values().size(); i++) {
				Integer tempPriority = Integer.valueOf(qualificationSettings.values().get(i).Qualification_Priority__c);

				if (tempPriority > max){ 
	            	max = tempPriority;  
	            }
	            if (tempPriority < min){ 
		            min = tempPriority;  
		        }
			}
			lowestPriority = max;
			highestPriority = min;
		}
	}

	/*******************************************************************************************************
	* @description 		The purpose of the method is to take Account's contacts along with a map Map<String, Integer>
	*                	and calculate the number of occurances of each qualificaiton in the list of contacts 
	* 
	* @param 			[Map<String, Integer>] numberOfContactsPerQualification - Parameter will be passed into
	*                   method and update with the total count of contact for each qualificaiton. The map will
	*                   contain the key=Qualificaiton and the Integer value which will be the total count of
	*                   contacts which had the given qulificaiton in their Qualificaiton__c field
	*                   
	* @param 			[Contact] contact - Parameter will contain the contact based on which we will be calculating
	*                   the total count of qualifications
	*					 
	* @return 			void
	*/
	@TestVisible
	private void updateNumberOfContactsPerQualification(Map<String, Integer> numberOfContactsPerQualification, Contact contact) {
		if (numberOfContactsPerQualification == null) {
			throw new LoggingUtils.CustomException('Exception in CommissionUtils.updateQualificationNumber(args...) occured! \n' +
													 'Error Message: numberOfContactsPerQualification parameter cannot be null');
		}
		if (String.isNotEmpty(contact.Qualification__c) && String.isNotEmpty(contact.NPI__c)) {
			for (String qualification : contact.Qualification__c.split(';')) {
				if (numberOfContactsPerQualification.get(qualification) == null) {
					numberOfContactsPerQualification.put(qualification, 1);
				} else {
					Integer tempCount = numberOfContactsPerQualification.get(qualification);
					tempCount ++;
					numberOfContactsPerQualification.put(qualification, tempCount);
				}
			}	
		}
	}

	/*******************************************************************************************************
	* @description 	This class/value object is only used to hold data for qualificaiton type logic and pass this
	*               computed data among other methods
	* 
	*/
	public class QualificationTypeVo{

		public String highestPriorityQualificationType{set; get;}
		public Map<String, Integer> numberOfContactPerQualification{set; get;}

	}
}