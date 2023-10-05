/**
 * @description Unit tests for SC_API_SendClientPolicyPrint methods
 *
 * @see SC_API_SendClientPolicyPrint
 *
 * @author darrion.james.singh@accenture.com
 *
 * @date January 2022
 */
@IsTest
private class SC_API_SendClientPolicyPrint_TEST
{
	/**
	 * @description Successful CPP call when request body is present
	 */
	@IsTest
	private static void successfulClientPolicyPrintCall()
	{
		Map<String, String> requestParameters = new Map<String, String>
		{
				CMN_API_GuidedInteraction.PARAMETER_REQUEST_BODY => CMN_DAL_SObjectDomain.generateRandomName()
		};

		CMN_API_RestBaseOutboundTestHelper.successfulCall(SC_API_SendClientPolicyPrint.SERVICE_NAME, null, requestParameters);
	}

	/**
	 * @description Check to see a CPP call is aborted without request body parameter
	 */
	@IsTest
	private static void abortedClientPolicyPrintCall()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(SC_API_SendClientPolicyPrint.SERVICE_NAME, null);
	}
}