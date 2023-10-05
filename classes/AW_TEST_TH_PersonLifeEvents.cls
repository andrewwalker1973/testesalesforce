/**
 * @description Test class for AW_TH_PersonLifeEvents
 *
 * @see AW_TH_PersonLifeEvents
 *
 * @author vishakha.saini@accenture.com, jason.van.beukering@accenture.com
 *
 * @date 2021, February 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_TH_PersonLifeEvents
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;
	private static final String ERROR_ITEM_NOT_LINKED = 'Item was not linked to master account';
	private static final String ERROR_OWNER_NOT_SAME = 'Owner is not same as Account Owner';

	/**
	 * @description Test method to test whether a PersonLifeEvent is related to MasterAccount on Insert
	 */
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	@IsTest
	private static void linkPersonLifeEvent()
	{
		Account childAccount = AW_DAL_TestDataFactory.createPersonChildAccountWithMaster();
		childAccount = AW_DAL_Account.findById(childAccount.Id);

		Test.startTest();
		PersonLifeEvent newEvent = AW_DAL_TestDataFactory.createPersonLifeEvents(childAccount.PersonContactId, NUMBER_OF_ITEMS_TO_CREATE, true).iterator().next();

		Test.stopTest();

		AW_DAL_PersonLifeEvent.findByPrimaryPerson(childAccount.PersonContactId);
		newEvent = AW_DAL_PersonLifeEvent.findById(newEvent.Id);
		System.assertNotEquals(null, newEvent.AW_MasterAccount__c, ERROR_ITEM_NOT_LINKED);
	}

	/**
	 * @description Test method to test whether a PersonLifeEvent is assigned to ParentAccount Owner on Insert
	 */
	@IsTest
	private static void updatePersonLifeEventWithAccountOwner()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		Account childAccount;

		System.runAs(adviser)
		{
			childAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		}

		User personalAssistant = AW_DAL_User.findActivePersonalAssistant();

		PersonLifeEvent newEvent = new PersonLifeEvent();

		childAccount = AW_DAL_Account.findById(childAccount.Id);

		System.runAs(personalAssistant)
		{

			Test.startTest();

			newEvent = AW_DAL_TestDataFactory.createPersonLifeEvents(childAccount.PersonContactId, NUMBER_OF_ITEMS_TO_CREATE, true).iterator().next();

			Test.stopTest();
		}

		childAccount = AW_DAL_Account.findById(childAccount.Id);
		newEvent = AW_DAL_PersonLifeEvent.findById(newEvent.Id);
		System.assertEquals(newEvent.OwnerId, childAccount.OwnerId, ERROR_OWNER_NOT_SAME);
	}
}