/**
 * @description Will test the inbound service class SC_API_AppointmentCaseSync
 *
 * @see SC_API_AppointmentCaseSync @story ST-318497
 * @see SC_URL_AppointmentCaseSync
 *
 * @author mthobisi.ndlovu@accenture.com, vijay.jayswal@acceture.com
 *
 * @date May 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=false)
private class SC_API_AppointmentCaseSync_TEST
{
	private static final Integer INT_FOUR = 4;
	private static final Integer INT_ONE = 1;
	private static final Integer INT_SIX = 6;
	private static final Integer INT_THREE = 3;
	private static final String CASE_NUMBER = String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger(9));
	private static final String EXISTING_MEDICAL_REQUIREMENT = 'Cholesterol and HDL Ratio';
	private static final String MEDICAL_REQUIREMENT = 'Blood Urea Nitrogen';
	private static final String TITLE_MISS = 'Miss';
	private static final String WORK_ORDER_RECORD_TYPE = 'SC_WorkOrder';
	private static final String WORK_ORDER_LINE_ITEM_RECORD_TYPE = 'SC_MedicalRequirement';

	/**
	 * @description test data setup method
	 */
	@TestSetup
	private static void setup()
	{
		Account masterAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		Contact consultantContact = RSC_DAL_TestDataFactory.createPracticeContacts(SC_DAL_Contact.RT_ADVISER, INT_ONE, null).iterator().next();
		RSC_DAL_TestDataFactory.insertConsultantCode(consultantContact.Id, INT_ONE, true);
		SC_DAL_DataFactory.createServiceTypesWithAssignableValue(INT_ONE, true).iterator().next();

		AW_DAL_TestDataFactory.createInsurancePolicies(masterAccount, INT_THREE);
		AW_DAL_TestDataFactory.createFinancialAccounts(masterAccount, INT_ONE).iterator().next();

	}

	/**
	 * @description method to test if case extension records are created
	 */
	@IsTest
	private static void processCaseCreation()
	{
		SC_API_AppointmentCaseSync.DTO_Request request = generateRequestData();
		assertServiceCompleted(request);
		WorkType workType = SC_DAL_DataFactory.createWorkType().iterator().next();
		workType.SC_WorkOrderRecordType__c = WORK_ORDER_RECORD_TYPE;
		workType.SC_WorkOrderLineItemRecordType__c = WORK_ORDER_LINE_ITEM_RECORD_TYPE;
		CMN_DAL_SObjectDomain.updateDBObject(workType);
		SC_ServiceType__c serviceType = SC_DAL_ServiceType.getAll().iterator().next();
		serviceType.SC_WorkType__c = workType.Id;
		CMN_DAL_SObjectDomain.updateDBObject(serviceType);
		Account masterAccount = SC_DAL_Account.getAll().iterator().next();
		List<SC_CaseExtension__c> caseExtensions = SC_DAL_CaseExtension.getAll();
		Assert.isFalse(caseExtensions.isEmpty(), 'No case extension records created.');
		Id assignableQueueId = SC_DAL_Group.getAssignableCasesQueue()?.Id;

		List<Case> cases = SC_DAL_Case.getAll();
		Assert.isFalse(cases.isEmpty(), 'No case records created.');
		for(Case aCase : cases)
		{
			Assert.areEqual(assignableQueueId, aCase.OwnerId, 'Case owner was not set to the assignable case queue');
			Assert.areEqual(serviceType.Id, aCase.RSC_ServiceType__c, 'Case service type is null or does not match request service type');
			Assert.areEqual(masterAccount.Id, aCase.AccountId, 'Account Id is null or does not match client Id account');
		}

		CMN_UTIL_SObjectIndex caseNumberToExistingCase = new CMN_UTIL_SObjectIndex(SC_DAL_Case.FIELD_WORKFLOW_CASE_NUMBER).putAll(cases);
		for(SC_CaseExtension__c extension : caseExtensions)
		{
			String caseExtensionId = String.valueOf(((Case)caseNumberToExistingCase.get(extension.RSC_CaseNumber__c))?.SC_CaseExtension__c);
			Assert.areEqual(extension.Id, caseExtensionId, 'Case Extension record not associated with the case record');
		}

	}
	/**
	 * @description method to test if a case is created without associated contracts
	 */
	@IsTest
	private static void insertCaseWithoutAssociatedContracts()
	{
		SC_API_AppointmentCaseSync.DTO_Request request = generateRequestData();
		SC_API_AppointmentCaseSync.DTO_AppointmentCase medicalAppointment = request.cases.iterator().next();
		medicalAppointment.client.workTelephoneNumber = null;
		medicalAppointment.caseDetail.contractNumber = CMN_UTIL_String.EMPTY;
		medicalAppointment.concurrentContractNumbers = null;
		assertServiceCompleted(request);

		List<SC_AssociatedContractExtension__c> associatedContractExtensions = SC_DAL_AssociatedContractExtension.getAll();
		Assert.isTrue(associatedContractExtensions.isEmpty(), 'Associated contract extension records created.');

		List<SC_AssociatedContract__c> contracts = SC_DAL_AssociatedContract.getAll();
		Assert.isTrue(contracts.isEmpty(), 'Associated contract records created.');
	}

	/**
	 * @description method to test if associated contracts and contract extensions were created
	 */
	@IsTest
	private static void insertAssociatedContractExtensionWithAssociatedContracts()
	{
		SC_API_AppointmentCaseSync.DTO_Request request = generateRequestData();

		List<InsurancePolicy> insurancePolicies = SC_DAL_InsurancePolicy.getAll();
		Account masterAccount = SC_DAL_Account.getAll().iterator().next();
		FinServ__FinancialAccount__c financialAccount = AW_DAL_TestDataFactory.createFinancialAccounts(masterAccount, INT_ONE).iterator().next();
		Case appointmentCase = SC_DAL_DataFactory.createCase(INT_ONE).iterator().next();
		InsurancePolicy existingAssociatedContractPolicy = AW_DAL_TestDataFactory.createInsurancePolicies(masterAccount, INT_ONE).iterator().next();

		SC_DAL_DataFactory.insertAssociatedContracts(appointmentCase.Id, INT_ONE, financialAccount.Id, null);
		SC_DAL_DataFactory.insertAssociatedContracts(appointmentCase.Id, INT_ONE, null, existingAssociatedContractPolicy.Id);

		SC_API_AppointmentCaseSync.DTO_AppointmentCase dtoAppointmentCase = request.cases.iterator().next();
		dtoAppointmentCase.caseDetail.caseNumber = String.valueOf(appointmentCase.RSC_WorkflowCaseNumber__c);
		dtoAppointmentCase.caseDetail.contractNumber = SC_DAL_FinancialAccount.getAll().iterator().next().FinServ__FinancialAccountNumber__c;

		List<SC_API_AppointmentCaseSync.DTO_Contract> concurrentContractNumbers
				= new List<SC_API_AppointmentCaseSync.DTO_Contract>();
		for(InsurancePolicy policy : insurancePolicies)
		{
			SC_API_AppointmentCaseSync.DTO_Contract concurrentContractNumber =
					new SC_API_AppointmentCaseSync.DTO_Contract();
			concurrentContractNumber.concurrentContract = policy.Name;
			concurrentContractNumbers.add(concurrentContractNumber);
		}
		dtoAppointmentCase.concurrentContractNumbers = concurrentContractNumbers;
		assertServiceCompleted(request);

		List<SC_AssociatedContractExtension__c> associatedContractExtensions = SC_DAL_AssociatedContractExtension.getAll();
		Assert.areEqual(INT_FOUR, associatedContractExtensions.size(), 'No associated contract extension records created.');
		for(SC_AssociatedContractExtension__c contractExtension : associatedContractExtensions)
		{
			Assert.isNotNull(contractExtension.SC_CaseExtension__c, 'Case extension lookup not populated');
		}

		List<SC_AssociatedContract__c> contracts = SC_DAL_AssociatedContract.getAll();
		Assert.areEqual(INT_SIX, contracts.size(), 'No associated contract records created.');

		CMN_UTIL_SObjectIndex associatedContractExtensionMap =
				new CMN_UTIL_SObjectIndex(CMN_DAL_SObjectDomain.FIELD_ID).putAll(associatedContractExtensions);
		for(SC_AssociatedContract__c associatedContract : contracts)
		{
			String contractExtensionId =
					String.valueOf(((SC_AssociatedContractExtension__c)associatedContractExtensionMap.get(associatedContract.SC_AssociatedContractExtension__c))?.Id);
			Assert.areEqual(
					associatedContract.SC_AssociatedContractExtension__c,
					contractExtensionId,
					'Contract Extension record not associated with the associated contract record'
			);

		}
	}

	/**
	 * @description method to tests if blood test are created as WorkOrderLineItem
	 */
	@IsTest
	private static void insertCaseWithWorkOrder()
	{
		SC_API_AppointmentCaseSync.DTO_Request request = generateRequestData();
		SC_ServiceType__c serviceType = SC_DAL_ServiceType.getAll().iterator().next();
		SC_CaseExtension__c caseExtension = SC_DAL_DataFactory.insertCaseExtensions(INT_ONE).iterator().next();
		caseExtension.RSC_ClientIdentificationNumber__c = SC_DAL_Account.getAll().iterator().next().AW_IdentificationNumber__pc;
		CMN_DAL_SObjectDomain.updateDBObject(caseExtension);
		Case appointmentCase = SC_DAL_DataFactory.createCase(INT_ONE).iterator().next();
		appointmentCase.SC_CaseExtension__c = caseExtension.Id;
		appointmentCase.RSC_ServiceType__c=serviceType.Id;
		CMN_DAL_SObjectDomain.updateDBObject(appointmentCase);
		SC_AssociatedContractExtension__c associateContractExtension = SC_DAL_DataFactory.insertAssociatedContractExtensions(INT_ONE).iterator().next();
		associateContractExtension.SC_CaseExtension__c = caseExtension.Id;
		CMN_DAL_SObjectDomain.updateDBObject(associateContractExtension);
		User agent = SC_DAL_User.findRandomActiveAgent();
		WorkOrder newWorkOrder = SC_DAL_DataFactory.createWorkOrder(appointmentCase.Id, agent.Id, INT_ONE).iterator().next();
		WorkOrderLineItem existingWorkOrderLineItem = SC_DAL_DataFactory.createWorkOrderLineItem(newWorkOrder.Id, INT_ONE).iterator().next();
		existingWorkOrderLineItem.SC_MedicalRequirement__c = CMN_UTIL_System.getPicklistValue(
				WorkOrderLineItem.SObjectType,
				WorkOrderLineItem.SC_MedicalRequirement__c.getDescribe().getLocalName(),
				EXISTING_MEDICAL_REQUIREMENT
		);
		CMN_DAL_SObjectDomain.updateDBObject(existingWorkOrderLineItem);

		SC_API_AppointmentCaseSync.DTO_AppointmentCase dtoAppointmentCase = request.cases.iterator().next();
		dtoAppointmentCase.caseDetail.caseNumber = String.valueOf(appointmentCase.RSC_WorkflowCaseNumber__c);
		List<SC_API_AppointmentCaseSync.DTO_WorkOrderLineItem> medicalRequirements = new List<SC_API_AppointmentCaseSync.DTO_WorkOrderLineItem>();
		SC_API_AppointmentCaseSync.DTO_WorkOrderLineItem newMedicalRequirement = new SC_API_AppointmentCaseSync.DTO_WorkOrderLineItem();
		newMedicalRequirement.bloodRequirements = CMN_UTIL_System.getPicklistValue(
				WorkOrderLineItem.SObjectType,
				WorkOrderLineItem.SC_MedicalRequirement__c.getDescribe().getLocalName(),
				MEDICAL_REQUIREMENT
		);
		medicalRequirements.add(newMedicalRequirement);
		dtoAppointmentCase.medicalRequirements = medicalRequirements;
		assertServiceCompleted(request);

	}

	/**
	 * @description method to test if associated contracts and contract extensions were created if associated contracts extension has  case extension.
	 */
	@IsTest
	private static void insertAssociatedContractExtensionWithCaseExtension()
	{
		SC_API_AppointmentCaseSync.DTO_Request request = generateRequestData();
		SC_ServiceType__c serviceType = SC_DAL_ServiceType.getAll().iterator().next();
		SC_CaseExtension__c caseExtension = SC_DAL_DataFactory.insertCaseExtensions(INT_ONE).iterator().next();
		caseExtension.RSC_ClientIdentificationNumber__c = SC_DAL_Account.getAll().iterator().next().AW_IdentificationNumber__pc;
		CMN_DAL_SObjectDomain.updateDBObject(caseExtension);
		Case appointmentCase = SC_DAL_DataFactory.createCase(INT_ONE).iterator().next();
		appointmentCase.SC_CaseExtension__c = caseExtension.Id;
		appointmentCase.RSC_ServiceType__c=serviceType.Id;
		CMN_DAL_SObjectDomain.updateDBObject(appointmentCase);
		SC_AssociatedContractExtension__c associateContractExtension = SC_DAL_DataFactory.insertAssociatedContractExtensions(INT_ONE).iterator().next();
		associateContractExtension.SC_CaseExtension__c = caseExtension.Id;
		CMN_DAL_SObjectDomain.updateDBObject(associateContractExtension);
		SC_API_AppointmentCaseSync.DTO_AppointmentCase dtoAppointmentCase = request.cases.iterator().next();
		dtoAppointmentCase.caseDetail.caseNumber = String.valueOf(appointmentCase.RSC_WorkflowCaseNumber__c);
		dtoAppointmentCase.caseDetail.contractNumber = SC_DAL_FinancialAccount.getAll().iterator().next().FinServ__FinancialAccountNumber__c;
		assertServiceCompleted(request);

	}
	/**
	 * @description Will test that exception is thrown if the case creation request doesn't
	 * have the client's full name
	 */
	@IsTest
	private static void failedIfClientNameNotFound()
	{
		SC_API_AppointmentCaseSync.DTO_Request dtoRequest = generateRequestData();

		SC_API_AppointmentCaseSync.DTO_AppointmentCase dtoAppointmentCase = dtoRequest.cases.iterator().next();
		dtoAppointmentCase.client.fullName = null;

		assertServiceFailed(dtoRequest, SC_API_AppointmentCaseSync.ERROR_CLIENT_NAME_NOT_FOUND);
	}

	/**
	 * @description Check to see if the service fails if information is missing
	 *
	 * @param dtoRequest The request payload
	 * @param errorMessageMatch Check to see if correct phrase or word is in the error string
	 */
	private static void assertServiceFailed(SC_API_AppointmentCaseSync.DTO_Request dtoRequest, String errorMessageMatch)
	{
		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		SC_URL_AppointmentCaseSync.syncCase();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(SC_API_AppointmentCaseSync.SERVICE_NAME, errorMessageMatch);
	}

	/**
	 * @description Will test that exception is thrown if the case doesn't
	 * have a single client's contact number
	 */
	@IsTest
	private static void failedIfClientContactNumberNotFound()
	{
		SC_API_AppointmentCaseSync.DTO_Request dtoRequest = generateRequestData();

		SC_API_AppointmentCaseSync.DTO_AppointmentCase dtoAppointmentCase = dtoRequest.cases.iterator().next();
		dtoAppointmentCase.client.cellularPhoneNumber = null;
		dtoAppointmentCase.client.workTelephoneNumber = null;
		dtoAppointmentCase.client.homeTelephoneNumber = null;

		assertServiceFailed(dtoRequest, SC_API_AppointmentCaseSync.ERROR_NO_CONTACT_NUMBER_FOUND);
	}

	/**
	 * @description Will test that exception is thrown if the case creation request doesn't
	 * have the client's surname
	 */
	@IsTest
	private static void failedIfClientLastNameNotFound()
	{
		SC_API_AppointmentCaseSync.DTO_Request dtoRequest = generateRequestData();

		SC_API_AppointmentCaseSync.DTO_AppointmentCase dtoAppointmentCase = dtoRequest.cases.iterator().next();
		dtoAppointmentCase.client.surname = null;

		assertServiceFailed(dtoRequest, SC_API_AppointmentCaseSync.ERROR_CLIENT_LAST_NAME_NOT_FOUND);
	}

	/**
	 * @description Will test that exception is thrown if the case creation request doesn't
	 * have the client's Suburb
	 */
	@IsTest
	private static void failedIfClientSuburbNotFound()
	{
		SC_API_AppointmentCaseSync.DTO_Request dtoRequest = generateRequestData();

		SC_API_AppointmentCaseSync.DTO_AppointmentCase dtoAppointmentCase = dtoRequest.cases.iterator().next();
		dtoAppointmentCase.client.suburb = null;

		assertServiceFailed(dtoRequest, SC_API_AppointmentCaseSync.ERROR_CLIENT_SUBURB_NOT_FOUND);
	}

	/**
	 * @description Will test that exception is thrown if the case creation request doesn't
	 * have the client's email
	 */
	@IsTest
	private static void failedIfClientConsultantCodeNotFound()
	{
		SC_API_AppointmentCaseSync.DTO_Request dtoRequest = generateRequestData();

		SC_API_AppointmentCaseSync.DTO_AppointmentCase dtoAppointmentCase = dtoRequest.cases.iterator().next();
		dtoAppointmentCase.consultant.code = null;

		assertServiceFailed(dtoRequest, SC_API_AppointmentCaseSync.ERROR_CONSULTANT_CODE_NOT_FOUND);
	}

	/**
	 * @description Will test that exception is thrown if the case doesn't
	 * have a client's ID number
	 */
	@IsTest
	private static void failedIfClientIdNotFound()
	{
		SC_API_AppointmentCaseSync.DTO_Request dtoRequest = generateRequestData();

		SC_API_AppointmentCaseSync.DTO_AppointmentCase dtoAppointmentCase = dtoRequest.cases.iterator().next();
		dtoAppointmentCase.client.identificationNumber = null;

		assertServiceFailed(dtoRequest, SC_API_AppointmentCaseSync.ERROR_ID_NUMBER_NOT_FOUND);
	}

	/**
	 * @description Will setup the RestContext & execute the service request
	 *
	 * @param request The DTO that represents the JSON sent in a request
	 */
	private static void assertServiceCompleted(SC_API_AppointmentCaseSync.DTO_Request request)
	{
		CMN_API_InboundTestHelper.setupRestContext(request);

		Test.startTest();

		SC_URL_AppointmentCaseSync.syncCase();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(SC_API_AppointmentCaseSync.SERVICE_NAME);
	}
	/**
	 * @description method generates the request data
	 *
	 * @return the DTO_Request
	 */
	private static SC_API_AppointmentCaseSync.DTO_Request generateRequestData()
	{
		SC_API_AppointmentCaseSync.DTO_Request request = new SC_API_AppointmentCaseSync.DTO_Request();
		List<SC_API_AppointmentCaseSync.DTO_AppointmentCase> requestCases = new List<SC_API_AppointmentCaseSync.DTO_AppointmentCase>();

		Account masterAccount = SC_DAL_Account.getAll().iterator().next();
		SC_ConsultantCodes__c consultantCode = SC_DAL_ConsultantCodes.getAll().iterator().next();
		WorkType workType = SC_DAL_DataFactory.createWorkType().iterator().next();
		workType.SC_WorkOrderRecordType__c = WORK_ORDER_RECORD_TYPE;
		workType.SC_WorkOrderLineItemRecordType__c = WORK_ORDER_LINE_ITEM_RECORD_TYPE;
		CMN_DAL_SObjectDomain.updateDBObject(workType);
		SC_ServiceType__c serviceType = SC_DAL_ServiceType.getAll().iterator().next();
		serviceType.SC_WorkType__c = workType.Id;
		CMN_DAL_SObjectDomain.updateDBObject(serviceType);
		User agent = CMN_DAL_DataFactory.insertUsers(SC_DAL_Profile.PROFILE_SERVICE_AGENT, INT_ONE).iterator().next();

		if(String.isBlank(agent.AW_UACFID__c) || String.isBlank(agent.AW_ConsultantCode__c))
		{
			agent.AW_UACFID__c = AW_DAL_User.generateRandomUACFId();
			agent.AW_ConsultantCode__c = consultantCode.Name;

			update agent;
		}

		//Case details
		SC_API_AppointmentCaseSync.DTO_CaseDetail caseDetail = new SC_API_AppointmentCaseSync.DTO_CaseDetail();
		caseDetail.commentText = CMN_DAL_SObjectDomain.generateRandomName();
		caseDetail.uacfId = agent.AW_UACFID__c;
		caseDetail.nurseRegion = CMN_DAL_SObjectDomain.generateRandomName();
		caseDetail.nurseSuburbOrTown = CMN_DAL_SObjectDomain.generateRandomName();
		caseDetail.serviceType = String.valueOf(serviceType.SC_ServiceType__c);
		caseDetail.caseNumber = CASE_NUMBER;

		//Client details

		SC_API_AppointmentCaseSync.DTO_Client client = new SC_API_AppointmentCaseSync.DTO_Client();
		client.identificationNumber = masterAccount.AW_IdentificationNumber__pc;
		client.gender = AW_UTIL_IdentityNumber.IDENTITY_GENDER_FEMALE;
		client.title = TITLE_MISS;
		client.surname = CMN_DAL_SObjectDomain.generateRandomName();
		client.suburb = CMN_DAL_SObjectDomain.generateRandomName();
		client.fullName = CMN_DAL_SObjectDomain.generateRandomName();
		client.addressLine1 = CMN_DAL_SObjectDomain.generateRandomName();
		client.addressLine2 = CMN_DAL_SObjectDomain.generateRandomName();
		client.alternativeCellularPhoneNumber = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		client.alternativeTelephoneNumber = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		client.cellularPhoneNumber = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		client.homeTelephoneNumber = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		client.workTelephoneNumber = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		client.pdbId = String.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber(INT_FOUR));
		//Consultant details
		SC_API_AppointmentCaseSync.DTO_Consultant consultant = new SC_API_AppointmentCaseSync.DTO_Consultant();
		consultant.cellularPhoneNumber = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		consultant.surname = CMN_DAL_SObjectDomain.generateRandomName();
		consultant.type = CMN_DAL_SObjectDomain.generateRandomName();
		consultant.code = consultantCode.Name;
		consultant.canBookMed = CMN_DAL_SObjectDomain.generateRandomBoolean() ? 'Y' : 'N';
		consultant.priority = SC_DAL_Case.PRIORITY_NORMAL;
		consultant.copyEmailAddress = CMN_DAL_SObjectDomain.generateRandomEmail();
		consultant.emailAddress = CMN_DAL_SObjectDomain.generateRandomEmail();
		consultant.initials = TITLE_MISS;
		consultant.telephoneNumber = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();

		SC_API_AppointmentCaseSync.DTO_AppointmentCase dtoAppointmentCase = new SC_API_AppointmentCaseSync.DTO_AppointmentCase();
		dtoAppointmentCase.caseDetail = caseDetail;
		dtoAppointmentCase.client = client;
		dtoAppointmentCase.consultant = consultant;
		requestCases.add(dtoAppointmentCase);

		request.cases = requestCases;
		return request;
	}
}