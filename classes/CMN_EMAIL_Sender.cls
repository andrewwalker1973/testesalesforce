/**
 * @description This code is part of the "apex-lang" open-source project release 1.18 available at:
 * <p/>
 * http://code.google.com/p/apex-lang/
 * <p/>
 * Copyright (2012) richard van hook
 * <p/>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p/>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p/>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * <p/>
 * This project code has been forked and to update the latest salesforce APIs.
 *
 * @see CMN_EMAIL_Sender_TEST
 */
public inherited sharing class CMN_EMAIL_Sender
{
	/**
	 * @description Map to link deliverability access level text to equivalent enumeration
	 */
	private static final Map<String, DeliverabilityAccessLevel> ACCESS_LEVEL_MAP = new Map<String, CMN_EMAIL_Sender.DeliverabilityAccessLevel>
	{
			'System email only' => DeliverabilityAccessLevel.SYSTEM_EMAIL_ONLY,
			'All email' => DeliverabilityAccessLevel.ALL_EMAIL,
			'No access' => DeliverabilityAccessLevel.NO_ACCESS
	};

	/**
	 * @description Enumeration representing levels of Email deliverability access
	 */
	public enum DeliverabilityAccessLevel
	{
		NO_ACCESS, SYSTEM_EMAIL_ONLY, ALL_EMAIL
	}

	/**
	 * @description Will return the current Orgs' Email Deliverability Setting
	 *
	 * @return The relevant access level
	 *
	 * @see https://trailblazer.salesforce.com/ideaView?id=08730000000cHBEAA2
	 */
	public static DeliverabilityAccessLevel getEmailDeliverabilityAccessLevel()
	{
		PageReference emailSettingsPage = new PageReference('/email-admin/editOrgEmailSettings.apexp');
		String htmlBody = Test.isRunningTest() ? ' selected="selected">No access</option>' : emailSettingsPage.getContent().toString().replace(CMN_UTIL_String.LF, CMN_UTIL_String.EMPTY);
		String accessLevel = htmlBody.substringBetween(' selected="selected">', '</option>');

		DeliverabilityAccessLevel accessLevelEnumeration = ACCESS_LEVEL_MAP.get(accessLevel);
		return accessLevelEnumeration == null ? DeliverabilityAccessLevel.NO_ACCESS : accessLevelEnumeration;
	}

	/**
	 * @description sends an email with standard attachments (ids)
	 *
	 * @param recipients as input
	 * @param emailSubject as input
	 * @param body as input
	 * @param useHTML as input
	 * @param attachmentIds as input
	 */
	public static void sendEmailWithStandardAttachments(List<String> recipients, String emailSubject,
			String body, Boolean useHTML, List<Id> attachmentIds)
	{
		List<Attachment> stdAttachments =
		[
				SELECT Id,
						Name,
						Body
				FROM Attachment
				WHERE Id IN :attachmentIds
		];
		sendEmailWithStandardAttachments(recipients, emailSubject, body, useHTML, stdAttachments);
	}

	/**
	 * @description sends an email with standard attachments (sobjects)
	 *
	 * @param recipients as input
	 * @param emailSubject as input
	 * @param body as input
	 * @param useHTML as input
	 * @param stdAttachments as input
	 */
	public static void sendEmailWithStandardAttachments(List<String> recipients, String emailSubject, String body,
			Boolean useHTML, List<Attachment> stdAttachments)
	{
		List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();

		for(Attachment attachment : stdAttachments)
		{
			Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
			fileAttachment.setFileName(attachment.Name);
			fileAttachment.setBody(attachment.Body);
			fileAttachments.add(fileAttachment);
		}

		sendEmail(recipients, emailSubject, body, useHTML, fileAttachments);
	}

	/**
	 * @description set text email
	 *
	 * @param recipients as input
	 * @param emailSubject as input
	 * @param textBody as input
	 */
	public static void sendTextEmail(List<String> recipients, String emailSubject, String textBody)
	{
		sendEmail(recipients, emailSubject, textBody, false, null);
	}

	/**
	 * @description send html email
	 *
	 * @param recipients as input
	 * @param emailSubject as input
	 * @param htmlBody as input
	 */
	public static void sendHTMLEmail(List<String> recipients, String emailSubject, String htmlBody)
	{
		sendEmail(recipients, emailSubject, htmlBody, true, null);
	}

	/**
	 * @description set email with field attachments
	 *
	 * @param recipients as input
	 * @param emailSubject as input
	 * @param body as input
	 * @param useHTML as input
	 * @param fileAttachments as input
	 */
	public static void sendEmail(List<String> recipients, String emailSubject, String body, Boolean useHTML,
			List<Messaging.EmailFileAttachment> fileAttachments)
	{
		if(recipients == null)
		{
			return;
		}
		if(recipients.size() == 0)
		{
			return;
		}

		// Create a new single email message object
		// that will send out a single email to the addresses in the To, CC & BCC list.
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		//the email is not saved as an activity.
		mail.setSaveAsActivity(false);

		// Assign the addresses for the To lists to the mail object.
		mail.setToAddresses(recipients);

		// Specify the subject line for your email address.
		mail.setSubject(emailSubject);

		// Set to True if you want to BCC yourself on the email.
		mail.setBccSender(false);

		// The email address of the user executing the Apex Code will be used.
		mail.setUseSignature(false);

		if(useHTML)
		{
			// Specify the html content of the email.
			mail.setHtmlBody(body);
		}
		else
		{
			// Specify the text content of the email.
			mail.setPlainTextBody(body);
		}

		// Specify FileAttachments
		if(fileAttachments != null && fileAttachments.size() > 0)
		{
			mail.setFileAttachments(fileAttachments);
		}

		// Send the email you have created. Note: Some environments will have email switched off, so make sure we don't throw an exception if email fails as a result during unit test run
		Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail}, !Test.isRunningTest());
	}

	/**
	 * @description checks if email address is in valid format
	 * <p/>
	 * null     => false
	 * ''       => false
	 * ' '      => false
	 * 'x'      => false
	 * 'x@'     => false
	 * 'x@x'    => false
	 * 'x@x.x'  => true
	 *
	 * @param str as input
	 *
	 * @return boolean if valid or not
	 */
	public static Boolean isValidEmailAddress(String str)
	{
		if(str != null && str.trim() != null && str.trim().length() > 0)
		{
			List<String> split = str.split('@');
			if(split != null && split.size() == 2)
			{
				split = split[1].split('\\.');
				if(split != null && split.size() >= 2)
				{
					return true;
				}
			}
		}
		return false;
	}

	/**
	 * @description counter checks is not valid email address
	 *
	 * @param str as input
	 *
	 * @return boolean if invalid or is
	 */
	public static Boolean isNotValidEmailAddress(String str)
	{
		return !isValidEmailAddress(str);
	}
}