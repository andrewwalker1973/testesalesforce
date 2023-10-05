/**
 * @description Test class for CMN_DAL_BaseTemplateSelector
 *
 * @see CMN_DAL_BaseTemplateSelector @story ST-146934
 *
 * @author jason.van.beukering@accenture.com darrion.james.singh@accenture.com
 *
 * @date September 2021, May 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_DAL_BaseTemplateSelector_TEST
{
	private static final String CLASS_NAME = CMN_DAL_Foobar.class.getName();
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description Create data required for the unit test
	 */
	@TestSetup
	private static void setup()
	{
		Account account = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();

		Case caseRecord = SC_DAL_DataFactory.createCase(NUMBER_OF_ITEMS_TO_CREATE, account.Id).iterator().next();

		SC_DAL_DataFactory.insertAssociatedContracts(caseRecord.Id, 1, null,
				SC_DAL_DataFactory.createInsurancePolicies(NUMBER_OF_ITEMS_TO_CREATE, account.Id).iterator().next().Id);

		SC_DAL_DataFactory.insertDocumentCheckListItems(caseRecord.Id, NUMBER_OF_ITEMS_TO_CREATE);

		List<CMN_CommunicationTemplate__c> communicationTemplates =
				CMN_DAL_DataFactory.createCommunicationTemplate(NUMBER_OF_ITEMS_TO_CREATE, SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME);

		CMN_CommunicationTemplateObjectDef__c caseTemplateObjectDefinition =
				CMN_DAL_DataFactory.createCommunicationTemplateObjectDefinition(SC_DAL_Case.OBJECT_NAME);
		CMN_DAL_DataFactory.createCommTemplateObjectMap(communicationTemplates.iterator().next().Id, caseTemplateObjectDefinition.Id);
		CMN_DAL_DataFactory.createCommunicationTemplateObjectField(SC_DAL_Case.FIELD_SUB_STATUS, caseTemplateObjectDefinition.Id);
		CMN_DAL_DataFactory.createCommunicationTemplateObjectField(SC_DAL_Case.FIELD_IS_RELATED, caseTemplateObjectDefinition.Id);
		CMN_DAL_DataFactory.createCommunicationTemplateObjectField(SC_DAL_Case.FIELD_CREATED_DATE, caseTemplateObjectDefinition.Id);

		CMN_CommunicationTemplateObjectDef__c accountTemplateObjectDefinition =
				CMN_DAL_DataFactory.createCommunicationTemplateObjectDefinition(SC_DAL_Account.OBJECT_NAME);
		CMN_DAL_DataFactory.createCommTemplateObjectMap(communicationTemplates.iterator().next().Id, accountTemplateObjectDefinition.Id);
		CMN_DAL_DataFactory.createCommunicationTemplateObjectField(SC_DAL_Account.FIELD_PERSON_BIRTHDATE, accountTemplateObjectDefinition.Id);

		CMN_CommunicationTemplateObjectDef__c documentChecklistItemObjectDefinition =
				CMN_DAL_DataFactory.createCommunicationTemplateObjectDefinition(SC_DAL_DocumentChecklistItem.OBJECT_NAME);

		CMN_DAL_DataFactory.createCommTemplateObjectMap(communicationTemplates.iterator().next().Id, documentChecklistItemObjectDefinition.Id);

		CMN_CommunicationTemplateObjectDef__c freeTextObjectDefinition = CMN_DAL_DataFactory.createCommunicationTemplateObjectDefinition(
				SC_DAL_OutstandingDocumentSelector.FREE_TEXTS);
		CMN_DAL_DataFactory.createCommTemplateObjectMap(communicationTemplates.iterator().next().Id, freeTextObjectDefinition.Id);
		CMN_DAL_DataFactory.createCommunicationTemplateObjectField(SC_DAL_OutstandingDocumentSelector.FREE_TXT_FMT, freeTextObjectDefinition.Id);
		CMN_DAL_DataFactory.createCommunicationTemplateObjectField(SC_DAL_OutstandingDocumentSelector.FREE_TXT_TX, freeTextObjectDefinition.Id);

		CMN_CommunicationTemplateObjectDef__c contractsObjectDefinition = CMN_DAL_DataFactory.createCommunicationTemplateObjectDefinition(
				SC_DAL_OutstandingDocumentSelector.CONTRACTS_OBJECT_DEFINITION_API_NAME);
		CMN_DAL_DataFactory.createCommTemplateObjectMap(communicationTemplates.iterator().next().Id, contractsObjectDefinition.Id);
		CMN_DAL_DataFactory.createCommunicationTemplateObjectField(SC_DAL_OutstandingDocumentSelector.CONTRACT_NUMBER_TEMPLATE_OBJECT_FIELD_API_NAME,
				contractsObjectDefinition.Id);

		CMN_DAL_DataFactory.createCommunicationTemplateAttachments(communicationTemplates.iterator().next().Id, NUMBER_OF_ITEMS_TO_CREATE);
	}

	/**
	 * @description Check to see if records are successfully queried for the objects & fields
	 */
	@IsTest
	private static void querySobjectRecords()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();

		CMN_DAL_BaseTemplateSelector.CMN_TEST_BaseTemplate baseTemplate = new CMN_DAL_BaseTemplateSelector.CMN_TEST_BaseTemplate();

		CMN_SOQL_Query.AndCondition andConditionCases = new CMN_SOQL_Query.AndCondition();
		andConditionCases.add(new CMN_SOQL_Query.FieldCondition(SC_DAL_Case.FIELD_CASE_ID, CMN_SOQL_Query.Operator.EQUALS, caseRecord.Id));

		Test.startTest();

		baseTemplate.getMappingData(template.Id);
		List<SObject> cases = baseTemplate.queryRecords(SC_DAL_Case.OBJECT_NAME, andConditionCases);

		Test.stopTest();

		System.assertNotEquals(null, cases, 'Query should return the specified SObject records.');
		System.assertEquals(NUMBER_OF_ITEMS_TO_CREATE, cases.size(), 'Query should return the specified number of the SObject records.');
		System.assert(baseTemplate.getTemplateData().isEmpty());
	}

	/**
	 * @description Check to see if element was successfully created with the retrieved data
	 */
	@IsTest
	private static void getElementData()
	{
		List<Case> caseRecords = SC_DAL_Case.getAll();
		List<Account> accountRecords = SC_DAL_Account.getAll();
		for(Case aCase : caseRecords)
		{
			aCase.RSC_IsRelated__c = false;
			aCase.SC_SubStatus__c = SC_DAL_Case.SUB_STATUS_ON_HOLD;
		}
		CMN_DAL_SObjectDomain.updateDBObjects(caseRecords);

		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();

		CMN_DAL_BaseTemplateSelector.CMN_TEST_BaseTemplate baseTemplate = new CMN_DAL_BaseTemplateSelector.CMN_TEST_BaseTemplate();

		Test.startTest();

		baseTemplate.getMappingData(template.Id);
		CMN_DTO_SendCommunicationRequest.DTO_Element caseElement =
				baseTemplate.createElements(CMN_DAL_SObjectDomain.generateRandomName(), SC_DAL_Case.OBJECT_NAME, caseRecords);

		CMN_DTO_SendCommunicationRequest.DTO_Element accountElement =
				baseTemplate.createElements(CMN_DAL_SObjectDomain.generateRandomName(), SC_DAL_Account.OBJECT_NAME, accountRecords);

		Test.stopTest();

		System.assertNotEquals(null, caseElement, 'Element was not created successfully.');
		System.assertNotEquals(null, accountElement, 'Element was not created successfully.');
	}

	/**
	 * @description Check to see if element was successfully created with the retrieved data
	 */
	@IsTest
	private static void getElementsFromSelector()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData communicationData = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		communicationData.templateId = template.Id;
		communicationData.objectId = caseRecord.Id;
		communicationData.parameterIds = new List<Id>();

		Test.startTest();

		List<CMN_DTO_SendCommunicationRequest.DTO_Document> elements =
				CMN_DAL_BaseTemplateSelector.getData(SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME, communicationData);

		Test.stopTest();

		System.assertNotEquals(null, elements, 'Elements were not created successfully.');
	}

	/**
	 * @description Check to see if the exception was thrown if selector class is some random text
	 */
	@IsTest
	private static void throwExceptionForRandomSelectorName()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData communicationData = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		communicationData.templateId = template.Id;
		communicationData.objectId = caseRecord.Id;
		communicationData.parameterIds = new List<Id>();

		String selectorClassName = CMN_DAL_SObjectDomain.generateRandomName();
		try
		{
			Test.startTest();

			CMN_DAL_BaseTemplateSelector.getData(selectorClassName, communicationData);

			Test.stopTest();
		}
		catch(System.TypeException typeException)
		{
			System.assertEquals(typeException.getMessage(), 'No Accessible Class exists for Name: ' + selectorClassName);
		}
	}

	/**
	 * @description Check to see if the exception was thrown if selector class is invalid
	 */
	@IsTest
	private static void throwExceptionForInvalidSelector()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData communicationData = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		communicationData.templateId = template.Id;
		communicationData.objectId = caseRecord.Id;
		communicationData.parameterIds = new List<Id>();

		try
		{
			Test.startTest();

			CMN_DAL_BaseTemplateSelector.getData(CLASS_NAME, communicationData);

			Test.stopTest();
		}
		catch(System.TypeException typeException)
		{
			System.assertEquals
					(
							typeException.getMessage(),
							'Invalid Class Type for Name: ' + CLASS_NAME + ', a child class for CMN_DAL_BaseTemplateSelector is expected'
					);
		}
	}

	/**
	 * @description Check to see if the exception was thrown if the provided template id is blank
	 */
	@IsTest
	private static void throwExceptionForBlankTemplateId()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData communicationData = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		communicationData.templateId = null;
		communicationData.objectId = caseRecord.Id;
		communicationData.parameterIds = new List<Id>();
		try
		{
			Test.startTest();
			CMN_DAL_BaseTemplateSelector.getData(SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME, communicationData);
			Test.stopTest();
		}
		catch(System.IllegalArgumentException argumentException)
		{
			System.assertEquals(argumentException.getMessage(), 'No Template Id provided.');
		}
	}

	/**
	 * @description Check to see if the exception was thrown if the template is not found
	 */
	@IsTest
	private static void throwExceptionIfNoTemplateFound()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData communicationData = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		communicationData.templateId = UserInfo.getUserId();
		communicationData.objectId = caseRecord.Id;
		communicationData.parameterIds = new List<Id>();
		try
		{
			Test.startTest();
			CMN_DAL_BaseTemplateSelector.getData(SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME, communicationData);
			Test.stopTest();
		}
		catch(System.IllegalArgumentException argumentException)
		{
			System.assertEquals(argumentException.getMessage(), 'No template found for the Id given');
		}
	}

	/**
	 * @description No Object definitions
	 */
	@IsTest
	private static void constructElementNoObjectDef()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData communicationData = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		communicationData.templateId = template.Id;
		communicationData.objectId = caseRecord.Id;
		communicationData.parameterIds = new List<Id>();

		Test.startTest();
		CMN_DAL_SObjectDomain.deleteDBObjects(CMN_DAL_CommTemplateObjectDefinition.getAll());
		List<CMN_DTO_SendCommunicationRequest.DTO_Document> elements = CMN_DAL_BaseTemplateSelector.getData(SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME,
				communicationData);
		Test.stopTest();
		System.assert(!elements.isEmpty(), 'Empty document list returned.');
	}

	/**
	 * @description No Object definitions
	 */
	@IsTest
	private static void constructElementNoContracts()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData communicationData = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		communicationData.templateId = template.Id;
		communicationData.objectId = caseRecord.Id;
		communicationData.parameterIds = new List<Id>();

		Test.startTest();
		CMN_DAL_SObjectDomain.deleteDBObjects(SC_DAL_AssociatedContract.getAll());
		List<CMN_DTO_SendCommunicationRequest.DTO_Document> elements = CMN_DAL_BaseTemplateSelector.getData(SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME,
				communicationData);
		Test.stopTest();
		System.assert(!elements.isEmpty(), 'Empty document list returned.');
	}

	/**
	 * @description No Object definitions
	 */
	@IsTest
	private static void constructElementNoObjectDefCode()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData communicationData = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		communicationData.templateId = template.Id;
		communicationData.objectId = caseRecord.Id;
		communicationData.parameterIds = new List<Id>();

		Test.startTest();
		CMN_CommunicationTemplateObjectDef__c cmnCommunicationTemplateObjectDef =
		[
				SELECT CMN_Code__c
				FROM CMN_CommunicationTemplateObjectDef__c
				WHERE CMN_ApiName__c = :SC_DAL_OutstandingDocumentSelector.CONTRACTS_OBJECT_DEFINITION_API_NAME
		];
		cmnCommunicationTemplateObjectDef.CMN_Code__c = CMN_UTIL_String.EMPTY;
		update cmnCommunicationTemplateObjectDef;

		List<CMN_DTO_SendCommunicationRequest.DTO_Document> elements = CMN_DAL_BaseTemplateSelector.getData(SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME,
				communicationData);
		Test.stopTest();
		System.assert(!elements.isEmpty(), 'Empty document list returned.');
	}

	/**
	 * @description No Object definitions
	 */
	@IsTest
	private static void constructElementNoRecords()
	{
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData communicationData = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		communicationData.templateId = template.Id;
		communicationData.objectId = SC_DAL_DataFactory.createCase(NUMBER_OF_ITEMS_TO_CREATE,
				AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next().Id).iterator().next().Id;
		communicationData.parameterIds = new List<Id>();

		Test.startTest();
		List<CMN_DTO_SendCommunicationRequest.DTO_Document> elements = CMN_DAL_BaseTemplateSelector.getData(SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME,
				communicationData);
		Test.stopTest();
		System.assert(!elements.isEmpty(), 'Empty document list returned.');
	}

	/**
	 * @description No Object definitions
	 */
	@IsTest
	private static void constructElementMultipleRecords()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();

		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		SC_DAL_DataFactory.insertDocumentCheckListItems(caseRecord.Id, NUMBER_OF_ITEMS_TO_CREATE);
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData communicationData = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		communicationData.templateId = template.Id;
		communicationData.objectId = caseRecord.Id;
		communicationData.parameterIds = new List<Id>();

		Test.startTest();
		List<CMN_DTO_SendCommunicationRequest.DTO_Document> elements = CMN_DAL_BaseTemplateSelector.getData(SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME,
				communicationData);
		Test.stopTest();
		System.assert(!elements.isEmpty(), 'Empty document list returned.');
	}

	/**
	 * @description No Object definitions
	 */
	@IsTest
	private static void constructElementWithComments()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();

		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData communicationData = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		communicationData.templateId = template.Id;
		communicationData.objectId = caseRecord.Id;
		communicationData.parameterIds = new List<Id>();
		communicationData.otherComments = CMN_DAL_SObjectDomain.generateRandomName();

		Test.startTest();
		List<CMN_DTO_SendCommunicationRequest.DTO_Document> elements = CMN_DAL_BaseTemplateSelector.getData(SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME,
				communicationData);
		Test.stopTest();
		System.assert(!elements.isEmpty(), 'Empty document list returned.');
	}

	/**
	 * @description No Object definitions
	 */
	@IsTest
	private static void constructElementWithAttachments()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();

		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData communicationData = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		communicationData.templateId = template.Id;
		communicationData.objectId = caseRecord.Id;
		communicationData.parameterIds = new List<Id>();
		CMN_CommunicationTemplateAttachment__c templateAttachment = CMN_DAL_CommunicationTemplateAttachment.getAll().iterator().next();
		CMN_DTO_CommunicationAttachment attachment = new CMN_DTO_CommunicationAttachment();
		attachment.attachmentDefinitionId = templateAttachment.SC_Definition__c;
		attachment.attachmentId = templateAttachment.Id;
		attachment.definitionName = templateAttachment.SC_Definition__r.Name;
		communicationData.attachments = new List<CMN_DTO_CommunicationAttachment> {attachment};

		Test.startTest();
		List<CMN_DTO_SendCommunicationRequest.DTO_Document> elements = CMN_DAL_BaseTemplateSelector.getData(SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME,
				communicationData);
		Test.stopTest();
		System.assert(!elements.isEmpty(), 'Empty document list returned.');

	}

}