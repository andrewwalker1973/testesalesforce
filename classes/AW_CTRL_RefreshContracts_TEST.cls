/**
 * @description Test class related to the AW_CTRL_RefreshContracts
 *
 * @see AW_CTRL_RefreshContracts
 *
 * @author prashant.k.jain@accenture.com, jason.van.beukering@accenture.com
 *
 * @date May 2021, May 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_CTRL_RefreshContracts_TEST
{
	private static final String POLICY_REQUESTED_STATUS = 'Requested';

	/**
	 * @description Will test the successful execution of a refresh request for business account
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void successfulCallBusinessAccount()
	{
		Account newAccount = AW_DAL_TestDataFactory.createBusinessAccounts().iterator().next();

		Test.startTest();

		AW_CTRL_RefreshContracts.DTO_Response dtoResponse = AW_CTRL_RefreshContracts.triggerRefreshContract(newAccount.Id);

		Test.stopTest();

		Assert.isTrue(dtoResponse.callSuccessful, 'Refresh Contracts failed.');
	}

	/**
	 * @description Will test the successful execution of a refresh request for person account
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void successfulCallClientAccount()
	{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

		Test.startTest();

		AW_CTRL_RefreshContracts.DTO_Response dtoResponse = AW_CTRL_RefreshContracts.triggerRefreshContract(newAccount.Id);

		Test.stopTest();

		Assert.isTrue(dtoResponse.callSuccessful, 'Refresh Contracts failed.');
	}

	/**
	 * @description Will test the failed execution of a refresh request
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void failedCall()
	{
		Test.startTest();

		AW_CTRL_RefreshContracts.DTO_Response dtoResponse = AW_CTRL_RefreshContracts.triggerRefreshContract(UserInfo.getUserId());

		Test.stopTest();

		Assert.isFalse(dtoResponse.callSuccessful, 'Refresh Contracts did not fail as expected.');
	}

	/**
	 * @description method to update the Master Account
	 *
	 * @see AW_CTRL_RefreshContracts.accountToUpdate
	 */
	@IsTest
	private static void updateMasterAccounts()
	{
		Datetime newDate = System.now();

		Account newAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		newAccount.AW_PoliciesRefreshStatusDate__c = newDate;
		newAccount.AW_PoliciesRefreshStatus__c = POLICY_REQUESTED_STATUS;

		List<String> accountIds;

		Test.startTest();

		System.runAs(SC_DAL_User.findRandomActiveAgent())
		{
			accountIds = AW_CTRL_RefreshContracts.accountToUpdate(new List<Account> {newAccount});
		}

		Test.stopTest();

		newAccount = AW_DAL_Account.findById(newAccount.Id);

		Assert.areEqual(newDate, newAccount.AW_PoliciesRefreshStatusDate__c, 'Account Policy Refresh Date not updated as expected');
		Assert.areEqual(POLICY_REQUESTED_STATUS, newAccount.AW_PoliciesRefreshStatus__c, 'Account Policy Refresh Status not updated as expected');
	}
}