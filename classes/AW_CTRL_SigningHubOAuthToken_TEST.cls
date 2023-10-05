/**
 * @description Test class related to the AW_CTRL_SigningHubOAuthToken
 *
 * @see AW_CTRL_SigningHubOAuthToken
 *
 * @author Accenture
 *
 * @date August 2021
 **/
@IsTest(SeeAllData=false IsParallel=true)
public class AW_CTRL_SigningHubOAuthToken_TEST
{
	/**
	 * @description Create the test data
	 */
	@TestSetup
	private static void setup()
	{
		AW_DAL_TestDataFactory.insertEnvelope();
	}

	/**
	 * @description Will check that the controller will return the auth token for the given Envelope Id
	 */
	@IsTest
	private static void controllerReturnResults()
	{
		List<AW_Envelope__c> envelopes = AW_DAL_Envelope.getAll();
		AW_Envelope__c envelope = envelopes.iterator().next();

		Test.startTest();

		AW_CTRL_SigningHubOAuthToken.DTO_Response dtoResponse = AW_CTRL_SigningHubOAuthToken.fetchOAuthToken(envelope.Id);

		Test.stopTest();

		System.assertEquals(true, dtoResponse.callSuccessful, 'OAuth token not fetched as expected');
		System.assert(String.isNotBlank(dtoResponse.oAuthTokenOrErrorMessage), 'oAuthTokenOrErrorMessage is blank');
	}

	/**
	 * @description Will test the failed execution of the fetch OAuth token request
	 */
	@IsTest
	private static void failedOAuthTokenFetch()
	{
		Test.startTest();

		AW_CTRL_SigningHubOAuthToken.DTO_Response dtoResponse = AW_CTRL_SigningHubOAuthToken.fetchOAuthToken(UserInfo.getUserId());

		Test.stopTest();

		System.assertEquals(false, dtoResponse.callSuccessful, 'Fetching the auth token did not fail as expected');
		System.assert(String.isNotBlank(dtoResponse.oAuthTokenOrErrorMessage), 'oAuthTokenOrErrorMessage is blank');
	}
}