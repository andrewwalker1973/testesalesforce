/**
 * @description Public class to return the record of Insurance Policy
 *
 * @author jayanth.kumar.s@accenture.com, pavan.t@lntinfotech.com
 *
 * @date 2019, May 2023
 */
public inherited sharing class AW_DAL_InsurancePolicy
{
	/**
	 * @description Field representing current value of a policy
	 */
	public static final String FIELD_CURRENT_VALUE = InsurancePolicy.AW_CurrentValue__c.getDescribe().getLocalName();
	/**
	 * @description Field representing the financial goal of a policy
	 */
	public static final String FIELD_FINANCIAL_GOAL = InsurancePolicy.AW_FinancialGoal__c.getDescribe().getLocalName();
	/**
	 * @description Field representing the name of policy
	 */
	public static final String FIELD_NAME = CMN_DAL_SObjectDomain.FIELD_NAME;
	/**
	 * @description Object Name for Insurance Policy
	 */
	public static final String OBJECT_NAME = InsurancePolicy.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
	/**
	 * @description Record type name for Insurance Policy
	 */
	public static final String RT_INSURANCE_POLICY = 'AW_InsurancePolicy';
	/**
	 * @description Constant string representing In Force status
	 */
	public static final String STATUS_IN_FORCE = 'IN FORCE';
	/**
	 * @description Constant string representing list of active status
	 */
	private static final List<String> ACTIVE_STATUSES = new List<String>
	{
			STATUS_IN_FORCE
	};
	/**
	 * @description Field representing Name Insured Id of the policy
	 */
	private static final String FIELD_NAME_INSURED_ID = InsurancePolicy.NameInsuredId.getDescribe().getLocalName();
	/**
	 * @description Field representing Product Code of the policy
	 */
	private static final String FIELD_PRODUCT_TYPE_CODE = InsurancePolicy.AW_ProductTypeCode__c.getDescribe().getLocalName();
	/**
	 * @description The Product code of a Insurance Policy
	 */
	@TestVisible
	private static final String PICK_PRODUCT_CODE_14 = '14';
	/**
	 * @description Field representing the Status of the policy
	 */
	private static final String FIELD_STATUS = InsurancePolicy.Status.getDescribe().getLocalName();
	private static final String FIELD_OWNER_CONSULTANT_CODE = 'NameInsured.Owner.AW_ConsultantCode__c';
	private static final String RT_INSURANCE_POLICY_PARTICIPANTS = 'InsurancePolicyParticipants';
	private static final String RT_INSURANCE_POLICY_COVERAGES = 'InsurancePolicyCoverages';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_CURRENT_VALUE,
				FIELD_FINANCIAL_GOAL,
				FIELD_OWNER_CONSULTANT_CODE,
				InsurancePolicy.AW_AUMSourceExternalId__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_AnnualBenefitsIncreaseABI__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_AnnualContributionIncreaseACI__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_CommencementDate__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_CurrentValue__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_DeathIncome__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_Frequency__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_InsurancePolicyName__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_InvestmentValue__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_MasterAccount__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_MaturityDate__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_PaidUpValue__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_PaymentMethodCode__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_PaymentMethod__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_PolicyCategory__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_PremiumFrequencyCode__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_PremiumPatternCode__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_PremiumPattern__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_ProductTypeCode__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_StatusReasonCode__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_StatusReason__c.getDescribe().getLocalName(),
				InsurancePolicy.AW_ValueAsAt__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_AdvanceAvailable__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_AdvanceType__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_AidsInclusionIndicator__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_BankAccountHolderName__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_BankAccountNumber__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_BankAccountType__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_BankBranchCode__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_BankName__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_CashBackDate__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_CashBackEarned__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_CashBackIndicator__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_CessionaryInitials__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_CessionaryName__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_CessionaryTitle__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_CessionaryType__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_ConditionalPartRedemptionTaken__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_CoverType__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_DebitDay__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_EarlyRetirementValue__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_EmployeeNumber__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_ExpiryDate__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_FacilityGroup__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_FacilityName__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_FacilityNumber__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_FacilityType__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_FundValue__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_GuaranteeReviewDate__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_GuaranteeValue__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_IllustrativeReturnPercentage__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_IllustrativeValueAge__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_IllustrativeValueDate__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_IllustrativeValueRate__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_IllustrativeValue__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_IssueDate__c.getDescribe().getLocalName(),
          InsurancePolicy.CMN_MasterAccountRecordTypeName__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_NextBillingDate__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_OptionDate__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_OriginalCommencementDate__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_PackageNumber__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_PaidUpBenefitIndicator__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_PaidUpDeathValue__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_PaidUpPremiumAmount__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_PaidtoDate__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_PayPointNumber__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_PremiumReceivedIndicator__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_ProductName__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_PrototypeCode__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_QualifyingAddlibIndicator__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_RefundAvailableAmount__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_RepayableAmount__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_RestrictionEndDate__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_SystematicRedemptionPaymentIndicator__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_TermIllustrativeValue__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_TotalInvestmentAmount__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_TotalPackageDeathValue__c.getDescribe().getLocalName(),
				InsurancePolicy.CMN_TotalRepayableAmount__c.getDescribe().getLocalName(),
				InsurancePolicy.CashSurrenderValue.getDescribe().getLocalName(),
				InsurancePolicy.EffectiveDate.getDescribe().getLocalName(),
				InsurancePolicy.Name.getDescribe().getLocalName(),
				InsurancePolicy.NameInsuredId.getDescribe().getLocalName(),
				InsurancePolicy.OwnerId.getDescribe().getLocalName(),
				InsurancePolicy.PaidToDate.getDescribe().getLocalName(),
				InsurancePolicy.PolicyName.getDescribe().getLocalName(),
				InsurancePolicy.PremiumAmount.getDescribe().getLocalName(),
				InsurancePolicy.PremiumFrequency.getDescribe().getLocalName(),
				InsurancePolicy.RecordTypeId.getDescribe().getLocalName(),
				InsurancePolicy.Status.getDescribe().getLocalName()
		};
	}

	/**
	 * @description This method is use to return total value of each goal
	 *
	 * @param goalIds A list of Goal Ids
	 *
	 * @return List<InsurancePolicy>
	 */
	public static List<AggregateResult> totalCurrentValuePerGoal(Set<Id> goalIds)
	{
		return
		[
				SELECT
						AW_FinancialGoal__c,
						SUM(AW_CurrentValue__c) AW_CurrentValue__c
				FROM
						InsurancePolicy
				WHERE AW_FinancialGoal__c != NULL
				AND AW_FinancialGoal__c IN :goalIds
				GROUP BY AW_FinancialGoal__c
		];
	}

    /**
   * @description This method is use to return the InsurancePolicy by Id
   *
   * @param policyId Id to store to InsurancePolicy Id
   *
   * @return InsurancePolicy
   */
  public static InsurancePolicy findByInsurancePolicyId(Id policyId)
  {
    return (InsurancePolicy)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, policyId, getDefaultFields());
  }

	/**
	 * @description This method is use to return the InsurancePolicy by Id
	 *
	 * @param policyId Id to store to InsurancePolicy Id
	 *
	 * @return InsurancePolicy
	 */
	public static InsurancePolicy findById(Id policyId)
	{
		return (InsurancePolicy)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, policyId, getDefaultFields());
	}

	/**
	 * @description Will return all Insurance Policies created by unit tests
	 *
	 * @return A list of items
	 */
	@TestVisible
	private static List<InsurancePolicy> getAll()
	{
		return CMN_DAL_Search.getAll(InsurancePolicy.SObjectType, getDefaultFields());
	}

	/**
	 * @description This method is to be used to retrieve all Insurance Policy and their child records like Insurance Policy
	 * 				coverage and Insurance Policy Participants by passing account Id set
	 *
	 * @param accountId A set of account Id
	 *
	 * @return a List of items
	 */
	public static List<InsurancePolicy> findChildrenByAccountId(Set<Id> accountId)
	{
		CMN_SOQL_Builder participantSubQuery =
				new CMN_SOQL_Builder()
						.selectX(AW_DAL_InsurancePolicyParticipant.getDefaultFields())
						.fromX(RT_INSURANCE_POLICY_PARTICIPANTS);

		CMN_SOQL_Builder coveragesSubQuery =
				new CMN_SOQL_Builder()
						.selectX(AW_DAL_InsurancePolicyCoverage.getDefaultFields())
						.fromX(RT_INSURANCE_POLICY_COVERAGES);

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(getDefaultFields())
						.selectX(participantSubQuery)
						.selectX(coveragesSubQuery)
						.fromX(OBJECT_NAME)
						.whereX(CMN_SOQL_Query.inX(FIELD_NAME_INSURED_ID, CMN_UTIL_System.setToList(accountId)));

		return Database.query(builder.toSoql());

	}

	/**
	 * @description Will return all Insurance Policies
	 *
	 * @param accountId The account against which to filter insurance policies
	 *
	 * @return A list of Insurance policies
	 */
	public static List<InsurancePolicy> findInForceByAccountId(String accountId)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_NAME_INSURED_ID, new Set<String> {String.valueOf(accountId)}, getDefaultFields());

		searchParameters.searchConditions.inX(FIELD_STATUS, ACTIVE_STATUSES);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method is use to return the InsurancePolicy by Id
	 *
	 * @param recordId Id of the Insurance Policy
	 *
	 * @return InsurancePolicy
	 */
	public static InsurancePolicy findByIdWithChildDetails(Id recordId)
	{
		CMN_SOQL_Builder insurancePolicyParticipants =
				new CMN_SOQL_Builder()
						.selectX(AW_DAL_InsurancePolicyParticipant.getDefaultFields())
						.fromX(RT_INSURANCE_POLICY_PARTICIPANTS);

		CMN_SOQL_Builder insurancePolicyCoverage =
				new CMN_SOQL_Builder()
						.selectX(AW_DAL_InsurancePolicyCoverage.getDefaultFields())
						.fromX(RT_INSURANCE_POLICY_COVERAGES);

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();
		andCondition.add(new CMN_SOQL_Query.FieldCondition(InsurancePolicy.Id.getDescribe().getLocalName(), CMN_SOQL_Query.Operator.EQUALS, recordId));

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(getDefaultFields())
						.selectX(insurancePolicyParticipants)
						.selectX(insurancePolicyCoverage)
						.fromX(OBJECT_NAME)
						.whereX(andCondition);

		return Database.query(builder.toSoql());
	}

	/**
	 * @description This method is use to return the InsurancePolicy by a Product Code
	 *
	 * @param accountId The account against which to filter insurance policies
	 * @param productCodes List of codes against which to filter policies
	 *
	 * @return A list of items found
	 */
	public static List<InsurancePolicy> findByProductCodeAndAccountId(Id accountId, Set<String> productCodes)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());
		searchParameters.searchConditions.equalsX(FIELD_NAME_INSURED_ID, accountId);
		searchParameters.searchConditions.inX(FIELD_PRODUCT_TYPE_CODE, CMN_UTIL_System.setToList(productCodes));

		return CMN_DAL_Search.getObjects(searchParameters);
	}
}