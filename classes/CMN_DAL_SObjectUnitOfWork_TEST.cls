/**
 * @description Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 * <p/>
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 * <p/>
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *   may be used to endorse or promote products derived from this software without
 *   specific prior written permission.
 * <p/>
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @see CMN_DAL_SObjectUnitOfWork
 *
 * @author FinancialForce.com, jason.van.beukering@accenture.com
 *
 * @date December 2022, March 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_DAL_SObjectUnitOfWork_TEST
{
	private static final List<SObjectType> TEST_OBJECT_TYPES = new List<SObjectType> {Account.SObjectType, Contact.SObjectType, CMN_Foobar__c.SObjectType};
	private static final String EVENT_COMMIT_FINISHED = 'onCommitWorkFinished';
	private static final String EVENT_COMMIT_FINISHING = 'onCommitWorkFinishing';
	private static final String EVENT_COMMIT_STARTING = 'onCommitWorkStarting';
	private static final String EVENT_DML_FINISHED = 'onDMLFinished';
	private static final String EVENT_DML_STARTING = 'onDMLStarting';
	private static final String EXCEPTION_WAS_THROWN_AS_EXPECTED = 'Exception was thrown as expected.';

	/**
	 * @description Check that the correct events fire when a DML error is thrown on commit
	 */
	@IsTest
	private static void commitWithDMLFailing()
	{
		// Insert Account with UnitOfWork forcing a failure on DML by not setting 'Name' field
		CMN_TEST_UnitOfWork unitOfWork = new CMN_TEST_UnitOfWork();
		unitOfWork.addSObjectTypes(TEST_OBJECT_TYPES);

		//Create an Account without a Name, will result in a DML occurring
		Account newAccount = new Account();

		unitOfWork.registerNew(new List<SObject> {newAccount});
		try
		{
			Test.startTest();

			unitOfWork.commitWork();

			Test.stopTest();

			Assert.fail('DML Operation did not fail as expected');
		}
		catch(System.DmlException dmlError)
		{
			//Check if DML Operation failed for the correct reason
			Assert.isTrue(dmlError.getMessage().contains('REQUIRED_FIELD_MISSING'), 'Unexpected Exception was thrown.');
		}

		assertEvents
				(
						new List<String> {EVENT_COMMIT_STARTING, EVENT_DML_STARTING, EVENT_COMMIT_FINISHED + ' - false'},
						unitOfWork.getCommitWorkEventsFired(), new Set<SObjectType>(TEST_OBJECT_TYPES), unitOfWork.getRegisteredTypes()
				);
	}

	/**
	 * @description Check that commit happens successfully and all relevant events are fired.
	 */
	@IsTest
	private static void registerNew()
	{
		CMN_TEST_UnitOfWork unitOfWork = new CMN_TEST_UnitOfWork(TEST_OBJECT_TYPES);

		Account newAccount1 = CMN_DAL_DataFactory.insertBusinessAccount();

		newAccount1.Name = CMN_DAL_SObjectDomain.generateRandomName();
		unitOfWork.registerDirty(new List<SObject> {newAccount1});

		Account newAccount2 = CMN_DAL_DataFactory.newBusinessAccount();
		Contact newContact1 = CMN_DAL_DataFactory.newContact();
		Contact newContact2 = CMN_DAL_DataFactory.newContact();

		unitOfWork.registerNew(new List<SObject> {newAccount2});

		checkRegisterEventsFired(unitOfWork, newContact1, newContact2, newAccount2);
	}

	/**
	 * @description Check that commit happens successfully and all relevant events are fired when using registerChanged
	 */
	@IsTest
	private static void registerChanged()
	{
		CMN_TEST_UnitOfWork unitOfWork = new CMN_TEST_UnitOfWork(TEST_OBJECT_TYPES);

		Account newAccount1 = CMN_DAL_DataFactory.insertBusinessAccount();

		newAccount1.Name = CMN_DAL_SObjectDomain.generateRandomName();
		unitOfWork.registerChange(newAccount1);

		Account newAccount2 = CMN_DAL_DataFactory.newBusinessAccount();
		Contact newContact1 = CMN_DAL_DataFactory.newContact();
		Contact newContact2 = CMN_DAL_DataFactory.newContact();

		unitOfWork.registerChange(newAccount2);

		checkRegisterEventsFired(unitOfWork, newContact1, newContact2, newAccount2);
	}

	/**
	 * @description Will run common code to register relationships and see that relevant events fired
	 *
	 * @param unitOfWork Unit of Work that will managing transaction
	 * @param newContact1 Test Contact
	 * @param newContact2 Test Contact
	 * @param newAccount2 Test Account
	 */
	private static void checkRegisterEventsFired(CMN_TEST_UnitOfWork unitOfWork, Contact newContact1, Contact newContact2, Account newAccount2)
	{
		unitOfWork.registerNew(newContact1, Contact.AccountId, newAccount2);
		unitOfWork.registerNew(newContact2, Contact.AccountId, newAccount2);

		Test.startTest();

		unitOfWork.commitWork();

		Test.stopTest();

		Assert.isNotNull(newContact1.AccountId, 'Contact was not linked correct');

		assertEvents
				(
						new List<String>
						{
								EVENT_COMMIT_STARTING, EVENT_DML_STARTING, EVENT_DML_FINISHED, EVENT_COMMIT_FINISHING, EVENT_COMMIT_FINISHED + ' - true'
						},
						unitOfWork.getCommitWorkEventsFired(), new Set<SObjectType>(TEST_OBJECT_TYPES), unitOfWork.getRegisteredTypes()
				);
	}

	/**
	 * @description Test clearing changes in a UOW so new updates can be loaded
	 */
	@IsTest
	private static void clear()
	{
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(TEST_OBJECT_TYPES);

		Account newAccount1 = CMN_DAL_DataFactory.insertBusinessAccount();

		newAccount1.Name = CMN_DAL_SObjectDomain.generateRandomName();
		unitOfWork.registerChange(newAccount1);

		Account newAccount2 = CMN_DAL_DataFactory.newBusinessAccount();
		Contact newContact1 = CMN_DAL_DataFactory.newContact();
		Contact newContact2 = CMN_DAL_DataFactory.newContact();

		unitOfWork.registerChange(newAccount2);

		unitOfWork.registerNew(newContact1, Contact.AccountId, newAccount2);
		unitOfWork.registerNew(newContact2, Contact.AccountId, newAccount2);

		unitOfWork.commitWork();

		try
		{
			Test.startTest();

			unitOfWork.clear();
			unitOfWork.commitWork();

			Assert.isTrue(true, 'UOW cleared properly');

			Test.stopTest();
		}
		catch(Exception error)
		{
			Assert.fail('Exception was thrown because unit of work not cleared properly');
		}

	}

	/**
	 * @description Check to see exception is thrown if we try and  register new for a existing record
	 */
	@IsTest
	private static void registerNewFailForExisting()
	{
		CMN_TEST_UnitOfWork unitOfWork = new CMN_TEST_UnitOfWork(TEST_OBJECT_TYPES);

		Test.startTest();

		try
		{
			unitOfWork.registerNew(CMN_DAL_DataFactory.insertBusinessAccount());
			Assert.fail('Exception was not thrown for registering a new Object when the Object has an Id');
		}
		catch(Exception error)
		{
			Assert.isTrue(true, EXCEPTION_WAS_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}

	/**
	 * @description Confirm that exception is thrown when registering a New Object that isn't registered
	 */
	@IsTest
	private static void registerNewForUnregisteredType()
	{
		CMN_TEST_UnitOfWork unitOfWork = new CMN_TEST_UnitOfWork();

		Test.startTest();

		try
		{
			unitOfWork.registerNew(CMN_DAL_DataFactory.newBusinessAccount());
			Assert.fail('Exception was not thrown for registering new Object when the type is not supported');
		}
		catch(Exception error)
		{
			Assert.isTrue(true, EXCEPTION_WAS_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}

	/**
	 * @description Confirm that UOW processes delete correctly
	 */
	@IsTest
	private static void registerDelete()
	{
		CMN_TEST_UnitOfWork unitOfWork = new CMN_TEST_UnitOfWork(TEST_OBJECT_TYPES);

		Account newAccount1 = CMN_DAL_DataFactory.insertBusinessAccount();

		Test.startTest();

		unitOfWork.registerDeleted(new List<SObject> {newAccount1});

		Test.stopTest();

		unitOfWork.commitWork();

		newAccount1 = CMN_DAL_Account.findById(newAccount1.Id);

		Assert.isNull(newAccount1, 'Account was not deleted as expected.');
	}

	/**
	 * @description Confirm that exception is thrown when attempting to delete an  Object without an Id
	 */
	@IsTest
	private static void registerDeleteForNew()
	{
		CMN_TEST_UnitOfWork unitOfWork = new CMN_TEST_UnitOfWork(TEST_OBJECT_TYPES);

		Test.startTest();

		try
		{
			unitOfWork.registerDeleted(CMN_DAL_DataFactory.newBusinessAccount());
			Assert.fail('Exception was not thrown for deleting a new Object');
		}
		catch(Exception error)
		{
			Assert.isTrue(true, EXCEPTION_WAS_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}

	/**
	 * @description Confirm that exception is thrown when attempting to delete an ObjectType that hasn't been registered
	 */
	@IsTest
	private static void registerDeleteForUnregisteredType()
	{
		CMN_TEST_UnitOfWork unitOfWork = new CMN_TEST_UnitOfWork();

		Test.startTest();

		try
		{
			unitOfWork.registerDeleted(CMN_DAL_DataFactory.insertBusinessAccount());
			Assert.fail('Exception was not thrown for deleting an Object when the type is not supported');
		}
		catch(Exception error)
		{
			Assert.isTrue(true, EXCEPTION_WAS_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}

	/**
	 * @description Confirm that exception is thrown when attempting to edit an Object without an Id
	 */
	@IsTest
	private static void registerEditForNew()
	{
		CMN_TEST_UnitOfWork unitOfWork = new CMN_TEST_UnitOfWork(TEST_OBJECT_TYPES);

		Test.startTest();
		try
		{
			unitOfWork.registerDirty(CMN_DAL_DataFactory.newBusinessAccount());
			Assert.fail('Exception was not thrown for editing a new Object');
		}
		catch(Exception error)
		{
			Assert.isTrue(true, EXCEPTION_WAS_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}

	/**
	 * @description Confirm that exception is thrown when attempting to edit an ObjectType that hasn't been registered
	 */
	@IsTest
	private static void registerEditForUnregisteredType()
	{
		CMN_TEST_UnitOfWork unitOfWork = new CMN_TEST_UnitOfWork();

		Test.startTest();
		try
		{
			unitOfWork.registerDirty(CMN_DAL_DataFactory.insertBusinessAccount());
			Assert.fail('Exception was not thrown for editing an Object when the type is not supported');
		}
		catch(Exception error)
		{
			Assert.isTrue(true, EXCEPTION_WAS_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}

	/**
	 * @description Check that we can update relationship between two objects
	 */
	@IsTest
	private static void registerDirtyRelationship()
	{
		CMN_TEST_UnitOfWork unitOfWork = new CMN_TEST_UnitOfWork(TEST_OBJECT_TYPES);

		Account newAccount1 = CMN_DAL_DataFactory.insertBusinessAccount();
		Account newAccount2 = CMN_DAL_DataFactory.insertBusinessAccount();

		Contact newContact = CMN_DAL_DataFactory.newContact();
		newContact.AccountId = newAccount1.Id;

		insert newContact;

		unitOfWork.registerDirty(newContact, Contact.AccountId, newAccount2);

		Test.startTest();

		unitOfWork.commitWork();

		Test.stopTest();

		newContact = (Contact)CMN_DAL_Search.getAll(Contact.SObjectType).iterator().next();
		Assert.areEqual(newAccount2.Id, newContact.AccountId, 'Relationship was not updated');
	}

	/**
	 * @description Confirm that exception is thrown when attempting to edit a Relationship for an ObjectType that hasn't been registered
	 */
	@IsTest
	private static void registerEditRelationshipForUnregisteredType()
	{
		CMN_TEST_UnitOfWork unitOfWork = new CMN_TEST_UnitOfWork();

		Account newAccount1 = CMN_DAL_DataFactory.insertBusinessAccount();
		Account newAccount2 = CMN_DAL_DataFactory.insertBusinessAccount();

		Contact newContact = CMN_DAL_DataFactory.newContact();
		newContact.AccountId = newAccount1.Id;

		insert newContact;

		Test.startTest();

		try
		{
			unitOfWork.registerDirty(newContact, Contact.AccountId, newAccount2);
			Assert.fail('Exception was not thrown for editing an Object relationship when the type is not supported');
		}
		catch(Exception error)
		{
			Assert.isTrue(true, EXCEPTION_WAS_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}

	/**
	 * @description Confirm that exception is thrown when attempting to edit an Object relationship  without an Id
	 */
	@IsTest
	private static void registerEditRelationshipForNewObject()
	{
		CMN_TEST_UnitOfWork unitOfWork = new CMN_TEST_UnitOfWork();

		Account newAccount1 = CMN_DAL_DataFactory.insertBusinessAccount();
		Account newAccount2 = CMN_DAL_DataFactory.insertBusinessAccount();

		Contact newContact = CMN_DAL_DataFactory.newContact();
		newContact.AccountId = newAccount1.Id;

		Test.startTest();

		try
		{
			unitOfWork.registerDirty(newContact, Contact.AccountId, newAccount2);
			Assert.fail('Exception was not thrown for editing an Object relationship for  a new Item');
		}
		catch(Exception error)
		{
			Assert.isTrue(true, EXCEPTION_WAS_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}

	@IsTest
	private static void registerRelationshipWhenTypeNotRegistered()
	{
		CMN_TEST_UnitOfWork unitOfWork = new CMN_TEST_UnitOfWork();

		Account newAccount1 = CMN_DAL_DataFactory.insertBusinessAccount();
		Account newAccount2 = CMN_DAL_DataFactory.newBusinessAccount();

		Contact newContact = CMN_DAL_DataFactory.newContact();
		newContact.AccountId = newAccount1.Id;

		Test.startTest();

		try
		{
			unitOfWork.registerRelationship(newContact, Contact.AccountId, newAccount2);
			Assert.fail('Exception was not thrown for editing an Object relationship when the type is not supported');
		}
		catch(Exception error)
		{
			Assert.isTrue(true, EXCEPTION_WAS_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}

	/**
	 * @description Will check unit of work bypass's sharing appropriately
	 */
	@IsTest
	private static void bypassSharingAllOperations()
	{
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(TEST_OBJECT_TYPES);

		//Ready only user does access to the foobar record
		CMN_Foobar__c updateFoobar = CMN_DAL_DataFactory.insertFoobar();
		updateFoobar.Name = CMN_DAL_SObjectDomain.generateRandomName();

		unitOfWork.registerDirty(updateFoobar);
		unitOfWork.registerNew(CMN_DAL_DataFactory.newFoobar());
		unitOfWork.registerDeleted(updateFoobar);

		try
		{
			System.runAs(CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_STANDARD_USER))
			{
				Test.startTest();

				unitOfWork.commitWork(false);

				Test.stopTest();

				Assert.isTrue(true, 'Sharing was bypassed as expected.');
			}
		}
		catch(Exception error)
		{
			Assert.fail('Sharing was not bypassed as expected.\n' + error.getMessage());
		}
	}

	/**
	 * @description Will execute commit on provided unit of work and confirm sharing was enforced
	 *
	 * @param unitOfWork The unit of work which has the changes we intend to commit
	 *
	 * @see CMN_DAL_SObjectUnitOfWork.commitWork
	 */
	private static void assertSharingEnforced(CMN_DAL_SObjectUnitOfWork unitOfWork)
	{
		try
		{
			System.runAs(CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_STANDARD_USER))
			{
				Test.startTest();

				unitOfWork.commitWork(true);

				Test.stopTest();

				Assert.fail('Sharing was bypassed.');
			}
		}
		catch(Exception error)
		{
			Assert.isTrue(true, 'Sharing was not bypassed');
		}
	}

	/**
	 * @description Will check unit of work enforces sharing for update operation
	 */
	@IsTest
	private static void enforceSharingUpdate()
	{
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(TEST_OBJECT_TYPES);

		//Ready only user does access to the foobar record
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.insertFoobar();
		newFoobar.Name = CMN_DAL_SObjectDomain.generateRandomName();

		unitOfWork.registerDirty(newFoobar);

		assertSharingEnforced(unitOfWork);
	}

	/**
	 * @description Will check unit of work enforces sharing for delete operation
	 */
	@IsTest
	private static void enforceSharingDelete()
	{
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(TEST_OBJECT_TYPES);

		//Ready only user does access to the foobar record
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.insertFoobar();
		unitOfWork.registerDeleted(newFoobar);//New is not failing need to investigate, but leaving line for code coverage
		unitOfWork.registerNew(CMN_DAL_DataFactory.newFoobar());
		assertSharingEnforced(unitOfWork);
	}

	/**
	 * @description Assert that actual events exactly match expected events (size, order and name)
	 * and types match expected types
	 *
	 * @param expectedEvents as input
	 * @param actualEvents as input
	 * @param expectedTypes as input
	 * @param actualTypes as input
	 */
	private static void assertEvents
			(
					List<String> expectedEvents,
					List<String> actualEvents,
					Set<SObjectType> expectedTypes,
					Set<String> actualTypes
			)
	{
		// assert that events match
		Assert.areEqual(expectedEvents.size(), actualEvents.size(), 'events size');
		for(Integer i = 0; i < expectedEvents.size(); i++)
		{
			Assert.areEqual(expectedEvents[i], actualEvents[i], String.format('Event {0} was not fired in order expected.', new List<String>
			{
					expectedEvents[i]
			}));
		}

		// assert that types match
		Assert.areEqual(expectedTypes.size(), actualTypes.size(), 'types size');

		for(SObjectType objectType : expectedTypes)
		{
			Assert.areEqual
					(
							true,
							actualTypes.contains(objectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName()),
							String.format('Type {0} was not registered.', new List<String> {objectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName()})
					);
		}
	}

	/**
	 * @description Derived unit of work that tracks event notifications and handle registration of type
	 */
	private class CMN_TEST_UnitOfWork extends CMN_DAL_SObjectUnitOfWork
	{
		private final List<String> commitWorkEventsFired = new List<String>();

		/**
		 * @description Method use to get the list of String
		 *
		 * @return list of strings
		 */
		private List<String> getCommitWorkEventsFired()
		{
			return commitWorkEventsFired.clone();
		}

		/**
		 * @description Method use to get the list of SObject registered type
		 *
		 * @return set of sobjectTypes
		 */
		private Set<String> getRegisteredTypes()
		{
			return new Set<String>(registeredObjectNames);
		}

		/**
		 * @description NA
		 */
		public CMN_TEST_UnitOfWork()
		{
			super();
		}

		/**
		 * @description Method use to test Object type of Unit of work
		 *
		 * @param sObjectTypes as input
		 */
		public CMN_TEST_UnitOfWork(List<SObjectType> sObjectTypes)
		{
			super(sObjectTypes);
		}

		private void addEvent(String event)
		{
			// events should only be fired one time
			// ensure that this event has not been fired already
			for(String eventName : commitWorkEventsFired)
			{
				if(event == eventName)
				{
					throw new DerivedUnitOfWorkException(String.format('Event {0} has already been fired.', new List<String>
					{
							event
					}));
				}
			}

			commitWorkEventsFired.add(event);
		}

		public override void onCommitWorkStarting()
		{
			super.onCommitWorkStarting();

			addEvent(EVENT_COMMIT_STARTING);
		}

		public override void onDMLStarting()
		{
			super.onDMLStarting();

			addEvent(EVENT_DML_STARTING);
		}

		public override void onDMLFinished()
		{
			super.onDMLFinished();

			addEvent(EVENT_DML_FINISHED);
		}

		public override void onCommitWorkFinishing()
		{
			super.onCommitWorkFinishing();

			addEvent(EVENT_COMMIT_FINISHING);
		}

		public override void onCommitWorkFinished(Boolean wasSuccessful)
		{
			super.onCommitWorkFinished(wasSuccessful);

			addEvent(EVENT_COMMIT_FINISHED + ' - ' + wasSuccessful);
		}
	}

	private class DerivedUnitOfWorkException extends Exception
	{
	}
}