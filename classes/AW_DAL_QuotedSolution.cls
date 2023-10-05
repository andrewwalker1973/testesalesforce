/**
 * @description Public class to return the records of AW_Quoted_Solution__c
 *
 * @author Paweł Czermiński, jason.van.beukering@accenture.com
 *
 * @date 2020, February 2022
 */
public inherited sharing class AW_DAL_QuotedSolution
{
	private static final String FIELD_CONTRACT_NUMBER = AW_Quoted_Solution__c.AW_Contract_Number__c.getDescribe().getLocalName();
	private static final String FIELD_EXTERNAL_ID = AW_Quoted_Solution__c.AW_TF_External_Id__c.getDescribe().getLocalName();
	private static final String FIELD_QUOTE_NAME = AW_Quoted_Solution__c.AW_Quote_Name__c.getDescribe().getLocalName();
	private static final String OBJECT_NAME = AW_Quoted_Solution__c.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				AW_Quoted_Solution__c.AW_Contract_Status__c.getDescribe().getLocalName(),
				CMN_DAL_SObjectDomain.FIELD_NAME,
				FIELD_CONTRACT_NUMBER,
				FIELD_EXTERNAL_ID,
				FIELD_QUOTE_NAME
		};
	}

	/**
	 * @description Retrieves the quotes solutions corresponding to the given external ids.
	 *
	 * @param externalIds a list of external ids
	 *
	 * @return a list of items
	 */
	public static List<AW_Quoted_Solution__c> findByTfExternalId(Set<String> externalIds)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_EXTERNAL_ID, externalIds, getDefaultFields());
	}

	/**
	 * @description Retrieves the quote solutions corresponding to the given contract numbers.
	 *
	 * @param contractNumbers a  list of numbers
	 *
	 * @return a list of items
	 */
	public static List<AW_Quoted_Solution__c> findByContractNumber(Set<String> contractNumbers)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_CONTRACT_NUMBER, contractNumbers, getDefaultFields());
	}

	/**
	 * @description Will find a quote solutions based on name
	 *
	 * @param name The name against which to query
	 *
	 * @return A list of items
	 */
	public static List<AW_Quoted_Solution__c> findByQuoteName(String name)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_QUOTE_NAME, new Set<String> {name}, getDefaultFields());
	}
}