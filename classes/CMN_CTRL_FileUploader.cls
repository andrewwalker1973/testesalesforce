/**
 * @description This class is to get the base url and session id of the current logged in user
 *
 * @see CMN_CTRL_FileUploader_TEST
 *
 * @author bhanumurty.rayala@liberty.co.za
 *
 * @date January 2023
 */
public inherited sharing class CMN_CTRL_FileUploader
{
	private static final String BASE_URL_SERVICE = '/services/data/v56.0/sobjects/ContentVersion';

	/**
	 * @description return the Session Id of the current logged in user
	 *
	 * @return Session Id
	 */
	@AuraEnabled(Cacheable=true)
	public static String getSessionId()
	{
		return CMN_API_HttpBase.HTTP_AUTH_TOKEN_BEARER + CMN_UTIL_System.getApiEnabledSessionId();
	}

	/**
	 * @description returns the endpoint url of the service to be called
	 *
	 * @return Endpoint URL
	 */
	@AuraEnabled(Cacheable=true)
	public static String getBaseURL()
	{
		return Url.getSalesforceBaseUrl().toExternalForm() + BASE_URL_SERVICE;
	}
}