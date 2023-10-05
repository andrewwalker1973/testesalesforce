/**
 * @description Provides Queries related to RecordType object
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_RecordType
{
	public static final String OBJECT_NAME = 'RecordType';
	private static final String FIELD_SOBJECT_TYPE = 'SobjectType';

	/**
	 * @description Method use to get the set of fields of SObject
	 *
	 * @return A list of commonly queried Record Type fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				RecordType.BusinessProcessId.getDescribe().getLocalName(),
				RecordType.Description.getDescribe().getLocalName(),
				RecordType.DeveloperName.getDescribe().getLocalName(),
				RecordType.Id.getDescribe().getLocalName(),
				RecordType.IsActive.getDescribe().getLocalName(),
				RecordType.Name.getDescribe().getLocalName(),
				RecordType.NamespacePrefix.getDescribe().getLocalName(),
				FIELD_SOBJECT_TYPE
		};
	}

	/**
	 * @description This method is use to return the list of Record Type by Object
	 *
	 * @param objectType the object type to use
	 *
	 * @return A list of items
	 */
	@TestVisible
	private static List<RecordType> findByObjectType(SObjectType objectType)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_SOBJECT_TYPE, new Set<String> {objectType.getDescribe().getLocalName()}, getDefaultFields());
	}

}