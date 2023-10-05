/**
 * @description Test Class for SC_DAL_ClientPolicyPrintSelector
 *
 * @see SC_DAL_ClientPolicyPrintSelector
 *
 * @author meghana.g.n@accenture.com, darrion.james.singh@accenture.com
 *
 * @date January 2022, July 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class SC_DAL_ClientPolicyPrintSelector_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	@TestSetup
	private static void setup()
	{
		Account newAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		Case caseRecord = SC_DAL_DataFactory.createCase(NUMBER_OF_ITEMS_TO_CREATE, newAccount.Id).iterator().next();
		SC_DAL_DataFactory.insertDocumentCheckListItems(caseRecord.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		List<CMN_CommunicationTemplate__c> cppCommunicationTemplates =
				CMN_DAL_DataFactory.createCommunicationTemplate(NUMBER_OF_ITEMS_TO_CREATE, SC_DAL_ClientPolicyPrintSelector.SELECTOR_CLASS_NAME,
						SC_API_SendClientPolicyPrint.SERVICE_NAME);
		CMN_CommunicationTemplateObjectDef__c insurancePolicyObjectDefinition =
				CMN_DAL_DataFactory.createCommunicationTemplateObjectDefinition(SC_DAL_InsurancePolicy.OBJECT_NAME);
		CMN_CommunicationTemplateObjectDef__c financialAccountObjectDefinition =
				CMN_DAL_DataFactory.createCommunicationTemplateObjectDefinition(SC_DAL_FinancialAccount.OBJECT_NAME);
		CMN_DAL_DataFactory.createCommTemplateObjectMap(cppCommunicationTemplates.iterator().next().Id, insurancePolicyObjectDefinition.Id);
		CMN_DAL_DataFactory.createCommTemplateObjectMap(cppCommunicationTemplates.iterator().next().Id, financialAccountObjectDefinition.Id);
		SC_DAL_DataFactory.createInsurancePolicies(NUMBER_OF_ITEMS_TO_CREATE, newAccount.Id);
		SC_DAL_DataFactory.createFinancialAccounts(newAccount, NUMBER_OF_ITEMS_TO_CREATE);

	}

	@IsTest
	static void singleInsurancePolicy()
	{
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		InsurancePolicy newPolicy = SC_DAL_InsurancePolicy.getAll().iterator().next();
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData cmnCommunicationDataWrapper = getCommunicationWrapperForCase(template);
		cmnCommunicationDataWrapper.parameterIds = new List<Id> {newPolicy.Id};

		Test.startTest();
		List<CMN_DTO_SendCommunicationRequest.DTO_Document> documents =
				CMN_DAL_BaseTemplateSelector.getData(template.CMN_SelectorClassName__c, cmnCommunicationDataWrapper);
		Test.stopTest();

		System.assertNotEquals(null, documents, 'Document object not created');
		System.assert(!documents.isEmpty(), 'Document object not created');
	}

	@IsTest
	static void singleFinancialAccount()
	{
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		FinServ__FinancialAccount__c financialAccount = SC_DAL_FinancialAccount.getAll().iterator().next();
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData cmnCommunicationDataWrapper = getCommunicationWrapperForCase(template);
		cmnCommunicationDataWrapper.parameterIds = new List<Id> {financialAccount.Id};

		Test.startTest();
		List<CMN_DTO_SendCommunicationRequest.DTO_Document> documents =
				CMN_DAL_BaseTemplateSelector.getData(template.CMN_SelectorClassName__c, cmnCommunicationDataWrapper);
		Test.stopTest();

		System.assertNotEquals(null, documents, 'Document object not created');
		System.assert(!documents.isEmpty(), 'Document object not created');
	}

	@IsTest
	static void differentPolicyType()
	{
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		InsurancePolicy newPolicy = SC_DAL_InsurancePolicy.getAll().iterator().next();
		FinServ__FinancialAccount__c financialAccount = SC_DAL_FinancialAccount.getAll().iterator().next();
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData cmnCommunicationDataWrapper = getCommunicationWrapperForCase(template);
		cmnCommunicationDataWrapper.parameterIds = new List<Id> {newPolicy.Id, financialAccount.Id};

		Test.startTest();

		List<CMN_DTO_SendCommunicationRequest.DTO_Document> documents =
				CMN_DAL_BaseTemplateSelector.getData(template.CMN_SelectorClassName__c, cmnCommunicationDataWrapper);

		Test.stopTest();

		System.assertNotEquals(null, documents, 'Document object not created');
		System.assert(!documents.isEmpty(), 'Document object not created');
	}

	private static CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData getCommunicationWrapperForCase(CMN_CommunicationTemplate__c template)
	{
		CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData cmnCommunicationDataWrapper = new CMN_DAL_BaseTemplateSelector.CMN_DTO_CommunicationData();
		cmnCommunicationDataWrapper.emailType = template.CMN_Code__c;
		cmnCommunicationDataWrapper.workType = CMN_DAL_SObjectDomain.generateRandomName();
		cmnCommunicationDataWrapper.recipientRole = CMN_DAL_SObjectDomain.generateRandomName();
		cmnCommunicationDataWrapper.templateId = template.Id;
		cmnCommunicationDataWrapper.objectId = CMN_UTIL_Random.randomSObjectId(Case.SObjectType);
		cmnCommunicationDataWrapper.otherComments = CMN_DAL_SObjectDomain.generateRandomName();
		cmnCommunicationDataWrapper.attachments = new List<CMN_DTO_CommunicationAttachment>();

		return cmnCommunicationDataWrapper;
	}

	/**
 * @description Check for the flow successfully processing the client policy print callout
 */
	@IsTest
	private static void successfulClientPolicyPrintCall()
	{
		Case caseRecord = SC_DAL_Case.getAll().iterator().next();
		CMN_CommunicationTemplate__c template = CMN_DAL_CommunicationTemplate.findBySelectorClassName(SC_DAL_ClientPolicyPrintSelector.SELECTOR_CLASS_NAME);
		List<Id> policyIds = new List<Id>(CMN_UTIL_System.extractListIds(SC_DAL_InsurancePolicy.getAll()));
		List<SC_FLOW_SendCommunication.DTO_Response> dtoResponses = SC_FLOW_SendCommunication_TEST.communicationTemplateDataTest(template.Id,
				NUMBER_OF_ITEMS_TO_CREATE, caseRecord.Id, NUMBER_OF_ITEMS_TO_CREATE, new List<CMN_DTO_CommunicationAttachment>(), true, true, policyIds, false);
		System.assertEquals(false, SC_FLOW_SendCommunication_TEST.hasErrorsInResponse(dtoResponses), 'DTO Response has failed call');
	}
}