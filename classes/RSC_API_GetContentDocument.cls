/**
 * @description Service class to make the API call to download the documents from Mulesoft
 *
 * @see RSC_API_GetContentDocument_TEST @story ST-146054
 *
 * @author rajpal.singh@liberty.co.za
 *
 * @date August 2021
 */
public inherited sharing class RSC_API_GetContentDocument extends CMN_API_RestBaseOutboundMule
{
	private String objectToLinkDocumentTo;
	private String vaultedId;
	private static final String ERROR_DOCUMENT_NOT_VAULTED = 'Unable to process request as the selected Document is not vaulted.';
	/**
	 * @description Class name of the web service handler
	 */
	public static final String SERVICE_NAME = RSC_API_GetContentDocument.class.getName();

	/**
	 * @description Required parameter to be passed to the handler else call will be aborted
	 */
	public static final String PARAMETER_VAULTED_ID = 'vaultedId';

	@TestVisible
	private static String mockContentDocumentId;
	@TestVisible
	private static String mockDocumentId;

	/**
	 * @description Override to set request and response DTO types and any other globals which may be used
	 */
	protected override void initialise()
	{
		super.initialise();

		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description Override to use GET HTTP Method for API call
	 *
	 * @return String
	 */
	public override virtual String getVerb()
	{
		return CMN_API_HttpBase.HTTP_VERB_GET;
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
	 * @description Check if the JSON Response is in the form of an array without key; Parsing this using a Salesforce DTO
	 * class is not possible so it needs to be manually added to the response
	 *
	 * @return Boolean - An indicator to show if the response is an array and is withing a key node.
	 */
	protected override Boolean hasArrayResponse()
	{
		return true;
	}

	/**
	 * @description Returns the list of required parameters need to execute the request
	 *
	 * @return A list of required service parameters
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	protected override Set<String> getRequiredParameters()
	{
		Set<String> parameters = super.getRequiredParameters();

		parameters.add(PARAMETER_VAULTED_ID);

		return parameters;
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
			if(String.isBlank(requestParameters.getFirst(PARAMETER_VAULTED_ID)))
			{
				mustAbort = true;
				callResult.errors.add(ERROR_DOCUMENT_NOT_VAULTED);
			}
			else
			{
				vaultedId = requestParameters.items.iterator().next().value;
				objectToLinkDocumentTo = UserInfo.getUserId();
			}
		}

		return mustAbort;
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
						new List<String> {EncodingUtil.urlEncode(vaultedId, UTF8_ENCODING_SCHEME), objectToLinkDocumentTo}
				);
	}

	/**
	 * @description Public property exposing the documents successfully retrieved
	 */
	public String contentDocumentId
	{
		get
		{
			DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;
			return dtoResponse.responses.iterator().next().documentContentId;
		}
	}

	/**
	 * @description register all the object types we want to update
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType> {ContentVersion.SObjectType});
	}

	/**
	 * @description Will save updates to the ContentVersion if any updates exists
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;

		List<ContentVersion> contentVersions =
				CMN_DAL_ContentVersion.findLatestImageVersionByContentDocuments(new List<String> {dtoResponse.responses.iterator().next().documentContentId});

		if(contentVersions != null)
		{
			ContentVersion updateContentVersion = contentVersions.iterator().next();
			updateContentVersion.CMN_DeleteBy__c = System.now().addMinutes(Integer.valueOf(Label.RSC_ContentDocumentDeletedby));
			registerDirty(updateContentVersion);
		}
	}

	/**
	 * @description Inner class to define structure of response body
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public List<DTO_ContentDocument> responses;

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

	@TestVisible
	@SuppressWarnings('ApexUnusedDeclaration')
	private class DTO_ContentDocument
	{
		public String objectToLinkDocumentTo;
		public String documentContentId;
	}
	/**
	 * @description Override to return inner class having Mock response
	 *
	 * @return CMN_API_HttpBaseOutboundMock RSC_API_ViewDocumentMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new RSC_API_ViewDocumentMock();
	}

	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	private class RSC_API_ViewDocumentMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '[{"objectToLinkDocumentTo": "' + mockDocumentId + '","documentContentId":"' + mockContentDocumentId + '"}]';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}