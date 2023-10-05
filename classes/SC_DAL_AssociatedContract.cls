/**
 * @description Public class to return the records of Associated Contracts
 *
 * @author darrion.james.singh@accenture.com, jason.van.beukering@accenture.com
 *
 * @date 2021, January 2023
 */
public inherited sharing class SC_DAL_AssociatedContract
{
	private static final String FIELD_ASSOCIATED_CONTRACT_EXTENSION_FIELDSET = 'SC_Case__r.RSC_ServiceType__r.RSC_AssociatedContractExtensionFieldSet__c';

	private static final String FIELD_CASE_NUMBER = 'SC_Case__r.CaseNumber';
	private static final String FIELD_FINANCIAL_ACCOUNT_DATE = 'SC_FinancialAccount__r.FinServ__OpenDate__c';
	private static final String FIELD_FINANCIAL_ACCOUNT_NAME = 'SC_FinancialAccount__r.Name';
	private static final String FIELD_FINANCIAL_ACCOUNT_NUMBER = 'SC_FinancialAccount__r.FinServ__FinancialAccountNumber__c';
	private static final String FIELD_FINANCIAL_ACCOUNT_PAYMENT_METHOD = 'SC_FinancialAccount__r.CMN_PaymentMethod__c';
	private static final String FIELD_FINANCIAL_ACCOUNT_STATUS = 'SC_FinancialAccount__r.FinServ__Status__c';
	private static final String FIELD_FINANCIAL_ACCOUNT_TYPE = 'SC_FinancialAccount__r.FinServ__FinancialAccountType__c';
	private static final String FIELD_FINANCIAL_BANK_ACCOUNT_HOLDER = 'SC_FinancialAccount__r.CMN_BankAccountHolderName__c';
	private static final String FIELD_FINANCIAL_BANK_ACCOUNT_NAME = 'SC_FinancialAccount__r.CMN_BankName__c';
	private static final String FIELD_FINANCIAL_BANK_ACCOUNT_NUMBER = 'SC_FinancialAccount__r.CMN_BankAccountNumber__c';
	private static final String FIELD_FINANCIAL_BANK_ACCOUNT_TYPE = 'SC_FinancialAccount__r.CMN_BankAccountType__c';
	private static final String FIELD_FINANCIAL_DEBIT_DAY = 'SC_FinancialAccount__r.CMN_DebitDay__c';
	private static final String FIELD_INSURANCE_BANK_ACCOUNT_HOLDER = 'SC_InsurancePolicy__r.CMN_BankAccountHolderName__c';
	private static final String FIELD_INSURANCE_BANK_ACCOUNT_NAME = 'SC_InsurancePolicy__r.CMN_BankName__c';
	private static final String FIELD_INSURANCE_BANK_ACCOUNT_NUMBER = 'SC_InsurancePolicy__r.CMN_BankAccountNumber__c';
	private static final String FIELD_INSURANCE_BANK_ACCOUNT_TYPE = 'SC_InsurancePolicy__r.CMN_BankAccountType__c';
	private static final String FIELD_INSURANCE_DEBIT_DAY = 'SC_InsurancePolicy__r.CMN_DebitDay__c';
	private static final String FIELD_INSURANCE_POLICY_DATE = 'SC_InsurancePolicy__r.AW_CommencementDate__c';
	private static final String FIELD_INSURANCE_POLICY_NAME = 'SC_InsurancePolicy__r.Name';
	private static final String FIELD_INSURANCE_POLICY_PAYMENT_METHOD = 'SC_InsurancePolicy__r.AW_PaymentMethod__c';
	private static final String FIELD_INSURANCE_POLICY_POLICY_NAME = 'SC_InsurancePolicy__r.PolicyName';
	private static final String FIELD_INSURANCE_POLICY_STATUS = 'SC_InsurancePolicy__r.Status';
	private static final String FIELD_INSURANCE_POLICY_TYPE = 'SC_InsurancePolicy__r.PolicyType';
	private static final String FIELD_PARENT_RECORD_ACCOUNT_ID = 'SC_Case__r.AccountID';
	/**
	 * @description API of the object
	 */
	public static final String OBJECT_NAME = SC_AssociatedContract__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
	/**
	 * @description Field API name for SC_Case__c
	 */
	public static final String FIELD_CASE = SC_AssociatedContract__c.SC_Case__c.getDescribe().getLocalName();
	/**
	 * @description Field API Name for SC_FinancialAccount__c
	 */
	public static final String FIELD_FINANCIAL_ACCOUNT = SC_AssociatedContract__c.SC_FinancialAccount__c.getDescribe().getLocalName();

	/**
	 * @description Field API Name for SC_InsurancePolicy__c
	 */
	public static final String FIELD_INSURANCE_POLICY = SC_AssociatedContract__c.SC_InsurancePolicy__c.getDescribe().getLocalName();
	/**
	 * @description Field API Name for the SC_AssociatedContractExtension__r.SC_ContractNumber__c
	 */
	public static final String FIELD_ASSOCIATED_CONTRACT_EXTENSION_CONTRACT_NUMBER = 'SC_AssociatedContractExtension__r.SC_ContractNumber__c';
	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_ASSOCIATED_CONTRACT_EXTENSION_CONTRACT_NUMBER,
				FIELD_ASSOCIATED_CONTRACT_EXTENSION_FIELDSET,
				FIELD_CASE,
				FIELD_CASE_NUMBER,
				FIELD_FINANCIAL_ACCOUNT,
				FIELD_FINANCIAL_ACCOUNT_DATE,
				FIELD_FINANCIAL_ACCOUNT_NAME,
				FIELD_FINANCIAL_ACCOUNT_NUMBER,
				FIELD_FINANCIAL_ACCOUNT_PAYMENT_METHOD,
				FIELD_FINANCIAL_ACCOUNT_STATUS,
				FIELD_FINANCIAL_ACCOUNT_TYPE,
				FIELD_FINANCIAL_BANK_ACCOUNT_HOLDER,
				FIELD_FINANCIAL_BANK_ACCOUNT_NAME,
				FIELD_FINANCIAL_BANK_ACCOUNT_NUMBER,
				FIELD_FINANCIAL_BANK_ACCOUNT_TYPE,
				FIELD_FINANCIAL_DEBIT_DAY,
				FIELD_INSURANCE_BANK_ACCOUNT_HOLDER,
				FIELD_INSURANCE_BANK_ACCOUNT_NAME,
				FIELD_INSURANCE_BANK_ACCOUNT_NUMBER,
				FIELD_INSURANCE_BANK_ACCOUNT_TYPE,
				FIELD_INSURANCE_DEBIT_DAY,
				FIELD_INSURANCE_POLICY,
				FIELD_INSURANCE_POLICY_DATE,
				FIELD_INSURANCE_POLICY_NAME,
				FIELD_INSURANCE_POLICY_PAYMENT_METHOD,
				FIELD_INSURANCE_POLICY_POLICY_NAME,
				FIELD_INSURANCE_POLICY_STATUS,
				FIELD_INSURANCE_POLICY_TYPE,
				FIELD_PARENT_RECORD_ACCOUNT_ID,
				SC_AssociatedContract__c.Name.getDescribe().getLocalName(),
				SC_AssociatedContract__c.SC_AssociatedContractExtension__c.getDescribe().getLocalName(),
				SC_AssociatedContract__c.SC_CommencementDate__c.getDescribe().getLocalName(),
				SC_AssociatedContract__c.SC_PolicyNumber__c.getDescribe().getLocalName(),
				SC_AssociatedContract__c.SC_PolicyType__c.getDescribe().getLocalName(),
				SC_AssociatedContract__c.SC_Premium__c.getDescribe().getLocalName(),
				SC_AssociatedContract__c.SC_ProductType__c.getDescribe().getLocalName(),
				SC_AssociatedContract__c.Id.getDescribe().getLocalName(),
				SC_AssociatedContract__c.SC_Status__c.getDescribe().getLocalName()
		};
	}

	/**
	 * @description This method is use to get an Associated Contract record with the particular Id
	 *
	 * @param associatedContractIds Set of Associated Contract Ids to retrieve
	 *
	 * @return List of Associated Contracts
	 *
	 * @author vikrant.goswami@accenture.com
	 */
	public static List<SC_AssociatedContract__c> findById(Set<Id> associatedContractIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, associatedContractIds, getDefaultFields());
	}

	/**
	 * @description This method is use to get the List of Associated Contracts with the particular ParenRecordId
	 *
	 * @param parentRecordId The record to which this item is associated
	 *
	 * @return A list of Associated Contracts
	 */
	@AuraEnabled
	public static List<SC_AssociatedContract__c> findByParent(Id parentRecordId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_CASE, new Set<Id> {parentRecordId}, getDefaultFields());
	}

	/**
	 * @description This method is use to retrieve associated contract records
	 *
	 * @param caseIds A set of  case record Ids
	 *
	 * @return A list of Associated Contracts
	 */
	public static List<SC_AssociatedContract__c> findByCaseId(Set<Id> caseIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_CASE, caseIds, getDefaultFields());
	}
	/**
	 * @description Will return all Associated Contracts created by unit tests
	 *
	 * @return A list of associated contracts
	 */
	@TestVisible
	private static List<SC_AssociatedContract__c> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

}