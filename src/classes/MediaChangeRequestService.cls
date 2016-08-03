public with sharing class MediaChangeRequestService {
	
	public static void submitRequests(List<MediaChangeRequest__c> requests) {
		List<Approval.ProcessSubmitRequest> approvalProcessRequests = new List<Approval.ProcessSubmitRequest>();
		for (MediaChangeRequest__c request : requests) {
			if (request.Submit__c) {
				Approval.ProcessSubmitRequest approvalProcessRequest = new Approval.ProcessSubmitRequest();
				approvalProcessRequest.setObjectId(request.Id);
				approvalProcessRequests.add(approvalProcessRequest);
			}
		}
		if (ListUtils.isNotNullOrEmpty(approvalProcessRequests)) {
			List<Approval.ProcessResult> results = Approval.process(approvalProcessRequests);
		}
	}

	public static void updateAge(List<MediaChangeRequest__c> requests, Map<Id, MediaChangeRequest__c> oldRequests) {
		BusinessHours hours = BusinessHoursService.getByName(new Constants.BusinessHours().MEDIA_BUSINESS_HOURS, new List<String>{'Id'});
		for (MediaChangeRequest__c request : requests) {
			if (request.CompletedDate__c != oldRequests.get(request.Id).CompletedDate__c && request.DateAssigned__c != null && request.CompletedDate__c != null) {
				request.AgeInBusinessHours__c = Decimal.valueOf(BusinessHours.diff(hours.Id, request.DateAssigned__c, request.CompletedDate__c)) / 3600000;
			}
		}
	}	
}