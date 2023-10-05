/**
 * @description Tests the behaviour of the Object Share Configuration Trigger Action
 *
 * @see CMN_TRA_ObjectShareConfiguration
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date July 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_TRA_ObjectShareConfiguration_TEST
{
	private static final Integer NUMBER_OF_USERS = 2;

	/**
	 * @description Will create required unit test data
	 */
	@TestSetup
	private static void setup()
	{
		//Make sure Sharing setting for Foobar is set to Private, otherwise tests will fail.
		EntityDefinition entityDefinition = CMN_DAL_EntityDefinition.getByQualifiedApiNames(new Set<String> {CMN_DAL_Foobar.OBJECT_NAME}).iterator().next();
		System.assertEquals
				(
						CMN_DAL_EntityDefinition.SHARING_MODEL_PRIVATE,
						entityDefinition.InternalSharingModel,
						'Sharing setting for Foobar should be set to Private'
				);

		List<User> newUsers = CMN_DAL_DataFactory.insertUsers(CMN_DAL_Profile.PROFILE_STANDARD_USER, NUMBER_OF_USERS);
		CMN_DAL_DataFactory.createPermissionSetAssignments(newUsers, CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME);
	}

	/**
	 * @description Will construct a share configurations from a list of users
	 *
	 * @param users List of users
	 *
	 * @return newly initialised share configurations, not committed
	 */
	private static CMN_ObjectShareConfiguration__c newShareConfiguration(List<User> users)
	{
		return CMN_DAL_DataFactory.newObjectShareConfiguration
				(
						CMN_DAL_Foobar.OBJECT_NAME,
						CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_READ,
						users[0].Id,
						users[1].Id
				);
	}

	/**
	 * @description Will get a list with one object each with Private, Read and ReadWrite org-wide setting
	 *
	 * @return List of object names
	 */
	private static List<String> getObjectNamesForConfiguration()
	{
		// Get all Items that are valid for Apex Sharing (excluding their org-wide setting which we cannot filter against)
		List<EntityDefinition> definitions = CMN_DAL_EntityDefinition.getAllApexShareable();
		List<String> objectNamesForConfiguration = new List<String> {CMN_DAL_Foobar.OBJECT_NAME};

		Boolean objectWithReadSettingFound = false;
		Boolean objectWithReadWriteSettingFound = false;

		// Loop through all the Entity definition records to find one object each with Read and ReadWrite org-wide setting
		for(EntityDefinition definition : definitions)
		{
			if(!objectWithReadSettingFound && CMN_DAL_EntityDefinition.SHARING_MODEL_READ.equals(definition.InternalSharingModel))
			{
				objectWithReadSettingFound = true;
				objectNamesForConfiguration.add(definition.QualifiedApiName);
			}
			else if(!objectWithReadWriteSettingFound && CMN_DAL_EntityDefinition.SHARING_MODEL_READ_WRITE.equals(definition.InternalSharingModel))
			{
				objectWithReadWriteSettingFound = true;
				objectNamesForConfiguration.add(definition.QualifiedApiName);
			}

			//Break the loop if both values have been found
			if(objectWithReadSettingFound && objectWithReadWriteSettingFound)
			{
				break;
			}
		}
		return objectNamesForConfiguration;
	}

	/**
	 * @description Will check the cache is refreshed correctly when configuration changes
	 */
	@IsTest
	private static void cacheRefresh()
	{
		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		CMN_ObjectShareConfiguration__c newConfiguration = newShareConfiguration(usersWithPermissionSet);

		insert newConfiguration;

		List<CMN_ObjectShareConfiguration__c> newConfigurations = CMN_DAL_ObjectShareConfiguration.getAllFromCache();
		System.assertEquals(false, newConfigurations.isEmpty(), 'No items in the cache');

		Test.startTest();

		newConfiguration.CMN_AccessLevel__c = CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_EDIT;
		update newConfiguration;

		Test.stopTest();

		newConfigurations = CMN_DAL_ObjectShareConfiguration.getAllFromCache();
		System.assertEquals(newConfiguration.CMN_AccessLevel__c, newConfigurations.iterator().next().CMN_AccessLevel__c, 'Cache not updated correctly');

		delete newConfiguration;
		newConfigurations = CMN_DAL_ObjectShareConfiguration.getAllFromCache();
		System.assertEquals(true, newConfigurations.isEmpty(), 'Cache not updated correctly');
	}

	/**
	 * @description Will confirm that records are processed correctly after they were inserted
	 *
	 * @see CMN_TRA_ObjectShareConfiguration.afterInsert
	 */
	@IsTest
	private static void afterInsert()
	{
		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		System.runAs(usersWithPermissionSet.iterator().next())
		{
			List<CMN_ObjectShareConfiguration__c> shareConfigurations = new List<CMN_ObjectShareConfiguration__c>();

			for(String objectName : getObjectNamesForConfiguration())
			{
				CMN_ObjectShareConfiguration__c shareConfiguration = CMN_DAL_DataFactory.newObjectShareConfiguration
						(
								objectName,
								CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_READ,
								usersWithPermissionSet.get(0).Id,
								usersWithPermissionSet.get(1).Id
						);
				shareConfigurations.add(shareConfiguration);
			}

			Test.startTest();

			insert shareConfigurations;

			assertPlatformEventPublishedCorrectly(CMN_DAL_ObjectShareInstruction.OPERATION_INSERT);
		}
	}

	/**
	 * @description Will confirm that records are processed correctly after they were updated
	 *
	 * @see CMN_TRA_ObjectShareConfiguration.afterUpdate
	 */
	@IsTest
	private static void afterUpdate()
	{
		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		System.runAs(usersWithPermissionSet.iterator().next())
		{
			CMN_ObjectShareConfiguration__c shareConfiguration = newShareConfiguration(usersWithPermissionSet);

			insert shareConfiguration;

			shareConfiguration.CMN_AccessLevel__c = CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_EDIT;

			Test.startTest();

			update shareConfiguration;

			assertPlatformEventPublishedCorrectly(CMN_DAL_ObjectShareInstruction.OPERATION_UPDATE);
		}
	}

	/**
	 * @description Will confirm that records are processed correctly after they were deleted
	 *
	 * @see CMN_TRA_ObjectShareConfiguration.afterDelete
	 */
	@IsTest
	private static void afterDelete()
	{
		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		System.runAs(usersWithPermissionSet.iterator().next())
		{
			CMN_ObjectShareConfiguration__c shareConfiguration = newShareConfiguration(usersWithPermissionSet);

			insert shareConfiguration;

			Test.startTest();

			delete shareConfiguration;

			assertPlatformEventPublishedCorrectly(CMN_DAL_ObjectShareInstruction.OPERATION_DELETE);
		}
	}

	/**
	 * @description Will confirm that records are processed asynchronously via a batch
	 *
	 * @see CMN_TRA_ObjectShareEventPublisher.AsynchronousEventPublisher.execute
	 */
	@IsTest
	private static void checkEventIsPublishedAsynchronously()
	{
		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		System.runAs(usersWithPermissionSet.iterator().next())
		{
			//Ensure that events are published asynchronously
			CMN_TRA_ObjectShareEventPublisher.simulateDMLimitsBreach = true;

			CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
			insert newFoobar;

			Test.startTest();

			CMN_ObjectShareConfiguration__c shareConfiguration = newShareConfiguration(usersWithPermissionSet);
			insert shareConfiguration;

			System.assertEquals(1, Limits.getQueueableJobs(), 'No jobs was enqueued');

			Test.stopTest();

			System.assertNotEquals(true, CMN_TRA_ObjectShareConfiguration.instructions.isEmpty(), 'No events published.');

			List<SObject> foundShares = CMN_DAL_ObjectShare.findByParentIdAndRowCause(newFoobar.Id, CMN_DAL_ObjectShare.ROW_CAUSE_MANUAL);
			System.assertEquals(1, foundShares.size(), 'Foobar share records not created as expected');
			System.assertEquals
					(
							usersWithPermissionSet.get(1).Id,
							foundShares.iterator().next().get(CMN_DAL_ObjectShare.FIELD_USER_OR_GROUP_ID),
							'Foobar not shared with the correct user'
					);
		}
	}

	/**
	 * @description Creates an scenario where publishing sharing events asynchronously can't happen as we are at both DML and Queueable job limits
	 *
	 * @see CMN_TRA_ObjectShareEventPublisher.AsynchronousEventPublisher.execute
	 */
	@IsTest
	private static void unableToPublishDueToLimits()
	{
		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		System.runAs(usersWithPermissionSet.iterator().next())
		{
			CMN_TRA_ObjectShareEventPublisher.simulateDMLimitsBreach = true;
			CMN_TRA_ObjectShareEventPublisher.simulateQueueableLimitsBreach = true;

			CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
			insert newFoobar;

			Test.startTest();

			CMN_ObjectShareConfiguration__c shareConfiguration = newShareConfiguration(usersWithPermissionSet);
			insert shareConfiguration;

			System.assertEquals(0, Limits.getQueueableJobs(), 'No jobs should be enqueued');

			//Only 1 DML statement expected for the insert of share configuration. No event should be published.
			System.assertEquals(1, Limits.getDmlStatements(), 'Incorrect number of DML statements executed');

			Test.stopTest();
		}
	}

	/**
	 * @description Will confirm that records are processed correctly after they were undeleted
	 *
	 * @see CMN_TRA_ObjectShareConfiguration.afterUndelete
	 */
	@IsTest
	private static void afterUndelete()
	{
		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		System.runAs(usersWithPermissionSet.iterator().next())
		{
			CMN_ObjectShareConfiguration__c shareConfiguration = newShareConfiguration(usersWithPermissionSet);

			insert shareConfiguration;
			delete shareConfiguration;

			Test.startTest();

			undelete shareConfiguration;

			assertPlatformEventPublishedCorrectly(CMN_DAL_ObjectShareInstruction.OPERATION_INSERT);
		}
	}

	/**
	 * @description This will check the number of platform events published and the operation on the platform event
	 *
	 * @param operation Operation which will be set on the platform event
	 */
	private static void assertPlatformEventPublishedCorrectly(String operation)
	{
		//2 DML statements expected. 1 for explicit DML on share configuration in the test method and 1 for platform event publish.
		System.assertEquals(2, Limits.getDmlStatements(), 'Incorrect number of DML statements executed');

		Test.stopTest();

		List<CMN_ObjectShareInstruction__e> instructions = CMN_TRA_ObjectShareConfiguration.instructions;
		System.assertEquals(1, instructions.size(), 'Platform event records not created as expected');

		for(CMN_ObjectShareInstruction__e instruction : instructions)
		{
			System.assertEquals(operation, instruction.CMN_Operation__c, 'Operation not set correctly on the platform event');
		}
	}

	/**
	 * @description Will test the validation rule CMN_PreventSameShareFromShareWith - shareFrom and shareWith user should not be same
	 *
	 * @see CMN_ObjectShareConfiguration__c
	 */
	@IsTest
	private static void preventSameShareFromShareWithValidation()
	{
		try
		{
			Test.startTest();

			insert CMN_DAL_DataFactory.newObjectShareConfiguration
					(
							CMN_DAL_Foobar.OBJECT_NAME,
							CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_READ,
							UserInfo.getUserId(),
							UserInfo.getUserId()
					);

			Test.stopTest();

			System.assert(false, 'Exception not thrown as expected');
		}
		catch(Exception error)
		{
			CMN_DAL_SObjectDomain.assertIsCorrectDmlError(error, StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
		}
	}

	/**
	 * @description Will test the validation rule CMN_PreventChangesToFields - Object API Name, Share From and Share With fields cannot be modified after the
	 * record is created
	 *
	 * @see CMN_ObjectShareConfiguration__c
	 */
	@IsTest
	private static void preventChangesToFieldsValidation()
	{
		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		CMN_ObjectShareConfiguration__c shareConfiguration = newShareConfiguration(usersWithPermissionSet);

		insert shareConfiguration;

		shareConfiguration.CMN_ObjectAPIName__c = CMN_DAL_Account.OBJECT_NAME;

		try
		{
			Test.startTest();

			update shareConfiguration;

			Test.stopTest();

			System.assert(false, 'Exception not thrown as expected');
		}
		catch(Exception error)
		{
			CMN_DAL_SObjectDomain.assertIsCorrectDmlError(error, StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
		}
	}

	/**
	 * @description Will test the validation rule CMN_ShareWithMustBeActive - Records can only be shared with Active Users
	 *
	 * @see CMN_ObjectShareConfiguration__c
	 */
	@IsTest
	private static void shareWithMustBeActiveValidation()
	{
		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		usersWithPermissionSet[1].IsActive = false;
		update usersWithPermissionSet[1];

		System.runAs(usersWithPermissionSet[0])
		{
			CMN_ObjectShareConfiguration__c shareConfiguration = newShareConfiguration(usersWithPermissionSet);

			try
			{
				Test.startTest();

				insert shareConfiguration;

				Test.stopTest();

				System.assert(false, 'Exception not thrown as expected');
			}
			catch(Exception error)
			{
				CMN_DAL_SObjectDomain.assertIsCorrectDmlError(error, StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
			}
		}
	}

	/**
	 * @description Checks to see that system processes creating Contact Share records (in an Org with person accounts) correctly
	 *
	 * @see CMN_TRA_ObjectShareEventPublisher.extractValidConfigurations
	 */
	@IsTest
	private static void shareConfigurationForContact()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		System.runAs(usersWithPermissionSet.iterator().next())
		{
			Contact newContact = CMN_DAL_DataFactory.newContact();
			insert newContact;

			CMN_ObjectShareConfiguration__c shareConfiguration = CMN_DAL_DataFactory.newObjectShareConfiguration
					(
							CMN_DAL_Contact.OBJECT_NAME,
							CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_EDIT,
							usersWithPermissionSet.get(0).Id,
							usersWithPermissionSet.get(1).Id
					);

			Test.startTest();

			insert shareConfiguration;

			Test.stopTest();

			Boolean isPersonAccountEnabled = CMN_UTIL_SObjectDescribe.isPersonAccountEnabled();

			List<SObject> foundShares = CMN_DAL_ObjectShare.findByParentIdAndRowCause(newContact.Id, CMN_DAL_ObjectShare.ROW_CAUSE_MANUAL);
			EntityDefinition entityDefinition = CMN_DAL_EntityDefinition.getByQualifiedApiNames(new Set<String> {CMN_DAL_Contact.OBJECT_NAME}).iterator().next();

			// App log for Invalid Configuration is expected if Person Account is enabled
			// OR if the Contact sharing setting is not set to Private or Read.
			// Otherwise a Share record should be created.
			Boolean isAppLogExpected = isPersonAccountEnabled
					|| (entityDefinition.InternalSharingModel != CMN_DAL_EntityDefinition.SHARING_MODEL_PRIVATE
					&& entityDefinition.InternalSharingModel != CMN_DAL_EntityDefinition.SHARING_MODEL_READ);
			System.assertEquals(isAppLogExpected, foundShares.isEmpty(), 'Contact Shares not processed correctly');

			if(isAppLogExpected)
			{
				CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CMN_TRA_ObjectShareEventPublisher.CLASS_METHOD);
				System.assertNotEquals(null, appLog, 'App Log record not found as expected');
				System.assertEquals(CMN_DAL_Logger.LEVEL_WARN, appLog.CMN_LogLevel__c, 'Incorrect Log Level found');
				System.assertEquals
						(
								String.format(CMN_TRA_ObjectShareEventPublisher.INVALID_CONFIGURATION_ERROR_FORMAT, new List<String> {shareConfiguration.Id}),
								appLog.CMN_Message__c,
								'Incorrect Message found'
						);
			}
		}
	}
}