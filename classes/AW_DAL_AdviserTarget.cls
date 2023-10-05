/**
 * @description Public class to return the records of Adviser Target
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_DAL_AdviserTarget
{
	private static final String OBJECT_NAME = AW_AdviserTarget__c.SObjectType.getDescribe().getName();
	public static final String FIELD_COMPOSITE_KEY = AW_AdviserTarget__c.AW_AT_CompositeID__c.getDescribe().getName();

	/**
	 * @description Method to define the fields to retrieve Account Owner Config records
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				AW_AdviserTarget__c.Id.getDescribe().getLocalName(),
				AW_AdviserTarget__c.OwnerId.getDescribe().getLocalName(),
				FIELD_COMPOSITE_KEY

		};
	}

	/**
	 * @description This method is use to return the list of Adviser target with composiye keys
	 *
	 * @param compositeKeys
	 *
	 * @return List of AW_AdviserTarget__c
	 */
	public static List<AW_AdviserTarget__c> findByCompositeKeys(Set<String> compositeKeys)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_COMPOSITE_KEY, compositeKeys, getDefaultFields());
	}

	/**
	 * @description This method is use to return the list of Adviser target with Owner
	 *
	 * @param owners
	 *
	 * @return List of AW_AdviserTarget__c with Owner
	 */
	public static List<AW_AdviserTarget__c> findByOwnerIds(List<User> owners)
	{
		Set<String> ownerIds = new Set<String>();

		for(User owner : owners)
		{
			ownerIds.add(String.valueOf(owner.Id));
		}

		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_OWNER_ID, ownerIds, getDefaultFields());
	}

	/**
	 * @description This method is use to return the composite key
	 *
	 * @param month
	 * @param year
	 * @param uacfId
	 *
	 * @return compositeKey
	 */
	public static String constructTargetCompositeKey(String month, String year, String uacfId)
	{
		return month + year + CMN_UTIL_String.upperCase(uacfId);
	}
}