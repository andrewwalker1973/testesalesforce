/**
 * @description Test class to test the Outbound API call
 *
 * @see CMN_API_RestOutboundExample
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date 2019, July 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_API_RestOutboundExample_TEST
{
	private static final String SERVICE_NAME = CMN_API_RestOutboundExample.class.getName();

	/**
	 * @description To setup the List of Webservice Call Queue
	 *
	 * @return A list of queue items
	 */
	private static List<CMN_WebserviceCallQueue__c> setup()
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
				(
						SERVICE_NAME,
						UserInfo.getUserId(),
						CMN_DAL_SObjectDomain.generateRandomName(),
						CMN_DAL_SObjectDomain.generateRandomName()
				);

		return new List<CMN_WebserviceCallQueue__c> {queueItem};
	}

	/**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void successful()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCall(setup());
	}

	/**
	 * @description Emulates a successful call and then checks that transformation code complete successfully
	 */
	@IsTest
	private static void successfulWithTransformer()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCallWithTransformation(SERVICE_NAME, UserInfo.getUserId(), 'CMN_API_RestOutboundExample.DTO_Table');
	}

	/**
	 * @description Emulates a successful call and then checks that call was successful, but class name provided is invalid
	 */
	@IsTest
	private static void successfulWithInvalidTransformerClass()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCallWithInvalidTransformation(SERVICE_NAME, UserInfo.getUserId(), UserInfo.getUserId());
	}

	/**
	 * @description Emulates a successful call and then checks that call was successful, but class name provided is invalid
	 */
	@IsTest
	private static void successfulWithWrongTransformClassType()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCallWithInvalidTransformation(SERVICE_NAME, UserInfo.getUserId(), SERVICE_NAME);
	}

	/**
	 * @description Emulates a successful call using simpler alternative
	 */
	@IsTest
	private static void successfulAlternative()
	{
		CMN_API_HttpBase handler = CMN_API_RestBaseOutboundTestHelper.successfulCall(SERVICE_NAME, UserInfo.getUserId());
		Assert.isFalse(handler.callResult.mocking, 'Service Handler should not be mocking');
	}

	/**
	 * @description Emulates a successful call using a single parameter
	 */
	@IsTest
	private static void successfulWithSingleParameter()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCall(SERVICE_NAME, UserInfo.getUserId(), CMN_DAL_SObjectDomain.generateRandomName());
	}

	/**
	 * @description Emulates a successful call using parameters
	 */
	@IsTest
	private static void successfulWithParameters()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCall(SERVICE_NAME, UserInfo.getUserId(), new Set<String> {CMN_DAL_SObjectDomain.generateRandomName()});
	}

	/**
	 * @description Emulates a successful call using parameter map
	 */
	@IsTest
	private static void successfulWithParameterMap()
	{
		Map<String, String> parameters = new Map<String, String>
		{
				CMN_DAL_SObjectDomain.generateRandomName() => CMN_DAL_SObjectDomain.generateRandomName()

		};

		CMN_API_RestBaseOutboundTestHelper.successfulCall(SERVICE_NAME, UserInfo.getUserId(), parameters);
	}

	/**
	 * @description Retrieves the response as a Table using parameter input on helper class method
	 *
	 * @see CMN_API_HttpBaseOutbound.getResponseAsTable
	 * @see CMN_API_RestOutboundExample.DTO_Table.transform
	 */
	@IsTest
	private static void responseAsTableUsingParameterMap()
	{
		Map<String, String> parameters = new Map<String, String>
		{
				CMN_DAL_SObjectDomain.generateRandomName() => CMN_DAL_SObjectDomain.generateRandomName()

		};

		CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer(SERVICE_NAME, UserInfo.getUserId(), parameters);
	}

	/**
	 * @description Retrieves the response as a Table
	 *
	 * @see CMN_API_HttpBaseOutbound.getResponseAsTable
	 * @see CMN_API_RestOutboundExample.DTO_Table.transform
	 */
	@IsTest
	private static void getResponseAsTable()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer(SERVICE_NAME, UserInfo.getUserId());
	}

	/**
	 * @description Retrieves the response as a Table with alternative test that injects in a parameter
	 *
	 * @see CMN_API_HttpBaseOutbound.getResponseAsTable
	 * @see CMN_API_RestOutboundExample.DTO_Table.transform
	 */
	@IsTest
	private static void getResponseAsTableAlternative()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer(SERVICE_NAME, UserInfo.getUserId(), CMN_DAL_SObjectDomain.generateRandomName());
	}

	/**
	 * @description Emulates a failed call
	 */
	@IsTest
	private static void failedCall()
	{
		CMN_API_RestBaseOutboundTestHelper.failedCall(setup());
	}

	/**
	 * @description Emulates a failed call due to response parse failure
	 */
	@IsTest
	private static void parseFailed()
	{
		CMN_API_RestBaseOutboundTestHelper.parseFailed(setup());
	}

	/**
	 * @description Emulates a call that is aborted because no ID was provided
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	@IsTest
	private static void abortedNoId()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(SERVICE_NAME, null);
	}

	/**
	 * @description Emulates a call that is aborted because no ID was provided, uses an overload method that takes a parameter map
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	@IsTest
	private static void abortedWithParameters()
	{
		Map<String, String> parameterMap = new Map<String, String>
		{
				CMN_DAL_SObjectDomain.generateRandomName() => CMN_DAL_SObjectDomain.generateRandomName()

		};

		CMN_API_RestBaseOutboundTestHelper.abortedCall(SERVICE_NAME, null, parameterMap);
	}

	/**
	 * @description Emulates a call that is aborted because the API has been disabled for the current user
	 */
	@IsTest
	private static void abortAPIDisabled()
	{
		CMN_DAL_DataFactory.disableAPI(SERVICE_NAME);
		CMN_API_RestBaseOutboundTestHelper.abortedCall(setup());
	}

	/**
	 * @description Emulates a call that is returns a mock response because the API has been mocked for the current user
	 */
	@IsTest
	private static void mockAPI()
	{
		CMN_DAL_DataFactory.mockAPI(SERVICE_NAME);
		CMN_API_HttpBase handler = CMN_API_RestBaseOutboundTestHelper.successfulCall(SERVICE_NAME, UserInfo.getUserId());
		Assert.isTrue(handler.callResult.mocking, 'Service Handler is not mocking as expected');
	}

	/**
	 * @description Tests to see if the getBaseURL works as expected
	 */
	@IsTest
	private static void getBaseUrl()
	{
		CMN_API_RestOutboundExample service = new CMN_API_RestOutboundExample();

		Test.startTest();

		String baseUrl = service.getBaseUrl();

		Test.stopTest();

		Assert.areNotEqual(service.getWebServiceEndPoint(), baseUrl, 'Invalid base URL');
	}

	/**
	 * @description Ensures that use of DTO Json base class throws error for a method that should be overridden
	 *
	 * @see CMN_DTO_JsonBase.getObjectType
	 * @see CMN_DTO_JsonBase.deserialize
	 */
	@IsTest
	private static void checkJsonDtoMethodOverrideThrowsError()
	{
		CMN_DTO_Base dtoMethodOverride = new DTO_IncorrectlyImplemented();

		Test.startTest();

		try
		{
			dtoMethodOverride = dtoMethodOverride.deserialize(CMN_UTIL_String.EMPTY_JSON_RESPONSE);
			Assert.fail('Exception not thrown as expected.');
		}
		catch(JSONException jsonError)
		{
			Assert.isTrue(true, 'Exception Thrown as expected');
		}

		Test.stopTest();
	}

	/**
	 * @description Ensures that use of DTO Json base class works as expected when deserializing if getObjectType is implemented
	 *
	 * @see CMN_DTO_JsonBase.getObjectType
	 * @see CMN_DTO_JsonBase.deserialize
	 */
	@IsTest
	private static void checkJsonDtoMethodOverride()
	{
		CMN_DTO_Base dtoMethodOverride = new CMN_DTO_JsonBase();

		Test.startTest();

		try
		{
			dtoMethodOverride = dtoMethodOverride.deserialize(CMN_UTIL_String.EMPTY_JSON_RESPONSE);
			Assert.isTrue(true, 'No exception thrown as expected');
		}
		catch(JSONException jsonError)
		{
			Assert.fail('Exception was Thrown');
		}

		Test.stopTest();
	}

	/**
	 * @description Emulates a aborted call with exception
	 */
	@IsTest
	private static void abortedWithException()
	{
		CMN_DAL_DataFactory.disableAPI(SERVICE_NAME);
		CMN_API_RestBaseOutboundTestHelper.abortedCall(setup(), CMN_API_HttpBase.ERROR_API_DISABLED);
	}

	/**
	 * @description Used to check that getObjectType works correctly
	 *
	 * @see CMN_DTO_JsonBase.getObjectType
	 */
	private class DTO_IncorrectlyImplemented extends CMN_DTO_JsonBase
	{

	}
}