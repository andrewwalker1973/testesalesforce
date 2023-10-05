/**
 * @description Test class for AW_API_RestOutboundClientUpdated
 *
 * @see AW_API_RestOutboundClientUpdated @story ST-2034
 *
 * @author vishakha.saini@accenture.com
 *
 * @date 2019, March 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_API_RestOutboundClientUpdated_TEST
{
	/**
	 * @description Method to setup test data
	 */
	@TestSetup
	private static void setup()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		System.runAs(adviser)
		{
			AW_DAL_TestDataFactory.createClientAccount();
		}
	}

	/**
	 * @description Test Method to validate the scenario wherein successful outbound API call is made to send Client profile updates to Mulesoft
	 */
	@IsTest
	private static void successfulCall()
	{
		Account newAccount = AW_DAL_Account.getAll().iterator().next();

		System.runAs(newAccount.Owner)
		{
			CMN_API_RestBaseOutboundTestHelper.successfulCall(AW_API_RestOutboundClientUpdated.SERVICE_NAME, newAccount.Id);
		}
	}
}