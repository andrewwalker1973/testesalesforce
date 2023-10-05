/**
 * @description An class with an invokable method that will allow sending an email from a Flow where its required that the email is logged as an activity
 * otherwise we would just use an email alert
 *
 * @see CMN_FLOW_SendEmail_TEST
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date March 2021, January 2022
 */
public inherited sharing class CMN_FLOW_SendEmail
{
	private static final Set<String> PERSON_OBJECT_NAMES =
			new Set<String>
			{
					CMN_DAL_Lead.OBJECT_NAME,
					Contact.SObjectType.getDescribe().getLocalName(),
					CMN_DAL_User.OBJECT_NAME
			};

	/**
	 * @description Sends out an email based on the variables received and saves as an Activity in feed
	 *
	 * @param dtoEmails A list of variables to be used to craft emails
	 *
	 * @return A list indicating if the send email was successful and if not what the error was
	 */
	@InvocableMethod
	(
			Label='Send Email and Log an Activity'
			Description='Will use the SingleEmailMessage class to send an email with a template and ensure activity is logged'
	)
	public static List<DTO_SendEmailResponse> sendEmail(List<DTO_SendEmailRequest> dtoEmails)
	{
		Set<String> templateNames = new Set<String>();
		Set<String> orgWideEmailAddresses = new Set<String>();

		//Collate all the template names and Org wide emails as we need to query their Ids
		for(DTO_SendEmailRequest dtoEmail : dtoEmails)
		{
			templateNames.add(dtoEmail.templateUniqueName);
			orgWideEmailAddresses.add(dtoEmail.orgWideEmailAddress);
		}

		//Retrieve all the Ids for the template names and org Wide email address, make available in maps for easy query
		List<EmailTemplate> emailTemplates = CMN_DAL_EmailTemplate.findByName(templateNames);
		List<OrgWideEmailAddress> orgWideAddresses = CMN_DAL_OrgWideEmailAddress.findByName(orgWideEmailAddresses);
		Map<String, SObject> templateMap = CMN_UTIL_System.convertListToSingleStringMap(emailTemplates, CMN_DAL_EmailTemplate.FIELD_DEVELOPER_NAME);
		Map<String, SObject> orgWideEmailMap = CMN_UTIL_System.convertListToSingleStringMap(orgWideAddresses, CMN_DAL_OrgWideEmailAddress.FIELD_ADDRESS);

		List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();

		for(DTO_SendEmailRequest dtoEmail : dtoEmails)
		{
			mailsToSend.add(constructEmail(dtoEmail, templateMap, orgWideEmailMap));
		}

		return constructResponses(Messaging.sendEmail(mailsToSend, false));
	}

	/**
	 * @description Will take request DTO and construct an email message
	 *
	 * @param dtoEmail Details for the email to create
	 * @param templateMap A map of email templates, used when constructing an email
	 * @param orgWideEmailMap A map of org wide mails, used when constructing an email
	 *
	 * @return An email constructed using details provided
	 */
	private static Messaging.SingleEmailMessage constructEmail
			(
					DTO_SendEmailRequest dtoEmail,
					Map<String, SObject> templateMap,
					Map<String, SObject> orgWideEmailMap
			)
	{
		Id whoId = PERSON_OBJECT_NAMES.contains(CMN_UTIL_System.getObjectNameFromId(CMN_UTIL_String.validateId(dtoEmail.toAddress))) ?
				Id.valueOf(dtoEmail.toAddress) : null;
		whoId = whoId == null && PERSON_OBJECT_NAMES.contains(CMN_UTIL_System.getObjectNameFromId(dtoEmail.whatId)) ?
				dtoEmail.whatId : whoId;

		Messaging.SingleEmailMessage newMail = Messaging.renderStoredEmailTemplate
				(
						templateMap.get(dtoEmail.templateUniqueName)?.Id,
						whoId,
						dtoEmail.whatId,
						Messaging.AttachmentRetrievalOption.METADATA_ONLY
				);

		newMail.setTargetObjectId(whoId);
		newMail.setSaveAsActivity(whoId != null);
		newMail.setToAddresses(new List<String> {dtoEmail.toAddress});
		newMail.setOrgWideEmailAddressId(orgWideEmailMap.get(dtoEmail.orgWideEmailAddress)?.Id);
		newMail.setEntityAttachments(dtoEmail.fileIds);

		return newMail;
	}

	/**
	 * @description Will construct responses from the results of an email send
	 *
	 * @param sendEmailResults Email results from an attempt send operation
	 *
	 * @return A list of DTO responses
	 */
	private static List<DTO_SendEmailResponse> constructResponses(List<Messaging.SendEmailResult> sendEmailResults)
	{
		List<DTO_SendEmailResponse> dtoResponses = new List<DTO_SendEmailResponse>();

		//In the event errors did occur for some emails, ensure these are logged for debugging purposes
		for(Messaging.SendEmailResult sendEmailResult : sendEmailResults)
		{
			DTO_SendEmailResponse dtoResponse = new DTO_SendEmailResponse();
			dtoResponse.success = sendEmailResult.success;

			if(!sendEmailResult.success)
			{
				List<String> messages = new List<String>();

				for(Messaging.SendEmailError sendEmailError : sendEmailResult.errors)
				{
					String message = sendEmailError.statusCode.name();

					if(String.isNotBlank(sendEmailError.message))
					{
						message += CMN_UTIL_String.COLON + sendEmailError.message;
					}

					CMN_UTIL_Logger.error(message, 'CMN_FLOW_SendEmail/sendEmail');
					messages.add(message);
				}

				dtoResponse.errors = CMN_UTIL_String.joinArray(messages, CMN_UTIL_String.LF);
			}

			dtoResponses.add(dtoResponse);
		}

		return dtoResponses;
	}

	/**
	 * @description DTO to initiate a send email request
	 */
	@SuppressWarnings('ApexDocValidation,LongLine')
	public class DTO_SendEmailRequest
	{
		/**
		 * @description A list of email addresses or object IDs of the contacts, leads, and users you’re sending the email to.
		 * The maximum size for this field is 4,000 bytes. The maximum total of toAddresses, ccAddresses, and bccAddresses per email is 150.
		 * All recipients in these three fields count against the limit for email sent using Apex or the API.
		 */
		@InvocableVariable
		(
				Label='To Address'
				Description='The ID of the contact, lead, or user to which the email will be sent. The ID you specify sets the context and ensures that merge fields in the template contain the correct data. If no ID is available send the email address of the recipient'
				Required=false
		)
		public String toAddress;

		@InvocableVariable(Label='Template Unique Name' Description='The unique name of the template that will be used to generate the email' Required=true)
		public String templateUniqueName;

		@InvocableVariable(Label='Org Wide Email Address' Description='Will define the org wide email address to use as the from for the email' Required=true)
		public String orgWideEmailAddress;

		/**
		 * @description if you specify a contact for the targetObjectId field, you can specify an optional whatId as well.
		 * This helps to further ensure that merge fields in the template contain the correct data.
		 * <p/>
		 * The value must be one of the following types:
		 * Account
		 * Asset
		 * Campaign
		 * Case
		 * Contract
		 * Opportunity
		 * Order
		 * Product
		 * Solution
		 * Custom
		 */
		@InvocableVariable(Label='Related To ID' Description='An Object Id that can be related the email' Required=true)
		public Id whatId;

		@InvocableVariable
		(
				Label='List of Attachment Identifiers'
				Description='List of Attachment Identifiers to add Files as attachments to the email'
				Required=false
		)
		public List<Id> fileIds;
	}

	/**
	 * @description Indicates if a request to send an email was successful or not
	 */
	@SuppressWarnings('ApexDocValidation,LongLine')
	public class DTO_SendEmailResponse
	{
		@InvocableVariable
		(
				Label='Send Successful'
				Description='Indicates whether the email was successfully submitted for delivery (true) or not (false). Even if isSuccess is true, it does not mean the intended recipients received the email, as there could have been a problem with the email address or it could have bounced or been blocked by a spam blocker.'
				Required=true
		)
		public Boolean success;
		@InvocableVariable(Label='Errors' Description='A List of errors encountered when attempting to do the send email' Required=false)
		public String errors;
	}
}