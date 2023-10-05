/**
 * @description Will test the inbound service class AW_API_SynchroniseContracts
 *
 * @see AW_API_SynchroniseContracts
 * @see AW_URL_Contract
 *
 * @author vishakha.saini@accenture.com, jason.van.beukering@accenture.com
 *
 * @date November 2021, June 2023
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity,PMD.NcssTypeCount')
@IsTest(SeeAllData=false IsParallel=false)
private class AW_API_SynchroniseContracts_TEST
{
	private static FinServ__FinancialAccount__c financialAccountToBeDeleted;
	private static FinServ__FinancialAccount__c financialAccountToBeUpdated;
	private static InsurancePolicy policyToBeDeleted;
	private static InsurancePolicy policyToBeUpdated;
	private static final CMN_DAL_SObjectUnitOfWork UNIT_OF_WORK = new CMN_DAL_SObjectUnitOfWork();
	private static final Integer INT_FOUR = 4;
	private static final Integer INT_ONE = 1;
	private static final Integer INT_SIX = 6;
	private static final Integer INT_TEN = 10;
	private static final Integer INT_THREE = 3;
	private static final Integer INT_TWO = 2;
	private static final List<User> FOUND_ADVISERS = AW_DAL_User.findRandomActiveAdvisers(INT_TWO);
	private static final String ASSERT_INCORRECT_ITEM_COUNT = 'Incorrect number of Items';
	private static final String ASSERT_MISSING = ' missing';
	private static final String ASSERT_RECORD_NULL = 'Record should not be null';
	private static final String ASSERT_STATUS_NOT_UPDATED = 'Status not updated.';
	private static final String ASSERT_WARNING_INCORRECT = 'Warning not logged as expected';
	private static final String CONSULTANT_TYPE_CODE = 'CONS';
	private static final String FINANCIAL_PROTECTOR = 'FINANCIAL PROTECTOR';
	private static final String FUNERAL_BENEFIT = 'FUNERAL BENEFIT';
	private static final String INCEPTION_TYPE_CODE = 'Standard (Now Random)';
	private static final String INDICATOR_NO = 'N';
	private static final String INDICATOR_YES = 'Y';
	private static final String INDIVIDUAL_ID_TYPE = 'saNationalIdNumber';
	private static final String INTERMEDIATE_POLICY = '1';
	private static final String LIFE_ASSURED = 'Life Assured';
	private static final String LIFE_ASSURED_TYPE_CODE = 'LIFE_ASSD';
	private static final String OFFSHORE_INVESTMENT_PLAN_ICB = 'Offshore Investment Plan (ICB)';
	private static final String ORPHAN_POLICY = '0';
	private static final String PAYMENT_METHOD = 'SO';
	private static final String PREMIUM_FREQUENCY = 'Monthly';
	private static final String STR_HUNDRED = '100';
	private static final String STR_INVALID_PROTO_CODE = '1000';
	private static final String STR_ONE = '1';
	private static final String TITLE_MR = 'Mr.';
	private static final String TRUST_REGISTRATION_NUMBER = 'Trust Registration Number';
	private static final String UNIVERSAL_LIFE = 'UNIVERSAL LIFE';

	/**
	 * @description Will create all the information required to test contract synchronisation for financial accounts
	 *
	 * @return A list of newly created accounts with associated financial accounts
	 */
	private static List<Account> createFinancialAccounts()
	{
		return createAccountWithChildren(true, false, true);
	}

	/**
	 * @description Will create all the information required to test contract synchronisation for financial accounts
	 *
	 * @param isNonTideAdviser flag to indicate if non tide advisers are required
	 * @param isBusinessAccount flag to indicate to create business or individual accounts
	 * @param isFinancialAccount flag to indicate to create Financial Account or Insurance Policies
	 *
	 * @return A list of newly created accounts with associated financial accounts
	 */
	private static List<Account> createAccountWithChildren(Boolean isNonTideAdviser, Boolean isBusinessAccount, Boolean isFinancialAccount)
	{
		UNIT_OF_WORK.addSObjectTypes(new List<Schema.SObjectType>
		{
				Account.SObjectType, Contact.SObjectType,
				SC_ConsultantCodes__c.SObjectType,
				FinServ__FinancialAccount__c.SObjectType,
				FinServ__FinancialAccountRole__c.SObjectType,
				FinServ__FinancialHolding__c.SObjectType,
				InsurancePolicy.SObjectType,
				InsurancePolicyParticipant.SObjectType,
				InsurancePolicyCoverage.SObjectType
		});

		Account practiceAccount = RSC_DAL_TestDataFactory.newPracticeAccounts(SC_DAL_Account.RT_PRACTICE, INT_ONE).iterator().next();
		practiceAccount.Name = SC_DAL_Account.ACTIVE_ADVISER_ACCOUNT;

		UNIT_OF_WORK.registerNew(practiceAccount);

		List<Contact> practiceContacts = RSC_DAL_TestDataFactory.newPracticeContacts(SC_DAL_Contact.RT_ADVISER, INT_TWO, practiceAccount);

		for(Contact practiceContact : practiceContacts)
		{
			UNIT_OF_WORK.registerNew(practiceContact, Contact.AccountId, practiceAccount);
		}

		Contact practiceContact = practiceContacts.iterator().next();

		List<SC_ConsultantCodes__c> newCodes = RSC_DAL_TestDataFactory.newConsultantCodeRecords(practiceContact.Id, INT_TWO, true);

		for(Integer i = 0; i < newCodes.size(); i++)
		{
			SC_ConsultantCodes__c newCode = newCodes[i];
			newCode.Name = FOUND_ADVISERS[i].AW_ConsultantCode__c;

			UNIT_OF_WORK.registerNew(newCode, SC_ConsultantCodes__c.SC_ContactId__c, practiceContacts[i]);
		}

		SC_ConsultantCodes__c newNonTideCode;
		Contact practiceContactsForNonTideAdviser;

		if(isNonTideAdviser)
		{
			practiceContactsForNonTideAdviser = RSC_DAL_TestDataFactory.newPracticeContacts(SC_DAL_Contact.RT_ADVISER, INT_ONE, practiceAccount).iterator().next();
			UNIT_OF_WORK.registerNew(practiceContactsForNonTideAdviser);

			newNonTideCode = RSC_DAL_TestDataFactory.newConsultantCodeRecords(practiceContactsForNonTideAdviser.Id, INT_ONE, true).iterator().next();
			UNIT_OF_WORK.registerNew(newNonTideCode, SC_ConsultantCodes__c.SC_ContactId__c, practiceContactsForNonTideAdviser);
		}

		List<Account> newAccounts = new List<Account>();

		if(isBusinessAccount)
		{
			Account masterBusinessAccount = AW_DAL_TestDataFactory.newBusinessAccount(AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT);
			UNIT_OF_WORK.registerNew(masterBusinessAccount);
			newAccounts.add(masterBusinessAccount);

			createChildren(masterBusinessAccount, practiceContactsForNonTideAdviser, newNonTideCode, isFinancialAccount);
		}
		else
		{
			Account newAccountWithMaster = createPersonChildAccountWithMaster(FOUND_ADVISERS[0]);
			createChildren(newAccountWithMaster, practiceContacts[1], newNonTideCode, isFinancialAccount);
			newAccounts.add(newAccountWithMaster);

			Account newAccount = AW_DAL_TestDataFactory.newPersonAccount(AW_DAL_Account.RT_PERSON_ACCOUNT, newAccountWithMaster.AW_IdentificationNumber__pc);
			newAccount.AW_BypassValidationRules__c = true;
			newAccount.OwnerId = FOUND_ADVISERS[1].Id;
			UNIT_OF_WORK.registerNew(newAccount);

			if(isFinancialAccount)
			{
				FinServ__FinancialAccount__c financialAccount = SC_DAL_DataFactory.newFinancialAccounts(newAccount, INT_ONE).iterator().next();
				UNIT_OF_WORK.registerNew(financialAccount, FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c, newAccount);
			}
			else
			{
				InsurancePolicy policy = SC_DAL_DataFactory.newInsurancePolicies(newAccount, INT_ONE).iterator().next();
				UNIT_OF_WORK.registerNew(policy, InsurancePolicy.NameInsuredId, newAccount);
			}

			newAccounts.add(newAccount);
		}

		UNIT_OF_WORK.commitWork();
		return newAccounts;
	}

	/**
	 * @description Will check that associated contracts are created on cases as expected
	 *
	 * @see SC_UTIL_Contracts.addMissingAssociatedContracts
	 * @see SC_UTIL_Contracts.MissingContractsCacheHandler
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void addMissingAssociatedContracts()
	{
		Id accountId = createAccountWithChildren(true, true, true).iterator().next().Id;
		List<FinServ__FinancialAccount__c> foundFinancialAccounts = AW_DAL_FinancialAccount.findByPrimaryOwnerWithChildDetails(new Set<Id> {accountId});

		Set<String> contractNumbers = CMN_UTIL_System.extractSetValues(foundFinancialAccounts, SC_DAL_FinancialAccount.FIELD_FINANCIAL_ACCOUNT_NUMBER);

		Id caseId = SC_DAL_DataFactory.createCase(INT_ONE, accountId).iterator().next().Id;

		SC_UTIL_Contracts.MissingContractsCacheHandler cacheHandler = new SC_UTIL_Contracts.MissingContractsCacheHandler();
		cacheHandler.addMissingContracts(accountId, caseId, contractNumbers);
		cacheHandler.persistToCache();

		Test.startTest();

		SC_UTIL_Contracts.addMissingAssociatedContracts(new Set<Id> {accountId});

		Test.stopTest();

		assertAssociatedContractCreated(caseId, contractNumbers);
	}

	/**
	 * @description Will check that for the given Case and policies, missing associated contract records were created
	 *
	 * @param caseId Id of the case to check
	 * @param contractNumbers The list of missing contract numbers
	 */
	private static void assertAssociatedContractCreated(Id caseId, Set<String> contractNumbers)
	{
		List<SC_AssociatedContract__c> foundAssociatedContracts = SC_DAL_AssociatedContract.findByCaseId(new Set<Id> {caseId});
		Assert.isFalse(foundAssociatedContracts.isEmpty(), 'No items created.');
		Assert.areEqual(contractNumbers.size(), foundAssociatedContracts.size(), 'Incorrect number of items created');
	}

	/**
	 * @description Will check that no DUPLICATE associated contracts are created
	 *
	 * @see SC_UTIL_Contracts.addMissingAssociatedContracts
	 * @see SC_UTIL_Contracts.MissingContractsCacheHandler
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void checkDuplicateAssociatedContractsAreNotCreated()
	{
		Id accountId = createAccountWithChildren(true, true, false).iterator().next().Id;
		List<InsurancePolicy> foundPolicies = AW_DAL_InsurancePolicy.findChildrenByAccountId(new Set<Id> {accountId});

		Id caseId = SC_DAL_DataFactory.createCase(INT_ONE, accountId).iterator().next().Id;

		List<SC_AssociatedContract__c> newAssociatedContracts = new List<SC_AssociatedContract__c>();
		Set<String> contractNumbers = new Set<String>();

		//Make sure we create associated contracts for policies below
		for(InsurancePolicy foundPolicy : foundPolicies)
		{
			contractNumbers.add(foundPolicy.Name);
			newAssociatedContracts.addAll(newAssociatedContracts(caseId, INT_ONE, null, foundPolicy.Id));
		}

		insert newAssociatedContracts;

		//Log that we have missing policies (even though we have created associated contracts), we expect no new Associated contracts to be added
		SC_UTIL_Contracts.MissingContractsCacheHandler cacheHandler = new SC_UTIL_Contracts.MissingContractsCacheHandler();
		cacheHandler.addMissingContracts(accountId, caseId, contractNumbers);
		cacheHandler.persistToCache();

		Test.startTest();

		SC_UTIL_Contracts.addMissingAssociatedContracts(new Set<Id> {accountId});
		//Run this twice to see if calling this multiple times doesn't create duplicates either
		SC_UTIL_Contracts.addMissingAssociatedContracts(new Set<Id> {accountId});

		Test.stopTest();

		assertAssociatedContractCreated(caseId, contractNumbers);
	}

	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void createAdviserBusinessAccount()
	{
		Account businessAccount = createAccountWithChildren(true, true, true).iterator().next();
		List<FinServ__FinancialAccount__c> foundFinancialAccounts = AW_DAL_FinancialAccount.findByPrimaryOwnerWithChildDetails(new Set<Id> {businessAccount.Id});
		processFinancialAccounts(foundFinancialAccounts, businessAccount.Id);

		AW_API_SynchroniseContracts.DTO_Request dtoRequest = new AW_API_SynchroniseContracts.DTO_Request();
		List<AW_API_SynchroniseContracts.DTO_Contract> dtoContracts = new List<AW_API_SynchroniseContracts.DTO_Contract>();

		dtoRequest.identificationNumber = businessAccount.AW_CompanyRegistrationTrustNumber__c;
		dtoRequest.identificationNumberType = TRUST_REGISTRATION_NUMBER;

		dtoContracts.addAll(populateContractsDTO(dtoRequest, financialAccountToBeUpdated, FOUND_ADVISERS[0]));
		dtoRequest.contracts = dtoContracts;

		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Set<String> contractNumbers = CMN_UTIL_System.extractSetValues(foundFinancialAccounts, SC_DAL_FinancialAccount.FIELD_FINANCIAL_ACCOUNT_NUMBER);

		Id caseId = SC_DAL_DataFactory.createCase(INT_ONE, businessAccount.Id).iterator().next().Id;
		SC_UTIL_Contracts.MissingContractsCacheHandler cacheHandler = new SC_UTIL_Contracts.MissingContractsCacheHandler();
		cacheHandler.addMissingContracts(businessAccount.Id, caseId, contractNumbers);
		cacheHandler.persistToCache();

		List<Account> foundAccount = AW_DAL_Account.findByIdentityNumber(new Set<String> {businessAccount.AW_CompanyRegistrationTrustNumber__c});
		Assert.areEqual(INT_ONE, foundAccount.size(), ASSERT_INCORRECT_ITEM_COUNT);

		List<FinServ__FinancialAccount__c> foundPolicies = AW_DAL_FinancialAccount.findByPrimaryOwnerWithChildDetails(new Set<Id> {businessAccount.Id});
		Assert.areEqual(INT_ONE, foundPolicies.size(), ASSERT_INCORRECT_ITEM_COUNT);

		List<FinServ__FinancialAccountRole__c> foundRoles = SC_DAL_FinancialAccountRole.findByParentId(new Set<Id> {foundPolicies.iterator().next().Id});
		Assert.areEqual(INT_FOUR, foundRoles.size(), ASSERT_INCORRECT_ITEM_COUNT);

		Test.startTest();

		AW_URL_Contract.synchroniseContracts();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_SynchroniseContracts.SERVICE_NAME);

		Assert.isFalse(AW_DAL_Account.findActiveBusinessChildBySkfId(businessAccount.AW_SKF_Id__c).isEmpty(), 'Adviser Client Account not created as expected');

		String serviceName = AW_API_RestOutboundClientUpdated.SERVICE_NAME;

		//Check to see if we actually sent a prospect synchronisation outbound request
		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.findByServiceName(serviceName);

		Assert.isFalse(queueItems.isEmpty(), 'No QueueItems found for Service: "' + serviceName + '"');

		for(CMN_WebserviceCallQueue__c queueItem : queueItems) //noinspection DuplicatedCode
		{
			//Check that the request didn't abort, we can't check that it completed as batch process is running synchronously and so fails
			Assert.isFalse(CMN_DAL_WebserviceCallQueue.STATUS_ABORTED.equalsIgnoreCase(queueItem.CMN_Status__c), 'Service was aborted Queue Item JSON: ' + JSON.serialize(queueItem));
		}

		assertAssociatedContractCreated(caseId, contractNumbers);
	}

	/**
	 * @description Will tests that financial accounts are upserted or deleted correctly
	 *
	 * @see AW_API_SynchroniseContracts.upsertFinancialAccounts
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void synchroniseFinancialAccounts()
	{
		List<Account> newAccounts = createFinancialAccounts();

		//Only 2 accounts will be created, the first one has FA's that must be updated or inserted
		Account accountToBeUpdated = newAccounts.iterator().next();

		Set<Id> accountIds = CMN_UTIL_System.extractListIds(newAccounts);
		List<FinServ__FinancialAccount__c> foundAccounts = AW_DAL_FinancialAccount.findByPrimaryOwnerWithChildDetails(accountIds);
		processFinancialAccounts(foundAccounts, accountToBeUpdated.Id);

		//Creating DTORequest which will contain some contracts who will update the existing contracts, create new contracts and delete the non-updated contracts.
		AW_API_SynchroniseContracts.DTO_Request dtoRequest = populateFinancialAccountDTO(accountToBeUpdated, financialAccountToBeUpdated);
		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		// Financial Account Roles - Verifying the created data before the testing
		List<FinServ__FinancialAccountRole__c> newRoles = financialAccountToBeUpdated.FinServ__FinancialAccountRoles__r;
		Map<String, SObject> newRolesMap = CMN_UTIL_System.convertListToSingleStringMap(newRoles, AW_DAL_FinancialAccountRole.FIELD_ROLE);

		Assert.isTrue(newRolesMap.containsKey(AW_API_SynchroniseContracts.CONSULTANT_ROLE), AW_API_SynchroniseContracts.CONSULTANT_ROLE + ' Role missing');
		Assert.isTrue(newRolesMap.containsKey(SC_FLOW_SynchroniseContracts.PAYER_ROLE), SC_FLOW_SynchroniseContracts.PAYER_ROLE + ' Role missing');

		// Financial Holdings - Verifying the created data before the testing
		List<FinServ__FinancialHolding__c> newHoldings = financialAccountToBeUpdated.FinServ__FinancialHoldings__r;
		Assert.areEqual(INT_TWO, newHoldings.size(), 'Incorrect Number of Holdings');

		Test.startTest();

		AW_URL_Contract.synchroniseContracts();
		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_SynchroniseContracts.SERVICE_NAME);

		Test.stopTest();

		Account foundAccount = AW_DAL_Account.findById(accountToBeUpdated.Id);
		Assert.areNotEqual(accountToBeUpdated.AW_PoliciesRefreshStatus__c, foundAccount.AW_PoliciesRefreshStatus__c, ASSERT_STATUS_NOT_UPDATED);

		List<FinServ__FinancialAccount__c> foundFinancialAccounts = AW_DAL_FinancialAccount.findByPrimaryOwnerWithChildDetails(new Set<Id> {foundAccount.Id});
		Assert.areEqual(INT_THREE, foundFinancialAccounts.size(), ASSERT_INCORRECT_ITEM_COUNT);

		Map<Id, FinServ__FinancialAccount__c> financialAccountByIdMap = new Map<Id, FinServ__FinancialAccount__c>(foundFinancialAccounts);
		FinServ__FinancialAccount__c mapRemovedFinancialAccount = financialAccountByIdMap.remove(financialAccountToBeUpdated.Id);
		Assert.isNotNull(mapRemovedFinancialAccount, ASSERT_RECORD_NULL);

		Map<String, SObject> financialAccountRoleMap =
				CMN_UTIL_System.convertListToSingleStringMap(mapRemovedFinancialAccount.FinServ__FinancialAccountRoles__r, AW_DAL_FinancialAccountRole.FIELD_ROLE);
		Assert.isFalse(financialAccountRoleMap.containsKey(SC_FLOW_SynchroniseContracts.PAYER_ROLE), 'Payer role should have been removed');

		FinServ__FinancialAccount__c remainingFinancialAccount = financialAccountByIdMap.values().iterator().next();
		List<FinServ__FinancialAccountRole__c> remainingFinancialAccountRoles = remainingFinancialAccount.FinServ__FinancialAccountRoles__r;
		Assert.areEqual(INT_FOUR, remainingFinancialAccountRoles.size(), ASSERT_INCORRECT_ITEM_COUNT);

		List<FinServ__FinancialHolding__c> removedFinancialAccountHoldings = mapRemovedFinancialAccount.FinServ__FinancialHoldings__r;
		Assert.areEqual(INT_SIX, removedFinancialAccountHoldings.size(), ASSERT_INCORRECT_ITEM_COUNT);

		List<String> errorMessages = new List<String>();

		errorMessages.addAll(AW_API_SynchroniseContracts.ERROR_PRODUCT_CODE_AND_CATEGORY_MAPPING.split('\\{0\\}'));

		checkErrorMessages(errorMessages);
	}

	/**
	 * @description Will tests that insurance policies are upserted or deleted correctly
	 *
	 * @see AW_API_SynchroniseContracts.upsertInsurancePolicies
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void synchroniseInsurancePolicies()
	{
		List<Account> newAccounts = createInsurancePolicies();

		//Only 2 accounts will be created, the first one has FA's that must be updated or inserted
		Account accountToBeUpdated = newAccounts.iterator().next();

		policyToBeUpdated = new InsurancePolicy();
		policyToBeDeleted = new InsurancePolicy();

		List<InsurancePolicy> foundPolicies = AW_DAL_InsurancePolicy.findChildrenByAccountId(CMN_UTIL_System.extractListIds(newAccounts));

		processInsurancePolicies(foundPolicies, accountToBeUpdated.Id);

		//Creating DTORequest which will contain some contracts who will update the existing contracts, create new contracts and delete the non-updated contracts.
		CMN_API_InboundTestHelper.setupRestContext(populateInsurancePolicyDTO(accountToBeUpdated, policyToBeUpdated));

		Map<String, SObject> participantToRoleMap =
				CMN_UTIL_System.convertListToSingleStringMap(policyToBeUpdated.InsurancePolicyParticipants, AW_DAL_InsurancePolicyParticipant.FIELD_ROLE);
		Assert.isTrue(participantToRoleMap.containsKey(SC_FLOW_SynchroniseContracts.PAYER_ROLE), SC_FLOW_SynchroniseContracts.PAYER_ROLE + ASSERT_MISSING);

		InsurancePolicyParticipant beforeConsultantParticipant = (InsurancePolicyParticipant)participantToRoleMap.get(AW_API_SynchroniseContracts.CONSULTANT_ROLE);
		Assert.isNotNull(beforeConsultantParticipant, AW_API_SynchroniseContracts.CONSULTANT_ROLE + ASSERT_MISSING);

		Map<String, SObject> coverageByTypeMap =
				CMN_UTIL_System.convertListToSingleStringMap(policyToBeUpdated.InsurancePolicyCoverages, AW_DAL_InsurancePolicyCoverage.FIELD_TYPE);
		Assert.isTrue(coverageByTypeMap.containsKey(FUNERAL_BENEFIT), FUNERAL_BENEFIT + ASSERT_MISSING);

		InsurancePolicyCoverage foundProtectorCoverage = (InsurancePolicyCoverage)coverageByTypeMap.get(FINANCIAL_PROTECTOR);
		Assert.isNotNull(foundProtectorCoverage, FINANCIAL_PROTECTOR + ASSERT_MISSING);

		Test.startTest();

		AW_URL_Contract.synchroniseContracts();
		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_SynchroniseContracts.SERVICE_NAME);

		Test.stopTest();

		Account foundAccount = AW_DAL_Account.findById(accountToBeUpdated.Id);
		Assert.areNotEqual(accountToBeUpdated.AW_PoliciesRefreshStatus__c, foundAccount.AW_PoliciesRefreshStatus__c, ASSERT_STATUS_NOT_UPDATED);

		foundPolicies = AW_DAL_InsurancePolicy.findChildrenByAccountId(new Set<Id> {foundAccount.Id});
		Assert.areEqual(INT_THREE, foundPolicies.size(), ASSERT_INCORRECT_ITEM_COUNT);

		Map<Id, InsurancePolicy> policyByIdMap = new Map<Id, InsurancePolicy>(foundPolicies);
		InsurancePolicy mapRemovedPolicy = policyByIdMap.remove(policyToBeUpdated.Id);
		Assert.isNotNull(mapRemovedPolicy, 'Updated policy not found');

		Map<String, SObject> participantsByRoleMap =
				CMN_UTIL_System.convertListToSingleStringMap(mapRemovedPolicy.InsurancePolicyParticipants, AW_DAL_InsurancePolicyParticipant.FIELD_ROLE);
		Assert.isFalse(participantsByRoleMap.containsKey(SC_FLOW_SynchroniseContracts.PAYER_ROLE), 'Payer role should have been removed');

		InsurancePolicyParticipant afterConsultantParticipant = (InsurancePolicyParticipant)participantsByRoleMap.get(AW_API_SynchroniseContracts.CONSULTANT_ROLE);
		Assert.isNotNull(afterConsultantParticipant, AW_API_SynchroniseContracts.CONSULTANT_ROLE + ASSERT_MISSING);
		Assert.areNotEqual(beforeConsultantParticipant.AW_RoleCode__c, afterConsultantParticipant.AW_RoleCode__c, 'Role code not updated');

		InsurancePolicy remainingPolicy = policyByIdMap.values().iterator().next();
		Assert.areEqual(INT_FOUR, remainingPolicy.InsurancePolicyParticipants.size(), ASSERT_INCORRECT_ITEM_COUNT);

		Map<String, SObject> coveragesByTypeMap =
				CMN_UTIL_System.convertListToSingleStringMap(mapRemovedPolicy.InsurancePolicyCoverages, AW_DAL_InsurancePolicyCoverage.FIELD_TYPE);
		Assert.isFalse(coveragesByTypeMap.containsKey(FUNERAL_BENEFIT), 'Funeral Benefit coverage should have been removed');

		InsurancePolicyCoverage beforeProtectorCoverage = (InsurancePolicyCoverage)coveragesByTypeMap.get(FINANCIAL_PROTECTOR);
		Assert.isNotNull(beforeProtectorCoverage, FINANCIAL_PROTECTOR + ASSERT_MISSING);
		Assert.areNotEqual(foundProtectorCoverage.AW_CoverCategory__c, beforeProtectorCoverage.AW_CoverCategory__c, 'Category not updated');
	}

	/**
	 * @description Will tests that master record is linked to child
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void synchroniseInsurancePoliciesWhereMasterNotLinked()
	{
		List<Account> newAccounts = createAccountWithChildren(false, false, false);

		List<Account> accountsToBeUpdated = new List<Account>();
		//Remove link to master, and check that link is re-established
		for(Account newAccount : newAccounts)
		{
			Account accountToBeUpdated = newAccount;
			accountToBeUpdated.AW_ParentAccount__c = null;
			accountsToBeUpdated.add(accountToBeUpdated);
		}

		update accountsToBeUpdated;

		policyToBeUpdated = new InsurancePolicy();

		List<InsurancePolicy> foundPolicies = AW_DAL_InsurancePolicy.findChildrenByAccountId(CMN_UTIL_System.extractListIds(newAccounts));

		Account orphanAccount = accountsToBeUpdated.iterator().next();
		processInsurancePolicies(foundPolicies, orphanAccount.Id);

		//Creating DTORequest which will contain some contracts who will update the existing contracts, create new contracts and delete the non-updated contracts.
		CMN_API_InboundTestHelper.setupRestContext(populateInsurancePolicyDTO(orphanAccount, policyToBeUpdated));

		Test.startTest();

		AW_URL_Contract.synchroniseContracts();
		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_SynchroniseContracts.SERVICE_NAME);

		Test.stopTest();

		Account foundAccount = AW_DAL_Account.findById(orphanAccount.Id);

		Assert.isNotNull(foundAccount.AW_ParentAccount__c, 'Master Account Id was not set.');
	}

	/**
	 * @description Will test the IdentificationNumber blank Exception
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void identificationNumberExceptions()
	{
		checkIdNumberAndType(true, false, false);
	}

	/**
	 * @description Will test the IdentificationNumberType Blank Exception
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void identificationTypeExceptions()
	{
		checkIdNumberAndType(false, false, false);
	}

	/**
	 * @description Will test the IdentificationNumberType Blank Exception
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void ignoreSyncWhenNoContractsReceived()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Account newAccount = AW_DAL_TestDataFactory.createClientAccount(INT_ONE).iterator().next();
		AW_API_SynchroniseContracts.DTO_Request dtoRequest = new AW_API_SynchroniseContracts.DTO_Request();

		dtoRequest.identificationNumber = newAccount.AW_IdentificationNumber__pc;
		dtoRequest.identificationNumberType = newAccount.AW_IdentificationType__pc;
		dtoRequest.contracts = new List<AW_API_SynchroniseContracts.DTO_Contract>();

		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_Contract.synchroniseContracts();

		Test.stopTest();

		CMN_AppLog__c newLog = CMN_DAL_AppLog.findByMethod(AW_API_SynchroniseContracts.METHOD_REGISTER_CHANGES);
		Assert.areEqual(AW_API_SynchroniseContracts.WARNING_REQUEST_IGNORED, newLog.CMN_Message__c, ASSERT_WARNING_INCORRECT);
	}

	/**
	 * @description Will test the No client Found Exception
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void noClientFoundExceptions()
	{
		checkIdNumberAndType(false, true, false);
	}

	/**
	 * @description Will test the No client Found Exception
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void noClientFoundToProcessPolicies()
	{
		checkIdNumberAndType(false, true, true);
	}

	/**
	 * @description Method to check if the service failed correctly due any of the one reason(no identification number, no identification type
	 * and no client found)
	 *
	 * @param isIdNumber flag to indicate if Id number should be populated or Id type should be populated
	 * @param populateBothIdAndType flag to indicate if Id number should be populated or Id type should be populated
	 * @param generateContractRequest flag to indicate if the request should be generated or not
	 */
	private static void checkIdNumberAndType(Boolean isIdNumber, Boolean populateBothIdAndType, Boolean generateContractRequest)
	{
		String assertIdException = isIdNumber ? AW_API_SynchroniseContracts.ERROR_NO_IDENTITY_NUMBER : AW_API_SynchroniseContracts.ERROR_NO_IDENTITY_TYPE;
		String assertMessage = populateBothIdAndType ? AW_API_SynchroniseContracts.ERROR_NO_CLIENT_FOUND : assertIdException;
		String idNumber = isIdNumber ? null : CMN_DAL_SObjectDomain.generateRandomNumber();

		AW_API_SynchroniseContracts.DTO_Request dtoRequest = new AW_API_SynchroniseContracts.DTO_Request();

		if(populateBothIdAndType)
		{
			dtoRequest.identificationNumber = CMN_DAL_SObjectDomain.generateRandomNumber();
			dtoRequest.identificationNumberType = AW_API_SynchroniseContracts.BUSINESS_ID_TYPE;
		}
		else
		{
			dtoRequest.identificationNumber = idNumber;
			dtoRequest.identificationNumberType = null;
		}

		if(generateContractRequest)
		{
			Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

			dtoRequest.identificationNumber = newAccount.AW_IdentificationNumber__pc;
			dtoRequest.identificationNumberType = INDIVIDUAL_ID_TYPE;

			AW_API_SynchroniseContracts.DTO_Contract dtoContract = new AW_API_SynchroniseContracts.DTO_Contract();

			dtoContract.Id = CMN_DAL_SObjectDomain.generateRandomNumber();
			dtoContract.Type_Cd = STR_ONE;
			dtoContract.Type_Tx = OFFSHORE_INVESTMENT_PLAN_ICB;
			dtoContract.Contract_Status_Ind = SC_UTIL_Contracts.STATUS_IN_FORCE;
			dtoContract.Proto_Cd = STR_ONE;

			List<AW_API_SynchroniseContracts.DTO_EmailAddress> dtoEmails = new List<AW_API_SynchroniseContracts.DTO_EmailAddress>();
			List<AW_API_SynchroniseContracts.DTO_Telephone> dtoTelephones = new List<AW_API_SynchroniseContracts.DTO_Telephone>();
			List<AW_API_SynchroniseContracts.DTO_Registration> dtoRegistrations = new List<AW_API_SynchroniseContracts.DTO_Registration>();

			dtoContract.Roles = new List<AW_API_SynchroniseContracts.DTO_Role> {populateDtoPolicyOwnerRole(dtoRequest, dtoEmails, dtoTelephones, dtoRegistrations)};
			dtoRequest.contracts = new List<AW_API_SynchroniseContracts.DTO_Contract> {dtoContract};
		}

		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_Contract.synchroniseContracts();

		Test.stopTest();

		if(!generateContractRequest)
		{
			CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(AW_API_SynchroniseContracts.SERVICE_NAME, assertMessage);
		}
		else
		{
			checkErrorMessages(new List<String> {AW_API_SynchroniseContracts.ERROR_NO_CLIENT_FOUND});
		}
	}

	/**
	 * @description Method to Create a Person master and child account
	 *
	 * @param adviser Owner of the child account
	 *
	 * @return Child Account
	 */
	private static Account createPersonChildAccountWithMaster(User adviser)
	{
		String identityNumber = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();

		Account newPersonMasterAccount = AW_DAL_TestDataFactory.newPersonAccount(AW_DAL_Account.RT_PERSON_MASTER_ACCOUNT, identityNumber);
		UNIT_OF_WORK.registerNew(newPersonMasterAccount);

		Account newPersonChildAccount = AW_DAL_TestDataFactory.newPersonAccount(AW_DAL_Account.RT_PERSON_ACCOUNT, identityNumber);

		newPersonChildAccount.AW_SKF_Id__c = newPersonMasterAccount.AW_SKF_Id__c;
		newPersonChildAccount.AW_BypassValidationRules__c = true;
		newPersonChildAccount.OwnerId = adviser.Id;

		UNIT_OF_WORK.registerNew(newPersonChildAccount, Account.AW_ParentAccount__c, newPersonMasterAccount);

		return newPersonChildAccount;
	}

	/**
	 * @description Method to Create a Person master and child account
	 *
	 * @param newAccount Owner of the child account
	 * @param newContact Contact to link to Child
	 * @param newConsultant Consultant to link to Child
	 * @param isFinancialAccount flag to indicate if Financial Account or Insurance Policy should be created
	 */
	private static void createChildren(Account newAccount, Contact newContact, SC_ConsultantCodes__c newConsultant, Boolean isFinancialAccount)
	{
		if(isFinancialAccount)
		{
			createFinancialAccountWithChildren(newAccount, newContact, newConsultant);
		}
		else
		{
			createInsurancePolicyWithChildren(newAccount, newContact);
		}
	}

	/**
	 * @description Will create all the information required to test contract synchronisation for financial accounts
	 *
	 * @param newAccount account to link with financial account
	 * @param newContact contact to be linked with financial account
	 * @param newCode consultant to be linked with financial account
	 */
	private static void createFinancialAccountWithChildren(Account newAccount, Contact newContact, SC_ConsultantCodes__c newCode)
	{
		FinServ__FinancialAccount__c newFinancialAccount = SC_DAL_DataFactory.newFinancialAccounts(newAccount, INT_ONE).iterator().next();
		UNIT_OF_WORK.registerNew(newFinancialAccount, FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c, newAccount);

		for(FinServ__FinancialHolding__c newHolding : AW_DAL_TestDataFactory.newFinancialHoldings(newFinancialAccount, INT_TWO))
		{
			UNIT_OF_WORK.registerNew(newHolding, FinServ__FinancialHolding__c.FinServ__FinancialAccount__c, newFinancialAccount);
		}

		Set<String> roleTypes = new Set<String>
		{AW_API_SynchroniseContracts.CONSULTANT_ROLE, SC_FLOW_SynchroniseContracts.PAYER_ROLE, AW_API_SynchroniseContracts.OWNER_ROLE};
		List<FinServ__FinancialAccountRole__c> newRoles =
				AW_DAL_TestDataFactory.newFinancialAccountRoles(newAccount, newContact, newFinancialAccount, roleTypes, newCode.Name);

		for(FinServ__FinancialAccountRole__c newRole : newRoles)
		{

			if(newRole.FinServ__Role__c == AW_API_SynchroniseContracts.CONSULTANT_ROLE)
			{
				//link consultant code record to a consultant role record
				newRole.SC_ConsultantCode__c = newCode.Id;
				newRole.SC_ConsultantStatus__c = newCode.SC_AgreementStatus__c ? INTERMEDIATE_POLICY : ORPHAN_POLICY;
				UNIT_OF_WORK.registerRelationship(newRole, FinServ__FinancialAccountRole__c.FinServ__RelatedContact__c, newContact);
			}
			else
			{
				if(newRole.FinServ__Role__c == AW_API_SynchroniseContracts.OWNER_ROLE)
				{
					newRole.CMN_OrganizationName__c = CMN_DAL_SObjectDomain.generateRandomName();
					newRole.AW_RoleFirstName__c = newRole.AW_RoleLastName__c = CMN_UTIL_String.EMPTY;
				}
				UNIT_OF_WORK.registerRelationship(newRole, FinServ__FinancialAccountRole__c.FinServ__RelatedAccount__c, newAccount);
			}
			UNIT_OF_WORK.registerNew(newRole, FinServ__FinancialAccountRole__c.FinServ__FinancialAccount__c, newFinancialAccount);
		}
	}

	/**
	 * @description Will create all the information required to test contract synchronisation for financial accounts
	 *
	 * @param newAccount account to link with financial account
	 * @param newContact contact to be linked with financial account
	 */
	private static void createInsurancePolicyWithChildren(Account newAccount, Contact newContact)
	{
		InsurancePolicy newPolicy = SC_DAL_DataFactory.newInsurancePolicies(newAccount, INT_ONE).iterator().next();
		UNIT_OF_WORK.registerNew(newPolicy, InsurancePolicy.NameInsuredId, newAccount);

		Set<String> roleTypes =
				new Set<String> {AW_API_SynchroniseContracts.CONSULTANT_ROLE, SC_FLOW_SynchroniseContracts.PAYER_ROLE, AW_API_SynchroniseContracts.OWNER_ROLE};
		List<InsurancePolicyParticipant> newParticipants = AW_DAL_TestDataFactory.newInsurancePolicyParticipants(newPolicy, roleTypes, newContact, newAccount);

		for(InsurancePolicyParticipant newParticipant : newParticipants)
		{
			if(newParticipant.Role == AW_API_SynchroniseContracts.OWNER_ROLE)
			{
				newParticipant.CMN_OrganizationName__c = CMN_DAL_SObjectDomain.generateRandomName();
				newParticipant.AW_FirstName__c = newParticipant.AW_LastName__c = CMN_UTIL_String.EMPTY;
			}

			UNIT_OF_WORK.registerNew(newParticipant, InsurancePolicyParticipant.InsurancePolicyId, newPolicy);
			UNIT_OF_WORK.registerRelationship(newParticipant, InsurancePolicyParticipant.RelatedParticipantAccountId, newAccount);
		}

		Set<String> coverageTypes = new Set<String> {FUNERAL_BENEFIT, FINANCIAL_PROTECTOR};
		InsurancePolicyParticipant policyParticipant = newParticipants.iterator().next();

		for(InsurancePolicyCoverage newCoverage : AW_DAL_TestDataFactory.newInsurancePolicyCoverages(newPolicy, coverageTypes))
		{
			newCoverage.AW_TypeCode__c = AW_DAL_BenefitCodeAndCategoryMapping.getBenefitCodeMapping(newCoverage.AW_Type__c).AW_TypeCode__c;

			UNIT_OF_WORK.registerNew(newCoverage, InsurancePolicyCoverage.InsurancePolicyId, newPolicy);
			UNIT_OF_WORK.registerRelationship(newCoverage, InsurancePolicyCoverage.AW_InsurancePolicyParticipant__c, policyParticipant);
		}
	}

	/**
	 * @description Will create the dtoRequest data
	 *
	 * @param newAccount Account record with Contracts to be updated
	 * @param newFinancialAccount Financial Account records to be updated
	 *
	 * @return a populated dto
	 */
	private static AW_API_SynchroniseContracts.DTO_Request populateFinancialAccountDTO(Account newAccount, FinServ__FinancialAccount__c newFinancialAccount)
	{
		User accountOwner = AW_DAL_User.findById(newAccount.OwnerId);

		AW_API_SynchroniseContracts.DTO_Request dtoRequest = new AW_API_SynchroniseContracts.DTO_Request();
		List<AW_API_SynchroniseContracts.DTO_Contract> dtoContracts = new List<AW_API_SynchroniseContracts.DTO_Contract>();

		dtoRequest.identificationNumber = newAccount.AW_IdentificationNumber__pc;
		dtoRequest.identificationNumberType = newAccount.AW_IdentificationType__pc;

		dtoContracts.addAll(populateContractsDTO(dtoRequest, newFinancialAccount, accountOwner));
		dtoRequest.contracts = dtoContracts;

		return dtoRequest;
	}

	/**
	 * @description Checks that error messages are not set
	 *
	 * @param errorMessages List of valid error messages
	 */
	private static void checkErrorMessages(List<String> errorMessages)
	{
		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.findByServiceName(AW_API_SynchroniseContracts.SERVICE_NAME);

		//Checking the error messages are correct or not
		for(CMN_WebserviceCallQueue__c queueItem : queueItems)
		{
			for(String errorMessage : errorMessages)
			{
				Assert.isTrue(CMN_UTIL_String.contains(queueItem.CMN_Errors__c, errorMessage), 'Error Message Incorrect');
			}
		}
	}

	/**
	 * @description Will create all the information required to test contract synchronisation for insurance policies
	 *
	 * @return A list of newly created accounts with associated insurance policies
	 */
	private static List<Account> createInsurancePolicies()
	{
		return createAccountWithChildren(true, false, false);
	}

	/**
	 * @description Will generate (financial account)contract data for request dto.
	 *
	 * @param dtoRequest The parent request DTO
	 * @param newFinancialAccount Financial Account record
	 * @param accountOwner User record
	 *
	 * @return contractList
	 */
	private static List<AW_API_SynchroniseContracts.DTO_Contract>populateContractsDTO
			(
					AW_API_SynchroniseContracts.DTO_Request dtoRequest,
					FinServ__FinancialAccount__c newFinancialAccount,
					User accountOwner
			)
	{
		AW_API_SynchroniseContracts.DTO_Contract dtoContract1 = new AW_API_SynchroniseContracts.DTO_Contract();
		AW_API_SynchroniseContracts.DTO_Contract dtoContract2 = new AW_API_SynchroniseContracts.DTO_Contract();
		AW_API_SynchroniseContracts.DTO_Contract dtoNoMappingContract = new AW_API_SynchroniseContracts.DTO_Contract();
		AW_API_SynchroniseContracts.DTO_Contract dtoUpdatedContract = new AW_API_SynchroniseContracts.DTO_Contract();
		AW_API_SynchroniseContracts.DTO_Inception dtoInception = new AW_API_SynchroniseContracts.DTO_Inception();
		List<AW_API_SynchroniseContracts.DTO_AssociatedContract> dtoAssociatedContracts = new List <AW_API_SynchroniseContracts.DTO_AssociatedContract>();
		List<AW_API_SynchroniseContracts.DTO_Benefit> dtoBenefits = new List <AW_API_SynchroniseContracts.DTO_Benefit>();
		List<AW_API_SynchroniseContracts.DTO_Contract> dtoContracts = new List<AW_API_SynchroniseContracts.DTO_Contract>();
		List<AW_API_SynchroniseContracts.DTO_Role> dtoRoles1 = new List <AW_API_SynchroniseContracts.DTO_Role>();
		List<AW_API_SynchroniseContracts.DTO_Role> dtoRoles2 = new List <AW_API_SynchroniseContracts.DTO_Role>();

		List<AW_API_SynchroniseContracts.DTO_Account> dtoAccounts = new List<AW_API_SynchroniseContracts.DTO_Account>();
		dtoAccounts.add(populateAccountDTO());

		List<AW_API_SynchroniseContracts.DTO_EmailAddress> dtoEmails = new List<AW_API_SynchroniseContracts.DTO_EmailAddress>();
		dtoEmails.add(populateEmailDTO());

		List<AW_API_SynchroniseContracts.DTO_Registration> dtoRegistrations = new List<AW_API_SynchroniseContracts.DTO_Registration>();
		dtoRegistrations.add(populateRegistrationDTO(dtoRequest, AW_API_SynchroniseContracts.PASSPORT_REGISTRATION_TYPE_CODE));
		dtoRegistrations.add(populateRegistrationDTO(dtoRequest, AW_API_SynchroniseContracts.ID_REGISTRATION_TYPE_CODE));

		List<AW_API_SynchroniseContracts.DTO_Telephone> dtoTelephones = new List<AW_API_SynchroniseContracts.DTO_Telephone>();

		dtoTelephones.add(populatePhoneDTO(AW_API_SynchroniseContracts.LAND_LINE_FACILITY_CODE, AW_API_SynchroniseContracts.WORK_PHONE_USAGE_CODE));
		dtoTelephones.add(populatePhoneDTO(AW_API_SynchroniseContracts.CELL_PHONE_FACILITY_CODE, AW_API_SynchroniseContracts.PERSONAL_PHONE_USAGE_CODE));
		dtoTelephones.add(populatePhoneDTO(AW_API_SynchroniseContracts.LAND_LINE_FACILITY_CODE, AW_API_SynchroniseContracts.PERSONAL_PHONE_USAGE_CODE));

		List<AW_API_SynchroniseContracts.DTO_AccountsSO> dtoAccountsSO = new List<AW_API_SynchroniseContracts.DTO_AccountsSO>();
		dtoAccountsSO.add(populateAccountsSODTO());

		//Creating Contract1 Data which will create new Financial Account in Salesforce
		dtoContract1.Id = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoContract1.Type_Cd = STR_HUNDRED;
		dtoContract1.Type_Tx = OFFSHORE_INVESTMENT_PLAN_ICB;
		dtoContract1.Contract_Status_Ind = SC_UTIL_Contracts.STATUS_IN_FORCE;
		dtoContract1.Proto_Cd = STR_HUNDRED;

		dtoContract1.Inception = populateInceptionDTO();

		AW_API_SynchroniseContracts.DTO_AssociatedContract newContract = populateAssociatedContractDTO();
		dtoAssociatedContracts.add(newContract);
		dtoContract1.AssociatedContracts = dtoAssociatedContracts;

		AW_API_SynchroniseContracts.DTO_Illustrated illustrated = populateIllustratedDTO();
		dtoContract1.Illustrated = illustrated;

		AW_API_SynchroniseContracts.DTO_Current current = populateCurrentDTO(AW_API_SynchroniseContracts.CURRENT_PAYMENT_TYPE, PREMIUM_FREQUENCY);

		dtoContract1.Current = current;
		dtoContract1.Roles = dtoRoles1;

		AW_API_SynchroniseContracts.DTO_Current current1 = populateCurrentDTO(PAYMENT_METHOD, CMN_UTIL_String.EMPTY);

		AW_API_SynchroniseContracts.DTO_Benefit benefitWithNoPortfolios =
				populateBenefitDTO(AW_API_SynchroniseContracts.LIFE_BENEFIT_TYPE, AW_API_SynchroniseContracts.LIFE_BENEFIT_CODE, INDICATOR_YES);

		AW_API_SynchroniseContracts.DTO_Benefit benefit = new AW_API_SynchroniseContracts.DTO_Benefit();

		List<AW_API_SynchroniseContracts.DTO_Portfolio> dtoPortfolios = new List<AW_API_SynchroniseContracts.DTO_Portfolio>();

		//Updates the existing Portfolio
		AW_API_SynchroniseContracts.DTO_Portfolio dtoPortfolio1 = populatePortfolioDTO(newFinancialAccount.FinServ__FinancialHoldings__r.iterator().next().Name);
		dtoPortfolio1.Rand_Val = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();

		AW_API_SynchroniseContracts.DTO_Portfolio dtoPortfolio2 = populatePortfolioDTO(newFinancialAccount.FinServ__FinancialHoldings__r.iterator().next().Name);

		dtoPortfolios.add(dtoPortfolio1);
		dtoPortfolios.add(dtoPortfolio2);
		benefit.Portfolios = dtoPortfolios;
		dtoBenefits.add(benefit);
		dtoContract1.Benefits = dtoBenefits;
		dtoContracts.add(dtoContract1);

		//Creating Contract2 Data which will create new Financial Account in Salesforce
		dtoContract2.Id = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoContract2.Type_Cd = STR_ONE;
		dtoContract2.Type_Tx = OFFSHORE_INVESTMENT_PLAN_ICB;
		dtoContract2.Contract_Status_Ind = SC_UTIL_Contracts.STATUS_IN_FORCE;
		dtoContract2.Proto_Cd = STR_ONE;
		dtoContract2.Inception = dtoInception;
		dtoContract2.Current = current1;
		dtoContract2.Roles = dtoRoles1;

		dtoPortfolios.remove(1);
		dtoPortfolio2.Rand_Val = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoPortfolios.add(dtoPortfolio2);
		benefit.Portfolios = dtoPortfolios;
		dtoBenefits.add(benefitWithNoPortfolios);

		dtoContract2.Benefits = dtoBenefits;
		dtoContracts.add(dtoContract2);

		//Creating Contract Data which will update the existing Financial Account
		dtoUpdatedContract.Id = newFinancialAccount.FinServ__FinancialAccountNumber__c;
		dtoUpdatedContract.Type_Cd = STR_ONE;
		dtoUpdatedContract.Type_Tx = OFFSHORE_INVESTMENT_PLAN_ICB;
		dtoUpdatedContract.Contract_Status_Ind = SC_UTIL_Contracts.STATUS_IN_FORCE;
		dtoUpdatedContract.Proto_Cd = STR_ONE;
		dtoUpdatedContract.Inception = dtoInception;
		dtoUpdatedContract.Current = current;

		//Creating Consultant Role for all the contracts so that we can find the account to update these contracts
		AW_API_SynchroniseContracts.DTO_Role dtoConsultantRole = new AW_API_SynchroniseContracts.DTO_Role();
		dtoConsultantRole.Id = accountOwner.AW_ConsultantCode__c;
		dtoConsultantRole.Type_Cd = CONSULTANT_TYPE_CODE;
		dtoConsultantRole.Type_Tx = AW_API_SynchroniseContracts.CONSULTANT_ROLE;

		FinServ__FinancialAccountRole__c consultantFinancialAccountRole;
		for(FinServ__FinancialAccountRole__c financialAccountRole : newFinancialAccount.FinServ__FinancialAccountRoles__r)
		{
			if(financialAccountRole.FinServ__Role__c == dtoConsultantRole.Type_Tx)
			{
				consultantFinancialAccountRole = financialAccountRole;
				break;
			}
		}

		AW_API_SynchroniseContracts.DTO_Person dtoPerson = populateEntityPersonDTO(dtoEmails, dtoTelephones, dtoRegistrations);
		if(consultantFinancialAccountRole != null)
		{
			dtoPerson.First_Nm = consultantFinancialAccountRole.AW_RoleFirstName__c;
			dtoPerson.Last_Nm = consultantFinancialAccountRole.AW_RoleLastName__c;
		}

		dtoConsultantRole.Entity_Person = dtoPerson;

		dtoRoles1.add(dtoConsultantRole);
		dtoRoles2.add(dtoConsultantRole);

		AW_API_SynchroniseContracts.DTO_Role dtoLifeAssuredRole = new AW_API_SynchroniseContracts.DTO_Role();
		dtoLifeAssuredRole.Type_Cd = LIFE_ASSURED_TYPE_CODE;
		dtoLifeAssuredRole.Type_Tx = LIFE_ASSURED;
		dtoLifeAssuredRole.Entity_Person = dtoPerson;
		dtoRoles1.add(dtoLifeAssuredRole);
		dtoRoles2.add(dtoLifeAssuredRole);

		AW_API_SynchroniseContracts.DTO_Role dtoOrganisationOwnerRole = new AW_API_SynchroniseContracts.DTO_Role();
		dtoOrganisationOwnerRole.Type_Cd = dtoOrganisationOwnerRole.Type_Tx = AW_API_SynchroniseContracts.OWNER_ROLE;
		dtoOrganisationOwnerRole.Entity_Organization = populateOrganizationDTO(dtoEmails, dtoTelephones);
		dtoOrganisationOwnerRole.Benefits = dtoBenefits;
		dtoRoles2.add(dtoOrganisationOwnerRole);

		AW_API_SynchroniseContracts.DTO_Role dtoPolicyOwnerRole = populateDtoPolicyOwnerRole(dtoRequest, dtoEmails, dtoTelephones, dtoRegistrations);

		dtoRoles1.add(dtoPolicyOwnerRole);
		dtoRoles2.add(dtoPolicyOwnerRole);

		//This role will not be inserted as the first name or lastname in the entity person section is empty and hence the role not processed message will be added
		AW_API_SynchroniseContracts.DTO_Role payeeRole = new AW_API_SynchroniseContracts.DTO_Role();
		payeeRole.Type_Cd = SC_UTIL_Contracts.ROLE_PAYEE;
		payeeRole.Type_Tx = SC_UTIL_Contracts.ROLE_PAYEE;
		payeeRole.Entity_Person = new AW_API_SynchroniseContracts.DTO_Person();
		dtoRoles2.add(payeeRole);

		dtoUpdatedContract.Roles = dtoRoles2;
		dtoUpdatedContract.Benefits = dtoBenefits;

		dtoContracts.add(dtoUpdatedContract);

		//Creating Contract Data which will not update anything or insert anything because mapping is incorrect
		dtoNoMappingContract.Id = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoNoMappingContract.Type_Cd = STR_INVALID_PROTO_CODE;
		dtoNoMappingContract.Type_Tx = CMN_DAL_SObjectDomain.generateRandomName();
		dtoNoMappingContract.Contract_Status_Ind = SC_UTIL_Contracts.STATUS_IN_FORCE;
		dtoNoMappingContract.Proto_Cd = STR_INVALID_PROTO_CODE;
		dtoNoMappingContract.Roles = dtoRoles1;
		dtoNoMappingContract.Benefits = dtoBenefits;
		dtoNoMappingContract.Current = current;
		dtoNoMappingContract.Inception = dtoInception;
		dtoContracts.add(dtoNoMappingContract);

		return dtoContracts;
	}

	/**
	 * @description Will generate a Policy Owner Role
	 *
	 * @param dtoRequest The original request for which this role must be generated (uses id number and type)
	 * @param dtoEmails The emails to use for the role
	 * @param dtoTelephones The telephones to use for the role
	 * @param dtoRegistrations The registrations to use for the role
	 *
	 * @return An initialized role
	 */
	private static AW_API_SynchroniseContracts.DTO_Role populateDtoPolicyOwnerRole
			(
					AW_API_SynchroniseContracts.DTO_Request dtoRequest,
					List<AW_API_SynchroniseContracts.DTO_EmailAddress> dtoEmails,
					List<AW_API_SynchroniseContracts.DTO_Telephone> dtoTelephones,
					List<AW_API_SynchroniseContracts.DTO_Registration> dtoRegistrations
			)
	{
		AW_API_SynchroniseContracts.DTO_Role dtoPolicyOwnerRole = new AW_API_SynchroniseContracts.DTO_Role();
		dtoPolicyOwnerRole.Type_Cd = AW_API_SynchroniseContracts.OWNER_ROLE;
		dtoPolicyOwnerRole.Type_Tx = AW_API_SynchroniseContracts.OWNER_ROLE;

		if(TRUST_REGISTRATION_NUMBER.equals(dtoRequest.identificationNumberType))
		{
			AW_API_SynchroniseContracts.DTO_Organization dtoPolicyOwner = populateOrganizationDTO(dtoEmails, dtoTelephones);
			dtoPolicyOwner.Registration_No = dtoRequest.identificationNumber;
			dtoPolicyOwnerRole.Entity_Organization = dtoPolicyOwner;
		}
		{
			AW_API_SynchroniseContracts.DTO_Person dtoPolicyOwner = populateEntityPersonDTO(dtoEmails, dtoTelephones, dtoRegistrations);

			dtoPolicyOwner.First_Nm = CMN_DAL_SObjectDomain.generateRandomName();
			dtoPolicyOwner.Identity_No = dtoRequest.identificationNumber;
			dtoPolicyOwner.Last_Nm = CMN_DAL_SObjectDomain.generateRandomName();

			dtoPolicyOwnerRole.Entity_Person = dtoPolicyOwner;
		}
		return dtoPolicyOwnerRole;
	}

	/**
	 * @description Will create the dtoRequest data
	 *
	 * @param account Account record with Contracts to be updated
	 * @param foundInsurancePolicy Insurance Policy record to be updated
	 *
	 * @return dtoRequest
	 */
	private static AW_API_SynchroniseContracts.DTO_Request populateInsurancePolicyDTO(Account account, InsurancePolicy foundInsurancePolicy)
	{
		User owningUser = AW_DAL_User.findById(account.OwnerId);

		AW_API_SynchroniseContracts.DTO_Request dtoRequest = new AW_API_SynchroniseContracts.DTO_Request();
		List<AW_API_SynchroniseContracts.DTO_Contract> contracts = new List<AW_API_SynchroniseContracts.DTO_Contract>();

		dtoRequest.identificationNumber = account.AW_IdentificationNumber__pc;
		dtoRequest.identificationNumberType = account.AW_IdentificationType__pc;

		//Adds all the Insurance Policy Contracts created for DTORequest in the DTOContractList
		contracts.addAll(populateInsuranceContractsDTO(dtoRequest, foundInsurancePolicy, owningUser));
		dtoRequest.contracts = contracts;

		return dtoRequest;
	}

	/**
	 * @description Will generate (Insurance Policy)contract data for request dto.
	 *
	 * @param dtoRequest The full request DTO
	 * @param newPolicy Insurance Policy record
	 * @param accountOwner User record
	 *
	 * @return contractList
	 */
	private static List<AW_API_SynchroniseContracts.DTO_Contract> populateInsuranceContractsDTO
			(
					AW_API_SynchroniseContracts.DTO_Request dtoRequest,
					InsurancePolicy newPolicy,
					User accountOwner
			)
	{
		AW_API_SynchroniseContracts.DTO_Contract dtoContract1 = new AW_API_SynchroniseContracts.DTO_Contract();
		AW_API_SynchroniseContracts.DTO_Contract dtoContract2 = new AW_API_SynchroniseContracts.DTO_Contract();
		AW_API_SynchroniseContracts.DTO_Contract dtoUpdatedContract = new AW_API_SynchroniseContracts.DTO_Contract();
		AW_API_SynchroniseContracts.DTO_Inception dtoInception = new AW_API_SynchroniseContracts.DTO_Inception();
		List<AW_API_SynchroniseContracts.DTO_AssociatedContract> dtoAssociatedContracts = new List <AW_API_SynchroniseContracts.DTO_AssociatedContract> ();
		List<AW_API_SynchroniseContracts.DTO_Benefit> dtoBenefits = new List <AW_API_SynchroniseContracts.DTO_Benefit> ();
		List<AW_API_SynchroniseContracts.DTO_Contract> dtoContracts = new List<AW_API_SynchroniseContracts.DTO_Contract>();
		List<AW_API_SynchroniseContracts.DTO_Role> dtoRoles = new List <AW_API_SynchroniseContracts.DTO_Role>();

		List<AW_API_SynchroniseContracts.DTO_Account> dtoAccounts = new List<AW_API_SynchroniseContracts.DTO_Account>();
		dtoAccounts.add(populateAccountDTO());

		AW_API_SynchroniseContracts.DTO_Cessionary dtoCessionary = populateCessionaryDTO();

		List<AW_API_SynchroniseContracts.DTO_EmailAddress> dtoEmails = new List<AW_API_SynchroniseContracts.DTO_EmailAddress>();
		dtoEmails.add(populateEmailDTO());

		List<AW_API_SynchroniseContracts.DTO_Registration> dtoRegistrations = new List<AW_API_SynchroniseContracts.DTO_Registration>();

		dtoRegistrations.add(populateRegistrationDTO(dtoRequest, AW_API_SynchroniseContracts.PASSPORT_REGISTRATION_TYPE_CODE));
		dtoRegistrations.add(populateRegistrationDTO(dtoRequest, AW_API_SynchroniseContracts.ID_REGISTRATION_TYPE_CODE));

		List<AW_API_SynchroniseContracts.DTO_Telephone> dtoTelephones = new List<AW_API_SynchroniseContracts.DTO_Telephone>();

		dtoTelephones.add(populatePhoneDTO(AW_API_SynchroniseContracts.LAND_LINE_FACILITY_CODE, AW_API_SynchroniseContracts.WORK_PHONE_USAGE_CODE));
		dtoTelephones.add(populatePhoneDTO(AW_API_SynchroniseContracts.CELL_PHONE_FACILITY_CODE, AW_API_SynchroniseContracts.PERSONAL_PHONE_USAGE_CODE));
		dtoTelephones.add(populatePhoneDTO(AW_API_SynchroniseContracts.LAND_LINE_FACILITY_CODE, AW_API_SynchroniseContracts.PERSONAL_PHONE_USAGE_CODE));

		List<AW_API_SynchroniseContracts.DTO_AccountsSO> dtoAccountsSOS = new List<AW_API_SynchroniseContracts.DTO_AccountsSO>();
		dtoAccountsSOS.add(populateAccountsSODTO());

		//Creating new Contract Data which will create new Insurance Policy in Salesforce
		dtoContract1.Id = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoContract1.Type_Cd = STR_ONE;
		dtoContract1.Type_Tx = UNIVERSAL_LIFE;
		dtoContract1.Contract_Status_Ind = SC_UTIL_Contracts.STATUS_IN_FORCE;

		AW_API_SynchroniseContracts.DTO_Illustrated illustrated = populateIllustratedDTO();

		dtoInception = populateInceptionDTO();
		dtoContract1.Inception = dtoInception;
		dtoContract1.Illustrated = illustrated;

		AW_API_SynchroniseContracts.DTO_AssociatedContract newContract = populateAssociatedContractDTO();
		dtoAssociatedContracts.add(newContract);
		dtoContract1.AssociatedContracts = dtoAssociatedContracts;

		AW_API_SynchroniseContracts.DTO_Current current = populateCurrentDTO(AW_API_SynchroniseContracts.CURRENT_PAYMENT_TYPE, PREMIUM_FREQUENCY);
		dtoContract1.Current = current;

		//Creating Consultant Role for all the contracts so that we can find the account to update these contracts
		AW_API_SynchroniseContracts.DTO_Role consultantRole = new AW_API_SynchroniseContracts.DTO_Role();
		consultantRole.Id = String.valueOf(accountOwner.AW_ConsultantCode__c);
		consultantRole.Type_Cd = CONSULTANT_TYPE_CODE;
		consultantRole.Type_Tx = AW_API_SynchroniseContracts.CONSULTANT_ROLE;

		InsurancePolicyParticipant consultantInsurancePolicyParticipant;
		for(InsurancePolicyParticipant insurancePolicyParticipant : newPolicy.InsurancePolicyParticipants)
		{
			if(insurancePolicyParticipant.Role == consultantRole.Type_Tx)
			{
				consultantInsurancePolicyParticipant = insurancePolicyParticipant;
				break;
			}
		}

		AW_API_SynchroniseContracts.DTO_Person entityPerson = new AW_API_SynchroniseContracts.DTO_Person();

		if(consultantInsurancePolicyParticipant != null)
		{
			entityPerson.First_Nm = consultantInsurancePolicyParticipant.AW_FirstName__c;
			entityPerson.Last_Nm = consultantInsurancePolicyParticipant.AW_LastName__c;
		}

		consultantRole.Entity_Person = entityPerson;
		dtoRoles.add(consultantRole);

		AW_API_SynchroniseContracts.DTO_Role dtoPolicyOwnerRole = populateDtoPolicyOwnerRole(dtoRequest, dtoEmails, dtoTelephones, dtoRegistrations);

		dtoRoles.add(dtoPolicyOwnerRole);

		AW_API_SynchroniseContracts.DTO_Role lifeAssuredRole = new AW_API_SynchroniseContracts.DTO_Role();
		lifeAssuredRole.Type_Cd = LIFE_ASSURED_TYPE_CODE;
		lifeAssuredRole.Type_Tx = LIFE_ASSURED;
		lifeAssuredRole.Entity_Person = entityPerson;
		dtoRoles.add(lifeAssuredRole);

		//This role will not be inserted as the first name or lastname in the entity person section is empty and hence the role not processed message will be added
		AW_API_SynchroniseContracts.DTO_Role payeeRole = new AW_API_SynchroniseContracts.DTO_Role();
		payeeRole.Type_Cd = SC_UTIL_Contracts.ROLE_PAYEE;
		payeeRole.Type_Tx = SC_UTIL_Contracts.ROLE_PAYEE;
		payeeRole.Entity_Person = new AW_API_SynchroniseContracts.DTO_Person();
		dtoRoles.add(payeeRole);

		AW_API_SynchroniseContracts.DTO_Benefit benefit = populateBenefitDTO(
				FINANCIAL_PROTECTOR, AW_DAL_BenefitCodeAndCategoryMapping.getBenefitCodeMapping(FINANCIAL_PROTECTOR).AW_TypeCode__c, INDICATOR_NO);

		AW_API_SynchroniseContracts.DTO_Benefit newBenefit = populateBenefitDTO(
				AW_API_SynchroniseContracts.LIFE_BENEFIT_TYPE, AW_API_SynchroniseContracts.LIFE_BENEFIT_CODE, INDICATOR_YES);

		List<AW_API_SynchroniseContracts.DTO_Portfolio> portfolioList = new List<AW_API_SynchroniseContracts.DTO_Portfolio>();

		AW_API_SynchroniseContracts.DTO_Portfolio portfolio = populatePortfolioDTO(CMN_DAL_SObjectDomain.generateRandomName());
		portfolio.Rand_Val = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		portfolioList.add(portfolio);
		benefit.Portfolios = portfolioList;

		dtoBenefits.add(benefit);
		dtoBenefits.add(newBenefit);
		consultantRole.Benefits = dtoBenefits;

		dtoContract1.Roles = dtoRoles;
		dtoContract1.Benefits = dtoBenefits;
		dtoContracts.add(dtoContract1);

		dtoContract2.Id = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoContract2.Type_Cd = STR_ONE;
		dtoContract2.Type_Tx = UNIVERSAL_LIFE;
		dtoContract2.Contract_Status_Ind = SC_UTIL_Contracts.STATUS_IN_FORCE;
		dtoContracts.add(dtoContract2);

		AW_API_SynchroniseContracts.DTO_Current current1 = populateCurrentDTO(AW_API_SynchroniseContracts.CURRENT_PAYMENT_TYPE, PREMIUM_FREQUENCY);
		dtoContract2.Current = current1;

		AW_API_SynchroniseContracts.DTO_Person newEntityPerson = populateEntityPersonDTO(dtoEmails, dtoTelephones, dtoRegistrations);
		newEntityPerson.First_Nm = CMN_DAL_SObjectDomain.generateRandomName();
		newEntityPerson.Last_Nm = CMN_DAL_SObjectDomain.generateRandomName();

		AW_API_SynchroniseContracts.DTO_Role newRole = new AW_API_SynchroniseContracts.DTO_Role ();
		newRole.Type_Cd = LIFE_ASSURED_TYPE_CODE;
		newRole.Type_Tx = LIFE_ASSURED;
		newRole.Entity_Person = newEntityPerson;
		newRole.Cessionary = dtoCessionary;
		newRole.Accounts = dtoAccounts;
		//newRole.Entity_Organization = organisation;
		dtoRoles.add(newRole);

		dtoContract2.Roles = dtoRoles;
		dtoContract2.Inception = dtoInception;

		current1.Payment_Method_Tx = 'SO';

		//Creating Contract Data which will update the existing Insurance Policy in Salesforce
		dtoUpdatedContract.Id = newPolicy.Name;
		dtoUpdatedContract.Type_Cd = STR_ONE;
		dtoUpdatedContract.Type_Tx = UNIVERSAL_LIFE;
		dtoUpdatedContract.Contract_Status_Ind = SC_UTIL_Contracts.STATUS_IN_FORCE;
		dtoUpdatedContract.Inception = dtoInception;
		dtoUpdatedContract.Current = current1;

		dtoUpdatedContract.Roles = dtoRoles;

		dtoContracts.add(dtoUpdatedContract);

		return dtoContracts;
	}

	/**
	 * @description method to set the financial accounts to be updated or deleted
	 *
	 * @param foundFinancialAccounts financialAccounts to be processed
	 * @param accountToBeUpdatedId stores the account Id to be updated
	 */
	private static void processFinancialAccounts(List<FinServ__FinancialAccount__c> foundFinancialAccounts, Id accountToBeUpdatedId)
	{
		financialAccountToBeUpdated = new FinServ__FinancialAccount__c();
		financialAccountToBeDeleted = new FinServ__FinancialAccount__c();

		for(FinServ__FinancialAccount__c foundFinancialAccount : foundFinancialAccounts)
		{
			if(foundFinancialAccount.FinServ__PrimaryOwner__c == accountToBeUpdatedId)
			{
				financialAccountToBeUpdated = foundFinancialAccount;
			}
			else
			{
				financialAccountToBeDeleted = foundFinancialAccount;
			}
		}
	}

	/**
	 * @description method to set the Insurance Policies to be updated or deleted
	 *
	 * @param foundPolicies InsurancePolicies to be processed
	 * @param accountToBeUpdatedId stores the account Id to be updated
	 */
	private static void processInsurancePolicies(List<InsurancePolicy> foundPolicies, Id accountToBeUpdatedId)
	{
		policyToBeUpdated = new InsurancePolicy();
		policyToBeDeleted = new InsurancePolicy();

		for(InsurancePolicy foundPolicy : foundPolicies)
		{
			if(foundPolicy.NameInsuredId == accountToBeUpdatedId)
			{
				policyToBeUpdated = foundPolicy;
			}
			else
			{
				policyToBeDeleted = foundPolicy;
			}
		}
	}

	/**
	 * @description Will populate the test data needed for Cessionary DTO
	 *
	 * @return cessionary DTO
	 */
	private static AW_API_SynchroniseContracts.DTO_Cessionary populateCessionaryDTO()
	{
		AW_API_SynchroniseContracts.DTO_Cessionary dtoCessionary = new AW_API_SynchroniseContracts.DTO_Cessionary();

		dtoCessionary.Initials = CMN_DAL_SObjectDomain.generateRandomName();
		dtoCessionary.Last_Nm = CMN_DAL_SObjectDomain.generateRandomName();
		dtoCessionary.Title_Tx = CMN_DAL_SObjectDomain.generateRandomName();
		dtoCessionary.Type_Tx = CMN_DAL_SObjectDomain.generateRandomName();

		return dtoCessionary;
	}

	/**
	 * @description Will populate the test data needed for account DTO
	 *
	 * @return account DTO
	 */
	private static AW_API_SynchroniseContracts.DTO_Account populateAccountDTO()
	{
		AW_API_SynchroniseContracts.DTO_Account dtoAccount = new AW_API_SynchroniseContracts.DTO_Account();

		dtoAccount.Acc_Holder_Nm = CMN_DAL_SObjectDomain.generateRandomName();
		dtoAccount.Bank_Nm = CMN_DAL_SObjectDomain.generateRandomName();
		dtoAccount.Branch_Cd = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoAccount.Id = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoAccount.Type_Tx = CMN_DAL_SObjectDomain.generateRandomName();

		return dtoAccount;
	}

	/**
	 * @description Will populate the test data needed for Email address DTO
	 *
	 * @return Email address DTO
	 */
	private static AW_API_SynchroniseContracts.DTO_EmailAddress populateEmailDTO()
	{
		AW_API_SynchroniseContracts.DTO_EmailAddress dtoEmail = new AW_API_SynchroniseContracts.DTO_EmailAddress();

		dtoEmail.Email_Addr = CMN_DAL_SObjectDomain.generateRandomEmail();

		return dtoEmail;
	}

	/**
	 * @description Will populate the test data needed for Registration DTO
	 *
	 * @param dtoRequest the parent request dto
	 * @param registrationType indicates the registration type like Id number/passport
	 *
	 * @return Registration DTO
	 */
	private static AW_API_SynchroniseContracts.DTO_Registration populateRegistrationDTO(AW_API_SynchroniseContracts.DTO_Request dtoRequest, String registrationType)
	{
		AW_API_SynchroniseContracts.DTO_Registration dtoRegistration = new AW_API_SynchroniseContracts.DTO_Registration();

		dtoRegistration.Registration_Number = dtoRequest.identificationNumber;
		dtoRegistration.Registration_Type_Cd = registrationType;
		dtoRegistration.Registration_Type_Tx = registrationType;

		if(registrationType == AW_API_SynchroniseContracts.PASSPORT_REGISTRATION_TYPE_CODE)
		{
			dtoRegistration.Citizenship_Country_Cd = CMN_DAL_SObjectDomain.generateRandomNumber();
			dtoRegistration.Citizenship_Country_Tx = CMN_DAL_SObjectDomain.generateRandomName();
			dtoRegistration.Country_Of_Issue_Cd = CMN_DAL_SObjectDomain.generateRandomNumber();
			dtoRegistration.Country_Of_Issue_Tx = CMN_DAL_SObjectDomain.generateRandomName();
			dtoRegistration.Expiry_Date = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
			dtoRegistration.Issue_Date = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		}

		return dtoRegistration;
	}

	/**
	 * @description Will populate the test data needed for phone DTO
	 *
	 * @param facilityCode code to identify landline/cell
	 * @param usageCode code to personal/business
	 *
	 * @return phone DTO
	 */
	private static AW_API_SynchroniseContracts.DTO_Telephone populatePhoneDTO(String facilityCode, String usageCode)
	{
		AW_API_SynchroniseContracts.DTO_Telephone dtoTelephone = new AW_API_SynchroniseContracts.DTO_Telephone();

		dtoTelephone.Facility_Cd = facilityCode;
		dtoTelephone.Tel_No = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoTelephone.Usage_Cd = usageCode;

		return dtoTelephone;
	}

	/**
	 * @description Will populate the test data needed for AccountsSODTO
	 *
	 * @return AccountsSO DTO
	 */
	private static AW_API_SynchroniseContracts.DTO_AccountsSO populateAccountsSODTO()
	{
		AW_API_SynchroniseContracts.DTO_AccountsSO dtoAccountsSO = new AW_API_SynchroniseContracts.DTO_AccountsSO();

		dtoAccountsSO.Employee_No = CMN_DAL_SObjectDomain.generateRandomName();
		dtoAccountsSO.Facility_Group = CMN_DAL_SObjectDomain.generateRandomName();
		dtoAccountsSO.Facility_Nm = CMN_DAL_SObjectDomain.generateRandomName();
		dtoAccountsSO.Facility_No = CMN_DAL_SObjectDomain.generateRandomName();
		dtoAccountsSO.PayPoint_No = CMN_DAL_SObjectDomain.generateRandomName();

		return dtoAccountsSO;
	}

	/**
	 * @description Will populate the test data needed for inception DTO
	 *
	 * @return inception DTO
	 */
	private static AW_API_SynchroniseContracts.DTO_Inception populateInceptionDTO()
	{
		AW_API_SynchroniseContracts.DTO_Inception dtoInception = new AW_API_SynchroniseContracts.DTO_Inception();

		dtoInception.Commencement_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoInception.Cover_Type_Cd = INCEPTION_TYPE_CODE;
		dtoInception.Guarantee_Val = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoInception.Package_No = String.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber());
		dtoInception.Srp_Ind = AW_API_SynchroniseContracts.CHECKBOX_INDICATOR;

		return dtoInception;
	}

	/**
	 * @description Will populate the test data needed for organization DTO
	 *
	 * @param dtoEmails list of email Address associated to the organization
	 * @param dtoTelephones list of telephone associated to the organization
	 *
	 * @return Initialised object
	 */
	private static AW_API_SynchroniseContracts.DTO_Organization populateOrganizationDTO
			(List<AW_API_SynchroniseContracts.DTO_EmailAddress> dtoEmails, List<AW_API_SynchroniseContracts.DTO_Telephone> dtoTelephones)
	{
		AW_API_SynchroniseContracts.DTO_Organization dtoOrganization = new AW_API_SynchroniseContracts.DTO_Organization();

		dtoOrganization.EmailAddresses = dtoEmails;
		dtoOrganization.Incorporation_Country_Tx = CMN_DAL_SObjectDomain.generateRandomName();
		dtoOrganization.Incorporation_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoOrganization.Name = CMN_DAL_SObjectDomain.generateRandomName();
		dtoOrganization.Org_Type_Tx = CMN_DAL_SObjectDomain.generateRandomName();
		dtoOrganization.Registration_No = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoOrganization.Suffix = CMN_DAL_SObjectDomain.generateRandomName();
		dtoOrganization.Telephones = dtoTelephones;

		return dtoOrganization;
	}

	/**
	 * @description Will populate the test data needed for entityPerson DTO
	 *
	 * @param dtoEmails list of email Address associated to the person
	 * @param dtoTelephones list of telephone associated to the person
	 * @param dtoRegistrations list of telephone associated to the person
	 *
	 * @return Person DTO
	 */
	private static AW_API_SynchroniseContracts.DTO_Person populateEntityPersonDTO
			(
					List<AW_API_SynchroniseContracts.DTO_EmailAddress> dtoEmails,
					List<AW_API_SynchroniseContracts.DTO_Telephone> dtoTelephones,
					List<AW_API_SynchroniseContracts.DTO_Registration> dtoRegistrations
			)
	{
		AW_API_SynchroniseContracts.DTO_Person dtoPerson = new AW_API_SynchroniseContracts.DTO_Person();

		dtoPerson.Birth_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoPerson.EmailAddresses = dtoEmails;
		dtoPerson.Id = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoPerson.Identity_No = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
		dtoPerson.Registrations = dtoRegistrations;
		dtoPerson.Telephones = dtoTelephones;
		dtoPerson.Title_Tx = TITLE_MR;

		return dtoPerson;
	}

	/**
	 * @description Will populate the test data needed for Benefits DTO
	 *
	 * @param typeText indicates the name of the benefit type
	 * @param typeCode indicates the code of the benefit type
	 * @param expenseIndicator indicates if the benefit has immediate expense benefit
	 *
	 * @return Benefits DTO
	 */
	private static AW_API_SynchroniseContracts.DTO_Benefit populateBenefitDTO(String typeText, String typeCode, String expenseIndicator)
	{
		AW_API_SynchroniseContracts.DTO_Benefit dtoBenefit = new AW_API_SynchroniseContracts.DTO_Benefit();

		dtoBenefit.Benefit_Amt = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoBenefit.End_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoBenefit.Imm_Exp_Benefit_Ind = expenseIndicator;
		dtoBenefit.Orig_Benefit_Amt = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoBenefit.Start_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoBenefit.Status_Cd = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoBenefit.Status_Rsn_Cd = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoBenefit.Term = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoBenefit.Type_Cd = typeCode;
		dtoBenefit.Type_Tx = typeText;

		return dtoBenefit;
	}

	/**
	 * @description Will populate the test data needed for Illustrated DTO
	 *
	 * @return Illustrated DTO
	 */
	private static AW_API_SynchroniseContracts.DTO_Illustrated populateIllustratedDTO()
	{
		AW_API_SynchroniseContracts.DTO_Illustrated dtoIllustrated = new AW_API_SynchroniseContracts.DTO_Illustrated();

		dtoIllustrated.Illustr_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoIllustrated.Illustr_Maturity_Val = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoIllustrated.Illustr_Val = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();

		return dtoIllustrated;
	}

	/**
	 * @description Will populate the test data needed for portfolio DTO
	 *
	 * @param type indicates the name of the portfolio
	 *
	 * @return portfolio DTO
	 */
	private static AW_API_SynchroniseContracts.DTO_Portfolio populatePortfolioDTO(String type)
	{
		AW_API_SynchroniseContracts.DTO_Portfolio dtoPortfolio = new AW_API_SynchroniseContracts.DTO_Portfolio();

		dtoPortfolio.Buy_Price = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoPortfolio.Sell_Price = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoPortfolio.Share_Perc = CMN_DAL_SObjectDomain.generateRandomPercentageAsString();
		dtoPortfolio.Type_Tx = type;
		dtoPortfolio.Unit_Amt = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();

		return dtoPortfolio;
	}

	/**
	 * @description Will populate the test data needed for associatedContracts DTO
	 *
	 * @return associatedContracts DTO
	 */
	private static AW_API_SynchroniseContracts.DTO_AssociatedContract populateAssociatedContractDTO()
	{
		AW_API_SynchroniseContracts.DTO_AssociatedContract dtoAssociatedContract = new AW_API_SynchroniseContracts.DTO_AssociatedContract();
		dtoAssociatedContract.Contract_Number = CMN_DAL_SObjectDomain.generateRandomNumber();
		return dtoAssociatedContract;
	}

	/**
	 * @description Will populate the test data needed for current DTO
	 *
	 * @param paymentMethod indicates the name of the payment method
	 * @param paymentFrequency indicates the payment frequency
	 *
	 * @return current DTO
	 */
	private static AW_API_SynchroniseContracts.DTO_Current populateCurrentDTO(String paymentMethod, String paymentFrequency)
	{
		AW_API_SynchroniseContracts.DTO_Current dtoCurrent = new AW_API_SynchroniseContracts.DTO_Current();

		dtoCurrent.Abi_Perc = CMN_DAL_SObjectDomain.generateRandomNumber(INT_TWO);
		dtoCurrent.Abi_Tx = CMN_UTIL_Random.randomAlphabetic(INT_TEN);
		dtoCurrent.Adhoc_Contrib_Amt = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Aids_Incl_Ind = INDICATOR_NO;
		dtoCurrent.Capital_Content_Amt = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Cash_Back_Date = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoCurrent.Cash_Back_Earned = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Cash_Back_Ind = INDICATOR_NO;
		dtoCurrent.Cpr_Advance_Amt = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Credit_Aci_Perc = CMN_DAL_SObjectDomain.generateRandomNumber(INT_TWO);
		dtoCurrent.Curr_Ind = INDICATOR_YES;
		dtoCurrent.Deduction_Amt = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Escal_Perc = CMN_DAL_SObjectDomain.generateRandomNumber(INT_TWO);
		dtoCurrent.Expiry_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoCurrent.Fund_Name = CMN_DAL_SObjectDomain.generateRandomName();
		dtoCurrent.Fund_Val = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Gross_Death_Val = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Guarantee_Expiry_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoCurrent.Guarantee_Review_Notified_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoCurrent.Hld_Status_Ind = INDICATOR_YES;
		dtoCurrent.Income_Drawdown_Tx = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoCurrent.Income_Freq_Tx = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoCurrent.Inv_Val = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Last_Income_Pmt_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoCurrent.Last_Withdrawal_Paid_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoCurrent.Loan_Interest_Rate = CMN_DAL_SObjectDomain.generateRandomNumber(INT_TWO);
		dtoCurrent.Maturity_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoCurrent.Member_Fund_Val = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Next_Billing_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoCurrent.OIP_Total_Inv_Amt = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Option_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoCurrent.Paid_To_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoCurrent.Paid_Up_Ben_Ind = INDICATOR_YES;
		dtoCurrent.Paid_Up_Contrib_Amt = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Paid_Up_Death_Val = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Participation_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoCurrent.Payment_Method_Tx = paymentMethod;
		dtoCurrent.Prem_Freq_Tx = paymentFrequency;
		dtoCurrent.Prem_Pattern_Cd = 'S';
		dtoCurrent.Prem_Recieved_Ind = INDICATOR_YES;
		dtoCurrent.Qual_Addlib_Ind = INDICATOR_NO;
		dtoCurrent.Ra_Emigration_Val = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Recur_Aci_Perc = CMN_DAL_SObjectDomain.generateRandomNumber(INT_TWO);
		dtoCurrent.Recur_Inv_Amt = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Recur_Inv_Freq_Cd = 'S';
		dtoCurrent.Refund_Available_Amt = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Restriction_End_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoCurrent.Section14_Transfer_Val = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Smoker_Rate_Ind = INDICATOR_YES;
		dtoCurrent.Total_Inv_Amt = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Total_Package_Death_Val = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Total_Repayable_Amt = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();
		dtoCurrent.Total_Withdrawal_Dt = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		dtoCurrent.Transaction_Fee = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();

		return dtoCurrent;
	}

	/**
	* @description Method to create and return associated contracts
	*
	* @param caseId The case object against which the associated contracts items should be created
	* @param numberOfRecords The number of records to be created
	* @param financialAccountId The financial account object against which the associated contracts items should be created
	* @param insurancePolicyId The insurance policy object against which the associated contracts items should be created
	*
	* @return A List associated contracts Item that's been committed
	*/
	public static List<SC_AssociatedContract__c> newAssociatedContracts(Id caseId, Integer numberOfRecords, Id financialAccountId, Id insurancePolicyId)
	{
	List<SC_AssociatedContract__c> newContracts = new List<SC_AssociatedContract__c>();

	for(Integer i = 0; i < numberOfRecords; i++)
	{
		SC_AssociatedContract__c newContract = new SC_AssociatedContract__c();

		newContract.SC_Case__c = caseId;
		newContract.SC_FinancialAccount__c = financialAccountId;
		newContract.SC_InsurancePolicy__c = insurancePolicyId;

		newContracts.add(newContract);
	}

	return newContracts;
	}
}