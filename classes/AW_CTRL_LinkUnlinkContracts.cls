/**
 * @description Controller class to Link or Unlink Goal(s) on a Financial Account
 *
 * @see AW_CTRL_LinkUnlinkContracts_TEST
 *
 * @author safwan.h.mohammed@accenture.com, vishakha.saini@accenture.com
 *
 * @date October 2022, April 2023
 */
public inherited sharing class AW_CTRL_LinkUnlinkContracts
{
	/**
	 * @description Will retrieve all Associated Contracts which are OR can be linked to the Goal record
	 *
	 * @param accountId The Id of the Account record to which the Associated Financial Accounts are linked
	 * @param goalId The Id of the goal record to which the Associated Financial Accounts are linked
	 *
	 * @return A list of associated contracts
	 */
	@AuraEnabled
	public static List<FinServ__FinancialAccount__c> getContracts(Id accountId, Id goalId)
	{
		return AW_DAL_FinancialAccount.findActiveInvestmentsByAccountAndGoalId(accountId, goalId);
	}
	/**
	 * @description Will retrieve all the Financial Goal of the Account record
	 *
	 * @param accountId The Id of Account through which Financial Goals will be fetched
	 *
	 * @return A list of Financial Goals
	 */
	@AuraEnabled
	public static List<FinServ__FinancialGoal__c> getInvestmentGoalsForAccount(Id accountId)
	{
		return AW_DAL_FinancialGoal.findByAccountIdAndGoalType(accountId, AW_DAL_FinancialGoal.PICK_INVESTMENT_GOAL_TYPE);
	}

	/**
	 * @description Will retrieve and update all Associated Financial Accounts linked to goal that are to be linked/unlinked
	 *
	 * @param selectedFinancialAccountIds The Ids of the Financial Account record to which the goal is to be linked
	 * @param deselectedFinancialAccountIds The Ids of Financial Accounts that are to be de-linked from Goal
	 * @param goalId The Id of the Financial goal which is to be linked or unlinked to Financial Account
	 */
	@AuraEnabled
	public static void updateContracts(List<Id> selectedFinancialAccountIds, List<Id> deselectedFinancialAccountIds, Id goalId)
	{
		List<FinServ__FinancialAccount__c> financialAccountsToUpdate = new List<FinServ__FinancialAccount__c>();

		addToUpdateList(selectedFinancialAccountIds, goalId, financialAccountsToUpdate);
		addToUpdateList(deselectedFinancialAccountIds, null, financialAccountsToUpdate);

		CMN_DAL_SObjectDomain.updateDBObjects(financialAccountsToUpdate);

		//US:439701 Initiate rollup calculation to update Actual Value on Goal
		Database.executeBatch(new dlrs.RollupJob());
	}

	/**
	 * @description Will construct and initialise a financial account record and add it to the a list of records
	 *
	 * @param financialAccountIds The ids that the financial accounts created should be set to
	 * @param goalId The goal to which they should be linked
	 * @param financialAccountsToUpdate List of records to which newly created items should be added
	 */
	private static void addToUpdateList(List<Id> financialAccountIds, Id goalId, List<FinServ__FinancialAccount__c> financialAccountsToUpdate)
	{
		for(Id financialAccountId : financialAccountIds)
		{
			FinServ__FinancialAccount__c updateAccount = new FinServ__FinancialAccount__c();

			updateAccount.Id = financialAccountId;
			updateAccount.AW_FinancialGoal__c = goalId;

			financialAccountsToUpdate.add(updateAccount);
		}
	}
}