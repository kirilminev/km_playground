public class RecordTypeService {
	private static final String RECORDTYPEx = 'RecordType';

	public static RecordType getByNameAndObjectType(String name, String type, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(RECORDTYPEx)
						  .wherex(
						  	new AndCondition()
						  		.add(new FieldCondition('Name').equals(name))
						  		.add(new FieldCondition('sObjectType').equals(type)))
						  .toSoql();
		return Database.query(soql);
	}

	public static List<RecordType> getByObjectType(String type, List<String> fields) {
		String soql = new SoqlBuilder()
						  .selectx(fields)
						  .fromx(RECORDTYPEx)
						  .wherex(new FieldCondition('sObjectType').equals(type))
						  .toSoql();
		return Database.query(soql);
	}

	/*******************************************************************************************************
	* @description 		Utilizing Scheme.Describe method will retrieve RecordTypes map with the key being the
	*                	name of the requested Record Type and the value to the map as the RecordTypeId
	* 
	* @param 			String sobjectType -> Sobject type name, examples: Opportunity, My_Custom_Object__c etc.
	* @param 			List<String> recordTypeNames -> The names of related record types associated to the sobjectType
	* @return 			Map<String, Id> -> String will be the name of record type and Id the RecordTypeId		
	* 
	*/
	public static Map<String, Id> getByNamesAndObjectTypeWithDescribe(String sobjectType, List<String> recordTypeNames) {
		
		Schema.DescribeSObjectResult sobjectResult = null;

		try {
			sobjectResult = Schema.getGlobalDescribe().get(sobjectType).getDescribe();
		}catch (NullPointerException nullException) {
			LoggingUtils.log(new LoggingUtils.CustomException('Not a valid Sobject Type Name: ' + sobjectType), true, true, false);
		}

		if (sobjectResult != null && ListUtils.isNotNullOrEmpty(recordTypeNames)) {
			Map<String, Id> recordTypesResultMap = new Map<String, Id>();

			for (String recordTypeName :recordTypeNames) {
				Schema.RecordTypeInfo recordTypeInfoTemp = sobjectResult.getRecordTypeInfosByName().get(recordTypeName);
				if (recordTypeInfoTemp != null) {
					recordTypesResultMap.put(recordTypeInfoTemp.getName(), recordTypeInfoTemp.getRecordTypeId());
				}
			}
			return recordTypesResultMap;
		} else {
			return null;
		}
	}
}