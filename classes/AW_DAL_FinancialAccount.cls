/**
 * @description Public class to return the record of Financial Account
 *
 * @author jayanth.kumar.s@accenture.com,  pavan.t@lntinfotech.com
 *
 * @date August 2022, May 2023
 */
public inherited sharing class AW_DAL_FinancialAccount
{
	private static final String FIELD_EXTERNAL_ID = FinServ__FinancialAccount__c.AW_AUMSourceExternalId__c.getDescribe().getLocalName();
	private static final String FIELD_FINANCIAL_GOAL_ID = FinServ__FinancialAccount__c.AW_FinancialGoal__c.getDescribe().getLocalName();
	private static final String FIELD_OWNER_CONSULTANT_CODE = 'FinServ__PrimaryOwner__r.Owner.AW_ConsultantCode__c';
	private static final String FIELD_PRIMARY_OWNER = FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c.getDescribe().getLocalName();
	private static final String FIELD_PRIMARY_OWNER_ID = 'FinServ__PrimaryOwner__r.Id';
	private static final String FIELD_PRODUCT_CATEGORY = FinServ__FinancialAccount__c.AW_ProductCategory__c.getDescribe().getLocalName();
	private static final String FIELD_STATUS = FinServ__FinancialAccount__c.FinServ__Status__c.getDescribe().getLocalName();
	private static final String RT_FINANCIAL_ACCOUNT_ROLES = 'FinServ__FinancialAccountRoles__r';
	private static final String RT_FINANCIAL_HOLDINGS = 'FinServ__FinancialHoldings__r';
	/**
	 * @description Constant string representing IN FORCE status
	 */
	public static final String STATUS_IN_FORCE = 'IN FORCE';

	/**
	 * @description Constant string representing list of active  status
	 */
	private static final List<String> ACTIVE_STATUSES = new List<String>
	{
			STATUS_IN_FORCE
	};
	/**
	 * @description Field to refer to financial account number of a financial account.
	 */
	public static final String FIELD_FINANCIAL_ACCOUNT_NUMBER = FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c.getDescribe().getLocalName();
	/**
	 * @description Field to refer to Financial Account object name.
	 */
	public static final String OBJECT_NAME = FinServ__FinancialAccount__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
	/**
	 * @description Field to store record type developer name  of Investment Account record type.
	 */
	public static final String RT_INVESTMENT_ACCOUNT = 'InvestmentAccount';
	/**
	 * @description Field to store record type developer name  of Retirement Account record type.
	 */
	public static final String RT_RETIREMENT_ACCOUNT = 'Retirement_Account';
	/**
	 * @description Constant string representing Investment Product Type
	 */
	public static final String PRODUCT_CATEGORY_INVESTMENT = 'Investment';
	/**
	 * @description Constant string representing Retirement Product Type
	 */
	public static final String PRODUCT_CATEGORY_RETIREMENT = 'Retirement';

  /**
   * @description Method to define the fields to retrieve for most query's
   *
   * @return A list of fields
   */
  public static Set<String> getDefaultFields()
  {
    return new Set<String>
    {
        FIELD_EXTERNAL_ID,
        FIELD_FINANCIAL_ACCOUNT_NUMBER,
	FIELD_FINANCIAL_GOAL_ID,
        FIELD_OWNER_CONSULTANT_CODE,
        FIELD_PRIMARY_OWNER,
				FIELD_PRODUCT_CATEGORY,
				FinServ__FinancialAccount__c.AW_AccessibleAmount__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.AW_ActualPremiumAmount__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.AW_AdvanceAvailable__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.AW_AnnualContributionIncreaseACI__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.AW_CurrentValue__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.AW_IllustratedValueDate__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.AW_IllustrativeMaturityValue__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.AW_IncomeFrequency__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.AW_InvestmentValue__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.AW_LastIncomeAmount__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.AW_LastIncomeDate__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.AW_Last_Updated_Date_from_Source__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.AW_MasterAccountId__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.AW_MasterAccount__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.AW_ProductSubCategory__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.AW_ProductTypeCode__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.AW_PrototypeCode__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.AW_RepayableAmount__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.AW_StatusReason__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.AW_SurrenderValue__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.AW_TotalInvestmentAmount__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.AW_ValueAsAt__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_AutomaticContributionIncreaseAmt__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_BankAccountHolderName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_BankAccountNumber__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_BankAccountType__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_BankBranchCode__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_BankName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_CessionaryInitials__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_CessionaryName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_CessionaryTitle__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_CessionaryType__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_CommutedValueOfAnnuity__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_DebitDay__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_EarlyRetirementValue__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_EmployeeNumber__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_FacilityGroup__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_FacilityName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_FacilityNumber__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_GrowthSharingPortion__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_GrowthSharingTargetReturn__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_GuaranteeEndDate__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_GuaranteeStartDate__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_GuaranteeValue__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_GuaranteedInvestmentAmount__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_HighWaterMarkGuarantee__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_MasterAccountRecordTypeName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_NonGuaranteedInvestmentAmount__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_OngoingAdviceFeeAnnualGrowth__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_OngoingAdviceFeeAnnual__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_OngoingAdviceFeeEIF__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_OngoingAdviceFeeOIP__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_OptionDate__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_PaidtoDate__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_PayPointNumber__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_PaymentMethod__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_PremiumPattern__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_RetirementAge__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_RetirementDate__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_SwitchedValue__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_TopUpValue__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_TotalPackageDeathValue__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_TotalWithdrawalAmount__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_TransferValue__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.CMN_TransferringPolicyNumbers__c.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.FinServ__InterestRate__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.FinServ__OpenDate__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.FinServ__PaymentFrequency__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.FinServ__Premium__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.FinServ__Status__c.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.Name.getDescribe().getLocalName(),
        FinServ__FinancialAccount__c.OwnerId.getDescribe().getLocalName(),
				FinServ__FinancialAccount__c.RecordTypeId.getDescribe().getLocalName(),
				//TODO: Move this field to SL DAL
				FinServ__FinancialAccount__c.SLSC_EntityNumber__c.getDescribe().getLocalName()
    };
  }

  /**
   * @description This method is use to return the Financial Account by Id
   *
	 * @param financialAccountId The id on which to match the financial account
   *
   * @return A financial account or null
   */
	public static FinServ__FinancialAccount__c findById(Id financialAccountId)
  {
		return (FinServ__FinancialAccount__c)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, financialAccountId, getDefaultFields());
  }

  /**
	 * @description This method is use to return the Financial Account by Id
	 *
	 * @param financialAccountIds The id on which to match the financial account
	 *
	 * @return A financial account or null
	 */
	public static List<FinServ__FinancialAccount__c> findById(Set<Id> financialAccountIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, financialAccountIds, getDefaultFields());
	}
	/**
   * @description Will return all Financial Accounts created by unit tests
   *
   * @return A list of items
   */
  @TestVisible
  private static List<FinServ__FinancialAccount__c> getAll()
  {
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
  }

  /**
	 * @description Will find financial accounts based on list of primary owner ids
	 *
	 * @param accountIds A set of account Id
	 *
	 * @return a List of items
	 */
	public static List<FinServ__FinancialAccount__c> findByPrimaryOwnerWithChildDetails(Set<Id> accountIds)
	{
		CMN_SOQL_Builder holdingSubQuery =
				new CMN_SOQL_Builder()
						.selectX(AW_DAL_FinancialHolding.getDefaultFields())
						.fromX(RT_FINANCIAL_HOLDINGS);

		CMN_SOQL_Builder accountRoleSubQuery =
				new CMN_SOQL_Builder()
						.selectX(AW_DAL_FinancialAccountRole.getDefaultFields())
						.fromX(RT_FINANCIAL_ACCOUNT_ROLES);

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(getDefaultFields())
						.selectX(accountRoleSubQuery)
						.selectX(holdingSubQuery)
						.fromX(OBJECT_NAME)
						.whereX(CMN_SOQL_Query.inX(FIELD_PRIMARY_OWNER, CMN_UTIL_System.setToList(accountIds)));

		return Database.query(builder.toSoql());
	}

  /**
   * @description Will return all Financial Accounts
   *
	 * @param accountId The account id with which to filter financial accounts
   *
   * @return A list of financial accounts
   */
  public static List<FinServ__FinancialAccount__c> findInForceByAccountId(String accountId)
    {
        CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters
            (
                OBJECT_NAME,
                FIELD_PRIMARY_OWNER_ID,
                new Set<String> {String.valueOf(accountId)},
                getDefaultFields()
            );

        searchParameters.searchConditions.inX(FIELD_STATUS, ACTIVE_STATUSES);
        
        return CMN_DAL_Search.getObjects(searchParameters);
    }
