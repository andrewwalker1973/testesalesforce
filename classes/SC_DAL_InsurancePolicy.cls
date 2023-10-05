/**
 * @description Public class to return the record of Insurance Policy
 *
 * @author jason.van.beukering@accenture.com jayanth.kumar.s@accenture.com
 *
 * @date August 2021, December 2022
 */
public inherited sharing class SC_DAL_InsurancePolicy
{
	private static final String FIELD_MASTER_ACCOUNT = InsurancePolicy.AW_MasterAccount__c.getDescribe().getLocalName();
	/**
	 * @description Used to store the Object APIName of InsurancePolicy
	 */
	public static final String OBJECT_NAME = InsurancePolicy.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
	/**
	 * @description Used to store the constant of the status In Force
	 */
	public static final String STATUS_IN_FORCE = AW_DAL_InsurancePolicy.STATUS_IN_FORCE;
	/**
	 * @description Used to store the constant of the type Home
	 */
	public static final String TYPE_HOME = 'Home';
	/**
	 * @description Insurance Policy record type id that should be used
	 */
	public static final Id RT_INSURANCE_POLICY_ID =
			CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(InsurancePolicy.SObjectType, AW_DAL_InsurancePolicy.RT_INSURANCE_POLICY);
	/**
   	 * @description Used to store the APIName of InsurancePolicy recordtype
   	 */
  	public static final String RT_INSURANCE_POLICY = AW_DAL_InsurancePolicy.RT_INSURANCE_POLICY;

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_MASTER_ACCOUNT,
				InsurancePolicy.AW_CommencementDate__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_PaymentMethod__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_BankAccountHolderName__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_BankAccountNumber__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_BankAccountType__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_BankBranchCode__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_BankName__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_CessionaryName__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_CessionaryType__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_DebitDay__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_MasterAccountRecordTypeName__c.getDescribe().getLocalName(),
				InsurancePolicy.CreatedDate.getDescribe().getLocalName(),
				InsurancePolicy.Name.getDescribe().getLocalName(),
				InsurancePolicy.NameInsuredId.getDescribe().getLocalName(),
				InsurancePolicy.PolicyName.getDescribe().getLocalName(),
				InsurancePolicy.PolicyType.getDescribe().getLocalName(),
				InsurancePolicy.PremiumAmount.getDescribe().getLocalName(),
				InsurancePolicy.Status.getDescribe().getLocalName()

		};
	}

	/**
	 * @description Retrieves the Insurance Policies by Id.
	 *
	 * @param policyIds a set of policy ids
	 *
	 * @return a list of items
	 */
	public static List<InsurancePolicy> findById(Set<Id> policyIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, policyIds, getDefaultFields());
	}

	/**
	 * @description Will find an insurance policy by Id
	 *
	 * @param policyId The Id of the account
	 *
	 * @return Either the item found or null
	 */
	public static InsurancePolicy findById(Id policyId)
	{
		return (InsurancePolicy)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, policyId, getDefaultFields());
	}

	/**
	 * @description Retrieves the Insurance Policies corresponding to the given policy numbers.
	 *
	 * @param policyNumbers a set of policy numbers
	 *
	 * @return a list of items
	 */
	public static List<InsurancePolicy> findByName(Set<String> policyNumbers)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_NAME, policyNumbers, getDefaultFields());
	}

	/**
	 * @description Retrieves the Insurance Policies corresponding to the given policy name
	 *
	 * @param policyNumber The policy number against which to query
	 *
	 * @return Null or found item
	 */
	public static InsurancePolicy findByName(String policyNumber)
	{
		return (InsurancePolicy)CMN_DAL_SObjectSelector.findByName(OBJECT_NAME, policyNumber, getDefaultFields());
	}

	/**
	 * @description Retrieves the Insurance Policies corresponding to the given AccountId.
	 *
	 * @param accountId The account Id against which to filter insurance policies
	 *
	 * @return a list of items
	 */
	public static List<InsurancePolicy> findByMasterAccountId(Id accountId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_MASTER_ACCOUNT, new Set<Id> {accountId}, getDefaultFields());
	}

	/**
	 * @description Will return all Policies created by unit tests
	 *
	 * @return A list of InsurancePolicy
	 */
	@TestVisible
	private static List<InsurancePolicy> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
}