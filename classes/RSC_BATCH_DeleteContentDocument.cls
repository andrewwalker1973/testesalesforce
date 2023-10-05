/**
 * @description Batch class to delete content documents
 *
 * @see RSC_BATCH_DeleteContentDocument_TEST @story ST-146054
 *
 * @author rajpal.singh@liberty.co.za
 *
 * @date September 2021
 */
public inherited sharing class RSC_BATCH_DeleteContentDocument implements Database.Batchable<SObject>, Database.Stateful
{
	/**
	 * @description Start method of batch class
	 *
	 * @param BC is batchable context variable
	 *
	 * @return ContentVersion records
	 */
	public Database.QueryLocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator(SC_DAL_ContentVersion.findByDeleteBy());
	}

	/**
	 * @description Execute method of batch class
	 *
	 * @param BC is batchable context variable
	 * @param contentVersions is used to hold data returned by start method
	 */
	public void execute(Database.BatchableContext BC, List<ContentVersion> contentVersions)
	{
		List<ContentDocument> documents = new List<ContentDocument>();

		for(ContentVersion version : contentVersions)
		{
			ContentDocument document = new ContentDocument();
			document.Id = version.ContentDocumentId;
			documents.add(document);
		}

		CMN_DAL_SObjectDomain.deleteDBObjects(documents);
	}

	/**
	 * @description Finish method of batch class
	 *
	 * @param BC is batchable context variable
	 */
	public void finish(Database.BatchableContext BC)
	{

	}
}