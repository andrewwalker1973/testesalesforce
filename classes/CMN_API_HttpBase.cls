/**
 * @description The Base class for all API Web Service Calls (outbound/inbound, either SOAP or REST)
 *
 * @author christopher.de.buys@accenture.com, jason.van.beukering@accenture.com
 *
 * @date 2019, August 2023
 */
public virtual inherited sharing class CMN_API_HttpBase extends CMN_DAL_SObjectUnitOfWork
{
	@TestVisible
	private static final String ERROR_API_DISABLED = 'API has been disabled';
	private static final String PERFORMANCE_LOG_FORMAT = '{0} {1} {2} milliseconds\n' +
			'\n' +
			'----REQUEST---------\n' +
			'{3}\n' +
			'\t\n' +
			'----RESPONSE---------\t\n' +
			'{4}';

	//http status codes https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
	@SuppressWarnings('ApexDocValidation')
	public static final Integer HTTP_OK = 200;
	@SuppressWarnings('ApexDocValidation')
	public static final Integer HTTP_CREATED = 201;
	@SuppressWarnings('ApexDocValidation')
	public static final Integer HTTP_ACCEPTED = 202;
	@SuppressWarnings('ApexDocValidation')
	public static final Integer HTTP_NON_AUTH_INFO = 203;
	@SuppressWarnings('ApexDocValidation')
	public static final Integer HTTP_NO_CONTENT = 204;
	@SuppressWarnings('ApexDocValidation')
	public static final Integer HTTP_RESET_CONTENT = 205;
	@SuppressWarnings('ApexDocValidation')
	public static final Integer HTTP_BAD_REQUEST = 400;
	@SuppressWarnings('ApexDocValidation,ApexUnusedDeclaration')
	public static final Integer HTTP_UNAUTHORISED = 401;
	@SuppressWarnings('ApexDocValidation,ApexUnusedDeclaration')
	public static final Integer HTTP_PAGE_NOT_FOUND = 404;
	@SuppressWarnings('ApexDocValidation,ApexUnusedDeclaration')
	public static final Integer HTTP_SERVICE_INCOMPLETE = 406;
	@SuppressWarnings('ApexDocValidation')
	public static final Integer HTTP_INTERNAL_SERVER_ERROR = 500;
	@SuppressWarnings('ApexDocValidation')
	public static final Integer HTTP_SERVICE_UNAVAILABLE = 503;

	@SuppressWarnings('ApexDocValidation')
	public static final Set<Integer> HTTP_VALID_CODES = new Set<Integer>
	{
			HTTP_OK, HTTP_CREATED, HTTP_ACCEPTED, HTTP_NON_AUTH_INFO, HTTP_NO_CONTENT, HTTP_RESET_CONTENT
	};

	@SuppressWarnings('ApexDocValidation,ApexUnusedDeclaration')
	public final static String HTTP_ENCODING_FORM_URL_ENCODED = 'application/x-www-form-urlencoded';
	@SuppressWarnings('ApexDocValidation')
	public static final String ERR_INTERNAL_SERVER = 'Internal Server Error';
	@SuppressWarnings('ApexDocValidation,ApexUnusedDeclaration')
	public static final String ERR_INTERNAL_UNAUTHORISED = 'Unauthorised';
	@SuppressWarnings('ApexDocValidation,ApexUnusedDeclaration')
	public static final String HTTP_AUTH_TOKEN_BEARER = 'Bearer ';
	@SuppressWarnings('ApexDocValidation')
	public static final String HTTP_CONTENT_TYPE = 'Content-Type';
	@SuppressWarnings('ApexDocValidation')
	public static final String HTTP_ENCODING_JSON = 'application/json';
	@SuppressWarnings('ApexDocValidation')
	public static final String HTTP_HEADER_ACCEPT = 'Accept';
	@SuppressWarnings('ApexDocValidation')
	public static final String HTTP_HEADER_AUTHORIZATION = 'Authorization';
	@SuppressWarnings('ApexDocValidation,ApexUnusedDeclaration')
	public static final String HTTP_HEADER_AUTH_BASIC = 'Basic ';
	@SuppressWarnings('ApexDocValidation')
	public static final String HTTP_HEADER_CLIENT_ID = 'x-ibm-client-id';
	@SuppressWarnings('ApexDocValidation')
	public static final String HTTP_HEADER_CLIENT_SECRET = 'x-ibm-client-secret';
	@SuppressWarnings('ApexDocValidation,ApexUnusedDeclaration')
	public static final String HTTP_HEADER_X_CLIENT_CERTIFICATE = 'x-client-certificate';
	@SuppressWarnings('ApexDocValidation,ApexUnusedDeclaration')
	public static final String HTTP_VERB_DELETE = 'DELETE';
	@SuppressWarnings('ApexDocValidation')
	public static final String HTTP_VERB_GET = 'GET';
	@SuppressWarnings('ApexDocValidation,ApexUnusedDeclaration')
	public static final String HTTP_VERB_PATCH = 'PATCH';
	@SuppressWarnings('ApexDocValidation')
	public static final String HTTP_VERB_POST = 'POST';
	@SuppressWarnings('ApexDocValidation,ApexUnusedDeclaration')
	public static final String HTTP_VERB_PUT = 'PUT';
	@SuppressWarnings('ApexDocValidation')
	public static final String UTF8_ENCODING_SCHEME = 'UTF-8';
	@SuppressWarnings('ApexDocValidation')
	public static final String HTTP_ACCEPT_JSON_WITH_CHARSET = 'application/json; charset=' + UTF8_ENCODING_SCHEME;

	/**
	 * @description Object to track the request, response and status of a web service call
	 */
	public CMN_DAL_WebserviceCallQueue.ServiceCallResult callResult
	{
		get
		{
			if(callResult == null)
			{
				callResult = new CMN_DAL_WebserviceCallQueue.ServiceCallResult();
			}

			return callResult;
		}
		private set;
	}

	/**
	 * @description A stop watch that can be used by external class to measure time taken by handler to process request
	 */
	protected CMN_UTIL_StopWatch stopWatch
	{
		get
		{
			if(stopWatch == null)
			{
				stopWatch = new CMN_UTIL_StopWatch();
			}

			return stopWatch;
		}
		private set;
	}

	/**
	 * @description The service name of the API class, will be based on the class name
	 */
	protected String serviceName
	{
		get
		{
			if(String.isBlank(serviceName))
			{
				serviceName = CMN_UTIL_System.getTypeName(this);
			}

			return serviceName;
		}
		private set;
	}

	/**
	 * @description The WebService Queue Item that initiated service call
	 */
	public CMN_WebserviceCallQueue__c queueItem
	{
		get;
		private set;
	}

	/**
	 * @description Base constructor for all HTTP request classes, will call virtual method call initialise
	 */
	public CMN_API_HttpBase()
	{
		initialise();
	}

	/**
	 * @description Ensure you override this on descendant classes if you need to initialise global variables
	 */
	protected virtual void initialise()
	{
		stopWatch.start();

		setUnitOfWorksObjectTypes();
	}

	/**
	 * @description HTTP Character encoding, override if you want to define custom content encoding for service
	 *
	 * @return string
	 */
	protected virtual String getEncoding()
	{
		return CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description The HTTP Verb that the service will use when making a request, override this if you want to change this for
	 * Descendant class
	 *
	 * @return string
	 */
	protected virtual String getVerb()
	{
		return CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description Will ensure that any changes to be made to Salesforce are registered here
	 */
	protected virtual void registerDatabaseChanges()
	{
	}

	/**
	 * @description This method will be called to get HTTP request Body
	 * Override this on descendant classes to provide relevant body
	 *
	 * @return string
	 */
	protected virtual String getBody()
	{
		return CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description This method must be called after object is constructed otherwise it will lead to an assert being raised.
	 *
	 * @param queueItem Use this parameter to store CMN_WebserviceCallQueue__c
	 */
	protected virtual void setQueueItem(CMN_WebserviceCallQueue__c queueItem)
	{
		this.queueItem = queueItem;

		//Make sure we reset the time taken when given queue item as we are start
		this.queueItem.CMN_RequestTimeTaken__c = null;

		//Add the queue item to list of changes we want to commit
		registerChange(this.queueItem);
	}

	/**
	 * @description This method is used to get the queue items
	 *
	 * @return queueItem
	 */
	public virtual CMN_WebserviceCallQueue__c getQueueItem()
	{
		return queueItem;
	}

	/**
	 * @description Will shorten a response to the length given
	 *
	 * @param inputString The response
	 * @param maxLength The maximum length
	 *
	 * @return The abbreviated string
	 */
	private static String abbreviate(String inputString, Integer maxLength)
	{
		return String.isNotBlank(inputString) && inputString.length() > maxLength ? CMN_UTIL_String.abbreviate(inputString, maxLength) : inputString;
	}

	/**
	 * @description Will update the Queue Item with the final results of the call made
	 */
	public virtual void setQueueItemDetails()
	{
		queueItem.CMN_Errors__c = CMN_UTIL_String.joinArray(callResult.errors, CMN_UTIL_String.CRLF);
		queueItem.CMN_MockedResponse__c = callResult.mocking == null ? false : callResult.mocking;
		queueItem.CMN_NextRetry__c = null;
		queueItem.CMN_RequestTimeTaken__c = stopWatch.getTime();
		queueItem.CMN_Request_Parameters__c = abbreviate(queueItem.CMN_Request_Parameters__c, CMN_DAL_WebserviceCallQueue.REQUEST_PARAMETERS_LENGTH);
		queueItem.CMN_Request_Parameters__c = CMN_UTIL_String.EMPTY_JSON_RESPONSE.equals(queueItem.CMN_Request_Parameters__c) ?
				null : queueItem.CMN_Request_Parameters__c;
		queueItem.CMN_Request__c = abbreviate(callResult.requestBody, CMN_DAL_WebserviceCallQueue.REQUEST_LENGTH);
		queueItem.CMN_Response__c = abbreviate(callResult.responseBody, CMN_DAL_WebserviceCallQueue.RESPONSE_LENGTH);
		queueItem.CMN_StatusCode__c = callResult.statusCode;
		queueItem.CMN_Status__c = callResult.statusText;
		queueItem.CMN_URL__c = abbreviate(callResult.url, CMN_DAL_WebserviceCallQueue.URL_LENGTH);
	}

	/**
	 * @description Define which objects are valid for data manipulation
	 */
	protected virtual void setUnitOfWorksObjectTypes()
	{
		addSObjectTypes(new List<Schema.SObjectType>
		{
				CMN_WebserviceCallQueue__c.SObjectType
		});
	}

	/**
	 * @description Override this in descendant classes if you want stack track to be added to error list if exception is being handled
	 *
	 * @return A boolean; true will add stack track to exceptions
	 */
	protected virtual Boolean addStackTraceToExceptions()
	{
		return false;
	}

	/**
	 * @description Method will check custom settings to determine if the API has been disabled for the current user
	 *
	 * @return True if disabled
	 */
	protected Boolean isDisabled()
	{
		CMN_FeatureSwitches__c featureSwitches = CMN_DAL_FeatureSwitches.getFeatureSwitch(null);

		String disabledAPIs = featureSwitches.CMN_APIsToDisableList1__c + featureSwitches.CMN_APIsToDisableList2__c + featureSwitches.CMN_APIsToDisableList3__c;

		return featureSwitches.CMN_DisableAllOutboundAPICalls__c || (String.isNotBlank(disabledAPIs) && disabledAPIs.containsIgnoreCase(getServiceName()));
	}

	/**
	 * @description Method will check custom settings to determine if the API is returning mock responses for the current user
	 *
	 * @return True if mocking
	 */
	protected Boolean isMocking()
	{
		CMN_FeatureSwitches__c featureSwitches = CMN_DAL_FeatureSwitches.getFeatureSwitch(null);

		String mockingAPIs = featureSwitches.CMN_APIsToMockList1__c + featureSwitches.CMN_APIsToMockList2__c + featureSwitches.CMN_APIsToMockList3__c;

		return featureSwitches.CMN_MockAllOutboundAPICalls__c || (String.isNotBlank(mockingAPIs) && mockingAPIs.containsIgnoreCase(getServiceName()));
	}

	/**
	 * @description Method checks to see if the web service should be allowed to run
	 *
	 * @return If true then the web service will be processed else aborted
	 */
	protected virtual Boolean abortRequest()
	{
		Boolean abort = isDisabled();

		if(abort)
		{
			callResult.errors.add(ERROR_API_DISABLED);
		}

		return abort;
	}

	/**
	 * @description Retrieves current Service Name, NB: This does not need to be implemented anymore, and only being retained for backwards compatibility
	 *
	 * @return The class name of the current service
	 *
	 * @see CMN_API_HttpBase.serviceName
	 */
	protected virtual String getServiceName()
	{
		return serviceName;
	}

	/**
	 * @description Perform any operation after UOW has performed DML operations
	 *
	 * @param wasSuccessful Indicates if the commit was successful or not
	 */
	public override virtual void onCommitWorkFinished(Boolean wasSuccessful)
	{
		super.onCommitWorkFinished(wasSuccessful);

		//If the commit failed (or there is nothing to commit) or the call out didn't complete, don't log as these will be logged through error handling
		if(wasSuccessful && callResult.completed)
		{
			String methodName = getServiceName() + '/onCommitWorkFinished';
			String message = String.format
					(
							PERFORMANCE_LOG_FORMAT,
							new List<Object> {getVerb(), callResult.url, stopWatch.getTime(), callResult.requestBody, callResult.responseBody}
					);

			CMN_UTIL_Logger.debug(message, methodName, queueItem.Id);
		}
	}

	/**
	 * @description Used to process any errors that occurred
	 *
	 * @param error The exception that should be handled
	 */
	public virtual void handleError(Exception error)
	{
		if(error instanceof DmlException)
		{
			DmlException dmlException = (DmlException)error;
			for(Integer i = 0; i < dmlException.getNumDml(); i++)
			{
				callResult.errors.add(dmlException.getDmlMessage(i));
			}
		}
		else
		{
			callResult.errors.add(error.getMessage());
		}

		if(addStackTraceToExceptions())
		{
			callResult.errors.add(error.getStackTraceString());
		}

		callResult.failed = true;
	}

	/**
	 * @description the main processing loop for the webservice handler, must be implemented
	 *
	 * @param queueItem The queueItem which will ultimately saved to record activity of webservice object
	 */
	public virtual void process(CMN_WebserviceCallQueue__c queueItem)
	{
		setQueueItem(queueItem);
	}
}