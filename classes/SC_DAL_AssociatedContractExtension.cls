/**
 * @description Public class to query Associated Contract Extension records
 *
 * @see SC_AssociatedContractExtension__c
 *
 * @author mthobisi.ndlovu@accenture.com vijay.jayswal@accenture.com
 *
 * @date December 2022
 */
public inherited sharing class SC_DAL_AssociatedContractExtension
{
	/**
	 * @description Object API name of the Case Extension object
	 */
	public static final String OBJECT_NAME = SC_AssociatedContractExtension__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
	/**
	 * @description API Name  for the  Unpaid Debit Order Fieldset
	 */
	public static final String FIELDSET_UNPAID_DEBIT_ORDER = 'RSC_UnpaidDebitOrder';
	/**
	 * @description Field API name of the Case Extension lookup field
	 */
	private static final String FIELD_CASE_EXTENSION = SC_AssociatedContractExtension__c.SC_CaseExtension__c.getDescribe().getLocalName();
	/**
	 * @description Field API name of the Contract Number
	 */
	public static final String FIELD_CONTRACT_NUMBER = SC_AssociatedContractExtension__c.SC_CaseExtension__c.getDescribe().getLocalName();

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
	 * @description Method to retrieve associated contract extension records created by unit tests
	 *
	 * @return A list of associated contract extension records
	 */
	@TestVisible
	private static List<SC_AssociatedContractExtension__c> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description this method is used to query associated contract extension by Case Extension Ids
	 *
	 * @param caseExtensionIds The number against which to filter
	 *
	 * @return A list of Associated Contract Extension records
	 */
	public static List<SC_AssociatedContractExtension__c> findByCaseExtension(Set<String> caseExtensionIds)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_CASE_EXTENSION, caseExtensionIds, getDefaultFields());
	}
}