/**
 * @description Test class for AW_TH_Planned_Solution
 *
 * @see AW_TH_Planned_Solution
 *
 * @author Deloitte vishakha.saini@accenture.com
 *
 * @date 2020, February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_TH_Planned_Solution
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description This method will test whether Opportunity is getting populated on Planned Solution
	 */
	@IsTest
	private static void populateOpportunityOnSolutions()
	{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

		Opportunity newOpportunity = AW_DAL_TestDataFactory.createDefaultOpportunities(newAccount, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		AW_FNA__c newFna = AW_DAL_TestDataFactory.createFNA(newAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		FinServ__FinancialGoal__c objGoal = AW_DAL_TestDataFactory.createGoals(newAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		objGoal.AW_FNA__c = newFna.Id;
		update objGoal;

		Test.startTest();

		AW_Planned_Solution__c newSolution = AW_DAL_TestDataFactory.createSolutions(objGoal.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		Test.stopTest();

		//TODO Priority 1: Query should be part of a DAL class
		newSolution =
		[
				SELECT Id,
						AW_Opportunity_Name__r.Id
				FROM AW_Planned_Solution__c
				WHERE Id = :newSolution.Id
		];

		System.assertEquals(newOpportunity.Id, newSolution.AW_Opportunity_Name__r.Id);
	}
}