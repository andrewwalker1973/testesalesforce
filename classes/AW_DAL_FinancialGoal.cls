/**
 * @description Public class to return the records of Financial Goal
 *
 * @author jason.van.beukering@accenture.com safwan.h.mohammed@accenture.com
 *
 * @date 2019, October 2022
 */
public inherited sharing class AW_DAL_FinancialGoal
{
	private static final String FIELD_GOAL_TYPE = FinServ__FinancialGoal__c.AW_Goal_Type__c.getDescribe().getLocalName();
	private static final String FIELD_PRIMARY_OWNER_ID = 'FinServ__PrimaryOwner__r.Id';
	private static final String FIELD_TARGET_DATE = FinServ__FinancialGoal__c.FinServ__TargetDate__c.getDescribe().getLocalName();

	/**
	 * @description The API name of the primary owner field
	 */
	public static final String FIELD_PRIMARY_OWNER = FinServ__FinancialGoal__c.FinServ__PrimaryOwner__c.getDescribe().getLocalName();
	/**
	 * @description The API name of the object
	 */
	public static final String OBJECT_NAME = FinServ__FinancialGoal__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
	/**
	 * @description The picklist value for "Risk" Goals
	 */
	public static final String PICK_RISK_GOAL_TYPE = 'Risk';
	/**
	 * @description The picklist value for "Risk" Goals
	 */
	public static final String PICK_INVESTMENT_GOAL_TYPE = 'Investment';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_GOAL_TYPE,
				FIELD_PRIMARY_OWNER,
				FIELD_PRIMARY_OWNER_ID,
				FIELD_TARGET_DATE,
				FinServ__FinancialGoal__c.AW_AssetsAndLiabilities__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_FNA__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_GoalTypeIfOther__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_IsCreator__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_IsInvestmentGoal__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_IsProtectionGoal__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_PercentageComplete__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_PriorityLevel__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_ProductType__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_RelatedOpportunity__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_Shortfall__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_SortingDate__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_TotalFinancialAmount__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_TotalInsuranceAmount__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_MasterAccount__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.AW_Total_Current_Market_Value__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.CreatedDate.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.FinServ__ActualValue__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.FinServ__CompletionDate__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.FinServ__Description__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.FinServ__Household__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.FinServ__InitialValue__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.FinServ__SourceSystemId__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.FinServ__Status__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.FinServ__TargetDate__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.FinServ__TargetValue__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.FinServ__Type__c.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.Id.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.Name.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.OwnerId.getDescribe().getLocalName(),
				FinServ__FinancialGoal__c.RecordTypeId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Method to return the List of Financial Goals sorted by target date
	 *
	 * @param accountId The primary owner of the Goal
	 *
	 * @return List of sorted items
	 */
	public static List<FinServ__FinancialGoal__c> findByPrimaryOwner(Id accountId)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_PRIMARY_OWNER, new Set<String> {String.valueOf(accountId)}, getDefaultFields());

		CMN_SOQL_Query.OrderBy orderBy = searchParameters.addOrderByField(FIELD_TARGET_DATE);
		orderBy.nullsFirst = true;

		return CMN_DAL_Search.getObjects(searchParameters);
	}
	/**
	 * @description Method to return the List of Financial Goals byt the Goal Type
	 *
	 * @param accountId The primary owner of the Goal
	 * @param goalType The goal type to filter the items
	 *
	 * @return List of found Items
	 */
	public static List<FinServ__FinancialGoal__c> findByAccountIdAndGoalType(Id accountId, String goalType)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());

		searchParameters.searchConditions.equalsX(FIELD_PRIMARY_OWNER, accountId);
		searchParameters.searchConditions.equalsX(FIELD_GOAL_TYPE, goalType);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Method to return the List of Financial Goal by Id
	 *
	 * @param accountIds Id to store the financial goal Id
	 *
	 * @return Null or Item
	 */
	public static List<FinServ__FinancialGoal__c> findByAccountId(Set<Id> accountIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_PRIMARY_OWNER, accountIds, getDefaultFields());
	}

	/**
	 * @description Method to return the List of Financial Goal by Id
	 *
	 * @param financialGoalId Id to store the financial goal Id
	 *
	 * @return Null or Item
	 */
	public static FinServ__FinancialGoal__c findById(Id financialGoalId)
	{
		return (FinServ__FinancialGoal__c)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, financialGoalId, getDefaultFields());
	}

	/**
	 * @description Method to return the List of Financial Goal by Id
	 *
	 * @param financialGoalIds Id to store the financial goal Id
	 *
	 * @return Null or Item
	 */
	public static List<FinServ__FinancialGoal__c> findById(Set<Id> financialGoalIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, financialGoalIds, getDefaultFields());
	}

	/**
	 * @description This method will return map of FNA Ids and Goals
	 *
	 * @param financialGoalIds Id to store the financial goal Id
	 *
	 * @return populated map
	 */
	public static Map<Id, List<FinServ__FinancialGoal__c>> getFnaToGoalMap(Set<Id> financialGoalIds)
	{
		List<FinServ__FinancialGoal__c> foundGoals = findById(financialGoalIds);

		Map<Id, List<FinServ__FinancialGoal__c>> fnaToGoalMap = new Map<Id, List<FinServ__FinancialGoal__c>>();

		for(FinServ__FinancialGoal__c foundGoal : foundGoals)
		{
			List<FinServ__FinancialGoal__c> goals = fnaToGoalMap.get(foundGoal.AW_FNA__c);

			if(goals == null)
			{
				goals = new List<FinServ__FinancialGoal__c>();
				fnaToGoalMap.put(foundGoal.AW_FNA__c, goals);
			}

			goals.add(foundGoal);
		}

		return fnaToGoalMap;
	}

	/**
	 * @description retrieves all financial goals in the system
	 *
	 * @return A list of items
	 */
	@TestVisible
	private static List<FinServ__FinancialGoal__c> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
}