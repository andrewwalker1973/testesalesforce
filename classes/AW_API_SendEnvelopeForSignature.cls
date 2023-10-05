/**
 * @description Service class to make the API call when Envelope is send for signature from Salesforce to MuleSoft and Signing Hub
 *
 * @see AW_API_SendEnvelopeForSignature_TEST @story ST-117357
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing class AW_API_SendEnvelopeForSignature extends CMN_API_RestBaseOutboundMule
{
	private AW_Envelope__c foundEnvelope;
	private static final String ENVELOPE_NAME_FORMAT = '{0} - {1}';
	private static final String ERROR_NO_ENVELOPE_FOUND = 'Unable to process request as no Envelope was found';
	private static final String SIGNER_ROLE = 'Signer';
	public static final String SERVICE_NAME = AW_API_SendEnvelopeForSignature.class.getName();

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
			foundEnvelope = AW_DAL_Envelope.findById(queueItem.CMN_TriggeringObjectId__c);

			if(foundEnvelope == null)
			{
				mustAbort = true;
				callResult.errors.add(ERROR_NO_ENVELOPE_FOUND);
			}
		}

		return mustAbort;
	}

	/**
	 * @description Override to set SObject types for DML operation
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType>
		{
				AW_Envelope__c.SObjectType
		});
	}

	/**
	 * @description Inner class to define structure of request body and populate the same for API call
	 */
	public class DTO_Request extends CMN_DTO_JsonBase
	{
		private String envelopeName;
		private List<DTO_CheckListItem> documents;
		private DTO_Consultant consultantDetails;
		private DTO_Client clientDetails;
		private String contractNumber;
		private List<DTO_Recipients> recipients;

		public override void populate(Id triggeringObjectId)
		{
			super.populate(triggeringObjectId);

			AW_Envelope__c envelope = AW_DAL_Envelope.findById(triggeringObjectId);
			envelopeName = String.format(ENVELOPE_NAME_FORMAT, new List<String> {envelope.Name, CMN_UTIL_Date.dateToIso8601String(envelope.CreatedDate.date())});

			List<DocumentChecklistItem> checklistItems = AW_DAL_DocumentChecklistItem.findByParent(triggeringObjectId);

			if(!checklistItems.isEmpty())
			{
				Map<Id, DocumentChecklistItem> documentChecklistItemMap = new Map<Id, DocumentChecklistItem>(checklistItems);

				documents = new List<DTO_CheckListItem>();

				List<ContentDocumentLink> documentLinks = CMN_DAL_ContentDocumentLink.findByLinkedEntitiesIds(CMN_UTIL_System.extractListIds(checklistItems));
				Map<Id, SObject> parentIdToDocumentMap = CMN_UTIL_System.convertListToSingleMap(documentLinks, ContentDocumentLink.LinkedEntityId.getDescribe().getLocalName());

				for(Id documentId : parentIdToDocumentMap.keySet())
				{
					DTO_CheckListItem dtoCheckListItem = new DTO_CheckListItem();

					dtoCheckListItem.documentId = documentId;
					ContentDocumentLink documentLink = (ContentDocumentLink)parentIdToDocumentMap.get(documentId);
					dtoCheckListItem.versionId = documentLink.ContentDocument.LatestPublishedVersionId;
					dtoCheckListItem.fileName = documentLink.ContentDocument.Title;
					dtoCheckListItem.documentType = documentChecklistItemMap.get(documentLink.LinkedEntityId).DocumentType?.MasterLabel;
					dtoCheckListItem.sourceId = documentChecklistItemMap.get(documentLink.LinkedEntityId).DocumentType?.Description;
					documents.add(dtoCheckListItem);
				}
			}

			consultantDetails = new DTO_Consultant();

			User envelopeOwner = AW_DAL_User.findById(envelope.OwnerId);

			consultantDetails.consultantCode = envelopeOwner.AW_ConsultantCode__c;
			consultantDetails.uacfid = envelopeOwner.AW_UACFID__c;
			consultantDetails.emailAddress = envelopeOwner.Email;

			clientDetails = new DTO_Client();
			if(String.isNotBlank(envelope.AW_Account__c))
			{
				Account account = AW_DAL_Account.findById(envelope.AW_Account__c);
				if(String.isNotBlank(account.AW_CompanyRegistrationTrustNumber__c))
				{
					clientDetails.companyTrustRegNo = account.AW_CompanyRegistrationTrustNumber__c;
				}
				else
				{
					clientDetails.surname = account.LastName;
					clientDetails.firstname = account.FirstName;
					clientDetails.passportNumber = account.AW_IdentificationType__pc == AW_DAL_Account.PICK_PASSPORT_TYPE ? account.AW_IdentificationNumber__pc : null;
					clientDetails.saNationalIDNumber = account.AW_IdentificationType__pc != AW_DAL_Account.PICK_PASSPORT_TYPE ? account.AW_IdentificationNumber__pc : null;
				}
			}
			else if(String.isNotBlank(envelope.AW_LeadAndReferral__c))
			{
				Lead lead = AW_DAL_Lead.findById(envelope.AW_LeadAndReferral__c);
				if(String.isNotBlank(lead.AW_CompanyRegistrationTrustNumber__c))
				{
					clientDetails.companyTrustRegNo = lead.AW_CompanyRegistrationTrustNumber__c;
				}
				else
				{
					clientDetails.surname = lead.LastName;
					clientDetails.firstname = lead.FirstName;
					clientDetails.passportNumber = lead.AW_IdentificationType__c == AW_DAL_Lead.IDENTIFICATION_TYPE_PASSPORT ? lead.AW_IdentificationNumber__c : null;
					clientDetails.saNationalIDNumber = lead.AW_IdentificationType__c != AW_DAL_Lead.IDENTIFICATION_TYPE_PASSPORT ? lead.AW_IdentificationNumber__c : null;
				}
			}
			else if(String.isNotBlank(envelope.AW_Opportunity__c) && String.isNotBlank(envelope.AW_Opportunity__r.AccountId))
			{
				Account account = AW_DAL_Account.findById(envelope.AW_Opportunity__r.AccountId);
				if(String.isNotBlank(account.AW_CompanyRegistrationTrustNumber__c))
				{
					clientDetails.companyTrustRegNo = account.AW_CompanyRegistrationTrustNumber__c;
				}
				else
				{
					clientDetails.surname = account.LastName;
					clientDetails.firstname = account.FirstName;
					clientDetails.passportNumber = account.AW_IdentificationType__pc == AW_DAL_Account.PICK_PASSPORT_TYPE ? account.AW_IdentificationNumber__pc : null;
					clientDetails.saNationalIDNumber = account.AW_IdentificationType__pc != AW_DAL_Account.PICK_PASSPORT_TYPE ? account.AW_IdentificationNumber__pc : null;
		}
	}

			contractNumber = '';

			List<AW_EnvelopeRole__c> envelopeRoles = AW_DAL_EnvelopeRole.findByParent(triggeringObjectId);

			if(!envelopeRoles.isEmpty())
	{
				recipients = new List<DTO_Recipients>();

				for(AW_EnvelopeRole__c envelopeRole : envelopeRoles)
				{
					DTO_Recipients dtoRecipient = new DTO_Recipients();

					dtoRecipient.email = envelopeRole.AW_Email__c;
					dtoRecipient.name = envelopeRole.AW_Contact__r.Name;
					dtoRecipient.mobile = envelopeRole.AW_Mobile__c;
					dtoRecipient.role = SIGNER_ROLE;
					dtoRecipient.emailNotification = true;
					dtoRecipient.signingOrder = 1;
					recipients.add(dtoRecipient);
				}
			}
		}
	}

	/**
	 * @description Will save updates to the envelope
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Response dtoEnvelope = (DTO_Response)baseResponseDTO;

		foundEnvelope.AW_PackageID__c = dtoEnvelope.packageId;
		foundEnvelope.AW_URL__c = dtoEnvelope.url;
		foundEnvelope.AW_Status__c = AW_DAL_Envelope.STATUS_SENT_FOR_SIGNING;

		registerChange(foundEnvelope);
	}

	/**
	 * @description Override to return mock response for test class
	 *
	 * @return CMN_API_HttpBaseOutboundMock AW_API_RestOutboundEnvelopeToSigMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new AW_API_SendEnvelopeForSignatureMock();
	}

	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	private class AW_API_SendEnvelopeForSignatureMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String VALID_RESPONSE = '{"packageId": "test", "url": "https://uatweb.signinghub.co.za/Integration?q=QUVTMjU2LUdDTZAqtW41drGf-2B-zwG1eGpYUhvurSwqxF12IttLaboG1t3wQw1BsCSP-2B-3FCjRyh-2F-2rBYJwByYMnL2JpG6lGx6wL-2B-FxbS56O5o-2F-zp2p5R-2B-FSD822-2B-tIPF2msM-2B-a9WSGowiRnxME2oEFFxeuIJiTEXCcbknqFrgPwp-2F-0YWmytmZckYDfkBTGBS8cSZi-2F-r71j4LaSxwXWMMG3W25vO2uGPEfxNNnrAnJHvRpTgKZmcaGj5y9NnUS7En3UcTBiZ0wQZdBDr0zQX2DbKT9rfi3A6yQp1oV6eB56TtL-2F-xJlv7os-2F-AbFUUsd4SlSXJEr-2B-THJvJZUKNYXpFZPtFMyE9yTK-2B-z340kTxwf9H1nCQoJ1ao-2F-MyJhg9M5sEIRH1X0Yv-2B-EdJOZSLLJMP0wAAZRp4NJQk53NMO-2F-9S3G1vgKyY7SnEWT5iL99KZ0ZrqdUVoWuqJrHG8mMdZH-2B-d-2B-9-2F-g-2F-QPkMl3qkPo6AJDZtt-2B-Ly8W8SrqHye350GHy5ZRHAFrxdLDa9cpc6ZkF-2B-7WygTMRqDTVdzgD-2F-LEmFThao-2B-jfh-2F-8FCUxQx6m9sDBAGcRmQ1nX1mzUnQ6H0xzJsrsOrjAa5MMfxYWbIYFslk7GzZ3RkGBSDDvFKqEbAbxxavtyuaafgIzdMA19yMnDpYdjSHz0ArCl62DPTRXQWIxVtcB6j7QVJlV7BO0DTItOlBYPUXuK0QeZjNMl-2B-3z0nwb6mED5QIRQ-2B-icFGCaLsa-2F-cnIdLcCgUCDFFxnMFPivyLroTGAGGM45VpmrxMzdaX2h13Cy4MVDuvpKvSgD5j23IUTPo9z8LXVmkYVW8PHibO7BNrm93h1kgZtIvAVW10dUlNHVEk0zDAZpjYENjMol3mTNUdaBxpVYc7yajYUEbMW-2F-fYp09G9rd0fLMKdTjyno7OKAFoOZ-2B-TOVBgg-2B-S-2F-kfPR6YZ6k3pmuLR8o8LOfoZjMA-2B-0zp3SOhJV1roJUlnChOyjq9Xv-2B-nm-2B-P-2F-tK6sc6QY1uXv-2F-fMiCexS8YoKcDT9-2B-5eO-2B-fpp7eJ9v4grcu2Bk15SRF2jLuOy-2F-VrTKjPgJYKU6ILREk-2F-L0PXQXJAot26yVxeqBSF6ww-2F-DzhvyFEonkAyJHU700QDVJKkAYPS3S33-2F-s-2B-JiDPMkv6JGaZY7YrDUzWsWJFcw-3D-"}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}
	}

	/**
	 * @description Class representing a document checklist item
	 */
	private class DTO_CheckListItem
	{
		private String versionId;
		private String fileName;
		private String documentId;
		private String documentType;
		private String sourceId;
	}

	/**
	 * @description Class representing the Consultant Details
	 */
	private class DTO_Consultant
	{
		private String consultantCode;
		private String uacfid;
		private String emailAddress;//used for setting signing hub scope and vaulting
	}

	/**
	 * @description Class representing the Client Details
	 */
	private class DTO_Client
	{
		private String surname;//Don't send if business
		private String firstname;//Don't send if business
		private String saNationalIDNumber;//optional 1 required either id, company reg or passport
		private String companyTrustRegNo;//optional
		private String passportNumber;//optional
	}

	/**
	 * @description Class representing the Recipient Details
	 */
	private class DTO_Recipients
	{
		private String email;//recipient email address
		private String name;//recipient name
		private String mobile;//recipient mobile
		private String role;//Signer, Approver We always send Signer
		private Boolean emailNotification;//Boolean true/false;
		private Integer signingOrder;// Use static value for now, 1
	}

	/**
	 * @description Inner class to define structure of response body
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		private String packageId;
		private String url;

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
}