/**
 * @description Public class to return the records of Task
 *
 * @author uttpal.chandra@accenture.com
 *
 * @date 2019, July 2022
 */
public inherited sharing class AW_DAL_Task
{
	private static final String FIELD_RECORD_TYPE_NAME = 'RecordType.DeveloperName';
	private static final String FIELD_STATUS = Task.Status.getDescribe().getLocalName();
	private static final String FIELD_WHAT_ID = Task.WhatId.getDescribe().getLocalName();

	@TestVisible
	private static final String FIELD_SUBJECT = Task.Subject.getDescribe().getLocalName();
	@TestVisible
	private static final String OBJECT_NAME = Task.SObjectType.getDescribe().getLocalName();
	@TestVisible
	private static final String RT_ADVISER_TASK = 'AW_AdviserTask';
	@TestVisible
	private static final String RT_ORPHAN_TASK = 'AW_OrphanTask';

	public static final String CHANGE_OF_CONSULTANT_FORM_STATUS_COMPLETED = 'Not Submitted - Reallocate';

	public static final String PRIORITY_NORMAL = 'Normal';
	/**
	 * @description stores the constant Completed
	 */
	public static final String STATUS_COMPLETED = 'Completed';
	public static final String STATUS_IN_PROGRESS = 'In Progress';
	public static final String SUBJECT_MEETING = 'Meeting';
	/**
	 * @description stores the constant Call
	 */
	public static final String PICK_CALL = 'Call';
	/**
	 * @description stores the DeveloperName of Outbound Task
	 */
	public static final String RT_OUTBOUND_TASK = 'RSC_OutboundTask';

	/**
	 * @description Will return the common fields used by all queries
	 *
	 * @return List of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIElD_RECORD_TYPE_NAME,
				FIElD_SUBJECT,
				FIElD_WHAT_ID,
				Task.Id.getDescribe().getLocalName(),
				Task.RecordTypeId.getDescribe().getLocalName(),
				Task.Status.getDescribe().getLocalName(),
				Task.Subject.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will find the orphaned tasks that are incomplete
	 *
	 * @param whatIds The relevant what ids
	 *
	 * @return List of items
	 */
	public static List<Task> findOpenOrphanedTasks(Set<Id> whatIds)
	{
		Set<String> whatIdStrings = new Set<String>();

		for(Id whatId : whatIds)
		{
			whatIdStrings.add(String.valueOf(whatId));
		}

		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIElD_WHAT_ID, whatIdStrings, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIElD_RECORD_TYPE_NAME, CMN_SOQL_Query.Operator.EQUALS, AW_DAL_Task.RT_ORPHAN_TASK));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIElD_SUBJECT, CMN_SOQL_Query.Operator.EQUALS, Label.AW_Change_of_Consultant_Form));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIElD_STATUS, CMN_SOQL_Query.Operator.NOT_EQUALS, AW_DAL_Task.STATUS_COMPLETED));

		searchParameters.addSearchCondition(andCondition);

		return CMN_DAL_Search.getObjects(searchParameters);

	}

	/**
	 * @description Will find an Task by accountId and RecordTypeName
	 *
	 * @param whatId The whatId of the task
	 * @param recordTypeName The recordType name of Task
	 *
	 * @return Null or Item
	 */
	public static Task findByWhatIdAndRecordType(Id whatId, String recordTypeName)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIElD_WHAT_ID, new Set<String> {whatId}, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIElD_RECORD_TYPE_NAME, CMN_SOQL_Query.Operator.EQUALS, recordTypeName));

		searchParameters.addSearchCondition(andCondition);

		List<Task> foundItems = CMN_DAL_Search.getObjects(searchParameters);

		return foundItems.isEmpty() ? null : foundItems.iterator().next();

	}
	
	/**
	 * @description Will return all Task created by unit tests
	 *
	 * @return A list of Task
	 */
	@TestVisible
	private static List<Task> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
}