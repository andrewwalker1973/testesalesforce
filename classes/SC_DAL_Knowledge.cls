/**
 * @description Public class to return the records of Knowledge articles
 *
 * @author bhaskar.arora@accenture.com uttpal.chandra@accenture.com
 *
 * @date August 2022, March 2023
 */
public inherited sharing class SC_DAL_Knowledge
{
	/**
	 * @description stores the Object APIName of the ServiceType
	 */
	private static final String OBJECT_NAME = Knowledge__kav.SObjectType.getDescribe().getLocalName();
	/**
	 * @description stores the APIName of Retail Agent Script RecordType of Knowledge Articles
	 */
	public static final String RT_RETAIL_AGENT_SCRIPT = 'SC_RetailAgentScript';
	/**
	 * @description stores the constant for the Publish Status picklist Online
	 */
	private static final String PICK_PUBLISH_STATUS_ONLINE = 'Online';
	/**
	 * @description stores the field API name of PublishStatus
	 */
	private static final String FIELD_PUBLISH_STATUS = Knowledge__kav.PublishStatus.getDescribe().getLocalName();
	/**
	 * @description stores the field API name of KnowledgeArticleId
	 */
	@TestVisible
	private static final String FIELD_KNOWLEDGE_ARTICLE_ID = Knowledge__kav.KnowledgeArticleId.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_KNOWLEDGE_ARTICLE_ID,
				FIELD_PUBLISH_STATUS,
				Knowledge__kav.AW_Text__c.getDescribe().getLocalName(),
				Knowledge__kav.IsLatestVersion.getDescribe().getLocalName(),
				Knowledge__kav.RecordTypeId.getDescribe().getLocalName(),
				Knowledge__kav.Title.getDescribe().getLocalName(),
				Knowledge__kav.UrlName.getDescribe().getLocalName(),
				Knowledge__kav.VersionNumber.getDescribe().getLocalName()
		};
	}

	/**
	 * @description This method is use to get a Case with the particular Id
	 *
	 * @param recordId The record of the Case
	 *
	 * @return A single Knowledge Article
	 */
	public static Knowledge__kav findById(Id recordId)
	{
		return (Knowledge__kav)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, recordId, getDefaultFields());
	}

	/**
	 * @description Will return all Knowledge Articles created by unit tests
	 *
	 * @return A list of knowledge articles
	 */
	@TestVisible
	private static List<Knowledge__kav> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description Will return Knowledge Article Record
	 *
	 * @param knowledgeArticleId Knowledge Article Id
	 *
	 * @return Null or found item
	 */
	public static Knowledge__kav findByPublishedKnowledgeArticleId(Id knowledgeArticleId)
	{
		List<Knowledge__kav> foundArticles = findByPublishedKnowledgeArticleId(new Set<Id> {knowledgeArticleId});
		return foundArticles.isEmpty() ? null : foundArticles.iterator().next();
	}

	/**
	 * @description Will return list of Knowledge Article
	 *
	 * @param knowledgeArticleIds List of Knowledge Article Id
	 *
	 * @return A list of found items
	 */
	public static List<Knowledge__kav> findByPublishedKnowledgeArticleId(Set<Id> knowledgeArticleIds)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());

		searchParameters.searchConditions.inX(FIELD_KNOWLEDGE_ARTICLE_ID, CMN_UTIL_System.setToList(knowledgeArticleIds));
		searchParameters.searchConditions.equalsX(FIELD_PUBLISH_STATUS, PICK_PUBLISH_STATUS_ONLINE);

		return CMN_DAL_Search.getObjects(searchParameters);

	}
}