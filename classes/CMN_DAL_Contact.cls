/**
 * @description Data Access Layer SOQL related to the Contact Object, this is common class to be used across applications
 *
 * @see Contact
 *
 * @author prashant.k.jain@accenture.com
 *
 * @date April 2021, July 2022
 */
public inherited sharing class CMN_DAL_Contact
{
	@TestVisible
	private static final String FIELD_ACCOUNT_ID = Contact.AccountId.getDescribe().getLocalName();
	private static final String FIELD_ACCOUNT_NAME = 'Account.Name';
	@TestVisible
	private static final String FIELD_LAST_NAME = Contact.LastName.getDescribe().getLocalName();

	/**
	 * @description The API name of the object
	 */
	public static final String OBJECT_NAME = Contact.SObjectType.getDescribe().getLocalName();

	/**
	 * @description A list of the common contact fields to query
	 *
	 * @return A set of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				Contact.AssistantName.getDescribe().getLocalName(),
				Contact.AssistantPhone.getDescribe().getLocalName(),
				Contact.Birthdate.getDescribe().getLocalName(),
				Contact.Department.getDescribe().getLocalName(),
				Contact.Description.getDescribe().getLocalName(),
				Contact.Email.getDescribe().getLocalName(),
				Contact.EmailBouncedDate.getDescribe().getLocalName(),
				Contact.FirstName.getDescribe().getLocalName(),
				Contact.HomePhone.getDescribe().getLocalName(),
				Contact.MobilePhone.getDescribe().getLocalName(),
				Contact.Name.getDescribe().getLocalName(),
				Contact.OwnerId.getDescribe().getLocalName(),
				Contact.Phone.getDescribe().getLocalName(),
				Contact.Salutation.getDescribe().getLocalName(),
				Contact.Title.getDescribe().getLocalName(),
				FIELD_ACCOUNT_ID,
				FIELD_ACCOUNT_NAME,
				FIELD_LAST_NAME
		};
	}

	/**
	 * @description Will return all the contacts in the system using default fields
	 *
	 * @return A list of contacts
	 */
	@TestVisible
	private static List<Contact> getAll()
	{
		return CMN_DAL_Search.getAll(Contact.SObjectType, getDefaultFields());
	}
}