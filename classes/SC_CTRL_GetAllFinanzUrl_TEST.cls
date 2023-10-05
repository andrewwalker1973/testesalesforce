/**
 * @description Class testing the functionality of AllFinanz URL retrieval controller
 *
 * @see SC_API_GetAllFinanzUrl
 * @see SC_CTRL_GetAllFinanzUrl
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date August 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class SC_CTRL_GetAllFinanzUrl_TEST
{
	/**
	 * @description Will check that behaviour of controller for successful url retrieval
	 *
	 * @see SC_CTRL_GetAllFinanzUrl.getUrl
	 */
	@IsTest
	private static void getUrl()
	{
		Test.startTest();

		SC_CTRL_GetAllFinanzUrl.DTO_Response dtoResponse = SC_CTRL_GetAllFinanzUrl.getUrl(AW_UTIL_IdentityNumber.generateRandomIdentityNumber(), CMN_DAL_SObjectDomain.generateRandomNumber());

		Test.stopTest();

		System.assertEquals(true, dtoResponse.callSuccessful, 'Call did not complete successfully');
		System.assertEquals(true, String.isNotBlank(dtoResponse.interviewUrlOrErrorMessage), 'Url was not set as expected');
	}

	/**
	 * @description Will check that behaviour of controller for failed url retrieval
	 *
	 * @see SC_CTRL_GetAllFinanzUrl.getUrl
	 */
	@IsTest
	private static void errorThrown()
	{
		CMN_API_HttpBaseOutboundMock.returnErrorResponse = true;

		Test.startTest();

		SC_CTRL_GetAllFinanzUrl.DTO_Response dtoResponse = SC_CTRL_GetAllFinanzUrl.getUrl(AW_UTIL_IdentityNumber.generateRandomIdentityNumber(), CMN_DAL_SObjectDomain.generateRandomNumber());

		Test.stopTest();

		System.assertNotEquals(true, dtoResponse.callSuccessful, 'Call did not fail as expected');
		System.assertEquals(SC_API_GetAllFinanzUrl.ERROR_NO_INTERVIEW, dtoResponse.interviewUrlOrErrorMessage, 'Incorrect Error Message returned');
	}
}