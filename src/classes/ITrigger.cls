/**
 * Interface containing methods Trigger Handlers must implement to enforce best practices and bulkification of triggers.
 */
public interface ITrigger {
/**
* 
*
* These methods are called prior to the execution of a trigger of the respective context. Use these to cache
* any data required into maps prior to execution of the trigger.
*/
	void bulkBefore();
	void bulkAfter();

/**
* beforeInsert
*
* This method is called for each record to be inserted during a before trigger.
*/
	void beforeInsert(List<SObject> soList);

/**
* beforeUpdate
*
* This method is called for each record to be updated during a before trigger.
*/
	void beforeUpdate(Map<Id, SObject> oldSoMap, List<SObject> soList);

/**
* beforeDelete
*
* This method is called for each record to be deleted during a before trigger.
*/
	void beforeDelete(List<SObject> soList);

/**
* afterInsert
*
* This method is called for each record inserted during an after trigger. Always put field validation in the 'after' methods in case another trigger has modified any values. The record is 'read only' by this point.
*/
	void afterInsert(List<SObject> soList);

/**
* afterUpdate
*
* This method is called for each record to be updated during an after trigger.
*/
	void afterUpdate(Map<Id, SObject> oldSoMap, List<SObject> soList);

/**
* afterDelete
*
* This method is called for each record to be deleted during an after trigger.
*/
	void afterDelete(List<SObject> soList);

/**
* andFinally
*
* This method is called once all records have been processed by the trigger. Use this method to accomplish any final operations such as creation or updates of other records.
*/
	void andFinally();
}