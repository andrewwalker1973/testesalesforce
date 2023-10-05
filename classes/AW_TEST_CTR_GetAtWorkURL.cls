/**
 * @description Test Class for AW_AUTH_AzureB2C
 *
 * @see AW_CTR_GetAtWorkURL
 *
 * @author jason.van.beukering@accenture.com vishakha.saini@accenture.com
 *
 * @date November 2021, February 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class AW_TEST_CTR_GetAtWorkURL
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description To setup the test data
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
	 * @description Test method to test the URL for an account
	 */
	@IsTest
	private static void getUrlFromAccount()
	{
		Account newAccount = AW_DAL_Account.getAll().iterator().next();

		User adviser = AW_DAL_User.findAdviserById(newAccount.OwnerId);

		System.runAs(adviser)
		{
			Test.startTest();

			AW_CTR_GetAtWorkURL.DTO_GetAtWorkUrlResponse dtoResponse = AW_CTR_GetAtWorkURL.getAtWorkURL(newAccount.Id, AW_DAL_User.generateRandomAtWorkUserId());

			Test.stopTest();

			System.assertEquals(true, dtoResponse.callSuccessful, 'Request failed.');
			System.assert(String.isNotBlank(dtoResponse.secureUrlOrErrorMessage), 'No URL returned.');
		}
	}

	/**
	 * @description Test method to test the URL for an account when run as a Person Assistant
	 */
	@IsTest
	private static void getUrlAsPersonalAssistant()
	{
		Account newAccount = AW_DAL_Account.getAll().iterator().next();

		User personalAssistant = AW_DAL_User.findActivePersonalAssistantByAdviser(newAccount.OwnerId);

		System.runAs(personalAssistant)
		{
			Test.startTest();

			AW_CTR_GetAtWorkURL.DTO_GetAtWorkUrlResponse dtoResponse = AW_CTR_GetAtWorkURL.getAtWorkURL(newAccount.Id, AW_DAL_User.generateRandomAtWorkUserId());

			Test.stopTest();

			System.assertEquals(true, dtoResponse.callSuccessful, 'Request failed.');
			System.assert(String.isNotBlank(dtoResponse.secureUrlOrErrorMessage), 'No URL returned.');
		}
	}

	/**
	 * @description Test method to test the URL for an opportunity
	 */
	@IsTest
	private static void getUrlFromOpportunity()
	{
		Account newAccount = AW_DAL_Account.getAll().iterator().next();
		User adviser = AW_DAL_User.findAdviserById(newAccount.OwnerId);

		System.runAs(adviser)
		{
			Opportunity newOpportunity = AW_DAL_TestDataFactory.createDefaultOpportunities(newAccount, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

			Test.startTest();

			AW_CTR_GetAtWorkURL.DTO_GetAtWorkUrlResponse dtoResponse = AW_CTR_GetAtWorkURL.getAtWorkURL(newOpportunity.Id, AW_DAL_User.generateRandomAtWorkUserId());

			Test.stopTest();

			System.assertEquals(true, dtoResponse.callSuccessful, 'Request failed.');
			System.assert(String.isNotBlank(dtoResponse.secureUrlOrErrorMessage), 'No URL returned.');
		}
	}

	/**
	 * @description Will check that if the call is successful (HTTP 200) but the payload returned has an error flag, this is returned as an error
	 */
	@IsTest
	private static void checkErrorOnSuccessfulCall()
	{
		Account newAccount = AW_DAL_Account.getAll().iterator().next();
		User adviser = AW_DAL_User.findAdviserById(newAccount.OwnerId);

		System.runAs(adviser)
		{
			Test.startTest();

			//Make sure the service provides an error response
			AW_API_RestOutboundGetAtWorkURL.returnErrorInResponse = true;

			AW_CTR_GetAtWorkURL.DTO_GetAtWorkUrlResponse dtoResponse = AW_CTR_GetAtWorkURL.getAtWorkURL(newAccount.Id, AW_DAL_User.generateRandomAtWorkUserId());

			Test.stopTest();

			System.assertEquals(false, dtoResponse.callSuccessful, 'Request did not fail as expected.');
			System.assert(String.isNotBlank(dtoResponse.secureUrlOrErrorMessage), 'No error message returned.');
		}
	}

	/**
	 * @description Will check that if the call has failed, status and error message is return
	 */
	@IsTest
	private static void checkErrorOnFailedCall()
	{
		Account newAccount = AW_DAL_Account.getAll().iterator().next();
		User adviser = AW_DAL_User.findAdviserById(newAccount.OwnerId);

		System.runAs(adviser)
		{
			Test.startTest();

			//Make sure the service throws an exception
			CMN_API_HttpBaseOutboundMock.returnErrorResponse = true;

			AW_CTR_GetAtWorkURL.DTO_GetAtWorkUrlResponse dtoResponse = AW_CTR_GetAtWorkURL.getAtWorkURL(newAccount.Id, AW_DAL_User.generateRandomAtWorkUserId());

			Test.stopTest();

			System.assertEquals(false, dtoResponse.callSuccessful, 'Request did not fail as expected.');
			System.assert(String.isNotBlank(dtoResponse.secureUrlOrErrorMessage), 'No error message returned.');
		}
	}

	/**
	 * @description Check to see if correct user record is returned
	 */
	@IsTest
	private static void getUserDetails()
	{
		Account newAccount = AW_DAL_Account.getAll().iterator().next();
		User runAsAdviser = AW_DAL_User.findById(newAccount.OwnerId);
		User accountOwner;
		User accountOwnerForOpportunity;

		System.runAs(runAsAdviser)
		{
			Opportunity newOpportunity = AW_DAL_TestDataFactory.createDefaultOpportunities(newAccount, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

			Test.startTest();

			accountOwner = AW_CTR_GetAtWorkURL.getUserDetails(newAccount.Id);
			accountOwnerForOpportunity = AW_CTR_GetAtWorkURL.getUserDetails(newOpportunity.Id);

			Test.stopTest();
		}

		System.assertEquals(runAsAdviser.Id, accountOwner.Id, 'Incorrect User returned for Account');
		System.assertEquals(accountOwner.Id, accountOwnerForOpportunity.Id, 'Incorrect User returned for Opportunity');
	}

	/**
	 * @description Test method to test the URL
	 */
	@IsTest
	private static void getBaseUrl()
	{
		Account newAccount = AW_DAL_Account.getAll().iterator().next();
		User adviser = AW_DAL_User.findAdviserById(newAccount.OwnerId);

		System.runAs(adviser)
		{
			Test.startTest();

			String baseUrl = AW_CTR_GetAtWorkURL.getBaseUrl();

			System.assertNotEquals(null, baseUrl, 'No base URL returned.');

			Test.stopTest();
		}
	}
}