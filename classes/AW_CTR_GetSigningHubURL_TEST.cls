/**
 * @description This class is the test class for AW_CTR_GetSigningHubURL
 *
 * @see AW_CTR_GetSigningHubURL
 *
 * @author Annu Agarwal
 *
 * @date May 2021
 **/
@IsTest(SeeAllData=false IsParallel=true)
private class AW_CTR_GetSigningHubURL_TEST
{
	/**
	 * @description This test method check if the URL for Signing Hub passed correctly.
	 **/
	@IsTest
	private static void getSigningHubBaseUrl()
	{
		//TODO: This code should be in a data factory
		AW_embeddedURL__c signHubURL = new AW_embeddedURL__c();
		signHubURL.Name = AW_CTR_GetSigningHubURL.URL_NAME;
		signHubURL.AW_External_Services__c = CMN_DAL_SObjectDomain.generateRandomName();

		insert signHubURL;

		Test.startTest();

		String resultURL = AW_CTR_GetSigningHubURL.getSigningHubBaseUrl();

		Test.stopTest();

		System.assertEquals(signHubURL.AW_External_Services__c, resultURL, 'The URL to Signing Hub does not match what is expected.');
	}
}