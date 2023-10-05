/**
 * @description Selector class to query Consultant Codes
 *
 * @author darrion.james.singh@accenture.com jayanth.kumar.s@accenture.com
 *
 * @date February 2022, December 2022
 */
public inherited sharing class SC_DAL_ConsultantCodes
{
	private static final String FIELD_AGREEMENT_STATUS = SC_ConsultantCodes__c.SC_AgreementStatus__c.getDescribe().getLocalName();
	private static final String FIELD_CONTACT_ID = SC_ConsultantCodes__c.SC_ContactId__c.getDescribe().getLocalName();
	private static final String OBJECT_NAME = SC_ConsultantCodes__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();

	/**
	 * @description Indicate whether an agreement is active or now
	 */
	public static final String ACTIVE_AGREEMENT_STATUS = 'Active';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_DAL_SObjectDomain.FIELD_NAME,
				FIELD_AGREEMENT_STATUS,
				FIELD_CONTACT_ID,
				SC_ConsultantCodes__c.RSC_AdviserEmail__c.getDescribe().getLocalName(),
				SC_ConsultantCodes__c.RSC_AdviserFirstName__c.getDescribe().getLocalName(),
				SC_ConsultantCodes__c.RSC_AdviserLastName__c.getDescribe().getLocalName()
		};
	}

	/**
	 * @description This method is use to get Consultants with the given set of Id
	 *
	 * @param consultantIds The Set of consultant Ids to retrieve
	 *
	 * @return List of found ConsultantCode Records
	 */
	@TestVisible
	private static List<SC_ConsultantCodes__c> findById(Set<Id> consultantIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, consultantIds, getDefaultFields());
	}

	/**
	 * @description Will look for consultant code records that are marked as Active but haven't been modified today
	 *
	 * @return List of Consultant Code records found
	 */
	public static List<SC_ConsultantCodes__c> findConsultantsNotModifiedToday()
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());

		searchParameters.searchConditions.equalsX(FIELD_AGREEMENT_STATUS, true);
		searchParameters.searchConditions.notEquals(CMN_DAL_SObjectDomain.FIELD_LAST_MODIFIED_DATE, new CMN_SOQL_Query.DateFormula().todayX());

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Will find a list of ConsultantCode records by consultant Codes
	 *
	 * @param consultantCodes The Set of consultant Codes  to retrieve
	 *
	 * @return List of SC_ConsultantCodes__c
	 */
	public static List<SC_ConsultantCodes__c> findByConsultantCode(Set<String> consultantCodes)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_NAME, consultantCodes, getDefaultFields());
	}

	/**
	 * @description Will return all ConsultantCode created by unit tests
	 *
	 * @return A list of ConsultantCodes
	 */
	@TestVisible
	private static List<SC_ConsultantCodes__c> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
}