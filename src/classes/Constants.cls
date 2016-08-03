public class Constants {

	public class AccountNetworks {
		public final String DIABETES = 'Diabetes';
		public final String GI = 'GI';
		public final String HEART = 'Heart';
		public final String NEURO = 'Neuro';
		public final String RHEUMATOID = 'Rheumatoid';
	}

	public class AccountRecordTypes {
		public final String MEMBER_OUTREACH = 'Member Outreach';
		public final String MEMBER_SERVICES = 'Member Services';
		public final String SPONSORSHIP = 'Sponsorship';
		public final String TECHNICAL_SERVICE = 'Technical Service';
	}

	public class AccountStages {
		public final String UNCONFIRMED = 'Unconfirmed';
		public final String UNCONFIRMED_OUTREACH = 'Unconfirmed_Outreach';
		public final String CONFIRMED_UNSCHEDULED = 'Confirmed unscheduled';
		public final String WAITLIST = 'Waitlist';
		public final String PENDING_IT_COORDINATION = 'Pending IT coordination';
		public final String PENDING_COMPETITOR_REMOVAL = 'Pending competitor removal';
		public final String PENDING_LINE_DROP = 'Pending line drop';
		public final String SCHEDULED = 'Scheduled';
		public final String INSTALLED = 'Installed';
		public final String PARTIAL_INSTALL_PLAYS_CONTENT = 'Partial install plays content';
		public final String PARTIAL_INSTALL_NO_CONTENT = 'Partial install no content';
		public final String PARTIAL_INSTALL_DVD = 'Partial install DVD';
		public final String PENDING_REPAIR_NO_CONTENT = 'Pending Repair - no content';
		public final String PENDING_REPAIR_PLAYING_CONTENT = 'Pending Repair - playing content';
		public final String DVD_SITE_PENDING_REPAIR_AWAITING_UPGRADE = 'DVD Site - Pending Repair/Awaiting Upgrade';
		public final String UNINSTALLED = 'Uninstalled';
		public final String RETIRED = 'Retired';
		public final String SOLD_DELAYED_CONFIRMATION = 'Sold Delayed Confirmation';
		public final String CONFIRMED_DELAYED_INSTALLATION = 'Confirmed Delayed Installation';
	}

	public class AssetInstallationStatuses {
		public final String ACTIVE = 'Active';
		public final String INACTIVE = 'Inactive';
		public final String PARTIAL_INSTALLATION = 'Partial Installation';
		public final String RETURNED = 'Returned';
	}

	public class AssetTypes {
		public final String ALL = 'All';
		public final String PLAYER = 'Player';
		public final String TABLET = 'Tablet';
	}

	public class BusinessHours {
		public final String INSTALL_DAYS = 'Install Days';
		public final String MEDIA_BUSINESS_HOURS = 'Media Business Hours';
		public final String SHIPPING_DAYS = 'Shipping Days';
	}

	public class CampaignStatuses {
		public final String ABORTED = 'Aborted';
		public final String COMPLETED = 'Completed';
		public final String IN_PROGRESS = 'In Progress';
		public final String PLANNED = 'Planned';
	}

	public class CampaignTypes {
		public final String SPONSORSHIP = 'Sponsorship';
	}

	public class CaseNoteSections {
		public final String PLAYER_SECTION = '<br/>PLAYER-<br/>'
										   + '1) Online in Broadsign and MDM?<br/>'
										   + '2) Player moved to active folder (or appropriate folder) and DU attached?<br/>'
										   + '3) Active/Basic Diagnostics Results? <br/>'
										   + '4) WiFi (Cradlepoint or Clinic), LAN, Sprint, or Verizon?';
		public final String TABLET_SECTION = '<br/>TABLET-<br/>'
										   + '1) Tablet online and playing content?<br/>'
										   + '2) Room numbers, mount type, date active, and JSON pushed?<br/>'
										   + '3) Can the tech access the buttons on the back of the stand?<br/>'
										   + '4) Cords run through the stand or tucked behind the mount?';
		public final String CHECKOUT_SECTION = '<br/>CHECK OUT-<br/>'
											 + 'Name:<br/>'
											 + '1) How did the (installation/repair) go today?<br/>'
											 + '2) Confirm clinic hours on the player/Tablet (ex. M-F 8am-5pm)?<br/>'
											 + '3) Is the volume at a good level?<br/>'
											 + '4) Did the technician clean up/tidy up cords?<br/>'
											 + '5) Do you have any questions for me?';
	}

	public class CaseRecordTypes {
		public final String IT_APPROVAL = 'IT Approval';
		public final String WORK_ORDERS = 'Work Orders';
	}

	public class CaseServices {
		public final String FULL_DEINSTALL = 'Full Deinstall';
	}

	public class CaseStatuses {
		public final String CLOSED = 'Closed';
	}

	public class CaseTypes {
		public final String NEW_INSTALLATION = 'New Installation';
		public final String REPAIR = 'Repair';
		public final String DEINSTALLATION = 'Deinstallation';
	}

	public class ContactQualifications {
		public final String NOT_QUALIFIED = 'Not Qualified';
		public final String NPI_MISSING_UNKNOWN = 'NPI Missing: Unknown';
	}

	public class ContactRecordTypes {
		public final String MEMBER_PRACTICE = 'Member Practice';
		public final String SERVICE_PROVIDER = 'Service Provider';
	}
	
	public class ExceptionMessages {
		public final String BROADSIGN_EXCEPTION_NOT_FOUND = 'Unable to connect to Broadsign. Please contact salesforce@contextmediainc.com for assistance. (';
		public final String CALLOUT_EXCEPTION_GENERIC = 'Unable to connect to an external system. Please contact salesforce@contextmediainc.com for assistance. (';
		public final String INSTALLATION_EXCEPTION_CLOSED = 'This installation approval has already been submitted. Please re-open the installation approval in order to continue.';
		public final String INSTALLATION_EXCEPTION_CONNECTIVITY_METHOD = 'Please select at least one connectivity method.';
		public final String INSTALLATION_EXCEPTION_REQUESTED_DATE = 'The chosen requested date of arrival is not valid. Please enter a different date.';
		public final String INSTALLATION_EXCEPTION_REQUIRED_FIELDS = 'One or more required fields have not been filled out. Please fill out all required fields in order to continue.';
		public final String INSTALLATION_EXCEPTION_SAVE = 'Error processing a new installation';
		public final String MDM_EXCEPTION_NOT_FOUND = 'Unable to connect to MDM. Please contact salesforce@contextmediainc.com for assistance.';
		public final String SHIPMENT_EXCEPTION_ALREADY_PROCESSED = 'This order can no longer be modified or canceled as it has already been processed.';
		public final String SHIPMENT_EXCEPTION_BAD_REQUEST = 'There was an issue submitting this order with the given information. Please review before re-submitting.';
		public final String SHIPMENT_EXCEPTION_CONFLICT = 'An order with this ID already exists in the system.';
		public final String SHIPMENT_EXCEPTION_UPDATE_CONFLICT = 'This order is already in production and can no longer be modified.';
		public final String SHIPMENT_EXCEPTION_INTERNAL_SERVER_ERROR = 'There was an issue with submitting this request. Please wait a moment and try again. If your problem persists, please contact your administrator.';
		public final String SHIPMENT_EXCEPTION_ORDER_NOT_FOUND = 'This order was not found.';
		public final String SHIPMENT_EXCEPTION_SAVE_ERROR = 'There was an issue saving this shipment. Please correct the following errors before submitting again. (';
		public final String SHIPMENT_EXCEPTION_UNAUTHORIZED = 'There was an issue with authorizing your shipment request. Please wait a moment and try again. If your problem persists, please contact your administrator.';
		public final String SHIPMENT_EXCEPTION_UNKNOWN_ERROR = 'An unknown error has ocurred while submitting this request. (';
		public final String TRIGGER_EXCEPTION_INVALID_SOBJECT_TYPE = 'No trigger handler registered for Object Type: ';
		public final String SHIPMENT_EXCEPTION_UNKNOWN_STATUS_CODE = 'An uknown status code returned from iD!\nStatus code returned: ';
	}

	public class InfoMessages {
		public final String INSTALLATION_INFO_CLOSED = 'This installation approval has already been submitted. You will be unable to submit again.';
	}

	public class OrganizationIds {
		public final Id DEV_ID = '00DL0000005sUSi';
		public final Id PRODUCTION_ID = '00D80000000Zf8Z';
		public final Id STAGING_ID = '00DM0000001e6Iz';
	}

	public class PermissionSetNames {
		public final String MDM_INTEGRATION_USER = 'MdmIntegrationUser';
	}

	public class ProductCodes {
		public final String RETURN_LABEL = 'LAB101';
	}

	public class ProductPackages {
		public final String INSTALLATION_BAG_KIT = 'Installation Bag Kit';
		public final String REPAIR_BAG_KIT = 'Repair Bag Kit';
	}

	public class ProductRecordTypes {
		public final String MEMBERSHIP = 'Membership';
		public final String SPONSORSHIP = 'Sponsorship';
		public final String SUPPLY_CHAIN = 'Supply Chain';
	}

	public class ProductSubTypes {
		public final String DHN_1 = 'DHN 1.0'; //This is deprecated.
		public final String HHN_1 = 'HHN 1.0'; //This is deprecated.
		public final String BROCHURE_HOLDER = 'Brochure Holder (Pair)';
		public final String CLINIC_SLIDES = 'Clinic Slides';
		public final String DHN_2 = 'DHN 2.0';
		public final String HHN_2 = 'HHN 2.0';
		public final String RHN_2 = 'RHN 2.0';
		public final String NHN_2 = 'NHN 2.0';
		public final String GI_2 = 'GI 2.0';
		public final String RHN_IR_SCREEN = 'RHN IR Screen';
		public final String EXAM_ROOM_SCREEN = 'Exam Room Screen';
		public final String EXAM_ROOM_TABLET_RHN = 'Exam Room Tablet - RHN';
		public final String EXAM_ROOM_TABLET_DHN = 'Exam Room Tablet - DHN';
		public final String EXAM_ROOM_TABLET_CMH = 'Exam Room Tablet - CMH';
		public final String EXAM_ROOM_TABLET_NHN = 'Exam Room Tablet - NHN';
		public final String EXAM_ROOM_TABLET_GI = 'Exam Room Tablet - GI';
	}

	public class Teams {
		public final String PES = 'PES';
		public final String MSE = 'MSE';
	}

	public class ProductTypes {
		public final String TABLET = 'Tablet';
		public final String WAITING_ROOM_SCREEN = 'Waiting Room Screen';
	}

	public class SalesStages {
		public final String HOLD_ON_CALLING = 'Hold on Calling';
		public final String INITIAL_TOUCH = 'Initial Touch';
		public final String OBJECTION = 'Objection';
		public final String ONGOING_DIALOGUE = 'Ongoing Dialogue';
		public final String OPEN = 'Open';
		public final String PITCHED_AND_INFO_SENT = 'Pitched & Info Sent';
		public final String QUALIFIED = 'Qualified';
		public final String UNCONFIRMED_OUTREACH = 'Unconfirmed Outreach';
		public final String UNQUALIFIED = 'Unqualified';
		public final String VERBAL_COMMITMENT = 'Verbal Commitment';

		public final Map<String, Integer> STAGE_TO_ORDER;

		public SalesStages() {
			STAGE_TO_ORDER = new Map<String, Integer>();
			STAGE_TO_ORDER.put(PITCHED_AND_INFO_SENT, 1);
			STAGE_TO_ORDER.put(ONGOING_DIALOGUE, 2);
			STAGE_TO_ORDER.put(VERBAL_COMMITMENT, 3);
			STAGE_TO_ORDER.put(QUALIFIED, 4);
		}
	}
	
	public class ScopesOfWork {
		public final String IT_CONTACT_NAME = 'IT Contact Name: ';
		public final String IT_CONTACT_EMAIL = 'IT Contact Email: ';
		public final String IT_CONTACT_PHONE = 'IT Contact Phone: ';
		public final String SPECIAL_INSTRUCTIONS = 'Special Instructions: ';
		public final String TECHNICIAN_DUTIES_1 = 'Technician checks in with Vendor. ' + ' \r\n ';
		public final String WORK_ORDER = 'At this site we are installing the following: ';
		public final String CONTEXTMEDIA_NDS = 'ContextMedia NDS: ';
		public final String CLINIC_ID = 'Clinic ID: ';
		public final String BEST_DAY_TIME_FOR_WORK_ORDER = 'Best Day/Time For Work Order: ';
												
												//+ '1) The technician should arrive and introduce themselves to the office and then TEXT the ContextMedia Network' + ' \r\n '
												//+ 'Engineer at ____________ to confirm their arrival on site, check in, and see if we have added anything to the WO. If you have not received a response,' + ' \r\n '
												//+ 'please call the number listed, or reach out to your company for instruction.' + ' \r\n '
												//+ '2) At this site we are installing the following # of ';

		public final String SCOPE_SCREENS = 'TVs: ';
		public final String SCOPE_PLAYERS = ' PCs: ';
		public final String SCOPE_TABLETS = ' Tablets: ';
		public final String SCOPE_ROUTERS = ' Routers: ';

		public final String SCOPE_INTERNET_CONNECTION_TYPE = 'The Internet Connection Type For Player: ';
		public final String SCOPE_TABLET_CONNECTION_TYPE = 'Tablet Connection Type: ';
		//public final String TECHNICIAN_DUTIES_2 = '';
												//'4) Report how many, if any, sealed boxes are returning to ContextMedia.' + ' \r\n '
												//+ '5) Before checking out: Pictures must be sent before checking out to picture@contextmediainc.com. Must add Clinic ID to subject line.' + ' \r\n '
												//+ 'New installs of TVs will always require a video. Please email a 5 second video of the TV Playing content with the business card of the doctor or' + ' \r\n '
												//+ 'brochure, etc. clearly in the video to picture@contextmediainc.com with the CLINIC ID in the subject line.' + ' \r\n '
												//+ '6) ContextMedia will provide check out code once everything is complete. There may be additional equipment that requires troubleshooting. \r\n ';
		public final String SCOPE_RECAP = ' \r\n ' + 'Recap: ' + ' \r\n '
										+ 'Use the equipment provided (faceplate, toggle bolts, panduit, etc.) to complete installation.' + ' \r\n '
										+ 'Use approved equipment. (Faceplate, Toggle Bolts, Panduit, etc.)' + ' \r\n '
										+ 'Hide player behind TV with power button facing down.' + ' \r\n '
										+ 'Cables must be hidden and organized.' + ' \r\n '
										+ 'Label Network Drops.' + ' \r\n '
										+ 'Routers/Access Points' + ' \r\n '
										+ 'Please call a ContextMedia Engineer before plugging it in.' + ' \r\n '
										+ 'Clinic ID: ';
	}

		
	public class ShipmentValidationMessages {
		public final String ADDRESS_INCOMPLETE = 'There is missing or invalid address information. Please correct the address before submitting again.';
		public final String CMH_ID = 'This account has no CMH ID. Please assign a CMH ID prior to submitting orders to this account.';
		public final String DMA_TIMEZONE = 'This account has no DMA Timezone. Please assign a Timezone to the DMA Zip Code related to the account prior to submitting orders to this account.';
		public final String DMA_ZIP = 'This account has no DMA Zip Code. Please assign a DMA Zip Code prior to submitting orders to this account.';
		public final String EXPEDITE_REASON = 'Expedite reason is required for expedited shipments.';
		public final String ITEMS_TO_RETURN = 'You must add products or select assets to be returned in order to submit this order.';
		public final String LINE_ITEM_QUANTITY = 'One or more of the products are missing quantities. Enter a valid quantity for every product prior to re-submitting this order.';
		public final String NETWORK = 'Content Requested must be entered on the Account prior to submitting orders.';
		public final String PHONE_NUMBER = 'Phone number is required for a contact to be used as the shipment contact.';
		public final String PRIMARY_CONTACT = 'Primary contact is a required field.';
		public final String REQUESTED_DATE = 'Requested date of arrival is required.';
	}

	public class ShippingOrderRecordTypes {
		public final String SHIPPING_ORDER = 'Shipping Order';
		public final String RECEIVING_ORDER = 'Receiving Order';
	}

	public class SuccessMessages {
		public final String MDM_SUCCESSFUL_TABLET_SYNC = 'The changes you made to this tablet were successfully saved to MDM. Have a wonderful day!';
		public final String MDM_SUCCESSFUL_CLINIC_SYNC = 'I love what you did with the place! The changes you made to the tablets for this clinic have been successfully saved to MDM.';
	}
}