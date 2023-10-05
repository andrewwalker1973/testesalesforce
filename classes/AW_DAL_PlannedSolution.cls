/**
 * @description Public class to return the records of a Planned Solution
 *
 * @author pavan.thammali@liberty.co.za, kiran.kumaryelisetti@lntinfotech.com
 *
 * @date June 2022, March 2023
 */
public inherited sharing class AW_DAL_PlannedSolution
{
	private static final String FIELD_ACCOUNT_CLIENT_ID = 'AW_Opportunity_Name__r.Account.AW_ClientId__c';
	private static final String FIELD_ACCOUNT_COUNTRY_OF_BIRTH = 'AW_Opportunity_Name__r.Account.AW_Country_Of_Birth__c';
	private static final String FIELD_ACCOUNT_FINSERV_GENDER = 'AW_Opportunity_Name__r.Account.FinServ__Gender__pc';
	private static final String FIELD_ACCOUNT_FIRST_NAME = 'AW_Opportunity_Name__r.Account.FirstName';
	private static final String FIELD_ACCOUNT_IDENTIFICATION_NUMBER = 'AW_Opportunity_Name__r.Account.AW_IdentificationNumber__pc';
	private static final String FIELD_ACCOUNT_IDENTIFICATION_TYPE = 'AW_Opportunity_Name__r.Account.AW_IdentificationType__pc';
	private static final String FIELD_ACCOUNT_LAST_NAME = 'AW_Opportunity_Name__r.Account.LastName';
	private static final String FIELD_ACCOUNT_PASSPORT_COUNTRY_OF_ISSUE = 'AW_Opportunity_Name__r.Account.AW_PassportCountryOfIssue__pr.AW_CountryCode__c';
	private static final String FIELD_ACCOUNT_PERSON_BIRTH_DATE = 'AW_Opportunity_Name__r.Account.PersonBirthdate';
	private static final String FIELD_ACCOUNT_RETIREMENT_AGE = 'AW_Opportunity_Name__r.Account.Retirement_Age__pc';
	private static final String FIELD_ACCOUNT_SALUTATION = 'AW_Opportunity_Name__r.Account.Salutation';
	private static final String FIELD_ACCOUNT_SKF_ID = 'AW_Opportunity_Name__r.Account.AW_SKF_Id__c';
	private static final String FIELD_FINANCIAL_GOAL = AW_Planned_Solution__c.AW_Financial_Goal__c.getDescribe().getLocalName();
	private static final String FIELD_FINANCIAL_GOAL_GOAL_TYPE = 'AW_Financial_Goal__r.AW_Goal_Type__c';
	private static final String FIELD_FINANCIAL_GOAL_SHORTFALL= 'AW_Financial_Goal__r.AW_Shortfall__c';
	private static final String FIELD_OPPORTUNITY = AW_Planned_Solution__c.AW_Opportunity_Name__c.getDescribe().getLocalName();
	private static final String FIELD_OPPORTUNITY_ID = 'AW_Opportunity_Name__r.Id';
	private static final String OBJECT_NAME = AW_Planned_Solution__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				AW_Planned_Solution__c.AW_CPI__c.getDescribe().getLocalName(),
				AW_Planned_Solution__c.AW_Growth_Strategy__c.getDescribe().getLocalName(),
				AW_Planned_Solution__c.AW_Lumpsum_Amount__c.getDescribe().getLocalName(),
				AW_Planned_Solution__c.AW_PremiumFrequency__c.getDescribe().getLocalName(),
				AW_Planned_Solution__c.AW_Premium_Amount__c.getDescribe().getLocalName(),
				AW_Planned_Solution__c.AW_Product_Name__c.getDescribe().getLocalName(),
				AW_Planned_Solution__c.AW_RecommendedMultiStratPortfolio__c.getDescribe().getLocalName(),
				AW_Planned_Solution__c.AW_SourceSystemId__c.getDescribe().getLocalName(),
				AW_Planned_Solution__c.AW_Target_Return__c.getDescribe().getLocalName(),
				AW_Planned_Solution__c.AW_Term_Months__c.getDescribe().getLocalName(),
				AW_Planned_Solution__c.Name.getDescribe().getLocalName(),
				FIELD_ACCOUNT_CLIENT_ID,
				FIELD_ACCOUNT_COUNTRY_OF_BIRTH,
				FIELD_ACCOUNT_FINSERV_GENDER,
				FIELD_ACCOUNT_FIRST_NAME,
				FIELD_ACCOUNT_IDENTIFICATION_NUMBER,
				FIELD_ACCOUNT_IDENTIFICATION_TYPE,
				FIELD_ACCOUNT_LAST_NAME,
				FIELD_ACCOUNT_PASSPORT_COUNTRY_OF_ISSUE,
				FIELD_ACCOUNT_PERSON_BIRTH_DATE,
				FIELD_ACCOUNT_RETIREMENT_AGE,
				FIELD_ACCOUNT_SALUTATION,
				FIELD_ACCOUNT_SKF_ID,
				FIELD_FINANCIAL_GOAL_GOAL_TYPE,
				FIELD_FINANCIAL_GOAL_SHORTFALL,
				FIELD_OPPORTUNITY,
				FIELD_OPPORTUNITY_ID
		};
	}

	/**
	 * @description Retrieves the planned solution having the given id.
	 *
	 * @param plannedSolutionId a planned solution id
	 *
	 * @return null or item
	 */
	public static AW_Planned_Solution__c findById(Id plannedSolutionId)
	{
		return (AW_Planned_Solution__c)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, plannedSolutionId, getDefaultFields());
	}

	/**
	 * @description Will return all Planned Solution records created by unit tests
	 *
	 * @return A list of Planned Solutions
	 */
	@TestVisible
	private static List<AW_Planned_Solution__c> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description Retrieves the planned solution having the given financial goal id.
	 *
	 * @param financialGoalIds a financial goal id
	 *
	 * @return null or item
	 */
	public static List<AW_Planned_Solution__c> findByFinancialGoalId(Set<Id> financialGoalIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_FINANCIAL_GOAL, financialGoalIds, getDefaultFields());
	}

	/**
	 * @description Retrieves the planned solution having the given opportunity id.
	 *
	 * @param opportunityIds a opportunity id
	 *
	 * @return null or item
	 */
	public static List<AW_Planned_Solution__c> findByOpportunityId(Set<Id> opportunityIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_OPPORTUNITY, opportunityIds, getDefaultFields());
	}
}