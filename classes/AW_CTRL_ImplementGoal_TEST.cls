/**
 * @description This class is the apex test class for the class AW_CTRL_ImplementGoal
 *
 * @see AW_CTRL_ImplementGoal
 *
 * @author vishakha.saini@accenture.com, jason.van.beukering@accenture.com
 *
 * @date November 2020, August 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_CTRL_ImplementGoal_TEST
{
	/**
	 * @description This setup test method prepares the data for the test methods
	 */
	@TestSetup
	private static void testSetup()
	{
		Account setupAcc = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

		Opportunity setupOpp = AW_DAL_TestDataFactory.createDefaultOpportunities(setupAcc, 1).iterator().next();

		List<AW_FNA__c> listFNA = AW_DAL_TestDataFactory.createFNA(setupAcc.Id, 1);

		FinServ__FinancialGoal__c goal = AW_DAL_TestDataFactory.createGoals(setupAcc.Id, 1).iterator().next();
		goal.AW_FNA__c = listFNA.iterator().next().Id;
		update goal;

		AW_Planned_Solution__c setupSol = AW_DAL_TestDataFactory.createSolutions(goal.Id, 1).iterator().next();

		Quote qte = AW_DAL_TestDataFactory.createQuoteWithQuoteNumber(setupOpp.Id, CMN_DAL_SObjectDomain.generateRandomNumber(), false);
		qte.AW_Planned_Solution__c = setupSol.Id;
		insert qte;
	}

	/**
	 * @description This test method tests fetchGoalsTest method behaviour
	 *
	 * @see AW_CTRL_ImplementGoal.fetchGoals
	 */
	@IsTest
	private static void fetchGoalsTest()
	{
		Account acc = AW_DAL_Account.getAll().iterator().next();

		Test.startTest();

		List<FinServ__FinancialGoal__c> result = AW_CTRL_ImplementGoal.fetchGoals(acc.Id);

		Test.stopTest();

		System.assertEquals(1, result.size());
	}

	/**
	 * @description This test method tests fetchGoalsWithGoalId method behaviour
	 *
	 * @see AW_CTRL_ImplementGoal.fetchGoalsWithGoalId
	 */
	@IsTest
	private static void fetchGoalsWithGoalIdTest()
	{
		FinServ__FinancialGoal__c goal = AW_DAL_FinancialGoal.getAll().iterator().next();

		Test.startTest();

		List<FinServ__FinancialGoal__c> result = AW_CTRL_ImplementGoal.fetchGoalsWithGoalId(goal.Id);

		Test.stopTest();

		System.assertEquals(1, result.size());
	}

	/**
	 * @description This test method tests fetchSolutions method behaviour
	 *
	 * @see AW_CTRL_ImplementGoal.fetchSolutions
	 */
	@IsTest
	private static void fetchSolutionsTest()
	{
		FinServ__FinancialGoal__c goal = AW_DAL_FinancialGoal.getAll().iterator().next();

		Test.startTest();

		List<AW_Planned_Solution__c> result = AW_CTRL_ImplementGoal.fetchSolutions(goal.Id);

		Test.stopTest();

		System.assertEquals(1, result.size());
	}

	/**
	 * @description This test method tests fetchSolutionsByGoalIds method behaviour
	 *
	 * @see AW_CTRL_ImplementGoal.fetchSolutionsByGoalIds
	 */
	@IsTest
	private static void fetchSolutionsByGoalIdsTest()
	{
		FinServ__FinancialGoal__c goal = AW_DAL_FinancialGoal.getAll().iterator().next();

		Test.startTest();

		List<AW_Planned_Solution__c> result = AW_CTRL_ImplementGoal.fetchSolutionsByGoalIds(new List<Id> {goal.Id});

		Test.stopTest();

		System.assertEquals(1, result.size());
	}

	/**
	 * @description This test method tests fetchOpportunitySolutions method behaviour
	 *
	 * @see AW_CTRL_ImplementGoal.fetchOpportunitySolutions
	 */
	@IsTest
	private static void fetchOpportunitySolutionsTest()
	{
		Opportunity opp = AW_DAL_Opportunity.getAll().iterator().next();

		Test.startTest();

		List<AW_Planned_Solution__c> result = AW_CTRL_ImplementGoal.fetchOpportunitySolutions(opp.Id);

		Test.stopTest();

		System.assertEquals(1, result.size());
	}

	/**
	 * @description This test method tests fetchQuotesWithSolutionId method behaviour
	 *
	 * @see AW_CTRL_ImplementGoal.fetchQuotesWithSolutionId
	 */
	@IsTest
	private static void fetchQuotesWithSolutionIdTest()
	{
		AW_Planned_Solution__c sol = AW_DAL_PlannedSolution.getAll().iterator().next();

		Test.startTest();

		List<Quote> result = AW_CTRL_ImplementGoal.fetchQuotesWithSolutionId(sol.Id);

		Test.stopTest();

		System.assertEquals(1, result.size());
	}

	/**
	 * @description This test method tests fetchQuoteWithQuoteId method behaviour
	 *
	 * @see AW_CTRL_ImplementGoal.fetchQuoteWithQuoteId
	 */
	@IsTest
	private static void fetchQuoteWithQuoteIdTest()
	{
		Quote quote = AW_DAL_Quote.getAll().iterator().next();

		Test.startTest();

		Quote result = AW_CTRL_ImplementGoal.fetchQuoteWithQuoteId(quote.Id);

		Test.stopTest();

		System.assertNotEquals(result, null);
	}

	/**
	 * @description This test method tests fetchQuotesWithAccountId method behaviour
	 *
	 * @see AW_CTRL_ImplementGoal.fetchQuotesWithAccountId
	 */
	@IsTest
	private static void fetchQuoteWithAccountIdTest()
	{
		Account acc = AW_DAL_Account.getAll().iterator().next();

		Test.startTest();

		List<Quote> result = AW_CTRL_ImplementGoal.fetchQuotesWithAccountId(acc.Id);

		Test.stopTest();

		System.assertNotEquals(result, null);
	}

	/**
	 * @description This test method tests getLabels method behaviour
	 *
	 * @see AW_CTRL_ImplementGoal.getLabels
	 */
	@IsTest
	private static void getLabelsTest()
	{
		Map<String, String> accountLabels = new Map<String, String>();

		Test.startTest();

		accountLabels = AW_CTRL_ImplementGoal.getLabels(AW_DAL_Account.OBJECT_NAME);

		Test.stopTest();

		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

		Schema.SObjectType leadSchema = schemaMap.get(AW_DAL_Account.OBJECT_NAME);
		Map<String, SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
		String accountNameLabel = fieldMap.get('name').getDescribe().getLabel();

		System.assertEquals(accountNameLabel, accountLabels.get('name'), 'The getLabels method does not get the right label for the Name field on Account');
	}
	/**
	 * @description This test method tests fetchAccountByOpportunityIdTest method behaviour
	 *
	 * @see AW_CTRL_ImplementGoal.fetchAccountByOpportunityId
	 */
	@IsTest
	private static void fetchAccountByOpportunityIdTest()
	{
		Opportunity opp = AW_DAL_Opportunity.getAll().iterator().next();
		Test.startTest();
		String result = AW_CTRL_ImplementGoal.fetchAccountByOpportunityId(opp.Id);
		Test.stopTest();

		System.assertNotEquals(result, null, 'Opportunity not found.');
	}
}