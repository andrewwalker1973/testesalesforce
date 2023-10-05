/**
 * @description Public class to return the records of ContentAsset
 *
 * @author Accenture
 *
 * @date Jun 2021
 */
public inherited sharing class AW_DAL_ContentAsset
{
	public static final String OBJECT_NAME = ContentAsset.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_DEVELOPER_NAME = ContentAsset.DeveloperName.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve Content Asset
	 *
	 * @return A list of fields for Content Asset
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				ContentAsset.Id.getDescribe().getLocalName(),
				FIELD_DEVELOPER_NAME
		};
	}

	/**
	 * @description This method is use to retrieve the image files for Next best Action
	 *
	 * @param names Developer name of the Content Asset
	 *
	 * @return List of items
	 */
	public static List<ContentAsset> findByDeveloperName(Set<String> names)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_DEVELOPER_NAME, names, getDefaultFields());

	}
}