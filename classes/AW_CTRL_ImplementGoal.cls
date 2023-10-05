/**
 * @description This class is the apex controller for Lightning Component AW_CMP_ImplementGoalContainer
 *
 * @see AW_CTRL_ImplementGoal_TEST
 *
 * @author safwan.h.mohammed@accenture.com, jason.van.beukering@accenture.com
 *
 * @date November 2020, August 2023
 */
public inherited sharing class AW_CTRL_ImplementGoal
{
	/**
	 * @description This aura enabled method will fetch Goals using the account ID
	 *
	 * @param accountId The account ID of the Account which initiated the process
	 *
	 * @return List of Items
	 */
	@AuraEnabled
	public static List<FinServ__FinancialGoal__c> fetchGoals(Id accountId)
	{
		return AW_DAL_FinancialGoal.findByAccountId(new Set<Id> {accountId});
	}

	/**
	 * @description This aura enabled method will fetch Goals using the goal ID
	 *
	 * @param financialGoalID The Financial Goal ID of the Account which initiated the process
	 *
	 * @return List of financial goals
	 */
	@AuraEnabled
	public static List<FinServ__FinancialGoal__c> fetchGoalsWithGoalId(Id financialGoalID)
	{
		return AW_DAL_FinancialGoal.findById(new Set<Id> {financialGoalID});
	}

	/**
	 * @description This aura enabled method will fetch Planned Solutions using the goal ID
	 *
	 * @param goalId The Financial Goal Id whose Solutions need to be fetched
	 *
	 * @return List of solutions
	 */
	@AuraEnabled
	public static List<AW_Planned_Solution__c> fetchSolutions(Id goalId)
	{
		return AW_DAL_PlannedSolution.findByFinancialGoalId(new Set<Id> {goalId});
	}

	/**
	 * @description This aura enabled method will fetch Planned Solutions using the list of goal IDs
	 *
	 * @param goalIds list of goal ids
	 *
	 * @return List of solutions
	 */
	@AuraEnabled
	public static List<AW_Planned_Solution__c> fetchSolutionsByGoalIds(List<Id> goalIds)
	{
		return AW_DAL_PlannedSolution.findByFinancialGoalId(new Set<Id>(goalIds));
	}

	/**
	 * @description This aura enabled method will fetch Planned Solutions using the Opportunity ID
	 *
	 * @param oppId The Opportunity Id whose Solutions need to be fetched
	 *
	 * @return List of solutions
	 */
	@AuraEnabled
	public static List<AW_Planned_Solution__c> fetchOpportunitySolutions(Id oppId)
	{
		return AW_DAL_PlannedSolution.findByOpportunityId(new Set<Id> {oppId});
	}

	/**
	 * @description This aura enabled method will fetch Quotes using the solution Id
	 *
	 * @param solutionId The Planned Solution Id whose quotes need to be fetched
	 *
	 * @return List of quotes
	 */
	@AuraEnabled
	public static List<Quote> fetchQuotesWithSolutionId(Id solutionId)
	{
		return AW_DAL_Quote.findByPlannedSolutionId(new Set<Id> {solutionId});
	}

	/**
	 * @description This aura enabled method will fetch Quotes using the quote Id
	 *
	 * @param quoteId The quote Id that needs to be fetched
	 *
	 * @return list of quotes
	 */
	@AuraEnabled
	public static Quote fetchQuoteWithQuoteId(Id quoteId)
	{
		return AW_DAL_Quote.findById(quoteId);
	}

	/**
	 * @description This aura enabled method will fetch Quotes using the account Id
	 *
	 * @param accountId account Id
	 *
	 * @return list of quotes
	 */
	@AuraEnabled
	public static List<Quote> fetchQuotesWithAccountId(Id accountId)
	{
		return AW_DAL_Quote.findByAccountId(accountId);
	}

	/**
	 * @description This aura enabled method will fetch field labels
	 *
	 * @param apiName sObject's API Name whose labels we want to get
	 *
	 * @return map of object labels
	 */
	@AuraEnabled
	public static Map<String, String> getLabels(String apiName)
	{
		Map<String, SObjectField> fieldMap = CMN_UTIL_SObjectDescribe.getDescribe(apiName).getFieldsMap();

		Map<String, String> labelMap = new Map<String, String>();

		for(String fieldName : fieldMap.keySet())
		{
			labelMap.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
		}

		return labelMap;
	}
	/**
	 * @description This aura enabled method will fetch accountId using the opportunity ID
	 *
	 * @param opportunityID is used to initiate the process
	 *
	 * @return String
	 */
	@AuraEnabled(Cacheable=true)
	public static String fetchAccountByOpportunityId(String opportunityID)
	{
		return String.valueOf(AW_DAL_Opportunity.findById(Id.valueOf(opportunityID)).AccountId);
	}
}