/**
 * @description Public class to return the records of DocumentType
 *
 * @author Futureform
 *
 * @date December 2022
 */
public inherited sharing class SLC_DAL_DocumentType
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
	 * @description stores the field APIName of MasterLabel of DocumentType
	 */
	public static final String FIELD_MASTER_LABEL = DocumentType.MasterLabel.getDescribe().getLocalName();

	public static final String FIELD_CODE = DocumentType.Description.getDescribe().getLocalName();
    /**
	 * @description stores the field APIName of Id of DocumentType
	 */
	public static final String FIELD_ID = DocumentType.Id.getDescribe().getLocalName();
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
	 * @description This method is use to retrieve the document types from the labels
	 *
	 * @param masterLabels Set of the Document Type labels
	 *
	 * @return List of items
	 */
	public static List<DocumentType> findByName(Set<String> masterLabels)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_MASTER_LABEL, masterLabels, getDefaultFields());
	}
    
	/**
	 * @description This method is use to retrieve the document types from the ids
	 *
	 * @param recordIds Set of the Document Type ids
	 *
	 * @return List of items
	 */
	public static List<DocumentType> findByIds(Set<String> recordIds)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_ID, recordIds, getDefaultFields());
	}
}