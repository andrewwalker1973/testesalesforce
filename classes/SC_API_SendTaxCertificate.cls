/**
 * @description Service class to make the API call to send tax certificates.
 *
 * @see SC_API_SendTaxCertificate_TEST @story ST-147578
 *
 * @author darrion.james.singh@accenture.com jason.van.beukering@accenture.com
 *
 * @date December 2021, April 2022
 */
public inherited sharing class SC_API_SendTaxCertificate extends CMN_API_GuidedInteraction
{
	private static final String ERROR_PERSON_ID_NOT_VALID = 'Unable to process request as the "personId" parameter is blank.';

	/**
	 * @description Required parameter to be passed to the handler else call will be aborted
	 */
	@TestVisible
	private static final String PARAMETER_PERSON_ID = 'personId';

	/**
	 * @description Service name to be referenced in webservice settings and test classes.
	 */
	public static final String SERVICE_NAME = SC_API_SendTaxCertificate.class.getName();

	/**
	 * @description Override to set request and response DTO types and any other globals which may be used
	 */
	protected override void initialise()
	{
		super.initialise();
		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description Check to see if the request should be aborted due the information provided
	 *
	 * @return If true, the API handler will stop processing the request
	 */
	protected override Boolean abortRequest()
	{
		Boolean abort = super.abortRequest();

		if(!abort)
		{
			if(String.isBlank(requestParameters.getFirst(PARAMETER_PERSON_ID)))
			{
				callResult.errors.add(ERROR_PERSON_ID_NOT_VALID);
				abort = true;
			}
		}

		return abort;
	}

	/**
	 * @description Override to construct API endpoint
	 *
	 * @return String Complete API Endpoint
	 */
	protected override String getWebServiceEndPoint()
	{
		return String.format
				(
						super.getWebServiceEndPoint(),
						new List<String> {EncodingUtil.urlEncode(requestParameters.getFirst(PARAMETER_PERSON_ID), UTF8_ENCODING_SCHEME)}
				);
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
	 * @description Inner class to define structure of response body
	 *
	 * @return True
	 */
	protected override Boolean hasArrayResponse()
	{
		return true;
	}

	/**
	 * @description Defines if triggering object is required
	 *
	 * @return Boolean
	 */
	protected override Boolean triggeringObjectRequired()
	{
		return false;
	}

	/**
	 * @description The DTO that will be used to parse the response
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public List<SC_TaxResponseMessage> responses;

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
	 * @description Response message in the response, corresponding to each request
	 */
	private class SC_TaxResponseMessage
	{
		public String message;
	}

	/**
	 * @description Override to return inner class having Mock response
	 *
	 * @return CMN_API_HttpBaseOutboundMock SC_API_SendCommunicationMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new SC_API_SendCommunicationMock();
	}

	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	private class SC_API_SendCommunicationMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '[{"message":"Document Mailed Successfully for role 1, Contract Number: 01, DocumentType: test 1 for the year 2010"},' +
				'{"message":"Document Mailed Successfully for role 2, Contract Number: 01, DocumentType: test 1 for the year 2010"},' +
				'{"message":"Document Mailed Successfully for role 3, Contract Number: 02, DocumentType: test 2 for the year 2020"}]';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}