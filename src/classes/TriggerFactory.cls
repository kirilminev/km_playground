public with sharing class TriggerFactory {
	
	public static void createHandler(Schema.sObjectType soType) {
		//Get a handler appropriate to the object being processed.
		ITrigger handler = getHandler(soType);

		//Make sure we have a handler registered. New handlers must be registered in the getHandler method.
		if (handler == null) {
			throw new TriggerException(new Constants.ExceptionMessages().TRIGGER_EXCEPTION_INVALID_SOBJECT_TYPE + soType);
		}

		//Execute the handler to fulfill the trigger.
		execute(handler);
	}

	private static void execute(ITrigger handler) {
		//Before trigger
		if (Trigger.isBefore) {
			//Call the bulk before to handle any caching of data and enable bulkification.
			handler.bulkBefore();

			if (Trigger.isDelete) {
				handler.beforeDelete(Trigger.old);
			}
			else if (Trigger.isInsert) {
				handler.beforeInsert(Trigger.new);
			}
			else if (Trigger.isUpdate) {
				handler.beforeUpdate(Trigger.oldMap, Trigger.new);
			}
		}
		else {
			//Call the bulk after to handle any caching of data and enable bulkification.
			handler.bulkAfter();

			if (Trigger.isDelete) {
				handler.afterDelete(Trigger.old);
			}
			else if (Trigger.isInsert) {
				handler.afterInsert(Trigger.new);
			}
			else if (Trigger.isUpdate) {
				handler.afterUpdate(Trigger.oldMap, Trigger.new);
			}
		}

		handler.andFinally();
	}

	private static ITrigger getHandler(Schema.sObjectType soType) {

		if (soType == Account.sObjectType) {
			return new AccountTriggerHandler();
		}
		else if (soType == Asset.sObjectType) {
			return new AssetTriggerHandler();
		}
		else if (soType == Case.sObjectType) {
			return new CaseTriggerHandler();
		}
		else if (soType == Contact.sObjectType) {
			return new ContactTriggerHandler();
		}
		else if (soType == Contract.sObjectType) {
			return new ContractTriggerHandler();
		}
		else if (soType == MediaChangeRequest__c.sObjectType) {
			return new MediaChangeRequestTriggerHandler();
		}
		else if (soType == Opportunity.sObjectType) {
			return new OpportunityTriggerHandler();
		}
		else if (soType == OpportunityLineItem.sObjectType) {
			return new OpportunityLineItemTriggerHandler();
		}
		else if (soType == Service_Date__c.sObjectType) {
			return new ServiceDateTriggerHandler();
		}
		return null;
	}
}