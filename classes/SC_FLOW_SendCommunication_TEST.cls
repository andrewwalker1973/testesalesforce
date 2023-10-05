/**
 * @description Test Class for SC_FLOW_SendCommunication
 *
 * @see SC_FLOW_SendCommunication @story ST-146941, ST-257265
 *
 * @author jason.van.beukering@accenture.com aakriti.a.goyal@accenture.com
 *
 * @date May 2022, July 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
public inherited sharing class SC_FLOW_SendCommunication_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;
	private static final Integer INT_THREE = 3;

	/**
	 * @description Creates recipient objects for email etc. population
	 *
	 * @param numberOfRecipients Number of recipients to create
	 *
	 * @return List of CMN_DTO_CommunicationRecipients
	 */
	private static List<CMN_DTO_CommunicationRecipients> createRecipients(Integer numberOfRecipients)
	{
		List<CMN_DTO_CommunicationRecipients> recipients = new List<CMN_DTO_CommunicationRecipients>();

		for(Integer i = 0; i < numberOfRecipients; i++)
		{
			CMN_DTO_CommunicationRecipients communicationRecipients = new CMN_DTO_CommunicationRecipients();
			communicationRecipients.recipientFirstName = CMN_DAL_SObjectDomain.generateRandomName();
			communicationRecipients.recipientSurname = CMN_DAL_SObjectDomain.generateRandomName();
			communicationRecipients.recipientFullName = communicationRecipients.recipientFirstName + communicationRecipients.recipientSurname;
			communicationRecipients.emailAddress = CMN_DAL_OrgWideEmailAddress.getRandomItem()?.Address;
			communicationRecipients.recipientType = SC_FLOW_SendCommunication.RECIPIENT_ROLE.values().iterator().next();
			recipients.add(communicationRecipients);
		}

		return recipients;
	}

	/**
	 * @description Reduces list of DTO response objects to whether they contain any errors.
	 *
	 * @param dtoResponses List of DTO responses from an API handler
	 *
	 * @return {Boolean} If any errors are present in the responses
	 */
	@TestVisible
	private static Boolean hasErrorsInResponse(List<SC_FLOW_SendCommunication.DTO_Response> dtoResponses)
	{
		Boolean hasError = false;

		for(SC_FLOW_SendCommunication.DTO_Response dtoResponse : dtoResponses)
		{
			if(!dtoResponse.success)
			{
				hasError = true;
				break;
			}
		}

		return hasError;
	}

	/**
	 * @description Create data required for the unit test
	 */
	@TestSetup
	private static void setup()
	{
		Account account = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		Case caseRecord = SC_DAL_DataFactory.createCase(NUMBER_OF_ITEMS_TO_CREATE, account.Id).iterator().next();
		SC_DAL_DataFactory.insertDocumentCheckListItems(caseRecord.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		List<CMN_CommunicationTemplate__c> documentsCommunicationTemplates = CMN_DAL_DataFactory.createCommunicationTemplate
				(
						NUMBER_OF_ITEMS_TO_CREATE,
						SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME,
						SC_API_SendCommunication.SERVICE_NAME
				);

		CMN_CommunicationTemplateObjectDef__c caseTemplateObjectDefinition =
				CMN_DAL_DataFactory.createCommunicationTemplateObjectDefinition(SC_DAL_Case.OBJECT_NAME);
		CMN_CommunicationTemplateObjectDef__c documentTemplateObjectDefinition =
				CMN_DAL_DataFactory.createCommunicationTemplateObjectDefinition(SC_DAL_DocumentChecklistItem.OBJECT_NAME);
		CMN_DAL_DataFactory.createCommTemplateObjectMap(documentsCommunicationTemplates.iterator().next().Id, caseTemplateObjectDefinition.Id);
		CMN_DAL_DataFactory.createCommTemplateObjectMap(documentsCommunicationTemplates.iterator().next().Id, documentTemplateObjectDefinition.Id);
		CMN_DAL_DataFactory.createCommunicationTemplateObjectField(SC_DAL_Case.FIELD_WORKFLOW_CASE_NUMBER, caseTemplateObjectDefinition.Id);
		CMN_DAL_DataFactory.createCommunicationTemplateAttachments(documentsCommunicationTemplates.iterator().next().Id, NUMBER_OF_ITEMS_TO_CREATE);
		SC_DAL_DataFactory.createInsurancePolicies(NUMBER_OF_ITEMS_TO_CREATE, account.Id);
	}

	/**
	 * @description Contains the base code required to run each test with variants in parameter list
	 *
	 * @param templateId Template Id
	 * @param numberOfRecords Number of request to be created
	 * @param recordId Case Id
	 * @param numberOfRecipients Number of recipient email addresses to generate
	 * @param selectedAttachments List of communication template attachments
	 * @param replyWithDocuments Boolean to indicate whether to set replyWithDocuments in template request
	 * @param passwordProtection Boolean to indicate whether to set passwordProtection in template request
	 * @param parameterIds List of Ids to handle retrieval
	 * @param includeInvalidRequest Boolean to indicate if an invalid request to be added to the collection
	 *
	 * @return List of DTO Responses
	 */
	public static List<SC_FLOW_SendCommunication.DTO_Response> communicationTemplateDataTest(Id templateId,
			Integer numberOfRecords,
			Id recordId,
			Integer numberOfRecipients,
			List<CMN_DTO_CommunicationAttachment> selectedAttachments,
			Boolean replyWithDocuments,
			Boolean passwordProtection,
			List<Id> parameterIds,
			Boolean includeInvalidRequest)
	{
		List<CMN_DTO_CommunicationTemplate> dtoRequests = new List<CMN_DTO_CommunicationTemplate>();
		for(Integer i = 0; i < numberOfRecords; i++)
	{
		CMN_DTO_CommunicationTemplate communicationData = new CMN_DTO_CommunicationTemplate();

		communicationData.templateId = templateId;
		communicationData.recordId = recordId;
		communicationData.recipients = new List<CMN_DTO_CommunicationRecipients>(createRecipients(numberOfRecipients));
		communicationData.selectedAttachments = selectedAttachments;
		communicationData.otherComments = CMN_DAL_SObjectDomain.generateRandomDescription();
		communicationData.replyWithDocuments = replyWithDocuments;
		communicationData.passwordProtection = passwordProtection;
		communicationData.parameterIds = parameterIds;

			dtoRequests.add(communicationData);
		}

		if(includeInvalidRequest)
		{
			dtoRequests.iterator().next().recipients = new List<CMN_DTO_CommunicationRecipients>();
		}

		Test.startTest();

		List<SC_FLOW_SendCommunication.DTO_Response> dtoResponses = SC_FLOW_SendCommunication.sendCommunication(dtoRequests);

		Test.stopTest();

		System.assertNotEquals(true, dtoResponses.isEmpty(), 'No responses received');
		System.assertEquals(dtoRequests.size(), dtoResponses.size(), 'The number of responses received is incorrect');

		return dtoResponses;
	}

	/**
	 * @description Confirm that call is aborted when the template data passed is incorrect
	 */
	@IsTest
	private static void abortedCall()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		System.assert(caseRecord != null, 'Case Record not found');
		List<SC_FLOW_SendCommunication.DTO_Response> dtoResponses = communicationTemplateDataTest(template.Id, NUMBER_OF_ITEMS_TO_CREATE, caseRecord.Id, null, null,
				false, false, null, false);
		System.assertEquals(true, hasErrorsInResponse(dtoResponses), 'Requests did not fail as expected.');
	}

	/**
	 * @description Check to see if call is successful when password is true and Identification Number is null,
	 * since password is generated using other information.
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	private static void successfulPasswordTrueIdNull()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		update new Account(Id = caseRecord.AccountId, AW_IdentificationNumber__pc = null);
		testPassedPasswordTrue(caseRecord);
	}

	/**
	 * @description Check to see if call fails when password is true and Identification Number + Date of Birth is null,
	 * since password cannot be generated using other information.
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	private static void failedNoPasswordIdAndBirthDateNull()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		update new Account(Id = caseRecord.AccountId, AW_IdentificationNumber__pc = null, PersonBirthdate = null);
		testFailedPasswordTrue(caseRecord);
	}

	/**
	 * @description Checks for errors when the API call returns an error response
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	private static void failed()
	{
		CMN_API_HttpBaseOutboundMock.returnErrorResponse = true;
		Account account = AW_DAL_TestDataFactory.createBusinessAccounts(AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		Case caseRecord = SC_DAL_DataFactory.createCase(NUMBER_OF_ITEMS_TO_CREATE, account.Id).iterator().next();
		testFailedPasswordTrue(caseRecord);
	}

	/**
	 * @description Checks that the password creation does not fail when Account/Case contains required information
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	private static void successfulPasswordAccountBusinessMaster()
	{
		Account account = AW_DAL_TestDataFactory.createBusinessAccounts(AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		Case caseRecord = SC_DAL_DataFactory.createCase(NUMBER_OF_ITEMS_TO_CREATE, account.Id).iterator().next();
		testPassedPasswordTrue(caseRecord);
	}

	/**
	 * @description Checks that the password creation does not fail when Account Identification type is Passport
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	private static void successfulPasswordPassportType()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		update new Account(Id = caseRecord.AccountId, AW_IdentificationType__pc = AW_DAL_Account.PICK_PASSPORT_TYPE);
		testPassedPasswordTrue(caseRecord);
	}

	/**
	 * @description Contains test asserts for unsuccessfully calling the Flow with the password requirement true
	 *
	 * @param caseRecord Case record to test
	 */
	private static void testFailedPasswordTrue(Case caseRecord)
	{
		System.assert(caseRecord != null, 'Case Record not found');
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		List<SC_FLOW_SendCommunication.DTO_Response> dtoResponses = communicationTemplateDataTest(template.Id, NUMBER_OF_ITEMS_TO_CREATE, caseRecord.Id, 1, null,
				false, true, null, false);
		System.assertEquals(true, hasErrorsInResponse(dtoResponses), 'Requests did not fail as expected.');
	}

	/**
	 * @description Contains test asserts for successfully calling the Flow with the password requirement true
	 *
	 * @param caseRecord Case record to test
	 */
	private static void testPassedPasswordTrue(Case caseRecord)
	{
		System.assert(caseRecord != null, 'Case Record not found');
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		List<SC_FLOW_SendCommunication.DTO_Response> dtoResponses = communicationTemplateDataTest(template.Id, NUMBER_OF_ITEMS_TO_CREATE, caseRecord.Id, 1, null,
				false, true, null, false);
		System.assertEquals(false, hasErrorsInResponse(dtoResponses), 'DTO Response has failed call with following errors: ' + JSON.serialize(dtoResponses));
	}

	/**
	 * @description Check for the flow successfully processing the outstanding documents callout
	 */
	@IsTest
	private static void validateSuccessAndFailureCallouts()
	{
		Account account = SC_DAL_Account.getAll().iterator().next();

		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.findBySelectorClassName(SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME);
		User foundAgent = SC_DAL_User.findRandomActiveAgent();
		List<SC_FLOW_SendCommunication.DTO_Response> dtoResponses;

		account.OwnerId = foundAgent.Id;
		update account;

		SC_ServiceType__c newServiceType = SC_DAL_DataFactory.createServiceTypesWithAssignableValue(NUMBER_OF_ITEMS_TO_CREATE, true).iterator().next();

		System.runAs(foundAgent)
		{
			Case caseRecord = SC_DAL_DataFactory.newCase(account.Id);
			caseRecord.RSC_ServiceType__c = newServiceType.Id;
			insert caseRecord;

			dtoResponses = communicationTemplateDataTest(template.Id, INT_THREE, caseRecord.Id, INT_THREE,
					CMN_DAL_DataFactory.createCommunicationAttachmentDto(CMN_DAL_CommunicationTemplateAttachment.getAll()), true, true, null, true);
		}

		System.assertEquals(INT_THREE, dtoResponses.size(), 'Expected response elements were not sent back for each of the request');
		System.assertEquals(true, hasErrorsInResponse(dtoResponses), 'Expected request was not failed for missing recipient details.');

		List<CMN_CommunicationLog__c> foundLogs = CMN_DAL_CommunicationLog.getAll();
		System.assertEquals(6, foundLogs.size(), 'Expected Communication Log records were not created');

		for(CMN_CommunicationLog__c foundLog : foundLogs)
		{
			System.assertEquals
					(
							SC_FLOW_SendCommunication.RECIPIENT_ROLE.values().iterator().next(),
							foundLog.CMN_Recipients__c,
							'Recipient was not populated properly on communication log.'
					);
		}
	}

	/**
	 * @description Check for the generated initials with various scenarios
	 */
	@IsTest
	private static void generateInitialsForVariousScenarios()
	{
		// Validate the scenario where recipient first name & last name both are provided
		assertInitials('Billy bob', 'thornton', null, null, 'BBT');

		// Validate the scenario where full name is provided
		assertInitials(null, 'thornton', 'billy bob thornton', null, 'BBT');

		// Validate the scenario only surname is provided
		assertInitials(null, 'thornton', null, null, 'T');

		// Validate the scenario only first name is provided
		assertInitials('billy bob', null, null, null, 'BB');

		// Validate the scenario where initials
		assertInitials('Billy bob', 'thornton', 'billy bob thornton', 'abc', 'ABC');
	}

	/**
	 * @description Will check, given the name parts, that initials are composed correctly
	 *
	 * @param firstName The first name of a person
	 * @param surname The surname of a person
	 * @param fullName The full name of a person
	 * @param initials The initials of a person
	 * @param expected The expected initials that should be calculated
	 */
	private static void assertInitials(String firstName, String surname, String fullName, String initials, String expected)
	{
		CMN_DTO_CommunicationRecipients dtoRecipient = new CMN_DTO_CommunicationRecipients();

		dtoRecipient.recipientFirstName = firstName;
		dtoRecipient.recipientSurname = surname;
		dtoRecipient.recipientFullName = fullName;
		dtoRecipient.recipientInitials = initials;

		System.assertEquals(expected, dtoRecipient.initials, 'Initials were not generated properly');
	}
}