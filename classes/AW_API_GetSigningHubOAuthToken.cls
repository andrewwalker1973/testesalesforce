/**
 * @description Service class to make the API call to retrieve Authentication details from SigningHub via Mulesoft
 *
 * @see AW_API_GetSigningHubOAuthToken_TEST @story ST-166458
 *
 * @author Accenture
 *
 * @date July 2021
 */
public inherited sharing class AW_API_GetSigningHubOAuthToken extends CMN_API_RestBaseOutboundMule
{
	private static final String ERROR_NO_ENVELOPE_FOUND = 'Unable to process request as no Envelope was found';
	public static final String SERVICE_NAME = AW_API_GetSigningHubOAuthToken.class.getName();

	/**
	 * @description Access token after authentication call
	 */
	public String accessToken
	{
		get
		{
			return ((DTO_Response)baseResponseDTO).access_token;
		}
	}

	/**
	 * @description Override to set request and response DTO types and any other globals which may be used
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();

	}

	/**
	 * @description Override to get Service name to be used when looking up custom settings for the service
	 *
	 * @return String Returns service name as string
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Override to validate if all the information required to make API call is available
	 *
	 * @return Boolean Returns true if all the information is present, else will return false
	 */
	protected override Boolean abortRequest()
	{
		Boolean mustAbort = super.abortRequest();

		if(!mustAbort)
		{
			AW_Envelope__c foundEnvelope = AW_DAL_Envelope.findById(queueItem.CMN_TriggeringObjectId__c);

			if(foundEnvelope == null)
			{
				mustAbort = true;
				callResult.errors.add(ERROR_NO_ENVELOPE_FOUND);
			}
			else
			{
				((DTO_Request)baseRequestDTO).envelope = foundEnvelope;
			}
		}

		return mustAbort;

	}

	/**
	 * @description Inner class to define structure of request body and populate the same for API call
	 */
	public class DTO_Request extends CMN_DTO_JsonBase
	{
		private String scope;

		public transient AW_Envelope__c envelope; //Defining as transient so that envelope is not serialized when sending the request JSON

		public override void populate(Id triggeringObjectId)
		{
			super.populate(triggeringObjectId);

			Id ownerId = envelope.OwnerId;
			scope = AW_DAL_User.findById(ownerId).Email;

		}
	}

	/**
	 * @description Inner class to define structure of response body
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		private String access_token; //NOPMD - valid OAuth Response property

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_Response.class;
		}
	}

	/**
	 * @description Override to return mock response for test class
	 *
	 * @return CMN_API_HttpBaseOutboundMock AW_API_SigningHubAuthMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new AW_API_GetSigningHubOAuthTokenMock();
	}

	/**
	 * @description Class for creating Moack Response
	 */
	private class AW_API_GetSigningHubOAuthTokenMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"access_token":"some_access_token","token_type":"bearer","expires_in":86399,"refresh_token":"some_refresh_token"}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}