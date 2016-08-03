public with sharing class InstallationApprovalController {
	public Case installationApproval {get;set;}

	public Account account {get;set;}
	public Case workOrder {get;set;}
	public Service_Date__c serviceDate {get;set;}

	public List<String> connectivityMethods {get;set;}
	public String specialInstructions {get;set;}

	public InstallationApprovalController(ApexPages.StandardController standardController) { 
		installationApproval = (Case)standardController.getRecord();
		installationApproval = CaseService.getById(installationApproval.Id, new List<String> { 'Account.Name',
																							   'Account.NetworkDeploymentSpecialist__r.FirstName',
																							   'Account.NetworkDeploymentSpecialist__r.LastName',
																							   'Account.NetworkDeploymentSpecialist__r.Phone',
																							   'AccessToNetwork__c',
																							   'Best_Day_Time_etc_for_Install__c',
																							   'Connectivity_Method_New__c',
																							   'Daily_WiFi_Authentication_Required__c',
																							   'Data_Drop_Access__c',
																							   'Electrical_Outlet_near_requested_TV_loca__c',
																							   'Ethernet_outlet_near_requested_TV_loc__c',
																							   'Id',
																							   'If_No_distance_to_ethernet_outlet__c',
																							   'If_no_will_traffic_through_a_proxy_serv__c',
																							   'If_ports_not_accessible_can_ports_be_o__c',
																							   'Is_office_network_DHCP__c',
																							   'Is_WiFi_Available__c',
																							   'IT_Contact_Name__c',
																							   'IT_Email_Address__c',
																							   'IT_Phone_Number__c',
																							   'MPTypeofInternet__c',
																							   'NumberofTVRemovedRelocated__c',
																							   'Ports_10799_10805_21_80_443_access__c',
																							   'Recommended_Player_Type__c',
																							   'Status',
																							   'Subject',
																							   'TabletConnectionType__c',
																							   'WIFISpecialCharacters__c'
																							   });
		account = AccountService.getById(installationApproval.AccountId, new List<String> { 'CMHID__c',
																							'Id',
																							'Name'});
		workOrder = new Case();
		workOrder.RecordTypeId = RecordTypeService.getByNameAndObjectType(new Constants.CaseRecordTypes().WORK_ORDERS, 'Case', new List<String> {'Id'}).Id;
		workOrder.Type = new Constants.CaseTypes().NEW_INSTALLATION;
		workOrder.AccountId = account.Id;
		workOrder.ParentId = installationApproval.Id;
		workOrder.OwnerId = UserInfo.getUserId();

		serviceDate = new Service_Date__c();

		connectivityMethods = new List<String>();
		if (installationApproval.Connectivity_Method_New__c != null && installationApproval.Connectivity_Method_New__c != '') {
			connectivityMethods.addAll(installationApproval.Connectivity_Method_New__c.split(';'));
		}
		if (installationApproval.Status == new Constants.CaseStatuses().CLOSED) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, new Constants.InfoMessages().INSTALLATION_INFO_CLOSED));
		}
	}

	public PageReference submit() {
		if (installationApproval.Status == new Constants.CaseStatuses().CLOSED) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, new Constants.ExceptionMessages().INSTALLATION_EXCEPTION_CLOSED));
			return null;
		}
		if (ListUtils.isNullOrEmpty(connectivityMethods)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, new Constants.ExceptionMessages().INSTALLATION_EXCEPTION_CONNECTIVITY_METHOD));
			return null;
		}
		if (isMissingRequiredFields(installationApproval)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, new Constants.ExceptionMessages().INSTALLATION_EXCEPTION_REQUIRED_FIELDS));
			return null;
		}

		SavePoint savePoint = Database.setSavePoint();
		try {
			workOrder.Subject = workOrder.Type + ' @ ' + String.valueOf(serviceDate.ServiceDateStart__c.format('MM/dd/yyyy hh:mm a'));
			workOrder.ScopeofWorkNotes__c = CaseService.getScopeOfWork(String.valueOf(account.CMHID__c),
																	   workOrder,
																	   installationApproval,
																	   specialInstructions);
			upsert workOrder;

			serviceDate.Related_Work_Order__c = workOrder.Id;
			if (serviceDate.ServiceDateEnd__c == null) {
				serviceDate.ServiceDateEnd__c = serviceDate.ServiceDateStart__c;
			}
			upsert serviceDate;

			String connectivity = '';
			for (String method : connectivityMethods) {
				if (connectivity == '') {
					connectivity = method;
				}
				else {
					connectivity += ';' + method;
				}
			}
			installationApproval.Connectivity_Method_New__c = connectivity;
			installationApproval.Status = new Constants.CaseStatuses().CLOSED;
			update installationApproval;

			PageReference workOrderPage = Page.CaseDetails;
			workOrderPage.getParameters().put('id', workOrder.Id);
			return workOrderPage;
		}
		catch(Exception ex) {
			Database.rollback(savePoint);
			workOrder.Id = null;
			serviceDate.Id = null;
			serviceDate.Related_Work_Order__c = null;
			EmailUtils.sendHTMLEmail(new List<String> { 'matt.t@contextmediainc.com' }, new Constants.ExceptionMessages().INSTALLATION_EXCEPTION_SAVE, ex.getMessage() + '<br/><br/>' + ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
		return null;
	}

	private Boolean isMissingRequiredFields(Case installationApproval) {
		if (installationApproval.AccessToNetwork__c && 
			(installationApproval.Is_office_network_DHCP__c == null
			|| installationApproval.Electrical_Outlet_near_requested_TV_loca__c == null
			|| installationApproval.Data_Drop_Access__c == null
			|| installationApproval.NumberofTVRemovedRelocated__c == null
			|| installationApproval.Is_WiFi_Available__c == null
			|| installationApproval.Daily_WiFi_Authentication_Required__c == null)) {
			return true;
		}
		else {
			return false;
		}
	}

}