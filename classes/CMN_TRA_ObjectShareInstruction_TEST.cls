/**
 * @description Tests the behaviour of the Object Share Instruction Trigger Action
 *
 * @see CMN_TRA_ObjectShareInstruction
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date September 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_TRA_ObjectShareInstruction_TEST
{
	private static final Integer NUMBER_OF_USERS = 3;

	/**
	 * @description Will create required unit test data
	 */
	@TestSetup
	private static void setup()
	{
		List<User> newUsers;
		System.runAs(CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN))
		{
			newUsers = CMN_DAL_DataFactory.insertUsers(CMN_DAL_Profile.PROFILE_STANDARD_USER, NUMBER_OF_USERS);
			CMN_DAL_DataFactory.createPermissionSetAssignments(newUsers, CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME);
		}

		System.runAs(newUsers.iterator().next())
		{
			//Need to cater for account's special share object
			CMN_DAL_DataFactory.insertBusinessAccount();
		}
	}

	/**
	 * @description Will construct a share configurations from a list of users
	 *
	 * @param users List of users
	 *
	 * @return newly initialised share configurations, not committed
	 */
	private static List<CMN_ObjectShareConfiguration__c> newShareConfigurations(List<User> users)
	{
		return new List<CMN_ObjectShareConfiguration__c>
		{
				CMN_DAL_DataFactory.newObjectShareConfiguration
						(
								CMN_DAL_Foobar.OBJECT_NAME,
								CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_READ,
								users[0].Id,
								users[1].Id
						),
				CMN_DAL_DataFactory.newObjectShareConfiguration
						(
								CMN_DAL_Foobar.OBJECT_NAME,
								CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_READ,
								users[0].Id,
								users[2].Id
						),
				//This configuration row is to check that we don't react to this when trying to create shares.
				CMN_DAL_DataFactory.newObjectShareConfiguration
						(
								CMN_DAL_Foobar.OBJECT_NAME,
								CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_READ,
								users[1].Id,
								users[2].Id
						),
				//This configuration is to ensure that we do create shares across objects (i.e we run two queries)
				CMN_DAL_DataFactory.newObjectShareConfiguration
						(
								CMN_DAL_Account.OBJECT_NAME,
								CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_READ,
								users[0].Id,
								users[1].Id
						)
		};
	}

	/**
	 * @description Will confirm shares are synchronously inserted
	 *
	 * @see CMN_TRA_ObjectShareInstruction.afterInsert
	 * @see CMN_TRA_ObjectShareInstruction.performDMLOperation
	 */
	@IsTest
	private static void insertShares()
	{
		assertInserts(false, false, false);
	}

	/**
	 * @description Will confirm shares are asynchronously inserted
	 *
	 * @see CMN_TRA_ObjectShareInstruction.afterInsert
	 * @see CMN_TRA_ObjectShareInstruction.performDMLOperation
	 */
	@IsTest
	private static void insertViaBatch()
	{
		assertInserts(true, false, false);
	}

	/**
	 * @description Will confirm shares instructions are asynchronously processed by batch
	 *
	 * @see CMN_TRA_ObjectShareInstruction.afterInsert
	 * @see CMN_TRA_ObjectShareInstruction.canRetrieveObjects
	 */
	@IsTest
	private static void insertProcessingViaBatch()
	{
		assertInserts(false, true, false);
	}

	/**
	 * @description Will confirm shares instructions are asynchronously processed by batch if not enough heap memory is available
	 *
	 * @see CMN_TRA_ObjectShareInstruction.afterInsert
	 * @see CMN_TRA_ObjectShareInstruction.hasEnoughMemory
	 */
	@IsTest
	private static void insertSimulateNotEnoughHeapMemory()
	{
		assertInserts(false, false, true);
	}

	/**
	 * @description Checks that Apex shares are correctly created for the relevant configuration rows
	 *
	 * @param commitViaBatch Set to true to perform DML operations via batch
	 * @param processViaBatch Set to true to process share operations via batch
	 * @param simulateNotEnoughHeapMemory Set this value to true to simulate that we don't have enough heap memory to process the request
	 *
	 * @see CMN_TRA_ObjectShareInstruction.afterInsert
	 */
	private static void assertInserts(Boolean commitViaBatch, Boolean processViaBatch, Boolean simulateNotEnoughHeapMemory)
	{
		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		System.runAs(usersWithPermissionSet.iterator().next())
		{
			//Creating record in the current user's context
			CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
			insert newFoobar;

			Test.startTest();

			CMN_TRA_ObjectShareInstruction.commitViaBatch = commitViaBatch;
			CMN_TRA_ObjectShareInstruction.processViaBatch = processViaBatch;
			CMN_TRA_ObjectShareInstruction.simulateNotEnoughHeapMemory = simulateNotEnoughHeapMemory;

			insert newShareConfigurations(usersWithPermissionSet);

			// We need to deliver the events in case of batch
			if(commitViaBatch || processViaBatch || simulateNotEnoughHeapMemory)
			{
				Test.getEventBus().deliver();
			}

			Test.stopTest();

			assertSharesAltered(newFoobar.Id, false);

			List<CMN_Foobar__Share> shares = CMN_DAL_ObjectShare.findByParentIdAndRowCause(newFoobar.Id, CMN_DAL_ObjectShare.ROW_CAUSE_MANUAL);

			System.assertEquals(2, shares.size(), 'Incorrect number of shares found');

			Set<Id> shareWithUserIdSet = new Set<Id> {usersWithPermissionSet[1].Id, usersWithPermissionSet[2].Id};
			for(CMN_Foobar__Share share : shares)
			{
				System.assertEquals(true, shareWithUserIdSet.contains(share.UserOrGroupId), 'Share record user id not set as expected');
				System.assertEquals(CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_READ, share.AccessLevel, 'Access Level not set as expected');
			}
		}
	}

	/**
	 * @description Checks that Apex shares are correctly modified
	 *
	 * @see CMN_TRA_ObjectShareInstruction.afterInsert
	 */
	@IsTest
	private static void modifyShares()
	{
		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		System.runAs(usersWithPermissionSet.iterator().next())
		{
			//Creating record in the current user's context
			CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
			insert newFoobar;

			List<CMN_ObjectShareConfiguration__c> newConfigurations = newShareConfigurations(usersWithPermissionSet);
			insert newConfigurations;

			for(CMN_ObjectShareConfiguration__c newConfiguration : newConfigurations)
			{
				newConfiguration.CMN_AccessLevel__c = CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_EDIT;
			}

			Test.startTest();

			update newConfigurations;

			Test.stopTest();

			List<CMN_Foobar__Share> shares = CMN_DAL_ObjectShare.findByParentIdAndRowCause(newFoobar.Id, CMN_DAL_ObjectShare.ROW_CAUSE_MANUAL);

			System.assertEquals(2, shares.size(), 'Incorrect number of shares found');
			for(CMN_Foobar__Share share : shares)
			{
				System.assertEquals(CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_EDIT, share.AccessLevel, 'Access Level not updated as expected');
			}
		}
	}

	/**
	 * @description Will confirm shares are synchronously deleted
	 *
	 * @see CMN_TRA_ObjectShareInstruction.afterInsert
	 * @see CMN_TRA_ObjectShareInstruction.performDMLOperation
	 */
	@IsTest
	private static void deleteShares()
	{
		assertDeleteShares(false, false, false);
	}

	/**
	 * @description Will confirm shares are asynchronously deleted
	 *
	 * @see CMN_TRA_ObjectShareInstruction.afterInsert
	 * @see CMN_TRA_ObjectShareInstruction.performDMLOperation
	 */
	@IsTest
	private static void deleteSharesViaBatch()
	{
		assertDeleteShares(true, false, false);
	}

	/**
	 * @description Will confirm shares instructions are asynchronously processed by batch
	 *
	 * @see CMN_TRA_ObjectShareInstruction.afterInsert
	 * @see CMN_TRA_ObjectShareInstruction.canRetrieveObjects
	 */
	@IsTest
	private static void deleteProcessingViaBatch()
	{
		assertDeleteShares(false, true, false);
	}

	/**
	 * @description Will confirm shares instructions are asynchronously processed by batch
	 *
	 * @see CMN_TRA_ObjectShareInstruction.afterInsert
	 * @see CMN_TRA_ObjectShareInstruction.canExecuteCountQuery
	 */
	@IsTest
	private static void deleteShareQueryViaBatch()
	{
		assertDeleteShares(false, false, true);
	}

	/**
	 * @description Checks that Apex shares are correctly removed for the relevant configuration rows
	 *
	 * @param commitViaBatch Set to true to perform DML operations via batch
	 * @param processViaBatch Set to process share operations via batch
	 * @param processDeleteViaBatch Set to process delete share query operations via batch
	 *
	 * @see CMN_TRA_ObjectShareInstruction.afterInsert
	 */
	private static void assertDeleteShares(Boolean commitViaBatch, Boolean processViaBatch, Boolean processDeleteViaBatch)
	{
		List<User> usersWithPermissionSet = CMN_DAL_PermissionSetAssignment.findAllocatedUsersByPermissionSetAndProfileName
				(CMN_DAL_PermissionSet.OBJECT_SHARE_PERMISSION_SET_API_NAME, CMN_DAL_Profile.PROFILE_STANDARD_USER);

		System.runAs(usersWithPermissionSet.iterator().next())
		{
			//Creating record in the current user's context
			CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
			insert newFoobar;

			List<CMN_ObjectShareConfiguration__c> newConfigurations = newShareConfigurations(usersWithPermissionSet);
			insert newConfigurations;

			Test.getEventBus().deliver();

			CMN_TRA_ObjectShareInstruction.commitViaBatch = commitViaBatch;
			CMN_TRA_ObjectShareInstruction.processViaBatch = processViaBatch;
			CMN_TRA_ObjectShareInstruction.processDeleteViaBatch = processDeleteViaBatch;

			Test.startTest();

			delete newConfigurations;

			// We need to deliver the events in case of batch
			if(commitViaBatch || processViaBatch || processDeleteViaBatch)
			{
				Test.getEventBus().deliver();
			}

			Test.stopTest();

			assertSharesAltered(newFoobar.Id, true);
		}
	}

	/**
	 * @description Will check that shares are inserted or deleted as expected
	 *
	 * @param parentId Id of the Parent record for querying shares
	 * @param sharesDeleted Alters the assert based on expectation of delete or insert
	 */
	private static void assertSharesAltered(Id parentId, Boolean sharesDeleted)
	{
		String errorMessage = sharesDeleted ? 'Share records not deleted as expected' : 'Share records not inserted as expected';
		List<SObject> shares = CMN_DAL_ObjectShare.findByParentIdAndRowCause(parentId, CMN_DAL_ObjectShare.ROW_CAUSE_MANUAL);
		System.assertEquals(sharesDeleted, shares.isEmpty(), errorMessage);
	}
}