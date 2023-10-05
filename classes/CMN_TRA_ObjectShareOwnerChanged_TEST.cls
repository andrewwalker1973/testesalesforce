/**
 * @description Tests the behaviour of the Object Share Owner Changed Trigger Action
 *
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date July 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_TRA_ObjectShareOwnerChanged_TEST
{
	private static final Integer NUMBER_OF_USERS = 2;

	/**
	 * @description Will create required unit test data
	 */
	@TestSetup
	private static void setup()
	{
		List<User> newUsers;
		User adminUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN);
		System.runAs(adminUser)
		{
			// Create users with Standard User profile
			newUsers = CMN_DAL_DataFactory.insertUsers(CMN_DAL_Profile.PROFILE_STANDARD_USER, NUMBER_OF_USERS);
			CMN_DAL_DataFactory.createPermissionSetAssignments(newUsers, CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME);
		}

		System.runAs(adminUser)
		{
			// newUser0 granting access to newUser1
			List<CMN_ObjectShareConfiguration__c> objectShareConfigurations = new List<CMN_ObjectShareConfiguration__c>();

			CMN_ObjectShareConfiguration__c objectShareConfiguration = CMN_DAL_DataFactory.newObjectShareConfiguration
					(
							CMN_DAL_Foobar.OBJECT_NAME,
							CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_READ,
							newUsers[0].Id,
							newUsers[1].Id
					);
			objectShareConfigurations.add(objectShareConfiguration);

			CMN_ObjectShareConfiguration__c invalidObjectShareConfiguration = CMN_DAL_DataFactory.newObjectShareConfiguration
					(
							CMN_DAL_SObjectDomain.generateRandomName(),
							CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_READ,
							newUsers[0].Id,
							newUsers[1].Id
					);
			objectShareConfigurations.add(invalidObjectShareConfiguration);

			insert objectShareConfigurations;
		}
	}

	/**
	 * @description Will confirm that records are processed correctly after they were inserted
	 *
	 * @see CMN_TRA_ObjectShareOwnerChanged.afterInsert
	 */
	@IsTest
	private static void afterInsert()
	{
		User standardUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_STANDARD_USER);
		CMN_ObjectShareConfiguration__c objectShareConfiguration = CMN_DAL_ObjectShareConfiguration.getAllFromCache().iterator().next();

		System.runAs(standardUser)
		{
			List<CMN_Foobar__c> newFoobars = newFoobars(objectShareConfiguration.CMN_ShareFrom__c, objectShareConfiguration.CMN_ShareWith__c);

			Test.startTest();

			insert newFoobars;

			assertPlatformEventPublishedCorrectly();
		}
	}

	/**
	 * @description Will confirm that records are processed correctly after they were inserted
	 *
	 * @see CMN_TRA_ObjectShareOwnerChanged.afterInsert
	 */
	@IsTest
	private static void afterUpdate()
	{
		CMN_ObjectShareConfiguration__c objectShareConfiguration = CMN_DAL_ObjectShareConfiguration.getAllFromCache().iterator().next();
		User runAsUser = new User(Id = objectShareConfiguration.CMN_ShareWith__c);

		System.runAs(runAsUser)
		{
			List<CMN_Foobar__c> newFoobars = newFoobars(objectShareConfiguration.CMN_ShareFrom__c, objectShareConfiguration.CMN_ShareWith__c);

			insert newFoobars;

			Test.startTest();

			CMN_Foobar__c newFoobar = newFoobars[1];

			newFoobar.OwnerId = objectShareConfiguration.CMN_ShareFrom__c;
			update newFoobar;

			assertPlatformEventPublishedCorrectly();
		}
	}

	/**
	 * @description Method to create 2 new Foobar records with specified owners
	 *
	 * @param ownerId1 Owner Id for 1st Foobar records
	 * @param ownerId2 Owner Id for 2nd Foobar records
	 *
	 * @return List of newly created Foobar records, not committed
	 */
	private static List<CMN_Foobar__c> newFoobars(Id ownerId1, Id ownerId2)
	{
		List<CMN_Foobar__c> newFoobars = new List<CMN_Foobar__c>();
		CMN_Foobar__c newFoobar1 = CMN_DAL_DataFactory.newFoobar();
		newFoobar1.OwnerId = ownerId1;
		newFoobars.add(newFoobar1);

		CMN_Foobar__c newFoobar2 = CMN_DAL_DataFactory.newFoobar();
		newFoobar2.OwnerId = ownerId2;
		newFoobars.add(newFoobar2);
		return newFoobars;
	}

	/**
	 * @description This will check the number of platform events published and the operation on the platform event
	 */
	private static void assertPlatformEventPublishedCorrectly()
	{
		//2 DML statements expected. 1 for explicit DML on Foobar object in the test method and 1 for platform event publish.
		System.assertEquals(2, Limits.getDmlStatements(), 'Incorrect number of DML statements executed');

		Test.stopTest();

		List<CMN_ObjectShareChangeInstruction__e> instructions = CMN_TRA_ObjectShareOwnerChanged.instructions;
		System.assertEquals(1, instructions.size(), 'Platform event records not created as expected');

		for(CMN_ObjectShareChangeInstruction__e instruction : instructions)
		{
			System.assertNotEquals(null, instruction.CMN_AccessLevel__c, 'Access Level not set correctly on the platform event');
			System.assertNotEquals(null, instruction.CMN_ObjectId__c, 'Object Id not set correctly on the platform event');
			System.assertNotEquals(null, instruction.CMN_ShareWith__c, 'Share With not set correctly on the platform event');
		}
	}

	/**
	 * @description Will confirm that Object Share Configuration records are returned when user doesn't have permission to Object Share Configuration
	 *
	 * @see CMN_DAL_ObjectShareConfiguration.getAllFromCache
	 */
	@IsTest
	private static void getAllFromCache()
	{
		List<User> newUsers;

		System.runAs(CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN))
		{
			// Advisers without object share permission set
			newUsers = CMN_DAL_DataFactory.insertUsers(CMN_DAL_Profile.PROFILE_STANDARD_USER, NUMBER_OF_USERS);

			// advisers0 granting access to advisers1
			CMN_ObjectShareConfiguration__c objectShareConfiguration = CMN_DAL_DataFactory.newObjectShareConfiguration
					(
							CMN_DAL_Foobar.OBJECT_NAME,
							CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_READ,
							newUsers[0].Id,
							newUsers[1].Id
					);
			insert objectShareConfiguration;
		}

		System.runAs(newUsers[0])
		{
			Test.startTest();

			List<CMN_ObjectShareConfiguration__c> objectShareConfiguration = CMN_DAL_ObjectShareConfiguration.getAllFromCache();

			Test.stopTest();

			System.assertEquals(false, objectShareConfiguration.isEmpty(), 'Object Share Configuration not retrieved as expected');
		}
	}
}