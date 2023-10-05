/**
 * @description Test class for Financial Account Trigger
 *
 * @see AW_TH_FinancialAccount
 *
 * @author jayanth.kumar.s@accenture.com, jason.van.beukering@accenture.com
 *
 * @date 2019, February 2023
 */
@IsTest(SeeAllData=false IsParallel=false)
private class AW_TEST_TH_FinancialAccount
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;
	private static final String ERROR_ITEM_NOT_LINKED = 'Item was not linked to master account';
	private static final String ERROR_OWNER_INCORRECT = 'The Owner Id incorrectly set';
	private static final String ERROR_OWNER_NOT_SAME = 'Owner is not same as Account Owner';

	/**
	 * @description To setup the test data
	 */
	@TestSetup
	private static void setup()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		//Ensure that we create community account and user and community account owned by an adviser
		System.runAs(adviser)
		{
			AW_DAL_TestDataFactory.createCommunityUser();
		}
	}

	/**
	 * @description Method to find the created account
	 *
	 * @return Account
	 */
	private static Account findCreatedAccount()
	{
		List<Account> newAccounts = AW_DAL_Account.getAll();

		Assert.isFalse(newAccounts.isEmpty(), 'Community  Account not created.');

		return newAccounts.iterator().next();
	}

	/**
	 * @description Test Method to create the Financial account and set the Owner
	 */
	@IsTest
	private static void setOwnerToAdviser()
	{
		Account createdAccount = findCreatedAccount();
		User communityUser = AW_DAL_User.findCommunityUser(createdAccount.Id);

		User adviserUser = AW_DAL_User.findById(createdAccount.OwnerId);
		FinServ__FinancialAccount__c newFinancialAccount =
				AW_DAL_TestDataFactory.createFinancialAccounts(createdAccount, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		System.runAs(communityUser)
		{
			Test.startTest();

			Test.stopTest();

			newFinancialAccount = AW_DAL_FinancialAccount.findById(newFinancialAccount.Id);

			Assert.areEqual(adviserUser.Id, newFinancialAccount.OwnerId, ERROR_OWNER_INCORRECT);
		}
	}

	/**
	 * @description Test method to test whether a FinancialAccount is related to Business Master Account on Insert
	 */
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	@IsTest
	private static void linkToMasterBusinessAccount()
	{
		Account childAccount = AW_DAL_TestDataFactory.createBusinessChildAccountWithMaster();

		Test.startTest();

		FinServ__FinancialAccount__c newFinancialAccount = AW_DAL_TestDataFactory.createFinancialAccounts(childAccount, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		Test.stopTest();

		newFinancialAccount = AW_DAL_FinancialAccount.findById(newFinancialAccount.Id);
		Assert.isNotNull(newFinancialAccount.AW_MasterAccount__c, ERROR_ITEM_NOT_LINKED);
		Assert.areEqual
				(AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT, newFinancialAccount.CMN_MasterAccountRecordTypeName__c, 'Record Type name not set as expected');
	}

	/**
	 * @description Test method to test whether a FinancialAccount is related to MasterAccount on Insert
	 */
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	@IsTest
	private static void linkToNonMasterAccount()
	{
		Account childAccount = AW_DAL_TestDataFactory.createClientAccount(AW_UTIL_IdentityNumber.generateRandomIdentityNumber()).iterator().next();

		Test.startTest();

		FinServ__FinancialAccount__c newFinancialAccount = AW_DAL_TestDataFactory.createFinancialAccounts(childAccount, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		Test.stopTest();

		newFinancialAccount = AW_DAL_FinancialAccount.findById(newFinancialAccount.Id);
        
		Assert.isNotNull(newFinancialAccount.CMN_MasterAccountRecordTypeName__c, 'Record Type name not blank as expected');
	}

	/**
	 * @description Test method to test whether a Master Person Account RecordType name is set on FinancialAccount
	 */
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs,PMD.ApexUnitTestClassShouldHaveAsserts')
	@IsTest
	private static void setMasterPersonAccountRecordTypeName()
	{
		linkToMasterAccount(true);
	}

	/**
	 * @description Test method to test whether a Master Business Account RecordType name is set on FinancialAccount
	 */
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs,PMD.ApexUnitTestClassShouldHaveAsserts')
	@IsTest
	private static void setMasterBusinessAccountRecordTypeName()
	{
		linkToMasterAccount(false);
	}

	/**
	 * @description common method to check if the master account record type name is populated on financial account
	 *
	 * @param isMasterIndividual flag to indicate to link Financial Account to Master Person or Master Individual Account
	 */
	private static void linkToMasterAccount(Boolean isMasterIndividual)
	{
		String recordTypeName = isMasterIndividual ? AW_DAL_Account.RT_PERSON_MASTER_ACCOUNT : AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT;

		Test.startTest();

		FinServ__FinancialAccount__c newFinancialAccount = SC_DAL_DataFactory.linkFinancialAccountToMasterAccount(isMasterIndividual);

		Test.stopTest();

		newFinancialAccount = AW_DAL_FinancialAccount.findById(newFinancialAccount.Id);
		Assert.areEqual
				(recordTypeName, newFinancialAccount.CMN_MasterAccountRecordTypeName__c, 'Record Type name not set as expected');
	}

	/**
	 * @description Test method to test whether a FinancialAccount owner is set to parent account owner if PA creates the record
	 */
	@IsTest
	private static void setOwner()
	{
		Account createdAccount = findCreatedAccount();

		User personalAssistant = AW_DAL_User.findActivePersonalAssistantByAdviser(createdAccount.OwnerId);

		FinServ__FinancialAccount__c newFinancialAccount;

		System.runAs(personalAssistant)
		{
			Test.startTest();

			newFinancialAccount = AW_DAL_TestDataFactory.createFinancialAccounts(createdAccount, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

			Test.stopTest();
		}

		AW_DAL_User.findByAccountId(createdAccount.Id);
		newFinancialAccount = AW_DAL_FinancialAccount.findById(newFinancialAccount.Id);

		Assert.areEqual(createdAccount.OwnerId, newFinancialAccount.OwnerId, ERROR_OWNER_NOT_SAME);
	}

	/**
	 * @description Test Method to create and test the Financial account and set to client
	 */
	@IsTest
	private static void setOwnerToClient()
	{
		Account createdAccount = findCreatedAccount();
		User communityUser = AW_DAL_User.findCommunityUser(createdAccount.Id);
		FinServ__FinancialAccount__c newFinancialAccount =
				AW_DAL_TestDataFactory.createFinancialAccounts(createdAccount, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		System.runAs(communityUser)
		{

			Test.startTest();

			newFinancialAccount.AW_AUMSourceExternalId__c = null;
			newFinancialAccount.AW_ShareWithMyAdviser__c = false;

			update newFinancialAccount;

			Test.stopTest();

			newFinancialAccount = AW_DAL_FinancialAccount.findById(newFinancialAccount.Id);

			System.assertEquals(communityUser.Id, newFinancialAccount.OwnerId, ERROR_OWNER_INCORRECT);
		}
	}
}