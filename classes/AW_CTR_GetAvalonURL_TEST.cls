/**
 * @description Tests the functionality of AW_CTR_GetAvalonURL
 *
 * @see AW_CTR_GetAvalonURL
 *
 * @author prashant.k.jain@accenture.com
 *
 * @date September 2020, February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_CTR_GetAvalonURL_TEST
{
	private static final Integer NUMBER_OF_RECORDS_TO_CREATE = 1;
	private static final String AVALON_URL = 'https://login-liberty-group-uat.avalon.co.za';
	private static final String ERROR_INVALID_URL = 'The URL does not match what is expected.';

	/**
	 * @description This setup method create records to be used in further test methods
	 */
	@TestSetup
	private static void setup()
	{
		AW_DAL_TestDataFactory.createClientAccount();

		AW_embeddedURL__c newURL = new AW_embeddedURL__c();
		newURL.Name = AW_DAL_FNA.URL_NAME;
		newURL.AW_External_Services__c = AVALON_URL;
		insert newURL;
	}

	/**
	 * @description This test method check if the URL to Avalon created from an account is correctly created.
	 *
	 * @see AW_CTR_GetAvalonURL.getAvalonBaseUrl
	 */
	@IsTest
	private static void getAvalonBaseUrlFromAccount()
	{
		Account newAccount = AW_DAL_Account.getAll().iterator().next();

		Test.startTest();

		String url = AW_CTR_GetAvalonURL.getAvalonBaseUrl(newAccount.Id);

		Test.stopTest();

		String validUrl = String.format(AW_CTR_GetAvalonURL.URL_FORMAT, new List<String> {AVALON_URL, newAccount.AW_SKF_Id__c, newAccount.AW_Owner_UACFID__c});

		System.assertEquals(validUrl, url, ERROR_INVALID_URL);
	}

	/**
	 * @description This test method check if the URL to Avalon created from an Opportunity is correctly created.
	 * 	 *
	 *
	 * @see AW_CTR_GetAvalonURL.getAvalonBaseUrl
	 */
	@IsTest
	private static void getAvalonBaseUrlFromOpportunity()
	{
		Account newAccount = AW_DAL_Account.getAll().iterator().next();
		Opportunity newOpportunity = AW_DAL_TestDataFactory.createDefaultOpportunities(newAccount, NUMBER_OF_RECORDS_TO_CREATE).iterator().next();

		Test.startTest();

		String url = AW_CTR_GetAvalonURL.getAvalonBaseUrl(newOpportunity.Id);

		Test.stopTest();

		newOpportunity = AW_DAL_Opportunity.findById(newOpportunity.Id);
		String validUrl = String.format
				(
						AW_CTR_GetAvalonURL.URL_FORMAT,
						new List<String> {AVALON_URL, newOpportunity?.Account?.AW_SKF_Id__c, newOpportunity?.Account?.AW_Owner_UACFID__c}
				);
		System.assertEquals(validUrl, url, ERROR_INVALID_URL);
	}

	/**
	 * @description This test method check if the URL to Avalon created from an account is correctly created.
	 *
	 * @see AW_CTR_GetAvalonURL.getAvalonBaseUrl
	 */
	@IsTest
	private static void getAvalonBaseUrlNoIdProvided()
	{
		Test.startTest();

		String url = AW_CTR_GetAvalonURL.getAvalonBaseUrl(null);

		Test.stopTest();

		System.assertEquals(AVALON_URL, url, ERROR_INVALID_URL);
	}
}