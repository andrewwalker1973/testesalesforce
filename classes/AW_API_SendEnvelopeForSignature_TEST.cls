/**
 * @description Test class for AW_API_SendEnvelopeForSignature
 *
 * @see AW_API_SendEnvelopeForSignature
 *
 * @author Accenture, vishakha.saini@accenture.com
 *
 * @date May 2021, February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_API_SendEnvelopeForSignature_TEST
{
	private static final Integer NUM_ITEMS_TO_CREATE = 1;

	/**
	 * @description Emulates a successful call, confirms envelope status was correctly set and checks that the envelope was created on Business Account.
	 */
	@IsTest
	private static void successfulCallForEnvelopeOnBusinessAccount()
	{
		AW_Envelope__c newEnvelopeOnBusinessAccount;
		Account newBusinessAccount;
		User adviser = AW_DAL_User.findRandomActiveAdviser();
		System.runAs(adviser)
		{
			List<Account> businessAccounts = AW_DAL_TestDataFactory.createBusinessAccounts();
			newBusinessAccount = businessAccounts.iterator().next();
			newEnvelopeOnBusinessAccount = AW_DAL_TestDataFactory.insertEnvelopeWithActiveAccount(newBusinessAccount.Id);
			DocumentChecklistItem documentChecklistItem = AW_DAL_TestDataFactory.insertDocumentCheckListItem(newEnvelopeOnBusinessAccount.Id);
			AW_DAL_TestDataFactory.createContentVersions(documentChecklistItem.Id, NUM_ITEMS_TO_CREATE);
			Contact contact = AW_DAL_TestDataFactory.createContact(newBusinessAccount.Id);
			AW_DAL_TestDataFactory.createEnvelopeRole(contact.Id, newEnvelopeOnBusinessAccount.Id);
		}
		successfulCall(newEnvelopeOnBusinessAccount);
	}

	/**
	 * @description Emulates a successful call, confirms envelope status was correctly set and checks that the envelope was created on Person Account.
	 */
	@IsTest
	private static void successfulCallForEnvelopeOnPersonAccount()
	{
		AW_Envelope__c newEnvelopeOnPersonAccount;
		Account newPersonAccount;
		User adviser = AW_DAL_User.findRandomActiveAdviser();
		System.runAs(adviser)
		{
			List<Account> personAccounts = AW_DAL_TestDataFactory.createClientAccount();
			newPersonAccount = personAccounts.iterator().next();
			newEnvelopeOnPersonAccount = AW_DAL_TestDataFactory.insertEnvelopeWithActiveAccount(newPersonAccount.Id);
			DocumentChecklistItem documentChecklistItem = AW_DAL_TestDataFactory.insertDocumentCheckListItem(newEnvelopeOnPersonAccount.Id);
			AW_DAL_TestDataFactory.createContentVersions(documentChecklistItem.Id, NUM_ITEMS_TO_CREATE);
		}
		successfulCall(newEnvelopeOnPersonAccount);
	}

	/**
	 * @description Emulates a successful call, confirms envelope status was correctly set and checks that the envelope was created on Business Lead.
	 */
	@IsTest
	private static void successfulCallForEnvelopeOnBusinessLead()
	{
		AW_Envelope__c newEnvelopeOnBusinessLead;
		Lead newBusinessLead;
		User adviser = AW_DAL_User.findRandomActiveAdviser();
		System.runAs(adviser)
		{
			List<Lead> businessLead = AW_DAL_TestDataFactory.createBusinessLead(NUM_ITEMS_TO_CREATE, adviser.Id);
			newBusinessLead = businessLead.iterator().next();
			newEnvelopeOnBusinessLead = AW_DAL_TestDataFactory.insertEnvelope();
			newEnvelopeOnBusinessLead.AW_LeadAndReferral__c = newBusinessLead.Id;
			update newEnvelopeOnBusinessLead;
			DocumentChecklistItem documentChecklistItem = AW_DAL_TestDataFactory.insertDocumentCheckListItem(newEnvelopeOnBusinessLead.Id);
			AW_DAL_TestDataFactory.createContentVersions(documentChecklistItem.Id, NUM_ITEMS_TO_CREATE);
		}
		successfulCall(newEnvelopeOnBusinessLead);
	}

	/**
	 * @description Emulates a successful call, confirms envelope status was correctly set and checks that the envelope was created on Client Lead.
	 */
	@IsTest
	private static void successfulCallForEnvelopeOnClientLead()
	{
		AW_Envelope__c newEnvelopeOnClientLead;
		Lead newClientLead;
		User adviser = AW_DAL_User.findRandomActiveAdviser();
		System.runAs(adviser)
		{
			List<Lead> clientLead = AW_DAL_TestDataFactory.createLeads
					(
							AW_DAL_Lead.RECORDTYPE_DEFAULT,
							NUM_ITEMS_TO_CREATE,
							adviser.Id,
							AW_DAL_Lead.IDENTIFICATION_TYPE_PASSPORT
					);
			newClientLead = clientLead.iterator().next();
			newEnvelopeOnClientLead = AW_DAL_TestDataFactory.insertEnvelope();
			newEnvelopeOnClientLead.AW_LeadAndReferral__c = newClientLead.Id;
			update newEnvelopeOnClientLead;
			DocumentChecklistItem documentChecklistItem = AW_DAL_TestDataFactory.insertDocumentCheckListItem(newEnvelopeOnClientLead.Id);
			AW_DAL_TestDataFactory.createContentVersions(documentChecklistItem.Id, NUM_ITEMS_TO_CREATE);
		}
		successfulCall(newEnvelopeOnClientLead);
	}

	/**
	 * @description Emulates a successful call, confirms envelope status was correctly set and checks that the envelope was created on Business Opportunity.
	 */
	@IsTest
	private static void successfulCallForEnvelopeOnBusinessOpportunity()
	{
		AW_Envelope__c newEnvelopeOnBusinessOpp;
		Account newBusinessAccount;
		Opportunity newBusinessOpportunity;
		User adviser = AW_DAL_User.findRandomActiveAdviser();
		System.runAs(adviser)
		{
			List<Account> businessAccount = AW_DAL_TestDataFactory.createBusinessAccounts();
			newBusinessAccount = businessAccount.iterator().next();
			List<Opportunity> businessOpportunity = AW_DAL_TestDataFactory.createDefaultOpportunities(newBusinessAccount, NUM_ITEMS_TO_CREATE);
			newBusinessOpportunity = businessOpportunity.iterator().next();
			newEnvelopeOnBusinessOpp = AW_DAL_TestDataFactory.insertEnvelope();
			newEnvelopeOnBusinessOpp.AW_Opportunity__c = newBusinessOpportunity.Id;
			update newEnvelopeOnBusinessOpp;
			DocumentChecklistItem documentChecklistItem = AW_DAL_TestDataFactory.insertDocumentCheckListItem(newEnvelopeOnBusinessOpp.Id);
			AW_DAL_TestDataFactory.createContentVersions(documentChecklistItem.Id, NUM_ITEMS_TO_CREATE);
			Contact contact = AW_DAL_TestDataFactory.createContact(newBusinessAccount.Id);
			AW_DAL_TestDataFactory.createEnvelopeRole(contact.Id, newEnvelopeOnBusinessOpp.Id);
		}
		successfulCall(newEnvelopeOnBusinessOpp);
	}

	/**
	 * @description Emulates a successful call, confirms envelope status was correctly set and checks that the envelope was created on Person Opportunity.
	 */
	@IsTest
	private static void successfulCallForEnvelopeOnPersonOpportunity()
	{
		AW_Envelope__c newEnvelopeOnPersonOpp;
		Account newPersonAccount;
		Opportunity newPersonOpportunity;
		User adviser = AW_DAL_User.findRandomActiveAdviser();
		System.runAs(adviser)
		{
			List<Account> personAccount = AW_DAL_TestDataFactory.createClientAccount();
			newPersonAccount = personAccount.iterator().next();
			List<Opportunity> personOpportunity = AW_DAL_TestDataFactory.createDefaultOpportunities(newPersonAccount, NUM_ITEMS_TO_CREATE);
			newPersonOpportunity = personOpportunity.iterator().next();
			newEnvelopeOnPersonOpp = AW_DAL_TestDataFactory.insertEnvelope();
			newEnvelopeOnPersonOpp.AW_Opportunity__c = newPersonOpportunity.Id;
			update newEnvelopeOnPersonOpp;
			DocumentChecklistItem documentChecklistItem = AW_DAL_TestDataFactory.insertDocumentCheckListItem(newEnvelopeOnPersonOpp.Id);
			AW_DAL_TestDataFactory.createContentVersions(documentChecklistItem.Id, NUM_ITEMS_TO_CREATE);
		}
		successfulCall(newEnvelopeOnPersonOpp);
	}

	/**
	 * @description Emulates a successful call, confirms envelope status was correctly set.
	 *
	 * @param envelope Envelope record
	 */
	private static void successfulCall(AW_Envelope__c envelope)
	{
		String envelopeStatusBeforeTest = envelope.AW_Status__c;

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_SendEnvelopeForSignature.SERVICE_NAME, envelope.Id);

		//Check call was successful
		CMN_API_RestBaseOutboundTestHelper.successfulCall(new List<CMN_WebserviceCallQueue__c>
		{
				queueItem
		});

		//Now check envelope status
		envelope = AW_DAL_Envelope.findById(envelope.Id);

		String envelopeStatusAfterTest = envelope.AW_Status__c;

		System.assertNotEquals(envelopeStatusBeforeTest, envelopeStatusAfterTest, 'Status did not change for Envelope');
		System.assertEquals(AW_DAL_Envelope.STATUS_SENT_FOR_SIGNING, envelopeStatusAfterTest, 'Status was not set correctly for Envelope');
	}

	/**
	 * @description Check that the service abort if the Id provided does not find an envelope
	 *
	 * @see AW_API_SendEnvelopeForSignature.abortRequest
	 */
	@IsTest
	private static void abortedCall()
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_SendEnvelopeForSignature.SERVICE_NAME, UserInfo.getUserId());
		CMN_API_RestBaseOutboundTestHelper.abortedCall(new List<CMN_WebserviceCallQueue__c>
		{
				queueItem
		});
	}
}