/**
 * @description Data Access Layer SOQL related to the Communication Log object,
 * this is common class to be used across applications
 *
 * @author darrion.james.singh@accenture.com aakriti.a.goyal@accenture.com
 *
 * @date July 2022
 */
public inherited sharing class CMN_DAL_CommunicationLog
{
	private static final String FIELD_CASE_NUMBER = 'Case__r.CaseNumber';
	private static final String FIELD_COMMUNICATION_TEMPLATE = CMN_CommunicationLog__c.CMN_CommunicationTemplate__c.getDescribe().getLocalName();
	private static final String FIELD_COMMUNICATION_TEMPLATE_NAME = 'CMN_CommunicationTemplate__r.Name';
	private static final String FIELD_SEND_REMINDER = CMN_CommunicationLog__c.CMN_SendReminder__c.getDescribe().getLocalName();

	/**
	 * @description The API name for the lookup field to case
	 */
	public static final String FIELD_CASE = CMN_CommunicationLog__c.Case__c.getDescribe().getLocalName();

	/**
	 * @description stores the constant for Failure status
	 */
	public static final String STATUS_FAILURE = 'Failure';
	/**
	 * @description stores the constant for Success status
	 */
	public static final String STATUS_SUCCESS = 'Success';
	/**
	 * @description stores the Object API name of Communication Log
	 */
	public static final String OBJECT_NAME = CMN_CommunicationLog__c.SObjectType.getDescribe().getLocalName();

	/**
	 * @description The default fields to query from the CMN_CommunicationLog__c Object
	 *
	 * @return A list of CMN_CommunicationLog__c fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_CommunicationLog__c.CMN_OtherComments__c.getDescribe().getLocalName(),
				CMN_CommunicationLog__c.CMN_Recipients__c.getDescribe().getLocalName(),
				CMN_CommunicationLog__c.CMN_RequestedDocuments__c.getDescribe().getLocalName(),
				CMN_CommunicationLog__c.CMN_Status__c.getDescribe().getLocalName(),
				CMN_CommunicationLog__c.Name.getDescribe().getLocalName(),
				CMN_CommunicationLog__c.OwnerId.getDescribe().getLocalName(),
				FIELD_CASE,
				FIELD_CASE_NUMBER,
				FIELD_COMMUNICATION_TEMPLATE,
				FIELD_COMMUNICATION_TEMPLATE_NAME,
				FIELD_SEND_REMINDER
		};
	}

	/**
	 * @description Will return all CMN_DAL_CommunicationLog objects created by unit tests
	 *
	 * @return A list of CMN_DAL_CommunicationLog
	 */
	@TestVisible
	private static List<CMN_CommunicationLog__c> getAll()
	{
		return (List<CMN_CommunicationLog__c>)CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description Will return list of  Communication Logs related to Case
	 *
	 * @param caseIds set of caseIds associated to communication log
	 *
	 * @return list of found Communication logs
	 */
	public static List<CMN_CommunicationLog__c> findByCaseId(Set<Id> caseIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_CASE, caseIds, getDefaultFields());
	}

	/**
	 * @description Will return list of Communication Logs related to Cases & communication template where send reminder flag is set to true
	 *
	 * @param caseIds set of caseIds associated to communication log
	 * @param communicationTemplateId Id of the communication template
	 *
	 * @return list of found Communication logs
	 */
	public static List<CMN_CommunicationLog__c> findByCasesAndTemplate(Set<Id> caseIds, Id communicationTemplateId)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());

		searchParameters.searchConditions.inX(FIELD_CASE, CMN_UTIL_System.setToList(caseIds));
		searchParameters.searchConditions.equalsX(FIELD_COMMUNICATION_TEMPLATE, communicationTemplateId);
		searchParameters.searchConditions.equalsX(FIELD_SEND_REMINDER, true);

		return CMN_DAL_Search.getObjects(searchParameters);
	}
}