/**
 * @description Provides Query methods related to the AppLog object
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date 2020, July 2022
 */
public inherited sharing class CMN_DAL_AppLog
{
	private static final String FIELD_CLASS_METHOD = CMN_AppLog__c.CMN_ClassMethod__c.getDescribe().getLocalName();
	private static final String FIELD_LOG_LEVEL = CMN_AppLog__c.CMN_LogLevel__c.getDescribe().getLocalName();
	private static final String OBJECT_NAME = CMN_AppLog__c.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of AppLog fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_AppLog__c.CMN_ExceptionType__c.getDescribe().getLocalName(),
				CMN_AppLog__c.CMN_Limits__c.getDescribe().getLocalName(),
				CMN_AppLog__c.CMN_LineNumber__c.getDescribe().getLocalName(),
				CMN_AppLog__c.CMN_Message__c.getDescribe().getLocalName(),
				CMN_AppLog__c.CMN_RecordId__c.getDescribe().getLocalName(),
				CMN_AppLog__c.CMN_RecordLink__c.getDescribe().getLocalName(),
				CMN_AppLog__c.CMN_ShortMessage__c.getDescribe().getLocalName(),
				CMN_AppLog__c.CMN_StackTrace__c.getDescribe().getLocalName(),
				CMN_AppLog__c.CMN_UserId__c.getDescribe().getLocalName(),
				CMN_AppLog__c.CMN_UserLink__c.getDescribe().getLocalName(),
				CMN_AppLog__c.Name.getDescribe().getLocalName(),
				FIELD_CLASS_METHOD,
				FIELD_LOG_LEVEL
		};
	}

	/**
	 * @description Will find a Single AppLog object based on method
	 *
	 * @param classMethod The class method to use in the query
	 *
	 * @return Either null or a single AppLog Object
	 */
	@TestVisible
	private static CMN_AppLog__c findByMethod(String classMethod)
	{
		List<CMN_AppLog__c> logs = findAllByMethod(classMethod);
		return logs.isEmpty() ? null : logs.iterator().next();
	}

	/**
	 * @description Will find all AppLog objects based on method
	 *
	 * @param classMethod The class method to use in the query
	 *
	 * @return Either null or a single AppLog Object
	 */
	@TestVisible
	private static List<CMN_AppLog__c> findAllByMethod(String classMethod)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_CLASS_METHOD, new Set<String> {CMN_UTIL_String.trim(classMethod)}, getDefaultFields());
	}

	/**
	 * @description Will return all the AppLog objects in the system
	 *
	 * @return A list of AppLog objects
	 */
	@TestVisible
	private static List<CMN_AppLog__c> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description Will find all AppLog objects based on logging level
	 *
	 * @param logLevel The level to filter on
	 *
	 * @return A list of AppLog objects
	 */
	@TestVisible
	private static List<CMN_AppLog__c> findByLogLevel(String logLevel)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_LOG_LEVEL, new Set<String> {logLevel}, getDefaultFields());
	}

	/**
	 * @description Retrieve the count of app logs
	 *
	 * @return Integer - The number of records
	 */
	@TestVisible
	private static Integer getRecordCount()
	{
		return CMN_DAL_Search.getObjectCount(new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME));
	}
}