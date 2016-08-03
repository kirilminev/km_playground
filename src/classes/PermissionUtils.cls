public with sharing class PermissionUtils {
	private static final String PERMISSIONSETx = 'PermissionSet';
	private static final String ASSIGNMENTSx = 'Assignments';

	public static Boolean hasPermissionSet(String permissionSetName, Id userId) {
		PermissionSet permissionSet = getWithAssignmentsByName(permissionSetName, new List<String> {'Id',
																									'Name'}, new List<String> {'AssigneeId'});
		for (PermissionSetAssignment assignment : permissionSet.Assignments) {
			if (assignment.AssigneeId == userId) {
				return true;
			}
		}
		return false;
	}


	public static PermissionSet getWithAssignmentsByName(String permissionSetName, List<String> permissionSetFields, List<String> assignmentFields) {
		String soql = new SoqlBuilder()
						  .selectx(permissionSetFields)
						  .selectx(
						  	new SoqlBuilder()
						  		.selectx(assignmentFields)
						  		.fromx(ASSIGNMENTSx))
						  .fromx(PERMISSIONSETx)
						  .wherex(new FieldCondition('Name').equals(permissionSetName))
						  .toSoql();
		return Database.query(soql);
	}
}