/**
 * @description Public class to return the record of EmailMessage
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing class AW_DAL_EmailMessage
{
	public static final String OBJECT_NAME = EmailMessage.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				EmailMessage.AW_MasterAccount__c.getDescribe().getLocalName(),
				EmailMessage.Id.getDescribe().getLocalName()
		};
	}
	/**
	 * @description Will find an EmailMessage by Id
	 *
	 * @param emailMessageId The Id of the EmailMessage
	 *
	 * @return Either the item found or null
	 */
	public static EmailMessage findById(Id emailMessageId)
	{
		List<EmailMessage> emailMessages = findById(new Set<Id> {emailMessageId});

		return emailMessages.isEmpty() ? null : emailMessages[0];
	}

	/**
	 * @description Will find a list of EmailMessage by Id
	 *
	 * @param emailMessageId The Set of EmailMessage Ids to retrieve
	 *
	 * @return List of EmailMessage
	 */
	public static List<EmailMessage> findById(Set<Id> emailMessageId)
	{
		return (List<EmailMessage>)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, emailMessageId, getDefaultFields());
	}
}