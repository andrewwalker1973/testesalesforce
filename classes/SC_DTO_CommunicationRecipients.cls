/**
 * @description DTO representing the recipients to be sent with the Communication API
 *
 * @author aakriti.a.goyal@accenture.com
 *
 * @date September 2021, March 2022
 */
public inherited sharing class SC_DTO_CommunicationRecipients
{
	/**
	 * @description stores the email address of the recipient
	 */
	@InvocableVariable
	@AuraEnabled
	public String emailAddress;

	/**
	 * @description stores the email type of the recipient
	 */
	@InvocableVariable
	@AuraEnabled
	public String emailType;

	/**
	 * @description stores the phone number of the recipient
	 */
	@InvocableVariable
	@AuraEnabled
	public String cellphoneNumber;

	/**
	 * @description stores the role of the recipient
	 */
	@InvocableVariable
	@AuraEnabled
	public String recipientType;

	/**
	 * @description stores recipient title
	 */
	@InvocableVariable
	@AuraEnabled
	public String recipientTitle;

	/**
	 * @description stores recipient initials
	 */
	@InvocableVariable
	@AuraEnabled
	public String recipientInitials;

	/**
	 * @description stores recipient surname
	 */
	@InvocableVariable
	@AuraEnabled
	public String recipientSurname;
}