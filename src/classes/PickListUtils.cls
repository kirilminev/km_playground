/*******************************************************************************************************
* @description 	Purpose of class is to provide helper methods related to manipilating picklist fields
* 
*/
public with sharing class PickListUtils {
	

	/*******************************************************************************************************
	* @description 				            For given sobject name and pick list field anme it will return 
	*                              			available pick list options as a list
	* 
	* @param[String objectName]				sobjectName
	* @param[String pickListFieldName]		pickList field
	* 
	* @return			List<SelectOption> 
	* @example
	* 					PickListUtils.getPickListOptions('Account', 'MyCustomPicklist__c');
	* 
	*/
	public static List<SelectOption> getPickListOptions(String objectName, String pickListFieldName) {

		List<SelectOption> options = new List<SelectOption>();

		Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe()
														.get(objectName)
														.getDescribe()
														.fields.getMap()
														.get(pickListFieldName).getDescribe();

		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		for(Schema.PicklistEntry f : ple) {
			options.add(new SelectOption(f.getLabel(), f.getValue()));
		}
		return options;
	}
}