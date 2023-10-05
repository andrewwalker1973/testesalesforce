/**
 * @description Public class to return the records of Insurance Policy Coverage
 *
 * @author jayanth.kumar.s@accenture.com rajpal.singh@accenture.com
 *
 * @date 2021, October 2022
 */
public inherited sharing class AW_DAL_InsurancePolicyCoverage
{
	private static final String FIELD_INSURANCE_POLICY_ID = InsurancePolicyCoverage.InsurancePolicyId.getDescribe().getLocalName();
	private static final String FIELD_INSURANCE_POLICY_PARTICIPANT = InsurancePolicyCoverage.AW_InsurancePolicyParticipant__c.getDescribe().getLocalName();
	@TestVisible
	private static final String FIELD_TYPE = InsurancePolicyCoverage.AW_Type__c.getDescribe().getLocalName();
	private static final String OBJECT_NAME = InsurancePolicyCoverage.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();

	/**
	 * @description Insurance Policy coverage type
	 */
	public static final String FINANCIAL_PROTECTOR = 'Financial Protector';
	/**
	 * @description The record type is being used when creating Insurance Policy Coverage records
	 */
	public static final String RT_LIBERTY_INSURANCE_POLICY_COVERAGE = 'CMN_LibertyInsurancePolicyCoverage';

	/**
	 * @description Liberty Insurance Policy Coverage record type id that should be used
	 */
	public static final Id RT_LIBERTY_INSURANCE_POLICY_COVERAGE_ID =
			CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName
					(
							InsurancePolicyCoverage.SObjectType,
							AW_DAL_InsurancePolicyCoverage.RT_LIBERTY_INSURANCE_POLICY_COVERAGE
					);

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_INSURANCE_POLICY_ID,
				FIELD_INSURANCE_POLICY_PARTICIPANT,
				FIELD_TYPE,
				InsurancePolicyCoverage.AW_BenefitAmount__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.AW_CoverCategory__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.AW_CoverSubCategory__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.AW_EndDate__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.AW_OriginalBenefitAmount__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.AW_StartDate__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.AW_StatusCode__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.AW_StatusReasonCode__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.AW_Term__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.AW_TypeCode__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.CMN_AutomaticContributionIncreasePerc__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.CMN_BenefitClassification__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.CMN_ContributionAmount__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.CMN_ExclusionIndicator__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.CMN_IncomeDisabilityClaimPercentage__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.CMN_LoadContributionAmount__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.CMN_LoadingIndicator__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.CMN_PortfolioName__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.CMN_TerminalIllnessValue__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.CMN_WaitingPeriod__c.getDescribe().getLocalName(),
				InsurancePolicyCoverage.CoverageName.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Method to retrieve Insurance Policy Coverage related to Insurance Policy
	 *
	 * @param policyId the Id of account linked to Related Insurance Policy
	 *
	 * @return A list of Insurance Policy Coverages
	 */
	public static List<InsurancePolicyCoverage> findByPolicyId(String policyId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_INSURANCE_POLICY_ID, new Set<Id> {policyId}, getDefaultFields());
	}

	/**
	 * @description Method to retrieve Insurance Policy Coverage related to Insurance Policy Participant
	 *
	 * @param policyParticipant the Id of participant linked to Related Insurance Policy Coverage
	 *
	 * @return A list of Insurance Policy Coverages
	 */
	public static List<InsurancePolicyCoverage> findByPolicyParticipant(String policyParticipant)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_INSURANCE_POLICY_PARTICIPANT, new Set<Id> {policyParticipant}, getDefaultFields());
	}
}