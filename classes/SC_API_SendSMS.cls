/**
 * @description Base class for Send SMS API
 *
 * @see SC_API_SendSMS_TEST @story ST-297814
 * 
 * @author vijay.jayswal@accenture.com jason.va.beukering@accenture.com
 *
 * @date December 2022
 */
public inherited sharing class SC_API_SendSMS extends CMN_API_RestBaseOutboundMule
{
	private static final Integer ALLOWED_SMS_SIZE = 160;
	private static final String ERROR_CASE_NOT_FOUND = 'Unable to process request as Case not found';
	private static final String ERROR_EMAIL_TEMPLATE_NOT_FOUND = 'Unable to process request as Email Template not found';
	private static final String ERROR_PHONE_NUMBER_NOT_FOUND = 'Unable to process request as Phone Number not found';

	/**
	 * @description Email template Name
	 */
	@TestVisible
	private static final String PARAMETER_EMAIL_TEMPLATE_NAME = 'templateName';
	/**
	 * @description Recipient Mobile Number
	 */
	@TestVisible
	private static final String PARAMETER_RECIPIENT_MOBILE_NUMBER = 'recipientNumber';

	/**
	 * @description SERVICE_NAME variable holds the class name
	 */
	public static final String SERVICE_NAME = SC_API_SendSMS.class.getName();

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
	@SuppressWarnings('PMD.CognitiveComplexity')
	protected override Boolean abortRequest()
	{
		Boolean mustAbort = super.abortRequest();

		if(!mustAbort)
		{
			DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

			if(CMN_UTIL_System.getSObjectTypeById(queueItem.CMN_TriggeringObjectId__c) == Case.SObjectType)
			{
				Case foundCase = SC_DAL_Case.findById(queueItem.CMN_TriggeringObjectId__c);

				if(foundCase == null)
				{
					mustAbort = true;
					callResult.errors.add(ERROR_CASE_NOT_FOUND);
				}
				else
				{
					dtoRequest.recipientNumber = String.isBlank(foundCase.Account.PersonMobilePhone) ?
							foundCase.SC_CaseExtension__r.RSC_ClientCellNumber__c : foundCase.Account.PersonMobilePhone;
				}
			}

			dtoRequest.recipientNumber = String.isBlank(dtoRequest.recipientNumber) ?
					requestParameters.getFirst(PARAMETER_RECIPIENT_MOBILE_NUMBER) : dtoRequest.recipientNumber;

			if(String.isBlank(dtoRequest.recipientNumber))
			{
				mustAbort = true;
				callResult.errors.add(ERROR_PHONE_NUMBER_NOT_FOUND);
			}

			String templateName = requestParameters.getFirst(PARAMETER_EMAIL_TEMPLATE_NAME);

			if(String.isBlank(templateName))
			{
				mustAbort = true;
				callResult.errors.add(ERROR_EMAIL_TEMPLATE_NOT_FOUND);
			}
			else
			{
				dtoRequest.template = CMN_DAL_EmailTemplate.findByName(templateName);

				if(dtoRequest.template == null)
				{
					mustAbort = true;
					callResult.errors.add(ERROR_EMAIL_TEMPLATE_NOT_FOUND);
				}
			}

			dtoRequest.consumerName = getAdditionalKey();

		}

		return mustAbort;
	}

	/**
	 * @description register all the object types we want to update
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType>
		{
				Task.SObjectType
		});
	}

	/**
	 * @description Will save updates
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;
		DTO_Sms dtoSms = dtoRequest.smsRecord.iterator().next();

		Task newTask = new Task();

		newTask.Description = dtoSms.text;
		newTask.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Task.SObjectType, AW_DAL_Task.RT_OUTBOUND_TASK);
		newTask.Status = AW_DAL_Task.STATUS_COMPLETED;
		newTask.Subject = dtoRequest.template.Subject;
		newTask.WhatId = queueItem.CMN_TriggeringObjectId__c;

		registerChange(newTask);
	}

	/**
	 * @description Override to return inner class having Mock response
	 *
	 * @return CMN_API_HttpBaseOutboundMock CMN_API_HttpBaseOutboundMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new SC_API_SendSMSMock();
	}

	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	private class SC_API_SendSMSMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"Message": "SMS added successfully"}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
	/**
	 * @description Inner class to define structure of request body and populate the same for API call
	 */
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		private transient EmailTemplate template;
		private transient String recipientNumber;
		public List<DTO_Sms> smsRecord;
		public String consumerName;

		/**
		 * @description Populate the object using the triggerObjectId to get relevant data
		 *
		 * @param triggeringObjectId as input
		 */
		public override void populate(Id triggeringObjectId)
		{
			Messaging.SingleEmailMessage renderedEmail = Messaging.renderStoredEmailTemplate
					(
							template.Id,
							null,
							triggeringObjectId,
							Messaging.AttachmentRetrievalOption.NONE
					);

			smsRecord = new List<DTO_Sms>();

			List<String> smsTexts = CMN_UTIL_String.split(renderedEmail.plainTextBody, ALLOWED_SMS_SIZE);

			for(String smsText : smsTexts)
			{
				if(String.isNotBlank(smsText)) //Last chunk may just be whitespace and so we don't want to send an sms
				{
					DTO_Sms dtoSms = new DTO_Sms();

					dtoSms.text = smsText;
					dtoSms.toNumber = recipientNumber;

					smsRecord.add(dtoSms);
				}
			}
		}
	}

	/**
	 * @description The DTO that will be used to parse the response
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		@SuppressWarnings('PMD.FieldNamingConventions,ApexUnusedDeclaration,ApexControlFlowAnalysis')
		private String Message;

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
	 * @description DTO containing required details to generate an SMS
	 */
	@TestVisible
	private class DTO_Sms
	{
		public String toNumber;
		public String text;
	}
}