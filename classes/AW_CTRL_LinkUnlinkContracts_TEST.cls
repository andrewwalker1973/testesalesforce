/**
 * @description Test class related to the AW_CTRL_LinkUnlinkContracts
 *
 * @see AW_CTRL_LinkUnlinkContracts
 *
 * @author safwan.h.mohammed@accenture.com
 *
 * @date October 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_CTRL_LinkUnlinkContracts_TEST
{
	private static final Integer NUMBER_OF_RECORDS_TO_CREATE = 2;

	/**
	 * @description Create data required for the unit test
	 */
	@TestSetup
	private static void setup()
	{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		List<FinServ__FinancialAccount__c> newFinancialAccounts = AW_DAL_TestDataFactory.createFinancialAccounts(newAccount, NUMBER_OF_RECORDS_TO_CREATE);
		List<FinServ__FinancialGoal__c> newFinancialGoals = AW_DAL_TestDataFactory.createGoals(newAccount.Id, NUMBER_OF_RECORDS_TO_CREATE);


		newFinancialGoals[0].AW_Goal_Type__c = AW_DAL_FinancialGoal.PICK_INVESTMENT_GOAL_TYPE;
		newFinancialGoals[1].AW_Goal_Type__c = AW_DAL_FinancialGoal.PICK_RISK_GOAL_TYPE;

		update newFinancialGoals;

		for(FinServ__FinancialAccount__c currentFinancialAccount : newFinancialAccounts)
		{
			currentFinancialAccount.FinServ__Status__c = AW_DAL_FinancialAccount.STATUS_IN_FORCE;
			currentFinancialAccount.AW_ProductCategory__c = AW_DAL_FinancialAccount.PRODUCT_CATEGORY_INVESTMENT;
		}
		newFinancialAccounts[1].AW_FinancialGoal__c = newFinancialGoals[0].Id;
		update newFinancialAccounts;
	}

	@IsTest
	private static void getFinancialGoalFromAccount()
	{
		Account newAccount = AW_DAL_Account.getAll().iterator().next();

		Test.startTest();

		List<FinServ__FinancialGoal__c> testFinancialGoals = AW_CTRL_LinkUnlinkContracts.getInvestmentGoalsForAccount(newAccount.Id);

		Test.stopTest();

		for(FinServ__FinancialGoal__c currentFinancialGoal: testFinancialGoals)
		{
			System.assertEquals(currentFinancialGoal.AW_Goal_Type__c, AW_DAL_FinancialGoal.PICK_INVESTMENT_GOAL_TYPE, 'Incorrect Financial Goals Fetched');
		}
	}

	@IsTest
	private static void getFinancialAccounts()
	{
		Account newAccount = AW_DAL_Account.getAll().iterator().next();
		List<FinServ__FinancialAccount__c> financialAccount = AW_DAL_FinancialAccount.getAll();
		FinServ__FinancialGoal__c financialGoal = AW_DAL_FinancialGoal.getAll().iterator().next();

		Test.startTest();

		List<FinServ__FinancialAccount__c> testFinancialAccounts = AW_CTRL_LinkUnlinkContracts.getContracts(newAccount.Id, financialGoal.Id);

		Test.stopTest();

		System.assertEquals(financialAccount[0].Id, testFinancialAccounts[0].Id, 'Incorrect Financial Account Id Fetched');
		System.assertEquals(financialAccount[1].Id, testFinancialAccounts[1].Id, 'Incorrect Financial Account Id Fetched');
	}

	@IsTest
	private static void updateContracts()
	{
		List<FinServ__FinancialAccount__c> contractsBeforeTest = AW_DAL_FinancialAccount.getAll();
		FinServ__FinancialGoal__c financialGoal = AW_DAL_FinancialGoal.getAll().iterator().next();

		List<Id> selectedContractIds = new List<Id> {contractsBeforeTest[0].Id};
		List<Id> deselectedContractIds = new List<Id> {contractsBeforeTest[1].Id};

		Test.startTest();

		AW_CTRL_LinkUnlinkContracts.updateContracts(selectedContractIds, deselectedContractIds, financialGoal.Id);

		Test.stopTest();

		List<FinServ__FinancialAccount__c> contractsAfterTest = AW_DAL_FinancialAccount.getAll();

		for(FinServ__FinancialAccount__c currentContract : contractsAfterTest)
		{
			if(currentContract.Id.equals(contractsBeforeTest[0].Id))
			{
				System.assertEquals(currentContract.AW_FinancialGoal__c, financialGoal.Id, 'Incorrect Financial Goal Assigned On Financial Account');
			}
			if(currentContract.Id.equals(contractsBeforeTest[1].Id))
			{
				System.assertEquals(currentContract.AW_FinancialGoal__c, null, 'Financial account has not been unlinked from goal');
			}
		}
	}
}