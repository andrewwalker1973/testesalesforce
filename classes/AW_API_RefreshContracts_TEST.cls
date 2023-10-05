/**
 * @description Test class for AW_API_RefreshContracts
 *
 * @see AW_API_RefreshContracts
 *
 * @author jason.van.beukering@accenture.com, jayanth.kumar.s@accenture.com
 *
 * @date May 2021, May 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class AW_API_RefreshContracts_TEST
{
	/**
	 * @description Will execute common code required for running successful test
	 *
	 * @param newAccount newly created account
	 * @param isSuccessful flag to check if successful
	 */
	private static void executeTest(Account newAccount, Boolean isSuccessful)
	{
		if(isSuccessful)
		{

			CMN_API_RestBaseOutboundTestHelper.successfulCall(AW_API_RefreshContracts.SERVICE_NAME, newAccount.Id);
		}
		else
		{
			CMN_API_RestBaseOutboundTestHelper.abortedCall(AW_API_RefreshContracts.SERVICE_NAME, newAccount.Id);
		}
	}

	/**
	 * @description Emulates a successful call and confirms contracts for a person account are fetched successfully
	 */
	@IsTest
	private static void successfulCallPerson()
	{
		executeTest(AW_DAL_TestDataFactory.createClientAccount().iterator().next(), true);
	}

	/**
	 * @description Emulates a successful call and confirms contracts for a business account are fetched successfully
	 */
	@IsTest
	private static void successfulCallBusiness()
	{
		executeTest(AW_DAL_TestDataFactory.createBusinessAccounts().iterator().next(), true);
	}

	/**
	 * @description Check the identification type as passport
	 *
	 * @see AW_API_RefreshContracts.abortRequest
	 */
	@IsTest
	private static void successfulCallPersonPassport()
	{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

		newAccount.AW_BypassValidationRules__c = true;
		newAccount.AW_IdentificationNumber__pc = CMN_DAL_SObjectDomain.generateRandomNumber();
		newAccount.AW_IdentificationType__pc = AW_DAL_Account.PICK_PASSPORT_TYPE;
		update newAccount;

		executeTest(newAccount, true);

		newAccount = AW_DAL_Account.findById(newAccount.Id);
		Assert.areEqual(AW_DAL_Account.PICK_REFRESH_REQUESTED, newAccount.AW_PoliciesRefreshStatus__c, 'Refresh status not set correctly');

	}

	/**
	 * @description Check the contract refresh as agent
	 */
	@IsTest
	private static void successfulCallPersonAsAgent()
	{
		User activeAgent = SC_DAL_User.findRandomActiveAgent();
		//Setting the agent as the owner of the account as the criteria based sharing doesnt works in test class, hence the test should be either ignored
		//to run as specific user or the running user should be made as the owner of the client.
		Account newMasterAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		newMasterAccount.OwnerId = activeAgent.Id;
		update newMasterAccount;

		System.runAs(activeAgent)
		{
			executeTest(newMasterAccount, true);
		}

		newMasterAccount = AW_DAL_Account.findById(newMasterAccount.Id);
		Assert.areEqual(AW_DAL_Account.PICK_REFRESH_REQUESTED, newMasterAccount.AW_PoliciesRefreshStatus__c, 'Refresh status not set correctly');

	}

	/**
	 * @description Check that the service aborts if the Id provided does not find an account
	 *
	 * @see AW_API_RefreshContracts.abortRequest
	 */
	@IsTest
	private static void abortedCallItemNotFound()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(AW_API_RefreshContracts.SERVICE_NAME, UserInfo.getUserId());
	}

	/**
	 * @description Check that the service aborts if the account doesn't have an identification number
	 *
	 * @see AW_API_RefreshContracts.abortRequest
	 */
	@IsTest
	private static void abortedCallBusinessNoIdentificationNumber()
	{
		Account newAccount = AW_DAL_TestDataFactory.createBusinessAccounts().iterator().next();
		newAccount.AW_CompanyRegistrationTrustNumber__c = null;
		update newAccount;

		executeTest(newAccount, false);
	}

	/**
	 * @description Check that the service aborts if the account doesn't have an identification number
	 *
	 * @see AW_API_RefreshContracts.abortRequest
	 */
	@IsTest
	private static void abortedCallClientNoIdentificationNumber()
	{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		newAccount.AW_IdentificationNumber__pc = null;
		newAccount.AW_IdentificationType__pc = null;

		AW_FeatureSwitches__c switches = AW_DAL_FeatureSwitches.getFeatureSwitch(UserInfo.getUserId());
		switches.AW_DisableAccountValidationRules__c = true;
		upsert switches;

		update newAccount;

		executeTest(newAccount, false);
	}
}