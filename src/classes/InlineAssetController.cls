/*
 * Created By : Lister
 * Created Date : 3-Apr-2014
 * Created Purpose : Extension controller class Inline Asset page
 * Test Class : TestAssetInline
 */
public with sharing class InlineAssetController {
    public final Case CASEx {get; set;}
    public List<Asset> assets {get; set;}
    public String assetId {get; set;}
    public String accountId {get; set;}
    public String assetIdEdit {get; set;} 
    
    public PageReference editAsset(){
        PageReference pageRef = new PageReference('/'+AssetIdEdit+'/e?retURL=%2F'+AssetIdEdit);
        pageRef.setRedirect(true);
        return pageRef ;
    }
    
    public InlineAssetController(ApexPages.StandardController standardController){
        Id CaseId = standardController.getRecord().Id;
        this.CASEx = [select Id, AccountId from Case where Id =:CaseId ];
        assets = new List<Asset>();
        assets = [select    Id, 
                            AccountId,
                            Model__c,  
                            Name, 
                            OS__c,
                            Outlet_Lock_Reason__c,
                            Player_location_at_site__c,
                            SerialNumber,
                            Status, 
                            Type__c
                    from Asset 
                    where AccountId =:CASEx.AccountId];
    }
    
}