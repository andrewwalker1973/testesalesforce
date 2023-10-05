/**
 * @description Provides Queries related to PermissionSets
 *
 * @see PermissionSet
 *
 * @author prashant.k.jain@accenture.com jason.van.beukering@accenture.com
 *
 * @date June 2022
 */
public inherited sharing class CMN_DAL_PermissionSet
{
	private static final String OBJECT_NAME = PermissionSet.SObjectType.getDescribe().getLocalName();

	/**
	 * @description API name of the Object Share Permission Set
	 */
	@TestVisible
	private static final String OBJECT_SHARE_PERMISSION_SET_API_NAME = 'CMN_ObjectShare';

	/**
	 * @description The commonly required field when querying PermissionSets
	 *
	 * @return A unique set of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				PermissionSet.IsCustom.getDescribe().getLocalName(),
				PermissionSet.Label.getDescribe().getLocalName(),
				PermissionSet.LicenseId.getDescribe().getLocalName(),
				PermissionSet.Name.getDescribe().getLocalName(),
				PermissionSet.Type.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will find a PermissionSet based on its unique name
	 *
	 * @param name name to find item against
	 *
	 * @return null or the item found
	 */
	public static PermissionSet findByName(String name)
	{
		return (PermissionSet)CMN_DAL_SObjectSelector.findByName(OBJECT_NAME, name, getDefaultFields());
	}
}