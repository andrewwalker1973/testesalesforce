/**
 * @description Will test the inbound service class RSC_API_UpsertCase
 *
 * @see RSC_API_UpsertCase @story ST-145996
 *
 * @author jayanth.kumar.s@accenture.com, jason.van.beukering@accenture.com
 *
 * @date December 2021, August 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=false)
private class RSC_API_UpsertCase_TEST
{
	private static final Id ASSIGNABLE_CASE_QUEUE_ID = SC_DAL_Group.getAssignableCasesQueue()?.Id;
	private static final Id NON_ASSIGNABLE_CASE_QUEUE_ID = SC_DAL_Group.getNonAssignableCasesQueue()?.Id;
	private static final Integer INT_FOUR = 4;
	private static final Integer INT_ONE = 1;
	private static final Integer INT_THREE = 3;
	private static final Integer INT_TWO = 2;
	private static final String ERROR_NO_CHECKLIST_ITEMS_INSERTED = 'No document checklist items were inserted.';
	private static final String ERROR_NO_CONTRACTS_INSERTED = 'No contracts were inserted.';
	private static final String ERROR_STATUS_INCORRECT = 'Status not as expected.';
	private static final String ERROR_SUB_STATUS_INCORRECT = 'Sub status not as expected.';
	private static final String REQUESTER_TYPE = 'Customer';

	/**
	 * @description Create data required for the unit test
	 */
	@TestSetup
	private static void setup()
	{
		Account newAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		FinServ__FinancialAccount__c newFinancialAccount = AW_DAL_TestDataFactory.createFinancialAccounts(newAccount, INT_ONE).iterator().next();
		List<InsurancePolicy> newPolicies = AW_DAL_TestDataFactory.createInsurancePolicies(newAccount, INT_TWO);
		Case newCase = SC_DAL_DataFactory.createCase(INT_ONE, newAccount.Id).iterator().next();
		SC_DAL_DataFactory.insertDocumentCheckListItems(newCase.Id, INT_TWO);
		SC_DAL_DataFactory.insertAssociatedContracts(newCase.Id, INT_ONE, newFinancialAccount.Id, null);
		Contact newContact = RSC_DAL_TestDataFactory.createPracticeContacts(SC_DAL_Contact.RT_ADVISER, INT_ONE, null).iterator().next();
		RSC_DAL_TestDataFactory.insertConsultantCode(newContact.Id, INT_ONE, true);
		RSC_DAL_TestDataFactory.insertCaseComments(INT_ONE, newCase.Id);
		for(InsurancePolicy newPolicy : newPolicies)
		{
			SC_DAL_DataFactory.insertAssociatedContracts(newCase.Id, INT_ONE, null, newPolicy.Id);
		}
	}

	/**
	 * @description Will check that a case is inserted successfully
	 */
	@IsTest
	private static void insertCaseForUnsupportedServiceType()
	{
		RSC_API_UpsertCase.DTO_Request dtoRequest = populateDtoRequestData(true);

		setupRestContextAndExecuteService(dtoRequest);
		assertCaseOwner(Integer.valueOf(dtoRequest.cases.iterator().next().sourceCaseNumber), false);
		List<SC_AssociatedContract__c> contracts = SC_DAL_AssociatedContract.getAll();
		Assert.isFalse(contracts.isEmpty(), ERROR_NO_CONTRACTS_INSERTED);

		List<DocumentChecklistItem> documentChecklistItems = SC_DAL_DocumentChecklistItem.getAll();
		Assert.isFalse(documentChecklistItems.isEmpty(), ERROR_NO_CHECKLIST_ITEMS_INSERTED);

		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.findByServiceName(AW_API_RefreshContracts.SERVICE_NAME);
		Assert.isTrue(queueItems.isEmpty(), 'Contracts should not have been refreshed');
	}

	/**
	 * @description Will check that a case is inserted successfully with New Status for the supported service types
	 */
	@IsTest
	private static void insertCaseForSupportedServiceType()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		RSC_API_UpsertCase.DTO_Request dtoRequest = populateDtoRequestData(true);

		for(RSC_DTO_Case dtoCase : dtoRequest.cases)
		{
			dtoCase.assignedTo = null;
		}

		SC_ServiceType__c foundServiceType = SC_DAL_ServiceType.getAll().iterator().next();
		foundServiceType.SC_Assignable__c = true;
		update foundServiceType;

		setupRestContextAndExecuteService(dtoRequest);
		assertCaseOwner(Integer.valueOf(dtoRequest.cases.iterator().next().sourceCaseNumber), true);
		assertPortfolioRefreshRequestWasSent();
		assertCacheRecordCreatedForMissingContract();
	}

	/**
	 * @description Will check that the owner is set as expected post the successful sync
	 *
	 * @param workFlowCaseNumber work flow case number of the case received from horizon
	 * @param isAssignable flag to indicate if the case is serviceable or not
	 */
	private static void assertCaseOwner(Integer workFlowCaseNumber, Boolean isAssignable)
	{
		Case foundCase = SC_DAL_Case.findByWorkflowCaseNumber(new Set<Object> {workFlowCaseNumber}).iterator().next();

		Assert.areEqual(isAssignable ? ASSIGNABLE_CASE_QUEUE_ID : NON_ASSIGNABLE_CASE_QUEUE_ID, foundCase.OwnerId, 'Owner not set as expected');
	}

	/**
	 * @description Will check that a request was send to refresh the clients' portfolio
	 */
	@SuppressWarnings('DuplicatedCode')
	private static void assertPortfolioRefreshRequestWasSent()
	{
		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.findByServiceName(AW_API_RefreshContracts.SERVICE_NAME);

		Assert.isFalse(queueItems.isEmpty(), 'No items found');

		//noinspection DuplicatedCode
		for(CMN_WebserviceCallQueue__c queueItem : queueItems)
		{
			//Check that the request didn't abort, we can't check that it completed as batch process is running synchronously and so fails
			Assert.isFalse(CMN_DAL_WebserviceCallQueue.STATUS_ABORTED.equalsIgnoreCase(queueItem.CMN_Status__c), 'Service was aborted Queue Item JSON: ' + JSON.serialize(queueItem));
		}
	}

	/**
	 * @description Will check that an entry was created in platform cache for a missing policy as well as the the issue was logged
	 */
	private static void assertCacheRecordCreatedForMissingContract()
	{
		List<Case> foundCases = SC_DAL_Case.getAll();

		Set<Id> accountIds = CMN_UTIL_System.extractListIds(foundCases, SC_DAL_Case.FIELD_ACCOUNT_ID);

		SC_UTIL_Contracts.MissingContractsCacheHandler cacheHandler = new SC_UTIL_Contracts.MissingContractsCacheHandler();
		Map<Id, Map<Id, Set<String>>> missingContractsMap = cacheHandler.retrieveFromCache(accountIds);

		Assert.isFalse(missingContractsMap.isEmpty(), 'No items were written to the cache');
		List<CMN_AppLog__c> appLogs = CMN_DAL_AppLog.findAllByMethod(RSC_API_UpsertCase.CLASS_METHOD_POPULATE_CONTRACT);

		Assert.isFalse(appLogs.isEmpty(), 'No Logs were written');
		Assert.areEqual(INT_TWO, appLogs.size(), 'Incorrect number of problems logged');

	}

	/**
	 * @description Will check that a case is updated successfully
	 */
	@IsTest
	private static void updateCaseWithDocumentsAndContractsWithServiceTypeChange()
	{
		Id activeAgentId = SC_DAL_User.findRandomActiveAgent().Id;
		Case foundCase = SC_DAL_Case.getAll().iterator().next();
		foundCase.OwnerId = activeAgentId;
		update foundCase;

		SC_ServiceType__c foundServiceType = SC_DAL_ServiceType.getAll().iterator().next();
		foundServiceType.SC_Assignable__c = true;
		foundServiceType.SC_ServiceType__c = CMN_DAL_SObjectDomain.generateRandomInteger(INT_THREE);
		update foundServiceType;

		DocumentChecklistItem documentChecklistItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next();
		FinServ__FinancialAccount__c financialAccount = AW_DAL_FinancialAccount.getAll().iterator().next();
		InsurancePolicy insurancePolicy = AW_DAL_InsurancePolicy.getAll().iterator().next();

		RSC_API_UpsertCase.DTO_Request dtoRequest = populateDtoRequestData(true);
		RSC_DTO_Case dtoCase = dtoRequest.cases.iterator().next();

		dtoCase.sourceCaseNumber = String.valueOf(foundCase.RSC_WorkflowCaseNumber__c);
		dtoCase.serviceTypeCode = Integer.valueOf(foundServiceType.SC_ServiceType__c);
		dtoCase.requestorType = CMN_UTIL_String.EMPTY;
		dtoCase.documents[0].id = documentChecklistItem.CMN_VaultedId__c;
		dtoCase.contractNumbers[0].contractNumber = financialAccount.FinServ__FinancialAccountNumber__c;
		dtoCase.contractNumbers[1].contractNumber = insurancePolicy.Name;

		setupRestContextAndExecuteService(dtoRequest);

		Assert.areEqual(foundCase.OwnerId, activeAgentId, 'Owner not set as expected');
		Assert.areEqual(foundCase.SC_RequesterType__c, null, 'Requester Type not set as expected');
		//Total documents :- 2 documents on Case, 3(ideally 2) DTO Documents (2 New DTO Documents + 1 DTO Document with existing vaulted ID)
		Assert.areEqual(INT_FOUR, SC_DAL_DocumentChecklistItem.findByParent(foundCase.Id).size(), 'Documents were not processed successfully.');

		List<SC_AssociatedContract__c> contracts = SC_DAL_AssociatedContract.getAll();
		Assert.areEqual(INT_FOUR, contracts.size(), 'Policies were not processed successfully.');

	}

	/**
	 * @description Will check that a caseComments are updated successfully
	 */
	@IsTest
	private static void updateCaseWithCommentsForNonSupportedServiceType()
	{
		Case request = SC_DAL_Case.getAll().iterator().next();
		CMN_CaseComment__c newComment = CMN_DAL_CaseComments.getAll().iterator().next();

		RSC_API_UpsertCase.DTO_Request dtoRequest = populateDtoRequestData(true);

		RSC_DTO_Case dtoCase = dtoRequest.cases.iterator().next();
		dtoCase.sourceCaseNumber = String.valueOf(request.RSC_WorkflowCaseNumber__c);

		RSC_DTO_Case.DTO_CaseComment dtoCaseComment = dtoCase.caseComments.iterator().next();

		dtoCaseComment.sourceCommentId = newComment.CMN_ExternalCommentId__c;
		dtoCaseComment.targetCaseNumber = request.CaseNumber;
		dtoCaseComment.sourceCaseNumber = String.valueOf(request.RSC_WorkflowCaseNumber__c);
		dtoCaseComment.commentHtml = CMN_DAL_SObjectDomain.generateRandomDescription();
		dtoCaseComment.userName = SC_DAL_User.findRandomActiveAgent().AW_UACFID__c;

		setupRestContextAndExecuteService(dtoRequest);

		assertCaseOwner(Integer.valueOf(request.RSC_WorkflowCaseNumber__c), false);
		Assert.areEqual(INT_TWO, CMN_DAL_CaseComments.findByCaseId(request.Id).size(), 'Case Comments were not processed successfully.');

	}

	/**
	 * @description Will check that a case is updated successfully with closed status
	 */
	@IsTest
	private static void updateCaseWithClosedStatus()
	{
		Case foundCase = SC_DAL_Case.getAll().iterator().next();

		DocumentChecklistItem documentChecklistItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next();

		//Adding another document of same type as, if already a document is updated with same type and if another document exists with same type,
		// then the 2nd document with same type will be updated instead of creating a duplicate item
		DocumentChecklistItem documentWithSameType = SC_DAL_DataFactory.newDocumentCheckListItems(foundCase.Id, INT_ONE).iterator().next();
		documentWithSameType.DocumentTypeId = documentChecklistItem.DocumentTypeId;
		insert documentWithSameType;

		String typeCode = CMN_UTIL_String.remove(documentChecklistItem.DocumentType.DeveloperName, SC_DAL_DocumentChecklistItem.DOCUMENT_CODE);

		RSC_API_UpsertCase.DTO_Request dtoRequest = populateDtoRequestData(true);

		RSC_DTO_Case dtoCase = new RSC_DTO_Case();
		dtoCase = dtoRequest.cases.iterator().next();
		dtoCase.sourceCaseNumber = String.valueOf(foundCase.RSC_WorkflowCaseNumber__c);
		dtoCase.statusCode = SC_DAL_Case.WORKFLOW_STATUS_CLOSED;

		for(RSC_DTO_Case.DTO_Document document : dtoCase.documents)
		{
			document.typeCode = typeCode;
		}

		setupRestContextAndExecuteService(dtoRequest);

		foundCase = SC_DAL_Case.findById(foundCase.Id);

		Assert.areEqual(SC_DAL_Case.STATUS_RESOLVED, foundCase.Status, ERROR_STATUS_INCORRECT);
		Assert.areEqual(REQUESTER_TYPE, foundCase.SC_RequesterType__c, 'Requester Type not set as expected');

		//3 Documents on case out of which 2 are of same type, and 3 Document from dto which are of same type as the 2 Documents on Case with same type,
		// so 2 documents will be updated and the third will be inserted.
		Assert.areEqual(INT_FOUR, SC_DAL_DocumentChecklistItem.findByParent(foundCase.Id).size(), 'Documents were not processed successfully.');
	}

	/**
	 * @description Will check that a case is updated successfully with on hold sub status
	 */
	@IsTest
	private static void updateCaseWithOnHoldSubStatus()
	{
		Case request = SC_DAL_Case.getAll().iterator().next();

		RSC_API_UpsertCase.DTO_Request dtoRequest = populateDtoRequestData(true);

		for(RSC_DTO_Case dtoCase : dtoRequest.cases)
		{
			dtoCase.sourceCaseNumber = String.valueOf(request.RSC_WorkflowCaseNumber__c);
			dtoCase.statusCode = dtoCase.subStatusCode = SC_DAL_Case.WORKFLOW_STATUS_PEND;

			for(RSC_DTO_Case.DTO_Document document : dtoCase.documents)
			{
				document.typeCode = CMN_DAL_SObjectDomain.generateRandomNumber(); // making it random to check if the debug logger is logged or not
			}
		}

		setupRestContextAndExecuteService(dtoRequest);

		List<Case> allRequests = SC_DAL_Case.getAll();
		for(Case serviceRequest : allRequests)
		{
			Assert.areEqual(SC_DAL_Case.SUB_STATUS_ON_HOLD, serviceRequest.SC_SubStatus__c, ERROR_SUB_STATUS_INCORRECT);
			Assert.areEqual(SC_DAL_Case.STATUS_IN_PROGRESS, serviceRequest.Status, ERROR_STATUS_INCORRECT);
		}

	}

	/**
	 * @description Will check that a case is updated successfully with terminated sub status
	 */
	@IsTest
	private static void updateCaseWithTerminatedSubStatus()
	{
		Case request = SC_DAL_Case.getAll().iterator().next();
		DocumentChecklistItem documentChecklistItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next();

		Case newCase = SC_DAL_DataFactory.createCase(INT_ONE).iterator().next();
		DocumentChecklistItem newItem = SC_DAL_DataFactory.newDocumentCheckListItems(newCase.Id, INT_ONE).iterator().next();
		newItem.SC_UploadedWithCase__c = true;
		insert newItem;

		List<Case> caseList = SC_DAL_Case.findById(new Set<Id> {request.Id, newCase.Id});

		RSC_API_UpsertCase.DTO_Request dtoRequest = populateDtoRequestData(true);

		for(Integer i = 0; i < INT_TWO; i++) //adding this chk to make sure that each dto has different workflow case Number
		{
			//adding different workflow case number so that map will not have same case for different DTO key
			dtoRequest.cases[i].sourceCaseNumber = String.valueOf(caseList[i].RSC_WorkflowCaseNumber__c);

			dtoRequest.cases[i].statusCode = dtoRequest.cases[i].subStatusCode = SC_DAL_Case.SUB_STATUS_TERMINATED;

			RSC_DTO_Case.DTO_Document document = dtoRequest.cases[i].documents.iterator().next();
			document.id = documentChecklistItem.CMN_VaultedId__c; // this make sures that the existing document with uploaded with case = true on 2nd DTO will be deleted
		}

		setupRestContextAndExecuteService(dtoRequest);

		List<Case> allRequests = SC_DAL_Case.getAll();
		for(Case serviceRequest : allRequests)
		{
			Assert.areEqual(SC_DAL_Case.SUB_STATUS_TERMINATED, serviceRequest.SC_SubStatus__c, ERROR_SUB_STATUS_INCORRECT);
			Assert.areEqual(SC_DAL_Case.STATUS_CLOSED, serviceRequest.Status, ERROR_STATUS_INCORRECT);

		}

		// Total documents before delete = 4 (3 dto documents, one on case)
		// Total documents after delete = 3 (3 dto documents)
		Assert.areEqual(INT_THREE, SC_DAL_DocumentChecklistItem.findByParent(newCase.Id).size(), 'Items not deleted as expected');
	}

	/**
	 * @description Will setup the RestContext & execute the service
	 *
	 * @param dtoRequest The DTO that represents the JSON sent in a request
	 */
	private static void setupRestContextAndExecuteService(RSC_API_UpsertCase.DTO_Request dtoRequest)
	{
		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		RSC_URL_CaseSync.caseSync();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(RSC_API_UpsertCase.SERVICE_NAME);
	}

	/**
	 * @description Will test that exception is thrown if the Service type is not matched
	 */
	@IsTest
	private static void insertCaseIfServiceTypeNotFound()
	{
		RSC_API_UpsertCase.DTO_Request dtoRequest = populateDtoRequestData(true);
		for(RSC_DTO_Case dtoCase : dtoRequest.cases)
		{
			dtoCase.serviceTypeCode = CMN_DAL_SObjectDomain.generateRandomInteger();
		}

		setupRestContextAndExecuteService(dtoRequest);

		List<SC_AssociatedContract__c> contracts = SC_DAL_AssociatedContract.getAll();
		Assert.isFalse(contracts.isEmpty(), ERROR_NO_CONTRACTS_INSERTED);

		List<DocumentChecklistItem> documentChecklistItems = SC_DAL_DocumentChecklistItem.getAll();
		Assert.isFalse(documentChecklistItems.isEmpty(), ERROR_NO_CHECKLIST_ITEMS_INSERTED);

		List<CaseComment> comments = RSC_DAL_CaseComment.getAll();
		Assert.areEqual(INT_TWO, comments.size(), 'Case Comments were not created successfully');
	}

	/**
	 * @description Will test that exception is thrown if the case is not found to be processed
	 */
	@IsTest
	private static void failIfCaseNotFound()
	{
		RSC_API_UpsertCase.DTO_Request dtoRequest = new RSC_API_UpsertCase.DTO_Request();

		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		RSC_URL_CaseSync.caseSync();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(RSC_API_UpsertCase.SERVICE_NAME, RSC_API_UpsertCase.ERROR_NO_CASE_FOUND);
	}

	/**
	 * @description Will populate the dtoRequest data
	 *
	 * @param requesterTypeRequired flag to identify if the requester type should be included in the request
	 *
	 * @return the DTO_Request
	 */
	private static RSC_API_UpsertCase.DTO_Request populateDtoRequestData(Boolean requesterTypeRequired)
	{
		Account foundAccount = SC_DAL_Account.getAll().iterator().next();
		FinServ__FinancialAccount__c foundFinancialAccount = AW_DAL_FinancialAccount.getAll().iterator().next();
		InsurancePolicy foundPolicy = AW_DAL_InsurancePolicy.getAll().iterator().next();
		SC_ConsultantCodes__c foundConsultantCode = SC_DAL_ConsultantCodes.getAll().iterator().next();
		SC_ServiceType__c foundServiceType = SC_DAL_ServiceType.getAll().iterator().next();
		User foundAgent = SC_DAL_User.findRandomActiveAgent();

		RSC_API_UpsertCase.DTO_Request dtoRequest = new RSC_API_UpsertCase.DTO_Request();
		List<RSC_DTO_Case> dtoCases = new List<RSC_DTO_Case>();

		for(Integer i = 0; i < INT_TWO; i++)
		{
			String salesforceCaseNumber = CMN_DAL_SObjectDomain.generateRandomNumber();
			Integer workFlowCaseNumber = CMN_DAL_SObjectDomain.generateRandomInteger();

			RSC_DTO_Case dtoCase = new RSC_DTO_Case();

			dtoCase.assignedTo = foundAgent.AW_UACFID__c;
			dtoCase.caseTitle = CMN_DAL_SObjectDomain.generateRandomName();
			dtoCase.consultantCode = foundConsultantCode.Name;
			dtoCase.departmentName = CMN_DAL_SObjectDomain.generateRandomName();
			dtoCase.emailAddress = CMN_DAL_SObjectDomain.generateRandomEmail();
			dtoCase.identificationNumber = foundAccount.AW_IdentificationNumber__pc;
			dtoCase.priority = SC_DAL_Case.PRIORITY_NORMAL;
			if(requesterTypeRequired)
			{
			dtoCase.requestorType = REQUESTER_TYPE;
			}
			dtoCase.serviceTypeCode = Integer.valueOf(foundServiceType.SC_ServiceType__c);
			dtoCase.sourceCaseNumber = String.valueOf(workFlowCaseNumber);
			dtoCase.sourceChannel = SC_DAL_Case.DEFAULT_CASE_ORIGIN;
			dtoCase.sourceSystem = SC_DAL_Case.DEFAULT_SOURCE_SYSTEM;
			dtoCase.statusCode = SC_DAL_Case.WORKFLOW_STATUS_WIP;
			dtoCase.targetCaseNumber = salesforceCaseNumber;

			dtoCase.documents = new List<RSC_DTO_Case.DTO_Document>();

			for(Integer j = 0; j < INT_THREE; j++)
			{
				RSC_DTO_Case.DTO_Document dtoDocument = new RSC_DTO_Case.DTO_Document();

				dtoDocument.id = CMN_DAL_SObjectDomain.generateRandomNumber();
				dtoDocument.storedDate = Datetime.now();
				dtoDocument.typeCode = CMN_UTIL_String.remove(SC_DAL_DocumentType.findRandomActive().DeveloperName, SC_DAL_DocumentChecklistItem.DOCUMENT_CODE);
				dtoDocument.typeText = CMN_DAL_SObjectDomain.generateRandomName();

				dtoCase.documents.add(dtoDocument);
			}

			dtoCase.contractNumbers = new List<RSC_DTO_Case.DTO_Contract>();

			addContractNumber(foundFinancialAccount.FinServ__FinancialAccountNumber__c, dtoCase.contractNumbers);
			addContractNumber(foundPolicy.Name, dtoCase.contractNumbers);
			addContractNumber(CMN_DAL_SObjectDomain.generateRandomNumber(), dtoCase.contractNumbers);

			List<RSC_DTO_Case.DTO_CaseComment> dtoCaseComments = new List<RSC_DTO_Case.DTO_CaseComment>();

			for(Integer j = 0; j < INT_TWO; j++)
			{
				RSC_DTO_Case.DTO_CaseComment dtoComment = new RSC_DTO_Case.DTO_CaseComment();

				dtoComment.commentDate = CMN_DAL_SObjectDomain.generateRandomDateTime();
				dtoComment.commentHtml = CMN_DAL_SObjectDomain.generateRandomDescription();
				dtoComment.sourceCaseNumber = String.valueOf(workFlowCaseNumber);
				dtoComment.sourceCommentId = CMN_DAL_SObjectDomain.generateRandomNumber();
				dtoComment.targetCaseNumber = salesforceCaseNumber;
				dtoComment.targetCommentId = CMN_DAL_SObjectDomain.generateRandomNumber();
				dtoComment.userName = String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger());

				dtoCaseComments.add(dtoComment);
			}

			dtoCase.caseComments = dtoCaseComments;

			dtoCases.add(dtoCase);
		}

		dtoRequest.cases = dtoCases;
		return dtoRequest;
	}

	/**
	 * @description Will add a contact dto to the list with the number given
	 *
	 * @param contractNumber The contract number
	 * @param contractNumbers The list to which to add the contract number
	 */
	private static void addContractNumber(String contractNumber, List<RSC_DTO_Case.DTO_Contract> contractNumbers)
	{
		RSC_DTO_Case.DTO_Contract dtoContractFinancialAccount = new RSC_DTO_Case.DTO_Contract();
		dtoContractFinancialAccount.contractNumber = contractNumber;
		contractNumbers.add(dtoContractFinancialAccount);
	}
}