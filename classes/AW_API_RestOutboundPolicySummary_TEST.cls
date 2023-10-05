/**
 * @description Test class for AW_API_RestOutboundPolicySummary
 *
 * @see AW_API_RestOutboundPolicySummary @story ST-11986
 *
 * @author Thirugnana.sambandam@lntinfotech.com jason.van.beukering@accenture.com
 *
 * @date July 2021, February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
public class AW_API_RestOutboundPolicySummary_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;
	/**
	 * @description Create data required for the unit test
	 */
	@TestSetup
	private static void setup()
	{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		AW_DAL_TestDataFactory.createFinancialAccounts(newAccount, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		FinServ__FinancialGoal__c newGoal = AW_DAL_TestDataFactory.createGoals(newAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		AW_DAL_TestDataFactory.createInsurancePolicies(newAccount, newGoal, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
	}

	/**
	 * @description - successful call and confirms policy summary are fetched successfully
	 */
	@IsTest
	private static void successfulCallWithFinancialAccount()
	{
		FinServ__FinancialAccount__c newFinancialAccount = AW_DAL_FinancialAccount.getAll().iterator().next();
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RestOutboundPolicySummary.SERVICE_NAME, newFinancialAccount.Id);
		CMN_API_RestBaseOutboundTestHelper.successfulCall(new List<CMN_WebserviceCallQueue__c>
		{
				queueItem
		});
	}

	/**
	 * @description - successful call and confirms policy summary are fetched successfully
	 */
	@IsTest
	private static void successfulCallWithInsurancePolicy()
	{
		InsurancePolicy newInsurancePolicy = AW_DAL_InsurancePolicy.getAll().iterator().next();
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RestOutboundPolicySummary.SERVICE_NAME, newInsurancePolicy.Id);
		CMN_API_RestBaseOutboundTestHelper.successfulCall(new List<CMN_WebserviceCallQueue__c>
		{
				queueItem
		});
	}

	/**
	 * @description Check that the service aborted if no item was found
	 *
	 * @see AW_API_RestOutboundPolicySummary.abortRequest
	 */
	@IsTest
	private static void abortedCall()
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RestOutboundPolicySummary.SERVICE_NAME, UserInfo.getUserId());
		CMN_API_RestBaseOutboundTestHelper.abortedCall(new List<CMN_WebserviceCallQueue__c>
		{
				queueItem
		});
	}
}