/**
 * @description Public class to return the records of Custom CaseComment
 *
 * @see CMN_CaseComment__c
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date July 2022
 */
public with sharing class CMN_DAL_CaseComments
{
	private static final String FIELD_CREATED_BY_UACFID = 'CreatedBy.AW_UACFID__c';
	private static final String FIELD_RELATED_CASE_NUMBER = 'CMN_Case__r.CaseNumber';
	private static final String OBJECT_NAME = CMN_CaseComment__c.SObjectType.getDescribe().getLocalName();
	/**
	 * @description Field used to store the api name of Case related to Case Comment.
	 */
	public static final String FIELD_CASE = CMN_CaseComment__c.CMN_Case__c.getDescribe().getLocalName();
	/**
	 * @description Field used to store the api name of External Comment ID
	 */
	public static final String FIELD_EXTERNAL_COMMENT_ID = CMN_CaseComment__c.CMN_ExternalCommentId__c.getDescribe().getLocalName();

	/**
	 * @description Field used to store the api name of ID
	 */
	public static final String FIELD_ID = CMN_CaseComment__c.Id.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_CaseComment__c.CMN_CommentCreateDate__c.getDescribe().getLocalName(),
				CMN_CaseComment__c.CMN_Comment__c.getDescribe().getLocalName(),
				CMN_CaseComment__c.CMN_CreatedUser__c.getDescribe().getLocalName(),
				CMN_CaseComment__c.CMN_IsExternalComment__c.getDescribe().getLocalName(),
				CMN_CaseComment__c.CMN_IsPrivate__c.getDescribe().getLocalName(),
				CMN_CaseComment__c.CreatedDate.getDescribe().getLocalName(),
				CMN_CaseComment__c.Name.getDescribe().getLocalName(),
				FIELD_CASE,
				FIELD_CREATED_BY_UACFID,
				FIELD_EXTERNAL_COMMENT_ID,
				FIELD_RELATED_CASE_NUMBER
		};
	}

	/**
	 * @description This method is use to get the List of Case Comments with the given case ids
	 *
	 * @param caseIds The cases for which to retrieve comments
	 *
	 * @return A list of found Case Comments
	 */
	public static List<CMN_CaseComment__c> findByCaseId(Set<Id> caseIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_CASE, caseIds, getDefaultFields());
	}

	/**
	 * @description This method is use to get the List of Case Comments with the given case id
	 *
	 * @param caseId The case for which to retrieve comments
	 *
	 * @return A list of found Case Comments
	 */
	public static List<CMN_CaseComment__c> findByCaseId(Id caseId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_CASE, new Set<Id> {caseId}, getDefaultFields());
	}

	/**
	 * @description Will find a list of Case Comments by the external comment Id's
	 *
	 * @param externalCommentIds The Set of Comments to be retrieved
	 *
	 * @return List of CMN_CaseComment__c
	 */
	public static List<CMN_CaseComment__c> findByExternalCommentId(Set<String> externalCommentIds)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_EXTERNAL_COMMENT_ID, externalCommentIds, getDefaultFields());
	}

	/**
	 * @description This method is use to get a Case Comment with the particular Id
	 *
	 * @param recordId The record of the Case Comment
	 *
	 * @return A single Case Comment
	 */
	public static CMN_CaseComment__c findById(Id recordId)
	{
		return (CMN_CaseComment__c)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, recordId, getDefaultFields());
	}

	/**
	 * @description Will return all Case Comments created by unit tests
	 *
	 * @return A list of Case Comments
	 */
	@TestVisible
	private static List<CMN_CaseComment__c> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
}