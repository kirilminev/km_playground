public virtual class CaseDetailsActions {
	@RemoteAction
	public static Map<String, Object> getOptions(Id caseId) {
		try {
			Case thisCase = CaseService.getWithServiceDatesById(caseId, new List<String> {'AccountId',
																						  'Status'}, new List<String> {'Technician_Name__c'});

			List<Asset> thisAssets = AssetService.getByRelatedWorkOrderId(thisCase.Id, new List<String> {	'Id',
																								 			'Name',
																								 			'OutletLock__c',
																								 			'Outlet_Lock_Reason__c',
																								 			'Product2.ProductCode',
																								 			'Status',
																								 			'Type__c'});

			List<String> outletLockReasons = new List<String>();
	        
	        List<Schema.PicklistEntry> outletLockReasonEntries = Asset.Outlet_Lock_Reason__c.getDescribe().getPicklistValues();
	        
	        for (Schema.PicklistEntry entry : outletLockReasonEntries) {
	            outletLockReasons.add(entry.getValue());
	        }

	        return new Map<String, Object> {
	        	'assets' => thisAssets,
	        	'case' => thisCase,
	        	'outletLockReasons' => outletLockReasons
	        };
		}
		catch (Exception ex) {
			 throw ex;
		}
		return null;
	}

	@RemoteAction
	public static void close(Id caseId, List<Asset> assets) {
		try {
			Case thisCase = new Case(Id = caseId, Status = 'Closed');
			update thisCase;
			update assets;
		}
		catch (DmlException ex) {
			throw ex;
		}
	}
}