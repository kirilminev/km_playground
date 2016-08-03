public with sharing class CaseNotesClass {
	
	private final Case thisCase;
    
    public CaseNotesClass(ApexPages.StandardController stdController) {
        this.thisCase = (Case)stdController.getRecord();
    }
    
	public string notes {
		get {
				if (String.isBlank(notes)) {
					
					notes = '';
					
					for (Case_Note__c cn : [
						SELECT Note_Body__c, Priority__c, CreatedBy.Name, Createddate
						FROM Case_Note__c 
						WHERE Case__c = :thisCase.Id
						ORDER BY CreatedDate ASC
						]) {
						
						string color = (cn.Priority__c) ? 'red' : 'black';
						
						notes += '<p/>'
						+ '<font color = \'' + color + '\' >' 
						+ '--- Created by <b>' 
						+ cn.CreatedBy.Name 
						+ '</b> on <b>' 
						+  cn.Createddate.format('M/d/yyyy h:mm a')
						+ '</b><br/>';
						
						notes += cn.Note_Body__c + '</font>';
						
					}
				}
			
			return notes;
		}
		set;
	}
	
}