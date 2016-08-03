public with sharing class AccountStructure{

    public String accountId {get;set;}
    public String contactId {get;set;}
    public List<AccountContactRole> contactRoles {get;set;}
    public List<AccountContactRole> contactRolesToDelete {get;set;}
    public List<ObjectStructureMap> accountStructure;
    public Map<String, ObjectStructureMap> masm;
    public List<Integer> maxLevel;
    
    public AccountStructure() {
    	this.accountStructure = new List<ObjectStructureMap>();
    	this.masm = new Map<String, ObjectStructureMap>{};
    	this.maxLevel = new List<Integer>{};
    }
    
    public List<ObjectStructureMap> getObjectStructure() {
        accountStructure.clear();
        if (accountId == null) {
            accountId = System.currentPageReference().getParameters().get('id');
        }
        
        accountStructure = formatObjectStructure(accountId);
        
        return accountStructure;
    }

    public List<ObjectStructureMap> formatObjectStructure(String accountId){
        masm.clear();

        List<Account> accounts = new List<Account>();
        List<Id> accountIds = new List<Id>();
        Contact contact;
        Map<Id, AccountContactRole> accountContactRoles = new Map<Id, AccountContactRole>();
        Map<Id, String> nodeList = new Map<Id, String>();
        List<String> nodeSortList = new List<String>();
        List<Boolean> levelFlag = new List<Boolean>();
        List<Boolean> closeFlag = new List<Boolean>();
        String nodeId = '0';
        String nodeType = 'child';
        Integer count = 0;
        Integer level = 0;
        Boolean endOfStructure = false;
        
        accountIds.add(getTopAccountId(accountId));
        if (contactId != null) {
            contact = ContactService.getById(contactId, new List<String> {'Title__c'});
            contactRoles = ContactService.getAccountContactRolesByContactId(contactId, new List<String> {'AccountId',
                                                                                                         'ContactId',
                                                                                                         'Role'});
            contactRolesToDelete = new List<AccountContactRole>();
        }
        if (ListUtils.isNotNullOrEmpty(contactRoles)) {
            for (AccountContactRole contactRole : contactRoles) {
                accountContactRoles.put(contactRole.AccountId, contactRole);
            }
        }

        while (!endOfStructure) {
            if (level == 0) {
                accounts = AccountService.getByIdsWithOrder(accountIds, new List<String> {'CMHID__c',
                                                                                          'Id',
                                                                                          'Industry',
                                                                                          'Name',
                                                                                          'OwnerId',
                                                                                          'ParentId',
                                                                                          'Site',
                                                                                          'Type'}, 'Name');
            }
            else {
                accounts = AccountService.getByParentIdsWithOrder(accountIds, new List<String> {'CMHID__c',
                                                                                                'Id',
                                                                                                'Industry',
                                                                                                'Name',
                                                                                                'OwnerId',
                                                                                                'ParentId',
                                                                                                'Site',
                                                                                                'Type'}, 'Name');
            }

            if (accounts.size() == 0) {
                endOfStructure = true;
            }
            else {
                accountIds.clear();
                for (Integer i = 0; i < accounts.size(); i++) {
                    Account account = accounts[i];
                    nodeId = (level > 0) ? nodeList.get(account.ParentId ) + '.' + String.valueOf(i) : String.valueOf(i);

                    ObjectStructureMap newObjectStructureMap = new ObjectStructureMap();
                    newObjectStructureMap.nodeId = nodeId;
                    newObjectStructureMap.levelFlag = levelFlag;
                    newObjectStructureMap.closeFlag = closeFlag;
                    newObjectStructureMap.nodeType = nodeType;
                    newObjectStructureMap.currentNode = false;
                    newObjectStructureMap.account = account;
                    if (contactId != null) {
                        newObjectStructureMap.contactRole = accountContactRoles.get(account.Id) == null ? new AccountContactRole(AccountId = account.Id, ContactId = contactId, Role = contact.Title__c == null ? 'Default' : contact.Title__c) : accountContactRoles.get(account.Id);
                        newObjectStructureMap.hasSite = newObjectStructureMap.contactRole.Id != null;
                    }
                    masm.put(nodeId, newObjectStructureMap);
                    accountIds.add(account.Id);
                    nodeList.put(account.Id, nodeId);
                    nodeSortList.add(nodeId);
                }
                
                maxLevel.add(level);                
                level++;
            }
        }

        nodeSortList.sort();
        for (Integer i = 0; i < nodeSortList.size(); i++) {
            List<String> pnl = new List<String>();
            List<String> cnl = new List<String>();
            List<String> nnl = new List<String>();
            
            if ( i > 0 ){
                String pn = nodeSortList[i - 1];
                pnl = pn.split('\\.', -1);
            }

            String cn = nodeSortList[i];
            cnl = cn.split('\\.', -1);

            if (i < nodeSortList.size() - 1) {
                String nn = nodeSortList[i + 1];
                nnl = nn.split('\\.', -1);
            }
            
            ObjectStructureMap tasm = masm.get(cn);
            if (cnl.size() < nnl.size()) {
                tasm.nodeType = (isLastNode(cnl)) ? 'parent_end' : 'parent';
            }
            else if (cnl.size() > nnl.size()) {
                tasm.nodeType = 'child_end';
                tasm.closeFlag = setcloseFlag(cnl, nnl, tasm.nodeType);
            }
            else {
                tasm.nodeType = 'child';
            }
            
            tasm.levelFlag = setlevelFlag(cnl, tasm.nodeType); 
            
            if (tasm.account.id == accountId) {
                tasm.currentNode = true;
            }
            accountStructure.add(tasm);
        }
        
        accountStructure[0].nodeType = 'start';
        accountStructure[accountStructure.size() - 1].nodeType = 'end';
        
        return accountStructure;
    }
    
    public List<Boolean> setLevelFlag(List<String> nodeElements, String nodeType) {
    	
        List<Boolean> flagList = new List<Boolean>();
        String searchNode = '';
        String workNode = '';
        Integer cn = 0;
        
        for(Integer i = 0; i < nodeElements.size() - 1; i++) {
            cn = Integer.valueOf(nodeElements[i]);
            cn++;
            searchNode = workNode + String.valueOf(cn);
            workNode = workNode + nodeElements[i] + '.';
            if (masm.containsKey(searchNode)) {
                flagList.add(true);
            }
            else {
                flagList.add(false);
            }
        }
        
        return flagList;
    }
    
    public List<Boolean> setcloseFlag(List<String> cnl, List<String> nnl, String nodeType) {
    	
        List<Boolean> flagList = new List<Boolean>{};
        String searchNode = '';
        String workNode = '';
        Integer cn = 0;
        
        for (Integer i = nnl.size(); i < cnl.size(); i++) {
        	flagList.add(true);
        }
        
        return flagList;
    }
    
    public Boolean isLastNode(List<String> nodeElements) {
    	
        String searchNode = '';
        Integer cn = 0;
        
        for(Integer i = 0; i < nodeElements.size(); i++) {
            if (i == nodeElements.size() - 1) {
                cn = Integer.valueOf(nodeElements[i]);
                cn++;
                searchNode = searchNode + String.valueOf(cn);
            }
            else {
                searchNode = searchNode + nodeElements[i] + '.';
            }
        }
        if (masm.containsKey(searchNode)) {
            return false;
        }
        else {
            return true;
        }
    }
    
    public String getTopAccountId(String accountId){
        Boolean isTop = false;
        while (!isTop) {
            Account account = AccountService.getById(accountId, new List<String> {'Id',
                                                                                  'ParentId'});
            
            if (account.ParentId != null) {
                accountId = account.ParentId;
            }
            else {
                isTop = true;
            }
        }
        return accountId;
    }

    public void updateSites() {
        List<AccountContactRole> contactRolesToInsert = new List<AccountContactRole>();
        for (ObjectStructureMap objectStructureMap : accountStructure) {
            if (objectStructureMap.hasSite && objectStructureMap.contactRole != null && objectStructureMap.contactRole.Id == null) {
                contactRolesToInsert.add(objectStructureMap.contactRole);
            }
            else if (!objectStructureMap.hasSite && objectStructureMap.contactRole != null && objectStructureMap.contactRole.Id != null) {
                contactRolesToDelete.add(objectStructureMap.contactRole);
            }
        }

        SavePoint savePoint = Database.setSavepoint();
        try {
            if (ListUtils.isNotNullOrEmpty(contactRolesToInsert)) {
                insert contactRolesToInsert;
            }
            if (ListUtils.isNotNullOrEmpty(contactRolesToDelete)) {
                delete contactRolesToDelete;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The related sites have been successfully updated!'));
        }
        catch(DmlException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating related sites. (' + ex.getMessage() + ')'));
            Database.rollback(savePoint);
        }
    }
    
    public with sharing class ObjectStructureMap {
        public String nodeId {get;set;}
        public List<Boolean> levelFlag = new List<Boolean>();
        public List<Boolean> closeFlag = new List<Boolean>();
        public String nodeType {get;set;}
        public Boolean currentNode {get;set;}
        
        public Account account {get;set;}
        public Boolean hasSite {get;set;}

        public AccountContactRole contactRole {get;set;}
        
        public Boolean[] getlevelFlag() { return levelFlag; }
        public Boolean[] getcloseFlag() { return closeFlag; }
        
        public void setlevelFlag(Boolean l) { this.levelFlag.add(l); }
        public void setlcloseFlag(Boolean l) { this.closeFlag.add(l); }

        public ObjectStructureMap() {}
    }
}