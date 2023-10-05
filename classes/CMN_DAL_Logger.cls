/**
 * @description For writing persistent logs using platform events
 *
 * @see CMN_UTIL_Logger adapted from https://github.com/mlockett/ApexLogger
 * @see CMN_UTIL_Logger_TEST
 * @see CMN_DAL_Logger_TEST
 *
 * @author vishakha.saini@accenture.com, jason.van.beukering@accenture.com
 *
 * @date June 2018, July 2023
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public without sharing class CMN_DAL_Logger
{
	private static final Id CURRENT_USER_ID = UserInfo.getUserId();
	private static final Integer CLASS_METHOD_LENGTH = CMN_AppLogEvent__e.CMN_ClassMethod__c.getDescribe().length;
	private static final Integer MESSAGE_LENGTH = CMN_AppLogEvent__e.CMN_Message__c.getDescribe().length;
	private static final Integer SHORT_MESSAGE_LENGTH = CMN_AppLogEvent__e.CMN_ShortMessage__c.getDescribe().length;
	private static final Pattern STACK_LINE = Pattern.compile('^(?:Class\\.)?([^.]+)\\.?([^.:]+)?[.:]?([^.:]*): line (\\d+), column (\\d+)$');
	private static final String CLASS_SUFFIX = '_Logger.';
	private static final String CURRENT_USER_EMAIL = UserInfo.getUserEmail();
	private static final String CURRENT_USER_NAME = UserInfo.getUserName();
	private static final String DML_ERROR_FORMAT = 'The following {0} for record Id "{1}"';
	private static final String DUPLICATE_ERROR_FORMAT = 'duplicate record was detected on "{0}" based on rule "{1}"';
	private static final String EXTRACTED_ERROR_FORMAT = 'error occurred "{0}" for the following fields "{1}"';
	private static final String INVOCABLE_METHOD = 'Invocable';
	private static final String LIMIT_ERROR = 'Unable to publish logging events as the both DML and Queueable Limits have been reached';
	private static final String MESSAGE_DELIMITER = ';' + CMN_UTIL_String.LF;

	/**
	 * @description When test is running, event will not be published unless ignoreTestMode is set to true
	 */
	@TestVisible
	private static Boolean ignoreTestMode = false;
	/**
	 * @description Set this value to true in an unit test to ensure we test that events can be published by a Queueable job
	 */
	@TestVisible
	private static Boolean simulateDMLimitsBreach = false;
	/**
	 * @description Set this value to true to prevent asynchronous publishing so we can simulate situation where we are hitting limits
	 */
	@TestVisible
	private static Boolean simulateQueueableLimitsBreach = false;
	@TestVisible
	private static final String TYPE_ALL_USERS = 'All';
	@TestVisible
	private static final String TYPE_USER_ID = 'UserId';
	@TestVisible
	private static final String TYPE_USERNAME = 'Username';
	@TestVisible
	private static final String TYPE_EMAIL = 'Email';
	@TestVisible
	private static final String ALL_USERS = '*';
	@TestVisible
	private static final String LEVEL_WARN = LoggingLevel.WARN.name();
	@TestVisible
	private static final String LEVEL_DEBUG = LoggingLevel.DEBUG.name();
	@TestVisible
	private static final String LEVEL_ERROR = LoggingLevel.ERROR.name();
	@TestVisible
	private static final String LEVEL_INFO = LoggingLevel.INFO.name();
	@TestVisible
	private static final String ALL_LOG_LEVELS = LEVEL_INFO + ',' + LEVEL_DEBUG + ',' + LEVEL_WARN + ',' + LEVEL_ERROR;
	@TestVisible
	private static final Map<Id, List<CMN_LogUserFilter__mdt>> USER_ID_LOG_USER_FILTER_MAP = new Map<Id, List<CMN_LogUserFilter__mdt>>();

	// note: because SF doesn't allow creating custom metadata in tests, we're doing a workaround to allow testing
	// different metadata
	@TestVisible
	private static List<CMN_LogMessageFilter__mdt> messageFilters = null;

	// note: because SF doesn't allow creating custom metadata in tests, we're doing a workaround to allow testing
	// different metadata
	@TestVisible
	private static List<CMN_LogUserFilter__mdt> testUserFilters = null;

	/**
	 * @description Enables logging to be called from Process Builder
	 *
	 * @param messages because PB can insert/update multiple records, method takes a list which is concatenated
	 */
	@InvocableMethod(Label='Write Log' Description='Writes desired data to the Application Log')
	public static void info(List<String> messages)
	{
		log(CMN_UTIL_String.joinArray(messages, MESSAGE_DELIMITER), INVOCABLE_METHOD, LoggingLevel.INFO);
	}

	/**
	 * @description writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>.<method> if applicable
	 */
	//TODO: Vishakha: Deprecated: Method added for backward compatibility on higher environments. Remove when latest code deployed to QAY
	@SuppressWarnings('ApexUnusedDeclaration')
	public static void debug(String message, String classMethod)
	{
		log(message, classMethod, LoggingLevel.DEBUG);
	}

	/**
	 * @description writes log with message
	 *
	 * @param message message to be logged
	 * @param classMethod <class>/<method> if applicable
	 * @param logLevel the System.LoggingLevel to log as
	 */
	public static void log(String message, String classMethod, LoggingLevel logLevel)
	{
		log(new DTO_LogMessages(message, logLevel, classMethod));
	}

	/**
	 * @description will write logs for each of the messages provided
	 *
	 * @param messages List of log messages
	 * @param classMethod <class>/<method> if applicable
	 * @param logLevel the System.LoggingLevel to log as
	 */
	public static void log(List<String> messages, String classMethod, LoggingLevel logLevel)
	{
		log(new DTO_LogMessages(messages, logLevel, classMethod));
	}

	/**
	 * @description writes log with message
	 *
	 * @param message message to be logged
	 * @param classMethod <class>/<method> if applicable
	 * @param recordId record Id related to log event
	 * @param logLevel the System.LoggingLevel to log as
	 */
	public static void log(String message, String classMethod, Id recordId, LoggingLevel logLevel)
	{
		log(new DTO_LogMessages(message, recordId, logLevel, classMethod));
	}

	/**
	 * @description writes log with exception data
	 *
	 * @param error the exception to be logged
	 * @param classMethod <class>/<method> if applicable
	 * @param logLevel the System.LoggingLevel to log as
	 */
	public static void log(Exception error, String classMethod, LoggingLevel logLevel)
	{
		log(new DTO_LogMessages(error, logLevel, classMethod));
	}

	/**
	 * @description writes log with exception data
	 *
	 * @param error the exception to be logged
	 * @param classMethod <class>/<method> if applicable
	 * @param recordId record Id related to log event
	 * @param logLevel the System.LoggingLevel to log as
	 */
	public static void log(Exception error, String classMethod, Id recordId, System.LoggingLevel logLevel)
	{
		log(new DTO_LogMessages(error, recordId, logLevel, classMethod));
	}

	/**
	 * @description Will iterate through save results from DML operations and log errors encountered
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
	public static Boolean log(List<Object> operationResults, String classMethod)
	{
		DTO_LogMessages dtoLogMessages = new DTO_LogMessages(LoggingLevel.ERROR, classMethod);

		for(Object operationResult : operationResults)
		{
			Boolean operationFailed;
			Id recordId;
			List<Database.Error> errors;

			if(operationResult instanceof Database.SaveResult)
			{
				Database.SaveResult saveResult = (Database.SaveResult)operationResult;
				errors = saveResult.errors;
				operationFailed = !saveResult.success;
				recordId = saveResult.id;
			}
			else if(operationResult instanceof Database.DeleteResult)
			{
				Database.DeleteResult deleteResult = (Database.DeleteResult)operationResult;
				errors = deleteResult.errors;
				operationFailed = !deleteResult.success;
				recordId = deleteResult.id;
			}
			else if(operationResult instanceof Database.UndeleteResult)
			{
				Database.UndeleteResult undeleteResult = (Database.UndeleteResult)operationResult;
				errors = undeleteResult.errors;
				operationFailed = !undeleteResult.success;
				recordId = undeleteResult.id;
			}
			else
			{
				Database.UpsertResult upsertResult = (Database.UpsertResult)operationResult;
				errors = upsertResult.errors;
				operationFailed = !upsertResult.success;
				recordId = upsertResult.id;
			}

			if(operationFailed)
			{
				String errorMessage = extractErrorMessage(errors);
				dtoLogMessages.addMessage(String.format(DML_ERROR_FORMAT, new List<Object> {errorMessage, recordId}), recordId);
			}
		}

		log(dtoLogMessages);

		return !dtoLogMessages.isEmpty;
	}

	/**
	 * @description Will extract an error message from a database errors provided (assuming operation has failed)
	 *
	 * @param errors The error encountered
	 *
	 * @return An Error Message
	 */
	private static String extractErrorMessage(List<Database.Error> errors)
	{
		List<String> errorMessages = new List<String>();

		for(Database.Error error : errors)
		{
			String errorMessage;

			if(error instanceof Database.DuplicateError)
			{
				Datacloud.DuplicateResult duplicateResult = ((Database.DuplicateError)error).getDuplicateResult();
				errorMessage = String.format(DUPLICATE_ERROR_FORMAT, new List<String> {duplicateResult.duplicateRuleEntityType, duplicateResult.duplicateRule});
			}
			else
			{
				errorMessage = error.getMessage();
				String fields = CMN_UTIL_String.joinArray(error.getFields(), CMN_UTIL_String.COMMA);

				errorMessage = String.format(EXTRACTED_ERROR_FORMAT, new List<String>
				{
						errorMessage, fields
				});
			}

			errorMessages.add(errorMessage);
		}

		return CMN_UTIL_String.joinArray(errorMessages, CMN_UTIL_String.COMMA);
	}

	/**
	 * @description will write logs for each of the messages provided
	 *
	 * @param dtoLogMessages List of log messages
	 */
	private static void log(DTO_LogMessages dtoLogMessages)
	{
		if(!dtoLogMessages.isEmpty && isLoggable(dtoLogMessages.logLevel))
		{
			publishEvents(dtoLogMessages.getEvents());
		}
	}

	/**
	 * @description determines whether entry should be logged based on user and log level using CMN_LogUserFilter__mdt
	 *
	 * @param logLevel The debug logging level
	 *
	 * @return Whether the entry should be logged
	 */
	@TestVisible
	private static Boolean isLoggable(LoggingLevel logLevel)
	{
		List<CMN_LogUserFilter__mdt> userFilters = getLogUserFilters();

		Boolean canContinue = false;

		String strLogLevel = logLevel.name();

		for(CMN_LogUserFilter__mdt filter : userFilters)
		{
			if(filter.CMN_LogLevel__c == null)
			{
				continue;
			}

			// splits on comma space or comma
			List<String> logLevels = filter.CMN_LogLevel__c.split(', |,');

			// check if user log should be recorded
			if
			(
					logLevels.contains(strLogLevel) &&
					(
							filter.CMN_UserType__c.equals(TYPE_ALL_USERS)
							||
							filter.CMN_LogUser__c.equals(ALL_USERS)
							||
							(
									filter.CMN_UserType__c.equals(TYPE_USER_ID) && filter.CMN_LogUser__c.equals(CURRENT_USER_ID))
							||
							(
									filter.CMN_UserType__c.equals(TYPE_USERNAME) && filter.CMN_LogUser__c.equalsIgnoreCase(CURRENT_USER_NAME) ||
									filter.CMN_UserType__c.equals(TYPE_EMAIL) && filter.CMN_LogUser__c.equalsIgnoreCase(CURRENT_USER_EMAIL)
							)
					)
			)
			{
				canContinue = true;
				break;
			}
		}

		return canContinue;
	}

	/**
	 * @description gets CMN_LogUserFilter__mdt for current user and for * (all users)
	 *
	 * @return A list of record filters
	 */
	private static List<CMN_LogUserFilter__mdt> getLogUserFilters()
	{
		if(testUserFilters != null)
		{
			return testUserFilters;
		}

		/* check if resolved for user before access temporary in memory cache */
		List<CMN_LogUserFilter__mdt> userFilters = USER_ID_LOG_USER_FILTER_MAP.get (CURRENT_USER_ID);

		if(userFilters == null)
		{
			// mdt doesn't support disjunction OR queries so retrieve potential matches and filter
			userFilters = findActiveFiltersByUserId();

			/* update in memory cache for user */
			USER_ID_LOG_USER_FILTER_MAP.put(CURRENT_USER_ID, userFilters);
		}

		return userFilters;
	}

	/**
	 * @description Will query filter records based on User Id, UserName or UserEmail
	 *
	 * @return A list containing founder records
	 */
	private static List<CMN_LogUserFilter__mdt> findActiveFiltersByUserId()
	{
		String objectName = CMN_LogUserFilter__mdt.SObjectType.getDescribe().getLocalName();

		Set <String> fields = new Set <String>
		{
				CMN_LogUserFilter__mdt.CMN_LogLevel__c.getDescribe().getLocalName(),
				CMN_LogUserFilter__mdt.CMN_UserType__c.getDescribe().getLocalName()
		};

		String fieldLogUser = CMN_LogUserFilter__mdt.CMN_LogUser__c.getDescribe().getLocalName();

		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(objectName, fields);
		searchParameters.searchConditions.equalsX(CMN_LogUserFilter__mdt.CMN_Active__c.getDescribe().getLocalName(), true);
		searchParameters.searchConditions.inX(fieldLogUser, new Set<Object> {ALL_USERS, CURRENT_USER_ID, CURRENT_USER_NAME, CURRENT_USER_EMAIL});
		searchParameters.addOrderByField(fieldLogUser);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description publishes event... optionally suppresses when in test... deals with errors
	 *
	 * @param logEvents CMN_AppLogEvent__e events to be published
	 *
	 * @return A List of database errors
	 */
	@TestVisible
	@SuppressWarnings('PMD.AvoidDebugStatements')
	private static List<Database.SaveResult> publishEvents(List<CMN_AppLogEvent__e> logEvents)
	{
		List<Database.SaveResult> saveResults;

		// don't publish event during unit tests unless ignoreTestMode is true
		if(ignoreTestMode || !Test.isRunningTest())
		{
			// Ensure that the dml limits will not been breached when publishing the events
			if(canPublishImmediately(logEvents))
			{
				EventBus.publish(logEvents);
			}
			//Ensure we aren't reaching the limits of enqueuing jobs
			else if(!simulateQueueableLimitsBreach && Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() > 0)
			{
				System.enqueueJob(new AsynchronousLogger(logEvents));
			}
			else
			{
				//Ensure we record that we were unable to publish log events due to governor limits
				System.debug(LoggingLevel.DEBUG, LIMIT_ERROR);
			}
		}
		else
		{
			//Record App logs as system debug if running in test context
			System.debug(logEvents);
		}

		return saveResults;
	}

	/**
	 * @description Method will check current governor limits and determine if the events provided can be published immediately
	 *
	 * @param logEvents List of items to publish
	 *
	 * @return True if publishing the event immediately won't breach governor limits
	 */
	private static Boolean canPublishImmediately(List<CMN_AppLogEvent__e> logEvents)
	{
		if(simulateDMLimitsBreach)
		{
			return false;
		}

		Boolean publishImmediately = Limits.getPublishImmediateDML() < Limits.getLimitPublishImmediateDML();
		publishImmediately = publishImmediately && logEvents.size() <= Limits.getLimitDmlRows() - Limits.getDmlRows();

		return publishImmediately;
	}

	/**
	 * @description Filters string based on CMN_LogFilter__mdt or optionally testFilters
	 *
	 * @param inputString The string to search and replace against
	 *
	 * @return string with replacements made for all active filters
	 */
	public static String filterString(String inputString)
	{
		List<CMN_LogMessageFilter__mdt> filters = findAllActiveMessageFilters();

		for(CMN_LogMessageFilter__mdt filter : filters)
		{
			inputString = inputString.replaceAll(filter.CMN_RegexToFind__c, filter.CMN_RegexToReplaceWith__c);
		}

		return inputString;
	}

	/**
	 * @description retrieve the message filters
	 *
	 * @return list of message filters
	 */
	private static List<CMN_LogMessageFilter__mdt> findAllActiveMessageFilters()
	{
		// note: because Salesforce doesn't allow creating custom metadata in tests,
		// we're doing a workaround to allow test to set expected metadata
		if(messageFilters == null)
		{
			String objectName = CMN_LogMessageFilter__mdt.SObjectType.getDescribe().getLocalName();

			Set <String> fields = new Set <String>
			{
					CMN_LogMessageFilter__mdt.CMN_RegexToFind__c.getDescribe().getLocalName(),
					CMN_LogMessageFilter__mdt.CMN_RegexToReplaceWith__c.getDescribe().getLocalName()
			};

			CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(objectName, fields);
			searchParameters.searchConditions.equalsX(CMN_LogMessageFilter__mdt.CMN_Active__c.getDescribe().getLocalName(), true);
			messageFilters = CMN_DAL_Search.getObjects(searchParameters);
		}

		return messageFilters;
	}

	/**
	 * @description Represents a list of messages to be logged
	 */
	private class DTO_LogMessages
	{
		/**
		 * @description Default class constructor
		 *
		 * @param logLevel Log Level
		 * @param classMethod <class>/<method> if applicable
		 */
		public DTO_LogMessages(LoggingLevel logLevel, String classMethod)
		{
			this.logLevel = logLevel;
			this.classMethod = classMethod;
		}

		/**
		 * @description Default class constructor
		 *
		 * @param message Message to add to list of messages
		 * @param logLevel Log Level
		 * @param classMethod <class>/<method> if applicable
		 */
		public DTO_LogMessages(String message, LoggingLevel logLevel, String classMethod)
		{
			this(message, null, logLevel, classMethod);
		}

		/**
		 * @description Default class constructor
		 *
		 * @param message Message to add to list of messages
		 * @param recordId The record Id for which the message should be logged
		 * @param logLevel Log Level
		 * @param classMethod <class>/<method> if applicable
		 */
		public DTO_LogMessages(String message, Id recordId, LoggingLevel logLevel, String classMethod)
		{
			this(logLevel, classMethod);
			addMessage(message, recordId);
		}

		/**
		 * @description Default class constructor
		 *
		 * @param messages Messages to add to list of messages
		 * @param logLevel Log Level
		 * @param classMethod <class>/<method> if applicable
		 */
		public DTO_LogMessages(List<String> messages, LoggingLevel logLevel, String classMethod)
		{
			this(logLevel, classMethod);
			addMessages(messages);
		}

		/**
		 * @description Default class constructor
		 *
		 * @param error Error from which to retrieve the message
		 * @param logLevel Log Level
		 * @param classMethod <class>/<method> if applicable
		 */
		public DTO_LogMessages(Exception error, LoggingLevel logLevel, String classMethod)
		{
			this(error, null, logLevel, classMethod);
		}

		/**
		 * @description Default class constructor
		 *
		 * @param error Error from which to retrieve the message
		 * @param recordId Record Id of the object for which error was thrown
		 * @param logLevel Log Level
		 * @param classMethod <class>/<method> if applicable
		 */
		public DTO_LogMessages(Exception error, Id recordId, LoggingLevel logLevel, String classMethod)
		{
			this(logLevel, classMethod);
			this.error = error;
			addMessage(error, recordId);
		}

		/**
		 * @description Add a message to the list
		 *
		 * @param message Message text
		 * @param recordId Associated Record Id (if applicable)
		 */
		private void addMessage(String message, Id recordId)
		{
			logMessages.add(new DTO_LogMessage(message, recordId));
		}

		/**
		 * @description Add a message to the list
		 *
		 * @param error Exception from which to retrieve the message
		 * @param recordId Associated Record Id (if applicable)
		 */
		private void addMessage(Exception error, Id recordId)
		{
			addMessage(error.getMessage(), recordId);
		}

		/**
		 * @description will add multiple messages to the list
		 *
		 * @param messages List of message to add
		 */
		private void addMessages(List<String> messages)
		{
			for(String message : messages)
			{
				addMessage(message, null);
			}
		}

		/**
		 * @description Returns true if no messages have been added to the list
		 */
		public Boolean isEmpty
		{
			get
			{
				return logMessages.isEmpty();
			}
		}

		/**
		 * @description The class method for this logger
		 */
		private String classMethod
		{
			get;
			set
			{
				classMethod = CMN_UTIL_String.ellipsisTrim(value, CLASS_METHOD_LENGTH, 0);
			}
		}
		/**
		 * @description Contains error for this logger (if one was provided)
		 */
		private final Exception error;
		/**
		 * @description Log level for this logger
		 */
		private final LoggingLevel logLevel;
		/**
		 * @description All the messages that have been created
		 */
		private final List<DTO_LogMessage> logMessages = new List<DTO_LogMessage>();

		/**
		 * @description Will construct a list off events from the log messages
		 *
		 * @return List of items
		 */
		public List<CMN_AppLogEvent__e> getEvents()
		{
			List<CMN_AppLogEvent__e> events = new List<CMN_AppLogEvent__e>();

			String executionEvent = Request.getCurrent().getQuiddity().name();
			String stackTrace = getStackTrace(error);

			for(DTO_LogMessage dtoLogMessage : logMessages)
			{
				CMN_AppLogEvent__e event = dtoLogMessage.getEvent();

				event.CMN_ClassMethod__c = classMethod;
				event.CMN_ExceptionType__c = error != null ? error.getTypeName() : null;
				event.CMN_ExecutionEvent__c = executionEvent;
				event.CMN_Limits__c = ((logLevel == LoggingLevel.DEBUG || error != null) ? getDebugLimits() : null);
				event.CMN_LineNumber__c = error != null ? error.getLineNumber() : null;
				event.CMN_LogLevel__c = logLevel.name();
				event.CMN_StackTrace__c = stackTrace;
				event.CMN_UserId__c = CURRENT_USER_ID;

				events.add(event);
			}

			return events;
		}

		/**
		 * @description Will return the stack trace to be included in the error log,
		 * uses an idea from Idea taken from https://salesforce.stackexchange.com/questions/153835
		 *
		 * @param error If the log was called with an exception, this will be used else the stack will be calculated
		 *
		 * @return The stack track of the log entry
		 */
		private String getStackTrace(Exception error)
		{
			String stackTrace;

			if(error != null)
			{
				stackTrace = error.getStackTraceString();
			}
			else
			{
				List<String> stackTraceLines = new DmlException().getStackTraceString().split(CMN_UTIL_String.LF);

				for(Integer i = stackTraceLines.size() - 1; i >= 0; i--)
				{
					String stackTraceLine = stackTraceLines[i];

					Matcher patternMatcher = STACK_LINE.matcher(stackTraceLine);

					if(!patternMatcher.find() || stackTraceLine.contains(CLASS_SUFFIX))
					{
						stackTraceLines.remove(i);
					}
				}

				stackTrace = CMN_UTIL_String.joinArray(stackTraceLines, CMN_UTIL_String.LF);
			}

			return stackTrace;
		}

		/**
		 * @description returns limits for debugging and error tracing purposes
		 *
		 * @return debug limits
		 */
		private String getDebugLimits()
		{
			return
					(
							CMN_UTIL_String.EMPTY
							+ CMN_UTIL_String.LF + 'AggregateQueries: ' + Limits.getAggregateQueries() + ' of ' + Limits.getLimitAggregateQueries()
							+ CMN_UTIL_String.LF + 'Callouts: ' + Limits.getCallouts() + ' of ' + Limits.getLimitCallouts()
							+ CMN_UTIL_String.LF + 'CPU Time: ' + Limits.getCpuTime() + ' of ' + Limits.getLimitCpuTime()
							+ CMN_UTIL_String.LF + 'Database Time: ' + Limits.getDatabaseTime() + ' of ' + Limits.getLimitDatabaseTime()
							+ CMN_UTIL_String.LF + 'DMLRows: ' + Limits.getDmlRows() + ' of ' + Limits.getLimitDmlRows()
							+ CMN_UTIL_String.LF + 'DMLStatements: ' + Limits.getDmlStatements() + ' of ' + Limits.getLimitDmlStatements()
							+ CMN_UTIL_String.LF + 'EmailInvocations: ' + Limits.getEmailInvocations() + ' of ' + Limits.getLimitEmailInvocations()
							+ CMN_UTIL_String.LF + 'FindSimilarCalls: ' + Limits.getFindSimilarCalls() + ' of ' + Limits.getLimitFindSimilarCalls()
							+ CMN_UTIL_String.LF + 'FutureCalls: ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls()
							+ CMN_UTIL_String.LF + 'HeapSize: ' + Limits.getHeapSize() + ' of ' + Limits.getLimitHeapSize()
							+ CMN_UTIL_String.LF + 'MobilePushApexCalls: ' + Limits.getMobilePushApexCalls() + ' of ' + Limits.getLimitMobilePushApexCalls()
							+ CMN_UTIL_String.LF + 'PublishImmediateDML: ' + Limits.getPublishImmediateDML() + ' of ' + Limits.getLimitPublishImmediateDML()
							+ CMN_UTIL_String.LF + 'Queries: ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries()
							+ CMN_UTIL_String.LF + 'QueryLocatorRows: ' + Limits.getQueryLocatorRows() + ' of ' + Limits.getLimitQueryLocatorRows()
							+ CMN_UTIL_String.LF + 'QueryRows: ' + Limits.getQueryRows() + ' of ' + Limits.getLimitQueryRows()
							+ CMN_UTIL_String.LF + 'QueueableJobs: ' + Limits.getQueueableJobs() + ' of ' + Limits.getLimitQueueableJobs()
							+ CMN_UTIL_String.LF + 'RunAs: ' + Limits.getRunAs() + ' of ' + Limits.getLimitRunAs()
							+ CMN_UTIL_String.LF + 'SavepointRollbacks: ' + Limits.getSavepointRollbacks() + ' of ' + Limits.getLimitSavepointRollbacks()
							+ CMN_UTIL_String.LF + 'Savepoints: ' + Limits.getSavepoints() + ' of ' + Limits.getLimitSavepoints()
							+ CMN_UTIL_String.LF + 'SoslQueries: ' + Limits.getSoslQueries() + ' of ' + Limits.getLimitSoslQueries()
					);
		}
	}

	/**
	 * @description DTO representing a message to be logged
	 */
	private class DTO_LogMessage
	{
		/**
		 * @description Default object constructor
		 *
		 * @param message The message to log
		 * @param recordId The object id (if any)
		 */
		public DTO_LogMessage(String message, Id recordId)
		{
			this.message = message;
			this.recordId = recordId;
		}

		/**
		 * @description Object Record Id associated to this message
		 */
		public Id recordId;
		/**
		 * @description The full message
		 */
		public String message
		{
			get;
			set
			{
				message = CMN_UTIL_String.abbreviate(value, MESSAGE_LENGTH);
				shortMessage = CMN_UTIL_String.ellipsisTrim(value, SHORT_MESSAGE_LENGTH, 0);
			}
		}
		/**
		 * @description An abbreviated message
		 */
		public String shortMessage;

		/**
		 * @description Will construct an event an populate it appropriately
		 *
		 * @return An app love event
		 */
		public CMN_AppLogEvent__e getEvent()
		{
			CMN_AppLogEvent__e event = new CMN_AppLogEvent__e();

			event.CMN_Message__c = message;
			event.CMN_RecordId__c = recordId;
			event.CMN_ShortMessage__c = shortMessage;

			return event;
		}
	}

	/**
	 * @description Will be used to publish logging events asynchronously
	 */
	public class AsynchronousLogger implements Queueable
	{
		private List<CMN_AppLogEvent__e> logEvents = new List<CMN_AppLogEvent__e>();

		/**
		 * @description Constructor that will get the SObjects to insert
		 *
		 * @param logEvents A list of events to be published
		 */
		public AsynchronousLogger(List<CMN_AppLogEvent__e> logEvents)
		{
			this.logEvents = logEvents;
		}

		/**
		 * @description Executes the Queueable job
		 *
		 * @param context the Context for Queueable job, contains the jobId
		 *
		 * @see Queueable
		 */
		public void execute(QueueableContext context)
		{
			EventBus.publish(logEvents);
		}
	}
}