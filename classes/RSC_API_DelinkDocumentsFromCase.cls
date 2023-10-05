/**
 * @description Service class to make the API call to notify Mulesoft when a document is de-linked from a specific case
 *
 * @see RSC_API_DelinkDocumentsFromCase_TEST @story ST-146083
 *
 * @author aakriti.a.goyal@accenture.com rajpal.singh@accenture.com
 *
 * @date August 2021, July 2022
 */
public inherited sharing class RSC_API_DelinkDocumentsFromCase extends CMN_API_RestBaseOutboundMule
{
	private static final String ERROR_DOCUMENT_NOT_VAULTED = 'Unable to process request as the selected document is not vaulted.';
	private static final String ERROR_ITEM_NOT_FOUND = 'Unable to process request as no checklist item was found.';
	private static final String ERROR_NO_REASON = 'Unable to process request as reason was blank.';
	private static final String RESPONSE_ERROR = '{"error":{"errorCode":400,"errorDateTime":"2021-08-20T09:49:53","errorMessage":"Document not found",' +
			'"errorDescription":""}}';

	/**
	 * @description Required parameter to be passed to the handler else call will be aborted
	 */
	public static final String PARAMETER_REASON = 'reason';

	/**
	 * @description constant to store the service name
	 */
	public static final String SERVICE_NAME = RSC_API_DelinkDocumentsFromCase.class.getName();

	/**
	 * @description Override to set request and response DTO types and any other globals which may be used
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_Request();
	}

	/**
	 * @description Override to use Delete HTTP Method for API call
	 *
	 * @return String
	 */
	public override virtual String getVerb()
	{
		return CMN_API_HttpBase.HTTP_VERB_DELETE;
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
	 * @description Returns the list of required parameters need to execute the request
	 *
	 * @return A list of required service parameters
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	protected override Set<String> getRequiredParameters()
	{
		Set<String> parameters = super.getRequiredParameters();

		parameters.add(PARAMETER_REASON);

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
			DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

			dtoRequest.foundCheckListItem = SC_DAL_DocumentChecklistItem.findById(queueItem.CMN_TriggeringObjectId__c);

			if(dtoRequest.foundCheckListItem == null)
			{
				mustAbort = true;
				callResult.errors.add(ERROR_ITEM_NOT_FOUND);
			}
			else if(String.isBlank(dtoRequest.foundCheckListItem.CMN_VaultedId__c))
			{
				mustAbort = true;
				callResult.errors.add(ERROR_DOCUMENT_NOT_VAULTED);
			}

			if(String.isBlank(requestParameters.getFirst(PARAMETER_REASON)))
			{
				mustAbort = true;
				callResult.errors.add(ERROR_NO_REASON);
			}

		}

		return mustAbort;
	}

	/**
	 * @description Inner class to define structure of request body and populate the same for API call
	 */
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public Integer caseNumber;
		public String reason;
		public String userName;
		private transient DocumentChecklistItem foundCheckListItem;

		/**
		 * @description Override to populate request body
		 *
		 * @param triggeringObjectId Case Id for which API call is initiated
		 * @param dtoRequestParameters Additional parameters to be populated on the dto request
		 */
		public override void populate(Id triggeringObjectId, CMN_DTO_NameValues dtoRequestParameters)
		{
			super.populate(triggeringObjectId, dtoRequestParameters);

			User currentUser = SC_DAL_User.findById(new Set<Id> {UserInfo.getUserId()}).iterator().next();

			userName = currentUser.AW_UACFID__c;

			if(foundCheckListItem != null && CMN_UTIL_System.getSObjectTypeById(foundCheckListItem.ParentRecordId) == Case.SObjectType)
			{
				Case caseRecord = SC_DAL_Case.findById(foundCheckListItem?.ParentRecordId);
				caseNumber = Integer.valueOf(caseRecord.RSC_WorkflowCaseNumber__c);
			}

			reason = dtoRequestParameters.getFirst(PARAMETER_REASON);
		}
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
						new List<String> {EncodingUtil.urlEncode(((DTO_Request)baseRequestDTO).foundCheckListItem.CMN_VaultedId__c, UTF8_ENCODING_SCHEME)}
				);
	}

	/**
	 * @description Override to return inner class having Mock response
	 *
	 * @return CMN_API_HttpBaseOutboundMock RSC_API_DelinkDocumentMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new RSC_API_DeLinkDocumentMock();
	}

	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	private class RSC_API_DeLinkDocumentMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"message": "Document Deleted Successfully."}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
		/**
		 * @description Will set response in the event on exception
		 *
		 * @param response The response object on which to set the relevant body
		 */
		protected override void setErrorResponse(HttpResponse response)
		{
			super.setErrorResponse(response);
			response.setBody(RESPONSE_ERROR);
		}
	}
}