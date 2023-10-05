/**
 * @description Used by Lightning Component to retrieve the SigningHub URL
 *
 * @see AW_CTR_GetSigningHubURL_TEST
 *
 * @author Annu Agarwal
 *
 * @date May 2021
 */
public inherited sharing class AW_CTR_GetSigningHubURL
{
	@TestVisible
	private static final String URL_NAME = 'SigningHub';

	/**
	 * @description Retrieves base login URL for Signing Hub
	 *
	 * @return Returns the base login URL for Signing Hub from custom settings
	 */
	@AuraEnabled(Cacheable=true)
	public static String getSigningHubBaseUrl()
	{
		//TODO: Can we look to shift to custom metadata instead; its deployable
		AW_embeddedURL__c signingHubURL = AW_embeddedURL__c.getValues(URL_NAME);
		return signingHubURL?.AW_External_Services__c;
	}
}