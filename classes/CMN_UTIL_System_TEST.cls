/**
 * @description Test class to tests the methods available in CMN_UTIL_System
 *
 * @see CMN_UTIL_System
 *
 * @author darrion.james.singh@accenture.com jason.van.beukering@accenture.com
 *
 * @date March 2021, June 2023
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity,PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_UTIL_System_TEST
{
	/**
	 * @description The number of account to create to test finding random SObject from a list
	 */
	private static final Integer NUMBER_OF_ACCOUNTS_TO_CREATE = 100;
	private static final String ERROR_FIELD_NOT_INVALID = 'Field not identified as being invalid';
	private static final String ERROR_LIST_SHOULD_NOT_BE_EMPTY = 'List should not be empty';
	private static final String ERROR_MAP_RETURNED_OF_WRONG_SIZE = 'Map returned of wrong size: ';
	private static final String ERROR_MISSING_OBJECT_NAME = 'Missing object Name';
	private static final String ERROR_NO_MAP_RETURNED = 'No map returned';
	private static final String ERROR_OBJECT_SHOULD_BE_EQUAL = 'Objects should be equal';
	private static final String ERROR_SET_SHOULD_NOT_BE_EMPTY = 'Set should not be empty';
	private static final String ERROR_SPLIT_SIZE_INVALID = 'Split invalid';
	private static final String ERROR_THROWN_AS_EXPECTED = 'Error was thrown as expected';
	private static final String ERROR_WRONG_LIST_SIZE = 'Wrong list size';
	private static final String ERROR_WRONG_SET_SIZE = 'Wrong set size';
	private static final String NOT_BLANK = 'not_blank';
	private static final String NOT_EMPTY = 'not empty';

	@IsTest
	private static void testTrimIdSet()
	{
		Set<Id> setIds = new Set<Id>
		{
				CMN_DAL_DataFactory.insertBusinessAccount().Id,
				CMN_DAL_DataFactory.insertBusinessAccount().Id,
				null
		};

		System.assertEquals(2, CMN_UTIL_System.trimSet(setIds).size(), 'Incorrect Set Size');
	}

	/**
	 * @description This method is use to test the converted Date from Datetime
	 */
	@IsTest
	private static void testDateTimeToDate()
	{
		Test.startTest();
		Datetime now = Datetime.now();
		Date gotDate = CMN_UTIL_System.dateTimeToDate(now);
		System.assertEquals(now.date(), gotDate);
		Test.stopTest();
	}

	@IsTest
	private static void testObjectQueryable()
	{
		Test.startTest();
		System.assertEquals(true, CMN_UTIL_System.objectQueryable(Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName()));
		Test.stopTest();
	}

	/**
	 * @description This method is use to test the field name of SObject
	 */
	@IsTest
	private static void testGetAllFieldNames()
	{
		Test.startTest();
		Set<String> fieldsSet = CMN_UTIL_System.getAllFieldNames(Account.SObjectType);
		System.assertNotEquals(0, fieldsSet.size());
		Test.stopTest();
	}

	/**
	 * @description This method is use to test the SObject by Id
	 */
	@IsTest
	private static void testGetSObjectTypeById()
	{
		Test.startTest();
		Account anAccount = CMN_DAL_DataFactory.insertBusinessAccount();
		Schema.SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(anAccount.Id);
		System.assertEquals(Account.SObjectType, objectType);
		Test.stopTest();
	}

	/**
	 * @description Checks the behaviour of the extractListValues method
	 *
	 * @see CMN_UTIL_System.extractListValues
	 */
	@IsTest
	private static void extractListValues()
	{
		Account newAccount1 = CMN_DAL_DataFactory.newBusinessAccount();
		Account newAccount2 = CMN_DAL_DataFactory.newBusinessAccount();
		Account newAccount3 = new Account();

		List<SObject> objects = new List<Account> {newAccount1, newAccount2, newAccount3};

		Test.startTest();

		List<String> resultsWithBlanks = CMN_UTIL_System.extractListValues(objects, CMN_DAL_SObjectDomain.FIELD_NAME);
		List<String> resultsWithoutBlanks = CMN_UTIL_System.extractListValues(objects, CMN_DAL_SObjectDomain.FIELD_NAME, true);

		Test.stopTest();

		System.assertEquals(false, resultsWithBlanks.isEmpty(), ERROR_LIST_SHOULD_NOT_BE_EMPTY);
		System.assertEquals(3, resultsWithBlanks.size(), ERROR_WRONG_LIST_SIZE);

		System.assertEquals(false, resultsWithoutBlanks.isEmpty(), ERROR_LIST_SHOULD_NOT_BE_EMPTY);
		System.assertEquals(2, resultsWithoutBlanks.size(), ERROR_WRONG_LIST_SIZE);

		Set<String> resultSet = new Set<String>(resultsWithBlanks);

		System.assert(resultSet.contains(newAccount1.Name), ERROR_MISSING_OBJECT_NAME);
		System.assert(resultSet.contains(newAccount2.Name), ERROR_MISSING_OBJECT_NAME);
	}

	/**
	 * @description Checks the behaviour of the extractSetValues method
	 *
	 * @see CMN_UTIL_System.extractSetValues
	 */
	@IsTest
	private static void extractSetValues()
	{
		Account newAccount1 = CMN_DAL_DataFactory.newBusinessAccount();
		Account newAccount2 = CMN_DAL_DataFactory.newBusinessAccount();
		Account newAccount3 = new Account();

		List<SObject> objects = new List<Account> {newAccount1, newAccount2, newAccount3};

		Test.startTest();

		Set<String> resultsWithBlanks = CMN_UTIL_System.extractSetValues(objects, CMN_DAL_SObjectDomain.FIELD_NAME);
		Set<String> resultsWithoutBlanks = CMN_UTIL_System.extractSetValues(objects, CMN_DAL_SObjectDomain.FIELD_NAME, true);

		Test.stopTest();

		System.assertEquals(false, resultsWithBlanks.isEmpty(), ERROR_SET_SHOULD_NOT_BE_EMPTY);
		System.assertEquals(3, resultsWithBlanks.size(), ERROR_WRONG_SET_SIZE);

		System.assertEquals(false, resultsWithoutBlanks.isEmpty(), ERROR_SET_SHOULD_NOT_BE_EMPTY);
		System.assertEquals(2, resultsWithoutBlanks.size(), ERROR_WRONG_SET_SIZE);

		System.assert(resultsWithBlanks.contains(newAccount1.Name), ERROR_MISSING_OBJECT_NAME);
		System.assert(resultsWithBlanks.contains(newAccount2.Name), ERROR_MISSING_OBJECT_NAME);
	}

	/**
	 * @description This method is use to test the items inserted.
	 */
	@IsTest
	private static void testFindWhere()
	{
		List<Account> itemsList = new List<Account>
		{
				CMN_DAL_DataFactory.insertBusinessAccount(),
				CMN_DAL_DataFactory.insertBusinessAccount(),
				CMN_DAL_DataFactory.insertBusinessAccount()
		};

		Account acc1 = CMN_DAL_DataFactory.insertBusinessAccount();
		Account acc2 = CMN_DAL_DataFactory.insertBusinessAccount();

		itemsList.add(acc1);
		itemsList.add(acc2);

		List<Account> results = new List<Account>();

		Test.startTest();

		results = CMN_UTIL_System.findWhereIn(itemsList, CMN_DAL_SObjectDomain.FIELD_NAME, new List<Object> {acc1.Name, acc2.Name});

		Test.stopTest();

		System.assertEquals(false, results.isEmpty(), ERROR_LIST_SHOULD_NOT_BE_EMPTY);
		System.assertEquals(2, results.size(), 'Wrong List size: ' + results.size());

		System.assertEquals(1, CMN_UTIL_System.findWhere(results, CMN_DAL_SObjectDomain.FIELD_NAME, acc1.Name).size(), 'Object not Found');
		System.assertEquals(1, CMN_UTIL_System.findWhere(results, CMN_DAL_SObjectDomain.FIELD_NAME, acc2.Name).size(), 'Object not Found');
	}

	/**
	 * @description This method is use to test Id of account which
	 */
	@IsTest
	private static void testOmit()
	{
		List<Account> accounts = new List<Account>
		{
				CMN_DAL_DataFactory.insertBusinessAccount(),
				CMN_DAL_DataFactory.insertBusinessAccount(),
				CMN_DAL_DataFactory.insertBusinessAccount()
		};

		Account a1 = CMN_DAL_DataFactory.insertBusinessAccount();
		Account a2 = CMN_DAL_DataFactory.insertBusinessAccount();

		accounts.add(a1);
		accounts.add(a2);

		Set<Id> idList = CMN_UTIL_System.extractListIds(accounts);
		Set<Id> idToBeOmitted = new Set<Id> {a1.Id, a2.Id};

		Test.startTest();
		Set<Id> results = CMN_UTIL_System.omit(idList, idToBeOmitted);
		List<Account> omitWhereResults = CMN_UTIL_System.omitWhere(accounts, CMN_DAL_SObjectDomain.FIELD_ID, (Id)a1.get(CMN_DAL_SObjectDomain.FIELD_ID));
		Set<Id> concatResults = CMN_UTIL_System.concat(results, idToBeOmitted);
		Test.stopTest();

		System.assertEquals(3, results.size(), 'Should be left 3 Ids in list');
		System.assertEquals(4, omitWhereResults.size(), 'Should remove one account from list and be left 4 items in list');
		System.assertEquals(5, concatResults.size(), 'Should add 2 into set and be size of 5');
	}

	/**
	 * @description This method is use to test the remove items from the list
	 */
	@IsTest
	private static void testRemoveItems()
	{
		Set<String> setToRemove = new Set<String> {NOT_EMPTY, NOT_BLANK};

		List<String> aList = new List<String>();

		Test.startTest();
		List<String> resultsList = CMN_UTIL_System.removeItems(aList, setToRemove);
		System.assertEquals(true, resultsList.isEmpty(), 'List should be empty');

		aList = new List<String> {'a', 'b', NOT_EMPTY, 'c', 'full', NOT_BLANK};

		resultsList = CMN_UTIL_System.removeItems(aList, setToRemove);
		System.assertEquals(4, resultsList.size(), 'This list should 3 items size');
		Test.stopTest();
	}

	/**
	 * @description This method is use to test the dataset
	 */
	@IsTest
	private static void testAssertDateSetEquals()
	{
		Test.startTest();

		Set<Date> set1 = new Set<Date>();
		set1.add(System.today());
		Set<Date> set2 = new Set<Date>();
		set2.add(System.today());

		String message = CMN_DAL_SObjectDomain.generateRandomName();

		try
		{
			CMN_UTIL_System.assertDateSetEquals(set1, new Set<Date>(), message);
			System.assert (false, 'TEST 0. Dates are not equal. This exception must be thrown.');
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}

		try
		{
			CMN_UTIL_System.assertDateSetEquals(set1, set2, message);
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (false, 'TEST 1. Dates are equal. This exception must be not thrown.');
		}

		try
		{
			set2 = new Set<Date>();
			set2.add(System.today().addDays(1));
			CMN_UTIL_System.assertDateSetEquals(set1, set2, message);
			System.assert (false, 'TEST 2. Dates are not equal. This exception must be thrown.');
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}

	/**
	 * @description This method is use to test the List of SObject from CMN_UTIL_System class
	 */
	@IsTest
	private static void testAssertEmptyList()
	{
		Test.startTest();

		String message = CMN_DAL_SObjectDomain.generateRandomName();

		try
		{
			CMN_UTIL_System.assertEmptyList(new List<SObject>(), message);
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (false, 'TEST 1. Size is correct. This exception must be not thrown.');
		}

		try
		{
			Account a = CMN_DAL_DataFactory.insertBusinessAccount();

			List<SObject> items = new List<SObject>();
			items.add(a);

			CMN_UTIL_System.assertEmptyList(items, message);
			System.assert (false, 'TEST 2. Size is NOT correct. This exception must be thrown.');
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}

	/**
	 * @description This method is use to test the ID of BaseObject from CMN_UTIL_System class
	 */
	@IsTest
	private static void testAssertIDSetEquals()
	{
		Test.startTest();

		Account a = CMN_DAL_DataFactory.insertBusinessAccount();

		Set<Id> set1 = new Set<Id>();

		set1.add(a.Id);
		Set<Id> set2 = new Set<Id>(set1);

		String message = CMN_DAL_SObjectDomain.generateRandomName();

		try
		{
			CMN_UTIL_System.assertIDSetEquals(set1, new Set<Id>(), message);
			System.assert (false, 'TEST 1. Sets are not equal. This exception must be thrown.');
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}

		try
		{
			CMN_UTIL_System.assertIDSetEquals(set1, set2, message);
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}

		try
		{
			a = CMN_DAL_DataFactory.insertBusinessAccount();

			set2 = new Set<Id>();
			set2.add(a.Id);
			CMN_UTIL_System.assertIDSetEquals(set1, set2, message);
			System.assert (false, 'TEST 3. Sets are not equal. This exception must be thrown.');
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}

	/**
	 * @description This method is use to test the field value od Object
	 */
	@IsTest
	private static void testAssertObjectValues()
	{
		Test.startTest();

		Account a = CMN_DAL_DataFactory.insertBusinessAccount();

		String message = CMN_DAL_SObjectDomain.generateRandomName();

		List<String> fieldNames = new List<String>();

		fieldNames.add('Name');
		fieldNames.add('OwnerId');
		fieldNames.add('Phone');
		fieldNames.add('BillingStreet');
		fieldNames.add('BillingCity');
		fieldNames.add('BillingState');
		fieldNames.add('BillingCountry');

		List<Object> values = new List<Object>();
		values.add(a.Name);
		values.add(a.OwnerId);
		values.add(a.Phone);
		values.add(a.BillingStreet);
		values.add(a.BillingCity);
		values.add(a.BillingState);
		values.add(a.BillingCountry);

		try
		{
			CMN_UTIL_System.assertObjectValues(a, fieldNames, values, message);
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (false, 'TEST 1. Data are equal. This exception must be not thrown.');
		}

		try
		{
			values[0] = CMN_DAL_SObjectDomain.generateRandomName();
			CMN_UTIL_System.assertObjectValues(a, fieldNames, values, message);
			System.assert (false, 'TEST 2. Data are not equal. This exception must be thrown.');
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}

	/**
	 * @description This method is use to test the size from testing helper method
	 */
	@IsTest
	private static void testAssertSizeEquals()
	{
		Test.startTest();

		Account a = CMN_DAL_DataFactory.insertBusinessAccount();

		List<SObject> items = new List<SObject>();
		items.add(a);

		String message = CMN_DAL_SObjectDomain.generateRandomName();

		try
		{
			CMN_UTIL_System.assertSizeEquals(items, items.size(), message);
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (false, 'TEST 1. Size is correct. This exception must be not thrown.');
		}

		try
		{
			CMN_UTIL_System.assertSizeEquals(items, items.size() + 1, message);
			System.assert (false, 'TEST 2. Size is NOT correct. This exception must be thrown.');
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}

	/**
	 * @description This method is use to test the exclude items of Account
	 */
	@IsTest
	private static void testExcludeItemsFromList()
	{
		Account acc1 = CMN_DAL_DataFactory.insertBusinessAccount();
		Account acc2 = CMN_DAL_DataFactory.insertBusinessAccount();
		Account acc3 = CMN_DAL_DataFactory.insertBusinessAccount();
		List<Account> itemsList = new List<Account>
		{
				acc1, acc2, acc3
		};
		List<Account> excludeItemsList = new List<Account>
		{
				acc1, acc3
		};
		List<Account> results;

		Test.startTest();

		results = CMN_UTIL_System.excludeItemsFromList(itemsList, excludeItemsList);

		Test.stopTest();

		CMN_UTIL_System.assertSizeEquals(results, 1, 'Incorrect size. Must be left only 1 item');
		System.assertEquals(results.get(0), acc2, 'Wrong item. Only item in list should be "b"');
	}

	/**
	 * @description This method is use to test the Object name by id
	 */
	@IsTest
	private static void testObjectNameById()
	{
		Account anAccount = CMN_DAL_DataFactory.insertBusinessAccount();

		String objectName;

		Test.startTest();
		objectName = CMN_UTIL_System.getObjectNameFromId(anAccount.Id);
		System.assertEquals(Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName(), objectName);
	}

	/**
	 * @description This method is use to test the fields
	 */
	@IsTest
	private static void testHasField()
	{
		String nonExistentField = 'nothing';

		Account account = CMN_DAL_DataFactory.insertBusinessAccount();
		Boolean hasField;

		Test.startTest();

		hasField = CMN_UTIL_System.hasSObjectField(account, CMN_DAL_SObjectDomain.FIELD_NAME);
		System.assertEquals(hasField, true, 'Account object always has Name field. Should be true');
		hasField = CMN_UTIL_System.hasSObjectField(account, nonExistentField);
		System.assertEquals(hasField, false, 'Account does not have this field. Should be false');

		Test.stopTest();
	}

	/**
	 * @description This method is use to test the list of Id
	 */
	@IsTest
	private static void testExtractListIds()
	{
		List<Account> itemsList = new List<Account>
		{
				CMN_DAL_DataFactory.insertBusinessAccount(),
				CMN_DAL_DataFactory.insertBusinessAccount(),
				CMN_DAL_DataFactory.insertBusinessAccount()
		};

		Set<Id> idSet;

		Test.startTest();

		idSet = CMN_UTIL_System.extractListIds(itemsList);
		System.assertEquals(3, idSet.size(), 'Should be 3 ids in Set');

		itemsList.add(new Account(Id = null));

		idSet = CMN_UTIL_System.extractListIds(itemsList, CMN_DAL_SObjectDomain.FIELD_ID);
		System.assertEquals(4, idSet.size(), 'Should be 4 ids in Set');

		idSet = CMN_UTIL_System.extractListIds(itemsList, true);
		System.assertEquals(3, idSet.size(), 'Should be 3 ids in Set');

		Test.stopTest();
	}

	/**
	 * @description Will test the conversion of an Object list into a map
	 *
	 * @see CMN_UTIL_System.convertListToMapSet
	 */
	@IsTest
	private static void convertListToMapSet()
	{
		List<Account> newAccounts = new List<Account>
		{
				CMN_DAL_DataFactory.newBusinessAccount(),
				CMN_DAL_DataFactory.newBusinessAccount(),
				CMN_DAL_DataFactory.newBusinessAccount()
		};

		Account newBusinessAccount = CMN_DAL_DataFactory.newBusinessAccount();
		newAccounts.add(newBusinessAccount);

		CMN_DAL_SObjectDomain.insertDBObjects(newAccounts);

		Test.startTest();

		Map<Id, Set<Id>> mapSet = CMN_UTIL_System.convertListToMapSet
				(
						CMN_DAL_Account.findById(CMN_UTIL_System.extractListIds(newAccounts)),
						CMN_DAL_SObjectDomain.FIELD_OWNER_ID,
						CMN_DAL_SObjectDomain.FIELD_ID
				);

		Test.stopTest();

		Set<Id> setId = mapSet.get(UserInfo.getUserId());

		System.assertEquals(newAccounts.size(), setId.size(), 'Set contains incorrect number of items');
	}

	/**
	 * @description Will test conversion of an Object list into a map
	 *
	 * @see CMN_UTIL_System.convertListToMap
	 */
	@IsTest
	private static void convertListToMap()
	{
		List<Account> newAccounts = new List<Account>
		{
				CMN_DAL_DataFactory.newBusinessAccount(),
				CMN_DAL_DataFactory.newBusinessAccount(),
				CMN_DAL_DataFactory.newBusinessAccount()
		};

		CMN_DAL_SObjectDomain.insertDBObjects(newAccounts);

		Test.startTest();

		Map<Id, List<Account>> objectsByIdMap = CMN_UTIL_System.convertListToMap
				(
						CMN_DAL_Account.findById(CMN_UTIL_System.extractListIds(newAccounts)),
						CMN_DAL_SObjectDomain.FIELD_OWNER_ID
				);

		Test.stopTest();

		List<Account> mapAccounts = objectsByIdMap.get(UserInfo.getUserId());
		System.assertEquals(newAccounts.size(), mapAccounts.size(), 'List contains incorrect number of items');
	}

	/**
	 * @description Will test conversion of an Object list into a map
	 *
	 * @see CMN_UTIL_System.convertListToSingleMap
	 */
	@IsTest
	private static void convertListToSingleMap()
	{
		List<Account> newAccounts = new List<Account>
		{
				CMN_DAL_DataFactory.newBusinessAccount(),
				CMN_DAL_DataFactory.newBusinessAccount(),
				CMN_DAL_DataFactory.newBusinessAccount()
		};

		Account newBusinessAccount = CMN_DAL_DataFactory.newBusinessAccount();

		newAccounts.add(newBusinessAccount);

		CMN_DAL_SObjectDomain.insertDBObjects(newAccounts);

		Test.startTest();

		Map<Id, SObject> mapList = CMN_UTIL_System.convertListToSingleMap(newAccounts, CMN_DAL_SObjectDomain.FIELD_ID);

		Test.stopTest();

		System.assertEquals(newAccounts.size(), mapList.size(), 'Map contains incorrect number of items');
		System.assertEquals(newBusinessAccount, mapList.get((Id)newBusinessAccount.get(CMN_DAL_SObjectDomain.FIELD_ID)), ERROR_OBJECT_SHOULD_BE_EQUAL);
	}

	/**
	 * @description This method is use to test the single map from List
	 */
	@IsTest
	private static void testListToSingleMapCompoundKey()
	{
		List<Account> itemsList = new List<Account>
		{
				CMN_DAL_DataFactory.insertBusinessAccount(),
				CMN_DAL_DataFactory.insertBusinessAccount(),
				CMN_DAL_DataFactory.insertBusinessAccount()
		};

		Account acc1 = CMN_DAL_DataFactory.insertBusinessAccount();

		itemsList.add(acc1);
		Map<String, SObject> mapList = new Map<String, SObject>();
		List<String> keyList = new List<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME};

		Test.startTest();

		mapList = CMN_UTIL_System.convertListToSingleMap(itemsList, keyList);

		Test.stopTest();

		String key = CMN_UTIL_System.getCompoundKey(acc1, keyList);

		System.assertEquals(mapList.isEmpty(), false, ERROR_LIST_SHOULD_NOT_BE_EMPTY);
		System.assertEquals(mapList.get(key), acc1, ERROR_OBJECT_SHOULD_BE_EQUAL);
	}

	/**
	 * @description Method to test extractListFromMap with String as key
	 */
	@IsTest
	private static void extractListFromStringMap()
	{
		final String testStringKey = 'key';

		List<CMN_Foobar__c> itemsList = new List<CMN_Foobar__c>
		{
				CMN_DAL_DataFactory.newFoobar(),
				CMN_DAL_DataFactory.newFoobar(),
				CMN_DAL_DataFactory.newFoobar()
		};

		Map<String, List<CMN_Foobar__c> > testMap = new Map<String, List<CMN_Foobar__c> >();

		testMap.put(testStringKey, itemsList);
		List<CMN_Foobar__c> extractedList = new List<CMN_Foobar__c>();
		Test.startTest();
		extractedList = CMN_UTIL_System.extractListFromMap(testMap);
		Test.stopTest();
		System.assertEquals(extractedList.isEmpty(), false, 'List should not be empty');
		System.assertEquals(testMap.get(testStringKey).size(), extractedList.size(), 'Objects should be equals');
	}

	/**
	 * @description Method to test extractListFromMap with String as key
	 */
	@IsTest
	private static void extractListFromIdMap()
	{
		Id key = CMN_DAL_DataFactory.newFoobar().Id;

		List<CMN_Foobar__c> itemsList = new List<CMN_Foobar__c>
		{
				CMN_DAL_DataFactory.newFoobar(),
				CMN_DAL_DataFactory.newFoobar(),
				CMN_DAL_DataFactory.newFoobar()
		};

		Map<Id, List<CMN_Foobar__c>> testMap = new Map<Id, List<CMN_Foobar__c> >();

		testMap.put(key, itemsList);
		List<CMN_Foobar__c> extractedList = new List<CMN_Foobar__c>();
		Test.startTest();
		extractedList = CMN_UTIL_System.extractListFromMap(testMap);
		Test.stopTest();
		System.assertEquals(extractedList.isEmpty(), false, 'List should not be empty');
		System.assertEquals(testMap.get(key).size(), extractedList.size(), 'Objects should be equals');
	}

	/**
	 * @description This method is use to test the converted string
	 */
	@IsTest
	private static void convertListToStringMap()
	{
		List<Account> newAccounts = new List<Account>();
		Integer listSize = 3;

		for(Integer i = 0; i < listSize; i++)
		{
			Account newAccount = CMN_DAL_DataFactory.newBusinessAccount();
			newAccounts.add(newAccount);
		}

		CMN_DAL_SObjectDomain.insertDBObjects(newAccounts);

		Map<String, List<SObject>> objectListMap;

		Test.startTest();

		objectListMap = CMN_UTIL_System.convertListToStringMap(newAccounts, CMN_DAL_SObjectDomain.FIELD_NAME);

		Test.stopTest();

		System.assertNotEquals(null, objectListMap, ERROR_NO_MAP_RETURNED);
		System.assertEquals(listSize, objectListMap.keySet().size(), ERROR_MAP_RETURNED_OF_WRONG_SIZE + objectListMap.keySet().size());

		for(Account newAccount : newAccounts)
		{
			System.assertNotEquals(null, objectListMap.get(newAccount.Name), 'Object List is null for Account Name: ' + newAccount.Name);
			System.assert(!objectListMap.get(newAccount.Name).isEmpty(), 'Object List is empty for Account Name: ' + newAccount.Name);
			System.assertEquals(1, objectListMap.get(newAccount.Name).size(), 'Object List is wrong size for Account Name: ' + newAccount.Name);
			System.assertEquals(newAccount.Name, ((Account)objectListMap.get(newAccount.Name)[0]).Name, 'Account Name "' + newAccount.Name + '" not under correct key');
		}
	}

	/**
	 * @description This method is use to test the converted string
	 */
	@IsTest
	private static void convertListToSingleStringMap()
	{
		List<Account> newAccounts = new List<Account>();
		Integer listSize = 3;

		for(Integer i = 0; i < listSize; i++)
		{
			Account newAccount = CMN_DAL_DataFactory.newBusinessAccount();
			newAccounts.add(newAccount);
		}

		CMN_DAL_SObjectDomain.insertDBObjects(newAccounts);

		Map<String, SObject> objectMap;

		Test.startTest();

		objectMap = CMN_UTIL_System.convertListToSingleStringMap(newAccounts, CMN_DAL_SObjectDomain.FIELD_NAME);

		Test.stopTest();

		System.assertNotEquals(null, objectMap, ERROR_NO_MAP_RETURNED);
		System.assertEquals(listSize, objectMap.keySet().size(), ERROR_MAP_RETURNED_OF_WRONG_SIZE + objectMap.keySet().size());

		for(Account newAccount : newAccounts)
		{
			System.assertNotEquals(null, objectMap.get(newAccount.Name), 'Object is null for Account Name: ' + newAccount.Name);
			System.assertEquals(newAccount.Name, ((Account)objectMap.get(newAccount.Name)).Name, 'Account Name "' + newAccount.Name + '" not under correct key');
		}
	}

	/**
	 * @description convertListToSingleUpperStringMap method to get a map of uppercase key and sObject
	 * for the list of sObject provided
	 */
	@IsTest
	private static void convertListToSingleUpperStringMap()
	{
		List<Account> newAccounts = new List<Account>();
		Integer listSize = 3;

		for(Integer i = 0; i < listSize; i++)
		{
			Account newAccount = CMN_DAL_DataFactory.newBusinessAccount();
			newAccounts.add(newAccount);
		}

		CMN_DAL_SObjectDomain.insertDBObjects(newAccounts);

		Map<String, SObject> objectMap;

		Test.startTest();

		objectMap = CMN_UTIL_System.convertListToSingleUpperStringMap(newAccounts, CMN_DAL_SObjectDomain.FIELD_NAME);

		Test.stopTest();

		System.assertNotEquals(null, objectMap, ERROR_NO_MAP_RETURNED);
		System.assertEquals(listSize, objectMap.keySet().size(), ERROR_MAP_RETURNED_OF_WRONG_SIZE + objectMap.keySet().size());

		for(Account newAccount : newAccounts)
		{
			System.assertNotEquals(null, objectMap.get(newAccount.Name.toUpperCase()), 'Object is null for Account Name: ' + newAccount.Name);
			System.assertEquals(newAccount.Name, ((Account)objectMap.get(newAccount.Name.toUpperCase())).Name, 'Account Name "' + newAccount.Name +
					'" not under correct key');
		}
	}

	/**
	 * @description Will test getting a list of pick list entries from an SObject field, this will have the key of the map being the label
	 *
	 * @see CMN_UTIL_System.getPicklistEntriesMap
	 */
	@IsTest
	private static void getPicklistEntriesMapByLabel()
	{
		Test.startTest();

		Map<String, String> entriesMap = CMN_UTIL_System.getPicklistEntriesMap(CMN_Foobar__c.SObjectType, CMN_DAL_Foobar.FIELD_PICKLIST);

		Test.stopTest();

		Assert.isFalse(entriesMap.isEmpty(), ERROR_MAP_RETURNED_OF_WRONG_SIZE);

		PicklistEntry foundEntry = CMN_UTIL_System.getPicklistEntries(CMN_Foobar__c.SObjectType, CMN_DAL_Foobar.FIELD_PICKLIST).iterator().next();
		Assert.isTrue(entriesMap.containsKey(foundEntry.label), 'Label Key was not found in map');
	}

	/**
	 * @description Will test getting a list of pick list entries from an SObject field, this will have the key of the map being the value
	 *
	 * @see CMN_UTIL_System.getPicklistEntriesMap
	 */
	@IsTest
	private static void getPicklistEntriesMapByValue()
	{
		Test.startTest();

		Map<String, String> entriesMap = CMN_UTIL_System.getPicklistEntriesMap(CMN_Foobar__c.SObjectType, CMN_DAL_Foobar.FIELD_PICKLIST, false);

		Test.stopTest();

		Assert.isFalse(entriesMap.isEmpty(), ERROR_MAP_RETURNED_OF_WRONG_SIZE);
		PicklistEntry foundEntry = CMN_UTIL_System.getPicklistEntries(CMN_Foobar__c.SObjectType, CMN_DAL_Foobar.FIELD_PICKLIST).iterator().next();
		Assert.isTrue(entriesMap.containsKey(foundEntry.value), 'Value Key was not found in map');
	}

	/**
	 * @description Will test utility method getPicklistValue
	 */
	@IsTest
	private static void getPicklistValue()
	{
		Test.startTest();

		String picklistValue = CMN_UTIL_System.getPicklistValue(CMN_Foobar__c.SObjectType, 'CMN_Picklist__c', 'Hot');

		Test.stopTest();

		System.assertEquals('Hot', picklistValue, 'Incorrect Picklist Value');
	}

	/**
	 * @description This method is use to test the pick list entries of SObject from list
	 */
	@IsTest
	private static void testPickListEntriesList()
	{
		CMN_DAL_DataFactory.insertBusinessAccount();

		Test.startTest();

		List<Schema.PicklistEntry> pickListEntries =
				CMN_UTIL_System.getPicklistEntries(Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName(), Account.AccountSource.getDescribe().getLocalName());

		Test.stopTest();

		System.assertEquals(false, pickListEntries.isEmpty());
	}

	/**
	 * @description This method is use to test the list from set
	 */
	@IsTest
	private static void testSetToList()
	{
		Set<Id> initIdsSet = null;
		Set<String> initStringSet = null;

		List<Id> resultIdsList;
		List<String> resultStringList;

		Test.startTest();

		resultIdsList = CMN_UTIL_System.setToList(initIdsSet);
		System.assertEquals(null, resultIdsList, 'Ids should be null now');

		resultStringList = CMN_UTIL_System.setToList(initStringSet);
		System.assertEquals(null, resultStringList, 'Strings should be null now');

		resultStringList = CMN_UTIL_System.setToList(new Set<String> {'a', 'b', 'c', ''});
		System.assertEquals(4, resultStringList.size(), 'String list size does not match');

		Test.stopTest();
	}

	/**
	 * @description Will test conversion of Id set to a String set
	 */
	@IsTest
	private static void convertIdSetToStringSet()
	{
		Set<Id> idSet = new Set<Id>
		{
				CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType),
				CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType),
				CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType),
				CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType),
				null
		};

		Test.startTest();

		Set<String> stringSet = CMN_UTIL_System.convertIdSetToStringSet(idSet);

		Test.stopTest();

		System.assertEquals(idSet.size() - 1, stringSet.size(), 'Set not converted correctly');

	}

	/**
	 * @description This method is use to test the  system expressions
	 */
	@IsTest
	private static void testSystemThrow()
	{
		String errorMessage = 'myTestThrow';

		Boolean exceptionThrown = false;

		Test.startTest();

		try
		{
			CMN_UTIL_System.justThrow();
		}
		catch(Exception e)
		{
			exceptionThrown = true;
		}

		System.assertEquals(exceptionThrown, true, 'justThrow() not thrown');
		exceptionThrown = false;

		try
		{
			CMN_UTIL_System.justThrow(errorMessage);
		}
		catch(Exception e)
		{
			Boolean expectedExceptionThrown = e.getMessage().contains(errorMessage);
			System.assertEquals(expectedExceptionThrown, true);
			exceptionThrown = true;
		}

		System.assertEquals(exceptionThrown, true, 'justThrow(msg) not thrown');
		exceptionThrown = false;

		Test.stopTest();
	}

	@IsTest
	private static void testTrimStringSet()
	{
		Set<String> result;

		Test.startTest();

		result = CMN_UTIL_System.trimSet(new Set<String> {'', '', NOT_EMPTY, ' ', 'full', NOT_BLANK});

		Test.stopTest();
		System.assertEquals(3, result.size(), 'result size is ' + result.size());
	}

	/**
	 * @description Will test the behaviour of the associated method
	 *
	 * @see CMN_UTIL_System.trimList
	 */
	@IsTest
	private static void trimList()
	{
		List<String> result;

		Test.startTest();

		result = CMN_UTIL_System.trimList(new List<String> {CMN_UTIL_String.EMPTY, null, NOT_EMPTY, CMN_UTIL_String.SPACE, 'full', NOT_BLANK});

		Test.stopTest();

		Assert.areEqual(3, result.size(), 'result size is ' + result.size());
	}

	/**
	 * @description This method is use to test the set value converted from string
	 */
	@IsTest
	private static void testConvertStringToSet()
	{
		Test.startTest();

		Set<String> aSet = CMN_UTIL_System.convertStringToSet('abc; 555; a b; 555;,', ';');

		Test.stopTest();

		System.assertEquals(4, aSet.size(), 'Invalid number of set items.');
	}

	/**
	 * @description This method is use to test the list value converted from string
	 */
	@IsTest
	private static void testConvertStringToList()
	{
		Test.startTest();

		List<String> aList = CMN_UTIL_System.convertStringToList('abc; 555; a b; 555;,', ';');

		Test.stopTest();

		System.assertEquals(5, aList.size(), 'Invalid number of list items.');
	}

	/**
	 * @description Tests utility function to return a Random Item from an SObject list
	 * It will also test the getRandomIndex method as this is used by getRandomItem
	 *
	 * @see CMN_UTIL_System.getRandomIndex
	 * @see CMN_UTIL_System.getRandomItem
	 */
	@IsTest
	private static void getRandomItem()
	{
		List<Account> accounts = new List<Account>();

		for(Integer i = 0; i < NUMBER_OF_ACCOUNTS_TO_CREATE; i++)
		{
			accounts.add(CMN_DAL_DataFactory.newBusinessAccount());
		}

		Test.startTest();

		Account account1 = (Account)CMN_UTIL_System.getRandomItem(accounts);
		Account account2 = (Account)CMN_UTIL_System.getRandomItem(accounts);

		Test.stopTest();

		System.assertNotEquals(account1.Name, account2.Name, 'Same items was retrieved, instead of Random ones');
	}

	/**
	 * @description Test splitting of an object list
	 *
	 * @see CMN_UTIL_System.splitSObjects
	 */
	@IsTest
	private static void splitSObjects()
	{
		List<SObject> foobars = (List<SObject>)CMN_DAL_DataFactory.newFoobars(NUMBER_OF_ACCOUNTS_TO_CREATE);

		Test.startTest();

		List<List<SObject>> splitAll = CMN_UTIL_System.splitSObjects(foobars, NUMBER_OF_ACCOUNTS_TO_CREATE);
		List<List<SObject>> splitTwo = CMN_UTIL_System.splitSObjects(foobars, NUMBER_OF_ACCOUNTS_TO_CREATE / 2);
		List<List<SObject>> splitTwenty = CMN_UTIL_System.splitSObjects(foobars, NUMBER_OF_ACCOUNTS_TO_CREATE / 20);

		Test.stopTest();

		Assert.areEqual(1, splitAll.size(), ERROR_SPLIT_SIZE_INVALID);
		Assert.areEqual(2, splitTwo.size(), ERROR_SPLIT_SIZE_INVALID);
		Assert.areEqual(20, splitTwenty.size(), ERROR_SPLIT_SIZE_INVALID);
	}

	/**
 * @description Test splitting of an object list
 *
 * @see CMN_UTIL_System.splitObjects
 */
	@IsTest
	private static void splitObjects()
	{
		List<Object> foobars = CMN_DAL_DataFactory.newFoobars(NUMBER_OF_ACCOUNTS_TO_CREATE);

		Test.startTest();

		List<List<Object>> splitAll = CMN_UTIL_System.splitObjects(foobars, NUMBER_OF_ACCOUNTS_TO_CREATE);
		List<List<Object>> splitTwo = CMN_UTIL_System.splitObjects(foobars, NUMBER_OF_ACCOUNTS_TO_CREATE / 2);
		List<List<Object>> splitTwenty = CMN_UTIL_System.splitObjects(foobars, NUMBER_OF_ACCOUNTS_TO_CREATE / 20);

		Test.stopTest();

		Assert.areEqual(1, splitAll.size(), ERROR_SPLIT_SIZE_INVALID);
		Assert.areEqual(2, splitTwo.size(), ERROR_SPLIT_SIZE_INVALID);
		Assert.areEqual(20, splitTwenty.size(), ERROR_SPLIT_SIZE_INVALID);
	}

	/**
	 * @description Makes sure the function to check if an object field name is valid is working
	 */
	@IsTest
	private static void isValidObjectFieldName()
	{
		String objectName = Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
		String fieldName = 'Contact.Account.Owner.Name';

		Test.startTest();

		Boolean isValid = CMN_UTIL_System.isValidObjectFieldName(objectName, fieldName);

		Test.stopTest();

		System.assertEquals(true, isValid, 'Field not identified as being valid');
	}

	/**
	 * @description Makes sure the function to check if an object field name is valid is working
	 */
	@IsTest
	private static void isInvalidFieldObjectName()
	{
		String objectName = 'Invalid';
		String fieldName = CMN_Foobar__c.CMN_Datetime__c.getDescribe().getLocalName();

		Test.startTest();

		Boolean isValid = CMN_UTIL_System.isValidObjectFieldName(objectName, fieldName);

		Test.stopTest();

		System.assertEquals(false, isValid, ERROR_FIELD_NOT_INVALID);
	}

	/**
	 * @description Makes sure the function to check if an object field name is valid is working
	 */
	@IsTest
	private static void isInvalidFieldName()
	{
		String objectName = CMN_Foobar__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
		String fieldName = CMN_Foobar__c.CMN_Datetime__c.getDescribe().label;

		Test.startTest();

		Boolean isValid = CMN_UTIL_System.isValidObjectFieldName(objectName, fieldName);

		Test.stopTest();

		System.assertEquals(false, isValid, ERROR_FIELD_NOT_INVALID);
	}

	/**
	 * @description Makes sure the function to check if an object relationship field name is invalid
	 */
	@IsTest
	private static void isInvalidRelationshipFieldName()
	{
		String objectName = CMN_Foobar__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
		String fieldName = 'InvalidRelationship__r.Name'; //This covers part of function where it checks for relationship and replaces __r

		Test.startTest();

		Boolean isValid = CMN_UTIL_System.isValidObjectFieldName(objectName, fieldName);

		Test.stopTest();

		System.assertEquals(false, isValid, ERROR_FIELD_NOT_INVALID);
	}

	/**
	 * @description Makes sure the function to check if an object field name is valid is working
	 */
	@IsTest
	private static void isBlankFieldName()
	{
		String objectName = CMN_Foobar__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
		String fieldName = CMN_UTIL_String.EMPTY;

		Test.startTest();

		Boolean isValid = CMN_UTIL_System.isValidObjectFieldName(objectName, fieldName);

		Test.stopTest();

		System.assertEquals(false, isValid, ERROR_FIELD_NOT_INVALID);
	}

	/**
	 * @description Makes sure that a multipart field name get be parsed an used to read data of an SObject returned from a query
	 */
	@IsTest
	private static void getFieldValue()
	{
		String fieldToQuery = 'Contact.Account.LastModifiedBy.Profile.Id';

		Account newAccount = CMN_DAL_DataFactory.insertBusinessAccount();
		Contact newContact = CMN_DAL_DataFactory.newContact();
		newContact.AccountId = newAccount.Id;
		insert newContact;

		Case newCase = CMN_DAL_DataFactory.newCase(newContact.Id);
		insert newCase;

		//Now retrieve the Account with a complex lookup multipart field
		newCase = (Case)CMN_DAL_SObjectSelector.findById(Case.SObjectType, newCase.Id, new Set<String>
		{
				fieldToQuery
		});

		Test.startTest();

		Object fieldValue = CMN_UTIL_System.getFieldValue(newCase, fieldToQuery);

		Test.stopTest();

		User currentUser = CMN_DAL_User.getCurrentUser();
		System.assertEquals(currentUser.ProfileId, fieldValue, 'Incorrect value returned');
	}

	/**
	 * @description Make sure that the method to retrieve an Object and Field queried using multipart field is correct
	 */
	@IsTest
	private static void getObjectAndField()
	{
		String fieldToQuery = 'Contact.Account.LastModifiedBy.Profile.Id';

		Account newAccount = CMN_DAL_DataFactory.insertBusinessAccount();
		Contact newContact = CMN_DAL_DataFactory.newContact();
		newContact.AccountId = newAccount.Id;

		insert newContact;

		Case newCase = CMN_DAL_DataFactory.newCase(newContact.Id);
		insert newCase;

		//Now retrieve the Account with a complex lookup multipart field
		newCase = (Case)CMN_DAL_SObjectSelector.findById(Case.SObjectType, newCase.Id, new Set<String> {fieldToQuery});

		Test.startTest();

		CMN_UTIL_System.ObjectFieldInformation result = CMN_UTIL_System.getObjectAndFieldInformation(newCase, fieldToQuery);

		Test.stopTest();

		System.assertNotEquals(null, result.objectReference, 'No Object Returned');
		System.assertNotEquals(null, result.objectField, 'No Field Returned');
		System.assertEquals(CMN_DAL_Profile.OBJECT_NAME, result.objectReference.getSObjectType().getDescribe().getLocalName(), 'Incorrect Object Found');
		System.assertEquals(CMN_DAL_SObjectDomain.FIELD_ID, result.objectField.getDescribe().getLocalName(), 'Incorrect Field Found');
	}

	/**
	 * @description Checks that the getObjectFieldReferenceMap method returns valid reference fields for an object
	 */
	@IsTest
	private static void getObjectFieldReferenceMap()
	{
		Test.startTest();

		Map<String, SObjectField> fieldMap = CMN_UTIL_System.getObjectFieldReferenceMap(CMN_DAL_Contact.OBJECT_NAME);

		Test.stopTest();

		System.assertEquals(true, fieldMap.containsKey(CMN_DAL_Account.OBJECT_NAME), 'Reference field missing');
	}

	/**
	 * @description Checks that nestable field name retrieval works as expected
	 *
	 * @see CMN_UTIL_System.getNestableFieldNames
	 */
	@IsTest
	private static void getNestableFieldNamesOneLevel()
	{
		Test.startTest();

		Set<String> fields = CMN_UTIL_System.getNestableFieldNames(CMN_Foobar__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName());

		Test.stopTest();

		Assert.isTrue(fields.contains('RecordType.DeveloperName'), 'Fields not retrieved correctly');
	}

	/**
	 * @description Checks that nestable field name retrieval works as expected
	 *
	 * @see CMN_UTIL_System.getNestableFieldNames
	 */
	@IsTest
	private static void getNestableFieldNamesMultipleLevels()
	{
		Test.startTest();

		Set<String> fields = CMN_UTIL_System.getNestableFieldNames(CMN_DAL_Foobar.OBJECT_NAME, CMN_UTIL_System.MAX_NESTED_LEVELS);

		Test.stopTest();

		String comparisonString = CMN_UTIL_String.EMPTY;
		for(Integer i = 0; i < CMN_UTIL_System.MAX_NESTED_LEVELS; i++)
		{
			String customFieldName = CMN_Foobar__c.CMN_Lookup__c.getDescribe().getName();
			String relationshipFieldName = CMN_UTIL_String.replace(customFieldName, CMN_UTIL_System.CUSTOM_FIELD_SUFFIX, CMN_UTIL_System.RELATIONSHIP_SUFFIX);
			comparisonString += relationshipFieldName + CMN_UTIL_String.DOT;
		}
		comparisonString += CMN_DAL_SObjectDomain.FIELD_NAME;

		Assert.isTrue(fields.contains(comparisonString), 'Fields not retrieved correctly');
	}

	private static void assertTo18(String the15charID, String expected)
	{
		String actual = CMN_UTIL_System.to18(the15charID);
		System.assert(actual == expected, 'CMN_UTIL_System.to18(\'' + the15charID + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@SuppressWarnings('PMD.AvoidHardcodingId')
	@IsTest
	private static void testTo18()
	{
		assertTo18('a0BA0000000L2Z', 'a0BA0000000L2Z');
		assertTo18('a0BA0000000L2ZC', 'a0BA0000000L2ZCMA0');
	}

	/**
	 * @description Will test the method fails as expected when trying to retrieve an Object Describe
	 *
	 * @see CMN_UTIL_System.getObjectResult
	 */
	@IsTest
	public static void getObjectResultWithInvalidApiName()
	{
		try
		{
			CMN_UTIL_System.getObjectResult(CMN_DAL_SObjectDomain.generateRandomName());
			System.assert(false, 'Exception was not thrown as expected');

		}
		catch(InvalidParameterValueException error)
		{
			System.assert(true, 'Exception was thrown as expected');
		}
	}

	@IsTest
	public static void testGetPicklistValues()
	{
		List<String> returned = CMN_UTIL_System.getPicklistValues('CMN_Foobar__c', 'CMN_Picklist__c');
		System.assert(!returned.isEmpty());
	}

	/**
	 * @description Example class for testing the retrieval of types
	 */
	public class ExampleClass
	{
	}

	/**
	 * @description Apex.getRunningType() returns running type of the object instance.
	 */
	@IsTest
	static void getRunningType()
	{
		ExampleClass instance = new ExampleClass();
		System.assertEquals(ExampleClass.class, CMN_UTIL_System.getType(instance), 'Invalid Type returned.');
	}

	@IsTest
	static void getDatesRunningType()
	{
		Date instance = Date.today();
		System.assertEquals(Date.class, CMN_UTIL_System.getType(instance), 'Invalid Type returned.');
	}

	/**
	 * @description Apex.getRunningType() returns name of running type of the object instance.
	 */
	@IsTest
	static void getRunningTypeName()
	{
		ExampleClass instance = new ExampleClass();
		System.assertEquals('CMN_UTIL_System_TEST.ExampleClass', CMN_UTIL_System.getTypeName(instance), 'Invalid Type Name returned');
	}

	/**
	 * @description Apex.getListItemType() returns type of elements in given list
	 */
	@IsTest
	static void getListItemType()
	{
		System.assertEquals(Account.class, CMN_UTIL_System.getListItemType(new List<Account>()), 'Invalid Type returned.');
	}

	/**
	 * @description Apex.getRunningType() returns name of running type of the object instance.
	 */
	@IsTest
	static void getNullRunningTypeName()
	{
		try
		{
			ExampleClass instance = null;
			CMN_UTIL_System.getTypeName(instance, '<', '/>');
			System.assert(false, 'Exception not thrown as expected');
		}
		catch(NullPointerException e)
		{
			System.assertEquals(e.getMessage(), 'Script-thrown exception', 'Incorrect exception raised');
		}
	}

	/**
	 * @description This method is used to test the shuffleList method
	 */
	@IsTest
	private static void shuffleList()
	{
		List<Account> accounts = new List<Account>();

		for(Integer i = 0; i < NUMBER_OF_ACCOUNTS_TO_CREATE; i++)
		{
			Account newAccount = CMN_DAL_DataFactory.newBusinessAccount();
			newAccount.Id = CMN_UTIL_Random.randomSObjectId(Account.SObjectType);
			accounts.add(newAccount);
		}

		List<Account> shuffledAccounts = accounts.clone();

		Test.startTest();

		CMN_UTIL_System.shuffleList(shuffledAccounts);

		Test.stopTest();

		Boolean isOrderSame = true;
		for(Integer i = 0; i < accounts.size(); i++)
		{
			if(!accounts.get(i).Id.equals(shuffledAccounts.get(i).Id))
			{
				isOrderSame = false;
				break;
			}
		}

		System.assertEquals(false, isOrderSame, 'List not shuffled');
	}

	/**
	 * @description Will check that session Id is returned for method below
	 *
	 * @see CMN_UTIL_System.getApiEnabledSessionId
	 */
	@IsTest
	private static void getApiEnabledSessionId()
	{
		Test.startTest();

		String sessionId = CMN_UTIL_System.getApiEnabledSessionId();

		Test.stopTest();

		Assert.isTrue(String.isNotBlank(sessionId), 'Session Id not retrieved');
	}
}