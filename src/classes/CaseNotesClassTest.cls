@isTest
private class CaseNotesClassTest {

    static testMethod void myUnitTest() {
		
		Case c = new Case();
		insert c;
		
		
		Case_Note__c n1 = new Case_Note__c(Case__c = c.Id,  Priority__c = true, Note_Body__c = 'test');
		Case_Note__c n2 = new Case_Note__c(Case__c = c.Id,  Priority__c = false, Note_Body__c = 'test');
		
		List <Case_Note__c> notes = new List <Case_Note__c>();
		
		notes.add(n1);
		notes.add(n2);
		
		insert notes;
		
		PageReference pageRef = Page.CaseNotesPage;
		pageRef.getParameters().put('id', c.Id);
		Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController controller = new ApexPages.StandardController(c);
        CaseNotesClass sc = new CaseNotesClass(controller);
        
        string caseNOtes = sc.notes;
    }
}