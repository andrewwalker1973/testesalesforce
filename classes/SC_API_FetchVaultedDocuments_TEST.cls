/**
 * @description Test class for SC_API_FetchVaultedDocuments
 *
 * @see SC_API_FetchVaultedDocuments @story ST-118605,ST-178029, ST-284351
 *
 * @author jason.van.beukering@accenture.com jayanth.kumar.s@accenture.com meghana.g.n@accenture.com
 *
 * @date May 2021, May 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class SC_API_FetchVaultedDocuments_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;
	private static User adviser = AW_DAL_User.findRandomActiveAdviser();

	/**
	 * @description Create data required for the unit test
	 */
	@TestSetup
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	private static void setup()
	{
		Account newAccount = AW_DAL_TestDataFactory.createPersonAccounts(AW_DAL_Account.RT_PERSON_ACCOUNT, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		newAccount.OwnerId = adviser.Id;
		update newAccount;
	}

	/**
	 * @description Emulates a successful call and confirms Vaulted docs were correctly set for a lead
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	private static void successfulCallForLead()
	{
		Account accountRecord = AW_DAL_Account.getAll().iterator().next();
		SC_API_VaultedDocumentsHelper_TEST.vaultedDocumentsForLead(SC_API_FetchVaultedDocuments.SERVICE_NAME, accountRecord);
	}

	/**
	 * @description Emulates a successful call and confirms Vaulted docs were correctly set for a lead
	 */
	@IsTest
	private static void successfulCallForOpportunity()
	{
		Account accountRecord = AW_DAL_Account.getAll().iterator().next();
		SC_API_VaultedDocumentsHelper_TEST.validateVaultedDocumentsForOpportunity(SC_API_FetchVaultedDocuments.SERVICE_NAME, accountRecord);
	}

	/**
	 * @description Emulates a successful call and confirms Vaulted docs were correctly set for a lead
	 */
	@IsTest
	private static void successfulCallForOutstandingRequirement()
	{
		Account accountRecord = AW_DAL_Account.getAll().iterator().next();
		SC_API_VaultedDocumentsHelper_TEST.validateVaultedDocumentsForOutstandingRequirement(SC_API_FetchVaultedDocuments.SERVICE_NAME, accountRecord);
	}

	/**
	 * @description To verify and confirms Vaulted docs were correctly set for a person account
	 */
	@IsTest
	private static void validateVaultedDocumentsForPersonAccount()
	{
		Account masterPersonAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		SC_API_VaultedDocumentsHelper_TEST.validateVaultedDocuments(SC_API_FetchVaultedDocuments.SERVICE_NAME, masterPersonAccount);
	}

	/**
	 * @description Check that the service abort if the Id provides is not of the correct object type for person account
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	private static void abortedCallWrongObjectTypeForPerson()
	{
		SC_API_VaultedDocumentsHelper_TEST.runAbortedTest(UserInfo.getUserId(), SC_API_FetchVaultedDocuments.SERVICE_NAME);
	}

	/**
	 * @description Check that the service abort if the person account is not found
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	private static void abortedAccountNotFoundForPerson()
	{
		SC_API_VaultedDocumentsHelper_TEST.abortedAccountNotFound(SC_API_FetchVaultedDocuments.SERVICE_NAME);
	}
}