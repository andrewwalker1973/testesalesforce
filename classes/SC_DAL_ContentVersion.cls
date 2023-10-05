/**
 * @description Batch class to delete content documents
 *
 * @see RSC_BATCH_DeleteContentDocument_TEST @story ST-146054
 *
 * @author rajpal.singh@liberty.co.za
 *
 * @date September 2021
 */
public inherited sharing class SC_DAL_ContentVersion
{
	private static final String FIELD_DELETED_BY = ContentVersion.CMN_DeleteBy__c.getDescribe().getLocalName();
	private static final String OBJECT_NAME = ContentVersion.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_CONTENT_DOCUMENT_ID = ContentVersion.ContentDocumentId.getDescribe().getLocalName();
	public static final String FILE_TYPE_PDF = 'PDF';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				ContentVersion.Id.getDescribe().getLocalName(),
				FIELD_DELETED_BY
		};
	}

	/**
	 * @description This method is use to get a ContentVersion with the particular Id
	 *
	 * @param recordId The record of the ContentVersion
	 *
	 * @return A single ContentVersion
	 */
	public static ContentVersion findById(Id recordId)
	{
		return (ContentVersion)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, recordId, getDefaultFields());
	}

	/**
	 * @description Queries ContentVersion for all the times
	 *
	 * @return List of Content Version
	 */
	public static String findByDeleteBy()
	{
		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(FIELD_CONTENT_DOCUMENT_ID)
						.fromX(OBJECT_NAME)
						.whereX(new CMN_SOQL_Query.FieldCondition(FIELD_DELETED_BY, CMN_SOQL_Query.Operator.LESS_THAN_OR_EQUAL_TO, System.now()));

		return builder.toSoql();
	}
}