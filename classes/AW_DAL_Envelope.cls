/**
 * @description Public class to return the records of Envelopes
 *
 * @author Accenture
 *
 * @date 2021
 */
public inherited sharing class AW_DAL_Envelope
{
	private static final String FIELD_PACKAGE_ID = AW_Envelope__c.AW_PackageID__c.getDescribe().getLocalName();
	public static final String FIELD_OWNER_EMAIL = 'Owner.Email';
	public static final String FIELD_OPPORTUNITY_ACCOUNT = 'AW_Opportunity__r.AccountId';
	public static final String OBJECT_NAME = AW_Envelope__c.SObjectType.getDescribe().getLocalName();
	public static final String STATUS_AWAITING_SIGNATURE = 'Awaiting Signature';
	public static final String STATUS_COMPLETED = 'Completed - Document Signed';
	public static final String STATUS_DECLINED = 'Declined';
	public static final String STATUS_NEW = 'New';
	public static final String STATUS_SENT_FOR_SIGNING = 'Sent to Signing Portal';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				AW_Envelope__c.AW_MasterAccount__c.getDescribe().getLocalName(),
				AW_Envelope__c.AW_Status__c.getDescribe().getLocalName(),
				AW_Envelope__c.AW_URL__c.getDescribe().getLocalName(),
				AW_Envelope__c.CreatedDate.getDescribe().getLocalName(),
				AW_Envelope__c.Id.getDescribe().getLocalName(),
				AW_Envelope__c.Name.getDescribe().getLocalName(),
				AW_Envelope__c.OwnerId.getDescribe().getLocalName(),
				AW_Envelope__c.AW_Account__c.getDescribe().getLocalName(),
				AW_Envelope__c.AW_LeadAndReferral__c.getDescribe().getLocalName(),
				AW_Envelope__c.AW_Opportunity__c.getDescribe().getLocalName(),
				FIELD_OPPORTUNITY_ACCOUNT,
				FIELD_OWNER_EMAIL,
				FIELD_PACKAGE_ID
		};
	}

	/**
	 * @description Will find an envelope by Id
	 *
	 * @param envelopeId The Id of the envelope
	 *
	 * @return Either the item found or null
	 */
	public static AW_Envelope__c findById(Id envelopeId)
	{
		List<AW_Envelope__c> envelopes = findById(new Set<Id> {envelopeId});

		return envelopes.isEmpty() ? null : envelopes[0];
	}

	/**
	 * @description Will find a list of envelope by Id
	 *
	 * @param envelopeIds The Set of envelope Ids to retrieve
	 *
	 * @return List of envelopes
	 */
	public static List<AW_Envelope__c> findById(Set<Id> envelopeIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, envelopeIds, getDefaultFields());
	}

	/**
	 * @description Will find an envelope by package Id
	 *
	 * @param packageId The Id of the package
	 *
	 * @return Either unique item, null (or throws an exception if not unique)
	 */
	public static AW_Envelope__c findByPackageId(String packageId)
	{
		return (AW_Envelope__c)CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_PACKAGE_ID, packageId, getDefaultFields(), true);
	}

	/**
	 * @description return all Envelopes created by test classes
	 *
	 * @return A list of items
	 */
	@TestVisible
	private static List<AW_Envelope__c> getAll()
	{
		return CMN_DAL_Search.getAll(AW_Envelope__c.SObjectType, getDefaultFields());
	}
}