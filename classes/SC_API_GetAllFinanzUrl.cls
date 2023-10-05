/**
 * @description Outbound API class to retrieve an AllFinanz Interview URL based on Identification and Contract Number
 *
 * @see SC_CTRL_GetAllFinanzUrl
 * @see SC_CTRL_GetAllFinanzUrl_TEST
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date August 2021
 */
public inherited sharing class SC_API_GetAllFinanzUrl extends CMN_API_RestBaseOutboundMule
{
	@TestVisible
	private static final String ERROR_NO_INTERVIEW = 'Contract does not qualify for an interview.';
	private static final String ERROR_RESPONSE = '{"error":{"errorCode":3,"errorDateTime":"2021-08-20T09:49:53","errorMessage":"Contract does not qualify","errorDescription":"This contract does not qualify for an interview"}}';
	private static final String ERROR_UNEXPECTED = 'An unexpected error occurred.';
	private static final String VALID_RESPONSE = '{"interviewURL":"https://ais-dev.libertysa.munichre.cloud/allfinanz/screens/view/individual/case/5124/NRS/entity/5124_53759/page/5/basequestions?viewMode=DEFAULT"}';

	public static final String SERVICE_NAME = SC_API_GetAllFinanzUrl.class.getName();

	private static final Map<Integer, String> ERROR_MAP = new Map<Integer, String>
	{
			1 => 'Contract could not be found.',
			2 => 'Invalid Identification or Passport Number.',
			3 => ERROR_NO_INTERVIEW,
			4 => 'Case has already been closed.'
	};

	/**
	 * @description Returns DTO response to be used by Lightning component for redirecting user to atWork
	 */
	public String interviewUrl
	{
		get
		{
			return ((DTO_Response)baseResponseDTO).interviewURL;
		}
	}

	/**
	 * @description If API encounters an error, this method will provide a user friendly error message
	 */
	public String errorMessage
	{
		get
		{
			String message = CMN_UTIL_String.EMPTY;

			if(callResult.failed)
			{
				DTO_ErrorResponse dtoErrorResponse = (DTO_ErrorResponse)JSON.deserialize(callResult.responseBody, DTO_ErrorResponse.class);
				message = ERROR_MAP.get(dtoErrorResponse.error?.errorCode);
				message = String.isBlank(message) ? ERROR_UNEXPECTED : message;
			}

			return message;
		}
	}

	/**
	 * @description Override to set request and response DTO types and any other globals which may be used
	 */
	protected override void initialise()
	{
		super.initialise();

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
	 * @description Override to use Get HTTP Method for API call
	 *
	 * @return the HTTP Verb
	 */
	public override String getVerb()
	{
		return HTTP_VERB_GET;
	}

	/**
	 * @description Indicates if the webservice requires a TriggerObjectId
	 *
	 * @return False, as it's not required for this service
	 */
	protected override Boolean triggeringObjectRequired()
	{
		return false;
	}

	/**
	 * @description Override to return inner class having Mock response
	 *
	 * @return CMN_API_HttpBaseOutboundMock AW_API_RestOutboundGetAtWorkURLMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new SC_API_GetAllFinanzUrlMock();
	}

	/**
	 * @description Will construct endpoint including URL parameters
	 *
	 * @return The final Url to be used for the request
	 */
	protected override String getWebServiceEndPoint()
	{
		return String.format
				(
						super.getWebServiceEndPoint(),
						new List<String>
						{
								queueItem.CMN_PartnerIDNumber__c,
								queueItem.CMN_ClientIDNumber__c
						}
				);
	}

	/**
	 * @description Extension of CMN_DTO_JsonBase class to specify response structure
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		private String interviewURL;

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
	 * @description Used to parse an error response
	 */
	private class DTO_ErrorResponse
	{
		private DTO_Error error;
	}

	/**
	 * @description Detail of error received
	 */
	private class DTO_Error
	{
		private Integer errorCode;
		//private String errorDateTime;
		//private String errorMessage;
		//private String errorDescription;
	}

	/**
	 * @description Mock Response class to be used in test classes for unit testing
	 */
	private class SC_API_GetAllFinanzUrlMock extends CMN_API_HttpBaseOutboundMock
	{

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}

		/**
		 * @description Will set response in the event on exception
		 *
		 * @param response The response object on which to set the relevant body
		 */
		protected override void setErrorResponse(HttpResponse response)
		{
			super.setErrorResponse(response);
			response.setBody(ERROR_RESPONSE);
		}
	}
}