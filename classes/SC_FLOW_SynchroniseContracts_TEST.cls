/**
 * @description Test Class containing test methods for SC_FLOW_SynchroniseContracts
 *
 * @see SC_FLOW_SynchroniseContracts
 *
 * @author jason.van.beukering@accenture.com, jayanth.kumar.s@accenture.com, vishakha.saini@accenture.com
 *
 * @date February 2023, March 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class SC_FLOW_SynchroniseContracts_TEST
{
	private static final Integer NUMBER_OF_CONTRACTS_TO_GENERATE = 10;
	private static final String ASSERT_NO_ACCOUNTS_FOUND = 'No Accounts found';
	private static final String ASSERT_NO_POLICIES_FOUND = 'No Policies were found.';
	private static final String ASSERT_NO_ROLES_FOUND = 'No Roles found';
	private static final String ASSERT_NUMBER_INCORRECT = 'Incorrect number of accounts';
	private static final String ASSERT_NUMBER_OF_POLICIES = 'Not all policies were found.';
	private static final String EMPTY_SOBJECT_PRODUCT_AND_PROTO_CODE = '1002';
	private static final String EMPTY_SOBJECT_PRODUCT_API_NAME = 'AW_ProductCodeForBlankObject';
	private static final String INCORRECT_LOG = 'Event not logged as expected';
	private static final String INVALID_SOBJECT_PRODUCT_AND_PROTO_CODE = '1001';
	private static final String RELATIONSHIP_WIFE = 'Wife';
	private static final String TWENTY_PERCENT = '20';

	/**
	 * @description Will publish the events provided and immediately make sure they are delivered
	 *
	 * @param contractEvents The events to publish
	 */
	private static void executeEventTest(List<RSC_ContractEvent__e> contractEvents)
	{
		Test.startTest();

		EventBus.publish(contractEvents);
		Test.getEventBus().deliver();

		Test.stopTest();
	}

	/**
	 * @description Executes the invocable method with contract events
	 *
	 * @param dtoRequest The request to provide to the invocable method
	 * @param ignoreLogsForTest flag to indicate if the App log for test methods should be ignored or not
	 */
	private static void executeInvocableMethod(SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest, Boolean ignoreLogsForTest)
	{
		CMN_DAL_Logger.ignoreTestMode = ignoreLogsForTest;

		Test.startTest();

		SC_FLOW_SynchroniseContracts.synchroniseContracts
				(
						new List<RSC_ContractEvent__e>
						{
								new RSC_ContractEvent__e(RSC_ContractData__c = JSON.serialize(dtoRequest))
						}
				);

		Test.stopTest();
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is created
	 */
	@IsTest
	private static void insertNewInsurancePolicyLinkToPersonMaster()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.generateMasterDtoRequest(true, false, SC_DAL_InsurancePolicy.OBJECT_NAME);
		Id accountId = SC_DAL_Account.getAll().iterator().next().Id;
		SC_ConsultantCodes__c consultantCodes = SC_DAL_DataFactory.createConsultantCodes();
		dtoRequest.consultant_code = consultantCodes.Name;
		executeInvocableMethod(dtoRequest, false);

		List<InsurancePolicy> foundPolicies = SC_DAL_InsurancePolicy.findByMasterAccountId(accountId);
		Assert.isFalse(foundPolicies.isEmpty(), ASSERT_NO_POLICIES_FOUND);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is updated
	 */
	@IsTest
	private static void upsertNewInsurancePolicyLinkToPersonMaster()
	{
		Account foundAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		InsurancePolicy policy = SC_DAL_DataFactory.createInsurancePolicies(1, foundAccount.Id).iterator().next();
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.createDtoContractRequest();
		dtoRequest.policy_number = policy.Name;
		dtoRequest.client_national_id = foundAccount.AW_IdentificationNumber__pc;
		SC_DAL_DataFactory.assignRandomProductCode(dtoRequest, SC_DAL_InsurancePolicy.OBJECT_NAME);

		Id accountId = SC_DAL_Account.getAll().iterator().next().Id;
		SC_ConsultantCodes__c consultantCodes = SC_DAL_DataFactory.createConsultantCodes();
		dtoRequest.consultant_code = consultantCodes.Name;

		executeInvocableMethod(dtoRequest, false);

		List<InsurancePolicy> foundPolicies = SC_DAL_InsurancePolicy.findByMasterAccountId(accountId);
		Assert.isFalse(foundPolicies.isEmpty(), ASSERT_NO_POLICIES_FOUND);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is created
	 */
	@IsTest
	private static void insertNewInsurancePolicyLinkToPersonMasterWithParty()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest =
				SC_DAL_DataFactory.generateMasterDtoRequestWithParties(true, false, SC_DAL_InsurancePolicy.OBJECT_NAME, 1);

		Id accountId = SC_DAL_Account.getAll().iterator().next().Id;
		SC_ConsultantCodes__c consultantCodes = SC_DAL_DataFactory.createConsultantCodes();
		dtoRequest.consultant_code = consultantCodes.Name;

		executeInvocableMethod(dtoRequest, false);

		List<InsurancePolicy> foundPolicies = SC_DAL_InsurancePolicy.findByMasterAccountId(accountId);
		List<InsurancePolicyParticipant> insurancePolicyParticipants = SC_DAL_InsurancePolicyParticipant.findByParent(new Set<Id>
		{
				foundPolicies.iterator().next().Id
		});
		Assert.isFalse(foundPolicies.isEmpty(), ASSERT_NO_POLICIES_FOUND);
		Assert.isFalse(insurancePolicyParticipants.isEmpty(), 'No Participants were found.');
	}

	/**
	 * @description Will check that if adviser account is missing it will be created during sync operations
	 */
	@IsTest
	private static void insertMissingAdvisorAccount()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest =
				SC_DAL_DataFactory.generateMasterDtoRequestWithParties(true, false, SC_DAL_InsurancePolicy.OBJECT_NAME, 1);

		List<Account> foundAccounts = AW_DAL_Account.getAll();
		//Only the master account should exist
		Assert.areEqual(1, foundAccounts.size(), ASSERT_NUMBER_INCORRECT);

		Account masterAccount = foundAccounts.iterator().next();

		SC_ConsultantCodes__c consultantCode = SC_DAL_DataFactory.createConsultantCodesForExistingUser(AW_DAL_User.findRandomActiveAdviser().AW_ConsultantCode__c);
		dtoRequest.consultant_code = consultantCode.Name;

		executeInvocableMethod(dtoRequest, false);

		foundAccounts = AW_DAL_Account.findByIdentityNumber(new Set<String> {masterAccount.AW_IdentificationNumber__pc});
		//Master account and adviser account should exist
		Assert.areEqual(2, foundAccounts.size(), ASSERT_NUMBER_INCORRECT);

		String serviceName = AW_API_RestOutboundClientUpdated.SERVICE_NAME;

		//Check to see if we actually sent a prospect synchronisation outbound request
		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.findByServiceName(serviceName);

		Assert.isFalse(queueItems.isEmpty(), 'No QueueItems found for Service: "' + serviceName + '"');

		for(CMN_WebserviceCallQueue__c queueItem : queueItems)
		{
			//Check that the request didn't abort, we can't check that it completed as batch process is running synchronously and so fails
			Assert.isFalse(CMN_DAL_WebserviceCallQueue.STATUS_ABORTED.equalsIgnoreCase(queueItem.CMN_Status__c), 'Service was aborted Queue Item JSON: ' + JSON.serialize(queueItem));
		}
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Financial Account is updated
	 */
	@IsTest
	private static void upsertInsurancePolicyLinkToPersonMasterWithParties()
	{
		Account foundAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		InsurancePolicy policy = SC_DAL_DataFactory.createInsurancePolicies(foundAccount, 1).iterator().next();

		SC_ConsultantCodes__c consultantCode = SC_DAL_DataFactory.createConsultantCodes();
		Contact newContact = SC_DAL_Contact.findById(new Set<Id> {consultantCode.SC_ContactId__c}).iterator().next();

		AW_DAL_TestDataFactory.createInsurancePolicyParticipants(policy, new Set<String> {SC_FLOW_SynchroniseContracts.CONSULTANT_ROLE}, newContact, foundAccount).iterator().next();

		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest =
				SC_DAL_DataFactory.generateMasterDtoRequestWithParties(true, false, SC_DAL_InsurancePolicy.OBJECT_NAME, 1);

		dtoRequest.client_national_id = foundAccount.AW_IdentificationNumber__pc;
		dtoRequest.consultant_code = consultantCode.Name;
		dtoRequest.policy_number = policy.Name;

		dtoRequest.parties = generateParties();

		executeInvocableMethod(dtoRequest, false);

		List<InsurancePolicy> foundInsurancePolicies = SC_DAL_InsurancePolicy.findByMasterAccountId(foundAccount.Id);
		Assert.isFalse(foundInsurancePolicies.isEmpty(), ASSERT_NO_POLICIES_FOUND);

		List<InsurancePolicyParticipant> foundParticipants = SC_DAL_InsurancePolicyParticipant.findByParent(new Set<Id> {foundInsurancePolicies.iterator().next().Id});
		//3 roles via the payload, and role for consultant
		Assert.areEqual(4, foundParticipants.size(), 'Participants not inserted as expected');
	}

	/**
	 * @description Will check if the sync failed correctly, as there no valid product code and prototype provided
	 */
	@IsTest
	private static void failedCallForInvalidProductAndProtoCode()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.generateMasterDtoRequest(true, false, SC_DAL_InsurancePolicy.OBJECT_NAME);

		dtoRequest.product_type_code = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoRequest.proto_cd = CMN_DAL_SObjectDomain.generateRandomNumber();

		executeInvocableMethod(dtoRequest, true);

		CMN_AppLog__c newLog = CMN_DAL_AppLog.findByLogLevel(CMN_DAL_Logger.LEVEL_DEBUG).iterator().next();
		Assert.areEqual(newLog.CMN_Message__c, String.format(SC_FLOW_SynchroniseContracts.ERROR_NO_PRODUCT_CODE_FOUND,
				new List<Object> {dtoRequest.product_type_code, dtoRequest.proto_cd}),
				INCORRECT_LOG);
	}

	/**
	 * @description Will check if the sync failed correctly, as the Sobject is not of type Financial Account or Insurance Policy
	 */
	@IsTest
	private static void failedCallForInvalidSObject()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.generateMasterDtoRequest(true, false, SC_DAL_InsurancePolicy.OBJECT_NAME);

		dtoRequest.product_type_code = INVALID_SOBJECT_PRODUCT_AND_PROTO_CODE;
		dtoRequest.proto_cd = INVALID_SOBJECT_PRODUCT_AND_PROTO_CODE;

		executeInvocableMethod(dtoRequest, true);

		CMN_AppLog__c newLog = CMN_DAL_AppLog.findByLogLevel(CMN_DAL_Logger.LEVEL_DEBUG).iterator().next();
		Assert.areEqual(newLog.CMN_Message__c, String.format(SC_FLOW_SynchroniseContracts.ERROR_INVALID_SOBJECT, new List<Object> {CMN_DAL_Foobar.OBJECT_NAME}),
				INCORRECT_LOG);
	}

	/**
	 * @description Will check if the sync failed correctly, as there no client found in Salesforce
	 */
	@IsTest
	private static void failedCallForClientDoesntExist()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest =
				SC_DAL_DataFactory.generateMasterDtoRequestWithParties(true, false, SC_DAL_InsurancePolicy.OBJECT_NAME, 1);

		dtoRequest.policy_number = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoRequest.client_national_id = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();

		executeInvocableMethod(dtoRequest, true);

		CMN_AppLog__c newLog = CMN_DAL_AppLog.findByLogLevel(CMN_DAL_Logger.LEVEL_DEBUG).iterator().next();
		Assert.areEqual(newLog.CMN_Message__c, String.format(SC_FLOW_SynchroniseContracts.ERROR_NO_ACCOUNT_FOUND, new List<Object> {dtoRequest.client_national_id}),
				INCORRECT_LOG);
	}

	/**
	 * @description Will check if the sync failed correctly, as there no SObject information on the Product Code and Category Mapping metadata
	 */
	@IsTest
	private static void failedCallForEmptySObject()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.generateMasterDtoRequest(true, false, SC_DAL_InsurancePolicy.OBJECT_NAME);

		dtoRequest.product_type_code = EMPTY_SOBJECT_PRODUCT_AND_PROTO_CODE;
		dtoRequest.proto_cd = EMPTY_SOBJECT_PRODUCT_AND_PROTO_CODE;

		executeInvocableMethod(dtoRequest, true);

		CMN_AppLog__c newLog = CMN_DAL_AppLog.findByLogLevel(CMN_DAL_Logger.LEVEL_DEBUG).iterator().next();
		Assert.areEqual(newLog.CMN_Message__c, String.format(SC_FLOW_SynchroniseContracts.ERROR_CATEGORY_MAPPING_NULL_SOBJECT,
				new List<Object> {EMPTY_SOBJECT_PRODUCT_API_NAME}), INCORRECT_LOG);
	}

	/**
	 * @description Will check if the sync failed correctly, as there no client national id/passport/company trust number
	 */
	@IsTest
	private static void failedCallForNoClientInformation()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest =
				SC_DAL_DataFactory.generateMasterDtoRequestWithParties(true, false, SC_DAL_InsurancePolicy.OBJECT_NAME, 1);

		dtoRequest.client_national_id = CMN_UTIL_String.EMPTY;
		dtoRequest.client_passport_no = CMN_UTIL_String.EMPTY;
		dtoRequest.client_company_reg_no = CMN_UTIL_String.EMPTY;

		executeInvocableMethod(dtoRequest, true);

		CMN_AppLog__c newLog = CMN_DAL_AppLog.findByLogLevel(CMN_DAL_Logger.LEVEL_DEBUG).iterator().next();
		Assert.areEqual(newLog.CMN_Message__c, String.format(
				SC_FLOW_SynchroniseContracts.ERROR_NO_IDENTITY_NUMBER_PROVIDED, new List<Object> {dtoRequest.policy_number}),
				INCORRECT_LOG);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is created
	 */
	@IsTest
	private static void insertNewFinancialAccountLinkToPersonMasterWithParty()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest =
				SC_DAL_DataFactory.generateMasterDtoRequestWithParties(true, false, SC_DAL_FinancialAccount.OBJECT_NAME, 1);

		Id accountId = SC_DAL_Account.getAll().iterator().next().Id;
		SC_ConsultantCodes__c consultantCodes = SC_DAL_DataFactory.createConsultantCodes();
		dtoRequest.consultant_code = consultantCodes.Name;

		executeInvocableMethod(dtoRequest, false);

		List<FinServ__FinancialAccount__c> foundFinancialAccounts = SC_DAL_FinancialAccount.findByMasterAccountId(accountId);
		System.assertNotEquals(true, foundFinancialAccounts.isEmpty(), ASSERT_NO_POLICIES_FOUND);

		List<FinServ__FinancialAccountRole__c> foundRoles =
				SC_DAL_FinancialAccountRole.findByParentId(new Set<Id> {foundFinancialAccounts.iterator().next().Id});

		Assert.isFalse(foundRoles.isEmpty(), ASSERT_NO_ROLES_FOUND);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is created
	 */
	@IsTest
	private static void insertNewInsurancePolicyLinkToPersonNonMaster()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.generateNonMasterDtoRequest(true, false, SC_DAL_InsurancePolicy.OBJECT_NAME);

		executeInvocableMethod(dtoRequest, false);

		List<Account> accounts = SC_DAL_Account.findAccountByRecordTypeName(AW_DAL_Account.RT_PERSON_ACCOUNT);
		Assert.isFalse(accounts.isEmpty(), ASSERT_NO_ACCOUNTS_FOUND);
		List<InsurancePolicy> foundPolicies = SC_DAL_InsurancePolicy.findByMasterAccountId(accounts.iterator().next().AW_ParentAccount__c);
		Assert.isFalse(foundPolicies.isEmpty(), ASSERT_NO_POLICIES_FOUND);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is created
	 */
	@IsTest
	private static void insertNewFinancialAccountLinkToPersonNonMaster()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.generateNonMasterDtoRequest(true, false,
				SC_DAL_FinancialAccount.OBJECT_NAME);

		SC_FLOW_SynchroniseContracts.DTO_Party payerParty = new SC_FLOW_SynchroniseContracts.DTO_Party();
		payerParty.rel_party_firstname = CMN_DAL_SObjectDomain.generateRandomName();
		payerParty.rel_party_surname = CMN_DAL_SObjectDomain.generateRandomName();
		payerParty.role_type = SC_FLOW_SynchroniseContracts.PAYER_ROLE;
		payerParty.bank_acct_name = CMN_DAL_SObjectDomain.generateRandomNumber();

		dtoRequest.parties = new List<SC_FLOW_SynchroniseContracts.DTO_Party> {payerParty};

		executeInvocableMethod(dtoRequest, false);

		List<Account> accounts = SC_DAL_Account.findAccountByRecordTypeName(AW_DAL_Account.RT_PERSON_ACCOUNT);
		Assert.isFalse(accounts.isEmpty(), ASSERT_NO_ACCOUNTS_FOUND);
		List<FinServ__FinancialAccount__c> foundPolicies = SC_DAL_FinancialAccount.findByMasterAccountId(accounts.iterator().next().AW_ParentAccount__c);
		Assert.isFalse(foundPolicies.isEmpty(), ASSERT_NO_POLICIES_FOUND);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is created
	 */
	@IsTest
	private static void insertNewInsurancePolicyLinkToBusinessNonMaster()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.generateNonMasterDtoRequest(false, false,
				SC_DAL_InsurancePolicy.OBJECT_NAME);

		executeInvocableMethod(dtoRequest, false);

		List<Account> accounts = SC_DAL_Account.findAccountByRecordTypeName(AW_DAL_Account.RT_BUSINESS_ACCOUNT);
		Assert.isFalse(accounts.isEmpty(), ASSERT_NO_ACCOUNTS_FOUND);
		List<InsurancePolicy> foundPolicies = SC_DAL_InsurancePolicy.findByMasterAccountId(accounts.iterator().next().AW_ParentAccount__c);
		Assert.isFalse(foundPolicies.size() > 0, ASSERT_NO_POLICIES_FOUND);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is created
	 */
	@IsTest
	private static void insertNewInsurancePolicyLinkToPassportPersonMaster()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.generateMasterDtoRequest(true, true, SC_DAL_InsurancePolicy.OBJECT_NAME);

		executeInvocableMethod(dtoRequest, false);

		List<InsurancePolicy> foundPolicies = SC_DAL_InsurancePolicy.findByMasterAccountId(SC_DAL_Account.getAll().iterator().next().Id);
		Assert.isFalse(foundPolicies.isEmpty(), ASSERT_NO_POLICIES_FOUND);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is created
	 */
	@IsTest
	private static void insertNewInsurancePolicyLinkToBusinessMaster()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.generateMasterDtoRequest(false, null, SC_DAL_InsurancePolicy.OBJECT_NAME);

		executeInvocableMethod(dtoRequest, false);

		List<InsurancePolicy> foundPolicies = SC_DAL_InsurancePolicy.findByMasterAccountId(SC_DAL_Account.getAll().iterator().next().Id);
		Assert.isFalse(foundPolicies.isEmpty(), ASSERT_NO_POLICIES_FOUND);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is created
	 */
	@IsTest
	private static void insertNewInsurancePolicyLinkToPersonMasterEvent()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.generateMasterDtoRequest(true, false, SC_DAL_InsurancePolicy.OBJECT_NAME);
		executeEventTest(SC_DAL_DataFactory.generateContractEvents(new List<SC_FLOW_SynchroniseContracts.DTO_ContractRequest> {dtoRequest}));
		List<InsurancePolicy> foundPolicies = SC_DAL_InsurancePolicy.findByMasterAccountId(SC_DAL_Account.getAll().iterator().next().Id);
		Assert.isFalse(foundPolicies.isEmpty(), ASSERT_NO_POLICIES_FOUND);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Financial Account is created
	 */
	@IsTest
	private static void insertNewFinancialAccountLinkToPersonMaster()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.generateMasterDtoRequest(true, false, SC_DAL_FinancialAccount.OBJECT_NAME);

		executeInvocableMethod(dtoRequest, false);

		List<FinServ__FinancialAccount__c> foundFinancialAccounts = SC_DAL_FinancialAccount.findByMasterAccountId(SC_DAL_Account.getAll().iterator().next().Id);
		Assert.isFalse(foundFinancialAccounts.isEmpty(), ASSERT_NO_POLICIES_FOUND);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Financial Account is updated
	 */
	@IsTest
	private static void upsertNewFinancialAccountLinkToPersonMaster()
	{
		Account foundAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		FinServ__FinancialAccount__c policy = SC_DAL_DataFactory.createFinancialAccounts(foundAccount, 1).iterator().next();
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.createDtoContractRequest();
		dtoRequest.policy_number = policy.FinServ__FinancialAccountNumber__c;
		dtoRequest.client_national_id = foundAccount.AW_IdentificationNumber__pc;
		SC_DAL_DataFactory.assignRandomProductCode(dtoRequest, SC_DAL_FinancialAccount.OBJECT_NAME);
		dtoRequest.frequency = SC_DAL_DataFactory.WEEKLY_FREQUENCY;

		executeInvocableMethod(dtoRequest, false);

		List<FinServ__FinancialAccount__c> foundFinancialAccounts = SC_DAL_FinancialAccount.findByMasterAccountId(SC_DAL_Account.getAll().iterator().next().Id);
		Assert.isFalse(foundFinancialAccounts.isEmpty(), ASSERT_NO_POLICIES_FOUND);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Financial Account is updated
	 */
	@IsTest
	private static void upsertNewFinancialAccountLinkToPersonMasterWithParties()
	{
		Account foundAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		FinServ__FinancialAccount__c policy = SC_DAL_DataFactory.createFinancialAccounts(foundAccount, 1).iterator().next();

		SC_ConsultantCodes__c consultantCodes = SC_DAL_DataFactory.createConsultantCodes();
		Contact newContact = SC_DAL_Contact.findById(new Set<Id> {consultantCodes.SC_ContactId__c}).iterator().next();

		AW_DAL_TestDataFactory.createFinancialAccountRoles(foundAccount, newContact, policy, new Set<String> {SC_FLOW_SynchroniseContracts.CONSULTANT_ROLE}, null).iterator().next();

		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest =
				SC_DAL_DataFactory.generateMasterDtoRequestWithParties(true, false, SC_DAL_FinancialAccount.OBJECT_NAME, 1);
		dtoRequest.client_national_id = foundAccount.AW_IdentificationNumber__pc;
		dtoRequest.consultant_code = consultantCodes.Name;
		dtoRequest.policy_number = policy.FinServ__FinancialAccountNumber__c;

		dtoRequest.parties = generateParties();

		executeInvocableMethod(dtoRequest, false);

		List<FinServ__FinancialAccount__c> foundFinancialAccounts = SC_DAL_FinancialAccount.findByMasterAccountId(foundAccount.Id);
		Assert.isFalse(foundFinancialAccounts.isEmpty(), ASSERT_NO_POLICIES_FOUND);

		List<FinServ__FinancialAccountRole__c> foundRoles = SC_DAL_FinancialAccountRole.findByParentId(new Set<Id> {foundFinancialAccounts.iterator().next().Id});
		//3 roles via the payload, and role for consultant and the default Primary Owner Role
		Assert.areEqual(5, foundRoles.size(), 'Roles not inserted as expected');
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Financial Account is created
	 */
	@IsTest
	private static void insertNewFinancialAccountLinkToPersonMasterEvent()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.generateMasterDtoRequest(true, false, SC_DAL_FinancialAccount.OBJECT_NAME);
		dtoRequest.frequency = SC_DAL_DataFactory.WEEKLY_FREQUENCY;

		executeEventTest(SC_DAL_DataFactory.generateContractEvents(new List<SC_FLOW_SynchroniseContracts.DTO_ContractRequest> {dtoRequest}));

		List<FinServ__FinancialAccount__c> foundFinancialAccounts = SC_DAL_FinancialAccount.findByMasterAccountId(SC_DAL_Account.getAll().iterator().next().Id);
		Assert.isFalse(foundFinancialAccounts.isEmpty(), ASSERT_NO_POLICIES_FOUND);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is created
	 */
	@IsTest
	private static void insertMultipleNewInsurancePolicyLinkToPersonMaster()
	{
		List<SC_FLOW_SynchroniseContracts.DTO_ContractRequest> dtoRequests =
				SC_DAL_DataFactory.generateMasterPersonIdDtoRequests(NUMBER_OF_CONTRACTS_TO_GENERATE, SC_DAL_InsurancePolicy.OBJECT_NAME);

		CMN_DAL_Logger.ignoreTestMode = false;

		Test.startTest();

		SC_FLOW_SynchroniseContracts.synchroniseContracts(SC_DAL_DataFactory.generateContractEvents(dtoRequests));

		Test.stopTest();

		List<InsurancePolicy> foundPolicies = SC_DAL_InsurancePolicy.getAll();
		Assert.isFalse(foundPolicies.isEmpty(), ASSERT_NO_POLICIES_FOUND);
		Assert.areEqual(NUMBER_OF_CONTRACTS_TO_GENERATE, foundPolicies.size(), ASSERT_NUMBER_OF_POLICIES);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is created
	 */
	@IsTest
	private static void insertMultipleNewFinancialAccountLinkToPersonMaster()
	{
		List<SC_FLOW_SynchroniseContracts.DTO_ContractRequest> dtoRequests =
				SC_DAL_DataFactory.generateMasterPersonIdDtoRequests(NUMBER_OF_CONTRACTS_TO_GENERATE, SC_DAL_FinancialAccount.OBJECT_NAME);

		for(SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest : dtoRequests)
		{
			dtoRequest.frequency = SC_DAL_DataFactory.WEEKLY_FREQUENCY;
		}

		CMN_DAL_Logger.ignoreTestMode = false;

		Test.startTest();

		SC_FLOW_SynchroniseContracts.synchroniseContracts(SC_DAL_DataFactory.generateContractEvents(dtoRequests));

		Test.stopTest();

		List<FinServ__FinancialAccount__c> foundPolicies = SC_DAL_FinancialAccount.getAll();
		Assert.isFalse(foundPolicies.isEmpty(), ASSERT_NO_POLICIES_FOUND);
		Assert.areEqual(NUMBER_OF_CONTRACTS_TO_GENERATE, foundPolicies.size(), ASSERT_NUMBER_OF_POLICIES);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is created
	 */
	@IsTest
	private static void insertMultipleNewInsurancePolicyLinkToPersonMasterEvent()
	{
		List<SC_FLOW_SynchroniseContracts.DTO_ContractRequest> dtoRequests =
				SC_DAL_DataFactory.generateMasterPersonIdDtoRequests(NUMBER_OF_CONTRACTS_TO_GENERATE, SC_DAL_InsurancePolicy.OBJECT_NAME);

		List<RSC_ContractEvent__e> contractEvents = SC_DAL_DataFactory.generateContractEvents(dtoRequests);

		executeEventTest(contractEvents);

		List<InsurancePolicy> foundPolicies = SC_DAL_InsurancePolicy.getAll();
		Assert.isFalse(foundPolicies.isEmpty(), ASSERT_NO_POLICIES_FOUND);
		Assert.areEqual(NUMBER_OF_CONTRACTS_TO_GENERATE, foundPolicies.size(), ASSERT_NUMBER_OF_POLICIES);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is created
	 */
	@IsTest
	private static void insertMultipleNewFinancialAccountLinkToPersonMasterEvent()
	{
		List<SC_FLOW_SynchroniseContracts.DTO_ContractRequest> dtoRequests =
				SC_DAL_DataFactory.generateMasterPersonIdDtoRequests(NUMBER_OF_CONTRACTS_TO_GENERATE, SC_DAL_FinancialAccount.OBJECT_NAME);

		List<RSC_ContractEvent__e> contractEvents = SC_DAL_DataFactory.generateContractEvents(dtoRequests);

		executeEventTest(contractEvents);

		List<FinServ__FinancialAccount__c> foundPolicies = SC_DAL_FinancialAccount.getAll();
		Assert.isFalse(foundPolicies.isEmpty(), ASSERT_NO_POLICIES_FOUND);
		Assert.areEqual(NUMBER_OF_CONTRACTS_TO_GENERATE, foundPolicies.size(), ASSERT_NUMBER_OF_POLICIES);
	}

	/**
	 * @description Will check that Master account is correctly matched and relevant Policy is created
	 */
	@IsTest
	private static void linkNonMasterAccountToMasterAccount()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest = SC_DAL_DataFactory.generateNonMasterDtoRequest(true, false,
				SC_DAL_InsurancePolicy.OBJECT_NAME);

		User activeAdvisor = AW_DAL_User.findRandomActiveAdviser();

		Account orphanAccount = new Account();
		orphanAccount.Id = SC_DAL_Account.findAccountByRecordTypeName(AW_DAL_Account.RT_PERSON_ACCOUNT).iterator().next().Id;
		orphanAccount.AW_ParentAccount__c = null;
		orphanAccount.OwnerId = activeAdvisor.Id;
		update orphanAccount;

		dtoRequest.consultant_code = activeAdvisor.AW_ConsultantCode__c;

		executeInvocableMethod(dtoRequest, false);

		List<Account> accounts = SC_DAL_Account.findAccountByRecordTypeName(AW_DAL_Account.RT_PERSON_ACCOUNT);
		Assert.isFalse(accounts.isEmpty(), ASSERT_NO_ACCOUNTS_FOUND);
		List<InsurancePolicy> foundPolicies = SC_DAL_InsurancePolicy.findByMasterAccountId(accounts.iterator().next().AW_ParentAccount__c);
		Assert.isFalse(foundPolicies.isEmpty(), ASSERT_NO_POLICIES_FOUND);
		Assert.isNotNull(accounts.iterator().next().AW_ParentAccount__c, 'MasterAccount not linked as expected');
	}

	/**
	 * @description method to generate parties/roles for both financial account or Insurance policy.
	 *
	 * @return list of parties to be linked to financial account/insurance policy
	 */
	private static List<SC_FLOW_SynchroniseContracts.DTO_Party> generateParties()
	{
		SC_FLOW_SynchroniseContracts.DTO_Party primaryLifeAssuredParty = new SC_FLOW_SynchroniseContracts.DTO_Party();
		primaryLifeAssuredParty.rel_party_firstname = CMN_DAL_SObjectDomain.generateRandomName();
		primaryLifeAssuredParty.rel_party_surname = CMN_DAL_SObjectDomain.generateRandomName();
		primaryLifeAssuredParty.role_type = SC_FLOW_SynchroniseContracts.RELATED_TO_PRIMARY;

		SC_FLOW_SynchroniseContracts.DTO_Party primaryLifeAssuredBeneficiaryParty = new SC_FLOW_SynchroniseContracts.DTO_Party();
		primaryLifeAssuredBeneficiaryParty.beneficiary_percentage = TWENTY_PERCENT;
		primaryLifeAssuredBeneficiaryParty.rel_party_firstname = CMN_DAL_SObjectDomain.generateRandomName();
		primaryLifeAssuredBeneficiaryParty.rel_party_surname = CMN_DAL_SObjectDomain.generateRandomName();
		primaryLifeAssuredBeneficiaryParty.relatedto = SC_FLOW_SynchroniseContracts.RELATED_TO_PRIMARY;
		primaryLifeAssuredBeneficiaryParty.relationship = RELATIONSHIP_WIFE;
		primaryLifeAssuredBeneficiaryParty.role_type = SC_FLOW_SynchroniseContracts.BENEFICIARY_ROLE;

		SC_FLOW_SynchroniseContracts.DTO_Party partyWithCompany = new SC_FLOW_SynchroniseContracts.DTO_Party();
		partyWithCompany.rel_party_firstname = CMN_DAL_SObjectDomain.generateRandomName();
		partyWithCompany.rel_party_surname = CMN_DAL_SObjectDomain.generateRandomName();
		partyWithCompany.role_type = SC_UTIL_Contracts.ROLE_PAYEE;
		partyWithCompany.rel_party_company_reg_no = CMN_DAL_SObjectDomain.generateRandomNumber();

		SC_FLOW_SynchroniseContracts.DTO_Party partyWithNoName = new SC_FLOW_SynchroniseContracts.DTO_Party();
		partyWithNoName.role_type = SC_UTIL_Contracts.ROLE_PAYEE;
		partyWithNoName.rel_party_company_reg_no = CMN_DAL_SObjectDomain.generateRandomNumber();

		return new List<SC_FLOW_SynchroniseContracts.DTO_Party> {primaryLifeAssuredParty, primaryLifeAssuredBeneficiaryParty, partyWithCompany, partyWithNoName};
	}

}