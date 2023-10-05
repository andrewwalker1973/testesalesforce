/**
 * @description Public class to return the records of Assets and Liabilities
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing class AW_DAL_AssetsAndLiabilities
{
	private static final String FIELD_PRIMARY_OWNER = FinServ__AssetsAndLiabilities__c.FinServ__PrimaryOwner__c.getDescribe().getLocalName();
	public static final String FIELD_EXTERNAL_ID = FinServ__AssetsAndLiabilities__c.AW_AUMSourceExternalId__c.getDescribe().getLocalName();
	public static final String OBJECT_NAME = FinServ__AssetsAndLiabilities__c.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_EXTERNAL_ID,
				FIELD_PRIMARY_OWNER,
				FinServ__AssetsAndLiabilities__c.AW_MasterAccount__c.getDescribe().getLocalName(),
				FinServ__AssetsAndLiabilities__c.Id.getDescribe().getLocalName(),
				FinServ__AssetsAndLiabilities__c.OwnerId.getDescribe().getLocalName(),
				FinServ__AssetsAndLiabilities__c.RecordTypeId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will return the list of Assets and Liabilities.
	 *
	 * @param primaryOwnerId Id to store the primary owner
	 *
	 * @return A list of items
	 */
	@TestVisible
	private static List<FinServ__AssetsAndLiabilities__c> findByPrimaryOwnerId(Id primaryOwnerId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_PRIMARY_OWNER, new Set<Id> {primaryOwnerId}, getDefaultFields());
	}

	/**
	 * @description Will find an AssetsAndLiabilities by Id
	 *
	 * @param assetId The Id of the AssetsAndLiabilities
	 *
	 * @return Either the item found or null
	 */
	@TestVisible
	private static FinServ__AssetsAndLiabilities__c findById(Id assetId)
	{
		return (FinServ__AssetsAndLiabilities__c)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, assetId, getDefaultFields());
	}
}