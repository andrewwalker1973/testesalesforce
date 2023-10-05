/**
 * @description Public class to return the records of UserRole
 *
 * @author Accenture
 *
 * @date 2021
 */
public inherited sharing class AW_DAL_Role
{
	private static final String OBJECT_NAME = UserRole.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				UserRole.Id.getDescribe().getLocalName(),
				UserRole.Name.getDescribe().getLocalName(),
				UserRole.ParentRoleId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will find an Role by its Name
	 *
	 * @param roleId The Id of the Role
	 *
	 * @return Either the item found or null
	 */
	public static UserRole findById(Id roleId)
	{
		return (UserRole)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, roleId, getDefaultFields());
	}
}