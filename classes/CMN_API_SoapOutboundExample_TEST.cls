/**
 * @description Test class for CMN_API_SoapOutboundExample
 *
 * @see CMN_API_SoapOutboundExample
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date Apr 2021, August 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_API_SoapOutboundExample_TEST
{
	private static final String SERVICE_NAME = CMN_API_SoapOutboundExample.class.getName();

	/**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void successful()
	{
		Map<String, String> parameters = new Map<String, String>
		{
				CMN_API_SoapOutboundExample.PARAMETER_UBI_NUM => CMN_DAL_SObjectDomain.generateRandomNumber()

		};

		CMN_API_SoapOutboundExample handler =
				(CMN_API_SoapOutboundExample)CMN_API_RestBaseOutboundTestHelper.successfulCall(SERVICE_NAME, null, parameters);
		CMN_API_SoapOutboundExample.DTO_Response dtoResponse = (CMN_API_SoapOutboundExample.DTO_Response)handler.baseResponseDTO;

		Assert.isTrue(String.isNotBlank(dtoResponse.NumberToWordsResult), 'Response not parsed correctly');
	}

	/**
	 * @description Checks that the call is aborted because required parameters were not provided
	 *
	 * @see CMN_API_SoapOutboundExample.getRequiredParameters
	 */
	@IsTest
	private static void abortNoParameter()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(SERVICE_NAME, null, CMN_DAL_SObjectDomain.generateRandomName());
	}

	/**
	 * @description Checks that the call is aborted because the API has been disabled for the current user
	 */
	@IsTest
	private static void abortAPIDisabled()
	{
		CMN_DAL_DataFactory.disableAPI(SERVICE_NAME);
		Map<String, String> parameters = new Map<String, String>
		{
				CMN_API_SoapOutboundExample.PARAMETER_UBI_NUM => CMN_DAL_SObjectDomain.generateRandomNumber()

		};

		CMN_API_RestBaseOutboundTestHelper.abortedCall(SERVICE_NAME, null, parameters);
	}
}