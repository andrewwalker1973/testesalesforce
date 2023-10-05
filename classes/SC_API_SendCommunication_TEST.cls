/**
 * @description Unit tests for SC_API_SendClientPolicyPrint methods
 *
 * @see SC_API_SendCommunication
 *
 * @author darrion.james.singh@accenture.com prashant.k.jain@accenture.com jason.van.beukering@accenture.com
 *
 * @date January 2022, April 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class SC_API_SendCommunication_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;
	@TestSetup
	private static void setup()
	{
		Account testAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		SC_DAL_DataFactory.createCase(NUMBER_OF_ITEMS_TO_CREATE, testAccount.Id).iterator().next();
	}

	/**
	 * @description Successful Communication email sent when request body and triggering object are present
	 */
	@IsTest
	private static void successfulCommunicationCall()
	{
		Map<String, String> requestParameters = new Map<String, String>
		{
				CMN_API_GuidedInteraction.PARAMETER_REQUEST_BODY => CMN_DAL_SObjectDomain.generateRandomName()
		};
		Case testCase = SC_DAL_Case.getAll().iterator().next();
		CMN_API_RestBaseOutboundTestHelper.successfulCall(SC_API_SendCommunication.SERVICE_NAME, testCase.Id, requestParameters);
	}

	/**
	 * @description Check to see a CPP call is aborted without request body parameter
	 */
	@IsTest
	private static void abortedCommunicationCallNoBody()
	{
		Case testCase = SC_DAL_Case.getAll().iterator().next();
		CMN_API_RestBaseOutboundTestHelper.abortedCall(SC_API_SendCommunication.SERVICE_NAME, testCase.Id);
	}

	/**
	 * @description Check to see a CPP call is aborted without request body parameter
	 */
	@IsTest
	private static void abortedCommunicationCallNoTriggeringObject()
	{
		Map<String, String> requestParameters = new Map<String, String>
		{
				CMN_API_GuidedInteraction.PARAMETER_REQUEST_BODY => CMN_DAL_SObjectDomain.generateRandomName()
		};
		CMN_API_RestBaseOutboundTestHelper.abortedCall(SC_API_SendCommunication.SERVICE_NAME, null, requestParameters);
	}
}