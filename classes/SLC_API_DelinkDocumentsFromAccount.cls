/**
 * @description Service class to make the API call to notify Mulesoft when a document is delinked from a specific Account
 *
 * @author Futureform
 *
 * @date December 2022
 */
public inherited sharing class SLC_API_DelinkDocumentsFromAccount extends CMN_API_RestBaseOutboundMule
{
	private static final String ERROR_DOCUMENT_NOT_VAULTED = 'Unable to process request as the selected document has no vaulted Id.';
	private static final String ERROR_ITEM_NOT_FOUND = 'Unable to process request as no checklistitem was found.';
	private static final String ERROR_NO_REASON = 'Unable to process request as reason was blank.';
	private static final String ERROR_UNEXPECTED = 'An unexpected error occurred.';
	private static final String RESPONSE_ERROR = '{"error":{"errorCode":400,"errorDateTime":"2021-08-20T09:49:53","errorMessage":"Document not found","errorDescription":""}}';

	/**
	 * @description Required parameter to be passed to the handler else call will be aborted
	 */
	public static final String PARAMETER_REASON = 'reason';
	public static final String PARAMETER_DOCUMENT_ID = 'documentId';

	public static final String SERVICE_NAME = SLC_API_DelinkDocumentsFromAccount.class.getName();

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
				message = dtoErrorResponse.error?.errorMessage;
				if(String.isBlank(message))
				{
					message = ERROR_UNEXPECTED;
				}
			}
			return message;
		}
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
		parameters.add(PARAMETER_DOCUMENT_ID);

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
			if(String.isBlank(requestParameters.getFirst(PARAMETER_REASON)))
			{
				mustAbort = true;
				callResult.errors.add(ERROR_NO_REASON);
			}

			if(String.isBlank(requestParameters.getFirst(PARAMETER_DOCUMENT_ID)))
			{
				mustAbort = true;
				callResult.errors.add(ERROR_DOCUMENT_NOT_VAULTED);
			}
		}
		return mustAbort;
	}

	/**
	 * @description Inner class to define structure of request body and populate the same for API call
	 */
	public class DTO_Request extends CMN_DTO_JsonBase
	{
		public String accountNumber;
		public String financialAccountNumber;
		public String identityNumber;
		public String reason;
		public String userName;
		public String uniqueInternalCode;
		private String documentId;

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
			reason = dtoRequestParameters.getFirst(PARAMETER_REASON);
			documentId = dtoRequestParameters.getFirst(PARAMETER_DOCUMENT_ID);

			if (triggeringObjectId.getSobjectType() == Account.SObjectType) {
				Account account = SLC_DAL_Account.findById(triggeringObjectId);

				if (account.IsPersonAccount) {
					this.identityNumber = account.SLC_IDNumber__c;
				} else {
					this.accountNumber = account.AccountNumber;
				}
			} else if (triggeringObjectId.getSobjectType() == FinServ__FinancialAccount__c.SObjectType) {
				FinServ__FinancialAccount__c account = AW_DAL_FinancialAccount.findById(triggeringObjectId);
				financialAccountNumber = account.FinServ__FinancialAccountNumber__c;
			}
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
						new List<String> {EncodingUtil.urlEncode(((DTO_Request)baseRequestDTO).documentId, UTF8_ENCODING_SCHEME)}
				);
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
		private String errorMessage;

	}

	/**
	 * @description Override to return inner class having Mock response
	 *
	 * @return CMN_API_HttpBaseOutboundMock RSC_API_DelinkDocumentMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new RSC_API_DelinkDocumentMock();
	}

	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	private class RSC_API_DelinkDocumentMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String VALID_RESPONSE = '{"message": "Document Deleted Successfully."}';

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
			response.setBody(RESPONSE_ERROR);
		}
	}
}