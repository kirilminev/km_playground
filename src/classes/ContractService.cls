public with sharing class ContractService {
	public static final String ACTIVATED = 'Activated';
	
	public static void closeOpportunities(Map<Id, Contract> oldContracts, List<Contract> contracts) {
		List<Id> contractIds = new List<Id>();
		for (Contract contract : contracts) {
			if (contract.Status == ACTIVATED && oldContracts.get(contract.Id).Status != ACTIVATED) {
				contractIds.add(contract.Id);
			}
		}
		if (ListUtils.isNotNullOrEmpty(contractIds)) {
			List<Opportunity> opportunitiesToClose = [Select Id From Opportunity Where ContractId IN: contractIds];
		
			if (ListUtils.isNotNullOrEmpty(opportunitiesToClose)) {
				for (Opportunity opportunity : opportunitiesToClose) {
					opportunity.StageName = 'Closed Won';
				}
				try {
					update opportunitiesToClose;
				}
				catch (DmlException ex) {
					LoggingUtils.log(ex, true, true, false);
				}
			}
		}
	}
}