/**
 * @description This class is the apex test class for the class AW_CTRL_BPOCanvasContainer
 *
 * @see AW_CTRL_BPOCanvasContainer
 *
 * @author vishakha.saini@accenture.com pavan.thammali@liberty.co.za
 *
 * @date October 2020, July 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_CTRL_BPOCanvasContainer_TEST
{
	/**
	 * @description This setup test method prepares the data for the test methods
	 */
	@TestSetup
	private static void setupData()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		System.runAs(adviser)
		{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

		AW_DAL_TestDataFactory.createDefaultOpportunities(newAccount, 1);

		List<AW_FNA__c> listFNA = AW_DAL_TestDataFactory.createFNA(newAccount.Id, 1);

		List<FinServ__FinancialGoal__c> listGoals = AW_DAL_TestDataFactory.createGoals(newAccount.Id, 1);
		FinServ__FinancialGoal__c goal = listGoals[0];
		goal.AW_FNA__c = listFNA[0].Id;
		update goal;

		AW_DAL_TestDataFactory.createSolutions(goal.Id, 1);
			List<InsurancePolicy> insurancePolicyList = AW_DAL_TestDataFactory.createInsurancePolicies(newAccount, 1);
			InsurancePolicy insurancePolicy = insurancePolicyList[0];
			insurancePolicy.PolicyName = CMN_DAL_SObjectDomain.generateRandomName();
            update insurancePolicy;

			List<FinServ__FinancialAccount__c> financialAccList = AW_DAL_TestDataFactory.createFinancialAccounts(newAccount, 1);
			FinServ__FinancialAccount__c financialAcc = financialAccList[0];
			financialAcc.AW_ProductCategory__c = AW_DAL_FinancialAccount.PRODUCT_CATEGORY_INVESTMENT;
			update financialAcc;

		}
	}

	/**
	 * @description This test method tests the happy flow for the method createQuoteWithExternalId and checks
	 * 				that the method behaves correctly.
	 */
	@IsTest
	private static void createQuoteWithExternalId_successScenarioTest()
	{
		//Quote number which is returned in the mock response of AW_API_RestOutboundQuoteInfo
		String quoteExternalIdForTest = '49081032';
		Opportunity opp = AW_DAL_Opportunity.getAll().iterator().next();
		AW_Planned_Solution__c sol = AW_DAL_PlannedSolution.getAll().iterator().next();

		AW_API_RestOutboundQuoteInfo.responseType = AW_API_RestOutboundQuoteInfo.RESPONSE_MULTIPLE_QUOTES;

		Test.startTest();

		AW_CTRL_BPOCanvasContainer.createQuoteWithExternalId(quoteExternalIdForTest, opp.AccountId, sol.Id);

		Test.stopTest();

		Quote quoteToBeTested = AW_DAL_Quote.findByQuoteSolutionNumber(quoteExternalIdForTest);

		System.assertEquals(quoteToBeTested.AW_Quote_Solution_Number__c, quoteExternalIdForTest, 'Quote Solution Number not populated as expected');
		System.assertEquals(quoteToBeTested.AW_Planned_Solution__c, sol.Id, 'Planned Solution not set as expected');
		System.assertEquals(quoteToBeTested.OpportunityId, opp.Id, 'Opportunity Id not populated as expected');
	}

	/**
	 * @description This test method tests the empty id flow for the method createQuoteWithExternalId and checks
	 * 				that the method behaves correctly.
	 */
	@IsTest
	private static void createQuoteWithExternalId_emptyIdScenarioTest()
	{
		Test.startTest();

		AW_CTRL_BPOCanvasContainer.createQuoteWithExternalId(CMN_UTIL_String.EMPTY, CMN_UTIL_String.EMPTY, CMN_UTIL_String.EMPTY);

		Test.stopTest();

		List<Quote> quoteToBeTested = AW_DAL_Quote.getAll();

		System.assertEquals(quoteToBeTested.size(), 0);
	}

	/**
	 * @description This test method tests the happy flow for the method createQuoteWithExternalIdForContract and checks
	 * 				that the method behaves correctly.
	 */
	@IsTest
	private static void createQuoteWithExternalIdForContractInsurancePolicy_successScenarioTest()
	{
		String quoteExternalIdForTest = CMN_DAL_SObjectDomain.generateRandomNumber();

		Opportunity opp = AW_DAL_Opportunity.getAll().iterator().next();

		List<InsurancePolicy> insurancePolicyList = AW_DAL_InsurancePolicy.getAll();
		InsurancePolicy insPolicy = insurancePolicyList.iterator().next();
		AW_CTRL_BPOCanvasContainer.LifeAssured lifeAssured = new AW_CTRL_BPOCanvasContainer.LifeAssured();
		lifeAssured.LifeAssuredName = 'Sample';
		lifeAssured.ChangeTypes = new List<String> {'Sample'};
		String lifeAssuredJson = JSON.serialize(new List<AW_CTRL_BPOCanvasContainer.LifeAssured> {lifeAssured});

		Test.startTest();

		AW_CTRL_BPOCanvasContainer.createQuoteWithExternalIdForContract
				(quoteExternalIdForTest, 'pdf_Name', opp.Id, insPolicy.Name, '[]', lifeAssuredJson, 'Insurance Policy', 
                 insPolicy.AW_PolicyCategory__c,insPolicy.policyName);

		Test.stopTest();

		Quote quoteToBeTested = AW_DAL_Quote.findByQuoteSolutionNumber(quoteExternalIdForTest);

		System.assertEquals(quoteToBeTested.AW_Quote_Solution_Number__c, quoteExternalIdForTest, 'Quote Solution Number not populated as expected');
		System.assertEquals(quoteToBeTested.OpportunityId, opp.Id, 'Opportunity Id not populated as expected');
		System.assertEquals(quoteToBeTested.AW_Contract_Numbers__c, insPolicy.Name, 'Contract Numbers not populated as expected');
	}

	/**
	 * @description This test method tests the happy flow for the method createQuoteWithExternalIdForContract and checks
	 * 				that the method behaves correctly.
	 */
	@IsTest
	private static void createQuoteWithExternalIdForContractFinancialAccount_successScenarioTest()
	{
		String quoteExternalIdForTest = CMN_DAL_SObjectDomain.generateRandomNumber();

		Opportunity opp = AW_DAL_Opportunity.getAll().iterator().next();

		List<FinServ__FinancialAccount__c> financialAccountList = AW_DAL_FinancialAccount.getAll();
		FinServ__FinancialAccount__c financialAccount = financialAccountList.iterator().next();

		AW_CTRL_BPOCanvasContainer.LifeAssured lifeAssured = new AW_CTRL_BPOCanvasContainer.LifeAssured();
		lifeAssured.LifeAssuredName = 'Sample';
		lifeAssured.ChangeTypes = new List<String> {'Sample'};
		AW_CTRL_BPOCanvasContainer.LifeAssured lifeAssured2 = new AW_CTRL_BPOCanvasContainer.LifeAssured();
		lifeAssured2.LifeAssuredName = 'Sample2';
		lifeAssured2.ChangeTypes = new List<String> {'Sample2'};
		String lifeAssuredJson = JSON.serialize(new List<AW_CTRL_BPOCanvasContainer.LifeAssured> {lifeAssured, lifeAssured2});

		Test.startTest();

		AW_CTRL_BPOCanvasContainer.createQuoteWithExternalIdForContract
				(quoteExternalIdForTest, 'pdf_Name', opp.Id, financialAccount.FinServ__FinancialAccountNumber__c, '[]', lifeAssuredJson, 
                 'Financial Account', financialAccount.AW_ProductCategory__c,financialAccount.Name);

		Test.stopTest();

		Quote quoteToBeTested = AW_DAL_Quote.findByQuoteSolutionNumber(quoteExternalIdForTest);

		System.assertEquals(quoteToBeTested.AW_Quote_Solution_Number__c, quoteExternalIdForTest, 'Quote Solution Number not populated as expected');
		System.assertEquals(quoteToBeTested.OpportunityId, opp.Id, 'Opportunity Id not populated as expected');
		System.assertEquals(quoteToBeTested.AW_Product_Category__c, AW_DAL_Quote.PRODUCT_CATEGORY_INVESTMENT, 'product category not populated as expected');

	}

	/**
	 * @description This test method tests the empty id flow for the method createQuoteWithExternalIdForContract and checks
	 * 				that the method behaves correctly.
	 */
	@IsTest
	private static void createQuoteWithExternalIdForContract_emptyIdScenarioTest()
	{
		Test.startTest();

		AW_CTRL_BPOCanvasContainer.createQuoteWithExternalIdForContract('', '', '', '', '[]', '[]', '', '','');

		Test.stopTest();

		List<Quote> quoteToBeTested = AW_DAL_Quote.getAll();

		System.assertEquals(quoteToBeTested.size(), 0);
	}
}