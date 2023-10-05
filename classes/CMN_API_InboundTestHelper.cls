/**
 * @description Class has base methods that can be used to assist with testing inbound service calls
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date December 2020, July 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
public inherited sharing class CMN_API_InboundTestHelper
{
	private static final String TEST_URL = 'https://example.com/test';
	/**
	 * @description Will setup the RestContext Objects of "request" and "response"
	 *
	 * @param dtoRequest The DTO that should be serialised and represents the JSON sent in a request
	 */
	@TestVisible
	private static void setupRestContext(CMN_DTO_Base dtoRequest)
	{
		setupRestContext();
		RestContext.request.requestBody = Blob.valueOf(dtoRequest.serialize());
	}

	/**
	 * @description Will setup the RestContext Objects of "request" and "response"
	 */
	@TestVisible
	private static void setupRestContext()
	{
		RestContext.request = new RestRequest();
		RestContext.request.headers.put(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
		RestContext.request.httpMethod = CMN_API_HttpBase.HTTP_VERB_POST;
		RestContext.request.requestURI = TEST_URL;

		RestContext.response = new RestResponse();
	}

	/**
	 * @description Will execute a call out and ensure that the call aborted (due to API being disabled)
	 *
	 * @param serviceName The name of the inbound  webservice handler
	 * @param dtoRequest The request being sent the handler
	 * @param exceptionMessage The message expected in the response/errors payload
	 *
	 * @return An instance of the handler, in case further checks are necessary
	 */
	@TestVisible
	private static CMN_API_HttpBase assertCallAborted(String serviceName, CMN_DTO_Base dtoRequest, String exceptionMessage)
	{
		setupRestContext(dtoRequest);
		return assertCallAborted(serviceName, exceptionMessage);
	}

	/**
	 * @description Will execute a call out and ensure that the call aborted (due to API being disabled)
	 *
	 * @param serviceName The name of the inbound  webservice handler
	 * @param exceptionMessage The message expected in the response/errors payload
	 *
	 * @return An instance of the handler, in case further checks are necessary
	 */
	@TestVisible
	private static CMN_API_HttpBase assertCallAborted(String serviceName, String exceptionMessage)
	{
		CMN_API_HttpBase handler = assertCallAborted(serviceName);

		Assert.isTrue(handler.callResult.errors.contains(exceptionMessage), 'Incorrect error message');

		return handler;
	}

	/**
	 * @description Will execute a call out and ensure that the call aborted (due to API being disabled)
	 *
	 * @param serviceName The name of the inbound  webservice handler
	 *
	 * @return An instance of the handler, in case further checks are necessary
	 */
	@TestVisible
	private static CMN_API_HttpBase assertCallAborted(String serviceName)
	{
		Test.startTest();

		CMN_API_HttpBase handler = CMN_FACTORY_WebserviceManager.processInboundService(serviceName);

		Test.stopTest();

		Assert.isTrue(handler.callResult.aborted, 'Request not aborted as expected.');
		Assert.isFalse(handler.callResult.errors.isEmpty(), 'No errors thrown');

		return handler;
	}

}