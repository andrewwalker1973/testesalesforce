/**
 * @description Service class to make the API call to send client policy print.
 *
 * @see SC_API_SendClientPolicyPrint_TEST @story ST-146321
 *
 * @author aakriti.a.goyal@accenture.com darrion.james.singh@accenture.com
 *
 * @date September 2021, February 2022
 */
public inherited sharing class SC_API_SendClientPolicyPrint extends CMN_API_GuidedInteraction
{
	/**
	 * @description The class name of the web service handler
	 */
	public static final String SERVICE_NAME = SC_API_SendClientPolicyPrint.class.getName();

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
	 * @description Indicate if a triggering object id is required
	 *
	 * @return Boolean indicating requirement
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	protected override Boolean triggeringObjectRequired()
	{
		return false;
	}

	/**
	 * @description Inner class to define structure of response body
	 */
	@SuppressWarnings('ApexUnusedDeclaration')
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		private String documentReference;
		private String requestSystemId;
		private List<DTO_Document> documents;
		private String responseCode;
		private String responseMessage;

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
	 * @description DTO Representing a list of documents
	 */
	@SuppressWarnings('ApexUnusedDeclaration')
	@TestVisible
	private class DTO_Document
	{
		private String documentName;
		private String documentId;
	}

	/**
	 * @description Override to return inner class having Mock response
	 *
	 * @return CMN_API_HttpBaseOutboundMock SC_API_SendClientPolicyPrintMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new SC_API_SendClientPolicyPrintMock();
	}

	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	private class SC_API_SendClientPolicyPrintMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"documentReference": "05778923","requestSystemId": "Salesforce", ' +
				'"documents":[{"documentName" : "OutstandingRequirements","documentId" : "0123654"}],' +
				'"responseCode": "200","responseMessage": "Communication sent successfully"}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}