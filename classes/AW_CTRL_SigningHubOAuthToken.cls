/**
 * @description Controller for retrieving the OAuth token for SigningHub
 *
 * @see AW_API_GetSigningHubOAuthToken @story 166448
 * @see AW_CTRL_SigningHubOAuthToken_TEST
 *
 * @author nihal.desai@accenture.com
 *
 * @date August 2021
 */
public inherited sharing class AW_CTRL_SigningHubOAuthToken
{
	public static final String ERROR_GENERAL_TEMPLATE = 'Access Token could not be fetched. Status Code: {0}, Status: {1}';

	/**
	 * @description Will retrieve a unique OAuth token
	 *
	 * @param envelopeId Id of the Envelope
	 *
	 * @return A unique OAuth token which will be passed along with the url to the iFrame
	 */
	@AuraEnabled
	public static DTO_Response fetchOAuthToken(Id envelopeId)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_GetSigningHubOAuthToken.SERVICE_NAME, envelopeId);
		List<CMN_API_HttpBase> handlers = CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem});
		AW_API_GetSigningHubOAuthToken fetchOAuthTokenHandler = (AW_API_GetSigningHubOAuthToken)handlers.iterator().next();

		DTO_Response dtoResponse = new DTO_Response();

		if(String.isNotBlank(fetchOAuthTokenHandler?.accessToken))
		{
			dtoResponse.callSuccessful = true;
			dtoResponse.oAuthTokenOrErrorMessage = fetchOAuthTokenHandler.accessToken;
		}
		else
		{
			List<String> errors = fetchOAuthTokenHandler?.callResult?.errors;
			String errorMessage = (errors?.size() > 0) ? String.join(errors, CMN_UTIL_String.LF) : String.format(ERROR_GENERAL_TEMPLATE, new List<String> {fetchOAuthTokenHandler?.callResult?.statusCode, fetchOAuthTokenHandler?.callResult?.statusText});

			dtoResponse.callSuccessful = false;
			dtoResponse.oAuthTokenOrErrorMessage = errorMessage;
		}

		return dtoResponse;
	}

	/**
	 * @description Provides the outcome of the request
	 */
	public class DTO_Response
	{
		@AuraEnabled
		public Boolean callSuccessful;
		@AuraEnabled
		public String oAuthTokenOrErrorMessage;
	}
}