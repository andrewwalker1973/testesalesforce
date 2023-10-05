/**
 * @description Test class for AW_TH_EmailMessage
 *
 * @see AW_TH_EmailMessage
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date May 2021, February 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_TH_EmailMessage
{
	private static final String ERROR_ITEM_NOT_LINKED = 'Item was not linked to master account';

	/**
	 * @description Test method to test whether a EmailMessage is related to MasterAccount on Insert
	 */
	@IsTest
	private static void linkEmailMessage()
	{
		Account childAccount = AW_DAL_TestDataFactory.createPersonChildAccountWithMaster();

		Test.startTest();

		EmailMessage newMessage = AW_DAL_TestDataFactory.createEmailMessage(childAccount.Id);

		Test.stopTest();

		newMessage = AW_DAL_EmailMessage.findById(newMessage.Id);
		System.assertNotEquals(null, newMessage.AW_MasterAccount__c, ERROR_ITEM_NOT_LINKED);
	}
}