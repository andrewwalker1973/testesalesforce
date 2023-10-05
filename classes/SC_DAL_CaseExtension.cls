/**
 * @description Public class to query Case Extension records
 *
 * @see SC_CaseExtension__c
 *
 * @author uttpal.chandra@accenture.com, vijay.jayswal@accenture.com
 *
 * @date December 2022, February 2023
 */
public inherited sharing class SC_DAL_CaseExtension
{
	/**
	 * @description Object API name of the Case Extension object
	 */
	public static final String OBJECT_NAME = SC_CaseExtension__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
	/**
	 * @description API name of the client identification number field
	 */
	public static final String FIELD_CASE_NUMBER = SC_CaseExtension__c.RSC_CaseNumber__c.getDescribe().getLocalName();
	/**
	 * @description API name of the client id  number field
	 */
	public static final String FIELD_CLIENT_IDENTIFICATION_NUMBER = SC_CaseExtension__c.RSC_ClientIdentificationNumber__c.getDescribe().getLocalName();

	/**
	 * @description API Name  for the  Medical Appointment record type
	 */
	public static final String RT_MEDICAL_APPOINTMENT = 'SC_MedicalAppointment';
	/**
	 * @description API Name  for the  Unpaid Debit Order Fieldset
	 */
	public static final String FIELDSET_UNPAID_DEBIT_ORDER = 'RSC_UnpaidDebitOrder';
	/**
	 * @description API Name  for the  Policy Owner details Fieldset
	 */
	public static final String FIELDSET_POLICY_OWNER_DETAILS = 'SC_PolicyOwnerDetails';
	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return CMN_UTIL_System.getAllFieldNames(OBJECT_NAME);
	}

	/**
	 * @description Method retrieves a list of case extension records by Id
	 *
	 * @param caseExtensionIds The Set of case extension Ids to retrieve
	 *
	 * @return List of Case Extension records
	 */
	public static List<SC_CaseExtension__c> findById(Set<Id> caseExtensionIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, caseExtensionIds, getDefaultFields());
	}

	/**
	 * @description Method to retrieve case extension records created by unit tests
	 *
	 * @return A list of case extension records
	 */
	@TestVisible
	private static List<SC_CaseExtension__c> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description this method is used to query case extension records by Case Number and client identification number
	 *
	 * @param caseNumbers The number against which to filter
	 * @param clientIdNumber The number against which to filter
	 *
	 * @return A list of Case Extension
	 */
	public static List<SC_CaseExtension__c> findByClientFields(Set<String> caseNumbers, String clientIdNumber)
	{

		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_CASE_NUMBER, caseNumbers, getDefaultFields());
		searchParameters.searchConditions.equalsX(FIELD_CLIENT_IDENTIFICATION_NUMBER, clientIdNumber);

		return CMN_DAL_Search.getObjects(searchParameters);
	}
	/**
	 * @description This method is used to generate a Map of Case Extension records mapped by Case Number
	 *
	 * @param caseNumbers The set of case numbers received extracted from the request
	 * @param clientIdNumber Id number against which to filter
	 *
	 * @return Map of the Case Number and client Identification number  to the Case Extension record
	 */
	public static CMN_UTIL_SObjectIndex generateCaseNumberToCaseExtensionMap(Set<String> caseNumbers, String clientIdNumber)
	{
		List<SC_CaseExtension__c> caseCaseExtensions = findByClientFields(caseNumbers, clientIdNumber);

		return new CMN_UTIL_SObjectIndex(FIELD_CASE_NUMBER).putAll(caseCaseExtensions);
	}
}