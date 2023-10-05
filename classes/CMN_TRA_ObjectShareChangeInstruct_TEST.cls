/**
 * @description Tests the behaviour of the Shared Object Change Instruction Trigger Action
 *
 * @see CMN_TRA_ObjectShareChangeInstruct
 *
 * @author vishakha.saini@accenture.com prashant.k.jain@accenture.com
 *
 * @date July 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_TRA_ObjectShareChangeInstruct_TEST
{
	private static final Integer NUMBER_OF_USERS = 2;

	/**
	 * @description Will create required unit test data
	 */
	@TestSetup
	private static void setup()
	{
		List<User> newUsers = CMN_DAL_DataFactory.insertUsers(CMN_DAL_Profile.PROFILE_STANDARD_USER, NUMBER_OF_USERS);
		CMN_DAL_DataFactory.createPermissionSetAssignments(newUsers, CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME);

		System.runAs(newUsers.iterator().next())
		{
			//Use this to test insert of new record
			insert CMN_DAL_DataFactory.newObjectShareConfiguration
					(
							CMN_DAL_Foobar.OBJECT_NAME,
							CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_READ,
							newUsers[0].Id,
							newUsers[1].Id
					);

			//Use this to test update of a record's owner id
			insert CMN_DAL_DataFactory.newObjectShareConfiguration
					(
							CMN_DAL_Foobar.OBJECT_NAME,
							CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_READ,
							newUsers[1].Id,
							newUsers[0].Id
					);
		}
	}

	/**
	 * @description Will confirm that records are processed correctly after they were inserted
	 *
	 * @see CMN_TRA_ObjectShareChangeInstruct.afterInsert
	 */
	@IsTest
	private static void newRecordInserted()
	{
		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		System.runAs(usersWithPermissionSet.iterator().next())
		{
			CMN_DAL_Logger.ignoreTestMode = true;

			CMN_Foobar__c foobar = CMN_DAL_DataFactory.newFoobar();

			Test.startTest();

			insert foobar;
			Test.getEventBus().deliver();

			Test.stopTest();

			Test.getEventBus().deliver(); //if an error occurred make sure we process the logging events

			CMN_AppLog__c foundLog = CMN_DAL_AppLog.findByMethod(CMN_DAL_SObjectDomain.CLASS_METHOD_UPDATE_DATABASE);
			System.assertEquals(null, foundLog, 'A DML exception was logged: ' + JSON.serialize(foundLog));

			List<CMN_Foobar__Share> foundShares = CMN_DAL_ObjectShare.findByParentIdAndRowCause(foobar.Id, CMN_DAL_ObjectShare.ROW_CAUSE_MANUAL);
			System.assertNotEquals(true, foundShares.isEmpty(), 'No shares were found.');
			System.assertEquals(usersWithPermissionSet[1].Id, foundShares.iterator().next().UserOrGroupId, 'Share record user id not set as expected');
		}
	}

	/**
	 * @description Will confirm that records are processed correctly after they were inserted
	 *
	 * @see CMN_TRA_ObjectShareChangeInstruct.afterInsert
	 */
	@IsTest
	private static void existingRecordUpdated()
	{
		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		System.runAs(usersWithPermissionSet.iterator().next())
		{
			CMN_Foobar__c foobar = CMN_DAL_DataFactory.newFoobar();
			insert foobar;
			Test.getEventBus().deliver(); //make sure event is processed

			Test.startTest();

			foobar.OwnerId = usersWithPermissionSet[1].Id;
			update foobar;

			Test.getEventBus().deliver();

			Test.stopTest();
		}

		List<CMN_Foobar__Share> foundShares =
				CMN_DAL_ObjectShare.findByParentIdAndRowCause(CMN_DAL_Foobar.getAll().iterator().next().Id, CMN_DAL_ObjectShare.ROW_CAUSE_MANUAL);
		System.assertNotEquals(true, foundShares.isEmpty(), 'No shares were found.');
		System.assertEquals(usersWithPermissionSet[0].Id, foundShares.iterator().next().UserOrGroupId, 'Share record user id not set as expected');
	}
}