/**
 * @description test class for CMN_UTIL_Logger
 *
 * @see CMN_UTIL_Logger adapted from https://github.com/mlockett/ApexLogger
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date 15 January 2019, July 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_UTIL_Logger_TEST
{
	private static final String MESSAGE = CMN_DAL_SObjectDomain.generateRandomName();
	private static final List<String> MESSAGES = new List<String> {MESSAGE, CMN_DAL_SObjectDomain.generateRandomName()};
	private static final String CLASS_METHOD = 'foo/method';
	private static final String RECORD_ID = CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType);

	@IsTest
	private static void infoWritesCorrectValues()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		CMN_UTIL_Logger.info(MESSAGE, CLASS_METHOD);

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

		System.assertEquals(MESSAGE, appLog.CMN_Message__c);
		System.assertEquals(CMN_DAL_Logger.LEVEL_INFO, appLog.CMN_LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@IsTest
	private static void infoMultipleWritesCorrectValues()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		CMN_UTIL_Logger.info(MESSAGES, CLASS_METHOD);

		Test.stopTest();

		List<CMN_AppLog__c> appLogs = CMN_DAL_AppLog.findAllByMethod(CLASS_METHOD);

		System.assertEquals(MESSAGES.size(), appLogs.size(), 'Incorrect Number of Logs written');

		CMN_AppLog__c appLog = appLogs.iterator().next();
		System.assertEquals(CMN_DAL_Logger.LEVEL_INFO, appLog.CMN_LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@IsTest
	private static void debugWritesCorrectValues()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		CMN_UTIL_Logger.debug(MESSAGE, CLASS_METHOD);

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

		System.assertEquals(MESSAGE, appLog.CMN_Message__c);
		System.assertEquals(CMN_DAL_Logger.LEVEL_DEBUG, appLog.CMN_LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@IsTest
	private static void debugMultipleWritesCorrectValues()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		CMN_UTIL_Logger.debug(MESSAGES, CLASS_METHOD);

		Test.stopTest();

		List<CMN_AppLog__c> appLogs = CMN_DAL_AppLog.findAllByMethod(CLASS_METHOD);

		System.assertEquals(MESSAGES.size(), appLogs.size(), 'Incorrect Number of Logs written');

		CMN_AppLog__c appLog = appLogs.iterator().next();
		System.assertEquals(CMN_DAL_Logger.LEVEL_DEBUG, appLog.CMN_LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@IsTest
	private static void debugWithIdWritesCorrectValues()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		CMN_UTIL_Logger.debug(MESSAGE, CLASS_METHOD, RECORD_ID);

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

		System.assertEquals(MESSAGE, appLog.CMN_Message__c);
		System.assertEquals(CMN_DAL_Logger.LEVEL_DEBUG, appLog.CMN_LogLevel__c);
		System.assertEquals(RECORD_ID, appLog.CMN_RecordId__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@IsTest
	private static void warnWritesCorrectValues()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		CMN_UTIL_Logger.warn(MESSAGE, CLASS_METHOD);

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

		System.assertEquals(MESSAGE, appLog.CMN_Message__c);
		System.assertEquals(CMN_DAL_Logger.LEVEL_WARN, appLog.CMN_LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@IsTest
	private static void warnMultipleWritesCorrectValues()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		CMN_UTIL_Logger.warn(MESSAGES, CLASS_METHOD);

		Test.stopTest();

		List<CMN_AppLog__c> appLogs = CMN_DAL_AppLog.findAllByMethod(CLASS_METHOD);

		System.assertEquals(MESSAGES.size(), appLogs.size(), 'Incorrect Number of Logs written');

		CMN_AppLog__c appLog = appLogs.iterator().next();
		System.assertEquals(CMN_DAL_Logger.LEVEL_WARN, appLog.CMN_LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@IsTest
	private static void warnWithIdWritesCorrectValues()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		CMN_UTIL_Logger.warn(MESSAGE, CLASS_METHOD, RECORD_ID);

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

		System.assertEquals(MESSAGE, appLog.CMN_Message__c);
		System.assertEquals(CMN_DAL_Logger.LEVEL_WARN, appLog.CMN_LogLevel__c);
		System.assertEquals(RECORD_ID, appLog.CMN_RecordId__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@IsTest
	private static void errorWritesCorrectValues()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		CMN_UTIL_Logger.error(MESSAGE, CLASS_METHOD);

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

		System.assertEquals(MESSAGE, appLog.CMN_Message__c);
		System.assertEquals(CMN_DAL_Logger.LEVEL_ERROR, appLog.CMN_LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@IsTest
	private static void errorMultipleWritesCorrectValues()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		CMN_UTIL_Logger.error(MESSAGES, CLASS_METHOD);

		Test.stopTest();

		List<CMN_AppLog__c> appLogs = CMN_DAL_AppLog.findAllByMethod(CLASS_METHOD);

		System.assertEquals(MESSAGES.size(), appLogs.size(), 'Incorrect Number of Logs written');

		CMN_AppLog__c appLog = appLogs.iterator().next();
		System.assertEquals(CMN_DAL_Logger.LEVEL_ERROR, appLog.CMN_LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@IsTest
	@SuppressWarnings('PMD.UnusedLocalVariable,ApexUnusedDeclaration')
	private static void errorWritesCorrectValuesForException()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		try
		{
			Double badNumber = 1 / 0; // force MathException
		}
		catch(Exception ex)
		{
			CMN_UTIL_Logger.error(ex, CLASS_METHOD);
		}

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

		System.assert(appLog.CMN_ExceptionType__c.equals(System.MathException.class.getName()));
		System.assertEquals(CMN_DAL_Logger.LEVEL_ERROR, appLog.CMN_LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

	@IsTest
	@SuppressWarnings('PMD.UnusedLocalVariable,ApexUnusedDeclaration')
	private static void errorWithIdWritesCorrectValuesForException()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();
		try
		{
			Double badNumber = 1 / 0; // force MathException
		}
		catch(Exception ex)
		{
			CMN_UTIL_Logger.error(ex, CLASS_METHOD, RECORD_ID);
		}

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

		System.assert(appLog.CMN_ExceptionType__c.equals(System.MathException.class.getName()));
		System.assertEquals(RECORD_ID, appLog.CMN_RecordId__c);
		System.assertEquals(CMN_DAL_Logger.LEVEL_ERROR, appLog.CMN_LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
	}

}