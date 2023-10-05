/**
 * @description Test class testing all common CMN copy tasks
 *
 * @see CMN_SPC_EnableUsers
 * @see CMN_SPC_DisableApiCalls
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date August 2021, August 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_SPC_Workers_TEST
{
	private static final Integer NUMBER_OF_USERS = 2;

	/**
	 * @description Will create users with a particular profile name
	 *
	 * @param profileName The name of the profile to user for the users
	 *
	 * @return A list of commit users that are inactive and have a dodgy email address
	 */
	private static List<User> setupUsers(String profileName)
	{
		List<User> newUsers = CMN_DAL_DataFactory.insertUsers(profileName, NUMBER_OF_USERS);

		for(User newUser : newUsers)
		{
			newUser.Email = newUser.Email + CMN_DAL_User.INVALID_EMAIL_SUFFIX;
			newUser.IsActive = false;
		}

		CMN_DAL_SObjectDomain.updateDBObjects(newUsers);

		return newUsers;
	}

	/**
	 * @description Creates test data for the unit tests
	 */
	@TestSetup
	private static void setup()
	{
		User newUser = setupUsers(CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN).iterator().next();
		setupUsers(CMN_DAL_Profile.PROFILE_STANDARD_USER);

		User adminUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN);

		System.runAs(adminUser)
		{
			List<CMN_SPC_UsersToEnable__c> customSettings = new List<CMN_SPC_UsersToEnable__c>();

			customSettings.add(CMN_DAL_DataFactory.newSpcUsersToEnable(CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN, CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN, null));
			customSettings.add(CMN_DAL_DataFactory.newSpcUsersToEnable(CMN_DAL_Profile.PROFILE_STANDARD_USER, CMN_DAL_Profile.PROFILE_STANDARD_USER, null));
			customSettings.add(CMN_DAL_DataFactory.newSpcUsersToEnable(newUser.Username, CMN_UTIL_String.EMPTY, newUser.Username));

			CMN_DAL_SObjectDomain.insertDBObjects(customSettings);

			CMN_DAL_DataFactory.createFeatureSwitch(UserInfo.getOrganizationId());
			CMN_DAL_DataFactory.createFeatureSwitch(newUser.Id);
		}
	}

	/**
	 * @description Will check that the users were enabled correctly
	 *
	 * @param profileName The profile to query for users
	 */
	private static void checkUsersAreEnabled(String profileName)
	{
		List<User> foundUsers = CMN_DAL_User.findByProfileName(new Set<String> {profileName});

		for(User foundUser : foundUsers)
		{
			System.assertNotEquals(true, foundUser.Email.endsWith(CMN_DAL_User.INVALID_EMAIL_SUFFIX), 'Email Suffix not removed');
			System.assertEquals(true, foundUser.IsActive, 'User was not made active');
		}
	}

	/**
	 * @description This method tests whether the user email has changed after the queued job ran
	 *
	 * @see CMN_SPC_EnableUsers.enableUsers
	 */
	@IsTest
	private static void enableUsers()
	{
		CMN_SPC_EnableUsers enableUsers = new CMN_SPC_EnableUsers();

		Test.startTest();

		enableUsers.execute(null);

		Test.stopTest();

		checkUsersAreEnabled(CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN);
		checkUsersAreEnabled(CMN_DAL_Profile.PROFILE_STANDARD_USER);

	}

	/**
	 * @description Ensures we cover the code for Mock Sandbox Context class getter
	 */
	@IsTest
	private static void mockSandboxContext()
	{
		CMN_SPC_EnableUsers enableUsers = new CMN_SPC_EnableUsers();

		Test.startTest();

		String orgId = enableUsers.context.organizationId();
		String sandboxId = enableUsers.context.sandboxId();

		Test.stopTest();

		System.assertEquals(UserInfo.getOrganizationId(), orgId);
		System.assertEquals(UserInfo.getOrganizationId(), sandboxId);
	}

	/**
	 * @description This method tests if the org default feature switch is disabled after queued job has ran
	 *
	 * @see CMN_SPC_DisableApiCalls.internalRun
	 */
	@IsTest
	private static void disableApiCalls()
	{
		User adminUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN);
		CMN_SPC_DisableApiCalls disableCalls = new CMN_SPC_DisableApiCalls();

		Test.startTest();

		System.runAs(adminUser)
		{
			disableCalls.run();
		}

		Test.stopTest();

		CMN_FeatureSwitches__c orgDefaultFeatureSwitch = CMN_DAL_FeatureSwitches.getFeatureSwitch(UserInfo.getOrganizationId());
		System.assertEquals(true, orgDefaultFeatureSwitch.CMN_DisableAllOutboundAPICalls__c);

	}

	/**
	 * @description Will confirm error handling is working as expected
	 */
	@IsTest
	private static void errorHandling()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		delete CMN_DAL_UsersToEnable.getAll();

		CMN_SPC_EnableUsers enableUsers = new CMN_SPC_EnableUsers();

		Test.startTest();

		enableUsers.run();

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.getAll().iterator().next();
		System.assertEquals(CMN_SPC_EnableUsers.ERROR_NO_USERS_FOUND, appLog?.CMN_Message__c, 'Incorrect Error Message');

	}
}