/**
 * @description Test class for AW_TH_BaseLinkToMaster
 *
 * @see AW_TH_BaseLinkToMaster
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date May 2021, February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TH_BaseLinkToMaster_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;
	private static final String ERROR_ITEM_NOT_LINKED = 'Item was not linked to master account';

	/**
	 * @description Test method to test whether a FinancialAccount is related to MasterAccount on Insert
	 */
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	@IsTest
	private static void linkToMaster()
	{
		Account newAccount = AW_DAL_TestDataFactory.createPersonChildAccountWithMaster();

		Test.startTest();

		FinServ__FinancialAccount__c newFinancialAccount = AW_DAL_TestDataFactory.createFinancialAccounts(newAccount, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		Test.stopTest();

		newFinancialAccount = AW_DAL_FinancialAccount.findById(newFinancialAccount.Id);
		System.assertNotEquals(null, newFinancialAccount.AW_MasterAccount__c, ERROR_ITEM_NOT_LINKED);
	}
}