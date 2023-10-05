/**
 * @description Test class for SC_CTRL_Script
 *
 * @see SC_CTRL_Script @story 297812 @story 425625
 *
 * @author vikrant.goswami@accenture.com uttpal.chandra@accenture.com
 *
 * @date June 2022, March 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
private class SC_CTRL_Script_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description Create data required for unit tests
	 */
	@TestSetup
	private static void setup()
	{
		AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		Knowledge__kav newKnowledgeArticle = SC_DAL_DataFactory.insertKnowledgeArticles(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		Knowledge__kav knowledgeArticleRecord = SC_DAL_Knowledge.findById(newKnowledgeArticle.Id);
		User knowledgeAdministratorUser = SC_DAL_User.findActiveKnowledgeAdministrator();
		System.runAs(knowledgeAdministratorUser)
		{
			KbManagement.PublishingService.publishArticle(knowledgeArticleRecord.KnowledgeArticleId, true);
		}
		SC_ServiceType__c newServiceType = SC_DAL_DataFactory.createServiceTypesWithAssignableValue(NUMBER_OF_ITEMS_TO_CREATE, true).iterator().next();
		newServiceType.SC_KnowledgeArticle__c = SC_DAL_Knowledge.findByPublishedKnowledgeArticleId(knowledgeArticleRecord.KnowledgeArticleId).Id;
		update newServiceType;
	}

	/**
	 * @description to test retrieval of script for a case
	 *
	 * @see SC_CTRL_Script.getScriptForCase
	 */
	@IsTest
	private static void getScriptForCase()
	{
		Account foundAccount = SC_DAL_Account.getAll().iterator().next();
		SC_ServiceType__c foundServiceType = SC_DAL_ServiceType.getAll().iterator().next();
		User foundAgent = SC_DAL_User.findRandomActiveAgent();
		Case newCase = SC_DAL_DataFactory.newCase(foundAccount.Id);
		newCase.RSC_ServiceType__c = foundServiceType.Id;
		newCase.OwnerId = foundAgent.Id;
		insert newCase;

		SC_CTRL_Script.DTO_Script dtoScript;

		Test.startTest();

		System.runAs(foundAgent)
		{
			dtoScript = SC_CTRL_Script.getScriptForCase(newCase.Id);
		}

		Test.stopTest();

		Knowledge__kav knowledgeArticle = SC_DAL_Knowledge.getAll().iterator().next();

		Assert.isNotNull(dtoScript, 'No script found.');
		Assert.areEqual(knowledgeArticle.Id, dtoScript.scriptId, 'Incorrect script found.');

	}
}