/**
 * @description Flow Class containing invocable methods to fetch the data of Knowledge Article Id
 * and Service Type Record Id
 *
 * @see SC_FLOW_UpdateServiceTypeArticle_TEST @story ST-425625
 *
 * @author uttpal.chandra@accenture.com
 *
 * @date March 2023
 */
public inherited sharing class SC_FLOW_UpdateServiceTypeArticle
{
	/**
	 * @description Method use to call the Queueable Apex with the parameters received from the flow
	 *
	 * @param dtoRequests List of request DTOs
	 */
	@InvocableMethod(Label='Update Service Type on Knowledge Article Publish' Description='Method is used to update the related Service Type on Knowledge Article publish')
	public static void updateServiceTypes(List<DTO_Request> dtoRequests)
	{
		System.enqueueJob(new SC_QUE_UpdateServiceType(dtoRequests));
	}

	/**
	 * @description Request DTO
	 */
	public class DTO_Request
	{
		/**
		 * @description Contains the Service Type recordId which is linked to the Published Articles
		 */
		@InvocableVariable(Label='Service Type Id' Description='List of Service Associated with the Published Article')
		public List<Id> serviceTypeIds;
		/**
		 * @description Contain the knowledgeArticleId
		 */
		@InvocableVariable(Label='Knowledge Article Id' Description='Knowledge Article Id of Knowledge Article')
		public Id knowledgeArticleId;
	}

	/**
	 * @description Inner class to update Service type with the Latest Knowledge Article
	 */
	public class SC_QUE_UpdateServiceType implements Queueable
	{
		private final Map<Id, Set<Id>> knowledgeArticleIdToServiceTypesMap;
		private final Set<Id> serviceTypeRecordIds;

		/**
		 * @description Constructor to initialize the variables
		 *
		 * @param knowledgeArticleServiceTypeIds DTO contains List of knowledge Article Id and List of Service type Ids
		 */
		public SC_QUE_UpdateServiceType(List<SC_FLOW_UpdateServiceTypeArticle.DTO_Request> knowledgeArticleServiceTypeIds)
		{
			knowledgeArticleIdToServiceTypesMap = new Map<Id, Set<Id>>();
			serviceTypeRecordIds = new Set<Id>();

			for(SC_FLOW_UpdateServiceTypeArticle.DTO_Request knowledgeArticleServiceTypeId : knowledgeArticleServiceTypeIds)
			{
				knowledgeArticleIdToServiceTypesMap.put(knowledgeArticleServiceTypeId.knowledgeArticleId, new Set<Id>(knowledgeArticleServiceTypeId.serviceTypeIds));
				serviceTypeRecordIds.addAll(knowledgeArticleServiceTypeId.serviceTypeIds);
			}
		}

		/**
		 * @description Method to Update the Service Type
		 *
		 * @param param1 Default Parameter
		 */
		public void execute(QueueableContext param1)
		{
			Map<Id, SC_ServiceType__c> serviceTypeMap = new Map<Id, SC_ServiceType__c>(SC_DAL_ServiceType.findById(serviceTypeRecordIds));

			List<Knowledge__kav> foundArticles = SC_DAL_Knowledge.findByPublishedKnowledgeArticleId(knowledgeArticleIdToServiceTypesMap.keySet());

			for(Knowledge__kav foundArticle : foundArticles)
			{
				Set<Id> serviceTypeIds = knowledgeArticleIdToServiceTypesMap.get(foundArticle.KnowledgeArticleId);

				for(Id serviceTypeId : serviceTypeIds)
				{
					SC_ServiceType__c foundServiceType = serviceTypeMap.get(serviceTypeId);
					foundServiceType.SC_KnowledgeArticle__c = foundArticle.Id;
				}
			}

			CMN_DAL_SObjectDomain.updateDBObjects(serviceTypeMap.values());
		}
	}
}