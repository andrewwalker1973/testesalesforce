/**
 * @description Test class for Trigger AW_TH_FinancialGoal
 *
 * @see AW_TH_FinancialGoal
 *
 * @author vishakha.saini@accenture.com, jason.van.beukering@accenture.com
 *
 * @date 2021, February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_TH_FinancialGoal
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;
	private static final String ERROR_ITEM_NOT_LINKED = 'Item was not linked to master account';
	private static final String ERROR_OWNER_NOT_SAME = 'Owner is not same as Account Owner';

	/**
	 * @description Test method to test whether a Goals is related to MasterAccount on Insert
	 */
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	@IsTest
	private static void linkGoal()
	{
		Account childAccount = AW_DAL_TestDataFactory.createPersonChildAccountWithMaster();

		Test.startTest();

		FinServ__FinancialGoal__c newGoal = AW_DAL_TestDataFactory.createGoals(childAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		Test.stopTest();

		newGoal = AW_DAL_FinancialGoal.findById(newGoal.Id);
		System.assertNotEquals(null, newGoal.AW_MasterAccount__c, ERROR_ITEM_NOT_LINKED);
	}

	/**
	 * @description Test method to test whether a FinancialGoal is assigned to ParentAccount Owner on Insert
	 */
	@IsTest
	private static void updateFinancialGoalWithAccountOwner()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		Account childAccount;

		System.runAs(adviser)
		{
			childAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		}

		User personalAssistant = AW_DAL_User.findActivePersonalAssistant();

		FinServ__FinancialGoal__c newGoal;

		System.runAs(personalAssistant)
		{
			Test.startTest();

			newGoal = AW_DAL_TestDataFactory.createGoals(childAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

			Test.stopTest();
		}

		childAccount = AW_DAL_Account.findById(childAccount.Id);
		newGoal = AW_DAL_FinancialGoal.findById(newGoal.Id);
		System.assertEquals(newGoal.OwnerId, childAccount.OwnerId, ERROR_OWNER_NOT_SAME);
	}
}