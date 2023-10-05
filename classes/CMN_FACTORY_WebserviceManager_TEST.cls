/**
 * @description Tests the behaviour of associated WebserviceManager class
 *
 * @see CMN_FACTORY_WebserviceManager
 *
 * @author jason.van.beukering@accenture.com darrion.james.singh@accenture.com
 *
 * @date December 2021, October 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_FACTORY_WebserviceManager_TEST
{
	private static final Integer INVALID_RETRIES = 1000;

	/**
	 * @description Method to test queue items in a separate transaction
	 * from the changes as a result of API calls
	 *
	 * @param serviceName as input
	 */
	private static void assertExecuteService(String serviceName)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(serviceName);

		Test.startTest();

		CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem});

		Test.stopTest();

		List<CMN_WebserviceCallQueue__c> foundItems = CMN_DAL_WebserviceCallQueue.findByServiceName(queueItem.CMN_Service__c);

		System.assertEquals(false, foundItems.isEmpty(), 'No queue items were saved as expected.');
		System.assertEquals(CMN_DAL_WebserviceCallQueue.STATUS_ABORTED, foundItems.iterator().next().CMN_Status__c, 'Service status is incorrect.');
	}

	/**
	 * @description Check to see that error is handled correctly if an invalid handler class name was provided
	 */
	@IsTest
	private static void handlerClassNotFound()
	{
		assertExecuteService(CMN_DAL_SObjectDomain.generateRandomName());
	}

	/**
	 * @description Check to see that error is handled correctly if an valid class name was provided, but the class isn't a web service handler
	 */
	@IsTest
	private static void handlerClassInvalid()
	{
		assertExecuteService(CMN_FACTORY_WebserviceManager.class.getName());
	}

	/**
	 * @description Check to if a DML exception is handled correctly by the framework
	 */
	@IsTest
	private static void handlerCommitFailure()
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_RestOutboundExample.class.getName());

		//The default length of this field is  2 digits; this should result in a  DML error being thrown on commit
		queueItem.CMN_Retries__c = INVALID_RETRIES;

		Test.startTest();

		CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem});

		Test.stopTest();

		List<CMN_WebserviceCallQueue__c> foundItems = CMN_DAL_WebserviceCallQueue.findByServiceName(queueItem.CMN_Service__c);

		System.assertEquals(false, foundItems.isEmpty(), 'No queue items were saved as expected.');
		System.assertEquals(CMN_DAL_WebserviceCallQueue.STATUS_FAILED, foundItems.iterator().next().CMN_Status__c, 'Service status is incorrect.');
	}

	/**
	 * @description create a request dto used to do a synchronous call from an invocable method
	 *
	 * @return request DTO
	 */
	private static CMN_FACTORY_WebserviceManager.DTO_Request setupRequestDto()
	{
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = new CMN_FACTORY_WebserviceManager.DTO_Request();

		dtoRequest.triggerObjectId = UserInfo.getUserId();
		dtoRequest.webServiceClassName = CMN_API_RestOutboundExample.class.getName();
		dtoRequest.transformToTable = true;

		return dtoRequest;
	}

	/**
	 * @description Will test that service class is execute successfully through invocable class and returns a table response
	 */
	@IsTest
	private static void invokeSuccessfulWithTableResponse()
	{
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		dtoRequest.parameters = 'foo=bar,bar=foo';

		Test.startTest();

		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses =
				CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});

		Test.stopTest();

		System.assertEquals(false, dtoResponses.isEmpty(), 'No responses received');
		System.assertEquals(true, CMN_UTIL_String.contains(dtoResponses.iterator().next().payload, 'bar'), 'Parameter not processed correctly');

		Map<String, Object> attributeMap = (Map<String, Object>)JSON.deserializeUntyped(dtoResponses.iterator().next().payload);
		List<Object> dtoColumns = (List<Object>)attributeMap.get('columns');
		System.assertNotEquals(true, dtoColumns.isEmpty(), 'Table has no columns.');

		List<Object> dtoRows = (List<Object>)attributeMap.get('rows');
		System.assertNotEquals(true, dtoRows.isEmpty(), 'Table has no rows.');

	}

	/**
	 * @description Will test that passing parameters with a custom delimiter is processed correctly
	 */
	@IsTest
	private static void invokeSuccessfulCallWithAlternativeParameterDelimiter()
	{
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		dtoRequest.parameters = 'foo=bar|bar=foo';
		dtoRequest.parameterDelimiter = '|';
		dtoRequest.transformToTable = false;

		Test.startTest();

		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses =
				CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});

		Test.stopTest();

		System.assertEquals(false, dtoResponses.isEmpty(), 'No responses received');
		System.assertEquals(true, dtoResponses.iterator().next().success, 'Call not successful');
		System.assertEquals(true, CMN_UTIL_String.contains(dtoResponses.iterator().next().payload, 'bar'), 'Parameter not processed correctly');
	}

	/**
	 * @description Will test that service class is execute successfully through invocable class a transformed class
	 */
	@IsTest
	private static void invokeSuccessfulWithTransformedResponse()
	{
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		dtoRequest.transformToTable = false;
		dtoRequest.transformClassName = CMN_API_RestOutboundExample.DTO_Table.class.getName();

		Test.startTest();

		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses =
				CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});

		Test.stopTest();

		System.assertEquals(false, dtoResponses.isEmpty(), 'No responses received');

		Map<String, Object> attributeMap = (Map<String, Object>)JSON.deserializeUntyped(dtoResponses.iterator().next().payload);
		List<Object> dtoColumns = (List<Object>)attributeMap.get('columns');
		System.assertNotEquals(true, dtoColumns.isEmpty(), 'Table has no columns.');

		List<Object> dtoRows = (List<Object>)attributeMap.get('rows');
		System.assertNotEquals(true, dtoRows.isEmpty(), 'Table has no rows.');

	}

	/**
	 * @description Will test that service class is execute successfully through invocable class and returns a element value from the response JSON
	 */
	@IsTest
	private static void invokeSuccessfulWithElementValueResponse()
	{
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		dtoRequest.transformToTable = false;
		dtoRequest.elementName = CMN_API_RestOutboundExample.TITLE_FIELD_NAME;

		Test.startTest();

		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses =
				CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});

		Test.stopTest();

		System.assertEquals(false, dtoResponses.isEmpty(), 'No responses received');
		System.assertEquals(true, String.isNotBlank(dtoResponses.iterator().next().elementValue), 'Element value was not extracted');
	}

	/**
	 * @description Will test that service class is execute successfully through invocable class and fails silently if the element request is invalid
	 */
	@IsTest
	private static void invokeSuccessfulWithFailedElementValueResponse()
	{
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		dtoRequest.transformToTable = false;
		String arrayAccess = '[0]';
		dtoRequest.elementName = arrayAccess;

		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses =
				CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});

		Test.stopTest();

		System.assertEquals(false, dtoResponses.isEmpty(), 'No responses received');
		System.assertEquals(true, String.isNotBlank(dtoResponses.iterator().next().elementValue), 'Element error was not extracted');
		List<CMN_AppLog__c> appLogs = CMN_DAL_AppLog.getAll();
		System.assertEquals(false, appLogs.isEmpty(), 'No app logs were found as expected.');
	}

	/**
	 * @description Will test that service class is execute successfully through invocable class and returns a table response
	 */
	@IsTest
	private static void invokeSuccessfulWithInvalidTransformClassName()
	{
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		dtoRequest.transformToTable = false;
		dtoRequest.transformClassName = CMN_API_RestOutboundExample.class.getName();

		Test.startTest();

		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses =
				CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});

		Test.stopTest();

		System.assertEquals(false, dtoResponses.isEmpty(), 'No responses received');
		System.assertEquals(true, dtoResponses.iterator().next().payload.contains(CMN_API_HttpBaseOutbound.ERROR_INVALID_TYPE), 'Exception not thrown');

	}

	/**
	 * @description Will test that service class is execute successfully through invocable class but should not return a table structure
	 */
	@IsTest
	private static void invokeSuccessfulWithStandardResponse()
	{
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		dtoRequest.transformToTable = false;

		Test.startTest();

		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses =
				CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});

		Test.stopTest();

		System.assertEquals(false, dtoResponses.isEmpty(), 'No responses received');
		Map<String, Object> attributeMap = (Map<String, Object>)JSON.deserializeUntyped(dtoResponses.iterator().next().payload);
		List<Object> dtoColumns = (List<Object>)attributeMap.get('columns');
		System.assertEquals(null, dtoColumns, 'Response should not be a table');
	}

	/**
	 * @description Test that if a handler has a failed call then response is still returned of the errors
	 */
	@IsTest
	private static void invokeFail()
	{
		CMN_API_HttpBaseOutboundMock.returnErrorResponse = true;

		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();

		Test.startTest();

		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses =
				CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});

		Test.stopTest();

		System.assertEquals(false, dtoResponses.isEmpty(), 'No responses received');
	}

	/**
	 * @description Will check the handling of parameters when invoking web service
	 */
	@IsTest
	private static void invokeWithInvalidParameter()
	{
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		dtoRequest.parameters = 'foo=bar=foo';

		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});

		Test.stopTest();

		List<CMN_AppLog__c> appLogs = CMN_DAL_AppLog.getAll();

		System.assertNotEquals(true, appLogs.isEmpty(), 'Invalid parameter not logged');
	}
}