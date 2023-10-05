/**
 * @description Test class for AW_TH_Case
 *
 * @see AW_TH_Case
 *
 * @author Accenture
 *
 * @date 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_TH_Case
{
	private static final String ERROR_ITEM_NOT_LINKED = 'Item was not linked to master account';
	private static final String ERROR_OWNER_NOT_SAME = 'Owner is not same as Account Owner';

	/**
	 * @description Test method to test whether a Case is assigned to ParentAccount Owner and is related to MasterAccount on Insert
	 */
	@IsTest
	private static void insertCaseAsPersonalAssistantAndLinkToMaster()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		Account childAccount;

		System.runAs(adviser)
		{
			childAccount = AW_DAL_TestDataFactory.createPersonChildAccountWithMaster();
		}

		childAccount = AW_DAL_Account.findById(childAccount.Id); //Re-query account to fetch PersonContactId field value
		User personalAssistant = AW_DAL_User.findActivePersonalAssistant();

		Case newCase;

		System.runAs(personalAssistant)
		{
			Test.startTest();

			newCase = AW_DAL_TestDataFactory.createCase(childAccount.PersonContactId);

			Test.stopTest();
		}

		childAccount = AW_DAL_Account.findById(childAccount.Id);
		newCase = AW_DAL_Case.findById(newCase.Id);
		System.assertNotEquals(null, newCase.AW_MasterAccount__c, ERROR_ITEM_NOT_LINKED);
		System.assertEquals(newCase.OwnerId, childAccount.OwnerId, ERROR_OWNER_NOT_SAME);
	}
}