/**
 * @description Provides Query methods related to CMN_WebserviceCallQueue__c object
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date 2019, June 2023
 */
public inherited sharing class CMN_DAL_WebserviceCallQueue
{
	private static final String FIELD_SERVICE = CMN_WebserviceCallQueue__c.CMN_Service__c.getDescribe().getName();
	private static final String FIELD_STATUS = CMN_WebserviceCallQueue__c.CMN_Status__c.getDescribe().getName();
	private static final String FIELD_TYPE = CMN_WebserviceCallQueue__c.CMN_Type__c.getDescribe().getName();
	private static final String OBJECT_NAME = CMN_WebserviceCallQueue__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName();

	/**
	 * @description The maximum number of character that can be stored in the Request Field
	 */
	public static final Integer REQUEST_LENGTH = CMN_WebserviceCallQueue__c.CMN_Request__c.getDescribe().length;
	/**
	 * @description The maximum number of character that can be stored in the Request Parameters Field
	 */
	public static final Integer REQUEST_PARAMETERS_LENGTH = CMN_WebserviceCallQueue__c.CMN_Request_Parameters__c.getDescribe().length;
	/**
	 * @description The maximum number of characters that can be stored in the Response Field
	 */
	public static final Integer RESPONSE_LENGTH = CMN_WebserviceCallQueue__c.CMN_Response__c.getDescribe().length;
	/**
	 * @description The maximum number of characters that can be stored in the URL Field
	 */
	public static final Integer URL_LENGTH = CMN_WebserviceCallQueue__c.CMN_URL__c.getDescribe().length;

	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public static final String STATUS_ABORTED = 'Aborted';
	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public static final String STATUS_BATCHED = 'Batched';
	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public static final String STATUS_COMPLETED = 'Completed';
	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public static final String STATUS_FAILED = 'Failed';
	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public static final String STATUS_QUEUED = 'Queued';
	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public static final String STATUS_RETRY = 'Retry';
	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public static final String TYPE_INBOUND = 'Inbound';
	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public static final String TYPE_OUTBOUND = 'Outbound';

	public static final String EMPTY_JSON_RESPONSE = '{ }';

	@SuppressWarnings('ApexDocValidation')
	public enum WebserviceStatus
	{
		COMPLETED, FAILED, ABORTED
	}

	/**
	 * @description Object to track the request, response and status of a web service call
	 */
	public virtual class ServiceCallResult
	{
		/**
		 * @description A list of errors encountered when the service call as made
		 */
		public List<String> errors = new List<String>();
		/**
		 * @description The request sent
		 */
		public String requestBody;
		/**
		 * @description The response received
		 */
		public String responseBody;
		/**
		 * @description The HTTP status code for the request
		 */
		public String statusCode;
		/**
		 * @description The URL of the endpoint accessed
		 */
		public String url;
		/**
		 * @description An indicator of webservice status
		 */
		public WebserviceStatus status;
		/**
		 * @description Indicates if this service call was mocked
		 */
		public Boolean mocking;
		/**
		 * @description Provides the text equivalent of status
		 */
		public String statusText
		{
			get
			{
				String serviceStatusText = String.valueOf(status);
				return CMN_UTIL_String.upperCase(serviceStatusText.substring(0, 1)) + CMN_UTIL_String.lowerCase(serviceStatusText.substring(1));
			}
		}

		/**
		 * @description Determines if a service call has failed by checking status
		 */
		public Boolean failed
		{
			get
			{
				return status == WebserviceStatus.FAILED;
			}
			set
			{
				status = value == true ? WebserviceStatus.FAILED : status;
			}
		}

		/**
		 * @description Determines if a service call has been successful by checking status
		 */
		public Boolean completed
		{
			get
			{
				return status == WebserviceStatus.COMPLETED;
			}
			set
			{
				status = value == true ? WebserviceStatus.COMPLETED : status;
			}
		}

		/**
		 * @description Determines if a service call has been aborted by checking status
		 */
		public Boolean aborted
		{
			get
			{
				return status == WebserviceStatus.ABORTED;
			}
			set
			{
				status = value == true ? WebserviceStatus.ABORTED : status;
			}
		}
	}

	/**
	 * @description This method is use to display Webservice call queue date.
	 *
	 * @param queueItem as input
	 * @param nextRetryTime as input
	 */
	public static void updateNextRetryInfo(CMN_WebserviceCallQueue__c queueItem, Datetime nextRetryTime)
	{
		queueItem.CMN_NextRetry__c = nextRetryTime;
		queueItem.CMN_Status__c = STATUS_RETRY;
		queueItem.CMN_Retries__c++;
	}

	/**
	 * @description The default fields to query from the CMN_WebserviceCallQueue__c Object
	 *
	 * @return A list of CMN_WebserviceCallQueue__c fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_WebserviceCallQueue__c.CMN_Errors__c.getDescribe().getName(),
				CMN_WebserviceCallQueue__c.CMN_NextRetry__c.getDescribe().getName(),
				CMN_WebserviceCallQueue__c.CMN_RequestTimeTaken__c.getDescribe().getName(),
				CMN_WebserviceCallQueue__c.CMN_Request_Parameters__c.getDescribe().getName(),
				CMN_WebserviceCallQueue__c.CMN_Request__c.getDescribe().getName(),
				CMN_WebserviceCallQueue__c.CMN_Response__c.getDescribe().getName(),
				CMN_WebserviceCallQueue__c.CMN_Retries__c.getDescribe().getName(),
				CMN_WebserviceCallQueue__c.CMN_StatusCode__c.getDescribe().getName(),
				CMN_WebserviceCallQueue__c.CMN_Status__c.getDescribe().getName(),
				CMN_WebserviceCallQueue__c.CMN_TriggeringObjectId__c.getDescribe().getName(),
				CMN_WebserviceCallQueue__c.CMN_TriggeringObjectUrl__c.getDescribe().getName(),
				CMN_WebserviceCallQueue__c.CMN_URL__c.getDescribe().getName(),
				CMN_WebserviceCallQueue__c.CreatedById.getDescribe().getName(),
				CMN_WebserviceCallQueue__c.CreatedDate.getDescribe().getName(),
				CMN_WebserviceCallQueue__c.Name.getDescribe().getName(),
				FIELD_SERVICE,
				FIELD_STATUS,
				FIELD_TYPE
		};
	}

	/**
	 * @description This method is use to List of of webservice call queue by Service name.
	 *
	 * @param serviceName as input
	 *
	 * @return list of webservice queues by service name
	 */
	@TestVisible
	private static List<CMN_WebserviceCallQueue__c> findByServiceName(String serviceName)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_SERVICE, new Set<String> {serviceName}, getDefaultFields());
	}

	/**
	 * @description Used by API unit tests to confirm that Service calls were logged as expected
	 *
	 * @param serviceName The name of the API class
	 */
	@TestVisible
	private static void checkServiceCompleted(String serviceName)
	{
		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.findByServiceName(serviceName);

		System.assertNotEquals(true, queueItems.isEmpty(), 'No QueueItems found for Service: "' + serviceName + '"');

		for(CMN_WebserviceCallQueue__c queueItem : queueItems)
		{
			Boolean statusCorrect = CMN_DAL_WebserviceCallQueue.STATUS_COMPLETED.equalsIgnoreCase(queueItem.CMN_Status__c);
			System.assert(statusCorrect, 'Service did not complete. Queue Item JSON: ' + JSON.serialize(queueItem));
		}
	}

	/**
	 * @description Will check to see that web service failed
	 *
	 * @param serviceName The name of the API class
	 * @param errorMessageMatch Check to see if correct phrase or word is in the error string
	 *
	 * @return The found Queue Items for the service name given, can be used to check other aspects of the queueItems
	 */
	@TestVisible
	private static List<CMN_WebserviceCallQueue__c> checkServiceFailedCorrectly(String serviceName, String errorMessageMatch)
	{
		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.findByServiceName(serviceName);

		System.assertNotEquals(true, queueItems.isEmpty(), 'No QueueItems found for Service: "' + serviceName + '"');

		for(CMN_WebserviceCallQueue__c queueItem : queueItems)
		{
			Boolean statusCorrect = CMN_DAL_WebserviceCallQueue.STATUS_FAILED.equalsIgnoreCase(queueItem.CMN_Status__c);
			System.assert(statusCorrect, 'Service did not fail. Queue Item JSON: ' + JSON.serialize(queueItem));
			System.assert(CMN_UTIL_String.contains(queueItem.CMN_Errors__c, errorMessageMatch), 'Error Message Incorrect');
		}

		return queueItems;
	}

	/**
	 * @description Find items that have been batched and are outbound
	 *
	 * @return List of Items
	 */
	public static List<CMN_WebserviceCallQueue__c> findByBatchedOutbound()
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_STATUS, new Set<String> {STATUS_BATCHED}, getDefaultFields());
		searchParameters.searchConditions.equalsX(FIELD_TYPE, TYPE_OUTBOUND);
		searchParameters.pageSize = CMN_DAL_Search.LIMIT_NUMBER_OF_RECORDS;
		return CMN_DAL_Search.getObjects(searchParameters);
	}
}