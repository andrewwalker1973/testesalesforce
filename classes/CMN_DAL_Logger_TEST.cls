/**
 * @description Tests the behaviour of the logger
 *
 * @see CMN_DAL_Logger adapted from https://github.com/mlockett/ApexLogger
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date June 2022, July 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_DAL_Logger_TEST
{
	private static final Integer SOQL_QUERY_LIMIT = Limits.getLimitPublishImmediateDML();
	private static final Integer RECORDS_TO_INSERT = SOQL_QUERY_LIMIT - 1;
	private static final String CLASS_METHOD = 'CMN_Foobar/method';
	private static final String MESSAGE = CMN_DAL_SObjectDomain.generateRandomName();
	private static final String RECORD_ID = CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType);

	/**
	 * @description Create test data
	 */
	private static void testSetup()
	{
		CMN_DAL_Logger.testUserFilters = new List<CMN_LogUserFilter__mdt>();

		CMN_LogUserFilter__mdt filter = new CMN_LogUserFilter__mdt();

		filter.CMN_LogLevel__c = CMN_DAL_Logger.ALL_LOG_LEVELS;
		filter.CMN_UserType__c = CMN_DAL_Logger.TYPE_ALL_USERS;
		filter.CMN_LogUser__c = CMN_DAL_Logger.ALL_USERS;
		filter.CMN_Active__c = true;

		CMN_DAL_Logger.testUserFilters.add(filter);
	}

	/**
	 * @description verifies that determining ability to log does not throw when test recordFilters are not supplied
	 */
	@IsTest
	private static void canQueryForLoggable()
	{
		// clear test values
		CMN_DAL_Logger.testUserFilters = null;
		try
		{
			Test.startTest();

			CMN_DAL_Logger.isLoggable(LoggingLevel.DEBUG);

			Test.stopTest();

			System.assert(true, 'No exception was thrown as expected');
		}
		catch(Exception error)
		{
			System.assert(false, 'Exception was thrown.');
		}
	}

	@IsTest
	private static void filtersLogRecordCorrectly()
	{
		testSetup();

		CMN_DAL_Logger.testUserFilters.iterator().next().CMN_LogLevel__c = CMN_DAL_Logger.LEVEL_INFO + CMN_UTIL_String.COMMA + CMN_DAL_Logger.LEVEL_WARN;

		Test.startTest();

		CMN_DAL_Logger.log(MESSAGE, CLASS_METHOD, LoggingLevel.DEBUG);

		Test.stopTest();

		Integer count = CMN_DAL_AppLog.getRecordCount();

		System.assertEquals(0, count);
	}

	@IsTest
	private static void filtersLogRecordCorrectlyWithNullFilter()
	{
		testSetup();

		CMN_DAL_Logger.testUserFilters.iterator().next().CMN_LogLevel__c = null;

		Test.startTest();

		CMN_DAL_Logger.log(MESSAGE, CLASS_METHOD, LoggingLevel.DEBUG);

		Test.stopTest();

		Integer count = CMN_DAL_AppLog.getRecordCount();

		System.assertEquals(0, count);
	}

	@IsTest
	private static void verifyFilter()
	{
		testSetup();

		CMN_LogMessageFilter__mdt filter = new CMN_LogMessageFilter__mdt();

		filter.CMN_RegexToReplaceWith__c = '***-**-$3';
		filter.CMN_RegexToFind__c = '(\\d{3})-(\\d{2})-(\\d{4})';

		CMN_DAL_Logger.messageFilters = new List<CMN_LogMessageFilter__mdt>();//[filter1];
		CMN_DAL_Logger.messageFilters.add(filter);

		String textToObscure = 'Hide the 123-12-1234 SSN.';
		String expectedText = 'Hide the ***-**-1234 SSN.';

		System.assertEquals(expectedText, CMN_DAL_Logger.filterString(textToObscure));
	}

	@IsTest
	private static void logWritesCorrectValues()
	{
		testSetup();

		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		CMN_DAL_Logger.log(MESSAGE, CLASS_METHOD, LoggingLevel.WARN);

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

		System.assertEquals(MESSAGE, appLog.CMN_Message__c);
		System.assertEquals(CMN_DAL_Logger.LEVEL_WARN, appLog.CMN_LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	/**
	 * @description Check that event logging is shifted to asynchronous job
	 */
	@IsTest
	private static void logAsynchronously()
	{
		testSetup();

		CMN_DAL_Logger.ignoreTestMode = true;
		CMN_DAL_Logger.simulateDMLimitsBreach = true;

		Test.startTest();

		CMN_DAL_Logger.log(MESSAGE, CLASS_METHOD, LoggingLevel.WARN);

		System.assertEquals(1, Limits.getQueueableJobs(), 'No jobs was enqueued');

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

		System.assertEquals(MESSAGE, appLog.CMN_Message__c);
	}

	/**
	 * @description Creates an scenario where publishing log event asynchronously can't happen as we are at both DML and Queueable job limits
	 */
	@IsTest
	private static void unableToLogDueToLimits()
	{
		testSetup();

		CMN_DAL_Logger.ignoreTestMode = true;
		CMN_DAL_Logger.simulateDMLimitsBreach = true;
		CMN_DAL_Logger.simulateQueueableLimitsBreach = true;

		Test.startTest();

		CMN_DAL_Logger.log('errorDoesNotThrow_message', CLASS_METHOD, LoggingLevel.WARN);

		Test.stopTest();

		List<CMN_AppLog__c> appLogs = CMN_DAL_AppLog.findByLogLevel(CMN_DAL_Logger.LEVEL_WARN);
		System.assertEquals(0, appLogs.size(), 'No Logs should exist');

	}

	@IsTest
	private static void invocableInfoWritesCorrectValues()
	{
		testSetup();

		List<String> messages = new List<String> {'a', 'b', 'c'};
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		CMN_DAL_Logger.info(messages);

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.getAll().iterator().next();

		String expected = 'a;\nb;\nc';

		System.assertEquals(expected, appLog.CMN_Message__c);
		System.assertEquals(CMN_DAL_Logger.LEVEL_INFO, appLog.CMN_LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@SuppressWarnings('PMD.UnusedLocalVariable, ApexUnusedDeclaration')
	@IsTest
	private static void errorWritesCorrectValuesForException()
	{
		testSetup();
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();
		try
		{
			Double badNumber = 1 / 0; // force MathException
		}
		catch(Exception error)
		{
			CMN_DAL_Logger.log(error, CLASS_METHOD, LoggingLevel.ERROR);
		}

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

		System.assert(appLog.CMN_ExceptionType__c.equals('System.MathException'));
		System.assertEquals(CMN_DAL_Logger.LEVEL_ERROR, appLog.CMN_LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@SuppressWarnings('PMD.UnusedLocalVariable')
	@IsTest
	private static void errorWithIdWritesCorrectValuesForException()
	{
		testSetup();
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();
		try
		{
			//noinspection ApexUnusedDeclaration
			Double badNumber = 1 / 0; // force MathException
		}
		catch(Exception error)
		{
			CMN_DAL_Logger.log(error, CLASS_METHOD, RECORD_ID, LoggingLevel.ERROR);
		}

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

		System.assert(appLog.CMN_ExceptionType__c.equals('System.MathException'));
		System.assertEquals(CMN_DAL_Logger.LEVEL_ERROR, appLog.CMN_LogLevel__c);
		System.assertEquals(RECORD_ID, appLog.CMN_RecordId__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@SuppressWarnings('PMD.UnusedLocalVariable,ApexUnusedDeclaration')
	@IsTest
	private static void logWritesCorrectValuesForException()
	{
		testSetup();
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();
		try
		{
			Double badNumber = 1 / 0; // force MathException
		}
		catch(Exception ex)
		{
			CMN_DAL_Logger.log(ex, CLASS_METHOD, LoggingLevel.DEBUG);
		}

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

		System.assert(appLog.CMN_ExceptionType__c.equals('System.MathException'));
		System.assertEquals(CMN_DAL_Logger.LEVEL_DEBUG, appLog.CMN_LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@IsTest
	@SuppressWarnings('PMD.CognitiveComplexity')
	private static void isLoggable()
	{
		CMN_DAL_Logger.testUserFilters = new List<CMN_LogUserFilter__mdt>();

		CMN_LogUserFilter__mdt userIdFilter = new CMN_LogUserFilter__mdt();
		CMN_LogUserFilter__mdt emailFilter = new CMN_LogUserFilter__mdt();
		CMN_LogUserFilter__mdt usernameFilter = new CMN_LogUserFilter__mdt();

		// userId filter
		userIdFilter.CMN_LogLevel__c = CMN_DAL_Logger.ALL_LOG_LEVELS;
		userIdFilter.CMN_UserType__c = CMN_DAL_Logger.TYPE_USER_ID;
		userIdFilter.CMN_LogUser__c = UserInfo.getUserId();
		userIdFilter.CMN_Active__c = true;

		// email filter
		emailFilter.CMN_LogLevel__c = CMN_DAL_Logger.ALL_LOG_LEVELS;
		emailFilter.CMN_UserType__c = CMN_DAL_Logger.TYPE_EMAIL;
		emailFilter.CMN_LogUser__c = UserInfo.getUserEmail();
		emailFilter.CMN_Active__c = true;

		// username filter
		usernameFilter.CMN_LogLevel__c = CMN_DAL_Logger.ALL_LOG_LEVELS;
		usernameFilter.CMN_UserType__c = CMN_DAL_Logger.TYPE_USERNAME;
		usernameFilter.CMN_LogUser__c = UserInfo.getUserName();
		usernameFilter.CMN_Active__c = true;

		Test.startTest();

		// test user id scenarios
		CMN_DAL_Logger.testUserFilters.add(userIdFilter);

		System.assert(CMN_DAL_Logger.isLoggable(LoggingLevel.DEBUG));

		userIdFilter.CMN_LogUser__c = CMN_UTIL_Random.randomSObjectId(User.SObjectType);

		System.assert(!CMN_DAL_Logger.isLoggable(LoggingLevel.DEBUG));

		// test user email scenarios
		CMN_DAL_Logger.testUserFilters.clear();
		CMN_DAL_Logger.testUserFilters.add(emailFilter);

		System.assert(CMN_DAL_Logger.isLoggable(LoggingLevel.DEBUG));

		emailFilter.CMN_LogUser__c = CMN_DAL_SObjectDomain.generateRandomEmail();

		System.assert(!CMN_DAL_Logger.isLoggable(LoggingLevel.DEBUG));

		// test user email scenarios
		CMN_DAL_Logger.testUserFilters.clear();
		CMN_DAL_Logger.testUserFilters.add(usernameFilter);

		System.assert(CMN_DAL_Logger.isLoggable(LoggingLevel.DEBUG));

		usernameFilter.CMN_LogUser__c = CMN_DAL_SObjectDomain.generateRandomName();

		System.assert(!CMN_DAL_Logger.isLoggable(LoggingLevel.DEBUG));

		Test.stopTest();
	}

	/**
	 * @description Test the limit breach and check if records were inserted up to the limit
	 */
	@IsTest
	private static void limitFailure()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		// Insert the initial records
		CMN_DAL_DataFactory.publishLogEvents(RECORDS_TO_INSERT + 1);

		Test.stopTest();

		Integer count = CMN_DAL_AppLog.getRecordCount();

		// The above has now attempted to insert almost twice the limit, the only additional log records that should have been inserted would be to bring the
		// count up to the max limit, therefore the total records should be max limit as the logger stops inserting and starts adding debug messages when the
		// limit is breached.
		System.assertEquals(SOQL_QUERY_LIMIT, count, 'Incorrect number of items inserted');
	}

	/**
	 * @description Test the successful insertion of N records
	 */
	@IsTest
	private static void limitSuccess()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		CMN_DAL_DataFactory.publishLogEvents(RECORDS_TO_INSERT);

		Test.stopTest();

		// Assert that the initial records were inserted (Less than limit)
		Integer count = CMN_DAL_AppLog.getRecordCount();

		System.assertEquals(RECORDS_TO_INSERT, count, 'Incorrect number of items inserted');
	}
}