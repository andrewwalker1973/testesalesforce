/**
 * @description DTO representing the recipients to be sent with the Communication API
 *
 * @author aakriti.a.goyal@accenture.com
 *
 * @date September 2021, July 2022
 */
public inherited sharing class CMN_DTO_CommunicationRecipients
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

	/**
	 * @description stores recipient first name
	 */
	@InvocableVariable
	@AuraEnabled
	public String recipientFirstName;

	/**
	 * @description stores recipient full name
	 */
	@InvocableVariable
	@AuraEnabled
	public String recipientFullName;

	/**
	 * @description Initials calculated from either full name or a combination of first and last names
	 */
	public String initials
	{
		get
		{
			//Initials will be derived from what ever is in the full name or first name combined with last name
			return CMN_UTIL_String.upperCase(String.isNotBlank(recipientInitials) ? recipientInitials : CMN_UTIL_Word.initials(String.isNotBlank(recipientFullName) ?
					recipientFullName : CMN_UTIL_String.trimToEmpty(recipientFirstName) + CMN_UTIL_String.SPACE + CMN_UTIL_String.trimToEmpty(recipientSurname)));
		}
	}
}