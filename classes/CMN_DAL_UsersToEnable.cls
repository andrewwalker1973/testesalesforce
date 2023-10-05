/**
 * @description Public class to as part of post copy script for users to make admins in sandboxes
 *
 * @author Accenture
 *
 * @date 2020
 */
public inherited sharing class CMN_DAL_UsersToEnable
{
	/**
	 * @description This method is use to get the list of all profiles and users in CMN_SPC_UsersToEnable__c
	 *
	 * @return List
	 */
	public static List<CMN_SPC_UsersToEnable__c> getAll()
	{
		return CMN_DAL_Search.getAll(CMN_SPC_UsersToEnable__c.SObjectType);
	}
}