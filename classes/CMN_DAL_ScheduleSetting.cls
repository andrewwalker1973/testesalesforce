/**
 * @description Public class to return the record of Schedule Setting
 *
 * @see CMN_ScheduleSetting__c
 *
 * @author latika.kharbanda@accenture.com
 *
 * @date October 2022
 */
public inherited sharing class CMN_DAL_ScheduleSetting
{
	/**
	 * @description This method is to get the record of Schedule setting
	 *
	 * @param scheduleName Schedule name
	 *
	 * @return Found item
	 */
	public static CMN_ScheduleSetting__c getScheduleSetting(String scheduleName)
	{
		return CMN_ScheduleSetting__c.getValues(scheduleName);
	}
}