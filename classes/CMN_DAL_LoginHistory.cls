/**
 * @description Class to query the records of Login History
 *
 * @see LoginHistory
 *
 * @author latika.kharbanda@accenture.com jason.van.beukering@accenture.com
 *
 * @date December 2022
 */
public inherited sharing class CMN_DAL_LoginHistory
{
	private static final Integer LIMIT_FOR_TEST_CLASS = 5;
	private static final String FIELD_LOGIN_TIME = LoginHistory.LoginTime.getDescribe().getName();
	private static final String FIELD_USER_ID = LoginHistory.UserId.getDescribe().getName();
	private static final String OBJECT_NAME = LoginHistory.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName();

	/**
	 * @description The commonly required field when querying Login History records
	 *
	 * @return A unique set of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_LOGIN_TIME,
				FIELD_USER_ID
		};
	}

	/**
	 * @description This method is used to get the Login History records
	 *
	 * @param fromLoginTime Login time on which to filter records (will find any records greater or equal to this date and time)
	 * @param addLimitClause Will limit the number of records returned if true
	 *
	 * @return List of Login History records
	 */
	public static Database.QueryLocator findByLoginTime(Datetime fromLoginTime, Boolean addLimitClause)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());

		searchParameters.searchConditions.greaterThanOrEqualTo(FIELD_LOGIN_TIME, fromLoginTime == null ? CMN_UTIL_Date.getEpochDateTime() : fromLoginTime);

		Datetime today = System.today();
		Datetime toLoginTime = Datetime.newInstance(today.year(), today.month(), today.day());

		searchParameters.searchConditions.lessThan(FIELD_LOGIN_TIME, toLoginTime);
		searchParameters.addOrderByField(FIELD_USER_ID);
		searchParameters.addOrderByField(FIELD_LOGIN_TIME);

		searchParameters.pageSize = addLimitClause ? LIMIT_FOR_TEST_CLASS : searchParameters.pageSize;

		return Database.getQueryLocator(CMN_DAL_Search.soqlQuery(searchParameters).queryString);
	}
}