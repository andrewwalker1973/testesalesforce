/**
 * @description Class to query the records of Login Frequency
 *
 * @see CMN_LoginFrequency__c
 *
 * @author latika.kharbanda@accenture.com
 *
 * @date November 2022
 */
public inherited sharing class CMN_DAL_LoginFrequency
{
	private static final String OBJECT_NAME = CMN_LoginFrequency__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName();
	/**
	 * @description Stores the fieldAPIName of User Id With Login Year and Month
	 */
	public static final String FIELD_USERID_WITH_LOGIN_YEAR_AND_MONTH = CMN_LoginFrequency__c.CMN_UserIdWithLoginYearAndMonth__c.getDescribe().getName();

	/**
	 * @description The commonly required field when querying Login frequency records
	 *
	 * @return A unique set of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_LoginFrequency__c.CMN_TotalLoginCount__c.getDescribe().getName(),
				CMN_LoginFrequency__c.CMN_UniqueLoginCount__c.getDescribe().getName(),
				CMN_LoginFrequency__c.CMN_User__c.getDescribe().getName(),
				FIELD_USERID_WITH_LOGIN_YEAR_AND_MONTH
		};
	}

	/**
	 * @description Will return list of login frequency records related to the user
	 *
	 * @param concatenatedUserIdAndLoginMonth will take the concatenated user id and Login month of the user
	 *
	 * @return A list of found items
	 */
	public static List<CMN_LoginFrequency__c> findByUserIdAndLoginMonth(Set<String> concatenatedUserIdAndLoginMonth)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_USERID_WITH_LOGIN_YEAR_AND_MONTH, concatenatedUserIdAndLoginMonth, getDefaultFields());
	}

	/**
	 * @description Will return all login frequencies created by unit tests
	 *
	 * @return A list of Login Frequencies
	 */
	@TestVisible
	private static List<CMN_LoginFrequency__c> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
}