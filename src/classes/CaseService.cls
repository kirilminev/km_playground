public class CaseService {
	private static final String CASEx = 'Case';
	private static final String SERVICEDATESx = 'Service_Dates__r';
	private static final String SHIPMENTSx = 'Shipments__r';
	
	public static Case getById(Id caseId, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(CASEx)
						  .wherex(new FieldCondition('Id').equals(caseId))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Case> getByIds(List<Id> caseIds, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(CASEx)
						  .wherex(new SetCondition('Id').inx(caseIds))
						  .toSoql();
		return Database.query(soql);
	}

	public static Case getWithServiceDatesById(Id caseId, List<String> caseFields, List<String> serviceDateFields) {
		String soql = new SoqlBuilder()
						  .selectx(caseFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(serviceDateFields)
						  		.fromx(SERVICEDATESx))
						  .fromx(CASEx)
						  .wherex(new FieldCondition('Id').equals(caseId))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Case> getWithServiceDatesByIds(List<Id> caseIds, List<String> caseFields, List<String> serviceDateFields) {
		String soql = new SoqlBuilder()
						  .selectx(caseFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(serviceDateFields)
						  		.fromx(SERVICEDATESx))
						  .fromx(CASEx)
						  .wherex(new SetCondition('Id').inx(caseIds))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<Case> getWorkOrdersWithShipmentsByAccountId(Id accountId, List<String> caseFields, List<String> shipmentFields) {
		String soql = new SoqlBuilder()
						  .selectx(caseFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(shipmentFields)
						  		.fromx(SHIPMENTSx))
						  .fromx(CASEx)
						  .wherex(new AndCondition()
						  			  .add(new FieldCondition('RecordType.Name').equals(new Constants.CaseRecordTypes().WORK_ORDERS))
						  			  .add(new FieldCondition('AccountId').equals(accountId)))
						  .toSoql();
		return Database.query(soql);
	}

	public static String getScopeOfWork(String clinicId, Case workOrder, Case installationApproval, String specialInstructions) {
		Constants.ScopesOfWork scope = new Constants.ScopesOfWork();
		String scopeOfWork = '';

		scopeOfWork += scope.TECHNICIAN_DUTIES_1; scopeOfWork +=' \r\n'; 

		scopeOfWork += scope.CONTEXTMEDIA_NDS +  installationApproval.account.NetworkDeploymentSpecialist__r.FirstName 
		+  ' ' + installationApproval.account.NetworkDeploymentSpecialist__r.LastName ;
		if (installationApproval.account.NetworkDeploymentSpecialist__r.Phone != null && installationApproval.account.NetworkDeploymentSpecialist__r.Phone <>''){
			scopeOfWork += ' - '+ installationApproval.account.NetworkDeploymentSpecialist__r.Phone;
		}
		scopeOfWork +=' \r\n\r\n '; 

		if (installationApproval.IT_Contact_Name__c != null && installationApproval.IT_Contact_Name__c != '') {
			scopeOfWork += scope.IT_CONTACT_NAME
						 + installationApproval.IT_Contact_Name__c + ' \r\n '
						 + scope.IT_CONTACT_EMAIL
						 + installationApproval.IT_Email_Address__c + ' \r\n '
						 + scope.IT_CONTACT_PHONE
						 + installationApproval.IT_Phone_Number__c + ' \r\n\r\n ';
		}				 


		if (specialInstructions != null && specialInstructions != '') {
			scopeOfWork += scope.SPECIAL_INSTRUCTIONS;
			scopeOfWork += specialInstructions + ' \r\n\r\n ';
		}

		scopeOfWork +=scope.WORK_ORDER + ' \r\n ';

		if (workOrder.TVs_Being_Installed__c != null && workOrder.TVs_Being_Installed__c != '') {
			scopeOfWork += scope.SCOPE_SCREENS + workOrder.TVs_Being_Installed__c;
		}
		if (workOrder.Players_Being_Installed__c != null && workOrder.Players_Being_Installed__c != '') {
			scopeOfWork += scope.SCOPE_PLAYERS + workOrder.Players_Being_Installed__c;
		}
		if (workOrder.Tablets_Being_Installed__c != null && workOrder.Tablets_Being_Installed__c != '') {
			scopeOfWork += scope.SCOPE_TABLETS + workOrder.Tablets_Being_Installed__c;
		}
		if (workOrder.Routers_Being_Installed__c != null && workOrder.Routers_Being_Installed__c != '') {
			scopeOfWork += scope.SCOPE_ROUTERS + workOrder.Routers_Being_Installed__c;
		}

		scopeOfWork += ' \r\n\r\n ';
		if (workOrder.TVs_Being_Installed__c != null && workOrder.TVs_Being_Installed__c != ''
				|| workOrder.Players_Being_Installed__c != null && workOrder.Players_Being_Installed__c != '' ) {
		scopeOfWork += scope.SCOPE_INTERNET_CONNECTION_TYPE + installationApproval.Recommended_Player_Type__c;
		scopeOfWork += ' \r\n\r\n ';
		}

		if (workOrder.Tablets_Being_Installed__c != null && workOrder.Tablets_Being_Installed__c != '') {
		scopeOfWork += scope.SCOPE_TABLET_CONNECTION_TYPE + installationApproval.TabletConnectionType__c;
		scopeOfWork += ' \r\n\r\n ';
		}

		scopeOfWork += scope.ClINIC_ID + clinicId;
		scopeOfWork += ' \r\n\r\n ';

		if (installationApproval.Best_Day_Time_etc_for_Install__c != null && installationApproval.Best_Day_Time_etc_for_Install__c != '') {
		scopeOfWork += scope.BEST_DAY_TIME_FOR_WORK_ORDER + installationApproval.Best_Day_Time_etc_for_Install__c;
		}

		return scopeOfWork;
	}

	public static void getDeinstallApproval(List<Case> cases) {
		List<Approval.ProcessSubmitRequest> approvalProcessRequests = new List<Approval.ProcessSubmitRequest>();
		for (Case theCase : cases) {
			if (theCase.Service__c == 'Full Deinstall') {
				Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
				request.setObjectId(theCase.id);
				approvalProcessRequests.add(request);
			}
		}
		if (ListUtils.isNotNullOrEmpty(approvalProcessRequests)) {
			List<Approval.ProcessResult> results = Approval.process(approvalProcessRequests);
		}
	}

	public static void getDeinstallApproval(Map<Id, Case> oldCases, List<Case> cases) {
		List<Approval.ProcessSubmitRequest> approvalProcessRequests = new List<Approval.ProcessSubmitRequest>();
		for (Case theCase : cases) {
			if (theCase.Service__c == new Constants.CaseServices().FULL_DEINSTALL && oldCases.get(theCase.Id).Service__c != new Constants.CaseServices().FULL_DEINSTALL) {
				Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
				request.setObjectId(theCase.id);
				approvalProcessRequests.add(request);
			}
		}
		if (ListUtils.isNotNullOrEmpty(approvalProcessRequests)) {
			List<Approval.ProcessResult> results = Approval.process(approvalProcessRequests);
		}
	}

	public static void validateWorkOrderClosure(Map<Id, Case> oldSoMap, List<Case> soList) {
		Map<Id, Schema.RecordTypeInfo> recordTypes = Schema.getGlobalDescribe().get(CASEx).getDescribe().getRecordTypeInfosById();

		if (soList.size() == 1) {
			system.debug('Record Type: ' + recordTypes.get(soList[0].RecordTypeId).getName());
			if (recordTypes.get(soList[0].RecordTypeId).getName() == new Constants.CaseRecordTypes().WORK_ORDERS && soList[0].Status == new Constants.CaseStatuses().CLOSED && oldSoMap.get(soList[0].Id).Status != new Constants.CaseStatuses().CLOSED && soList[0].AccountId != null) {
				validateWorkOrderClosure(String.valueOf(soList[0].CMH_ID__c), soList[0].Id);
			}
		}
	}

	@future(callout=true)
	private static void validateWorkOrderClosure(String clinicId, Id workOrderId) {
		Map<String, Object> mdmResponse;
		Map<String, Object> mdmDevices = new Map<String, Object>();
		Map<String, Object> broadsignResponse;
		try {
			mdmResponse = MdmDelegate.getMdmStatusesByClinicId(clinicId);
			Object devicesObject;
			if (mdmResponse != null) {
				devicesObject = mdmResponse.get('devices');
			}
			if (devicesObject != null) {
				List<Object> devicesObjects = (List<Object>)devicesObject;
				for (Object device : devicesObjects) {
					Map<String, Object> deviceMap = (Map<String, Object>)device;
					for (String value : deviceMap.keySet()) {
						mdmDevices.put(value, deviceMap.get(value));
					}
				}
			}

			broadsignResponse = BroadsignDelegate.getBroadsignStatusesByClinicId(clinicId);
		}
		catch (MdmException ex) {
			EmailUtils.sendTextEmail(new List<String> {'matt.t@contextmediainc.com'}, 'Work Order Closure Mdm Exception', ex.getMessage());
		}
		catch (BroadsignException ex) {
			EmailUtils.sendTextEmail(new List<String> {'matt.t@contextmediainc.com'}, 'Work Order Closure Broadsign Exception', ex.getMessage());
		}
		catch (CalloutException ex) {
			EmailUtils.sendTextEmail(new List<String> {'matt.t@contextmediainc.com'}, 'Work Order Closure Callout Exception', ex.getMessage());
		}

		List<Asset> assetsToProcess = new List<Asset>();
		List<Asset> unknownAssets = new List<Asset>();
		List<Asset> assets = AssetService.getByRelatedWorkOrderId(workOrderId, new List<String> {'Name',
																								 'Shipment__c',
																								 'Status',
																								 'Type__c'});
		if (ListUtils.isNotNullOrEmpty(assets)) {
			for (Asset asset : assets) {
				if (asset.Status == 'Installed' && asset.Shipment__c == null) {
					if (asset.Type__c == new Constants.AssetTypes().TABLET) {
						if (mdmDevices.get(asset.Name) != null) {
							Map<String, Object> tabletResponse = (Map<String, Object>)mdmDevices.get(asset.Name);
							system.debug('Asset ' + asset.Name + ' is ' + tabletResponse.get('device_status'));
							if (tabletResponse.get('device_status') != 'up') {
								assetsToProcess.add(asset);
							}
						}
						else {
							unknownAssets.add(asset);
						}
					}
					else if (asset.Type__c == new Constants.AssetTypes().PLAYER) {
						if (broadsignResponse == null || broadsignResponse.get('error') != null) {
							unknownAssets.add(asset);
						}
						else {
							if (broadsignResponse.get(asset.Name) != null) {
								Map<String, Object> playerResponse = (Map<String, Object>)broadsignResponse.get(asset.Name);
								if ((String)playerResponse.get('status') != '1') {
									assetsToProcess.add(asset);
								}
							}
							else {
								unknownAssets.add(asset);
							}
						}
					}
				}
			}
		}

		if (ListUtils.isNotNullOrEmpty(assetsToProcess) || ListUtils.isNotNullOrEmpty(unknownAssets)) {
			Case workOrder = CaseService.getById(workOrderId, new List<String> {'Account.CMHID__c',
																				'Account.Name',
																				'CaseNumber',
																				'CreatedBy.Email',
																				'Owner.Email',
																				'Product__c',
																				'Service__c',
																				'Type'});
			workOrder.Status = 'Reopened';
			try {
				update workOrder;
				String emailBody = 'The ' + workOrder.Product__c + ' ' + workOrder.Service__c + ' work order for '
								 + workOrder.Account.Name + ' (' + clinicId + ') was closed but has been reopened because the following assets are either not online or were not found:  <br/><br/>';
				if (ListUtils.isNotNullOrEmpty(assetsToProcess)) {
					emailBody += '<strong>Offline Assets:</strong><br/>';
					for (Asset asset : assetsToProcess) {
						emailBody += asset.Name + ' - ' + asset.Type__c + ': <br/>'
								   + Url.getSalesforceBaseUrl().toExternalForm() + '/' + asset.Id + '<br/><br/>';
					}
				}
				if (ListUtils.isNotNullOrEmpty(unknownAssets)) {
					emailBody += '<strong>Unknown Assets:</strong><br/>';
					for (Asset asset : unknownAssets) {
						emailBody += asset.Name + ' - ' + asset.Type__c + ': <br/>'
								   + Url.getSalesforceBaseUrl().toExternalForm() + '/' + asset.Id + '<br/><br/>';
					}
				}
				emailBody += 'Please ensure these devices are online prior to closing the work order again. Here is a link to the work order: '
						   + Url.getSalesforceBaseUrl().toExternalForm() + '/' + workOrder.Id;
				EmailUtils.sendHtmlEmail(new List<String> {workOrder.Owner.Email, workOrder.CreatedBy.Email, 'matt.t@contextmediainc.com'}, 'Work Order ' + workOrder.CaseNumber + ' - Reopened', emailBody);
			}
			catch (DmlException ex) {
				EmailUtils.sendTextEmail(new List<String> {'matt.t@contextmediainc.com'}, 'DmlException in work order closure validation', ex.getMessage());
			}
		}
		else {
			system.debug('All Assets are ONLINE.');
		}
	}
}