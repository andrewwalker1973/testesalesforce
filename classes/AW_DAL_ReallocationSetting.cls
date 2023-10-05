/**
 * @description Public class to return the records of Reallocation Setting metadata
 *
 * @author prashant.k.jain@accenture.com
 *
 * @date July 2021
 */
public inherited sharing class AW_DAL_ReallocationSetting
{
	public static final String DEVELOPER_NAME_ACCOUNT_REALLOCATION = 'AW_OrphanAccountReallocation';
	public static final String DEVELOPER_NAME_LEAD_REALLOCATION = 'AW_OrphanLeadReallocation';
	public static final String FIELD_IS_REALLOCATED = 'AW_IsReallocated__c';

	/**
	 * @description This method is use to get the list of all Lead And Account Orphan Reallocation
	 *
	 * @param developerName Developer name of the metadata record
	 *
	 * @return List of Reallocation Setting records
	 */
	public static AW_ReallocationSetting__mdt getInstance(String developerName)
	{
		return AW_ReallocationSetting__mdt.getInstance(developerName);
	}
}