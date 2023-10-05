/**
 * @description Test class for AW_TH_DocumentCheckListItem
 *
 * @see AW_TH_DocumentCheckListItem
 *
 * @author vishakha.saini@accenture.com jason.van.beukering@accenture.com
 *
 * @date 2021, July 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TH_DocumentCheckListItem_TEST
{
	private static final String ERROR_OWNER_NOT_SAME = 'Owner is not same as Envelope Owner';

	/**
	 * @description Will insert an envelope with relevant status
	 *
	 * @param status The status to set envelope too
	 *
	 * @return A committed envelope
	 */
	private static AW_Envelope__c insertEnvelope(String status)
	{
		AW_Envelope__c newEnvelope = AW_DAL_TestDataFactory.newEnvelope();
		newEnvelope.AW_Status__c = status;
		CMN_DAL_SObjectDomain.insertDBObject(newEnvelope);
		return newEnvelope;
	}

	/**
	 * @description Test method to test whether a delete is prevented when an envelope does not have the status of New
	 */
	@IsTest
	private static void preventDelete()
	{
		AW_Envelope__c envelope = insertEnvelope(AW_DAL_Envelope.STATUS_NEW);

		DocumentChecklistItem documentChecklistItem = AW_DAL_TestDataFactory.insertDocumentCheckListItem(envelope.Id);

		envelope.AW_Status__c = AW_DAL_Envelope.STATUS_DECLINED;

		Test.startTest();

		update envelope;

		Boolean successful = CMN_DAL_SObjectDomain.deleteDBObject(documentChecklistItem, false).success;

		Test.stopTest();

		System.assertEquals(false, successful, 'Delete was not prevented as expected.');

	}

	/**
	 * @description Test method to test whether an insert is prevented when an envelope does not have the status of New
	 */
	@IsTest
	private static void preventInsert()
	{
		AW_Envelope__c envelope = insertEnvelope(AW_DAL_Envelope.STATUS_NEW);

		DocumentChecklistItem documentChecklistItem = AW_DAL_TestDataFactory.insertDocumentCheckListItem(envelope.Id);

		envelope.AW_Status__c = AW_DAL_Envelope.STATUS_DECLINED;

		Test.startTest();

		update envelope;

		Boolean successful = CMN_DAL_SObjectDomain.insertDBObject(documentChecklistItem, false).success;

		Test.stopTest();

		System.assertEquals(false, successful, 'Insert was not prevented as expected.');

	}

	/**
	 * @description Test method to test whether a delete is prevented when an envelope has the status of New
	 */
	@IsTest
	private static void allowDelete()
	{
		AW_Envelope__c envelope = insertEnvelope(AW_DAL_Envelope.STATUS_NEW);

		DocumentChecklistItem documentChecklistItem = AW_DAL_TestDataFactory.insertDocumentCheckListItem(envelope.Id);

		Test.startTest();

		Boolean successful = CMN_DAL_SObjectDomain.deleteDBObject(documentChecklistItem, true).success;

		Test.stopTest();

		System.assertEquals(true, successful, 'Delete was allowed as expected');
	}

	/**
	 * @description Test method to test whether a insert is prevented when an envelope has the status of New
	 */
	@IsTest
	private static void allowInsert()
	{
		AW_Envelope__c envelope = insertEnvelope(AW_DAL_Envelope.STATUS_NEW);

		DocumentChecklistItem newDocumentChecklistItem = new DocumentChecklistItem();

		newDocumentChecklistItem.ParentRecordId = envelope.Id;

		newDocumentChecklistItem.Name = CMN_DAL_SObjectDomain.generateRandomName();

		Test.startTest();

		Boolean successful = CMN_DAL_SObjectDomain.insertDBObject(newDocumentChecklistItem, true).success;

		Test.stopTest();

		System.assertEquals(true, successful, 'Insert was allowed as expected.');
	}

	/**
	 * @description Test to see that nothing happens for items parented to object other than an envelope
	 */
	@IsTest
	private static void ignoreItemsThatAreNotOnAnEnvelope()
	{
		CMN_Foobar__c newFoo = new CMN_Foobar__c();

		CMN_DAL_SObjectDomain.insertDBObject(newFoo);

		DocumentChecklistItem documentChecklistItem = AW_DAL_TestDataFactory.insertDocumentCheckListItem(newFoo.Id);

		Test.startTest();

		Boolean successful = CMN_DAL_SObjectDomain.deleteDBObject(documentChecklistItem, false).success;

		Test.stopTest();

		System.assertEquals(true, successful, 'Delete was allowed as expected');
	}

	/**
	 * @description Test method to test whether an DocumentChecklistItem created by Personal Assistant is linked to Envelope Owner
	 */
	@IsTest
	private static void updateDocumentChecklistItemWithEnvelopeOwner()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		Account envelopeParentAccount;
		AW_Envelope__c parentEnvelope;

		System.runAs(adviser)
		{
			envelopeParentAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
			parentEnvelope = AW_DAL_TestDataFactory.insertEnvelopeWithActiveAccount(envelopeParentAccount.Id);
		}

		User personalAssistant = AW_DAL_User.findActivePersonalAssistant();

		DocumentChecklistItem newDocumentChecklistItem;

		System.runAs(personalAssistant)
		{
			Test.startTest();
			newDocumentChecklistItem = AW_DAL_TestDataFactory.insertDocumentCheckListItem(parentEnvelope.Id);
			Test.stopTest();
		}

		parentEnvelope = AW_DAL_Envelope.findById(parentEnvelope.Id);
		newDocumentChecklistItem = AW_DAL_DocumentChecklistItem.findById(newDocumentChecklistItem.Id);
		System.assertEquals(newDocumentChecklistItem.OwnerId, parentEnvelope.OwnerId, ERROR_OWNER_NOT_SAME);
	}
}