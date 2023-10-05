/**
 * @description test class to test the Inbound API call that will echo exactly what was sent
 *
 * @see CMN_API_RestInboundEcho
 * @see CMN_URL_Echo
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date October 2021, July 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_API_RestInboundEcho_TEST
{
	private static final String SERVICE_NAME = CMN_API_RestInboundEcho.class.getName();

	/**
	 * @description Sets up the Rest request context to mimic an inbound API call
	 *
	 * @return DTO that will be serialised in to the request object
	 */
	private static DTO_InboundTest setupContext()
	{
		DTO_InboundTest inboundRequest = new DTO_InboundTest();
		inboundRequest.helloWorld = CMN_DAL_SObjectDomain.generateRandomName();

		CMN_API_InboundTestHelper.setupRestContext(inboundRequest);
		RestContext.request.addParameter(CMN_DAL_SObjectDomain.generateRandomName(), CMN_DAL_SObjectDomain.generateRandomName());

		return inboundRequest;

	}
	/**
	 * @description This method is use to test a successful call to Echo service
	 */
	@IsTest
	private static void successful()
	{
		DTO_InboundTest inboundRequest = setupContext();

		Test.startTest();

		CMN_URL_Echo.echo();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(SERVICE_NAME);

		Assert.isNotNull(RestContext.response.responseBody, 'Response Body was not set.');
		Assert.areEqual(inboundRequest.serialize(), RestContext.response.responseBody.toString(), 'Response does not match what was expected');
	}

	/**
	 * @description This method is use to test a failed call to Echo service
	 */
	@IsTest
	private static void failed()
	{
		setupContext();
		RestContext.request.addParameter(CMN_API_HttpBaseInbound.QUERY_PARAM_ADD_STACK_TRACE, String.valueOf(true));

		// this will result in an exception is throw
		CMN_API_HttpBaseInbound.returnErrorResponse = true;

		Test.startTest();

		CMN_URL_Echo.echo();

		Test.stopTest();

		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(SERVICE_NAME, CMN_UTIL_String.EMPTY);

		List<String> errors = CMN_UTIL_System.convertStringToList(queueItems.iterator().next().CMN_Errors__c, CMN_UTIL_String.CRLF);

		Assert.areEqual(2, errors.size(), 'Expected Error Message and Stack Trace');
		Assert.areEqual(CMN_API_HttpBaseInbound.ERROR_TEST_EXCEPTION_HANDLING, errors.iterator().next(), 'Invalid Error Message');
	}

	/**
	 * @description Emulates a call that is aborted because all APIs have been disabled for the current user and checks that message is correct
	 */
	@IsTest
	private static void abortApiDisabled()
	{
		CMN_DAL_DataFactory.disableAPI(SERVICE_NAME);

		DTO_InboundTest inboundRequest = new DTO_InboundTest();
		inboundRequest.helloWorld = CMN_DAL_SObjectDomain.generateRandomName();

		CMN_API_RestInboundEcho handler =
				(CMN_API_RestInboundEcho)CMN_API_InboundTestHelper.assertCallAborted(SERVICE_NAME, inboundRequest, CMN_API_HttpBase.ERROR_API_DISABLED);
		Assert.areEqual(String.valueOf(CMN_API_HttpBase.HTTP_SERVICE_UNAVAILABLE), handler.callResult.statusCode, 'Status Code not set correctly');
		Assert.areEqual(CMN_API_HttpBase.HTTP_SERVICE_UNAVAILABLE, RestContext.response.statusCode, 'Status Code not set correctly');
	}

	/**
	 * @description Class used to generate a test JSON payload to test the API
	 */
	private class DTO_InboundTest extends CMN_DTO_JsonBase
	{
		public String helloWorld;

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_InboundTest.class;
		}
	}
}