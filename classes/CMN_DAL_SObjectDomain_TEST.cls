/**
 * @description Class has base methods that can be used to test and DAL class of Base Object
 *
 * @see CMN_DAL_SObjectDomain
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date 2019, May 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_DAL_SObjectDomain_TEST
{
	private static final Integer NUMBER_BOOLEANS_TO_GENERATE = 20;
	private static final String ERROR_CLEARED = 'Field should not be cleared';
	private static final String ERROR_FIELD_NOT_CLEARED = 'Field not cleared';

	/**
	 * @description Method is use to test the new Object
	 *
	 * @see CMN_DAL_SObjectDomain.newObject
	 */
	@IsTest
	private static void newObject()
	{
		Test.startTest();

		SObject newObject = CMN_DAL_SObjectDomain.newObject(CMN_DAL_Account.OBJECT_NAME);

		Test.stopTest();

		Assert.areEqual(Account.SObjectType, newObject.getSObjectType(), 'Incorrect object type');
	}

	/**
	 * @description Will create an invalid account
	 *
	 * @return newly created uncommitted account
	 */
	private static Account newInvalidAccount()
	{
		Account newAccount = CMN_DAL_DataFactory.newBusinessAccount();
		newAccount.Name = CMN_UTIL_String.EMPTY;
		return newAccount;
	}

	/**
	 * @description Method is use to test the database error handling when dml operations fail
	 *
	 * @see CMN_DAL_SObjectDomain.insertDBObject
	 */
	@IsTest
	private static void insertFailed()
	{
		Test.startTest();

		Boolean successful = CMN_DAL_SObjectDomain.insertDBObject(newInvalidAccount(), false).success;

		Test.stopTest();

		Assert.areEqual(successful, false, 'Expected Insert to Fail as Name is blank');
	}

	/**
	 * @description Method is use to test the database error handling when dml operations fail
	 *
	 * @see CMN_DAL_SObjectDomain.updateDBObject
	 */
	@IsTest
	private static void updateFailed()
	{
		Test.startTest();

		Boolean successful = CMN_DAL_SObjectDomain.updateDBObject(newInvalidAccount(), false).success;

		Test.stopTest();

		Assert.areEqual(successful, false, 'Expected Update to Fail Object has no Id');
	}

	/**
	 * @description Method is use to test the database error handling when dml operations fail
	 *
	 * @see CMN_DAL_SObjectDomain.deleteDBObject
	 */
	@IsTest
	private static void deleteFailed()
	{
		Account newAccount = CMN_DAL_DataFactory.newBusinessAccount();
		newAccount.Id = CMN_UTIL_Random.getRandomId(Account.SObjectType);

		Test.startTest();

		Boolean successful = CMN_DAL_SObjectDomain.deleteDBObject(newAccount, false).success;

		Test.stopTest();

		Assert.areEqual(successful, false, 'Expected delete to Fail Object has no Id');
	}

	/**
	 * @description Method is use to test the database error handling when dml operations fail
	 *
	 * @see CMN_DAL_SObjectDomain.undeleteDBObject
	 */
	@IsTest
	private static void undeleteFailed()
	{
		Account newAccount = CMN_DAL_DataFactory.newBusinessAccount();
		newAccount.Id = CMN_UTIL_Random.randomSObjectId(Account.SObjectType);

		Test.startTest();

		Boolean successful = CMN_DAL_SObjectDomain.undeleteDBObject(newAccount, false).success;

		Test.stopTest();

		Assert.areEqual(successful, false, 'Expected undelete to Fail Object has no Id');
	}

	/**
	 * @description Method is use to test the database error handling when dml operations fail
	 *
	 * @see CMN_DAL_SObjectDomain.upsertDBObject
	 */
	@IsTest
	private static void upsertFailed()
	{
		Test.startTest();

		Boolean successful = CMN_DAL_SObjectDomain.upsertDBObject(newInvalidAccount(), false).success;

		Test.stopTest();

		Assert.areEqual(successful, false, 'Expected Insert to Fail as Name is blank');
	}

	/**
	 * @description Method is use to test the database error handling when dml operations fail
	 *
	 * @see CMN_DAL_SObjectDomain.deleteDBObject
	 * @see CMN_DAL_SObjectDomain.deleteDBObjects
	 * @see CMN_DAL_SObjectDomain.undeleteDBObject
	 * @see CMN_DAL_SObjectDomain.undeleteDBObjects
	 * @see CMN_DAL_SObjectDomain.updateDBObject
	 * @see CMN_DAL_SObjectDomain.updateDBObjects
	 * @see CMN_DAL_SObjectDomain.updateDatabase
	 * @see CMN_DAL_SObjectDomain.upsertDBObject
	 * @see CMN_DAL_SObjectDomain.upsertDBObjects
	 */
	@IsTest
	private static void dmlOperationsSucceed()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		List<SObject> newObjects = new List<SObject> {newFoobar};
		try
		{
			Test.startTest();

			// Insert record using updateDatabase method with singleObjectType set to false
			CMN_DAL_SObjectDomain.updateDatabase
					(
							new List<SObject> {newFoobar},
							CMN_DAL_SObjectDomain.DatabaseOperation.DBO_INSERT,
							true,
							true,
							false,
							true
					);

			CMN_DAL_SObjectDomain.deleteDBObject(newFoobar);
			CMN_DAL_SObjectDomain.undeleteDBObject(newFoobar);

			newFoobar.Name = CMN_DAL_SObjectDomain.generateRandomName();
			CMN_DAL_SObjectDomain.upsertDBObject(newFoobar);

			newFoobar.Name = CMN_DAL_SObjectDomain.generateRandomName();
			CMN_DAL_SObjectDomain.upsertDBObjects(newObjects);

			newFoobar.Name = CMN_DAL_SObjectDomain.generateRandomName();
			CMN_DAL_SObjectDomain.updateDBObject(newFoobar);

			newFoobar.Name = CMN_DAL_SObjectDomain.generateRandomName();
			CMN_DAL_SObjectDomain.updateDBObjects(newObjects);

			Test.stopTest();

			List<CMN_Foobar__c> foundFoobars = CMN_DAL_Foobar.getAll();
			Assert.isFalse(foundFoobars.isEmpty(), 'No foobars found.');

			CMN_Foobar__c foundFoobar = foundFoobars.iterator().next();
			Assert.areEqual(foundFoobar.Name, newFoobar.Name, 'Foobar not updated correctly');

			CMN_DAL_SObjectDomain.deleteDBObjects(newObjects);

			foundFoobars = CMN_DAL_Foobar.getAll();
			Assert.isTrue(foundFoobars.isEmpty(), 'Foobar not deleted correctly');

			CMN_DAL_SObjectDomain.undeleteDBObjects(newObjects);

			foundFoobars = CMN_DAL_Foobar.getAll();
			Assert.isFalse(foundFoobars.isEmpty(), 'Foobar not undeleted correctly');
		}
		catch(Exception error)
		{
			Assert.fail('A DML operation failed with error: ' + error.getMessage());
		}
	}

	/**
	 * @description Will test random date generation
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomDate
	 */
	@IsTest
	private static void generateRandomDate()
	{
		Test.startTest();

		Date date1 = CMN_DAL_SObjectDomain.generateRandomDate();
		Date date2 = CMN_DAL_SObjectDomain.generateRandomDate();

		Test.stopTest();

		Assert.areNotEqual(date1, date2, 'Dates not Random');
		Assert.isFalse(date1.isSameDay(date2), 'Dates should not be on same day');
	}

	/**
	 * @description Will test random date time generation
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomDateTime
	 */
	@IsTest
	private static void generateRandomDateTime()
	{
		Test.startTest();

		Datetime dateTime1 = CMN_DAL_SObjectDomain.generateRandomDateTime();
		Datetime dateTime2 = CMN_DAL_SObjectDomain.generateRandomDateTime();

		Test.stopTest();

		Assert.areNotEqual(dateTime1, dateTime2, 'Dates not random');
		Assert.isFalse(dateTime1.isSameDay(dateTime2), 'Dates should not be on same day');
	}

	/**
	 * @description Method is use to test the number
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomNumber
	 */
	@IsTest
	private static void generateRandomNumber()
	{
		Test.startTest();

		String randomNumber = CMN_DAL_SObjectDomain.generateRandomNumber();

		Test.stopTest();

		Boolean isNumeric = randomNumber.isNumeric();

		Assert.isTrue(isNumeric, 'The number provided is not numeric');

		Integer expectedLength = 8;
		Assert.areEqual(expectedLength, randomNumber.length(), 'Number generated with incorrect length');
	}

	/**
	 * @description Will test that random number is generated between a min and max value
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomInteger
	 */
	@IsTest
	private static void generateRandomIntegerMinMax()
	{
		Integer min = 5;
		Integer max = 10;

		Test.startTest();

		Integer randomInteger = CMN_DAL_SObjectDomain.generateRandomInteger(min, max);

		Test.stopTest();

		Assert.isTrue(randomInteger >= min, 'Generated Integer is lower than min value');
		Assert.isTrue(randomInteger <= max, 'Generated Integer is higher than max value');
	}

	/**
	 * @description Method is use test generation of a random integer
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomInteger
	 */
	@IsTest
	private static void generateRandomInteger()
	{
		Test.startTest();

		Integer randomInteger1 = CMN_DAL_SObjectDomain.generateRandomInteger();
		Integer randomInteger2 = CMN_DAL_SObjectDomain.generateRandomInteger();

		Test.stopTest();

		Assert.areNotEqual(randomInteger1, randomInteger2, 'Integers not random');
	}

	/**
	 * @description Method is use test generation of a random currency
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomCurrencyAsString
	 */
	@IsTest
	private static void generateRandomCurrencyAsString()
	{
		Test.startTest();

		String randomCurrencyAsString = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();

		Test.stopTest();

		Assert.isTrue(randomCurrencyAsString.contains(CMN_UTIL_String.DOT), 'No decimal point found');

		List<String> splitString = randomCurrencyAsString.split('\\.');

		Assert.areEqual(2, splitString.size(), 'More than 1 decimal point found');

		String stringBeforeDot = splitString.get(0);
		String stringAfterDot = splitString.get(1);

		Assert.isTrue(CMN_UTIL_String.isNumeric(stringBeforeDot) && CMN_UTIL_String.isNumeric(stringAfterDot), 'Not a valid number');
		Assert.areEqual(2, stringAfterDot.length(), 'There should be two digits after the decimal point');
	}

	/**
	 * @description Method is use test generation of a random percentage
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomPercentageAsString
	 */
	@IsTest
	private static void generateRandomPercentageAsString()
	{
		Test.startTest();

		String randomPercentageAsString = CMN_DAL_SObjectDomain.generateRandomPercentageAsString();

		Test.stopTest();

		Assert.isTrue(randomPercentageAsString.contains(CMN_UTIL_String.DOT), 'No decimal point found');

		List<String> splitString = randomPercentageAsString.split('\\.');

		Assert.areEqual(2, splitString.size(), 'More than 1 decimal point found');

		String stringBeforeDot = splitString.get(0);
		String stringAfterDot = splitString.get(1);

		Assert.isTrue(CMN_UTIL_String.isNumeric(stringBeforeDot) && CMN_UTIL_String.isNumeric(stringAfterDot), 'Not a valid number');
		Assert.isTrue(stringBeforeDot.length() <= 2, 'Number should be between 0 and 100');
		Assert.areEqual(2, stringAfterDot.length(), 'There should be two digits after the decimal point');
	}

	/**
	 * @description Method is use to test the number
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomName
	 */
	@IsTest
	private static void generateRandomName()
	{
		Test.startTest();

		String randomName = CMN_DAL_SObjectDomain.generateRandomName();

		Test.stopTest();

		Boolean isAlphabetic = randomName.isAlpha();

		Assert.isTrue(isAlphabetic, 'Name is not alphabetic');

		Integer expectedLength = 15;
		Assert.areEqual(expectedLength, randomName.length(), 'Name generated with incorrect length.');
	}

	/**
	 * @description Method is use to test the generated description
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomDescription
	 */
	@IsTest
	private static void generateRandomDescription()
	{
		Test.startTest();

		String randomDescription = CMN_DAL_SObjectDomain.generateRandomDescription();

		Test.stopTest();

		Boolean isAlphabetic = randomDescription.isAlpha();

		Assert.isTrue(isAlphabetic, 'Generated Description is not alphabetic');

		Integer expectedLength = 80;
		Assert.areEqual(expectedLength, randomDescription.length(), 'Description generated with incorrect length');
	}

	/**
	 * @description Method is use to test the generated Email
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomEmail
	 */
	@IsTest
	private static void generateRandomEmail()
	{
		Test.startTest();

		String randomEmail = CMN_DAL_SObjectDomain.generateRandomEmail();

		Test.stopTest();

		String randomEmailSuffix = randomEmail.substring(15, randomEmail.length());

		Assert.areEqual(CMN_DAL_SObjectDomain.CONTACT_EMAIL_SUFFIX, randomEmailSuffix, 'Suffix incorrect');
	}

	/**
	 * @description Checks that performing DML operations with empty list works as expected
	 *
	 * @see CMN_DAL_SObjectDomain.deleteDBObjects
	 * @see CMN_DAL_SObjectDomain.insertDBObjects
	 * @see CMN_DAL_SObjectDomain.undeleteDBObjects
	 * @see CMN_DAL_SObjectDomain.updateDBObjects
	 * @see CMN_DAL_SObjectDomain.upsertDBObjects
	 */
	@IsTest
	private static void checkEmptyDatabaseUpdateSucceed()
	{
		List<SObject> emptyList = new List<SObject>();

		Test.startTest();

		Boolean insertSuccessful = CMN_DAL_SObjectDomain.insertDBObjects(emptyList, false).isEmpty();
		Boolean updateSuccessful = CMN_DAL_SObjectDomain.updateDBObjects(emptyList, false).isEmpty();
		Boolean upsertSuccessful = CMN_DAL_SObjectDomain.upsertDBObjects(emptyList, false).isEmpty();
		//Second Upsert for Coverage
		Boolean upsertSuccessful2 = CMN_DAL_SObjectDomain.updateDatabase (emptyList, CMN_DAL_SObjectDomain.DatabaseOperation.DBO_UPSERT, false).isEmpty();
		Boolean deleteSuccessful = CMN_DAL_SObjectDomain.deleteDBObjects(emptyList, false).isEmpty();
		Boolean undeleteSuccessful = CMN_DAL_SObjectDomain.undeleteDBObjects(emptyList, false).isEmpty();

		Test.stopTest();

		String assertMessage = 'Expected no DML save results';

		Assert.isTrue(insertSuccessful, assertMessage);
		Assert.isTrue(updateSuccessful, assertMessage);
		Assert.isTrue(upsertSuccessful, assertMessage);
		Assert.isTrue(upsertSuccessful2, assertMessage);
		Assert.isTrue(deleteSuccessful, assertMessage);
		Assert.isTrue(undeleteSuccessful, assertMessage);
	}

	/**
	 * @description Method is used to check if a Duplicate error thrown during a DML operation where
	 * partial successes are allowed is collected correctly
	 *
	 * @see CMN_DAL_SObjectDomain.insertDBObject
	 */
	@IsTest
	private static void collectDuplicateErrors()
	{
		CMN_Foobar__c newFoo1 = CMN_DAL_DataFactory.insertFoobar();
		CMN_Foobar__c newFoo2 = CMN_DAL_DataFactory.newFoobar();
		newFoo2.Name = newFoo1.Name;

		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		Boolean insertSuccessful = CMN_DAL_SObjectDomain.insertDBObject(newFoo2, false).success;

		Test.stopTest();

		Assert.isFalse(insertSuccessful, 'Insert Operation Did not Fail due to duplicate rule');
	}

	/**
	 * @description Will check that random boolean is generated
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomBoolean
	 */
	@IsTest
	private static void generateRandomBoolean()
	{
		Integer numberTrue = 0;
		Integer numberFalse = 0;

		Test.startTest();

		for(Integer i = 0; i < NUMBER_BOOLEANS_TO_GENERATE; i++)
		{
			Boolean randomBoolean = CMN_DAL_SObjectDomain.generateRandomBoolean();
			if(randomBoolean)
			{
				numberTrue++;
			}
			else
			{
				numberFalse++;
			}
		}

		Test.stopTest();

		Assert.isTrue((numberTrue > 0) && (numberFalse > 0), 'Boolean values not generated randomly');
	}

	@IsTest
	private static void testInstance()
	{
		CMN_DAL_SObjectDomain.ISObjectDomain foobarDomain = new CMN_DAL_SObjectDomain(CMN_Foobar__c.SObjectType);
		Assert.areEqual(CMN_Foobar__c.SObjectType, foobarDomain.sObjectType(), 'Object type is incorrect');
	}

	/**
	 * @description Method is use to test the recordtype by developer name of SObject
	 *
	 * @see CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName
	 */
	@IsTest
	private static void getRecordTypeByDeveloperName()
	{
		List<RecordType> recordTypes = CMN_DAL_RecordType.findByObjectType(Account.SObjectType);

		if(!recordTypes.isEmpty())
		{
			RecordType aRecordType = recordTypes.iterator().next();

			Test.startTest();

			Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, aRecordType.DeveloperName);

			Test.stopTest();

			Assert.areEqual(aRecordType.Id, recordTypeId, 'Incorrect Recordtype found');
		}
	}

	/**
	 * @description Check that system handles situation where recordtype doesn't exist
	 *
	 * @see CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName
	 */
	@IsTest
	private static void getRecordTypeByDeveloperNameNotFound()
	{
		Test.startTest();

		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, CMN_DAL_SObjectDomain.generateRandomName());

		Test.stopTest();

		Assert.isNull(recordTypeId, 'No RecordType should be found');
	}

	/**
	 * @description Will test assertIsCorrectDmlError method by causing a DML exception and also check commit was rolled back
	 *
	 * @see CMN_DAL_SObjectDomain.assertIsCorrectDmlError
	 */
	@IsTest
	private static void assertIsCorrectDmlError()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		// Setting Email to an invalid email address to cause exception
		newFoobar.CMN_Email__c = CMN_DAL_SObjectDomain.generateRandomName();

		//Account is valid so this should insert find... we want to check that it rolls back appropriately
		Account newAccount = CMN_DAL_DataFactory.newAccount();

		List<SObject> newObjects = new List<SObject> {newFoobar, newAccount};

		try
		{
			Test.startTest();

			//Check that exception is thrown, will also ensure transaction is rolled back
			CMN_DAL_SObjectDomain.updateDatabase(newObjects, CMN_DAL_SObjectDomain.DatabaseOperation.DBO_INSERT, true, true, false, true);

			Test.stopTest();

			Assert.fail('Exception not thrown as expected');
		}
		catch(Exception error)
		{
			CMN_DAL_SObjectDomain.assertIsCorrectDmlError(error, StatusCode.INVALID_EMAIL_ADDRESS);

			List<Account> foundAccounts = CMN_DAL_Search.getAll(CMN_DAL_Account.OBJECT_NAME);
			Assert.isTrue(foundAccounts.isEmpty(), 'Insert of account not rolled back as expected');
		}
	}

	/**
	 * @description Will test the behaviour of the newObjectFromExisting method
	 *
	 * @see CMN_DAL_SObjectDomain.newObjectFromExisting
	 */
	@IsTest
	private static void newObjectFromExisting()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		newFoobar.CMN_Checkbox__c = true;
		insert newFoobar;

		CMN_Foobar__c newChildFoobar = CMN_DAL_DataFactory.newFoobar();
		newChildFoobar.CMN_Lookup__c = newFoobar.Id;
		insert newChildFoobar;

		newFoobar = CMN_DAL_Foobar.getAllWithChildren().iterator().next();

		Test.startTest();

		SObject clearedObject = CMN_DAL_SObjectDomain.newObjectFromExisting
				(
						newFoobar,
						new Set<SObjectField> {CMN_Foobar__c.CMN_Phone__c, CMN_Foobar__c.RecordTypeId}
				);

		Test.stopTest();

		Assert.isNotNull(clearedObject, 'SObject not initialized');
		Assert.areEqual(newFoobar.getSObjectType(), clearedObject.getSObjectType(), 'Incorrect Object Type created');

		CMN_Foobar__c clearedFoobar = (CMN_Foobar__c)clearedObject;

		Assert.areEqual(newFoobar.CMN_Phone__c, clearedFoobar.CMN_Phone__c, ERROR_CLEARED);
		Assert.areEqual(newFoobar.RecordTypeId, clearedFoobar.RecordTypeId, ERROR_CLEARED);
		Assert.areNotEqual(newFoobar.Name, clearedFoobar.Name, ERROR_FIELD_NOT_CLEARED);
		Assert.isFalse(clearedFoobar.CMN_Foobars__r.isEmpty(), 'Child Objects were incorrectly cleared.');

		update clearedFoobar;
		clearedFoobar = CMN_DAL_Foobar.getAll().iterator().next();

		Assert.areNotEqual(newFoobar.Name, clearedFoobar.Name, ERROR_FIELD_NOT_CLEARED);
	}
}