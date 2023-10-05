/**
 * @description Test class for AW_TH_BusinessMilestone
 *
 * @see AW_TH_BusinessMilestone
 *
 * @author vishakha.saini@accenture.com, jason.van.beukering@accenture.com
 *
 * @date 2021, February 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_TH_BusinessMilestone
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;
	private static final String ERROR_ITEM_NOT_LINKED = 'Item was not linked to master account';
	private static final String ERROR_OWNER_NOT_SAME = 'Owner is not same as Account Owner';

	/**
	 * @description Test method to test whether a BusinessMilestone is related to MasterAccount on Insert
	 */
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	@IsTest
	private static void linkBusinessMilestone()
	{
		Account childAccount = AW_DAL_TestDataFactory.createPersonChildAccountWithMaster();

		Test.startTest();

		BusinessMilestone newMilestone = AW_DAL_TestDataFactory.createBusinessMilestone(childAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		Test.stopTest();

		newMilestone = AW_DAL_BusinessMilestone.findById(newMilestone.Id);
		System.assertNotEquals(null, newMilestone.AW_MasterAccount__c, ERROR_ITEM_NOT_LINKED);
	}

	/**
	 * @description Test method to test whether a BusinessMilestone owner is set to parent account owner if PA creates the record
	 */
	@IsTest
	private static void setOwner()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		Account childAccount;

		System.runAs(adviser)
		{
			childAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		}

		User personalAssistant = AW_DAL_User.findActivePersonalAssistant();

		BusinessMilestone newMilestone;

		System.runAs(personalAssistant)
		{
			Test.startTest();

			newMilestone = AW_DAL_TestDataFactory.createBusinessMilestone(childAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

			Test.stopTest();
		}

		childAccount = AW_DAL_Account.findById(childAccount.Id);
		newMilestone = AW_DAL_BusinessMilestone.findById(newMilestone.Id);

		System.assertEquals(childAccount.OwnerId, newMilestone.OwnerId, ERROR_OWNER_NOT_SAME);
	}
}