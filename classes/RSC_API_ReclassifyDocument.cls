/**
 * @description Service class to make the API call to notify Mulesoft when a Case is reclassified in Salesforce
 *
 * @see RSC_API_ReclassifyDocument_TEST @story ST-146099, ST-244882
 *
 * @author m.sudhakar.rokde@accenture.com, meghana.g.n@accenture.com
 *
 * @date August 2021, January 2022
 */
public inherited sharing class RSC_API_ReclassifyDocument extends CMN_API_RestBaseOutboundMule
{
	private static final String ERROR_CONTACT_ADMIN = 'An unexpected error occurred. Please contact your System Administrator.';
	private static final String ERROR_DOCUMENT_NOT_VAULTED = 'Unable to process request as the selected Document is not vaulted.';
	private static final String ERROR_INVALID_DOCUMENT_TYPE_ID = 'Unable to process request as an invalid Document Type Id was provided.';
	private static final String ERROR_ITEM_NOT_FOUND = 'Unable to process request as no Check List Item was found.';
	private static final String ERROR_NO_UACF_ID = 'Unable to process the request as current user does not have an UACF Id.';
	private static final String ERROR_NO_WORKFLOW_CASE_NUMBER = 'Unable to process the request as case does not have Workflow Case Number.';
	private static final String ERROR_UNEXPECTED = 'An unexpected error occurred.';
	private static final String RESPONSE_ERROR = '{"error":{"errorCode":400,"errorDateTime":"2021-08-20T09:49:53","errorMessage":"User name not found","errorDescription":"This user is not associated with UACF Id"}}';
	private static final String RESPONSE_VALID = '{"message": "Document Reclassified Successfully."}';

	/**
	 * @description Class name of the web service handler
	 */
	public static final String SERVICE_NAME = RSC_API_ReclassifyDocument.class.getName();

	private static final Map<Integer, String> ERROR_MAP = new Map<Integer, String>
	{
			500 => ERROR_CONTACT_ADMIN
	};

	/**
	 * @description Required parameter to be passed to the handler else call will be aborted
	 */
	public static final String PARAMETER_DOCUMENT_TYPE = 'documentTypeId';

	/**
	 * @description Override to set request and response DTO types and any other globals which may be used
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_Request();
	}

	/**
	 * @description If API encounters an error, this method will provide a user friendly error message
	 */
	public String errorMessage
	{
		get
		{
			String message;

			if(callResult.failed)
			{
				DTO_ErrorResponse dtoErrorResponse = (DTO_ErrorResponse)JSON.deserialize(callResult.responseBody, DTO_ErrorResponse.class);
				message = ERROR_MAP.get(dtoErrorResponse.error?.errorCode);
				if(String.isBlank(message))
				{
					message = ERROR_UNEXPECTED;
				}
			}

			return message;
		}
	}

	/**
	 * @description Override to use Put HTTP Method for API call
	 *
	 * @return String
	 */
	public override virtual String getVerb()
	{
		return CMN_API_HttpBase.HTTP_VERB_PUT;
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

		parameters.add(PARAMETER_DOCUMENT_TYPE);

		return parameters;
	}

	/**
	 * @description Override to validate if all the information required to make API call is available
	 *
	 * @return Boolean Returns true if all the information is present, else will return false
	 */
	@SuppressWarnings('PMD.CognitiveComplexity')
	protected override Boolean abortRequest()
	{
		Boolean mustAbort = super.abortRequest();

		if(!mustAbort)
		{
			if(String.isBlank(CMN_UTIL_String.validateId(requestParameters.getFirst(PARAMETER_DOCUMENT_TYPE))))
			{
				mustAbort = true;
				callResult.errors.add(ERROR_INVALID_DOCUMENT_TYPE_ID);
			}

			DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

			dtoRequest.foundCheckListItem = SC_DAL_DocumentChecklistItem.findById(queueItem.CMN_TriggeringObjectId__c);

			if(dtoRequest.foundCheckListItem == null)
			{
				mustAbort = true;
				callResult.errors.add(ERROR_ITEM_NOT_FOUND);
			}
			else if(dtoRequest.foundCheckListItem.AW_Vaulted__c == false)
			{
				mustAbort = true;
				callResult.errors.add(ERROR_DOCUMENT_NOT_VAULTED);
			}

			dtoRequest.foundUser = SC_DAL_User.findById(UserInfo.getUserId());

			if(String.isBlank(dtoRequest.foundUser.AW_UACFID__c))
			{
				mustAbort = true;
				callResult.errors.add(ERROR_NO_UACF_ID);
			}

			SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(dtoRequest.foundCheckListItem.ParentRecordId);
			if(objectType == Case.SObjectType)
			{
				Case caseRecord = SC_DAL_Case.findById(dtoRequest.foundCheckListItem.ParentRecordId);
				if(caseRecord.RSC_WorkflowCaseNumber__c == null)
				{
					mustAbort = true;
					callResult.errors.add(ERROR_NO_WORKFLOW_CASE_NUMBER);
				}
			}
		}

		return mustAbort;
	}
	/**
	 * @description Inner class to define structure of request body and populate the same for API call
	 */
	public class DTO_Request extends CMN_DTO_JsonBase
	{
		public String userName;
		public Integer caseNumber;
		public Integer documentId;
		public Integer sourceDocumentTypeCode;
		public String sourceDocumentTypeText;
		private transient DocumentChecklistItem foundCheckListItem;
		private transient User foundUser;

		/**
		 * @description Override to populate request body
		 *
		 * @param triggeringObjectId document Id for which API call is initiated
		 * @param dtoRequestParameters Additional parameters to be populated on the dto request
		 */
		public override void populate(Id triggeringObjectId, CMN_DTO_NameValues dtoRequestParameters)
		{
			super.populate(triggeringObjectId, dtoRequestParameters);

			userName = foundUser.AW_UACFID__c;

			documentId = Integer.valueOf(foundCheckListItem.CMN_VaultedId__c);

			if(CMN_UTIL_System.getSObjectTypeById(foundCheckListItem.ParentRecordId) == Case.SObjectType)
			{
				Case caseRecord = SC_DAL_Case.findById(foundCheckListItem.ParentRecordId);
				caseNumber = Integer.valueOf(caseRecord.RSC_WorkflowCaseNumber__c);
			}

			DocumentType foundDocumentType = SC_DAL_DocumentType.findById(dtoRequestParameters.getFirst(PARAMETER_DOCUMENT_TYPE));
			sourceDocumentTypeCode = Integer.valueOf(CMN_UTIL_String.remove(foundDocumentType.DeveloperName, SC_DAL_DocumentChecklistItem.DOCUMENT_CODE));
			sourceDocumentTypeText = foundDocumentType.MasterLabel;
		}
	}

	/**
	 * @description Override to construct API endpoint
	 *
	 * @return String Complete API Endpoint
	 */
	protected override String getWebServiceEndPoint()
	{
		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;
		return String.format
				(
						super.getWebServiceEndPoint(),
						new List<String> {EncodingUtil.urlEncode(dtoRequest.foundCheckListItem.CMN_VaultedId__c, UTF8_ENCODING_SCHEME)}
				);
	}

	/**
	 * @description Override to return inner class having Mock response
	 *
	 * @return CMN_API_HttpBaseOutboundMock RSC_API_ReclassifyDocumentMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new RSC_API_ReclassifyDocumentMock();
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
	@SuppressWarnings('ApexUnusedDeclaration')
	private class DTO_Error
	{
		private Integer errorCode;
		private String errorMessage;

	}

	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	private class RSC_API_ReclassifyDocumentMock extends CMN_API_HttpBaseOutboundMock
	{
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(RESPONSE_VALID);
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