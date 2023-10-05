/**
 * @description Public class to return the records of ContentDocumentLink
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date 2021
 */
public inherited sharing class SC_DAL_ContentDocumentLink
{
	private static final String FIELD_CONTENT_DOCUMENT_LATEST_VERSION = 'ContentDocument.LatestPublishedVersionId';
	private static final String FIELD_CONTENT_DOCUMENT_TITLE = 'ContentDocument.Title';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_DAL_SObjectDomain.FIELD_ID,
				FIELD_CONTENT_DOCUMENT_LATEST_VERSION,
				FIELD_CONTENT_DOCUMENT_TITLE
		};
	}
}