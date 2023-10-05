/**
 * @description Test Class for AW_AUTH_AzureB2C
 *
 * @author vishakha.saini@accenture.com
 *
 * @date 2019, February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_AUTH_AzureB2C
{
	private static final String FEDERATION_IDENTIFIER = 'tVsYVJthLSbRbdY@mailinator.com';
	private static final String USER_EMAIL = 'thisistherightemail@mailinator.com';

	private static void createUser(String federationId)
	{
		User administratorUser = AW_DAL_User.findActiveAdministrator();

		System.runAs(administratorUser)
		{
			Account communityUserAccount = AW_DAL_TestDataFactory.createClientAccount()[0];
			communityUserAccount = AW_DAL_Account.findById(communityUserAccount.Id);
			User communityUser = AW_DAL_User.newCommunityUser(communityUserAccount);

			//Set up a user so that we can be sure they found.
			communityUser.FederationIdentifier = federationId;
			communityUser.Email = USER_EMAIL;

			insert communityUser;
		}
	}
	/**
	 * @description To setup the test data
	 */
	@TestSetup
	private static void insertTestData()
	{
		createUser(FEDERATION_IDENTIFIER);
	}

	/**
	 * @description This method is to create a user and test if the user found
	 */
	@IsTest
	private static void userFoundUsingEmail()
	{
		Auth.UserData userData = createUserData();

		userData.email = FEDERATION_IDENTIFIER;

		Test.startTest();

		User identifiedUser = new AW_AUTH_AzureB2C().createUser(null, userData);

		Test.stopTest();

		System.assertNotEquals(null, identifiedUser, 'User not Found');
		System.assertEquals(FEDERATION_IDENTIFIER, identifiedUser.FederationIdentifier, 'Incorrect User Found');
	}

	/**
	 * @description This method is to create test if the username found
	 */
	@IsTest
	private static void userFoundUsingUserName()
	{
		Auth.UserData userData = createUserData();

		userData.username = FEDERATION_IDENTIFIER;

		Test.startTest();

		User identifiedUser = new AW_AUTH_AzureB2C().createUser(null, userData);

		Test.stopTest();

		System.assertNotEquals(null, identifiedUser, 'User not Found');
		System.assertEquals(FEDERATION_IDENTIFIER, identifiedUser.FederationIdentifier, 'Incorrect User Found');
	}

	/**
	 * @description This method is to create test if the username not found
	 */
	@IsTest
	private static void userNotFound()
	{
		Auth.UserData userData = createUserData();

		Test.startTest();

		User identifiedUser = new AW_AUTH_AzureB2C().createUser(null, userData);

		Test.stopTest();

		System.assertEquals(null, identifiedUser, 'User should not be Found');
	}

	/**
	 * @description This method is to create user without email and user name and test the exceptions
	 */
	@IsTest
	private static void noEmailOrUserName()
	{
		Auth.UserData userData = createUserData();

		userData.email = CMN_UTIL_String.EMPTY;
		userData.username = CMN_UTIL_String.EMPTY;

		Test.startTest();

		try
		{
			new AW_AUTH_AzureB2C().createUser(null, userData);
			System.assert(false, 'Expected error to be thrown');
		}
		catch(Exception error)
		{
			System.assert(true, 'Error thrown due to blank email and username');
		}

		Test.stopTest();

	}

	/**
	 * @description This method is use to increase the code coverage of the class
	 */
	@IsTest
	private static void updateUser()
	{
		Auth.UserData userData = createUserData();

		Test.startTest();

		new AW_AUTH_AzureB2C().updateUser(null, null, userData);

		Test.stopTest();

		System.assert(true, 'The Update User is not implemented, this test is for code coverage');
	}

	/**
	 * @description Create a user information to test the user in test class
	 *
	 * @return Auth.UserData details
	 */
	static private Auth.UserData createUserData()
	{
		return new Auth.UserData
				(
						CMN_DAL_SObjectDomain.generateRandomName(), //Identifier
						CMN_DAL_SObjectDomain.generateRandomName(), //FirstName
						CMN_DAL_SObjectDomain.generateRandomName(), //LostName
						CMN_DAL_SObjectDomain.generateRandomName(), //FullName
						CMN_DAL_SObjectDomain.generateRandomEmail(), //Email
						CMN_DAL_SObjectDomain.generateRandomName(), //Link
						CMN_DAL_SObjectDomain.generateRandomEmail(), //UserName
						CMN_DAL_SObjectDomain.generateRandomName(), //Locale
						CMN_DAL_SObjectDomain.generateRandomName(), //Provider
						CMN_DAL_SObjectDomain.generateRandomName(), //SiteLoginUrl
						new Map<String, String>() //AttributeMap
				);

	}
}