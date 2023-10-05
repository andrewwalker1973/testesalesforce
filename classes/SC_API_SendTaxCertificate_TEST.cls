/**
 * @description Test class for SC_API_SendTaxCertificate
 *
 * @see SC_API_SendTaxCertificate @story ST-147578
 *
 * @author darrion.james.singh@accenture.com jason.van.beukering@accenture.com
 *
 * @date December 2021, April 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class SC_API_SendTaxCertificate_TEST
{
	/**
	 * @description Check that the service abort if the personId parameter is missing
	 *
	 * @see SC_API_SendTaxCertificate.abortRequest
	 */
	@IsTest
	private static void abortedCallBlankPersonId()
	{
		Map<String, String> requestParameters = new Map<String, String>
		{
				CMN_API_GuidedInteraction.PARAMETER_REQUEST_BODY => CMN_DAL_SObjectDomain.generateRandomName(),
				SC_API_SendTaxCertificate.PARAMETER_PERSON_ID => CMN_UTIL_String.EMPTY
		};

		CMN_API_RestBaseOutboundTestHelper.abortedCall(SC_API_SendTaxCertificate.SERVICE_NAME, null, requestParameters);
	}

	/**
	 * @description Check that the service provides the required tax certificates
	 */
	@IsTest
	private static void successfulCall()
	{
		Map<String, String> requestParameters = new Map<String, String>
		{
				CMN_API_GuidedInteraction.PARAMETER_REQUEST_BODY => CMN_DAL_SObjectDomain.generateRandomName(),
				SC_API_SendTaxCertificate.PARAMETER_PERSON_ID => AW_UTIL_IdentityNumber.generateRandomIdentityNumber()
		};

		CMN_API_RestBaseOutboundTestHelper.successfulCall(SC_API_SendTaxCertificate.SERVICE_NAME, null, requestParameters);
	}
}