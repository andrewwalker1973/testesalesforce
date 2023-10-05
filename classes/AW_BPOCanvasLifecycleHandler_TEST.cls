/**
 * @description This class is the apex test class for the class AW_BPOCanvasLifecycleHandler
 *
 * @see AW_BPOCanvasLifecycleHandler
 *
 * @author pavan.t@lntinfotech.com kiran.kumaryelisetti@lntinfotech.com vishakha.saini@accenture.com
 *
 * @date November 2020, March 2023, July 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_BPOCanvasLifecycleHandler_TEST
{
	private static final String QUOTE_EXTERNAL_ID = '123456789';
	private static final String RISK_FINANCIAL_GOAL_NAME = 'Life Cover';
	private static final String PRODUCT_TYPE_LIFE_ANNUITY = '47';

	/**
	 * @description This setup test method prepares the data for the test methods
	 */
	@TestSetup
	private static void testSetup()
	{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

		AW_DAL_TestDataFactory.createDefaultOpportunities(newAccount, 1);

		List<AW_FNA__c> listFNA = AW_DAL_TestDataFactory.createFNA(newAccount.Id, 1);

		FinServ__FinancialGoal__c goal = AW_DAL_TestDataFactory.createGoals(newAccount.Id, 1).iterator().next();
		goal.AW_FNA__c = listFNA.iterator().next().Id;
		update goal;

		AW_DAL_TestDataFactory.createSolutions(goal.Id, 1);
	}

	/**
	 * @description This test method tests the Canvas Lifecycle Handler with overwritten app values and
	 * overwritten environment values
	 */
	@IsTest
	@SuppressWarnings('ApexScopeAgreement, PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void testCanvasLifecycleHandlerOverriddenValues()
	{
		AW_Planned_Solution__c plannedSolution = AW_DAL_PlannedSolution.getAll().iterator().next();
		Quote newQuote = AW_DAL_TestDataFactory.createQuoteWithQuoteNumber(plannedSolution.AW_Opportunity_Name__r.Id, QUOTE_EXTERNAL_ID, true);
		newQuote.AW_Product_Type__c = PRODUCT_TYPE_LIFE_ANNUITY;
		update newQuote;

		//        Set some application context data in a Map
		Map<String, String> appValues = new Map<String, String>();
		appValues.put(Canvas.Test.KEY_NAMESPACE, 'alternateNamespace');
		appValues.put(Canvas.Test.KEY_VERSION, '3.0');

		//        Set some environment context data in a Map
		Map<String, String> envValues = new Map<String, String>();
		envValues.put(Canvas.Test.KEY_DISPLAY_LOCATION, 'Chatter');
		envValues.put(Canvas.Test.KEY_LOCATION_URL, 'https://yourInstance.salesforce.com/_ui/core/chatter/ui/ChatterPage');

		AW_BPOCanvasLifecycleHandler handler = new AW_BPOCanvasLifecycleHandler();
		//        Create a mock RenderContext using the test application and environment context data Maps
		Canvas.RenderContext mock = Canvas.Test.mockRenderContext(appValues, envValues);

		//        Set custom params on the mock RenderContext
		Map<String, Object> mockParams = new Map<String, String>();
		mockParams.put('plannedSolutionId', plannedSolution.Id);
		mockParams.put('quoteSolutionNumber', newQuote.AW_Quote_Solution_Number__c);
		mock.getEnvironmentContext().setParametersAsJSON(JSON.serialize(mockParams));
		Canvas.Test.testCanvasLifecycle(handler, mock);

		Map<String, Object> finalParams = (Map<String, Object>)JSON.deserializeUntyped(mock.getEnvironmentContext().getParametersAsJSON());

		Assert.areEqual(finalParams.get('clientFirstName'), plannedSolution.AW_Opportunity_Name__r.Account.FirstName, 'Client first name should be equal');
		Assert.areEqual(finalParams.get('clientLastName'), plannedSolution.AW_Opportunity_Name__r.Account.LastName, 'Client last name should be equal');
		Assert.areEqual(finalParams.get('clientRetirementAge'), plannedSolution.AW_Opportunity_Name__r.Account.Retirement_Age__pc, 'Client retirement age should be equal');
		Assert.areEqual(finalParams.get('clientIdPassportNumber'),
				plannedSolution.AW_Opportunity_Name__r.Account.AW_IdentificationNumber__pc, 'Client identification number shoulld be equal');
		Assert.areEqual(finalParams.get('solutionLumpsumAmount'), plannedSolution.AW_Lumpsum_Amount__c, 'Lumpsum amount should be equal');
		Assert.areEqual(finalParams.get('solutionGrowthStrategy'), plannedSolution.AW_Growth_Strategy__c, 'Growth Strategy should be equal');
		Assert.areEqual(finalParams.get('solutionPremiumAmount'), plannedSolution.AW_Premium_Amount__c, 'Premium amount should be equal');
		Assert.areEqual(finalParams.get('solutionPremiumFrequency'), plannedSolution.AW_PremiumFrequency__c, 'Premium frequency should be equal');

	}

	@IsTest
	@SuppressWarnings('ApexScopeAgreement, PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void testCanvasLifecycleHandlerForNullQuoteSolutionNumber()
	{
		AW_Planned_Solution__c plannedSolution = AW_DAL_PlannedSolution.getAll().iterator().next();
		AW_DAL_TestDataFactory.createQuoteWithQuoteNumber(plannedSolution.AW_Opportunity_Name__r.Id, QUOTE_EXTERNAL_ID, true);
		FinServ__FinancialGoal__c financialGoal = AW_DAL_FinancialGoal.findById(plannedSolution.AW_Financial_Goal__c);
		financialGoal.Name = RISK_FINANCIAL_GOAL_NAME;
		financialGoal.AW_Goal_Type__c = AW_DAL_FinancialGoal.PICK_RISK_GOAL_TYPE;
		financialGoal.FinServ__ActualValue__c = Decimal.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber(4));
		financialGoal.FinServ__TargetValue__c = Decimal.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber(5));
		update financialGoal;
		//        Set some application context data in a Map
		Map<String, String> appValues = new Map<String, String>();
		appValues.put(Canvas.Test.KEY_NAMESPACE, 'alternateNamespace');
		appValues.put(Canvas.Test.KEY_VERSION, '3.0');

		//        Set some environment context data in a Map
		Map<String, String> envValues = new Map<String, String>();
		envValues.put(Canvas.Test.KEY_DISPLAY_LOCATION, 'Chatter');
		envValues.put(Canvas.Test.KEY_LOCATION_URL, 'https://yourInstance.salesforce.com/_ui/core/chatter/ui/ChatterPage');

		AW_BPOCanvasLifecycleHandler handler = new AW_BPOCanvasLifecycleHandler();
		//        Create a mock RenderContext using the test application and environment context data Maps
		Canvas.RenderContext mock = Canvas.Test.mockRenderContext(appValues, envValues);

		//        Set custom params on the mock RenderContext
		Map<String, Object> mockParams = new Map<String, String>();
		mockParams.put('plannedSolutionId', plannedSolution.Id);
		mockParams.put('quoteSolutionNumber', null);
		mock.getEnvironmentContext().setParametersAsJSON(JSON.serialize(mockParams));
		Canvas.Test.testCanvasLifecycle(handler, mock);
		Set<Canvas.ContextTypeEnum> excludedAttributes = handler.excludeContextTypes();

		Map<String, Object> finalParams = (Map<String, Object>)JSON.deserializeUntyped(mock.getEnvironmentContext().getParametersAsJSON());
		Assert.areEqual(finalParams.get('isRiskGoalSync'), true, 'Risk goal sync flag should be true');
		Assert.areEqual(finalParams.get('quoteSolutionNumber'), '0', 'Quote solutinon number should be 0');
		FinServ__FinancialGoal__c foundGoal = AW_DAL_FinancialGoal.findById(financialGoal.Id);
		Assert.areEqual(finalParams.get('shortFallorSurpLusAmount'), foundGoal.AW_Shortfall__c < 0 ?
				'' + foundGoal.Name.deleteWhitespace() + ':' + foundGoal.AW_Shortfall__c + '' : '0', 'Shortfall/Surplus amount should match');
		Assert.areEqual(0, excludedAttributes.size(), 'Excluded attributes should be empty');

	}
}