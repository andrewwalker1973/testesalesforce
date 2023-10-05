/**
 * @description Public class to return the records of Case
 *
 * @author Accenture
 *
 * @date 2021
 */
public inherited sharing class AW_DAL_Case
{
	private static final String OBJECT_NAME = Case.SObjectType.getDescribe().getLocalName();

	public static final String FIELD_ACCOUNT_ID = Case.AccountId.getDescribe().getLocalName();
	public static final String FIELD_CONTACT_ID = Case.ContactId.getDescribe().getLocalName();

	public static final String PICK_ORIGIN_PHONE = 'Phone';
	public static final String PICK_STATUS_WORKING = 'Working';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				Case.AW_MasterAccount__c.getDescribe().getLocalName(),
				Case.Id.getDescribe().getLocalName(),

				Case.OwnerId.getDescribe().getLocalName(),
				FIELD_ACCOUNT_ID

		};
	}
	/**
	 * @description Will find an Case by Id
	 *
	 * @param caseId The Id of the Case
	 *
	 * @return Either the item found or null
	 */
	@TestVisible
	private static Case findById(Id caseId)
	{
		return (Case)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, caseId, getDefaultFields());
	}
}