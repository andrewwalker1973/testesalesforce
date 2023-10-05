/**
 * @description Test Class for SC_DAL_OutstandingDocumentSelector
 *
 * @see SC_DAL_OutstandingDocumentSelector
 *
 * @author aakriti.a.goyal@accenture.com darrion.james.singh@accenture.com,
 *
 * @date January 2022, May 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class SC_DAL_OutstandingDocumentSelector_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description Creates the data required for the tests
	 */
	@TestSetup
	private static void setup()
	{
		Account account = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		Case caseRecord = SC_DAL_DataFactory.createCase(NUMBER_OF_ITEMS_TO_CREATE, account.Id).iterator().next();
		SC_DAL_DataFactory.insertDocumentCheckListItems(caseRecord.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		List<CMN_CommunicationTemplate__c> cppCommunicationTemplates =
				CMN_DAL_DataFactory.createCommunicationTemplate(NUMBER_OF_ITEMS_TO_CREATE, SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME);

		CMN_CommunicationTemplateObjectDef__c caseObjectDefinition =
				CMN_DAL_DataFactory.createCommunicationTemplateObjectDefinition(SC_DAL_Case.OBJECT_NAME);
		CMN_DAL_DataFactory.createCommTemplateObjectMap(cppCommunicationTemplates.iterator().next().Id, caseObjectDefinition.Id);

		CMN_CommunicationTemplateObjectDef__c insurancePolicyObjectDefinition =
				CMN_DAL_DataFactory.createCommunicationTemplateObjectDefinition(SC_DAL_DocumentChecklistItem.OBJECT_NAME);
		CMN_DAL_DataFactory.createCommTemplateObjectMap(cppCommunicationTemplates.iterator().next().Id, insurancePolicyObjectDefinition.Id);

		SC_DAL_DataFactory.insertAssociatedContracts(caseRecord.Id, 1, null,
				SC_DAL_DataFactory.createInsurancePolicies(NUMBER_OF_ITEMS_TO_CREATE, account.Id).iterator().next().Id);

		CMN_DAL_DataFactory.createCommunicationTemplateAttachments(cppCommunicationTemplates.iterator().next().Id, NUMBER_OF_ITEMS_TO_CREATE);
	}

	/**
	 * @description Checks the the selector class is able to query the data required by a template
	 */
	@IsTest
	private static void singlePolicy()
	{
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		InsurancePolicy insurancePolicy = SC_DAL_InsurancePolicy.getAll().iterator().next();

		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData cmnCommunicationDataWrapper = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		cmnCommunicationDataWrapper.emailType = template.CMN_Code__c;
		cmnCommunicationDataWrapper.workType = CMN_DAL_SObjectDomain.generateRandomName();
		cmnCommunicationDataWrapper.recipientRole = CMN_DAL_SObjectDomain.generateRandomName();
		cmnCommunicationDataWrapper.templateId = template.Id;
		cmnCommunicationDataWrapper.objectId = caseRecord.Id;
		cmnCommunicationDataWrapper.parameterIds = new List<Id> {insurancePolicy.Id};
		cmnCommunicationDataWrapper.otherComments = CMN_DAL_SObjectDomain.generateRandomName();
		cmnCommunicationDataWrapper.attachments =
				CMN_DAL_DataFactory.createCommunicationAttachmentDto(CMN_DAL_CommunicationTemplateAttachment.getAll());

		Test.startTest();
		List<CMN_DTO_SendCommunicationRequest.DTO_Document> documents =
				CMN_DAL_BaseTemplateSelector.getData(template.CMN_SelectorClassName__c, cmnCommunicationDataWrapper);
		Test.stopTest();

		System.assertNotEquals(null, documents, 'Document object not created');
		System.assert(!documents.isEmpty(), 'Document object not created');
	}
}