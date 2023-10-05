/**
 * @description Test class Asset and Liabilities
 *
 * @author vishakha.saini@accenture.com, jason.van.beukering@accenture.com
 *
 * @date 2019, January 2023
 */
@IsTest(SeeAllData=false IsParallel=false)
private class AW_TEST_TH_AssetsAndLiabilities
{
	private static final Integer NUMBER_OF_ASSETS_TO_CREATE = 5;
	private static final String ERROR_ITEM_NOT_LINKED = 'Item was not linked to master account';
	private static final String ERROR_OWNER_NOT_SAME = 'Owner is not same as Account Owner';
	private static final String ERROR_THE_OWNER_ID_INCORRECTLY_SET = 'The Owner Id incorrectly set';

	/**
	 * @description Method to setup the test data
	 */
	@TestSetup
	private static void insertTestData()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		//Ensure that we create community account and user and community account owned by an adviser
		System.runAs(adviser)
		{
			AW_DAL_TestDataFactory.createCommunityUser();
		}
	}

	/**
	 * @description Method to get the list of Account
	 *
	 * @return List<Account>
	 */
	private static Account findCreatedAccount()
	{
		List<Account> newAccounts = AW_DAL_Account.getAll();

		Assert.areEqual(1, newAccounts.size(), 'Community  Account not created.');

		return newAccounts.iterator().next();
	}

	/**
	 * @description Will check that items created by community user are set to be shared with  adviser
	 */
	@IsTest
	private static void setAssetOwnerToPrimaryOwnerAccountOwner()
	{
		Account createdAccount = findCreatedAccount();
		User communityUser = AW_DAL_User.findCommunityUser(createdAccount.Id);

		List<User> adviserUsers = AW_DAL_User.findById(new Set<Id> {createdAccount.OwnerId});

		User adviserUser = adviserUsers[0];

		System.runAs(communityUser)
		{
			Test.startTest();

			AW_DAL_TestDataFactory.createAssetsAndLiabilities(createdAccount, NUMBER_OF_ASSETS_TO_CREATE);

			Test.stopTest();

			List<FinServ__AssetsAndLiabilities__c> newAssetsAndLiabilities = AW_DAL_AssetsAndLiabilities.findByPrimaryOwnerId(createdAccount.Id);

			Assert.areEqual(adviserUser.Id, newAssetsAndLiabilities.iterator().next().OwnerId, 'The Owner Id incorrectly  set');
		}
	}

	/**
	 * @description Check to see that if an Asset/Liability will only  be shared with community user when flag is set
	 */
	@IsTest
	private static void setAssetOwnerToCommunityUser()
	{
		Account createdAccount = findCreatedAccount();
		User communityUser = AW_DAL_User.findCommunityUser(createdAccount.Id);

		System.runAs(communityUser)
		{
			List<FinServ__AssetsAndLiabilities__c> newAssetsAndLiabilities =
					AW_DAL_TestDataFactory.createAssetsAndLiabilities(createdAccount, NUMBER_OF_ASSETS_TO_CREATE);

			Test.startTest();

			for(FinServ__AssetsAndLiabilities__c newAssetsAndLiability : newAssetsAndLiabilities)
			{
				newAssetsAndLiability.AW_AUMSourceExternalId__c = null;
				newAssetsAndLiability.AW_ShareWithMyAdviser__c = false;
			}

			update newAssetsAndLiabilities;

			Test.stopTest();

			newAssetsAndLiabilities = AW_DAL_AssetsAndLiabilities.findByPrimaryOwnerId(createdAccount.Id);

			for(FinServ__AssetsAndLiabilities__c newAssetsAndLiability : newAssetsAndLiabilities)
			{
				Assert.areEqual(communityUser.Id, newAssetsAndLiability.OwnerId, ERROR_THE_OWNER_ID_INCORRECTLY_SET);
			}
		}
	}

	/**
	 * @description Test method to test whether a Assets and Liabilities is related to MasterAccount on Insert
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void insertAssetsWithAccount()
	{
		Account childAccount = AW_DAL_TestDataFactory.createPersonChildAccountWithMaster();

		Test.startTest();

		FinServ__AssetsAndLiabilities__c newAssets = AW_DAL_TestDataFactory.createAssetsAndLiabilities(childAccount, NUMBER_OF_ASSETS_TO_CREATE).iterator().next();

		Test.stopTest();

		newAssets = AW_DAL_AssetsAndLiabilities.findById(newAssets.Id);

		Assert.isNotNull(newAssets.AW_MasterAccount__c, ERROR_ITEM_NOT_LINKED);
	}

	/**
	 * @description Test method to test whether a Assets and Liabilities is related to Account owner on Insert
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void updateAssetsWithAccountOwner()
	{
		Account childAccount = findCreatedAccount();

		User personalAssistant = AW_DAL_User.findActivePersonalAssistantByAdviser(childAccount.OwnerId);
		FinServ__AssetsAndLiabilities__c newAsset = AW_DAL_TestDataFactory.newAssetAndLiability(childAccount);

		Test.startTest();

		System.runAs(personalAssistant)
		{
			insert newAsset;
		}

		Test.stopTest();

		newAsset = AW_DAL_AssetsAndLiabilities.findById(newAsset.Id);
		Assert.areEqual(childAccount.OwnerId, newAsset.OwnerId, ERROR_OWNER_NOT_SAME);
	}
}