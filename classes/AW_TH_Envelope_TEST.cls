/**
 * @description Test class for AW_TH_Envelope
 *
 * @see AW_TH_Envelope
 *
 * @author vishakha.saini@accenture.com jason.van.beukering@accenture.com
 *
 * @date 2021, July 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TH_Envelope_TEST
{
	private static final String ERROR_ITEM_NOT_LINKED = 'Item was not linked to master account';
	private static final String ERROR_OWNER_NOT_SAME = 'Owner is not same as Account Owner';

	/**
	 * @description Will insert an envelope with relevant status
	 *
	 * @param status The status to set envelope too
	 *
	 * @return An committed envelope
	 */
	private static AW_Envelope__c insertEnvelope(String status)
	{
		AW_Envelope__c newEnvelope = AW_DAL_TestDataFactory.newEnvelope();
		newEnvelope.AW_Status__c = status;
		CMN_DAL_SObjectDomain.insertDBObject(newEnvelope);
		return newEnvelope;
	}

	/**
	 * @description Test method to test whether a Envelope is related to MasterAccount on Insert
	 */
	@IsTest
	private static void insertEnvelopeWithAccount()
	{
		Account childAccount = AW_DAL_TestDataFactory.createPersonChildAccountWithMaster();

		Test.startTest();

		AW_Envelope__c newEnvelope = AW_DAL_TestDataFactory.insertEnvelopeWithActiveAccount(childAccount.Id);

		Test.stopTest();

		newEnvelope = AW_DAL_Envelope.findById(newEnvelope.Id);

		System.assertNotEquals(null, newEnvelope.AW_MasterAccount__c, ERROR_ITEM_NOT_LINKED);
	}

	/**
	 * @description Test method to test whether an Envelope created by Personal Assistant is linked to Account Owner
	 */
	@IsTest
	private static void updateEnvelopeWithAccountOwner()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		Account childAccount;

		System.runAs(adviser)
		{
			childAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		}

		User personalAssistant = AW_DAL_User.findActivePersonalAssistant();

		AW_Envelope__c newEnvelope;

		System.runAs(personalAssistant)
		{
			Test.startTest();
			newEnvelope = AW_DAL_TestDataFactory.insertEnvelopeWithActiveAccount(childAccount.Id);
			Test.stopTest();
		}

		childAccount = AW_DAL_Account.findById(childAccount.Id);
		newEnvelope = AW_DAL_Envelope.findById(newEnvelope.Id);
		System.assertEquals(newEnvelope.OwnerId, childAccount.OwnerId, ERROR_OWNER_NOT_SAME);
	}

	/**
	 * @description Test method to test whether a delete is prevented when an envelope does not have the status of New
	 */
	@IsTest
	private static void preventDelete()
	{
		AW_Envelope__c envelope = insertEnvelope(AW_DAL_Envelope.STATUS_DECLINED);

		Test.startTest();

		Boolean successful = CMN_DAL_SObjectDomain.deleteDBObject(envelope, false).success;

		Test.stopTest();

		System.assertEquals(false, successful, 'Delete was not prevented as expected.');

	}

	/**
	 * @description Test method to test whether a delete is prevented when an envelope has the status of New
	 */
	@IsTest
	private static void allowDelete()
	{
		AW_Envelope__c envelope = insertEnvelope(AW_DAL_Envelope.STATUS_NEW);

		Test.startTest();

		Boolean successful = CMN_DAL_SObjectDomain.deleteDBObject(envelope, false).success;

		Test.stopTest();

		System.assertEquals(true, successful, 'Delete was allowed as expected');
	}
}