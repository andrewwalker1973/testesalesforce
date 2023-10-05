/**
 * @description Provides Queries related to PermissionSetAssignments
 *
 * @see PermissionSetAssignment
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date June 2022
 */
public inherited sharing class CMN_DAL_PermissionSetAssignment
{
	private static final String FIELD_ASSIGNEE_ID = PermissionSetAssignment.AssigneeId.getDescribe().getLocalName();
	private static final String FIELD_ASSIGNEE_PROFILE_NAME = 'Assignee.Profile.Name';
	private static final String FIELD_IS_ACTIVE = PermissionSetAssignment.IsActive.getDescribe().getLocalName();
	private static final String FIELD_PERMISSION_SET_NAME = 'PermissionSet.Name';
	private static final String OBJECT_NAME = PermissionSetAssignment.SObjectType.getDescribe().getLocalName();
	/**
	 * @description API name of the permissionset id field
	 *
	 * @see PermissionSetAssignment.PermissionSetId
	 */
	public static final String FIELD_PERMISSION_SET_ID = PermissionSetAssignment.PermissionSetId.getDescribe().getLocalName();

	/**
	 * @description The commonly required field when querying PermissionSetAssignments
	 *
	 * @return A unique set of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_ASSIGNEE_ID,
				FIELD_IS_ACTIVE,
				FIELD_PERMISSION_SET_ID,
				PermissionSetAssignment.ExpirationDate.getDescribe().getLocalName(),
				PermissionSetAssignment.PermissionSetGroupId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will find all assignment for a particular PermissionSet Name
	 *
	 * @param permissionSetName Name of the permission set to query by
	 * @param profileName Name of the profile to query by
	 *
	 * @return A list of found items
	 */
	@TestVisible
	private static List<PermissionSetAssignment> findActiveByPermissionSetAndProfileName(String permissionSetName, String profileName)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());
		searchParameters.searchConditions.equalsX(FIELD_IS_ACTIVE, true);
		searchParameters.searchConditions.equalsX(FIELD_PERMISSION_SET_NAME, permissionSetName);
		searchParameters.searchConditions.equalsX(FIELD_ASSIGNEE_PROFILE_NAME, profileName);
		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Will return a list of User objects (to be used by System.runAs) that are allocated to the given permissionset
	 *
	 * @param permissionSetName Name of the permission set to query by
	 * @param profileName Name of the profile to query by
	 *
	 * @return A list of found items
	 */
	@TestVisible
	private static List<User> findAllocatedUsersByPermissionSetAndProfileName(String permissionSetName, String profileName)
	{
		List<PermissionSetAssignment> assignments = findActiveByPermissionSetAndProfileName(permissionSetName, profileName);

		List<User> foundUsers = new List<User>();

		for(PermissionSetAssignment assignment : assignments)
		{
			User foundUser = new User();
			foundUser.Id = assignment.AssigneeId;

			foundUsers.add(foundUser);
		}

		return foundUsers;
	}
}