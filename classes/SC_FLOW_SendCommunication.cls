/**
 * @description Flow Class containing invocable methods to fetch the data for the template.
 * This class can be used in any flow to send communication for the selected template.
 *
 * @see SC_FLOW_SendCommunication_TEST @story ST-146941 ST-257265
 *
 * @author aakriti.a.goyal@accenture.com jason.van.beukering@accenture.com
 *
 * @date September 2021, July 2022
 */
public inherited sharing class SC_FLOW_SendCommunication
{
	private static CMN_CommunicationSetting__mdt setting;
	private static CMN_DAL_SObjectUnitOfWork unitOfWork;
	private static CMN_DTO_SendCommunicationRequest.DTO_PasswordProtection dtoPasswordProtection = new CMN_DTO_SendCommunicationRequest.DTO_PasswordProtection();
	private static List<CMN_DTO_CommunicationTemplate> requests;
	private static List<DTO_Response> dtoResponses = new List<DTO_Response>();
	private static Map<Id, CMN_API_HttpBase> handlerByQueueMap;
	private static Map<Id, CMN_CommunicationTemplate__c> templateMap;
	private static Map<Id, CMN_DTO_CommunicationTemplate> recordIdToTemplateMap = new Map<Id, CMN_DTO_CommunicationTemplate>();
	private static Map<Id, Case> caseMap;
	private static Map<Integer, List<CMN_WebserviceCallQueue__c>> requestToQueueMap = new Map<Integer, List<CMN_WebserviceCallQueue__c>>();
	private static String uacfId = CMN_UTIL_String.EMPTY;
	/**
	 * @description Map Document Reference (Unique identifier sent with the Communication request) to the recipient selected in the request.
	 * Used to identify the unique recipient for each response handler received & populate that recipient on the communication log record.
	 */
	private static Map<String, String> mapDocumentReferenceToRecipient = new Map<String, String>();
	/**
	 * @description Map of recipient type to recipient role to be sent with communication API
	 */
	@TestVisible
	private static final Map<String, String> RECIPIENT_ROLE = new Map<String, String>
	{
			'Client' => 'Client',
			'Financial Adviser' => 'Other',
			'Other' => 'Other'
	};
	private static final String ERROR_REQUIRED_EMAIL_ADDRESS = 'Recipients are required if we are not requesting a document to be returned.';
	private static final String ERROR_REQUIRED_PASSWORD = 'Password not found for the documents to be protected with a password.';

	/**
	 * @description This Method is used to prepare the request body based on the parameters sent from a flow,
	 * send Communication emails using API and returns the response back to flow
	 *
	 * @param dtoRequests List of communication requests to process
	 *
	 * @return List of responses
	 */
	@InvocableMethod(Label='Send Communication' Description='Method to send a communication using a communication template')
	public static List<DTO_Response> sendCommunication(List<CMN_DTO_CommunicationTemplate> dtoRequests)
	{
		requests = dtoRequests;

		initialiseMapsAndSettings();

		for(Integer i = 0; i < dtoRequests.size(); i++)
		{
			CMN_DTO_CommunicationTemplate dtoRequest = dtoRequests[i];
			if(validRequest(dtoRequest))
			{
				createRequests(i, dtoRequest);
			}
		}

		callServiceAndLogResults();

		return dtoResponses;
	}

	/**
	 * @description Will setup re-usable maps as well as get relevant communication settings
	 */
	private static void initialiseMapsAndSettings()
	{
		setting = CMN_DAL_CommunicationSetting.getInstance();

		Set<Id> caseIds = new Set<Id>();
		Set<Id> templateIds = new Set<Id>();

		recordIdToTemplateMap = new Map<Id, CMN_DTO_CommunicationTemplate>();

		for(CMN_DTO_CommunicationTemplate dtoRequest : requests)
		{
			caseIds.add(dtoRequest.recordId);
			templateIds.add(dtoRequest.templateId);
			recordIdToTemplateMap.put(dtoRequest.recordId, dtoRequest);
		}

		caseMap = new Map<Id, Case>(SC_DAL_Case.findByIdWithChildDetails(caseIds));
		templateMap = new Map<Id, CMN_CommunicationTemplate__c>(CMN_DAL_CommunicationTemplate.findByIds(templateIds));
		uacfId = SC_DAL_User.findById(UserInfo.getUserId()).AW_UACFID__c;
	}

	/**
	 * @description Will validate the current request and determine if it can be processed
	 *
	 * @param dtoRequest The request to validate
	 *
	 * @return True if the we must ignore current request
	 */
	private static Boolean validRequest(CMN_DTO_CommunicationTemplate dtoRequest)
	{
		Boolean validRequest = true;
		List<String> errorMessages = new List<String>();

		// Email address should be mandatory
		if(dtoRequest.recipients.isEmpty())
		{
			validRequest = false;
			errorMessages.add(ERROR_REQUIRED_EMAIL_ADDRESS);
		}

		if(dtoRequest.passwordProtection == true)
		{
			populatePasswordDetails(dtoRequest);

			// Password should be required if passwordProtection is selected as true for the documents
			if(String.isBlank(dtoPasswordProtection.password))
			{
				validRequest = false;
				errorMessages.add(ERROR_REQUIRED_PASSWORD);
			}
		}

		if(!validRequest)
		{
			DTO_Response dtoResponse = new DTO_Response();

			dtoResponse.success = false;
			dtoResponse.responses = errorMessages;

			dtoResponses.add(dtoResponse);
		}

		return validRequest;
	}

	/**
	 * @description Will process provided request and create one or more webservice requests
	 *
	 * @param index original index for the request provided
	 * @param dtoRequest request provided
	 */
	private static void createRequests(Integer index, CMN_DTO_CommunicationTemplate dtoRequest)
	{
		List<CMN_WebserviceCallQueue__c> webServiceRequests = new List<CMN_WebserviceCallQueue__c>();
		CMN_DTO_CommunicationTemplate clonedRequest = dtoRequest.clone();

		for(CMN_DTO_CommunicationRecipients recipient : dtoRequest.recipients)
		{
			clonedRequest.recipients = new List<CMN_DTO_CommunicationRecipients> {recipient};

			CMN_WebserviceCallQueue__c webServiceRequest =
					CMN_DAL_DataFactory.newOutboundWebserviceQueue
							(
									templateMap.get(clonedRequest.templateId).CMN_APIName__c,
									clonedRequest.recordId,
									CMN_API_GuidedInteraction.PARAMETER_REQUEST_BODY,
									JSON.serialize(prepareRequestBody(clonedRequest))
							);

			webServiceRequests.add(webServiceRequest);
		}

		requestToQueueMap.put(index, webServiceRequests);
	}

	/**
	 * @description Will prepare the request for Communication API
	 *
	 * @param dtoRequest DTO containing all details sent from a flow
	 *
	 * @return CMN_DTO_SendCommunicationRequest
	 */
	private static CMN_DTO_SendCommunicationRequest prepareRequestBody(CMN_DTO_CommunicationTemplate dtoRequest)
	{
		CMN_CommunicationTemplate__c template = (CMN_CommunicationTemplate__c)templateMap.get(dtoRequest.templateId);

		Case caseDetails = (Case)caseMap.get(dtoRequest.recordId);
		CMN_DTO_SendCommunicationRequest newDTORequest = new CMN_DTO_SendCommunicationRequest();
		CMN_DTO_SendCommunicationRequest.DTO_DocumentManagement dtoDocumentManagement = new CMN_DTO_SendCommunicationRequest.DTO_DocumentManagement();

		CMN_DTO_SendCommunicationRequest.DTO_Requester dtoRequester = new CMN_DTO_SendCommunicationRequest.DTO_Requester();
		dtoRequester.requestCompany = setting?.CMN_RequesterCompany__c;
		dtoRequester.requestBusinessUnit = setting?.CMN_RequesterBusinessUnit__c;
		dtoRequester.requestDepartment = caseDetails?.RSC_Department__c;
		dtoRequester.requestTeam = caseDetails?.RSC_Team__c;
		dtoRequester.requestSystemId = setting?.CMN_RequestSystemId__c;
		dtoRequester.requestId = uacfId;

		dtoRequester.documentReference = CMN_UTIL_Random.randomUUID();
		mapDocumentReferenceToRecipient.put(dtoRequester.documentReference, dtoRequest.recipients.iterator().next().recipientType);

		dtoDocumentManagement.requester = dtoRequester;

		CMN_DTO_SendCommunicationRequest.DTO_ReplyOption dtoReplyOption = new CMN_DTO_SendCommunicationRequest.DTO_ReplyOption();
		dtoReplyOption.replyInSession = !(dtoRequest.replyWithDocuments == true);
		dtoReplyOption.replyWithDocuments = dtoRequest.replyWithDocuments == true;
		dtoDocumentManagement.replyOptions = dtoReplyOption;

		dtoDocumentManagement.passwordProtection = dtoPasswordProtection;

		CMN_DTO_SendCommunicationRequest.DTO_DistributeTo dtoDistributeTo = new CMN_DTO_SendCommunicationRequest.DTO_DistributeTo();
		List<CMN_DTO_SendCommunicationRequest.DTO_Email> dtoEmails = new List<CMN_DTO_SendCommunicationRequest.DTO_Email>();
		List<CMN_DTO_SendCommunicationRequest.DTO_Recipient> dtoRecipients = new List<CMN_DTO_SendCommunicationRequest.DTO_Recipient>();

		dtoRecipients.addAll(populateRecipients(dtoRequest.recipients));

		CMN_DTO_SendCommunicationRequest.DTO_Email dtoEmail = new CMN_DTO_SendCommunicationRequest.DTO_Email();
		dtoEmail.recipient = dtoRecipients;
		dtoEmail.replyToAddress = setting?.CMN_ReplyToEmailAddress__c;
		dtoEmails.add(dtoEmail);

		dtoDistributeTo.email = dtoEmails;
		dtoDistributeTo.fax = new List<CMN_DTO_SendCommunicationRequest.DTO_Fax>();
		dtoDistributeTo.post = new CMN_DTO_SendCommunicationRequest.DTO_Post();
		dtoDocumentManagement.distributeTo = dtoDistributeTo;

		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData cmnCommunicationDataWrapper = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		cmnCommunicationDataWrapper.emailType = template.CMN_CommunicationsLabel__c;
		cmnCommunicationDataWrapper.workType = caseDetails.RSC_ServiceType__r.SC_CommunicationsLabel__c;
		cmnCommunicationDataWrapper.recipientRole = RECIPIENT_ROLE.get(dtoRequest.recipients.iterator().next().recipientType);
		cmnCommunicationDataWrapper.templateId = dtoRequest.templateId;
		cmnCommunicationDataWrapper.objectId = dtoRequest.recordId;
		cmnCommunicationDataWrapper.parameterIds = dtoRequest.parameterIds;
		cmnCommunicationDataWrapper.otherComments = dtoRequest.otherComments;
		cmnCommunicationDataWrapper.attachments = dtoRequest.selectedAttachments;
		cmnCommunicationDataWrapper.passwordProtect = dtoRequest.passwordProtection;

		CMN_DTO_CommunicationRecipients dtoRecipient = dtoRequest.recipients.iterator().next();

		cmnCommunicationDataWrapper.recipientInitials = dtoRecipient.initials;
		cmnCommunicationDataWrapper.recipientSurname = dtoRecipient.recipientSurname;
		cmnCommunicationDataWrapper.recipientTitle = dtoRecipient.recipientTitle;

		dtoDocumentManagement.documents = CMN_DAL_BaseTemplateSelector.getData(template.CMN_SelectorClassName__c, cmnCommunicationDataWrapper);
		newDTORequest.documentManagement = dtoDocumentManagement;
		return newDTORequest;
	}

	/**
	 * @description Will populate the recipient details for Communication API
	 *
	 * @param recipients List of Communication Recipients
	 *
	 * @return List of DTO Recipients
	 */
	private static List<CMN_DTO_SendCommunicationRequest.DTO_Recipient> populateRecipients(List<CMN_DTO_CommunicationRecipients> recipients)
	{
		List<CMN_DTO_SendCommunicationRequest.DTO_Recipient> dtoRecipients = new List<CMN_DTO_SendCommunicationRequest.DTO_Recipient>();
		for(CMN_DTO_CommunicationRecipients recipient : recipients)
		{
			CMN_DTO_SendCommunicationRequest.DTO_Recipient dtoRecipient = new CMN_DTO_SendCommunicationRequest.DTO_Recipient();
			dtoRecipient.emailAddress = recipient.emailAddress;
			dtoRecipient.emailType = recipient.emailType;
			dtoRecipient.cellphoneNumber = recipient.cellphoneNumber;
			dtoRecipients.add(dtoRecipient);
		}
		return dtoRecipients;
	}

	/**
	 * @description Will make callouts per the requests provided and log the results of the callout
	 */
	private static void callServiceAndLogResults()
	{
		if(!requestToQueueMap.isEmpty())
		{
			List<CMN_WebserviceCallQueue__c> webServiceRequests = new List<CMN_WebserviceCallQueue__c>();

			for(List<CMN_WebserviceCallQueue__c> requests : requestToQueueMap.values())
			{
				webServiceRequests.addAll(requests);
			}

			handlerByQueueMap = new Map<Id, CMN_API_HttpBase>();

			for(CMN_API_HttpBase handler : CMN_FACTORY_WebserviceManager.execute(webServiceRequests))
			{
				handlerByQueueMap.put(handler.getQueueItem().Id, handler);
			}

			populateDtoResponsesAndCommit();
		}
	}

	/**
	 * @description Will populate the payload in the DTO response
	 */
	private static void populateDtoResponsesAndCommit()
	{
		//Ensure we bypass sharing when committing logs, due to current users permissions
		unitOfWork = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType> {CMN_CommunicationLog__c.SObjectType, CMN_CommunicationLogForm__c.SObjectType});

		for(Integer i = 0; i < requests.size(); i++)
		{
			List<CMN_WebserviceCallQueue__c> requestItems = requestToQueueMap.get(i);

			if(requestItems == null)
			{
				continue;
			}

			DTO_Response dtoResponse = new DTO_Response();
			Boolean success = true;
			List<String> responses = new List<String>();

			for(CMN_WebserviceCallQueue__c requestItem : requestItems)
			{
				CMN_API_HttpBase handler = handlerByQueueMap.get(requestItem.Id);
				Id recordId = requestItem.CMN_TriggeringObjectId__c;

				CMN_DTO_CommunicationTemplate templateData = recordIdToTemplateMap.get(recordId);

				CMN_DTO_SendCommunicationRequest communicationRequest =
						(CMN_DTO_SendCommunicationRequest)JSON.deserialize(handler.callResult.requestBody, CMN_DTO_SendCommunicationRequest.class);
				String selectedRecipient = mapDocumentReferenceToRecipient.get(communicationRequest.documentManagement.requester.documentReference);
				String status;

				if(handler.callResult.completed)
				{
					responses.add(handler.callResult.responseBody);
					status = CMN_DAL_CommunicationLog.STATUS_SUCCESS;
				}
				else
				{
					success = false;
					responses.add(String.join(handler.callResult.errors, CMN_UTIL_String.LF));
					status = CMN_DAL_CommunicationLog.STATUS_FAILURE;
				}

				populateCommunicationLog(templateData, status, selectedRecipient);
			}

			dtoResponse.success = success;
			dtoResponse.responses = responses;

			dtoResponses.add(dtoResponse);
		}

		unitOfWork.commitWork(false);
	}

	/**
	 * @description Will add new communication logs & related forms to unit of work
	 *
	 * @param templateData DTO containing all details sent from a flow
	 * @param status Status of the communication log
	 * @param selectedRecipient Recipient sent with the request
	 */
	private static void populateCommunicationLog(CMN_DTO_CommunicationTemplate templateData, String status, String selectedRecipient)
	{
		CMN_CommunicationLog__c communicationLog = new CMN_CommunicationLog__c();
		communicationLog.Case__c = templateData.recordId;
		communicationLog.CMN_OtherComments__c = templateData.otherComments;
		communicationLog.CMN_SendReminder__c = CMN_UTIL_Boolean.isTrue(templateData.sendEmail);
		communicationLog.CMN_Recipients__c = selectedRecipient;
		communicationLog.CMN_RequestedDocuments__c = templateData.replyWithDocuments;
		communicationLog.CMN_Status__c = status;
		communicationLog.CMN_CommunicationTemplate__c = templateData.templateId;

		unitOfWork.registerNew(communicationLog);

		if(templateData.selectedAttachments != null && templateData.selectedAttachments.size() > 0)
		{
			for(CMN_DTO_CommunicationAttachment attachment : templateData.selectedAttachments)
			{
				CMN_CommunicationLogForm__c communicationLogForm = new CMN_CommunicationLogForm__c();
				communicationLogForm.CMN_CommunicationAttachmentDefinition__c = attachment.attachmentDefinitionId;
				communicationLogForm.CMN_Reason__c = attachment.reason;

				unitOfWork.registerNew(communicationLogForm, CMN_CommunicationLogForm__c.CMN_CommunicationLog__c, communicationLog);
			}
		}
	}

	/**
	 * @description Will populate the password details in the DTO request
	 *
	 * @param dtoRequest DTO containing all details sent from a flow
	 */
	private static void populatePasswordDetails(CMN_DTO_CommunicationTemplate dtoRequest)
	{
		Case requestCase = caseMap.get(dtoRequest.recordId);

		String password = CMN_UTIL_String.EMPTY;
		String passwordType = CMN_UTIL_String.EMPTY;

		if(requestCase.Account.RecordType.DeveloperName == AW_DAL_Account.RT_PERSON_MASTER_ACCOUNT)
		{
			if(requestCase.Account.AW_IdentificationType__pc == AW_DAL_Account.PICK_SA_ID_TYPE && requestCase.Account.AW_IdentificationNumber__pc != null)
			{
				password = requestCase.Account.AW_IdentificationNumber__pc;
				passwordType = CMN_DAL_CommunicationTemplate.IDENTIFICATION_NUMBER_TYPE;
			}
			else if(requestCase.Account.AW_IdentificationType__pc == AW_DAL_Account.PICK_PASSPORT_TYPE && requestCase.Account.AW_IdentificationNumber__pc != null)
			{
				password = requestCase.Account.AW_IdentificationNumber__pc;
				passwordType = CMN_DAL_CommunicationTemplate.PASSPORT_NUMBER_TYPE;
			}
			else if(requestCase.Account.PersonBirthdate != null)
			{
				password = requestCase.Account.PersonBirthdate.format();
				passwordType = CMN_DAL_CommunicationTemplate.BIRTH_DATE_TYPE;
			}
		}
		else if(AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT.equals(requestCase.Account.RecordType.DeveloperName) &&
				String.isNotBlank(requestCase.Account.AW_CompanyRegistrationTrustNumber__c))
		{
			password = requestCase.Account.AW_CompanyRegistrationTrustNumber__c;
			passwordType = CMN_DAL_CommunicationTemplate.COMPANY_REGISTRATION_NUMBER_TYPE;
		}

		dtoPasswordProtection.password = password;
		dtoPasswordProtection.passwordType = CMN_DAL_CommunicationTemplate.PASSWORD_TYPES.get(passwordType);
	}

	/**
	 * @description Response variable representing the webservice response or errors and a success indicator
	 */
	public class DTO_Response
	{
		/**
		 * @description A boolean representation of the success or failure of the callout
		 */
		@InvocableVariable(Label='API Response Success Indicator' Description='A boolean representation of the success or failure of the callout')
		public Boolean success;
		/**
		 * @description Contains JSON response for request or if error message if the callout failed
		 */
		@InvocableVariable(Label='API Response or Error Response' Description='Contains JSON response for request or if error message if the callout failed')
		public List<String> responses;
	}
}