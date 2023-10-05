/**
 * @description Class to fetch settings for Batch
 *
 * @see CMN_BatchSetting__mdt
 *
 * @author vishakha.saini@accenture.com, jason.van.beukering@accenture.com
 *
 * @date June 2022, July 2023
 */
public inherited sharing class CMN_DAL_BatchSetting
{
	/**
	 * @description Will return size of batch for the provided batch class. If no record is found it will default to standard batch size
	 *
	 * @param batchClassName Batch Apex Class name
	 *
	 * @return Batch size, not larger than the maximum.
	 */
	public static Integer getBatchSize(String batchClassName)
	{
		CMN_BatchSetting__mdt setting = CMN_BatchSetting__mdt.getInstance(batchClassName);

		Integer batchSize = CMN_DAL_SObjectDomain.DEFAULT_BATCH_SIZE;

		if(setting != null && setting.CMN_BatchSize__c >= 1)
		{
			batchSize = Math.min(Integer.valueOf(setting.CMN_BatchSize__c), CMN_DAL_SObjectDomain.MAXIMUM_BATCH_SIZE);
		}

		return batchSize;
	}
}