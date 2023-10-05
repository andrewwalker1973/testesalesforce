/**
 * @description Public class to return the record of Financial Account
 *
 * @author aakriti.a.goyal@accenture.com darrion.james.singh@accenture.com jason.van.beukering@accenture.com
 *
 * @date August 2021, April 2022
 */
public inherited sharing class SC_DAL_FinancialAccount
{
	private static final String FIELD_MASTER_ACCOUNT = FinServ__FinancialAccount__c.AW_MasterAccount__c.getDescribe().getLocalName();

	/**
	 * @description Financial Account Number field API name
	 */
	public static final String FIELD_FINANCIAL_ACCOUNT_NUMBER = FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c.getDescribe().getLocalName();

	/**
	 * @description Financial Account SObject API Name
	 */
	public static final String OBJECT_NAME = FinServ__FinancialAccount__c.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_FINANCIAL_ACCOUNT_NUMBER,
				FIELD_MASTER_ACCOUNT,
				FinServ__FinancialAccount__c.CMN_MasterAccountRecordTypeName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.FinServ__OpenDate__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.FinServ__Premium__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.FinServ__Status__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.Name.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Retrieves the financial accounts corresponding to the given contract numbers.
	 *
	 * @param accountNumbers a set of contract numbers
	 *
	 * @return a list of items
	 */
	public static List<FinServ__FinancialAccount__c> findByAccountNumber(Set<String> accountNumbers)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_FINANCIAL_ACCOUNT_NUMBER, accountNumbers, getDefaultFields());
	}

	/**
	 * @description Retrieves a financial account corresponding to the given account number
	 *
	 * @param accountNumber Number against which to search
	 *
	 * @return Null or found Item
	 */
	public static FinServ__FinancialAccount__c findByAccountNumber(String accountNumber)
	{
		return (FinServ__FinancialAccount__c)CMN_DAL_SObjectSelector.findByField
				(OBJECT_NAME, FIELD_FINANCIAL_ACCOUNT_NUMBER, accountNumber, getDefaultFields(), true);
	}

	/**
	 * @description Retrieves the financial accounts corresponding to the given AccountID.
	 *
	 * @param accountId The account to filter financial accounts against
	 *
	 * @return a list of items
	 */
	public static List<FinServ__FinancialAccount__c> findByMasterAccountId(Id accountId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_MASTER_ACCOUNT, new Set<Id> {accountId}, getDefaultFields());
	}

	/**
	 * @description Will return all FinancialAccounts created by unit tests
	 *
	 * @return A list of FinancialAccounts
	 */
	@TestVisible
	private static List<FinServ__FinancialAccount__c> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description Retrieves the Financial Account by Id.
	 *
	 * @param financialAccountIds a set of policy ids
	 *
	 * @return a list of items
	 */
	public static List<FinServ__FinancialAccount__c> findById(Set<Id> financialAccountIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, financialAccountIds, getDefaultFields());
	}

	/**
	 * @description Will find a financial account by Id
	 *
	 * @param financialAccountId The Id of the account
	 *
	 * @return Either the item found or null
	 */
	public static FinServ__FinancialAccount__c findById(Id financialAccountId)
	{
		return (FinServ__FinancialAccount__c)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, financialAccountId, getDefaultFields());
	}
}