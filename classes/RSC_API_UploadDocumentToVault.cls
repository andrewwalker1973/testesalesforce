/**
 * @description Service class to make the API call to notify Mulesoft to retrieve a document and send it to the vault
 *
 * @see RSC_API_UploadDocumentToVault_TEST @story 146092
 *
 * @author meghana.g.n@accenture.com rajpal.singh@accenture.com
 *
 * @date August 2021, July 2022
 */
public inherited sharing class RSC_API_UploadDocumentToVault extends CMN_API_RestBaseOutboundMule
{
	private String personId;
	private static final String ERROR_INCORRECT_OBJECT_TYPE = 'Item was not processed as it is linked to an Object other than a Case';
	private static final String ERROR_ITEM_NOT_FOUND = 'Unable to process request as no Check List Item was found.';
	private static final String ERROR_NO_CONTENT_VERSION = 'Unable to process request as the Check List Item has no document associated with it.';
	private static final String ERROR_NO_UACF_ID = 'Unable to process the request as the current user does not have an UACF Id.';

	/**
	 * @description API class name from the service
	 */
	public static final String SERVICE_NAME = RSC_API_UploadDocumentToVault.class.getName();

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
	 * @description Main process loop which controls the processing of outbound request and ensure result of call is logged
	 *
	 * @param queueItem The queueItem which will ultimately saved to record activity of webservice object
	 */

	public override void process(CMN_WebserviceCallQueue__c queueItem)
	{
		super.process(queueItem);

		//We must make sure that the document is always deleted irrespective of the API call being successful or not
		if(((DTO_Request)baseRequestDTO).foundVersion != null)
		{
			registerDeleted(new ContentDocument(Id = ((DTO_Request)baseRequestDTO).foundVersion.ContentDocument.Id));
		}
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
			User userFound = AW_DAL_User.findById(UserInfo.getUserId());

			personId = userFound.AW_UACFID__c;

			if(String.isBlank(personId))
			{
				mustAbort = true;
				callResult.errors.add(ERROR_NO_UACF_ID);
			}

			DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

			dtoRequest.foundCheckListItem = SC_DAL_DocumentChecklistItem.findById(queueItem.CMN_TriggeringObjectId__c);

			if(dtoRequest.foundCheckListItem == null)
			{
				mustAbort = true;
				callResult.errors.add(ERROR_ITEM_NOT_FOUND);
			}
			else
			{
				SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(dtoRequest.foundCheckListItem.ParentRecordId);

				if(objectType != Case.SObjectType)
				{
					mustAbort = true;
					callResult.errors.add(ERROR_INCORRECT_OBJECT_TYPE);
				}

				List<ContentVersion> foundVersions = CMN_DAL_ContentVersion.findByFirstPublishLocationId(dtoRequest.foundCheckListItem.Id);

				if(foundVersions.isEmpty())
				{
					mustAbort = true;
					callResult.errors.add(ERROR_NO_CONTENT_VERSION);
				}
				else
				{
					dtoRequest.foundVersion = foundVersions.iterator().next();
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
		private Boolean attachToCase;
		private String caseNumber;
		private String companyFundTrustRegNo;
		private String documentType;
		private String fileName;
		private String identityNumber;
		private String sourceId;
		private String versionId;
		private transient ContentVersion foundVersion;
		private transient DocumentChecklistItem foundCheckListItem;

		public override void populate(Id triggeringObjectId)
		{
			super.populate(triggeringObjectId);

			Case caseRecord = SC_DAL_Case.findById(foundCheckListItem?.ParentRecordId);
			Account account = AW_DAL_Account.findById(caseRecord.AccountId);

			attachToCase = true;
			caseNumber = caseRecord.RSC_WorkflowCaseNumber__c != null ? CMN_UTIL_String.trimDecimal(caseRecord.RSC_WorkflowCaseNumber__c) : null;
			companyFundTrustRegNo =
					AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT.equalsIgnoreCase(account?.RecordType.DeveloperName) ? account?.AW_CompanyRegistrationTrustNumber__c : null;
			documentType = foundCheckListItem.DocumentType.MasterLabel;
			fileName = foundVersion.Title;
			identityNumber = AW_DAL_Account.RT_PERSON_MASTER_ACCOUNT.equalsIgnoreCase(account?.RecordType.DeveloperName) ? account?.AW_IdentificationNumber__pc : null;
			sourceId = CMN_UTIL_String.remove(foundCheckListItem.DocumentType.DeveloperName, SC_DAL_DocumentChecklistItem.DOCUMENT_CODE);
			versionId = foundVersion.ContentDocument.LatestPublishedVersionId;
		}
	}

	/**
	 * @description Override to set SObject types for DML operation
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType> {DocumentChecklistItem.SObjectType, ContentVersion.SObjectType, ContentDocument.SObjectType});
	}

	/**
	 * @description Will save updates
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;
		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

		dtoRequest.foundCheckListItem.AW_Vaulted__c = true;
		dtoRequest.foundCheckListItem.AW_DateVaulted__c = System.now();
		dtoRequest.foundCheckListItem.SC_UploadedWithCase__c = true;
		dtoRequest.foundCheckListItem.CMN_VaultedId__c = dtoResponse.documentId;

		registerChange(dtoRequest.foundCheckListItem);
	}

	/**
	 * @description Inner class to define structure of response body
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		private String documentId;

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
	 * @description Override to construct API endpoint
	 *
	 * @return String Complete API Endpoint
	 */
	protected override String getWebServiceEndPoint()
	{
		return String.format
				(
						super.getWebServiceEndPoint(),
						new List<String> {EncodingUtil.urlEncode(personId, UTF8_ENCODING_SCHEME)}
				);
	}

	/**
	 * @description Override to return mock response for test class
	 *
	 * @return CMN_API_HttpBaseOutboundMock ARSC_API_UploadDocumentToVaultMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new RSC_API_UploadDocumentToVaultMock();
	}

	private class RSC_API_UploadDocumentToVaultMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String errorResponse = '{"error":{"errorCode":400,"errorDateTime":"2021-08-20T09:49:53","errorMessage":"User name not found",' +
				'"errorDescription":"This user is not associated with UACF Id"}}';
		private final String validResponse = '{"message": "Document uploaded successfully.","documentId": "123456"}';

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
			response.setBody(errorResponse);
		}
	}
}