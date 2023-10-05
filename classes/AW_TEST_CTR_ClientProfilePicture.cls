/**
 * @description Test class for AW_CTR_ClientProfilePicture
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
public class AW_TEST_CTR_ClientProfilePicture
{

	/**
	 * @description Method use to setup the test data .
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
	 * @description Method use to get the Account.
	 *
	 * @return List of Account
	 */
	private static Account findCreatedAccount()
	{
		List<Account> newAccounts = AW_DAL_Account.getAll();

		System.assertEquals(1, newAccounts.size(), 'Community  Account not created.');

		return newAccounts[0];
	}

	/**
	 * @description Method use to get community users.
	 *
	 * @return List of Users
	 */
	private static User findCommunityUser()
	{
		Account createdAccount = findCreatedAccount();
		return AW_DAL_User.findCommunityUser(createdAccount.Id);
	}

	/**
	 * @description Test method is use to test the community user
	 */
	@IsTest
	private static void getCommunityUserDetails()
	{
		User communityUser = findCommunityUser();

		Test.startTest();

		User foundUser = AW_CTR_ClientProfilePicture.getCommunityUserDetails(communityUser.AccountId);

		Test.stopTest();

		System.assertEquals(communityUser.Id, foundUser.Id, 'User returned is invalid.');
	}

	@IsTest
	private static void absentCommunityUser()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		System.runAs(adviser)
		{
			Test.startTest();

			User foundUser = AW_CTR_ClientProfilePicture.getCommunityUserDetails(null);

			Test.stopTest();

			System.assertEquals(null, foundUser, 'No user should be returned.');
		}

	}

}