/**
 * @description Test Class for SC_FLOW_CalKnowledgeQueueable
 *
 * @see SC_FLOW_updateServiceTypeArticle @story ST-425625
 *
 * @author uttpal.chandra@accenture.com
 *
 * @date March 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
private class SC_FLOW_UpdateServiceTypeArticle_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description Create data required for unit tests
	 */
	@TestSetup
	private static void setup()
	{
		AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		Knowledge__kav newKnowledgeRecord = SC_DAL_DataFactory.insertKnowledgeArticles(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		Knowledge__kav knowledgeArticleRecord = SC_DAL_Knowledge.findById(newKnowledgeRecord.Id);

		System.runAs(SC_DAL_User.findActiveKnowledgeAdministrator())
		{
			KbManagement.PublishingService.publishArticle(knowledgeArticleRecord.KnowledgeArticleId, true);
		}

		SC_ServiceType__c newServiceType = SC_DAL_DataFactory.createServiceTypesWithAssignableValue(NUMBER_OF_ITEMS_TO_CREATE, true).iterator().next();
		newServiceType.SC_KnowledgeArticle__c = SC_DAL_Knowledge.findByPublishedKnowledgeArticleId(knowledgeArticleRecord.KnowledgeArticleId).Id;

		update newServiceType;

	}

	/**
	 * @description This method will validate if latest published Article is linked with the Service Type
	 *
	 * @see SC_FLOW_updateServiceTypeArticle.updateServiceTypes
	 */
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	@IsTest
	private static void updateServiceTypes()
	{
		User knowledgeAdministratorUser = SC_DAL_User.findActiveKnowledgeAdministrator();

		String draftArticleVersionId;
		System.runAs(knowledgeAdministratorUser)
		{
			draftArticleVersionId = KbManagement.PublishingService.editOnlineArticle(SC_DAL_Knowledge.getAll().iterator().next().KnowledgeArticleId, true);
		}

		Knowledge__kav knowledgeArticleRecord = SC_DAL_Knowledge.findById(draftArticleVersionId);

		System.runAs(knowledgeAdministratorUser)
		{
			KbManagement.PublishingService.publishArticle(knowledgeArticleRecord.KnowledgeArticleId, true);
		}
		SC_FLOW_UpdateServiceTypeArticle.DTO_Request dtoRequest = new SC_FLOW_UpdateServiceTypeArticle.DTO_Request();
		dtoRequest.knowledgeArticleId = knowledgeArticleRecord.KnowledgeArticleId;
		dtoRequest.serviceTypeIds = new List<Id> {SC_DAL_ServiceType.getAll().iterator().next().Id};

		Test.startTest();

		SC_FLOW_UpdateServiceTypeArticle.updateServiceTypes(new List<SC_FLOW_UpdateServiceTypeArticle.DTO_Request> {dtoRequest});

		Test.stopTest();

		SC_ServiceType__c foundServiceType = SC_DAL_ServiceType.getAll().iterator().next();

		Assert.areEqual
				(
						foundServiceType.SC_KnowledgeArticle__c,
						SC_DAL_Knowledge.findByPublishedKnowledgeArticleId(knowledgeArticleRecord.KnowledgeArticleId).Id,
						'Incorrect Knowledge Article Id found'
				);
	}
}