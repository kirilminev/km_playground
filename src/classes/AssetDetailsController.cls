public with sharing class AssetDetailsController {
	ApexPages.StandardController controller;
	public Asset asset {get;set;}
	public Account account {get;set;}
	public Map<String, Object> broadsignData {get;set;}
	public Map<String, Object> mdmData {get;set;}
	public BroadsignBo broadsignBo {get;set;}
	public MdmBo mdmBo {get;set;}

	private Boolean isSynchronizedWithMdm {get;set;}

	public String broadsignStatus {
		get {
			if (broadsignBo != null) {
				if (broadsignBo.status == '0') {
					return '(Offline)';
				}
				else if (broadsignBo.status == '1') {
					return '(Online)';
				}
				else if (broadsignBo.status == '2') {
					return '(MIA)';
				}
				else {
					return '(Unknown)';
				}
			}
			else {
				return '(Unknown)';
			}
		}
		set;
	}

	public String mdmStatus {
		get {
			if (mdmBo.status == 'device-up') {
				return '(Online)';
			}
			else if (mdmBo.status == 'device-down') {
				return '(MIA)';
			}
			else {
				return '(Unknown)';
			}
		}
		set;
	}
	public String mdmLastSeen {get;set;}

	public AssetDetailsController(ApexPages.StandardController standardController) {
		controller = standardController;
		mdmBo = new MdmBo();
		broadsignBo = new BroadsignBo();
		isSynchronizedWithMdm = true;
		standardController.addFields(new List<String> { 'AccountId',
														'ClinicExamRoom__c',
													    'Id',
													    'Installation_Status__c',
													    'InstalledDate__c',
													    'MountType__c',
													    'Name',
													    'Speciality__c',
													    'Type__c',
													    'Volume__c'});
		asset = (Asset)standardController.getRecord();
		if (asset.AccountId != null) {
			account = AccountService.getById(asset.AccountId, new List<String> { 'CMHID__c',
																				 'Id',
																				 'Network__c'});
		}

		if (asset.Type__c != null && asset.Type__c == new Constants.AssetTypes().PLAYER) {
			try {
				broadsignData = BroadsignDelegate.getBroadsignStatus(asset.Name);
			}
			catch(BroadsignException ex) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			}
			catch(CalloutException coEx) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, new Constants.ExceptionMessages().CALLOUT_EXCEPTION_GENERIC + coEx.getMessage() + ')'));
			}
			if (broadsignData != null) {
				if (broadsignData.get('error') != null) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, new Constants.ExceptionMessages().BROADSIGN_EXCEPTION_NOT_FOUND + broadsignData.get('error') + ')'));
				}
				else {
					broadsignBo.avVersion = (String)broadsignData.get('AVVersion');
					broadsignBo.clockSkew = (String)broadsignData.get('ClockSkew');
					broadsignBo.currentLocation = (String)broadsignData.get('CurrentLocation');
					broadsignBo.currentlyDownloading = (String)broadsignData.get('CurrentlyDownloading');
					broadsignBo.currentlyPlaying = (String)broadsignData.get('CurrentlyPlaying');
					broadsignBo.currentVolume = (String)broadsignData.get('CurrentVolume');
					broadsignBo.displayUnitId = (String)broadsignData.get('display_unit_id');
					broadsignBo.issue = (String)broadsignData.get('Issue');
					broadsignBo.lastPoll = (String)broadsignData.get('lastpoll');
					broadsignBo.localTime = (String)broadsignData.get('LocalTime');
					broadsignBo.loopx = (String)broadsignData.get('loop');
					broadsignBo.name = (String)broadsignData.get('name');
					broadsignBo.nextAdToDownload = (String)broadsignData.get('NextAdToDownload');
					broadsignBo.nextPoll = (String)broadsignData.get('nextpoll');
					broadsignBo.playerId = (String)broadsignData.get('id');
					broadsignBo.playerVersion = (String)broadsignData.get('PlayerVersion');
					broadsignBo.screenResolution = (String)broadsignData.get('ScreenResolution');
					broadsignBo.status = (String)broadsignData.get('status');

					system.debug('Broadsign BO: ' + broadsignBo);
				}
			}
		}
		if (asset.Type__c == new Constants.AssetTypes().TABLET) {
			try {
				Map<String, Object> mdmData = MdmDelegate.getMdmStatus(asset);
				if (mdmData != null) {
					mdmBo.status = (String)mdmData.get('device_status');
					mdmBo.lastSeen = mdmData.get('last_seen_at') == '' ? null : DateTime.valueOf((String)mdmData.get('last_seen_at')).format('MM/dd/yyyy hh:mm a');
					mdmBo.speciality = (String)mdmData.get('speciality');
					asset.Speciality__c = mdmBo.speciality;
					mdmBo.volume = (Integer)mdmData.get('default_min_volume_in_percentage');
					asset.Volume__c = mdmBo.volume;
				}
				else {
					mdmStatus = '(Unknown)';
					mdmBo.lastSeen = '(Unknown)';
				}
			}
			catch(MdmException ex) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			}
			catch(CalloutException coEx) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, new Constants.ExceptionMessages().CALLOUT_EXCEPTION_GENERIC + coEx.getMessage() + ')'));
			}
		}
	}

	public void saveTablet() {
		try {
			Map<String, String> fields = new Map<String, String>();
			fields.put('asset_id', asset.Name);
			fields.put('clinic_id', String.valueOf(account == null ? null : account.CMHID__c));
			fields.put('clinic_exam_room', asset.ClinicExamRoom__c);
			fields.put('installed_date', String.valueOf(asset.InstalledDate__c));
			fields.put('mount_type', asset.MountType__c == null ? asset.MountType__c : asset.MountType__c.toLowerCase());
			fields.put('speciality', asset.Speciality__c);
			fields.put('status', asset.Installation_Status__c);
			fields.put('default_min_volume_in_percentage', String.valueOf(asset.Volume__c));
			MdmDelegate.updateAssetInMdm(fields, asset.Type__c.toLowerCase());
			update asset;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, new Constants.SuccessMessages().MDM_SUCCESSFUL_TABLET_SYNC));
		}
		catch(Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, new Constants.ExceptionMessages().CALLOUT_EXCEPTION_GENERIC + ex.getMessage() + ')'));
		}
	}
}