/**
 * @description Public class to return the records of EnvelopeRoles
 *
 * @author Annu
 *
 * @date July 2021
 */
public inherited sharing class AW_DAL_EnvelopeRole
{
	private static final String OBJECT_NAME = AW_EnvelopeRole__c.SObjectType.getDescribe().getLocalName();
	private static final String FIELD_PARENT_RECORD_ID = AW_EnvelopeRole__c.AW_Envelope__c.getDescribe().getLocalName();
	public static final String FIELD_ROLE_NAME = 'AW_Contact__r.Name';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				AW_EnvelopeRole__c.Name.getDescribe().getLocalName(),
				AW_EnvelopeRole__c.Id.getDescribe().getLocalName(),
				AW_EnvelopeRole__c.AW_Contact__c.getDescribe().getLocalName(),
				AW_EnvelopeRole__c.AW_Mobile__c.getDescribe().getLocalName(),
				AW_EnvelopeRole__c.AW_Email__c.getDescribe().getLocalName(),
				FIELD_PARENT_RECORD_ID,
				FIELD_ROLE_NAME
		};
	}

	/**
	 * @description This method is use to get the List of EnvelopeRoles with the particular ParenRecordId
	 *
	 * @param parentRecordId The record to which this item is associated
	 *
	 * @return A list of items
	 */
	public static List<AW_EnvelopeRole__c> findByParent(Id parentRecordId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_PARENT_RECORD_ID, new Set<Id> {parentRecordId}, getDefaultFields());
	}
}