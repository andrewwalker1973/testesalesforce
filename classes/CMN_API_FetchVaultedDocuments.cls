/**
 * @description Common Service class to make the API call to retrieve list of vaulted documents
 *
 * @see RSC_CTRL_GetVaultedDocuments_TEST
 * @see SC_API_BusinessClientVaultedDocs_TEST
 * @see SC_API_FetchVaultedDocuments_TEST
 *
 * @author jayanth.kumar.s@accenture.com meghana.g.n@accenture.com
 *
 * @date May 2022
 */
public inherited sharing abstract class CMN_API_FetchVaultedDocuments extends CMN_API_RestBaseOutboundMule
{
	private String identificationNumber;
	private static final String HEADER_ADVISOR_CONSULTANT_CODE = 'advisorConsultantCode';
	private static final String HEADER_AGENT_UACF_ID = 'agentUacfId';
	private static final String NO_IDENTIFICATION_NUMBER = 'Unable to process request as the parent object did not have an Identification Number.';

	/**
	 * @description Contains list of Objects whose Id can be processed
	 */
	private static final Set<SObjectType> ALLOWED_OBJECT_TYPES = new Set<SObjectType>
	{
			Account.SObjectType, Opportunity.SObjectType, AW_Outstanding_Requirement__c.SObjectType, Lead.SObjectType
	};

	/**
	 * @description Public property exposing the documents successfully retrieved
	 */
	public List<DTO_VaultedDocumentChecklistItem> vaultedDocuments
	{
		get
		{
			DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;
			return dtoResponse.responses;
		}
	}

	protected virtual override void initialise()
	{
		super.initialise();
		baseResponseDTO = new DTO_Response();
	}

	protected override Boolean hasArrayResponse()
	{
		return true;
	}

	/**
	 * @description Override to use Get HTTP Method for API call
	 *
	 * @return String
	 */

	public override virtual String getVerb()
	{
		return HTTP_VERB_GET;
	}

	/**
	 * @description Override to set header values
	 */
	protected override void setHeaders()
	{
		super.setHeaders();

		User currentUser = AW_DAL_User.getCurrentUser();

		if(currentUser.Profile.Name == SC_DAL_Profile.PROFILE_SERVICE_AGENT && String.isNotBlank(currentUser.AW_UACFID__c))
		{
			request.setHeader(HEADER_AGENT_UACF_ID, currentUser.AW_UACFID__c);
		}
		else if(currentUser.Profile.Name == AW_DAL_Profile.PROFILE_ADVISER && String.isNotBlank(currentUser.AW_ConsultantCode__c))
		{
			request.setHeader(HEADER_ADVISOR_CONSULTANT_CODE, currentUser.AW_ConsultantCode__c);
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
						new List<String>
						{
								EncodingUtil.urlEncode(identificationNumber, UTF8_ENCODING_SCHEME)
						}
				);
	}

	/**
	 * @description Override to validate if all the information required to make API call is available
	 *
	 * @return Boolean Returns true if all the information is present, else will return false
	 */
	@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
	protected virtual override Boolean abortRequest()
	{
		Boolean mustAbort = super.abortRequest();

		if(!mustAbort)
		{
			Id triggeringObjectId = CMN_UTIL_String.validateId(queueItem.CMN_TriggeringObjectId__c);
			SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(triggeringObjectId);

			if(!ALLOWED_OBJECT_TYPES.contains(objectType))
			{
				mustAbort = true;
				callResult.errors.add('The Object Type "' + objectType.getDescribe().getLocalName() + '" is unsupported');
			}
			else
			{
				if(objectType == Lead.SObjectType)
				{
					identificationNumber = AW_DAL_Lead.findById(triggeringObjectId)?.AW_IdentificationNumber__c;
				}
				else
				{
					Id accountId = triggeringObjectId;

					if(objectType == Opportunity.SObjectType)
					{
						Opportunity foundOpportunity = AW_DAL_Opportunity.findById(triggeringObjectId);
						accountId = foundOpportunity?.AccountId;
					}
					else if(objectType == AW_Outstanding_Requirement__c.SObjectType)
					{
						AW_Outstanding_Requirement__c foundRequirement = AW_DAL_OutstandingRequirement.findById(triggeringObjectId);
						accountId = foundRequirement?.AW_Account__c;
					}

					Account foundAccount = AW_DAL_Account.findById(accountId);
					if(foundAccount != null)
					{
						identificationNumber = foundAccount.IsPersonAccount ? foundAccount.AW_IdentificationNumber__pc : foundAccount.AW_CompanyRegistrationTrustNumber__c;
					}
				}

				if(String.isBlank(identificationNumber))
				{
					mustAbort = true;
					callResult.errors.add(NO_IDENTIFICATION_NUMBER);
				}
			}
		}
		return mustAbort;
	}

	/**
	 * @description Inner class to define structure of response body
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		private List <DTO_VaultedDocumentChecklistItem> responses;

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
	 * @description Class representing a vaulted document
	 */
	@SuppressWarnings('ApexUnusedDeclaration')
	public class DTO_VaultedDocumentChecklistItem
	{
		/**
		 * @description Where the vaulted document is stored, e.g. 'Horizon'
		 */
		@AuraEnabled
		public String source;
		/**
		 * @description Vaulted Id - external Id from Horizon
		 */
		@AuraEnabled
		public String documentId;
		/**
		 * @description Document Type - used to store document name
		 */
		@AuraEnabled
		public String documentType;
		/**
		 * @description Vaulted Date - saved as AW_VaultedDate
		 */
		@AuraEnabled
		public String entryDate;
		/**
		 * @description Document Type Code - used to store document code
		 */
		@AuraEnabled
		public String sourceId;
		/**
		 * @description Indicates that the document read-only. Added as part of Service Console
		 */
		@AuraEnabled
		public Boolean readOnly;
	}

	/**
	 * @description Override to return mock response for test class
	 *
	 * @return CMN_API_HttpBaseOutboundMock CMN_API_FetchVaultedDocumentsMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new CMN_API_FetchVaultedDocumentsMock();
	}

	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	private class CMN_API_FetchVaultedDocumentsMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '[{"source": "Horizon", "documentId": "911642606", "documentType": "Cancel Cession",' +
				'"entryDate": "01/03/2021 12:26:41", "sourceId": "1234", "readOnly": true},{"source": "Horizon", "documentId": "911642707",' +
				' "documentType": "Id Declaration", "entryDate": "02/03/2021 12:27:41", "sourceId": "2211", "readOnly": false}]';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}