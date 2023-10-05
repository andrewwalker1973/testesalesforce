/**
 * @description Public class to return the records of DocumentType
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date 2021, April 2022
 */
public inherited sharing class SC_DAL_DocumentType
{
	/**
	 * @description stores the field APIName of Active of DocumentType
	 */
	private static final String FIELD_IS_ACTIVE = DocumentType.IsActive.getDescribe().getLocalName();
	/**
	 * @description API name of the object
	 */
	private static final String OBJECT_NAME = DocumentType.SObjectType.getDescribe().getLocalName();
	/**
	 * @description stores the field APIName of DeveloperName of DocumentType
	 */
	public static final String FIELD_DEVELOPER_NAME = DocumentType.DeveloperName.getDescribe().getLocalName();
	/**
	 * @description stores the Constant which is used to identify the Authority DocumentType
	 */
	public static final String LETTER_OF_AUTHORITY_CODE = 'DocumentCode_3472';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				DocumentType.Description.getDescribe().getLocalName(),
				DocumentType.MasterLabel.getDescribe().getLocalName(),
				FIELD_DEVELOPER_NAME
		};
	}

	/**
	 * @description This method is use to retrieve the document types for the developer name
	 *
	 * @param developerNames Set of the developer names
	 *
	 * @return List of items
	 */
	public static List<DocumentType> findByDeveloperName(Set<String> developerNames)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_DEVELOPER_NAME, developerNames, getDefaultFields());
	}

	/**
	 * @description This method is use to get a DocumentType with the particular Id
	 *
	 * @param recordId The record of the DocumentType
	 *
	 * @return A single DocumentType
	 */
	public static DocumentType findById(Id recordId)
	{
		return (DocumentType)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, recordId, getDefaultFields());
	}

	/**
	 * @description Will retrieve an random DocumentType that's active, and retrieves requested fields
	 *
	 * @return random item or null
	 */
	public static DocumentType findRandomActive()
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());

		searchParameters.randomResults = true;
		searchParameters.searchConditions.equalsX(FIELD_IS_ACTIVE, true);

		List<DocumentType> foundItems = CMN_DAL_Search.getObjects(searchParameters);

		return foundItems.isEmpty() ? null : foundItems.iterator().next();
	}
}