/**
 * @description Will return all Financial Accounts which satisfy the criteria
 *
 * @param accountId The account id with which to filter financial accounts
 * @param goalId The goal id with which to filter financial accounts
 *
 * @return A list of financial accounts
 */
public static List<FinServ__FinancialAccount__c> findActiveInvestmentsByAccountAndGoalId(String accountId, String goalId)
{
	CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters
			(
					OBJECT_NAME,
					FIELD_PRIMARY_OWNER_ID,
					new Set<String> {String.valueOf(accountId)},
					getDefaultFields()
			);

	CMN_SOQL_Query.OrCondition orCondition = CMN_SOQL_Query.orX();
	CMN_SOQL_Query.AndCondition andCondition = CMN_SOQL_Query.andX();

		//TODO: If the goalId is passed in as null this condition will always be true.... what are you trying to do
	andCondition.equalsX(FIELD_FINANCIAL_GOAL_ID, goalId);
	orCondition.add(andCondition);

	CMN_SOQL_Query.AndCondition secondAndCondition = CMN_SOQL_Query.andX();

	secondAndCondition.equalsX(FIELD_FINANCIAL_GOAL_ID, null);
	secondAndCondition.inX(FIELD_STATUS, ACTIVE_STATUSES);
	secondAndCondition.equalsX(FIELD_PRODUCT_CATEGORY, AW_DAL_FinancialAccount.PRODUCT_CATEGORY_INVESTMENT);

	orCondition.add(secondAndCondition);

	searchParameters.searchConditions.add(orCondition);

	return CMN_DAL_Search.getObjects(searchParameters);
	}
	
      /**
	 * @description Finds a Financial Account by Id and also returns related child objects
	 *
	 * @param financialAccountId The id of the financial account
	 *
	 * @return null or the item
	 */
	public static FinServ__FinancialAccount__c findByIdWithChildDetails(Id financialAccountId)
	{
		CMN_SOQL_Builder holdingSubQuery =
				new CMN_SOQL_Builder()
						.selectX(AW_DAL_FinancialHolding.getDefaultFields())
						.fromX(RT_FINANCIAL_HOLDINGS);

		CMN_SOQL_Builder accountRoleSubQuery =
				new CMN_SOQL_Builder()
						.selectX(AW_DAL_FinancialAccountRole.getDefaultFields())
						.fromX(RT_FINANCIAL_ACCOUNT_ROLES);

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(getDefaultFields())
						.selectX(accountRoleSubQuery)
						.selectX(holdingSubQuery)
						.fromX(OBJECT_NAME)
						.whereX(CMN_SOQL_Query.equalsX(CMN_DAL_SObjectDomain.FIELD_ID, financialAccountId));

		return Database.query(builder.toSoql());
	}
}