/**
 * @description API handler to support updating all Contracts
 *
 * @see AW_URL_Contract
 * @see AW_API_SynchroniseContracts_TEST
 *
 * @author jayanth.kumar.s@accenture.com, jason.van.beukering@accenture.com
 *
 * @date May 2021, June 2023
 *
 * @since ST-217444, ST-146028, ST-352261
 */
@SuppressWarnings('PMD.CognitiveComplexity,PMD.CyclomaticComplexity,PMD.ExcessiveClassLength,PMD.StdCyclomaticComplexity,PMD.StdCognitiveComplexity,PMD.ExcessivePublicCount')
public inherited sharing class AW_API_SynchroniseContracts extends CMN_API_RestBaseInbound
{
	private Account foundAccount;
	private Boolean adviserChanged = false;
	private Boolean isMasterAccount = false;
	private CMN_UTIL_SObjectIndex productCodeByCompositeMap;
	private List<Account> foundAccounts = new List<Account>();
	private Map<String, SObject> benefitCodeByLabelMap;
	private Map<String, SObject> financialAccountsByNumberMap;
	private Map<String, SObject> insurancePoliciesByNameMap;
	private Set<Id> foundAccountIds = new Set<Id>();
	private String consultantRoleCode;
	private String productCategory;
	private String productSubCategory;
	private String productTypeCode;
	private String prototypeCode;
	private final List<Account> accountsToSynchronise = new List<Account>();
	private final Map<String, Account> accountByNumberAndCode = new Map<String, Account>();
	private final Map<String, Account> mapMasterAccounts = new Map<String, Account>();
	private final Map<String, Account> mapNonMasterAccounts = new Map<String, Account>();
	private final Map<String, SC_ConsultantCodes__c> consultantsByConsultantCodeMap = new Map<String, SC_ConsultantCodes__c>();
	private final Map<String, String> accountStatusByNumberAndCode = new Map<String, String>();
	private final Set<Id> existingFinancialAccountIds = new Set<Id>();
	private final Set<Id> existingPolicyIds = new Set<Id>();
	private final Set<String> accountSKFIds = new Set<String>();

	private static final List<String> SEARCH_FIELDS = new List<String>
	{
			AW_DAL_ProductCodeAndCategoryMapping.FIELD_PRODUCT_CODE, AW_DAL_ProductCodeAndCategoryMapping.FIELD_PROTO_TYPE
	};

	@TestVisible
	private static final String BUSINESS_ID_TYPE = 'Company Registration';
	@TestVisible
	private static final String CONSULTANT_ROLE = 'Consultant';
	@TestVisible
	private static final String OWNER_ROLE = 'OWNER';
	private static final String POLICY_HOLDER_ROLE = 'POLICY HOLDER';
	@TestVisible
	private static final String ERROR_NO_CLIENT_FOUND = 'Unable to process request as no Client was found.';
	@TestVisible
	private static final String ERROR_NO_IDENTITY_NUMBER = 'Unable to process request as Identity Number is blank.';
	@TestVisible
	private static final String ERROR_NO_IDENTITY_TYPE = 'Unable to process request as Identity Type is blank.';
	@TestVisible
	private static final String WARNING_CONTRACT_IGNORED_FMT = 'The following policy was removed as the client with identity number {0} was not in the owner role\n policy: {1}';
	@TestVisible
	private static final String WARNING_REQUEST_IGNORED = 'Request Ignored: The policy list is empty which is invalid.';
	@TestVisible
	private static final String ERROR_PRODUCT_CODE_AND_CATEGORY_MAPPING =
			'The Contracts related to this Client: {0} were partially updated because Product Code and Category Mapping were not found.';
	@TestVisible
	private static final String CHECKBOX_INDICATOR = 'Y';
	@TestVisible
	private static final String PASSPORT_REGISTRATION_TYPE_CODE = 'PASSPORT';
	@TestVisible
	private static final String ID_REGISTRATION_TYPE_CODE = 'ID_NO';
	@TestVisible
	private static final String TAX_REGISTRATION_TYPE_CODE = 'TAX_NO';
	@TestVisible
	private static final String CURRENT_PAYMENT_TYPE = 'DEBIT ORDER';
	@TestVisible
	private static final String WORK_PHONE_USAGE_CODE = 'BUS';
	@TestVisible
	private static final String PERSONAL_PHONE_USAGE_CODE = 'PVT';
	@TestVisible
	private static final String LAND_LINE_FACILITY_CODE = 'LL';
	@TestVisible
	private static final String CELL_PHONE_FACILITY_CODE = 'CELL';
	@TestVisible
	private static final String LIFE_BENEFIT_CODE = '001';
	@TestVisible
	private static final String LIFE_BENEFIT_TYPE = 'LIFE COVER';
	@TestVisible
	private static final String METHOD_VALIDATE_CONTRACTS = 'AW_API_SynchroniseContracts/extractConsultantsAndRemoveInvalidContracts';
	@TestVisible
	private static final String METHOD_REGISTER_CHANGES = 'AW_API_SynchroniseContracts/registerDatabaseChanges';

	private static final Date DATE_NULL_IDENTIFIER = null;
	private static final Decimal DECIMAL_NULL_IDENTIFIER = null;
	private static final Decimal ZERO_DECIMAL = 0;
	private static final String ACI_AMOUNT = '99.99';
	private static final String BANK_ACCOUNT_HOLDER_NAME_FIELD = 'CMN_BankAccountHolderName__c';
	private static final String BANK_ACCOUNT_NUMBER_FIELD = 'CMN_BankAccountNumber__c';
	private static final String BANK_ACCOUNT_TYPE_FIELD = 'CMN_BankAccountType__c';
	private static final String BANK_BRANCH_CODE_FIELD = 'CMN_BankBranchCode__c';
	private static final String BANK_NAME_FIELD = 'CMN_BankName__c';
	private static final String CESSIONARY_INITIALS_FIELD = 'CMN_CessionaryInitials__c';
	private static final String CESSIONARY_NAME_FIELD = 'CMN_CessionaryName__c';
	private static final String CESSIONARY_TITLE_FIELD = 'CMN_CessionaryTitle__c';
	private static final String CESSIONARY_TYPE_FIELD = 'CMN_CessionaryType__c';
	private static final String EMPLOYEE_NUMBER_FIELD = 'CMN_EmployeeNumber__c';
	private static final String FACILITY_GROUP_FIELD = 'CMN_FacilityGroup__c';
	private static final String FACILITY_NAME_FIELD = 'CMN_FacilityName__c';
	private static final String FACILITY_NUMBER_FIELD = 'CMN_FacilityNumber__c';
	private static final String FACILITY_TYPE_FIELD = 'CMN_FacilityType__c';
	private static final String INTERMEDIATE_POLICY = '1';
	private static final String INVESTMENT_PRODUCT_CATEGORY = 'Investment';
	private static final String MOBILE_FIELD = 'CMN_Mobile__c';
	private static final String ORPHAN_POLICY = '0';
	private static final String PAY_POINT_NUMBER_FIELD = 'CMN_PayPointNumber__c';
	private static final String PHONE_FIELD = 'CMN_PhoneNumber__c';
	private static final String PREMIUM_FREQUENCY_MONTHLY = 'Monthly';
	private static final String PREMIUM_FREQUENCY_SINGLE = 'Single';
	private static final String STRING_NULL_IDENTIFIER = null;
	private static final String WORK_PHONE_FIELD = 'CMN_WorkPhoneNumber__c';

	/**
	 * @description Class name for the web service handler
	 */
	public static final String SERVICE_NAME = AW_API_SynchroniseContracts.class.getName();

	/**
	 * @description Initialise variable Object variables
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description register all the object types we want to update
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType>
		{
				Account.SObjectType,
				FinServ__FinancialAccount__c.SObjectType,
				FinServ__FinancialAccountRole__c.SObjectType,
				FinServ__FinancialHolding__c.SObjectType,
				InsurancePolicy.SObjectType,
				InsurancePolicyParticipant.SObjectType,
				InsurancePolicyCoverage.SObjectType,
				CMN_WebserviceCallQueue__c.SObjectType
		});
	}

	/**
	 * @description Will check that the information received is valid and query any related data
	 */
	protected override void processRequest()
	{
		super.processRequest();

		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;
		Set<Id> adviserAccountIds = new Set<Id>();
		Set<Id> masterAccountIds = new Set<Id>();

		if(String.isNotBlank(dtoRequest.identificationNumber) && String.isNotBlank(dtoRequest.identificationNumberType))
		{
			foundAccounts = AW_DAL_Account.findByIdentityNumber(new Set<String> {dtoRequest.identificationNumber});

			if(!foundAccounts.isEmpty())
			{
				Set<String> consultantCodes = new Set<String>();

				extractConsultantsAndRemoveInvalidContracts(dtoRequest, consultantCodes);

				if(!consultantCodes.isEmpty())
			{
				for(SC_ConsultantCodes__c consultantCode : SC_DAL_ConsultantCodes.findByConsultantCode(consultantCodes))
				{
					consultantsByConsultantCodeMap.put(consultantCode.Name, consultantCode);
				}
			}

				for(Account foundAccount : foundAccounts)
				{
					String identityNumber = foundAccount.IsPersonAccount ? foundAccount.AW_IdentificationNumber__pc : foundAccount.AW_CompanyRegistrationTrustNumber__c;

					if(AW_DAL_Account.MASTER_ACCOUNT_RECORDTYPE_NAMES.contains(foundAccount.RecordType.DeveloperName))
					{
						masterAccountIds.add(foundAccount.Id);
						mapMasterAccounts.put(identityNumber, foundAccount);
					}
					else
					{
						adviserAccountIds.add(foundAccount.Id);
						mapNonMasterAccounts.put(getKeyToFetchAccount(foundAccount), foundAccount);
					}
				}

				//US 352261 - Create Child Account(Adviser Client) if it is not present and Adviser User record in present in Salesforce for the consultant code
				// returned in the payload
				if(!consultantsByConsultantCodeMap.isEmpty())
				{
					insertActiveChildAccounts();
				}

				foundAccountIds = adviserAccountIds;
				foundAccountIds.addAll(masterAccountIds);

				financialAccountsByNumberMap = CMN_UTIL_System.convertListToSingleStringMap
						(AW_DAL_FinancialAccount.findByPrimaryOwnerWithChildDetails(foundAccountIds), AW_DAL_FinancialAccount.FIELD_FINANCIAL_ACCOUNT_NUMBER);

				insurancePoliciesByNameMap = CMN_UTIL_System.convertListToSingleStringMap
						(AW_DAL_InsurancePolicy.findChildrenByAccountId(foundAccountIds), AW_DAL_InsurancePolicy.FIELD_NAME);

				benefitCodeByLabelMap = CMN_UTIL_System.convertListToSingleStringMap
						(AW_DAL_BenefitCodeAndCategoryMapping.getAll(), AW_DAL_BenefitCodeAndCategoryMapping.FIELD_TYPE_CODE);

				productCodeByCompositeMap = new CMN_UTIL_SObjectIndex(SEARCH_FIELDS).putAll(AW_DAL_ProductCodeAndCategoryMapping.getAll());
			}
			else
			{
				throw new SearchException(ERROR_NO_CLIENT_FOUND);
			}
		}
		else if(String.isEmpty(dtoRequest.identificationNumber))
		{
			throw new SearchException(ERROR_NO_IDENTITY_NUMBER);
		}
		else if(String.isEmpty(dtoRequest.identificationNumberType))
		{
			throw new SearchException(ERROR_NO_IDENTITY_TYPE);
		}
	}

	/**
	 * @description Will find all the adviser consultant codes, as well as removing any policies where the policy isn't owned by the provided client
	 *
	 * @param dtoRequest The inbound request
	 * @param consultantCodes A set to which we must add all the found consultant codes
	 */
	@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
	private void extractConsultantsAndRemoveInvalidContracts(DTO_Request dtoRequest, Set<String> consultantCodes)
	{
		if(dtoRequest.contracts != null && !dtoRequest.contracts.isEmpty())
		{
			for(Integer i = dtoRequest.contracts.size() - 1; i >= 0; i--)
			{
				DTO_Contract dtoContract = dtoRequest.contracts[i];
				Boolean hasValidOwner = false;

				if(dtoContract.Roles != null && !dtoContract.Roles.isEmpty())
				{
					for(DTO_Role dtoRole : dtoContract.Roles)
					{
						if(CONSULTANT_ROLE.equalsIgnoreCase(dtoRole.Type_Tx))
						{
							consultantCodes.add(dtoRole.Id);
						}
						else if(!hasValidOwner)
						{
							hasValidOwner = hasValidOwner(dtoRole, dtoRequest.identificationNumber);
						}
					}
				}

				//If we don't have a valid policy owner, remove policy from the list
				if(!hasValidOwner)
				{
					DTO_Contract removedContract = dtoRequest.contracts.remove(i);
					String warningMessage = String.format(WARNING_CONTRACT_IGNORED_FMT, new List<String> {dtoRequest.identificationNumber, JSON.serializePretty(removedContract)});
					CMN_UTIL_Logger.warn(warningMessage, METHOD_VALIDATE_CONTRACTS);
				}
			}
		}
	}

	/**
	 * @description Will determine if the current
	 *
	 * @param dtoRole The role to check to see if matches the
	 * @param ownerIdentityNumber The identity number to match
	 *
	 * @return Either true, if we could determine from the role if this is the owner, otherwise false
	 */
	private Boolean hasValidOwner(DTO_Role dtoRole, String ownerIdentityNumber)
	{
		Boolean hasValidOwner = false;

		if
		(
				OWNER_ROLE.equalsIgnoreCase(dtoRole.Type_Cd) ||
				OWNER_ROLE.equalsIgnoreCase(dtoRole.Type_Tx) ||
				POLICY_HOLDER_ROLE.equalsIgnoreCase(dtoRole.Type_Tx)
		)
		{
			DTO_RoleDetails dtoRoleDetails = getRoleDetails(dtoRole);

			String roleIdentityNumber;

			if(dtoRoleDetails.hasPersonEntity)
			{
				roleIdentityNumber = getIdentityNumber(dtoRole.Entity_Person.Identity_No, dtoRole.Entity_Person.Registrations);
			}
			else if(dtoRoleDetails.hasOrganisationEntity)
			{
				roleIdentityNumber = dtoRole.Entity_Organization.Registration_No;
			}

			hasValidOwner = ownerIdentityNumber.equalsIgnoreCase(roleIdentityNumber);
		}

		return hasValidOwner;
	}

	/**
	 * @description Will return identity number from registrations or the one provided
	 *
	 * @param identityNumber The identity number of the client
	 * @param dtoRegistrations Registrations linked to the client, which may contain the identityNumber
	 *
	 * @return blank or the identity number
	 */
	private static String getIdentityNumber(String identityNumber, List<DTO_Registration> dtoRegistrations)
	{
		String foundIdentityNumber = identityNumber;

		if(dtoRegistrations != null)
		{
			for(DTO_Registration dtoRegistration : dtoRegistrations)
			{
				if(
						String.isNotBlank(dtoRegistration.Registration_Number) &&
						(
								ID_REGISTRATION_TYPE_CODE.equalsIgnoreCase(dtoRegistration.Registration_Type_Cd) ||
								PASSPORT_REGISTRATION_TYPE_CODE.equalsIgnoreCase(dtoRegistration.Registration_Type_Cd)
						)
				)
				{
					foundIdentityNumber = CMN_UTIL_String.defaultIfEmpty(dtoRegistration.Registration_Number, foundIdentityNumber);
					break;
				}
			}
		}

		return foundIdentityNumber;
	}

	/**
	 * @description Will ensure that the change to Sobjects is registered to be committed after
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

		Boolean contractsReceived = dtoRequest.contracts != null && !dtoRequest.contracts.isEmpty();

		if(contractsReceived)
		{
			for(DTO_Contract dtoContract : dtoRequest.contracts)
			{
				adviserChanged = false;
				upsertContract(dtoContract);
			}
		}
		else
		{
			CMN_UTIL_Logger.warn(WARNING_REQUEST_IGNORED, METHOD_REGISTER_CHANGES);
		}

		for(Account account : foundAccounts)
		{
			String accountStatus = accountStatusByNumberAndCode.get(getKeyToFetchAccount(account));
			Account upsertAccount = new Account();

			if(account.Id != null)
			{
				upsertAccount.Id = account.Id;
			}
			else
			{
				upsertAccount = account;
			}

			// Set the Account status and Timestamp if Account Id is found in the map, otherwise set it to SUCCESSFUL
			upsertAccount.AW_PoliciesRefreshStatus__c = !contractsReceived ? AW_DAL_Account.PICK_FAILED : String.isNotBlank(accountStatus) ? accountStatus : AW_DAL_Account.PICK_SUCCESSFUL;
			upsertAccount.AW_PoliciesRefreshStatusDate__c = Datetime.now();
			String identityNumber = account.IsPersonAccount ? account.AW_IdentificationNumber__pc : account.AW_CompanyRegistrationTrustNumber__c;

			//link non master account to master account for the scenario where master account is not linked
			isMasterAccount = AW_DAL_Account.MASTER_ACCOUNT_RECORDTYPE_NAMES.contains(account.RecordType.DeveloperName);
			if(!isMasterAccount && String.isBlank(account.AW_ParentAccount__c) && mapMasterAccounts.containsKey(identityNumber))
			{
				upsertAccount.AW_ParentAccount__c = mapMasterAccounts.get(identityNumber).Id;
			}

			// US 352261 - Set the Account Field value if contract is received
			if(accountByNumberAndCode.containsKey(getKeyToFetchAccount(account)))
			{
				//set Account Status to Active if it is Prospect
				upsertAccount.FinServ__Status__c = AW_DAL_Account.STATUS_PROSPECT.equalsIgnoreCase(account.FinServ__Status__c) ?
						AW_DAL_Account.STATUS_ACTIVE : account.FinServ__Status__c;

				Account masterAccount = mapMasterAccounts.get(identityNumber);

				if(masterAccount != null)
				{
					upsertAccount.AW_SKF_Id__c = String.isBlank(account.AW_SKF_Id__c) ? masterAccount.AW_SKF_Id__c : account.AW_SKF_Id__c;
				}
			}

			if(!mapNonMasterAccounts.isEmpty())
			{
				if(upsertAccount.AW_PoliciesRefreshStatus__c == AW_DAL_Account.PICK_SUCCESSFUL) //Indicates the status is updated to success status
				{
					if(!String.isBlank(account.AW_SKF_Id__c))
					{
						accountSKFIds.add(account.AW_SKF_Id__c);
					}
				}
			}

			registerChange(upsertAccount);

			//US:435211 - trigger Prospect sync for new adviser Account
			if(!isMasterAccount && String.isBlank(upsertAccount.Id))
			{
				accountsToSynchronise.add(upsertAccount);
			}
		}

		if(!accountSKFIds.isEmpty())
		{
			List<Account> masterAccounts = AW_DAL_Account.findMasterBySkfId(accountSKFIds);

			setMasterAccountRefreshStatus(masterAccounts);
		}

	}

	/**
	 * @description Any actions to take after a commit is completed
	 */
	public override void onCommitWorkFinishing()
	{
		super.onCommitWorkFinishing();

		List<CMN_WebserviceCallQueue__c> queueItems = new List<CMN_WebserviceCallQueue__c>();

		//US:435211 - trigger Prospect sync for new adviser Account
		for(Account account : accountsToSynchronise)
		{
			queueItems.add(CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RestOutboundClientUpdated.SERVICE_NAME, account.Id));
		}

		CMN_DAL_SObjectDomain.insertDBObjects(queueItems);

		SC_UTIL_Contracts.deleteInactiveRoles(existingFinancialAccountIds, existingPolicyIds);

		addMissingAssociatedContracts();
		//Initiate rollup calculations immediately so that the delay for scheduled items is minimized
		Database.executeBatch(new dlrs.RollupJob());
	}

	/**
	 * @description Will query cache to see if any cases exist for the current account that have cases with missing
	 * associated contracts; i.e. when Case's where synchronised into Salesforce, the system was unable to find the policy
	 * in Salesforce. This information was then cached and a callout was made to get the latest policy information for
	 * the client.
	 *
	 * This method will add the missing policies to the case
	 */
	private void addMissingAssociatedContracts()
	{
		if(!mapMasterAccounts.isEmpty())
		{
			Set<Id> accountIds = new Set<Id>();

			for(String identityNumber : mapMasterAccounts.keySet())
			{
				Account foundAccount = mapMasterAccounts.get(identityNumber);
				accountIds.add(foundAccount.Id);
			}

			SC_UTIL_Contracts.addMissingAssociatedContracts(accountIds);
		}
	}

	/**
	 * @description Will determine what kind of contract was provided and then upsert said contract
	 *
	 * @param dtoContract The contract provided
	 */
	private void upsertContract(DTO_Contract dtoContract)
	{
		if(setFoundAccount(dtoContract))
		{
			productTypeCode = CMN_UTIL_String.isBlank(dtoContract.Type_Cd) ? dtoContract.Prod_Class_Cd : dtoContract.Type_Cd;
			prototypeCode = CMN_UTIL_String.isNumeric(dtoContract.Proto_Cd) ? dtoContract.Proto_Cd : null;

			// Removing leading zeros if any
			productTypeCode = String.isNotBlank(productTypeCode) ? String.valueOf(Integer.valueOf(productTypeCode)) : productTypeCode;
			prototypeCode = String.isNotBlank(prototypeCode) ? String.valueOf(Integer.valueOf(prototypeCode)) : prototypeCode;

			Map<String, Object> searchFieldsMap = new Map<String, Object>
			{
					AW_DAL_ProductCodeAndCategoryMapping.FIELD_PRODUCT_CODE => productTypeCode, AW_DAL_ProductCodeAndCategoryMapping.FIELD_PROTO_TYPE => prototypeCode
			};

			List<AW_ProductCodeAndCategoryMapping__mdt> productCodeAndCategoryList =
					(List<AW_ProductCodeAndCategoryMapping__mdt>)productCodeByCompositeMap.getAll(searchFieldsMap);

			//if more than one record exists with same product code and prototype code we are logging the same for tracking purpose
			if(productCodeAndCategoryList.size() > 1)
			{
				CMN_UTIL_Logger.debug('Product with Code: "' + productTypeCode + '" and Proto Type Code "' + productTypeCode + '" has multiple records',
						'AW_API_SynchroniseContracts/upsertContract');
			}

			String accountIdWithConsultantCode = getKeyToFetchAccount(foundAccount);

			if(productCodeAndCategoryList != null && !productCodeAndCategoryList.isEmpty())
			{
				AW_ProductCodeAndCategoryMapping__mdt productCodeAndCategoryRecord = productCodeAndCategoryList.iterator().next();
				productCategory = productCodeAndCategoryRecord.AW_ProductCategory__c;
				productSubCategory = productCodeAndCategoryRecord.AW_ProductSubCategory__c;

				if(productCodeAndCategoryRecord.AW_SalesforceObject__c.equalsIgnoreCase(AW_DAL_FinancialAccount.OBJECT_NAME))
				{
					upsertFinancialAccounts(dtoContract, accountIdWithConsultantCode);
				}
				else
				{
					upsertInsurancePolicies(dtoContract, accountIdWithConsultantCode);
				}
				setAccountStatus(accountIdWithConsultantCode, AW_DAL_Account.PICK_SUCCESSFUL);
			}
			else
			{
				setAccountStatus(accountIdWithConsultantCode, AW_DAL_Account.PICK_FAILED);
				callResult.errors.add(String.format(ERROR_PRODUCT_CODE_AND_CATEGORY_MAPPING, new List<String> {accountIdWithConsultantCode}));
			}
		}
	}

	/**
	 * @description Utility method that will match the account based on
	 * 1. Consultant Code and Identity Number
	 * 2. Identity Number if 1 returns nothing
	 *
	 * @param dtoContract The current contract we are processing
	 *
	 * @return Will return true if an account was matched in the Org
	 */
	private Boolean setFoundAccount(DTO_Contract dtoContract)
	{
		foundAccount = null;
		isMasterAccount = false;
		String currentAdvisorCode = null;
		String identificationNumber = ((DTO_Request)baseRequestDTO).identificationNumber;

		if(financialAccountsByNumberMap != null)
		{
			FinServ__FinancialAccount__c financialAccount = (FinServ__FinancialAccount__c)financialAccountsByNumberMap.get(dtoContract.Id);
			if(financialAccount != null)
			{
				for(FinServ__FinancialAccountRole__c accountRole : financialAccount.FinServ__FinancialAccountRoles__r)
				{
					if(accountRole.FinServ__Role__c == CONSULTANT_ROLE)
					{
						currentAdvisorCode = accountRole.CMN_ConsultantCode__c;
					}
				}
			}
		}
		if(dtoContract.Roles != null)
		{
			for(DTO_Role roles : dtoContract.Roles)
			{
				if(CONSULTANT_ROLE.equalsIgnoreCase(roles.Type_Tx))
				{
					String consultantCode = roles.Id;

					foundAccount = mapNonMasterAccounts.containsKey(identificationNumber + consultantCode) ? mapNonMasterAccounts.get(identificationNumber + consultantCode) : null;
					consultantRoleCode = consultantCode;

					if(currentAdvisorCode != null && !String.isBlank(currentAdvisorCode))
					{
						adviserChanged = currentAdvisorCode != consultantCode ? true : false;
					}

					//Keep trying to find account with consultant code, some contracts may have more than one
					if(foundAccount != null)
					{
						accountByNumberAndCode.put(getKeyToFetchAccount(foundAccount), foundAccount);
						break;
					}
				}
			}
		}

		foundAccount = foundAccount != null ? foundAccount : mapMasterAccounts.get(identificationNumber);

		Boolean accountExists = foundAccount != null;

		if(!accountExists)
		{
			callResult.errors.add(ERROR_NO_CLIENT_FOUND);
		}
		else
		{
			isMasterAccount = AW_DAL_Account.MASTER_ACCOUNT_RECORDTYPE_NAMES.contains(foundAccount.RecordType.DeveloperName);
		}

		return accountExists;
	}

	/**
	 * @description fetch Financial Accounts under the client account
	 *
	 * @param dtoContract The DTO that represents the JSON sent in a request
	 * @param accountIdWithConsultantCode Account Identification number with Consultant code
	 */
	private void upsertFinancialAccounts(DTO_Contract dtoContract, String accountIdWithConsultantCode)
	{
		SObject foundObject = financialAccountsByNumberMap.get(dtoContract.Id);

		FinServ__FinancialAccount__c upsertAccount = foundObject == null ?
				new FinServ__FinancialAccount__c() : (FinServ__FinancialAccount__c)CMN_DAL_SObjectDomain.newObjectFromExisting(foundObject, null);

		String recordTypeName = INVESTMENT_PRODUCT_CATEGORY.equalsIgnoreCase(productCategory) ?
				AW_DAL_FinancialAccount.RT_INVESTMENT_ACCOUNT : AW_DAL_FinancialAccount.RT_RETIREMENT_ACCOUNT;
		upsertAccount.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(FinServ__FinancialAccount__c.SObjectType, recordTypeName);

		populateFinancialAccountData(upsertAccount, dtoContract);
		deleteFinancialHoldings(upsertAccount);
		upsertFinancialAccountRoles(upsertAccount, dtoContract, accountIdWithConsultantCode);
		upsertFinancialHolding(upsertAccount, dtoContract.Benefits);
	}

	/**
	 * @description Map Financial Accounts data with the response data
	 *
	 * @param financialAccount The Financial Account record which needs to be created or updated
	 * @param dtoContract The DTO that represents the JSON sent in a request
	 */
	@SuppressWarnings('PMD.NcssMethodCount')
	public void populateFinancialAccountData(FinServ__FinancialAccount__c financialAccount, DTO_Contract dtoContract)
	{
		financialAccount.AW_LastIncomeDate__c = getDateValue(dtoContract.Current.Last_Income_Pmt_Dt);
		financialAccount.AW_ProductTypeCode__c = CMN_UTIL_String.isBlank(dtoContract.Type_Cd) ? dtoContract.Prod_Class_Cd : dtoContract.Type_Cd;
		financialAccount.AW_PrototypeCode__c = prototypeCode;
		financialAccount.AW_StatusReason__c = getStringValue(dtoContract.Current.Status_Rsn_Tx);
		financialAccount.CMN_OriginalCommencementDate__c = getDateValue(dtoContract.Inception.Orig_Commencement_Dt);
		financialAccount.CMN_PolicySourceSystem__c = dtoContract.Source;
		financialAccount.FinServ__FinancialAccountNumber__c = dtoContract.Id;
		financialAccount.FinServ__OpenDate__c = getDateValue(dtoContract.Inception.Commencement_Dt);
		financialAccount.FinServ__PaymentFrequency__c = getStringValue(dtoContract.Current.Prem_Freq_Tx);
		financialAccount.FinServ__Status__c = getStringValue(dtoContract.Contract_Status_Ind, getStringValue(dtoContract.Current.Status_Tx));
		financialAccount.Name = CMN_UTIL_String.isBlank(dtoContract.Type_Tx) ? dtoContract.Prod_Class_Tx : dtoContract.Type_Tx;

		if(String.isBlank(financialAccount.FinServ__PaymentFrequency__c))
		{
			//229051 Logic: If Prem_Freq_Tx is either not in payload or empty then map Prem_Freq_Cd OR Recur_Inv_Freq_Cd instead.
			String premiumFrequency = getStringValue(dtoContract.Current.Prem_Freq_Cd, dtoContract.Current.Recur_Inv_Freq_Cd);
			if(String.isNotBlank(premiumFrequency))
			{
				financialAccount.FinServ__PaymentFrequency__c =
						premiumFrequency.equalsIgnoreCase('M') ? PREMIUM_FREQUENCY_MONTHLY : premiumFrequency.equalsIgnoreCase('S') ? PREMIUM_FREQUENCY_SINGLE : null;
			}
		}

		financialAccount.AW_AccessibleAmount__c = getDecimalValue(dtoContract.Current.Accessible_Amt);
		financialAccount.AW_ActualPremiumAmount__c = getDecimalValue(dtoContract.Current.Actual_Prem_Amt);
		financialAccount.AW_AdvanceAvailable__c = getDecimalValue(dtoContract.Current.Adv_Avail_Amt);
		financialAccount.AW_CurrentValue__c = getCurrentValue(dtoContract);
		financialAccount.AW_IncomeFrequency__c = getStringValue(dtoContract.Current.Income_Freq_Tx);
		financialAccount.AW_InvestmentValue__c = getDecimalValue(dtoContract.Current.Inv_Val);
		financialAccount.AW_LastIncomeAmount__c = getDecimalValue(dtoContract.Current.Last_Income_Pmt_Amt);
		financialAccount.AW_RepayableAmount__c = getDecimalValue(dtoContract.Current.Repayable_Amt);
		financialAccount.AW_SurrenderValue__c = getDecimalValue(dtoContract.Current.Surrender_Val);
		financialAccount.AW_TotalInvestmentAmount__c = getDecimalValue(dtoContract.Current.Total_Inv_Amt);
		financialAccount.FinServ__Premium__c = getDecimalValue(dtoContract.Current.Recur_Inv_Amt);

		processIllustratedSection(financialAccount, dtoContract);

		financialAccount.AW_ProductCategory__c = productCategory;
		financialAccount.AW_ProductSubCategory__c = productSubCategory;
		financialAccount.OwnerId = foundAccount.OwnerId;

		Date valueAsAt = getDateValue(dtoContract.Current.Val_At_Dt);
		financialAccount.AW_ValueAsAt__c = valueAsAt != null ? valueAsAt : System.today();

		financialAccount.AW_Last_Updated_Date_from_Source__c = Datetime.now();

		financialAccount.AW_MasterAccount__c = isMasterAccount ? foundAccount.Id : foundAccount.AW_ParentAccount__c;

		financialAccount.CMN_RetirementAge__c = getStringValue(dtoContract.Current.Retirement_Age);
		financialAccount.CMN_TotalPackageDeathValue__c = getCurrentValue(dtoContract);
		financialAccount.CMN_PaymentMethod__c = getStringValue(dtoContract.Current.Payment_Method_Tx);
		financialAccount.CMN_PremiumPattern__c = getStringValue(dtoContract.Current.Prem_Pattern_Tx);
		financialAccount.CMN_DebitDay__c = getStringValue(dtoContract.Current.Debit_Day);
		financialAccount.CMN_AutomaticContributionIncreaseAmt__c = dtoContract.Current.Aci_Amt < ACI_AMOUNT ?
				getStringValue(dtoContract.Current.Aci_Amt) : STRING_NULL_IDENTIFIER;
		financialAccount.AW_AnnualContributionIncreaseACI__c = String.isBlank(financialAccount.CMN_AutomaticContributionIncreaseAmt__c) ?
				getStringValue(dtoContract.Current.Aci_Tx) : STRING_NULL_IDENTIFIER;
		financialAccount.CMN_AdhocPremiumAmount__c = getDecimalValue(dtoContract.Current.Adhoc_Contrib_Amt);
		financialAccount.CMN_AdvanceType__c = getStringValue(dtoContract.Current.Adv_Type_Tx);
		financialAccount.CMN_AidsInclusionIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(dtoContract.Current.Aids_Incl_Ind) ? true : false;
		financialAccount.CMN_AnnualIncomePercentage__c = getDecimalValue(dtoContract.Current.Escal_Perc);
		financialAccount.CMN_AssociatedContracts__c = setAssociatedContracts(dtoContract.AssociatedContracts);
		financialAccount.CMN_AutomaticBenefitIncreaseAmount__c = getStringValue(dtoContract.Current.Abi_Amt);
		financialAccount.CMN_CapitalContentAmount__c = getDecimalValue(dtoContract.Current.Capital_Content_Amt);
		financialAccount.CMN_CommutedValueOfAnnuity__c = getDecimalValue(dtoContract.Current.Commuted_Val);
		financialAccount.CMN_ConditionalPartRedemptionTaken__c = getDecimalValue(dtoContract.Current.Cpr_Advance_Amt);
		financialAccount.CMN_CoverType__c = getStringValue(dtoContract.Inception.Cover_Type_Tx);
		financialAccount.CMN_CreditACIPercentage__c = getDecimalValue(dtoContract.Current.Credit_Aci_Perc);
		financialAccount.CMN_CurrencyIndicator__c = getStringValue(dtoContract.Current.Curr_Ind);
		financialAccount.CMN_DeathValue__c = getDecimalValue(dtoContract.Current.Gross_Death_Val);
		financialAccount.CMN_EarlyRetirementValue__c = getDecimalValue(dtoContract.Inception.ERB_Amt);
		financialAccount.CMN_FundName__c = getStringValue(dtoContract.Current.Fund_Name);
		financialAccount.CMN_GrossIncomePayable__c = getDecimalValue(dtoContract.Current.Deduction_Amt);
		financialAccount.CMN_GrowthSharingPortion__c = getDecimalValue(dtoContract.Current.Growth_Sharing_Perc);
		financialAccount.CMN_GrowthSharingTargetReturn__c = getDecimalValue(dtoContract.Current.Target_Ret_Perc);
		financialAccount.CMN_GuaranteeEndDate__c = getDateValue(dtoContract.Current.Guarantee_End_Dt);
		financialAccount.CMN_GuaranteeExpiryDate__c = getDateValue(dtoContract.Current.Guarantee_Expiry_Dt);
		financialAccount.CMN_GuaranteeStartDate__c = getDateValue(dtoContract.Current.Guarantee_Start_Dt);
		financialAccount.CMN_GuaranteeValue__c = getDecimalValue(dtoContract.Current.OIP_Guarantee_Amt);
		financialAccount.CMN_GuaranteedInvestmentAmount__c = getDecimalValue(dtoContract.Current.Guarantee_Inv_Amt);
		financialAccount.CMN_HighWaterMarkGuarantee__c = getDecimalValue(dtoContract.Current.Ret_Guarantee_Perc);
		financialAccount.CMN_IncomeDrawdown__c = getStringValue(dtoContract.Current.Income_Drawdown_Tx);
		financialAccount.CMN_LastWithdrawalPaidDate__c = getDateValue(dtoContract.Current.Last_Withdrawal_Paid_Dt);
		financialAccount.CMN_LoanInterestRate__c = getDecimalValue(dtoContract.Current.Loan_Interest_Rate);
		financialAccount.CMN_NonGuaranteedInvestmentAmount__c = getDecimalValue(dtoContract.Current.Non_Guarantee_Inv_Amt);
		financialAccount.CMN_OIPTotalInvestedAmountToDate__c = getDecimalValue(dtoContract.Current.OIP_Total_Inv_Amt);
		financialAccount.CMN_OngoingAdviceFeeAnnualGrowth__c = getDecimalValue(dtoContract.Inception.FA_Yr_Oac_Growth_Perc);
		financialAccount.CMN_OngoingAdviceFeeAnnual__c = getDecimalValue(dtoContract.Inception.FA_Yr_Oac_Perc);
		financialAccount.CMN_OngoingAdviceFeeOIP__c = getDecimalValue(dtoContract.Current.OIP_Oac_Perc);
		financialAccount.CMN_OptionDate__c = getDateValue(dtoContract.Current.Option_Dt);
		financialAccount.CMN_OriginalOptionDate__c = getDateValue(dtoContract.Inception.Orig_Option_Dt);
		financialAccount.CMN_OriginalRetirementDate__c = getDateValue(dtoContract.Inception.Orig_Retirement_Dt);
		financialAccount.CMN_PaidUpDeathValue__c = getDecimalValue(dtoContract.Current.Paid_Up_Death_Val);
		financialAccount.CMN_PaidUpPremiumAmount__c = getDecimalValue(dtoContract.Current.Paid_Up_Contrib_Amt);
		financialAccount.CMN_PaidtoDate__c = getDateValue(dtoContract.Current.Paid_To_Dt);
		financialAccount.CMN_ParticipationDate__c = getDateValue(dtoContract.Current.Participation_Dt);
		financialAccount.CMN_PaymentHoldStatusIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(dtoContract.Current.Hld_Status_Ind) ? true : false;
		financialAccount.CMN_PaymentHoldStatus__c = getStringValue(dtoContract.Current.Hld_Status_Cd);
		financialAccount.CMN_PaymentMode__c = getStringValue(dtoContract.Current.Income_Adv_Arrears_Tx);
		financialAccount.CMN_PolicyholderFundValue__c = getDecimalValue(dtoContract.Current.Member_Fund_Val);
		financialAccount.CMN_RetirementAnnuityEmigrationValue__c = getDecimalValue(dtoContract.Current.Ra_Emigration_Val);
		financialAccount.CMN_RetirementDate__c = getDateValue(dtoContract.Current.Retirement_Dt);
		financialAccount.CMN_Section14TransferValue__c = getDecimalValue(dtoContract.Current.Section14_Transfer_Val);
		financialAccount.CMN_SmokerRateIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(dtoContract.Current.Smoker_Rate_Ind) ? true : false;
		financialAccount.CMN_SwitchedValue__c = getDecimalValue(dtoContract.Current.Switch_Val);
		financialAccount.CMN_SystematicRedemptionPaymentIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(dtoContract.Inception.Srp_Ind) ? true : false;
		financialAccount.CMN_TopUpValue__c = getDecimalValue(dtoContract.Current.Guarantee_Top_Up_Amt);
		financialAccount.CMN_TotalWithdrawalAmount__c = getDecimalValue(dtoContract.Current.Total_Withdrawal_Amt);
		financialAccount.CMN_TotalWithdrawalDate__c = getDateValue(dtoContract.Current.Total_Withdrawal_Dt);
		financialAccount.CMN_TransferValue__c = getDecimalValue(dtoContract.Current.Trans_Val);

		if(dtoContract.Roles != null)
		{
			for(DTO_Role roles : dtoContract.Roles)
			{
				setCessionaryFields(roles.Cessionary, financialAccount);
				setAccountFields(roles.Accounts, financialAccount);
				setAccountSOFields(roles.AccountsSO, financialAccount);
			}
		}

		registerChange(financialAccount);
		registerRelationship(financialAccount, FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c, foundAccount);

		if(String.isNotBlank(financialAccount.Id))
		{
			existingFinancialAccountIds.add(financialAccount.Id);
		}
	}

	/**
	 * @description Will determine the contract's current value
	 *
	 * @param dtoContract DTO containing contract information
	 *
	 * @return The value determined
	 */
	private static Decimal getCurrentValue(DTO_Contract dtoContract)
	{
		return Math.max
				(
						getDecimalValue(dtoContract.Current.Gross_Death_Val, ZERO_DECIMAL),
						Math.max
								(
										getDecimalValue(dtoContract.Current.Inv_Val, ZERO_DECIMAL),
										getDecimalValue(dtoContract.Current.Total_Package_Death_Val, ZERO_DECIMAL)
								)
				);
	}

	/**
	 * @description update the illustrated values on Financial Account
	 *
	 * @param financialAccount The Financial Account record under which the Financial Holding get created
	 * @param dtoContract DTO contract received from the source system
	 */
	private static void processIllustratedSection(FinServ__FinancialAccount__c financialAccount, DTO_Contract dtoContract)
	{
		if(dtoContract.Illustrated != null)
		{
			financialAccount.AW_IllustratedValueDate__c = getDateValue(dtoContract.Illustrated.Illustr_Dt);
			financialAccount.AW_IllustrativeMaturityValue__c = getDecimalValue(dtoContract.Illustrated.Illustr_Maturity_Val);
			financialAccount.CMN_EIFGuidelineAllocationIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(dtoContract.Illustrated.Guide_Alloc_Ind) ? true : false;
			financialAccount.CMN_EIFTotalInvestedAmountToDate__c = getDecimalValue(dtoContract.Illustrated.EIF_Total_Inv_Amt);
			financialAccount.CMN_ExactIncomeCapitalValue__c = getDecimalValue(dtoContract.Illustrated.EIF_Capital_Amt);
			financialAccount.CMN_ExactIncomeFundFrequency__c = getStringValue(dtoContract.Illustrated.EIF_Freq_Cd);
			financialAccount.CMN_ExactIncomeFundGuaranteedValue__c = getDecimalValue(dtoContract.Illustrated.EIF_Guarantee_Amt);
			financialAccount.CMN_FutureInvestmentFundName__c = getStringValue(dtoContract.Illustrated.Future_Inv_Fund_Name);
			financialAccount.CMN_FutureInvestmentFundPercentage__c = getDecimalValue(dtoContract.Illustrated.Future_Inv_Fund_Perc);
			financialAccount.CMN_IllustrativeRetirementAmount__c = getDecimalValue(dtoContract.Illustrated.Illustr_Retirement_Amt);
			financialAccount.CMN_IllustrativeSurrenderValueDate__c = getDateValue(dtoContract.Illustrated.Illustr_Surrender_Val_Dt);
			financialAccount.CMN_IllustrativeSurrenderValue__c = getDecimalValue(dtoContract.Illustrated.Illustr_Surrender_Val);
			financialAccount.CMN_IllustrativeValueAge__c = getDecimalValue(dtoContract.Illustrated.Illustr_Val_Age);
			financialAccount.CMN_IllustrativeValueDate__c = getDateValue(dtoContract.Illustrated.Illustr_Val_Dt);
			financialAccount.CMN_IllustrativeValueRate__c = getDecimalValue(dtoContract.Illustrated.Illustr_Val_Rate);
			financialAccount.CMN_IllustrativeValue__c = getDecimalValue(dtoContract.Illustrated.Illustr_Val);
			financialAccount.CMN_OngoingAdviceFeeEIF__c = getDecimalValue(dtoContract.Illustrated.EIF_Oac_Perc);
			financialAccount.CMN_RecurringEIFFutureInvestmentPercent__c = getDecimalValue(dtoContract.Illustrated.Recur_EIF_Future_Perc);
			financialAccount.CMN_TotalFuturePercentage__c = getDecimalValue(dtoContract.Illustrated.Total_Future_Perc);
		}
	}

	/**
	 * @description fetch Financial Holding under the Financial Account Object
	 *
	 * @param financialAccount The Financial Account record under which the Financial Holding get created
	 * @param dtoBenefits list of Benefits of the particular DTO contract
	 */
	@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
	private void upsertFinancialHolding(FinServ__FinancialAccount__c financialAccount, List<DTO_Benefit> dtoBenefits)
	{
		if(dtoBenefits != null && !dtoBenefits.isEmpty())
		{
			for(DTO_Benefit benefit : dtoBenefits)
			{
				if(String.isNotBlank(benefit.Type_Tx) || String.isNotBlank(benefit.Type_Cd))
				{
					processFinancialBenefitsAndPortfolios(foundAccount, benefit, null, true, financialAccount);
				}
				if(benefit.Portfolios != null && !benefit.Portfolios.isEmpty())
				{
					for(DTO_Portfolio financialHolds : benefit.Portfolios)
					{
						if(String.isNotBlank(financialHolds.Type_Tx) || String.isNotBlank(financialHolds.Type_Cd))
						{
							processFinancialBenefitsAndPortfolios(foundAccount, benefit, financialHolds, false, financialAccount);
						}
					}
				}
			}
		}
	}

	/**
	 * @description common method to process both benefits and portfolios for the Investment records
	 *
	 * @param foundAccount The Account record associated with Financial Holding record
	 * @param benefit list of Benefits of the particular DTO contract
	 * @param portfolio list of Portfolios of the particular DTO contract
	 * @param isBenefit boolean to identify benefit or portfolio
	 * @param financialAccount The Financial Account record under which the Financial Holding get created
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	private void processFinancialBenefitsAndPortfolios(Account foundAccount, DTO_Benefit benefit, DTO_Portfolio portfolio, Boolean isBenefit,
			FinServ__FinancialAccount__c financialAccount)
	{
		String type = isBenefit ? benefit.Type_Tx : portfolio.Type_Tx;

		FinServ__FinancialHolding__c financialHolding = new FinServ__FinancialHolding__c();
		financialHolding.Name = type;
		financialHolding.RecordTypeId = AW_DAL_FinancialHolding.RT_LIBERTY_FINANCIAL_HOLDING_ID;

		if(isBenefit)
		{
			financialHolding.AW_Product_Code__c = getStringValue(benefit.Type_Cd);
			financialHolding.CMN_BenefitAmount__c = getDecimalValue(benefit.Benefit_Amt);
			financialHolding.CMN_BenefitEndDate__c = getDateValue(benefit.End_Dt);
			financialHolding.CMN_BenefitStartDate__c = getDateValue(benefit.Start_Dt);
			financialHolding.CMN_WaitingPeriod__c = String.isNotBlank(benefit.Waiting_Period) ? getStringValue(benefit.Waiting_Period) :
					getStringValue(benefit.Waiting_Period_Tx);
			financialHolding.CMN_ExclusionIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(benefit.Excl_Ind) ? true : false;
			financialHolding.CMN_LoadingIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(benefit.Load_Ind) ? true : false;
			financialHolding.CMN_ConversionOptionIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(benefit.Conver_Option_Ind) ? true : false;
		}
		else
		{
			financialHolding.AW_Product_Code__c = getStringValue(portfolio.Type_Cd);
			financialHolding.FinServ__MarketValue__c = getDecimalValue(portfolio.Rand_Val);
			financialHolding.FinServ__PurchasePrice__c = getDecimalValue(portfolio.Buy_Price);
			financialHolding.FinServ__Shares__c = getDecimalValue(portfolio.Unit_Amt);
			// bug #171520 - missed the current value field mapping.
			financialHolding.AW_CurrentValue__c = financialHolding.FinServ__MarketValue__c;
			financialHolding.AW_Last_Updated_Date_from_Source__c = Datetime.now();
			financialHolding.AW_SellingPrice__c = getDecimalValue(portfolio.Sell_Price);
			financialHolding.AW_SharePercentage__c = getDecimalValue(portfolio.Share_Perc);
			financialHolding.AW_ValueAsAt__c = Datetime.now();
		}

		registerNew(financialHolding, FinServ__FinancialHolding__c.FinServ__FinancialAccount__c, financialAccount);

		registerRelationship(financialHolding, FinServ__FinancialHolding__c.FinServ__PrimaryOwner__c, foundAccount);
	}

	/**
	 * @description fetch Financial Account Roles under the Financial Account Object
	 *
	 * @param financialAccount The Financial Account record under which the Financial Account Roles get created
	 * @param dtoContract The DTO that represents the JSON sent in a request
	 * @param accountIdWithConsultantCode account identification number with consultant code
	 */
	private void upsertFinancialAccountRoles(FinServ__FinancialAccount__c financialAccount, DTO_Contract dtoContract,
			String accountIdWithConsultantCode)
	{
		//Setting all the existing roles to inactive
		for(FinServ__FinancialAccountRole__c existingRole : financialAccount.FinServ__FinancialAccountRoles__r)
		{
			if(!SC_DAL_FinancialAccountRole.PRIMARY_OWNER_ROLE.equals(existingRole.FinServ__Role__c))
			{
				existingRole.FinServ__Active__c = false;
				registerChange(existingRole);
			}
		}

		for(DTO_Role dtoRole : dtoContract.Roles)
		{
			DTO_RoleDetails dtoRoleDetails = getRoleDetails(dtoRole);

			if(dtoRoleDetails.hasPersonEntity || dtoRoleDetails.hasOrganisationEntity || dtoRoleDetails.isAdviserRole)
			{
				FinServ__FinancialAccountRole__c newRole = new FinServ__FinancialAccountRole__c();

				newRole.CMN_PercentageSplit__c = getDecimalValue(dtoRole.Split_Percentage);
				newRole.CMN_RelationshipToLifeAssured__c = getStringValue(dtoRole.Relationship_Tx);
				newRole.CMN_RelationshipToOwner__c = getStringValue(dtoRole.Relationship_To_Owner_Tx);
				newRole.FinServ__Active__c = true;
				newRole.FinServ__Role__c = dtoRole.Type_Tx;
				newRole.RecordTypeId = SC_DAL_FinancialAccountRole.RT_LIBERTY_FINANCIAL_ACCOUNT_ROLE_ID;

				if(dtoRoleDetails.hasPersonEntity)
				{
					populateRoleFromPersonEntity(newRole, dtoRole.Entity_Person);
				}
				else if(dtoRoleDetails.hasOrganisationEntity)
				{
					populateRoleFromOrganisationEntity(newRole, dtoRole);
				}

				if(dtoRoleDetails.isAdviserRole)
				{
					populateRoleWithAdviserDetails(newRole, consultantsByConsultantCodeMap.get(consultantRoleCode));
				}

				registerNew(newRole, FinServ__FinancialAccountRole__c.FinServ__FinancialAccount__c, financialAccount);

				if(newRole.FinServ__RelatedContact__c == null)
				{
					registerRelationship(newRole, FinServ__FinancialAccountRole__c.FinServ__RelatedAccount__c, foundAccount);
				}

				if(dtoRole.Benefits != null)
				{
					upsertFinancialHolding(financialAccount, dtoRole.Benefits);
				}

				setAccountStatus(accountIdWithConsultantCode, AW_DAL_Account.PICK_SUCCESSFUL);
			}
			else
			{
				processRoleError(accountIdWithConsultantCode, dtoRole);
			}
		}
	}

	/**
	 * @description Will read the current role and provide details about the role
	 *
	 * @param dtoRole Original Role
	 *
	 * @return newly initialised role details
	 */
	private DTO_RoleDetails getRoleDetails(DTO_Role dtoRole)
	{
		DTO_RoleDetails dtoRoleDetails = new DTO_RoleDetails();

		dtoRoleDetails.hasPersonEntity = dtoRole.Entity_Person != null && (String.isNotBlank(dtoRole.Entity_Person.First_Nm) || String.isNotBlank(dtoRole.Entity_Person.Last_Nm));
		dtoRoleDetails.hasOrganisationEntity = !dtoRoleDetails.hasPersonEntity && dtoRole.Entity_Organization != null;
		dtoRoleDetails.isAdviserRole =
				String.isNotBlank(consultantRoleCode) &&
				CONSULTANT_ROLE.equals(dtoRole.Type_Tx) &&
				consultantsByConsultantCodeMap.containsKey(consultantRoleCode);

		return dtoRoleDetails;
	}

	/**
	 * @description Will ensure that error in processing roles is logged
	 *
	 * @param accountIdWithConsultantCode Key of ID and consultant code
	 * @param dtoRole The role that couldn't be processed
	 */
	private void processRoleError(String accountIdWithConsultantCode, DTO_Role dtoRole)
	{
		setAccountStatus(accountIdWithConsultantCode, AW_DAL_Account.PICK_FAILED);
		callResult.errors.add(String.format(SC_UTIL_Contracts.ERROR_ROLE_NOT_PROCESSED, new List<String> {dtoRole.Type_Tx}));
	}

	/**
	 * @description Will populate the role from Person Information
	 *
	 * @param newRole The Role to be inserted
	 * @param dtoPerson The details of the role
	 */
	private static void populateRoleFromPersonEntity(FinServ__FinancialAccountRole__c newRole, DTO_Person dtoPerson)
	{
		newRole.AW_RoleDOB__c = getDateValue(dtoPerson.Birth_Dt);
		newRole.AW_RoleFirstName__c = getStringValue(dtoPerson.First_Nm);
		newRole.AW_RoleIdentificationNumber__c = getStringValue(dtoPerson.Identity_No);
		newRole.AW_RoleInitials__c = getStringValue(dtoPerson.Initials);
		newRole.AW_RoleLastName__c = getStringValue(dtoPerson.Last_Nm);
		newRole.AW_RoleTitle__c = getStringValue(dtoPerson.Title_Tx);
		newRole.CMN_FifthName__c = getStringValue(dtoPerson.Fifth_Nm);
		newRole.CMN_FourthName__c = getStringValue(dtoPerson.Fourth_Nm);
		newRole.CMN_Gender__c = getStringValue(dtoPerson.Gender_Cd);
		newRole.CMN_MaritalStatus__c = getStringValue(dtoPerson.Marital_Status_Cd);
		newRole.CMN_OccupationRiskCategory__c = getStringValue(dtoPerson.Occupation_Risk_Cat_Tx);
		newRole.CMN_Occupation__c = getStringValue(dtoPerson.Occupation_Tx);
		newRole.CMN_PDBID__c = dtoPerson.Id;
		newRole.CMN_Race__c = getStringValue(dtoPerson.Race_Tx);
		newRole.CMN_SecondName__c = getStringValue(dtoPerson.Second_Nm);
		newRole.CMN_ThirdName__c = getStringValue(dtoPerson.Third_Nm);
		newRole.CMN_WeddingAnniversary__c = getDateValue(dtoPerson.Marriage_Date);

		if(dtoPerson.EmailAddresses != null && !dtoPerson.EmailAddresses.isEmpty())
		{
			newRole.CMN_Email__c = getStringValue(dtoPerson.EmailAddresses.iterator().next().Email_Addr);
		}

		if(dtoPerson.Registrations != null && !dtoPerson.Registrations.isEmpty())
		{
			for(DTO_Registration registrations : dtoPerson.Registrations)
			{
				newRole.CMN_TaxNumber__c = registrations.Registration_Type_Cd == TAX_REGISTRATION_TYPE_CODE ? getStringValue(registrations.Registration_Number) :
						STRING_NULL_IDENTIFIER;

				//Adding this specifically for funeral products
				if(registrations.Registration_Type_Cd == ID_REGISTRATION_TYPE_CODE)
				{
					newRole.AW_RoleIdentificationNumber__c = getStringValue(registrations.Registration_Number);
				}

				if(registrations.Registration_Type_Cd == PASSPORT_REGISTRATION_TYPE_CODE)
				{
					newRole.CMN_CountryOfCitizenship__c = getStringValue(registrations.Citizenship_Country_Tx);
					newRole.CMN_CountryOfIssue__c = getStringValue(registrations.Country_Of_Issue_Tx);
					newRole.CMN_ExpiryDate__c = getDateValue(registrations.Expiry_Date);
					newRole.CMN_IssueDate__c = getDateValue(registrations.Issue_Date);
					newRole.CMN_PassportNumber__c = getStringValue(registrations.Registration_Number);
				}
			}
		}

		if(dtoPerson.Telephones != null && !dtoPerson.Telephones.isEmpty())
		{
			setTelephoneFields(dtoPerson.Telephones, newRole);
		}
	}

	/**
	 * @description Will populate the role from Organisation Information
	 *
	 * @param newRole The Role to be inserted
	 * @param dtoRole The details of the role
	 */
	private static void populateRoleFromOrganisationEntity(FinServ__FinancialAccountRole__c newRole, DTO_Role dtoRole)
	{
		newRole.CMN_CountryOfIncorporation__c = getStringValue(dtoRole.Entity_Organization.Incorporation_Country_Tx);
		newRole.CMN_DateOfIncorporation__c = getDateValue(dtoRole.Entity_Organization.Incorporation_Dt);
		newRole.CMN_OrganisationType__c = getStringValue(dtoRole.Entity_Organization.Org_Type_Cd);
		newRole.CMN_OrganizationName__c = getStringValue(dtoRole.Entity_Organization.Name);
		newRole.CMN_PDBID__c = dtoRole.Entity_Organization.Id;
		newRole.CMN_RegistrationNumber__c = getStringValue(dtoRole.Entity_Organization.Registration_No);
		newRole.CMN_Suffix__c = getStringValue(dtoRole.Entity_Organization.Suffix);

		if(dtoRole.Entity_Organization.EmailAddresses != null && !dtoRole.Entity_Organization.EmailAddresses.isEmpty())
		{
			newRole.CMN_Email__c = getStringValue(dtoRole.Entity_Organization.EmailAddresses.iterator().next().Email_Addr);
		}

		if(dtoRole.Entity_Organization.Telephones != null && !dtoRole.Entity_Organization.Telephones.isEmpty())
		{
			setTelephoneFields(dtoRole.Entity_Organization.Telephones, newRole);
		}
	}

	/**
	 * @description fetch Insurance Policies under the client account
	 *
	 * @param dtoContract The DTO that represents the JSON sent in a request
	 * @param accountIdWithConsultantCode Account Identification number with Consultant Code
	 */
	private void upsertInsurancePolicies(DTO_Contract dtoContract, String accountIdWithConsultantCode)
	{
		SObject foundPolicy = insurancePoliciesByNameMap.get(dtoContract.Id);

		InsurancePolicy upsertPolicy = foundPolicy == null ? new InsurancePolicy() : (InsurancePolicy)CMN_DAL_SObjectDomain.newObjectFromExisting(foundPolicy, null);

		upsertPolicy.RecordTypeId = SC_DAL_InsurancePolicy.RT_INSURANCE_POLICY_ID;
		populateInsurancePolicyData(upsertPolicy, dtoContract);
		upsertInsurancePolicyParticipants(upsertPolicy, dtoContract, accountIdWithConsultantCode);
	}

	/**
	 * @description Map Insurance Policy data with the response data
	 *
	 * @param insurancePolicyRecord The Insurance Policy record under which the Insurance policy get created
	 * @param dtoContract The DTO that represents the JSON sent in a request
	 */
	private void populateInsurancePolicyData(InsurancePolicy insurancePolicyRecord, DTO_Contract dtoContract)
	{
		insurancePolicyRecord.AW_CommencementDate__c = getDateValue(dtoContract.Inception.Commencement_Dt);
		insurancePolicyRecord.AW_Frequency__c = getStringValue(dtoContract.Current.Prem_Freq_Tx);
		insurancePolicyRecord.AW_MasterAccount__c = isMasterAccount ? foundAccount.Id : foundAccount.AW_ParentAccount__c;
		insurancePolicyRecord.AW_PaymentMethodCode__c = getStringValue(dtoContract.Current.Payment_Method_Cd);
		insurancePolicyRecord.AW_PaymentMethod__c = getStringValue(dtoContract.Current.Payment_Method_Tx);
		insurancePolicyRecord.AW_PolicyCategory__c = productCategory;
		insurancePolicyRecord.AW_PolicySubCategory__c = productSubCategory;
		insurancePolicyRecord.AW_PremiumFrequencyCode__c = getStringValue(dtoContract.Current.Prem_Freq_Cd);
		insurancePolicyRecord.AW_PremiumPatternCode__c = getStringValue(dtoContract.Current.Prem_Pattern_Cd);
		insurancePolicyRecord.AW_PremiumPattern__c = getStringValue(dtoContract.Current.Prem_Pattern_Tx);
		insurancePolicyRecord.AW_ProductTypeCode__c = CMN_UTIL_String.isBlank(dtoContract.Type_Cd) ? dtoContract.Prod_Class_Cd : dtoContract.Type_Cd;
		insurancePolicyRecord.AW_StatusReasonCode__c = getStringValue(dtoContract.Current.Status_Rsn_Cd);
		insurancePolicyRecord.AW_StatusReason__c = getStringValue(dtoContract.Current.Status_Rsn_Tx);
		insurancePolicyRecord.CMN_IssueDate__c = getDateValue(dtoContract.Inception.Issue_Dt);
		insurancePolicyRecord.CMN_OriginalCommencementDate__c = getDateValue(dtoContract.Inception.Orig_Commencement_Dt);
		insurancePolicyRecord.CMN_PolicySourceSystem__c = dtoContract.Source;
		insurancePolicyRecord.Name = dtoContract.Id;
		insurancePolicyRecord.OwnerId = foundAccount.OwnerId;
		insurancePolicyRecord.PolicyName = CMN_UTIL_String.isBlank(dtoContract.Type_Tx) ? dtoContract.Prod_Class_Tx : dtoContract.Type_Tx;
		insurancePolicyRecord.PremiumAmount = getDecimalValue(dtoContract.Current.Actual_Prem_Amt);
		insurancePolicyRecord.PremiumFrequency = getStringValue(dtoContract.Current.Prem_Freq_Tx);
		insurancePolicyRecord.Status = getStringValue(dtoContract.Contract_Status_Ind, getStringValue(dtoContract.Current.Status_Tx));

		Date valueAsAt = getDateValue(dtoContract.Current.Val_At_Dt);
		insurancePolicyRecord.AW_ValueAsAt__c = valueAsAt != null ? valueAsAt : System.today();

		insurancePolicyRecord.AW_AnnualBenefitsIncreaseABI__c = getStringValue(dtoContract.Current.Abi_Tx);
		insurancePolicyRecord.AW_AnnualContributionIncreaseACI__c = getStringValue(dtoContract.Current.Aci_Tx);
		insurancePolicyRecord.AW_CurrentValue__c = getCurrentValue(dtoContract);
		insurancePolicyRecord.AW_InvestmentValue__c = getDecimalValue(dtoContract.Current.Inv_Val);
		insurancePolicyRecord.AW_Last_Updated_Date_from_Source__c = Datetime.now();
		insurancePolicyRecord.AW_MaturityDate__c = getDateValue(dtoContract.Current.Maturity_Dt);
		insurancePolicyRecord.AW_PaidUpValue__c = getDecimalValue(dtoContract.Current.Paid_Up_Death_Val);
		insurancePolicyRecord.CMN_AdvanceAvailable__c = getDecimalValue(dtoContract.Current.Adv_Avail_Amt);
		insurancePolicyRecord.CMN_AidsInclusionIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(dtoContract.Current.Aids_Incl_Ind) ? true : false;
		insurancePolicyRecord.CMN_CashBackDate__c = getDateValue(dtoContract.Current.Cash_Back_Date);
		insurancePolicyRecord.CMN_CashBackEarned__c = getDecimalValue(dtoContract.Current.Cash_Back_Earned);
		insurancePolicyRecord.CMN_CashBackIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(dtoContract.Current.Cash_Back_Ind) ? true : false;
		insurancePolicyRecord.CMN_ConditionalPartRedemptionTaken__c = getDecimalValue(dtoContract.Current.Cpr_Advance_Amt);
		insurancePolicyRecord.CMN_CoverType__c = getStringValue(dtoContract.Inception.Cover_Type_Tx);
		insurancePolicyRecord.CMN_DeathValue__c = getDecimalValue(dtoContract.Current.Gross_Death_Val);
		insurancePolicyRecord.CMN_DebitDay__c = getStringValue(dtoContract.Current.Debit_Day);
		insurancePolicyRecord.CMN_EarlyRetirementValue__c = getDecimalValue(dtoContract.Inception.ERB_Amt);
		insurancePolicyRecord.CMN_ExpiryDate__c = getDateValue(dtoContract.Current.Expiry_Dt);
		insurancePolicyRecord.CMN_FundValue__c = getDecimalValue(dtoContract.Current.Fund_Val);
		insurancePolicyRecord.CMN_GuaranteeReviewDate__c = getDateValue(dtoContract.Current.Guarantee_Review_Notified_Dt);
		insurancePolicyRecord.CMN_GuaranteeValue__c = getDecimalValue(dtoContract.Inception.Guarantee_Val);
		insurancePolicyRecord.CMN_NextBillingDate__c = getDateValue(dtoContract.Current.Next_Billing_Dt);
		insurancePolicyRecord.CMN_OptionDate__c = getDateValue(dtoContract.Current.Option_Dt);
		insurancePolicyRecord.CMN_PackageNumber__c = getStringValue(dtoContract.Inception.Package_No);
		insurancePolicyRecord.CMN_PaidToDate__c = getDateValue(dtoContract.Current.Paid_To_Dt);
		insurancePolicyRecord.CMN_PaidUpBenefitIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(dtoContract.Current.Paid_Up_Ben_Ind) ? true : false;
		insurancePolicyRecord.CMN_PaidUpDeathValue__c = getDecimalValue(dtoContract.Current.Paid_Up_Death_Val);
		insurancePolicyRecord.CMN_PaidUpPremiumAmount__c = getDecimalValue(dtoContract.Current.Paid_Up_Contrib_Amt);
		insurancePolicyRecord.CMN_PremiumReceivedIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(dtoContract.Current.Prem_Recieved_Ind) ? true : false;
		insurancePolicyRecord.CMN_ProductName__c = getStringValue(dtoContract.Prod_Name_Type);
		insurancePolicyRecord.CMN_PrototypeCode__c = prototypeCode;
		insurancePolicyRecord.CMN_QualifyingAddlibIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(dtoContract.Current.Qual_Addlib_Ind) ? true : false;
		insurancePolicyRecord.CMN_RefundAvailableAmount__c = getDecimalValue(dtoContract.Current.Refund_Available_Amt);
		insurancePolicyRecord.CMN_RepayableAmount__c = getDecimalValue(dtoContract.Current.Repayable_Amt);
		insurancePolicyRecord.CMN_RestrictionEndDate__c = getDateValue(dtoContract.Current.Restriction_End_Dt);
		insurancePolicyRecord.CMN_SwitchedValue__c = getDecimalValue(dtoContract.Current.Switch_Val);
		insurancePolicyRecord.CMN_SystematicRedemptionPaymentIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(dtoContract.Inception.Srp_Ind) ? true : false;
		insurancePolicyRecord.CMN_TotalInvestmentAmount__c = getDecimalValue(dtoContract.Current.Total_Inv_Amt);
		insurancePolicyRecord.CMN_TotalPackageDeathValue__c = getDecimalValue(dtoContract.Current.Total_Package_Death_Val);
		insurancePolicyRecord.CMN_TotalRepayableAmount__c = getDecimalValue(dtoContract.Current.Total_Repayable_Amt);
		insurancePolicyRecord.CashSurrenderValue = getDecimalValue(dtoContract.Current.Surrender_Val);

		if(dtoContract.Illustrated != null)
		{
			insurancePolicyRecord.CMN_IllustrativeReturnPercentage__c = getDecimalValue(dtoContract.Illustrated.Illustr_Return_Perc);
			insurancePolicyRecord.CMN_IllustrativeValueAge__c = getDecimalValue(dtoContract.Illustrated.Illustr_Val_Age);
			insurancePolicyRecord.CMN_IllustrativeValueDate__c = getDateValue(dtoContract.Illustrated.Illustr_Val_Dt);
			insurancePolicyRecord.CMN_IllustrativeValueRate__c = getDecimalValue(dtoContract.Illustrated.Illustr_Val_Rate);
			insurancePolicyRecord.CMN_IllustrativeValue__c = getDecimalValue(dtoContract.Illustrated.Illustr_Val);
			insurancePolicyRecord.CMN_TermIllustrativeValue__c = getDecimalValue(dtoContract.Illustrated.Term_Illustr_Val);
		}

		insurancePolicyRecord.CMN_AssociatedContracts__c = setAssociatedContracts(dtoContract.AssociatedContracts);

		if(dtoContract.Roles != null && !dtoContract.Roles.isEmpty())
		{
			for(DTO_Role roles : dtoContract.Roles)
			{
				setCessionaryFields(roles.Cessionary, insurancePolicyRecord);
				setAccountFields(roles.Accounts, insurancePolicyRecord);
				setAccountSOFields(roles.AccountsSO, insurancePolicyRecord);
			}
		}

		registerChange(insurancePolicyRecord);
		registerRelationship(insurancePolicyRecord, InsurancePolicy.NameInsuredId, foundAccount);

		if(String.isNotBlank(insurancePolicyRecord.Id))
		{
			existingPolicyIds.add(insurancePolicyRecord.Id);
		}
	}

	/**
	 * @description fetch Insurance Policy Coverage under the Insurance Policy Object
	 *
	 * @param participant The participant record under which we need to create insurancePolicyCoverage records
	 * @param insurancePolicyRecord The insurancePolicy record under which the Insurance policy Coverage get created
	 * @param dtoBenefits The List of Benefits in the DTO Contract that either can be in the Role or after the role
	 */
	private void upsertInsurancePolicyCoverage(InsurancePolicyParticipant participant, InsurancePolicy insurancePolicyRecord,
			List<DTO_Benefit> dtoBenefits)
	{
		if(dtoBenefits != null && !dtoBenefits.isEmpty())
		{
			for(DTO_Benefit coverage : dtoBenefits)
			{
				if(String.isNotBlank(coverage.Type_Cd) || String.isNotBlank(coverage.Type_Tx))
				{
					if((String.isNotBlank(coverage.Type_Tx) && !coverage.Type_Tx.equalsIgnoreCase(AW_DAL_InsurancePolicyCoverage.FINANCIAL_PROTECTOR)) ||
							Decimal.valueOf(coverage.Benefit_Amt) > 0)
					{
						processPolicyBenefitsAndPortfolios(participant, coverage, null, true, insurancePolicyRecord);
					}
				}

				if(coverage.Portfolios != null && !coverage.Portfolios.isEmpty())
				{
					for(DTO_Portfolio policyCoverage : coverage.Portfolios)
					{
						processPolicyBenefitsAndPortfolios(participant, coverage, policyCoverage, false, insurancePolicyRecord);
					}
				}
			}
		}
	}

	/**
	 * @description common method to process both benefits and portfolios for the Risk products
	 *
	 * @param participant The participant record associated with Insurance Policy coverage record
	 * @param benefit list of Benefits of the particular DTO contract
	 * @param portfolio list of Portfolios of the particular DTO contract
	 * @param isBenefit boolean to identify benefit or portfolio
	 * @param insurancePolicyRecord The Insurance Policy record under which the Insurance Policy coverage get created
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	private void processPolicyBenefitsAndPortfolios(InsurancePolicyParticipant participant, DTO_Benefit benefit, DTO_Portfolio portfolio, Boolean isBenefit,
			InsurancePolicy insurancePolicyRecord)
	{
		String typeCode = benefit.Type_Cd ;
		// Remove leading zeros, if any. Retain this as its removing the leading zeros to identify the coverage from map, if its not numeric find the record based
		// on the actual code sent from API
		String type = CMN_UTIL_String.isNumeric(typeCode) ? String.valueOf(Integer.valueOf(typeCode)) : typeCode;
		String benefitOrPortfolioCode = isBenefit ? type : portfolio.Type_Tx;

		InsurancePolicyCoverage policyCoverage = new InsurancePolicyCoverage();
		policyCoverage.RecordTypeId = AW_DAL_InsurancePolicyCoverage.RT_LIBERTY_INSURANCE_POLICY_COVERAGE_ID;

		if(isBenefit)
		{
			policyCoverage.AW_BenefitAmount__c = getDecimalValue(benefit.Benefit_Amt);
			policyCoverage.AW_EndDate__c = getDateValue(benefit.End_Dt);
			policyCoverage.AW_OriginalBenefitAmount__c = getDecimalValue(benefit.Orig_Benefit_Amt);
			policyCoverage.AW_StartDate__c = getDateValue(benefit.Start_Dt);
			policyCoverage.AW_StatusCode__c = getStringValue(benefit.Status_Cd);
			policyCoverage.AW_StatusReasonCode__c = getStringValue(benefit.Status_Rsn_Cd);
			policyCoverage.AW_Term__c = getDecimalValue(benefit.Term);
			policyCoverage.AW_TypeCode__c = type;
			policyCoverage.AW_Type__c = benefit.Type_Tx;
			policyCoverage.CMN_AutomaticContributionIncreasePerc__c = getDecimalValue(benefit.Aci_Perc);
			policyCoverage.CMN_BenefitClassification__c = getStringValue(benefit.BenefitClassification);
			policyCoverage.CMN_ContributionAmount__c = getDecimalValue(benefit.Contrib_Amt);
			policyCoverage.CMN_ExclusionIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(benefit.Excl_Ind) ? true : false;
			policyCoverage.CMN_IncomeDisabilityClaimPercentage__c = getDecimalValue(benefit.Inc_Dis_Claim_Perc);
			policyCoverage.CMN_LoadContributionAmount__c = getDecimalValue(benefit.Load_Contrib_Amt);
			policyCoverage.CMN_LoadingIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(benefit.Load_Ind) ? true : false;
			policyCoverage.CMN_TerminalIllnessValue__c = getDecimalValue(benefit.Term_Ill_Val);
			policyCoverage.CMN_WaitingPeriod__c = String.isNotBlank(benefit.Waiting_Period) ?
					getStringValue(benefit.Waiting_Period) : getStringValue(benefit.Waiting_Period_Tx);

			AW_BenefitCodeAndCategoryMapping__mdt metadata = (AW_BenefitCodeAndCategoryMapping__mdt)benefitCodeByLabelMap.get(benefitOrPortfolioCode);

			if(metadata != null)
			{
				policyCoverage.AW_CoverCategory__c = metadata.AW_CoverCategory__c;
				policyCoverage.AW_CoverSubCategory__c = metadata.AW_CoverSubCategory__c;
				policyCoverage.CoverageName = metadata.AW_BenefitName__c;
			}
		}
		else
		{
			policyCoverage.CMN_PortfolioName__c = policyCoverage.AW_TypeCode__c = policyCoverage.CoverageName = getStringValue(portfolio.Type_Tx);
		}

		registerNew(policyCoverage, InsurancePolicyCoverage.InsurancePolicyId, insurancePolicyRecord);
		registerRelationship(policyCoverage, InsurancePolicyCoverage.AW_InsurancePolicyParticipant__c, participant);
	}

	/**
	 * @description fetch Insurance Policy Participants under the Insurance Policy Object
	 *
	 * @param insurancePolicyRecord The insurancePolicy record under which the Insurance policy Participant get created
	 * @param dtoContract The DTO that represents the JSON sent in a request
	 * @param accountIdWithConsultantCode Account Identification number with Consultant Code
	 */
	@SuppressWarnings('PMD.NcssMethodCount,PMD.AvoidDeeplyNestedIfStmts')
	private void upsertInsurancePolicyParticipants(InsurancePolicy insurancePolicyRecord, DTO_Contract dtoContract,
			String accountIdWithConsultantCode)
	{
		for(InsurancePolicyParticipant existingParticipant : insurancePolicyRecord.InsurancePolicyParticipants)
		{
			existingParticipant.IsActiveParticipant = false;
			registerChange(existingParticipant);
		}

		deleteInsurancePolicyCoverage(insurancePolicyRecord.Name);

		for(DTO_Role dtoRole : dtoContract.Roles)
		{
			DTO_RoleDetails dtoRoleDetails = getRoleDetails(dtoRole);

			if(dtoRoleDetails.hasPersonEntity || dtoRoleDetails.hasOrganisationEntity || dtoRoleDetails.isAdviserRole)
				{
				InsurancePolicyParticipant newParticipant = new InsurancePolicyParticipant();

				newParticipant.AW_PercentageSplit__c = getDecimalValue(dtoRole.Split_Percentage);
				newParticipant.AW_RelationshipToLifeAssured__c = getStringValue(dtoRole.Relationship_Tx);
				newParticipant.AW_RoleCode__c = getStringValue(dtoRole.Type_Cd);
				newParticipant.CMN_RelationshipToOwner__c = getStringValue(dtoRole.Relationship_To_Owner_Tx);
				newParticipant.CMN_Smoker__c = CHECKBOX_INDICATOR.equalsIgnoreCase(dtoContract.Current.Smoker_Rate_Ind) ? true : false;
				newParticipant.IsActiveParticipant = true;
				newParticipant.RecordTypeId = SC_DAL_InsurancePolicyParticipant.RT_LIBERTY_INSURANCE_POLICY_PARTICIPANT_ID;
				newParticipant.Role = dtoRole.Type_Tx;

				if(dtoRoleDetails.hasPersonEntity)
				{
					populateParticipantFromPersonEntity(newParticipant, dtoRole.Entity_Person);
				}
				else if(dtoRoleDetails.hasOrganisationEntity)
				{
					populateParticipantFromOrganisationEntity(newParticipant, dtoRole);
				}

				if(dtoRoleDetails.isAdviserRole)
				{
					populateParticipantWithAdviserDetails(newParticipant, consultantsByConsultantCodeMap.get(consultantRoleCode));
				}

				if(dtoRole.Benefits != null && !dtoRole.Benefits.isEmpty())
				{
					for(DTO_Benefit benefits : dtoRole.Benefits)
					{
						if(benefits.Type_Cd == LIFE_BENEFIT_CODE || benefits.Type_Tx == LIFE_BENEFIT_TYPE)
						{
							newParticipant.CMN_ImmediateExpenseBenefit__c = CHECKBOX_INDICATOR.equalsIgnoreCase(benefits.Imm_Exp_Benefit_Ind) ? true : false;
							break;
						}
					}
				}

				registerNew(newParticipant, InsurancePolicyParticipant.InsurancePolicyId, insurancePolicyRecord);

				if(newParticipant.RelatedParticipantContactId == null)
				{
					registerRelationship(newParticipant, InsurancePolicyParticipant.RelatedParticipantAccountId, foundAccount);
				}

				if(dtoRole.Benefits != null)
				{
					upsertInsurancePolicyCoverage(newParticipant, insurancePolicyRecord, dtoRole.Benefits);
				}

				if(String.isNotBlank(dtoRole.Type_Cd) && dtoRole.Type_Cd.containsIgnoreCase(OWNER_ROLE) && dtoContract.Benefits != null)
				{
					upsertInsurancePolicyCoverage(newParticipant, insurancePolicyRecord, dtoContract.Benefits);
				}

				setAccountStatus(accountIdWithConsultantCode, AW_DAL_Account.PICK_SUCCESSFUL);
				}
				else
				{
				setAccountStatus(accountIdWithConsultantCode, AW_DAL_Account.PICK_FAILED);
				callResult.errors.add(String.format(SC_UTIL_Contracts.ERROR_ROLE_NOT_PROCESSED, new List<String> {dtoRole.Type_Tx}));
				}

		}
	}

	/**
	 * @description Will populate new Participant using the Person Information Provided
	 *
	 * @param newParticipant The new item to populate
	 * @param dtoPerson The person information
	 */
	private static void populateParticipantFromPersonEntity(InsurancePolicyParticipant newParticipant, DTO_Person dtoPerson)
	{
		newParticipant.AW_DateofBirth__c = getStringValue(dtoPerson.Birth_Dt);
		newParticipant.AW_FirstName__c = getStringValue(dtoPerson.First_Nm);
		newParticipant.AW_Gender__c = getStringValue(dtoPerson.Gender_Cd);
		newParticipant.AW_IdentificationNumber__c = getStringValue(dtoPerson.Identity_No);
		newParticipant.AW_Initials__c = getStringValue(dtoPerson.Initials);
		newParticipant.AW_LastName__c = getStringValue(dtoPerson.Last_Nm);
		newParticipant.AW_MaritalStatus__c = getStringValue(dtoPerson.Marital_Status_Cd);
		newParticipant.AW_Occupation__c = getStringValue(dtoPerson.Occupation_Tx);
		newParticipant.AW_PDBID__c = getStringValue(dtoPerson.Id);
		newParticipant.AW_Salutation__c = getStringValue(dtoPerson.Title_Tx);
		newParticipant.AW_SecondName__c = getStringValue(dtoPerson.Second_Nm);
		newParticipant.CMN_FifthName__c = getStringValue(dtoPerson.Fifth_Nm);
		newParticipant.CMN_FourthName__c = getStringValue(dtoPerson.Fourth_Nm);
		newParticipant.CMN_OccupationRiskCategory__c = getStringValue(dtoPerson.Occupation_Risk_Cat_Tx);
		newParticipant.CMN_PreferredLanguage__c = getStringValue(dtoPerson.Preferred_Language_Cd);
		newParticipant.CMN_Qualification__c = getStringValue(dtoPerson.Qualification_Cd);
		newParticipant.CMN_Race__c = getStringValue(dtoPerson.Race_Tx);
		newParticipant.CMN_SouthAfricanResidentIndicator__c = CHECKBOX_INDICATOR.equalsIgnoreCase(dtoPerson.SA_Resident_Ind) ? true : false;
		newParticipant.CMN_ThirdName__c = getStringValue(dtoPerson.Third_Nm);
		newParticipant.CMN_WeddingAnniversary__c = getDateValue(dtoPerson.Marriage_Date);

		if(dtoPerson.EmailAddresses != null && !dtoPerson.EmailAddresses.isEmpty())
		{
			newParticipant.CMN_Email__c = getStringValue(dtoPerson.EmailAddresses.iterator().next().Email_Addr);
		}

		if(dtoPerson.Registrations != null && !dtoPerson.Registrations.isEmpty())
			{
			for(DTO_Registration registrations : dtoPerson.Registrations)
			{
				//Adding this specifically for funeral products
				if(registrations.Registration_Type_Cd == ID_REGISTRATION_TYPE_CODE)
					{
					newParticipant.AW_IdentificationNumber__c = getStringValue(registrations.Registration_Number);
				}

				if(registrations.Registration_Type_Cd == PASSPORT_REGISTRATION_TYPE_CODE)
				{
					newParticipant.CMN_CountryOfCitizenship__c = getStringValue(registrations.Citizenship_Country_Tx);
					newParticipant.CMN_CountryOfIssue__c = getStringValue(registrations.Country_Of_Issue_Tx);
					newParticipant.CMN_ExpiryDate__c = getDateValue(registrations.Expiry_Date);
					newParticipant.CMN_IssueDate__c = getDateValue(registrations.Issue_Date);
					newParticipant.CMN_PassportNumber__c = getStringValue(registrations.Registration_Number);
					}
				}
			}

		if(dtoPerson.Telephones != null && !dtoPerson.Telephones.isEmpty())
		{
			setTelephoneFields(dtoPerson.Telephones, newParticipant);
		}
	}

	/**
	 * @description Will populate new Participant using the Organisation Provided
	 *
	 * @param newParticipant The new item to populate
	 * @param dtoRole The person information
	 */
	private static void populateParticipantFromOrganisationEntity(InsurancePolicyParticipant newParticipant, DTO_Role dtoRole)
	{
		newParticipant.AW_PDBID__c = getStringValue(dtoRole.Entity_Organization.Id);
		newParticipant.CMN_CountryOfIncorporation__c = getStringValue(dtoRole.Entity_Organization.Incorporation_Country_Tx);
		newParticipant.CMN_DateOfIncorporation__c = getDateValue(dtoRole.Entity_Organization.Incorporation_Dt);
		newParticipant.CMN_OrganisationType__c = getStringValue(dtoRole.Entity_Organization.Org_Type_Cd);
		newParticipant.CMN_OrganizationName__c = getStringValue(dtoRole.Entity_Organization.Name);
		newParticipant.CMN_RegistrationNumber__c = getStringValue(dtoRole.Entity_Organization.Registration_No);
		newParticipant.CMN_Suffix__c = getStringValue(dtoRole.Entity_Organization.Suffix);

		if(dtoRole.Entity_Organization.EmailAddresses != null && !dtoRole.Entity_Organization.EmailAddresses.isEmpty())
		{
			newParticipant.CMN_Email__c = getStringValue(dtoRole.Entity_Organization.EmailAddresses.iterator().next().Email_Addr);
		}

		if(dtoRole.Entity_Organization.Telephones != null && !dtoRole.Entity_Organization.Telephones.isEmpty())
		{
			setTelephoneFields(dtoRole.Entity_Organization.Telephones, newParticipant);
		}
	}

	/**
	 * @description Delete the other Financial Holdings which are not updated.
	 *
	 * @param upsertAccount The financial account whose holding should be deleted
	 */
	private void deleteFinancialHoldings(FinServ__FinancialAccount__c upsertAccount)
	{
		if(upsertAccount.FinServ__FinancialHoldings__r != null)
		{
			for(FinServ__FinancialHolding__c existingHolding : upsertAccount.FinServ__FinancialHoldings__r)
			{
					registerDeleted(existingHolding);
				}
			}
		}

	/**
	 * @description Delete the other Insurance Policy Coverages and recreate the new coverages sent as part of API.
	 *
	 * @param insurancePolicyNumber An Insurance Policy Id
	 */
	private void deleteInsurancePolicyCoverage(String insurancePolicyNumber)
		{
			InsurancePolicy insurancePolicy = (InsurancePolicy)insurancePoliciesByNameMap.get(insurancePolicyNumber);

			if(insurancePolicy != null)
			{
				for(InsurancePolicyCoverage insurancePolicyCoverage : insurancePolicy.InsurancePolicyCoverages)
				{
						registerDeleted(insurancePolicyCoverage);
					}
				}
			}

	/**
	 * @description Utility method to get String value
	 *
	 * @param foundAccount account to generate the key identifier
	 *
	 * @return string value
	 */
	private static String getKeyToFetchAccount(Account foundAccount)
	{
		String identityNumber = foundAccount.IsPersonAccount ? foundAccount.AW_IdentificationNumber__pc : foundAccount.AW_CompanyRegistrationTrustNumber__c;
		//if its master account we will not have owner consultant else if it non master account we will have consultant code
		return identityNumber + foundAccount.Owner.AW_ConsultantCode__c;
	}

	/**
	 * @description Utility method to get String value
	 *
	 * @param inputValue input value to be checked
	 *
	 * @return string value
	 */
	private static String getStringValue(String inputValue)
	{
		return String.isBlank(inputValue) ? STRING_NULL_IDENTIFIER : inputValue;
	}

	/**
	 * @description Utility method to get String value
	 *
	 * @param inputValue input value to be checked
	 * @param defaultValue input value to be checked
	 *
	 * @return string value
	 */
	private static String getStringValue(String inputValue, String defaultValue)
	{
		return getStringValue(inputValue) != null ? inputValue : defaultValue;
	}

	/**
	 * @description Utility method to get Decimal value
	 *
	 * @param inputValue input value to be checked and converted
	 *
	 * @return decimal value
	 */
	private static Decimal getDecimalValue(String inputValue)
	{
		return String.isBlank(inputValue) ? DECIMAL_NULL_IDENTIFIER : Decimal.valueOf(inputValue);
	}

	/**
	 * @description Utility method to get Decimal value
	 *
	 * @param inputValue input value to be checked and converted
	 * @param defaultValue input value to be checked
	 *
	 * @return decimal value
	 */
	private static Decimal getDecimalValue(String inputValue, Decimal defaultValue)
	{
		Decimal valueToReturn = getDecimalValue(inputValue);
		return valueToReturn != null ? valueToReturn : defaultValue;
	}

	/**
	 * @description Utility method to get Date value
	 *
	 * @param inputValue input value to be checked and converted
	 *
	 * @return date value
	 */
	private static Date getDateValue(String inputValue)
	{
		return (String.isBlank(inputValue) || inputValue == '99999999') ? DATE_NULL_IDENTIFIER : CMN_UTIL_Date.sapStringToDate(inputValue);

	}

	/**
	 * @description Utility method to set Account Status in accountStatusById map
	 *
	 * @param accountIdWithConsultantCode Account Identification number with consultant code
	 * @param newStatus Status to be set
	 */
	private void setAccountStatus(String accountIdWithConsultantCode, String newStatus)
	{
		String currentStatus = accountStatusByNumberAndCode.get(accountIdWithConsultantCode);
		Boolean setStatus = (currentStatus == newStatus) || String.isBlank(currentStatus);

		accountStatusByNumberAndCode.put(accountIdWithConsultantCode, setStatus ? newStatus : AW_DAL_Account.PICK_SUCCESSFUL);
	}

	/**
	 * @description method to populate all the required information for advisers
	 *
	 * @param newRole consultant role to be updated
	 * @param foundCode found Consultant record
	 */
	private void populateRoleWithAdviserDetails(FinServ__FinancialAccountRole__c newRole, SC_ConsultantCodes__c foundCode)
	{
		newRole.AW_RoleFirstName__c = String.isBlank(newRole.AW_RoleFirstName__c) ? foundCode.RSC_AdviserFirstName__c : newRole.AW_RoleFirstName__c;
		newRole.AW_RoleLastName__c = String.isBlank(newRole.AW_RoleLastName__c) ? foundCode.RSC_AdviserLastName__c : newRole.AW_RoleLastName__c;
		newRole.CMN_ConsultantCode__c = consultantRoleCode;
		newRole.FinServ__RelatedContact__c = foundCode.SC_ContactId__c;
		newRole.SC_ConsultantCode__c = foundCode.Id;
		newRole.SC_ConsultantStatus__c = foundCode.SC_AgreementStatus__c ? INTERMEDIATE_POLICY : ORPHAN_POLICY;
	}

	/**
	 * @description method to populate all the required information for advisers
	 *
	 * @param newParticipant consultant role to be updated
	 * @param foundCode found Consultant record
	 */
	private void populateParticipantWithAdviserDetails(InsurancePolicyParticipant newParticipant, SC_ConsultantCodes__c foundCode)
	{
		newParticipant.AW_ConsultantCode__c = consultantRoleCode;
		newParticipant.AW_FirstName__c = String.isBlank(newParticipant.AW_FirstName__c) ? foundCode.RSC_AdviserFirstName__c : newParticipant.AW_FirstName__c;
		newParticipant.AW_LastName__c = String.isBlank(newParticipant.AW_LastName__c) ? foundCode.RSC_AdviserLastName__c : newParticipant.AW_LastName__c;
		newParticipant.RelatedParticipantContactId = foundCode.SC_ContactId__c;
		newParticipant.SC_ConsultantCode__c = foundCode.Id;
		newParticipant.SC_ConsultantStatus__c = foundCode.SC_AgreementStatus__c ? INTERMEDIATE_POLICY : ORPHAN_POLICY;
	}

	/**
	 * @description Method to set Master Account Policy Refresh Status and Date
	 *
	 * @param masterAccounts List of Master Accounts to be updated
	 */
	private void setMasterAccountRefreshStatus(List<Account> masterAccounts)
	{
		for(Account newAccount : masterAccounts)
		{
			Account updateAccount = new Account();
			updateAccount.Id = newAccount.Id;
			updateAccount.AW_BypassValidationRules__c = true;
			updateAccount.AW_PoliciesRefreshStatus__c = AW_DAL_Account.PICK_SUCCESSFUL;
			updateAccount.AW_PoliciesRefreshStatusDate__c = Datetime.now();
			registerChange(updateAccount);
		}

	}

	/**
	 * @description Common Method to set telephone details on Financial account and Insurance policy
	 *
	 * @param telephones DTO+Telephone either from Financial account or Insurance policy
	 * @param contractObject SObject on which the phone field has to be updated
	 */
	private static void setTelephoneFields(List<DTO_Telephone> telephones, SObject contractObject)
	{
		for(DTO_Telephone telephone : telephones)
		{
			if(telephone.Usage_Cd == PERSONAL_PHONE_USAGE_CODE && telephone.Facility_Cd == LAND_LINE_FACILITY_CODE)
			{
				contractObject.put(PHONE_FIELD, getStringValue(telephone.Tel_No));
			}
			else if(telephone.Usage_Cd == WORK_PHONE_USAGE_CODE && telephone.Facility_Cd == LAND_LINE_FACILITY_CODE)
			{
				contractObject.put(WORK_PHONE_FIELD, getStringValue(telephone.Tel_No));
			}
			else if(telephone.Usage_Cd == PERSONAL_PHONE_USAGE_CODE && telephone.Facility_Cd == CELL_PHONE_FACILITY_CODE)
			{
				contractObject.put(MOBILE_FIELD, getStringValue(telephone.Tel_No));
			}
		}
	}

	/**
	 * @description Common Method to set account details on Financial account and Insurance policy
	 *
	 * @param accounts DTOAccount either from Financial account or Insurance policy
	 * @param contractObject SObject on which the account field has to be updated
	 */
	private static void setAccountFields(List<DTO_Account> accounts, SObject contractObject)
	{
		if(accounts != null && !accounts.isEmpty())
		{
			AW_API_SynchroniseContracts.DTO_Account dtoAccount = new AW_API_SynchroniseContracts.DTO_Account();
			dtoAccount = accounts.iterator().next();

			contractObject.put(BANK_ACCOUNT_HOLDER_NAME_FIELD, getStringValue(dtoAccount.Acc_Holder_Nm));
			contractObject.put(BANK_ACCOUNT_NUMBER_FIELD, getStringValue(dtoAccount.Id));
			contractObject.put(BANK_ACCOUNT_TYPE_FIELD, getStringValue(dtoAccount.Type_Cd));
			contractObject.put(BANK_BRANCH_CODE_FIELD, getStringValue(dtoAccount.Branch_Cd));
			contractObject.put(BANK_NAME_FIELD, getStringValue(dtoAccount.Bank_Nm));
		}
	}

	/**
	 * @description Common Method to set accountSo details on Financial account and Insurance policy
	 *
	 * @param accountSo DTOAccountSo either from Financial account or Insurance policy
	 * @param contractObject SObject on which the accountSo field has to be updated
	 */
	private static void setAccountSOFields(List<DTO_AccountsSO> accountSo, SObject contractObject)
	{
		if(accountSo != null && !accountSo.isEmpty())
		{
			AW_API_SynchroniseContracts.DTO_AccountsSO dtoAccountSO = new AW_API_SynchroniseContracts.DTO_AccountsSO();
			dtoAccountSO = accountSo.iterator().next();

			contractObject.put(EMPLOYEE_NUMBER_FIELD, getStringValue(dtoAccountSO.Employee_No));
			contractObject.put(FACILITY_GROUP_FIELD, getStringValue(dtoAccountSO.Facility_Group));
			contractObject.put(FACILITY_NAME_FIELD, getStringValue(dtoAccountSO.Facility_Nm));
			contractObject.put(FACILITY_NUMBER_FIELD, getStringValue(dtoAccountSO.Facility_No));
			contractObject.put(FACILITY_TYPE_FIELD, getStringValue(dtoAccountSO.Facility_Type));
			contractObject.put(PAY_POINT_NUMBER_FIELD, getStringValue(dtoAccountSO.PayPoint_No));
		}
	}

	/**
	 * @description Common Method to set cessionary details on Financial account and Insurance policy
	 *
	 * @param dtoCessionary Cessionary either from Financial account or Insurance policy
	 * @param contractObject SObject which the cessionary field has to be updated
	 */
	private static void setCessionaryFields(DTO_Cessionary dtoCessionary, SObject contractObject)
	{
		if(dtoCessionary != null)
		{
			contractObject.put(CESSIONARY_INITIALS_FIELD, getStringValue(dtoCessionary.Initials));
			contractObject.put(CESSIONARY_NAME_FIELD, getStringValue(dtoCessionary.Last_Nm));
			contractObject.put(CESSIONARY_TITLE_FIELD, getStringValue(dtoCessionary.Title_Tx));
			contractObject.put(CESSIONARY_TYPE_FIELD, getStringValue(dtoCessionary.Type_Tx));
		}
	}

	/**
	 * @description Common Method to set associated contracts on Financial account and Insurance policy
	 *
	 * @param associatedContracts associated contracts associated to policy
	 *
	 * @return returns the concatenated associated contract numbers if found else blank
	 */
	private static String setAssociatedContracts(List<DTO_AssociatedContract> associatedContracts)
	{
		String associatedContractNumbers = CMN_UTIL_String.EMPTY;
		if(associatedContracts != null)
		{
			Set<String> associatedContractNumbersSet = new Set<String>();
			for(DTO_AssociatedContract associatedContract : associatedContracts)
			{
				associatedContractNumbersSet.add(associatedContract.Contract_Number);
			}
			associatedContractNumbers = CMN_UTIL_String.joinStrings(associatedContractNumbersSet, CMN_UTIL_String.EMPTY);
		}
		return associatedContractNumbers;
	}

	/**
	 * @description Method to create child account(Adviser Client)
	 */
	private void insertActiveChildAccounts()
	{
		String identificationNumber = ((DTO_Request)baseRequestDTO).identificationNumber;

		Account masterAccount = mapMasterAccounts.get(identificationNumber);

		if(masterAccount == null)
		{
			return;
		}

		Set<String> missingConsultantCodes = new Set<String>();
		for(String consultantCode : consultantsByConsultantCodeMap.keySet())
		{
			if(!mapNonMasterAccounts.containsKey(identificationNumber + consultantCode))
			{
				missingConsultantCodes.add(consultantCode);
			}
		}

		if(!missingConsultantCodes.isEmpty())
		{
			List<User> foundAdvisers = AW_DAL_User.findByConsultantCode(missingConsultantCodes);

			String recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, masterAccount.IsPersonAccount ?
					AW_DAL_Account.RT_PERSON_ACCOUNT : AW_DAL_Account.RT_BUSINESS_ACCOUNT);

			for(User foundAdviser : foundAdvisers)
			{
				Account newAdviserAccount = new Account();

				newAdviserAccount.AW_BypassValidationRules__c = true;
				newAdviserAccount.AW_ParentAccount__c = masterAccount.Id;
				newAdviserAccount.AW_SKF_Id__c = masterAccount.AW_SKF_Id__c;
				newAdviserAccount.FinServ__Status__c = AW_DAL_Account.STATUS_ACTIVE;
				newAdviserAccount.OwnerId = foundAdviser.Id;
				newAdviserAccount.RecordTypeId = recordTypeId;

				Map<String, Schema.FieldSet> fieldSetMap = CMN_UTIL_SObjectDescribe.getDescribe(Account.SObjectType).getFieldSetsMap();
					String fieldSetName = masterAccount.IsPersonAccount ? AW_DAL_Account.FIELDSET_PERSON : AW_DAL_Account.FIELDSET_BUSINESS;

					FieldSet fieldsToUse = fieldSetMap.get(fieldSetName);

					if(fieldsToUse != null)
					{
						for(FieldSetMember fields : fieldsToUse.getFields())
						{
						newAdviserAccount.put(fields.getFieldPath(), masterAccount.get(fields.getFieldPath()));
					}
				}

				foundAccounts.add(newAdviserAccount);
				mapNonMasterAccounts.put(identificationNumber + foundAdviser.AW_ConsultantCode__c, newAdviserAccount);
			}
		}
	}

	/**
	 * @description The DTO representing the request being sent
	 */
	@TestVisible
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public String identificationNumber;
		public String identificationNumberType;
		public List<DTO_Contract> contracts;

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_Request.class;
		}
	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions')
	private class DTO_Contract
	{
		public String Id;//Name
		public String Source;
		public String Type_Cd;//AW_ProductTypeCode__c,AW_ProductTypeCode__c
		public String Type_Tx;//PolicyName,Name
		public String Contract_Status_Ind;//Status,FinServ__Status__c
		public String Proto_Cd;//AW_PrototypeCode__c
		public String Prod_Class_Cd;
		public String Prod_Class_Tx;
		public List<DTO_AssociatedContract> AssociatedContracts;

		public String Prod_Name_Type;
		public DTO_Inception Inception;
		public DTO_Current Current;
		public DTO_Illustrated Illustrated;

		public List<DTO_Role> Roles;
		public List<DTO_Benefit> Benefits;
	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions')
	private class DTO_AssociatedContract
	{
		public String Contract_Number;
	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions')
	private class DTO_Inception
	{
		//public String ERB_Dis_Amt;
		public String Commencement_Dt;//AW_CommencementDate__c,FinServ__OpenDate__c
		public String Issue_Dt;
		public String Orig_Commencement_Dt;

		//Below Fields added as part of #243432
		public String ERB_Amt;
		public String FA_Yr_Oac_Perc;
		public String FA_Yr_Oac_Growth_Perc;

		public String Package_No;
		public String Srp_Ind;
		public String Cover_Type_Cd;
		public String Cover_Type_Tx;
		public String Guarantee_Val;
		public String Orig_Option_Dt;
		public String Orig_Retirement_Dt;

	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions,ApexUnusedDeclaration,PMD.TooManyFields')
	private class DTO_Current
	{
		//public String Status_Cd;//Status
		public String Status_Tx;//Status,FinServ__Status__c
		public String Status_Rsn_Cd;//AW_StatusReasonCode__c
		public String Status_Rsn_Tx;//AW_StatusReason__c,AW_StatusReason__c
		public String Actual_Prem_Amt;//PremiumAmount
		public String Prem_Pattern_Cd;//AW_PremiumPatternCode__c
		public String Prem_Pattern_Tx;//AW_PremiumPattern__c
		public String Prem_Freq_Cd;//AW_PremiumFrequencyCode__c
		public String Prem_Freq_Tx;//AW_Frequency__c,FinServ__PaymentFrequency__c,PremiumFrequency
		public String Payment_Method_Cd;//AW_PaymentMethodCode__c
		public String Payment_Method_Tx;//AW_PaymentMethod__c
		public String Val_At_Dt;//AW_ValueAsAt__c
		public String Inv_Val;//AW_InvestmentValue__c,AW_InvestmentValue__c

		public String Surrender_Val;//CashSurrenderValue,AW_SurrenderValue__c
		public String Gross_Death_Val;//AW_CurrentValue__c,AW_CurrentValue__c
		public String Paid_Up_Death_Val;//AW_PaidUpValue__c
		public String Total_Package_Death_Val;//AW_CurrentValue__c
		//public String Retirement_Dt;
		public String Adv_Avail_Amt;//AW_AdvanceAvailable__c
		public String Repayable_Amt;//AW_RepayableAmount__c
		public String Accessible_Amt;//AW_AccessibleAmount__c
		public String Recur_Inv_Freq_Cd;//if Prem_Freq_Tx is empty then refer value from Prem_Freq_Cd,Recur_Inv_Freq_Cd
		//public String Aci_Amt;
		public String Aci_Tx;
		public String Abi_Tx;
		public String Abi_Amt;
		//public String Switch_Adv_Amt;
		public String Adhoc_Contrib_Amt;
		public String Recur_Inv_Amt;//FinServ__Premium__c

		public String Total_Inv_Amt;//AW_TotalInvestmentAmount__c
		public String Income_Freq_Tx;//AW_IncomeFrequency__c
		public String Last_Income_Pmt_Amt;//AW_LastIncomeAmount__c
		public String Last_Income_Pmt_Dt;//AW_LastIncomeDate__c

		//Below Fields added as part of #146028

		public String Debit_Day;
		public String Aci_Amt;
		//public String Abi_Cd; // inter related to Abi_Tx check should we map or not
		public String Abi_Perc;
		public String Aci_Perc;
		public String Retirement_Age;
		public String Smoker_Rate_Ind;
		public String Retirement_Dt;
		public String Paid_To_Dt;
		public String Non_Guarantee_Inv_Amt;
		public String Guarantee_Inv_Amt;
		public String Trans_Val;
		public String Total_Withdrawal_Amt;
		public String Trans_No;

		//Below Fields added as part of #243432
		public String Switch_Val;
		public String Commuted_Val;
		public String Adv_Type_Tx;
		public String OIP_Oac_Perc;
		public String Guarantee_Start_Dt;
		public String Guarantee_End_Dt;
		public String Target_Ret_Perc;
		public String Ret_Guarantee_Perc;
		public String Growth_Sharing_Perc;
		public String Guarantee_Top_Up_Amt;
		public String OIP_Guarantee_Amt;

		public String Paid_Up_Contrib_Amt;
		public String Guarantee_Review_Notified_Dt;
		public String Option_Dt;
		public String Maturity_Dt;
		public String Expiry_Dt;
		public String Restriction_End_Dt;
		public String Aids_Incl_Ind;
		public String Fund_Val;
		public String Cpr_Advance_Amt;
		public String Qual_Addlib_Ind;
		public String Total_Repayable_Amt;
		public String Next_Billing_Dt;
		public String Paid_Up_Ben_Ind;
		public String Cash_Back_Ind;
		public String Refund_Available_Amt;
		public String Cash_Back_Earned;
		public String Cash_Back_Date;
		public String Prem_Recieved_Ind;

		public String Credit_Aci_Perc;
		public String Escal_Perc;
		public String Curr_Ind;
		public String Fund_Name;
		public String Guarantee_Expiry_Dt;
		public String Income_Drawdown_Tx;
		public String Last_Withdrawal_Paid_Dt;
		public String Loan_Interest_Rate;
		public String Participation_Dt;
		public String Hld_Status_Cd;
		public String Hld_Status_Ind;
		public String Ra_Emigration_Val;
		public String Recur_Aci_Perc;
		public String Section14_Transfer_Val;
		public String Total_Withdrawal_Dt;
		public String Transaction_Fee;
		public String OIP_Total_Inv_Amt;
		public String Adv_Type_Cd;
		public String Capital_Content_Amt;
		public String Deduction_Amt;
		public String Member_Fund_Val;
		public String Income_Adv_Arrears_Tx;
	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions')
	private class DTO_Illustrated
	{
		public String Illustr_Dt;//AW_IllustratedValueDate__c
		public String Illustr_Maturity_Val;//AW_IllustrativeMaturityValue__c

		//Below Fields added as part of #146028
		public String Illustr_Val;

		//Below Field added as part of #243432
		public String EIF_Oac_Perc;

		public String Term_Illustr_Val;
		public String Illustr_Val_Dt;
		public String Illustr_Val_Rate;
		public String Illustr_Val_Age;
		public String Illustr_Return_Perc;

		public String EIF_Capital_Amt;
		public String EIF_Guarantee_Amt;
		public String Future_Inv_Fund_Name;
		public String Illustr_Retirement_Amt;
		public String Illustr_Surrender_Val;
		public String Illustr_Surrender_Val_Dt;
		public String Recur_EIF_Future_Perc;
		public String Total_Future_Perc;
		public String Guide_Alloc_Ind;
		public String EIF_Total_Inv_Amt;
		public String Future_Inv_Fund_Perc;
		public String EIF_Freq_Cd;
	}

	/**
	 * @description Class representing Roles
	 */
	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions')
	private class DTO_Role//Insurance Policy Participants,Financial Account Roles
	{
		public String Id;//owner Consultant code
		public String Type_Tx;//Role,FinServ__Role__c
		public String Type_Cd;//AW_RoleCode__c
		//public String Type_PB_Cd;
		//public String Status_Cd;
		public String Relationship_Tx;//AW_Relationship__c
		public String Relationship_To_Owner_Tx;
		public String Split_Percentage;//AW_PercentageSplit__c
		//public String Entity_Type_Cd;

		public DTO_Person Entity_Person;
		public List<DTO_Benefit> Benefits;

		//Below Fields added as part of #146028
		public DTO_Cessionary Cessionary;
		public DTO_Organization Entity_Organization;
		public List<DTO_Account> Accounts;
		public List<DTO_AccountsSO> AccountsSO;
	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions, ApexUnusedDeclaration')
	private class DTO_Cessionary
	{
		public String Comp_Suff;
		public String Id;
		public String Title_Tx;
		public String Initials; //mapped
		public String Last_Nm; //mapped
		public String Type_Cd; //picklist field // need to chk we need to map based on text or code
		// bcz we have only one field on salesforce
		public String Type_Tx; //mapped //picklist field
	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions,ApexUnusedDeclaration')
	private class DTO_Organization
	{
		public String Id;//AW_PDBID__c will be mapped if the role is of ORG type
		public String Name;
		public String Registration_No;
		public String Suffix;
		public String Org_Type_Cd; //picklist // need to chk the mapping should be based on code or Text, as of now done with Text
		public String Org_Type_Tx;
		public String Incorporation_Dt;
		public String Incorporation_Country_Cd; //picklist // need to chk the mapping should be based on code or Text, as of now done with Text
		public String Incorporation_Country_Tx;
		public List<DTO_Registration> Registrations;

		public List<DTO_Telephone> Telephones;
		public List<DTO_EmailAddress> EmailAddresses;
	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions')
	private class DTO_Account
	{
		public String Bank_Nm;
		public String Id;
		public String Acc_Holder_Nm;
		public String Branch_Cd; //picklist
		@SuppressWarnings('ApexUnusedDeclaration')
		public String Type_Cd;//picklist
		public String Type_Tx; //picklist
	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions')
	private class DTO_AccountsSO
	{
		public String Facility_Group;
		public String PayPoint_No;
		public String Facility_Type;
		public String Facility_No;
		public String Facility_Nm;
		public String Employee_No;
	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions,ApexUnusedDeclaration')
	private class DTO_Person
	{
		public String Initials;//AW_Initials__c,AW_RoleInitials__c
		public String Last_Nm;//AW_LastName__c,AW_RoleLastName__c
		public String Title_Tx;//AW_Salutation__c,AW_RoleTitle__c
		public String First_Nm;//AW_FirstName__c,AW_RoleFirstName__c
		public String Second_Nm;//AW_SecondName__c
		public String Identity_No;//AW_IdentificationNumber__c,AW_RoleIdentificationNumber__c
		public String Birth_Dt;//AW_DateofBirth__c,AW_RoleDOB__c
		public String Gender_Cd;//AW_Gender__c
		public String Marital_Status_Cd;//AW_MaritalStatus__c
		public String Occupation_Tx;//AW_Occupation__c
		public String Id;//AW_PDBID__c
		public String Preferred_Language_Cd;
		//public String Preferred_Language_Tx;
		public String Qualification_Cd;
		//public String Qualification_Tx;
		//public List<DTO_Address> Addresses;

		//Below Fields added as part of #146028

		public List<DTO_Registration> Registrations;

		public List<DTO_Telephone> Telephones;
		public List<DTO_EmailAddress> EmailAddresses;
		public String Marriage_Date;
		public String Race_Cd; //mapped based on text as we have only one field
		public String Race_Tx;
		public String SA_Resident_Ind;
		public String Occupation_Risk_Cat_Cd;//mapped based on text as we have only one field
		public String Occupation_Risk_Cat_Tx;
		public String Third_Nm;
		public String Fourth_Nm;
		public String Fifth_Nm;
	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions,ApexUnusedDeclaration')
	private class DTO_Telephone
	{
		public String Facility_Cd;
		public String Facility_Tx;
		public String Usage_Tx;
		public String Tel_No;
		public String Usage_Cd;
	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions')
	private class DTO_EmailAddress
	{
		public String Email_Addr;
	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions,ApexUnusedDeclaration')
	private class DTO_Address
	{
		public String Usage_Cd;
		public String Addr_Line_2;
		public String Addr_Line_1;
		public String Postal_Cd;
		public String Usage_Tx;
	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions')
	private class DTO_Registration
	{
		public String Registration_Number;
		public String Registration_Type_Cd;
		public String Registration_Type_Tx;
		public String Country_Of_Issue_Cd;
		public String Country_Of_Issue_Tx;
		public String Citizenship_Country_Cd;
		public String Citizenship_Country_Tx;
		public String Issue_Date;
		public String Expiry_Date;
	}

	/**
	 * @description Class representing Coverages
	 */
	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions')
	private class DTO_Benefit//Insurance policy Coverage,Financial Holdings
	{
		public String Term;//AW_Term__c
		public String Type_Cd;//AW_TypeCode__c
		public String Type_Tx;//AW_Type__c
		public String Status_Cd;//AW_StatusCode__c
		public String Status_Rsn_Cd;//AW_StatusReasonCode__c
		public String Start_Dt;//AW_StartDate__c
		public String End_Dt;//AW_EndDate__c
		public String Benefit_Amt;//AW_BenefitAmount__c
		public String Orig_Benefit_Amt;//AW_OriginalBenefitAmount__c

		//Below Fields added as part of #146028

		public String Imm_Exp_Benefit_Ind;
		public String Load_Ind;
		public String Waiting_Period;
		public String Waiting_Period_Tx;
		public String Load_Contrib_Amt;
		public String Contrib_Amt;
		public String Aci_Perc;

		public String Excl_Ind;
		public String Inc_Dis_Claim_Perc;
		public String BenefitClassification;
		public String Term_Ill_Val;
		public String Conver_Option_Ind;

		public List<DTO_Portfolio> Portfolios;
	}

	@TestVisible
	@SuppressWarnings('PMD.FieldNamingConventions')
	private class DTO_Portfolio
	{
		public String Type_Cd;//AW_Product_Code__c
		public String Type_Tx;//Name
		public String Unit_Amt;//FinServ__Shares__c
		public String Buy_Price;//FinServ__PurchasePrice__c
		public String Rand_Val;//FinServ__MarketValue__c
		public String Sell_Price;//AW_SellingPrice__c
		public String Share_Perc;//AW_SharePercentage__c
	}

	/**
	 * @description DTO representing a successful response
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		@SuppressWarnings('ApexUnusedDeclaration')
		public String message = 'Contracts synchronised successfully';
	}

	/**
	 * @description Used to pass around role information
	 */
	private class DTO_RoleDetails
	{
		Boolean hasPersonEntity;
		Boolean hasOrganisationEntity;
		Boolean isAdviserRole;
	}
}