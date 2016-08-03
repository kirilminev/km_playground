public class ServiceDateService {
	private static final String SERVICEDATEx = 'Service_Date__c';

	public static void updateFurthestServiceDateInformation(List<Service_Date__c> serviceDates) {
		if (ListUtils.isNullOrEmpty(serviceDates)) {
			return;
		}
		List<Id> caseIds = new List<Id>();
		for (Service_Date__c serviceDate : serviceDates) {
			caseIds.add(serviceDate.Related_Work_Order__c);
		}
		List<Case> cases = CaseService.getWithServiceDatesByIds(caseIds, new List<String> { 'Id',
																							'LatestServiceDateEnd__c',
																							'LatestServiceDateStart__c'}, new List<String> { 'Id',
																																			 'CheckedInYES__c',
																																			 'CheckedOutYES__c',
																																			 'CheckInTime__c',
																																			 'CheckOutTime__c',
																																			 'ServiceDateEnd__c',
																																			 'ServiceDateStart__c',
																																			 'Technician_Name__r.Name'});
		Service_Date__c furthestServiceDate;
		List<Case> casesToUpdate = new List<Case>();
		for (Case workOrder : cases) {
			furthestServiceDate = getFurthestServiceDateByCase(workOrder);
			if (furthestServiceDate == null) {
				workOrder.LatestServiceDateStart__c = null;
				workOrder.LatestServiceDateEnd__c = null;
				workOrder.Checked_In__c = false;
				workOrder.Checked_Out__c = false;
				workOrder.CheckInTime__c = null;
				workOrder.CheckOutTime__c = null;
				workOrder.TechName__c = null;
				casesToUpdate.add(workOrder);
				continue;
			}
			else {
				workOrder.LatestServiceDateStart__c = furthestServiceDate.ServiceDateStart__c;
				workOrder.LatestServiceDateEnd__c = furthestServiceDate.ServiceDateEnd__c;
				workOrder.Checked_In__c = furthestServiceDate.CheckedInYES__c;
				workOrder.Checked_Out__c = furthestServiceDate.CheckedOutYES__c;
				workOrder.CheckInTime__c = furthestServiceDate.CheckInTime__c == null ? null : String.valueOf(furthestServiceDate.CheckInTime__c.format('MM/dd/yyyy hh:mm a'));
				workOrder.CheckOutTime__c = furthestServiceDate.CheckOutTime__c == null ? null : String.valueOf(furthestServiceDate.CheckOutTime__c.format('MM/dd/yyyy hh:mm a'));
				workOrder.TechName__c = furthestServiceDate.Technician_Name__r.Name;
				casesToUpdate.add(workOrder);
			}
		}
		if (ListUtils.isNotNullOrEmpty(casesToUpdate)) {
			try {
				update casesToUpdate;
			}
			catch(DmlException ex) {
				EmailUtils.sendTextEmail(new List<String> { 'matt.t@contextmediainc.com' }, 'ProductService DmlException', ex.getMessage());
			}
		}
	}


	public static Service_Date__c getById(Id serviceDateId, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(SERVICEDATEx)
						  .wherex(new FieldCondition('Id').equals(serviceDateId))
						  .toSoql();
		return Database.query(soql);
	}


	public static Service_Date__c getFurthestServiceDateByCase(Case workOrder) {
		Service_Date__c furthestServiceDate;

		if (ListUtils.isNullOrEmpty(workOrder.Service_Dates__r)) {
			return null;
		}
		else if (workOrder.Service_Dates__r.size() == 1) {
			return workOrder.Service_Dates__r[0];
		}
		else {
			for (Service_Date__c serviceDate : workOrder.Service_Dates__r) {
				if (furthestServiceDate == null) {
					furthestServiceDate = serviceDate;
					continue;
				}
				if (serviceDate.ServiceDateStart__c > furthestServiceDate.ServiceDateStart__c) {
					furthestServiceDate = serviceDate;
				}
			}
		}
		return furthestServiceDate;
	}


	/*******************************************************************************************************
    * @description      Check to see if ServiceDateEnd__c is within business hours and adds a DML error if
    *					it does not.
    * 
    * @return           void
    */
	public static void checkInstallBlackoutDates(List<Service_Date__c> serviceDates) {
		checkInstallBlackoutDates(null, serviceDates);
	}

	/*******************************************************************************************************
    * @description      Check to see if ServiceDateEnd__c is within business hours and adds a DML error if
    *					it does not.
    * 
    * @return           void
    */
	public static void checkInstallBlackoutDates(Map<Id, Service_Date__c> oldServiceDates, List<Service_Date__c> serviceDates) {
		if (ListUtils.isNullOrEmpty(serviceDates)) {
			return;
		}
		try {
			BusinessHours installDays = BusinessHoursService.getByName(new Constants.BusinessHours().INSTALL_DAYS, new List<String> {'Id','TimeZoneSidKey'});
			if (installDays != null) {
				for (Service_Date__c serviceDate : serviceDates) {
					if (serviceDate.ServiceDateEnd__c != null && (oldServiceDates == null || serviceDate.ServiceDateEnd__c != oldServiceDates.get(serviceDate.Id).ServiceDateEnd__c) && !BusinessHours.isWithin(installDays.id, serviceDate.ServiceDateEnd__c)) {
						serviceDate.addError('Date Not Available for Install');
					}
				}
			} else {
				// LoggingUtils.log(new LoggingUtils.LogInfo(new ServiceDateServiceException('BusinessHours Install Days not found')), true, true, true);  // waiting on SAL-92
				// don't stop user
			}
		} catch (exception e) {
			// LoggingUtils.log(new LoggingUtils.LogInfo(e), true, true, true);  // waiting on SAL-92
			// don't stop user
		}
	
	}

	public class ServiceDateServiceException extends Exception {}
}
