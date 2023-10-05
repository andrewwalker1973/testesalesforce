/**
 * @description Class allow logging at an instance level
 *
 * @see CMN_UTIL_Logger_TEST
 *
 * @author originally adapted from https://github.com/mlockett/ApexLogger jason.van.beukering@accenture.com
 *
 * @date 15 January 2019, July 2023
 */
public inherited sharing class CMN_UTIL_Logger
{
	/**
	 * @description writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>/<method> if applicable
	 */
	public static void debug(String message, String classMethod)
	{
		CMN_DAL_Logger.log(message, classMethod, LoggingLevel.DEBUG);
	}

	/**
	 * @description writes a log for every message
	 *
	 * @param messages message to be logged
	 * @param classMethod <class>/<method> if applicable
	 */
	public static void debug(List<String> messages, String classMethod)
	{
		CMN_DAL_Logger.log(messages, classMethod, LoggingLevel.DEBUG);
	}

	/**
	 * @description writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 */
	public static void debug(String message, String classMethod, String affectedId)
	{
		CMN_DAL_Logger.log(message, classMethod, affectedId, LoggingLevel.DEBUG);
	}

	/**
	 * @description writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>/<method> if applicable
	 */
	public static void info(String message, String classMethod)
	{
		CMN_DAL_Logger.log(message, classMethod, LoggingLevel.INFO);
	}

	/**
	 * @description writes a log for every message
	 *
	 * @param messages message to be logged
	 * @param classMethod <class>/<method> if applicable
	 */
	public static void info(List<String> messages, String classMethod)
	{
		CMN_DAL_Logger.log(messages, classMethod, LoggingLevel.INFO);
	}

	/**
	 * @description writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>/<method> if applicable
	 */
	public static void warn(String message, String classMethod)
	{
		CMN_DAL_Logger.log(message, classMethod, LoggingLevel.WARN);
	}

	/**
	 * @description writes a log for every message
	 *
	 * @param messages message to be logged
	 * @param classMethod <class>/<method> if applicable
	 */
	public static void warn(List<String> messages, String classMethod)
	{
		CMN_DAL_Logger.log(messages, classMethod, LoggingLevel.WARN);
	}

	/**
	 * @description writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 */
	public static void warn(String message, String classMethod, String affectedId)
	{
		CMN_DAL_Logger.log(message, classMethod, affectedId, LoggingLevel.WARN);
	}

	/**
	 * @description Write error with exception data
	 *
	 * @param ex exception to log
	 * @param classMethod <class>.<method> if applicable
	 */
	public static void error(Exception ex, String classMethod)
	{
		CMN_DAL_Logger.log(ex, classMethod, LoggingLevel.ERROR);
	}

	/**
	 * @description Write error with exception data
	 *
	 * @param ex exception to log
	 * @param classMethod <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 */
	public static void error(Exception ex, String classMethod, String affectedId)
	{
		CMN_DAL_Logger.log(ex, classMethod, affectedId, LoggingLevel.ERROR);
	}

	/**
	 * @description writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>/<method> if applicable
	 */
	public static void error(String message, String classMethod)
	{
		CMN_DAL_Logger.log(message, classMethod, LoggingLevel.ERROR);
	}

	/**
	 * @description writes a log for every message
	 *
	 * @param messages message to be logged
	 * @param classMethod <class>/<method> if applicable
	 */
	public static void error(List<String> messages, String classMethod)
	{
		CMN_DAL_Logger.log(messages, classMethod, LoggingLevel.ERROR);
	}

	/**
	 * @description Will iterate through save results from dml operations and log errors encountered
	 *
	 * @param operationResults Results from an DML Operation, could be any of save result types listed below
	 * @param classMethod <class>/<method> if applicable
	 *
	 * @return Will return true if any errors were found and logged
	 *
	 * @see Database.DeleteResult
	 * @see Database.SaveResult
	 * @see Database.UpsertResult
	 */
	public static Boolean errorDMLOperationResults(List<Object> operationResults, String classMethod)
	{
		return CMN_DAL_Logger.log(operationResults, classMethod);
	}
}