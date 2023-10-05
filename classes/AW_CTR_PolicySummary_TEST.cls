/**
 * @description Test class for AW_CTR_PolicySummary
 *
 * @see AW_CTR_PolicySummary @story ST-11986
 * @see AW_API_RestOutboundPolicySummary
 *
 * @author thirugnana.sambandam@lntinfotech.com prashant.k.jain@accenture.com
 *
 * @date July 2021, February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_CTR_PolicySummary_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description Tests that policy summary is retrieved for a Financial Account
	 */
	@IsTest
	private static void getPolicyForFinancialAccount()
	{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

		FinServ__FinancialAccount__c newFinancialAccount = AW_DAL_TestDataFactory.createFinancialAccounts(newAccount, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		Test.startTest();

		Map<String, Object> policySummary = AW_CTR_PolicySummary.getPolicySummary(newFinancialAccount.Id);

		Test.stopTest();

		System.assertEquals(false, policySummary.isEmpty(), 'No policy were returned as expected');

	}
	/**
	 * @description Tests that policy summary is retrieved for an Insurance Policy
	 */
	@IsTest
	private static void getPolicyForInsurancePolicy()
	{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		FinServ__FinancialGoal__c newGoal = AW_DAL_TestDataFactory.createGoals(newAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		InsurancePolicy newInsurancePolicy = AW_DAL_TestDataFactory.createInsurancePolicies(newAccount, newGoal, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		Test.startTest();

		Map<String, Object> policySummary = AW_CTR_PolicySummary.getPolicySummary(newInsurancePolicy.Id);

		Test.stopTest();

		System.assertEquals(false, policySummary.isEmpty(), 'No policy were returned as expected');
	}

	/**
	 * @description Will test that the controller returns the error thrown by API due to contract number being blank
	 */
	@IsTest
	private static void contractNumberBlank()
	{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

		FinServ__FinancialAccount__c newFinancialAccount = AW_DAL_TestDataFactory.createFinancialAccounts(newAccount, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		newFinancialAccount.FinServ__FinancialAccountNumber__c = CMN_UTIL_String.EMPTY;
		update newFinancialAccount;

		try
		{
			Test.startTest();

			AW_CTR_PolicySummary.getPolicySummary(newFinancialAccount.Id);

			System.assert(false, 'Controller did not throw exception as expected');

			Test.stopTest();
		}
		catch(Exception error)
		{
			System.assert(true, 'Service threw exception as expected');
		}
	}
}