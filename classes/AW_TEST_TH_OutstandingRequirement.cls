/**
 * @description Test class for AW_TH_OutStandingRequirement
 *
 * @see AW_TH_OutstandingRequirement
 *
 * @author vishakha.saini@accenture.com, jason.van.beukering@accenture.com
 *
 * @date 2021, February 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_TH_OutstandingRequirement
{
	private static final String ERROR_ITEM_NOT_LINKED = 'Item was not linked to master account';
	private static final String ERROR_OWNER_NOT_SAME = 'Owner is not same as Account Owner';

	/**
	 * @description Test method to test whether a OutStandingRequirement is related to MasterAccount on Insert
	 */
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	@IsTest
	private static void linkOutstandingRequirement()
	{
		Account childAccount = AW_DAL_TestDataFactory.createPersonChildAccountWithMaster();

		Test.startTest();

		AW_Outstanding_Requirement__c newRequirement = AW_DAL_TestDataFactory.createWorkflowTask(childAccount);

		Test.stopTest();

		newRequirement = AW_DAL_OutstandingRequirement.findById(newRequirement.Id);
		System.assertNotEquals(null, newRequirement.AW_MasterAccount__c, ERROR_ITEM_NOT_LINKED);
	}

	/**
	 * @description Test method to test whether a OutStandingRequirement is assigned to ParentAccount Owner on Insert
	 */
	@IsTest
	private static void updateOutStandingRequirementWithAccountOwner()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		Account childAccount;

		System.runAs(adviser)
		{
			childAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		}

		User personalAssistant = AW_DAL_User.findActivePersonalAssistant();

		AW_Outstanding_Requirement__c newRequirement;

		System.runAs(personalAssistant)
		{

			Test.startTest();

			newRequirement = AW_DAL_TestDataFactory.createWorkflowTask(childAccount);

			Test.stopTest();
		}

		childAccount = AW_DAL_Account.findById(childAccount.Id);
		newRequirement = AW_DAL_OutstandingRequirement.getAll().iterator().next();
		System.assertEquals(newRequirement.OwnerId, childAccount.OwnerId, ERROR_OWNER_NOT_SAME);
	}
}