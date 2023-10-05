/**
 * @description Test various methods of related DAL class
 *
 * @see CMN_DAL_User
 *
 * @author jason.van.beukering@accenture.com, latika.kharbanda@accenture.com
 *
 * @date October 2020, November 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_DAL_User_TEST
{
	private static final Integer NUMBER_OF_USERS_TO_CREATE = 50;

	/**
	 * @description Test the method to check if the current user is system administrator profile
	 */
	@IsTest
	private static void isCurrentUserSystemAdmin()
	{
		User newUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN);

		System.runAs(newUser)
		{
			Test.startTest();

			Boolean isSysAdmin = CMN_DAL_User.isCurrentUserSystemAdmin();

			Test.stopTest();

			Assert.isTrue(isSysAdmin, 'User should be system admin');
		}
	}

	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void findRandomActiveByProfileName()
	{
		List<User> newUsers = new List<User>();

		for(Integer i = 0; i < NUMBER_OF_USERS_TO_CREATE; i++)
		{
			newUsers.add(CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_CHATTER_FREE_USER));
		}

		CMN_DAL_SObjectDomain.insertDBObjects(newUsers);

		Test.startTest();

		User foundUser1 = CMN_DAL_User.findRandomActiveByProfileName(CMN_DAL_Profile.PROFILE_CHATTER_FREE_USER);
		User foundUser2 = CMN_DAL_User.findRandomActiveByProfileName(CMN_DAL_Profile.PROFILE_CHATTER_FREE_USER);

		Test.stopTest();

		Assert.areNotEqual(foundUser1.Id, foundUser2.Id, 'Random User not retrieved');
	}

	/**
	 * @description tests that user is not found if fake or random federation id is used
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void findUserByFederationIdNegative()
	{
		Assert.isNull(CMN_DAL_User.findUserByFederationId(CMN_DAL_SObjectDomain.generateRandomEmail()), 'No federation Id should be found');
	}

	/**
	 * @description Will see that method returns list of active users
	 */
	@IsTest
	private static void findActiveUsers()
	{
		User newUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN);

		System.runAs(newUser)
		{
			Test.startTest();

			List<User> foundUsers = CMN_DAL_User.findActiveUsers(CMN_DAL_DataFactory.NUMBER_OF_ACTIVE_USERS_TO_RETRIEVE);

			Test.stopTest();

			Assert.isFalse(foundUsers.isEmpty(), 'There should be at least 1 active user');
			Assert.isTrue(foundUsers.size() <= CMN_DAL_DataFactory.NUMBER_OF_ACTIVE_USERS_TO_RETRIEVE, 'The number of active users found is incorrect');
		}
	}
}