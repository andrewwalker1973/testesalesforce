/**
 * @description Class containing invocable action to upsert contracts from a platform event
 *
 * @see SC_FLOW_SynchroniseContracts_TEST
 *
 * @author abhijeet.s.shete@accenture.com jayanth.kumar.s@accenture.com vishakha.saini@accenture.com
 *
 * @date February 2023, March 2023
 */
@SuppressWarnings('PMD.CognitiveComplexity,PMD.CyclomaticComplexity,PMD.StdCyclomaticComplexity,PMD.ExcessivePublicCount')
public inherited sharing class SC_FLOW_SynchroniseContracts
{
	private static Account accountToLinkPolicy;
	private static Account masterAccount;
	private static CMN_UTIL_SObjectIndex productCodeByCompositeMap;
	private static Map<Id, List<SObject>> existingPartyMap = new Map<Id, List<SObject>>();
	private static Map<String, SObject> contractNumberToObjectMap = new Map<String, SObject>();
	private static SC_ConsultantCodes__c consultantCode;
	private static Set<Id> existingFinancialAccountIds;
	private static Set<Id> existingPolicyIds;
	private static String identityNumber;

	private final static List<Account> ACCOUNTS_TO_SYNCHRONISE = new List<Account>();
	@TestVisible
	private static final String BENEFICIARY_ROLE = 'Beneficiary';
	@TestVisible
	private static final String RELATED_TO_PRIMARY = 'Primary Life Assured';
	@TestVisible
	private static final String RELATED_TO_SECONDARY = 'Secondary Life Assured';
	@TestVisible
	private static final Integer DEFAULT_YEAR = 1900;
	@TestVisible
	private static final Integer DEFAULT_MONTH = 01;
	@TestVisible
	private static final Integer DEFAULT_DAY = 01;
	private static final Date DEFAULT_DATE = Date.newInstance(DEFAULT_YEAR, DEFAULT_MONTH, DEFAULT_DAY);

	private static final List<String> RELATED_TO_ROLES = new List<String>
	{
			RELATED_TO_PRIMARY, RELATED_TO_SECONDARY
	};
	private static final List<String> SEARCH_FIELDS = new List<String>
	{
			AW_DAL_ProductCodeAndCategoryMapping.FIELD_PRODUCT_CODE, AW_DAL_ProductCodeAndCategoryMapping.FIELD_PROTO_TYPE
	};

	private static final CMN_DAL_SObjectUnitOfWork UNIT_OF_WORK =
			new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>
			{
					Account.SObjectType,
					InsurancePolicy.SObjectType,
					FinServ__FinancialAccount__c.SObjectType,
					InsurancePolicyParticipant.SObjectType,
					FinServ__FinancialAccountRole__c.SObjectType,
					CMN_WebserviceCallQueue__c.SObjectType
			});

	private static final Map<String, Account> NATIONAL_ID_TO_MASTER_ACCOUNT_MAP = new Map<String, Account>();
	private static final Map<String, Account> NATIONAL_ID_TO_NON_MASTER_ACCOUNT_MAP = new Map<String, Account>();
	private static final Map<String, SObject> CONSULTANT_CODE_BY_CODE_MAP = new Map<String, SObject>();
	private static final Map<String, SObject> USER_BY_CONSULTANT_CODE = new Map<String, SObject>();
	@TestVisible
	private static final String CONTRACT_SYNC_METHOD = 'SC_FLOW_SynchroniseContracts/synchroniseContracts';
	@TestVisible
	private static final String ERROR_CATEGORY_MAPPING_NULL_SOBJECT = 'SObject mapping is null for category "{0}".';
	@TestVisible
	private static final String ERROR_MULTIPLE_PRODUCT_CODES = 'Product with Code: "{0}" and Proto Type Code "{1}" has multiple records';
	@TestVisible
	private static final String ERROR_INVALID_SOBJECT = 'SObject "{0}" is not supported for the Contract Synchronisation process.';
	@TestVisible
	private static final String ERROR_NO_ACCOUNT_FOUND = 'Account with Identity Number / Business Registration Number / Passport Number "{0}" not found';
	@TestVisible
	private static final String ERROR_NO_IDENTITY_NUMBER_PROVIDED = 'No Id / Reg / Passport number provided for policy number "{0}"';
	@TestVisible
	private static final String ERROR_NO_PRODUCT_CODE_FOUND = 'Product Code "{0}" and ProtoCode "{1}" not found';
	@TestVisible
	private static final String CONSULTANT_ROLE = 'Consultant';
	@TestVisible
	private static final String PAYER_ROLE = 'Payer';
	private static final String INFO_NO_PRODUCT_CODE_FOUND = 'The following contract event was received: \n "{0}"';
	private static final String INTERMEDIATE_POLICY = '1';
	private static final String INVESTMENT_PRODUCT_CATEGORY = 'Investment';
	private static final String ORPHAN_POLICY = '0';
	/**
	 * @description Processes Contracts from Synchronise Contracts API and inserts or updates them.
	 *
	 * @param insertedEvents A list of events that were inserted
	 */
	@InvocableMethod(Label='Synchronise Contracts' Description='Processes Contracts from Synchronise Contracts API and either inserts or updates them.')
	public static void synchroniseContracts(List<RSC_ContractEvent__e> insertedEvents)
	{
		Boolean clientFound;

		productCodeByCompositeMap = new CMN_UTIL_SObjectIndex(SEARCH_FIELDS).putAll(AW_DAL_ProductCodeAndCategoryMapping.getAll());

		List<DTO_ContractRequest> dtoContractRequests = new List<DTO_ContractRequest>();
		Set<String> policyNumbers = new Set<String>();
		Set<String> accountIdentityNumbers = new Set<String>();
		Set<String> consultantCodes = new Set<String>();

		for(RSC_ContractEvent__e insertedEvent : insertedEvents)
		{
			clientFound = true;
			existingPolicyIds = new Set<Id>();
			existingFinancialAccountIds = new Set<Id>();

			CMN_UTIL_Logger.info(String.format(INFO_NO_PRODUCT_CODE_FOUND, new List<String> {JSON.serializePretty(insertedEvent, true)}), CONTRACT_SYNC_METHOD);

			DTO_ContractRequest dtoContractRequest = (DTO_ContractRequest)new DTO_ContractRequest().deserialize(insertedEvent.RSC_ContractData__c);

			if(String.isNotBlank(dtoContractRequest.client_national_id))
			{
				accountIdentityNumbers.add(dtoContractRequest.client_national_id);
			}
			else if(String.isNotBlank(dtoContractRequest.client_company_reg_no))
			{
				accountIdentityNumbers.add(dtoContractRequest.client_company_reg_no);
			}
			else if(String.isNotBlank(dtoContractRequest.client_passport_no))
			{
				accountIdentityNumbers.add(dtoContractRequest.client_passport_no);
			}
			else
			{
				clientFound = false;
				CMN_UTIL_Logger.debug(String.format(ERROR_NO_IDENTITY_NUMBER_PROVIDED, new List<Object> {dtoContractRequest.policy_number}), CONTRACT_SYNC_METHOD);
			}

			if(clientFound)
			{
				if(String.isNotBlank(dtoContractRequest.policy_number))
				{
					policyNumbers.add(dtoContractRequest.policy_number);
				}
				if(String.isNotBlank(dtoContractRequest.consultant_code))
				{
					consultantCodes.add(dtoContractRequest.consultant_code);
				}

				dtoContractRequests.add(dtoContractRequest);
			}
		}

		CONSULTANT_CODE_BY_CODE_MAP.putAll(CMN_UTIL_System.convertListToSingleStringMap(SC_DAL_ConsultantCodes.findByConsultantCode(consultantCodes),
				CMN_DAL_SObjectDomain.FIELD_NAME));
		USER_BY_CONSULTANT_CODE.putAll(CMN_UTIL_System.convertListToSingleStringMap(AW_DAL_User.findByConsultantCode(consultantCodes),
				AW_DAL_User.FIELD_CONSULTANT_CODE));

		List<InsurancePolicy> insurancePolicies = SC_DAL_InsurancePolicy.findByName(policyNumbers);
		contractNumberToObjectMap = CMN_UTIL_System.convertListToSingleStringMap(insurancePolicies, CMN_DAL_SObjectDomain.FIELD_NAME);

		List<FinServ__FinancialAccount__c> financialAccounts = SC_DAL_FinancialAccount.findByAccountNumber(policyNumbers);
		contractNumberToObjectMap.putAll(CMN_UTIL_System.convertListToSingleStringMap(financialAccounts, SC_DAL_FinancialAccount.FIELD_FINANCIAL_ACCOUNT_NUMBER));

		for(Account foundAccount : AW_DAL_Account.findByIdentityNumber(accountIdentityNumbers))
		{
			String foundIdentityNumber = foundAccount.IsPersonAccount ? foundAccount.AW_IdentificationNumber__pc : foundAccount.AW_CompanyRegistrationTrustNumber__c;

			if(AW_DAL_Account.MASTER_ACCOUNT_RECORDTYPE_NAMES.contains(foundAccount.RecordType.DeveloperName))
			{
				NATIONAL_ID_TO_MASTER_ACCOUNT_MAP.put(foundIdentityNumber, foundAccount);
			}
			else
			{
				NATIONAL_ID_TO_NON_MASTER_ACCOUNT_MAP.put(foundIdentityNumber + foundAccount.Owner.AW_ConsultantCode__c, foundAccount);
			}
		}

		existingPartyMap = CMN_UTIL_System.convertListToMap
				(
						SC_DAL_InsurancePolicyParticipant.findByParent(CMN_UTIL_System.extractListIds(insurancePolicies)),
						SC_DAL_InsurancePolicyParticipant.FIELD_PARENT_POLICY_ID
				);

		existingPartyMap.putAll
				(
						CMN_UTIL_System.convertListToMap
								(
										SC_DAL_FinancialAccountRole.findByParentId(CMN_UTIL_System.extractListIds(financialAccounts)),
										SC_DAL_FinancialAccountRole.FIELD_PARENT
								)
				);

		processContracts(dtoContractRequests);
	}

	/**
	 * @description Populates Insurance Policy record with DTO_ContractRequest from event
	 *
	 * @param dtoRequests Contract request
	 */
	private static void processContracts(List<DTO_ContractRequest> dtoRequests)
	{
		for(DTO_ContractRequest dtoRequest : dtoRequests)
		{
			addConsultantParty(dtoRequest);

			if(String.isNotBlank(dtoRequest.client_national_id))
			{
				identityNumber = dtoRequest.client_national_id;
			}
			else if(String.isNotBlank(dtoRequest.client_company_reg_no))
			{
				identityNumber = dtoRequest.client_company_reg_no;
			}
			else
			{
				identityNumber = dtoRequest.client_passport_no;
			}

			masterAccount = NATIONAL_ID_TO_MASTER_ACCOUNT_MAP.get(identityNumber);

			if(masterAccount != null)
			{
				UNIT_OF_WORK.registerChange(new Account(Id = masterAccount.Id, SC_PDBId__c = dtoRequest.pdb_id));
			}

			Account nonMasterAccount = NATIONAL_ID_TO_NON_MASTER_ACCOUNT_MAP.get(identityNumber + dtoRequest.consultant_code);

			if(nonMasterAccount != null && String.isBlank(nonMasterAccount.AW_ParentAccount__c) && masterAccount != null)
			{
				UNIT_OF_WORK.registerChange(new Account(Id = nonMasterAccount.Id, AW_ParentAccount__c = masterAccount.Id));
			}
			accountToLinkPolicy = nonMasterAccount != null ? nonMasterAccount : initialiseAdviserOwnerAccount();
			accountToLinkPolicy = accountToLinkPolicy == null ? masterAccount : accountToLinkPolicy;

			if(accountToLinkPolicy == null)
			{
				CMN_UTIL_Logger.debug(String.format(ERROR_NO_ACCOUNT_FOUND, new List<Object> {identityNumber}), CONTRACT_SYNC_METHOD);
				continue;
			}

			// Removing leading zeros if any
			String productTypeCode = String.isNotBlank(dtoRequest.product_type_code) ?
					String.valueOf(Integer.valueOf(dtoRequest.product_type_code)) : dtoRequest.product_type_code;

			String prototypeCode = CMN_UTIL_String.isNumeric(dtoRequest.proto_cd) ? dtoRequest.proto_cd : null;
			prototypeCode = String.isNotBlank(prototypeCode) ? String.valueOf(Integer.valueOf(prototypeCode)) : prototypeCode;

			Map<String, Object> searchFieldsMap = new Map<String, Object>
			{
					AW_DAL_ProductCodeAndCategoryMapping.FIELD_PRODUCT_CODE => productTypeCode,
					AW_DAL_ProductCodeAndCategoryMapping.FIELD_PROTO_TYPE => prototypeCode
			};

			List<AW_ProductCodeAndCategoryMapping__mdt> productCodeAndCategoryList =
					(List<AW_ProductCodeAndCategoryMapping__mdt>)productCodeByCompositeMap.getAll(searchFieldsMap);

			if(productCodeAndCategoryList.size() > 1)
			{
				CMN_UTIL_Logger.debug(String.format(ERROR_MULTIPLE_PRODUCT_CODES, new List<Object> {dtoRequest.product_type_code, dtoRequest.proto_cd}),
						CONTRACT_SYNC_METHOD);
			}

			AW_ProductCodeAndCategoryMapping__mdt foundProductCode;

			if(productCodeAndCategoryList != null && !productCodeAndCategoryList.isEmpty())
			{
				foundProductCode = productCodeAndCategoryList.iterator().next();
				if(String.isNotBlank(foundProductCode.AW_SalesforceObject__c) && foundProductCode.AW_SalesforceObject__c.equalsIgnoreCase(
						SC_DAL_InsurancePolicy.OBJECT_NAME))
				{
					upsertInsurancePolicy((InsurancePolicy)contractNumberToObjectMap.get(dtoRequest.policy_number), dtoRequest);
				}
				else if(String.isNotBlank(foundProductCode.AW_SalesforceObject__c) && foundProductCode.AW_SalesforceObject__c.equalsIgnoreCase(
						SC_DAL_FinancialAccount.OBJECT_NAME))
				{
					upsertFinancialAccount((FinServ__FinancialAccount__c)contractNumberToObjectMap.get(dtoRequest.policy_number), dtoRequest, foundProductCode);
				}
				else if(String.isBlank(foundProductCode.AW_SalesforceObject__c))
				{
					CMN_UTIL_Logger.debug(String.format(ERROR_CATEGORY_MAPPING_NULL_SOBJECT, new List<Object> {foundProductCode.DeveloperName}), CONTRACT_SYNC_METHOD);
				}
				else
				{
					CMN_UTIL_Logger.debug(String.format(ERROR_INVALID_SOBJECT, new List<Object> {foundProductCode.AW_SalesforceObject__c}), CONTRACT_SYNC_METHOD);
				}
			}
			else
			{
				CMN_UTIL_Logger.debug(String.format(ERROR_NO_PRODUCT_CODE_FOUND, new List<Object> {dtoRequest.product_type_code, dtoRequest.proto_cd}),
						CONTRACT_SYNC_METHOD);
			}
		}

		UNIT_OF_WORK.commitWork();

		SC_UTIL_Contracts.deleteInactiveRoles(existingFinancialAccountIds, existingPolicyIds);

		List<CMN_WebserviceCallQueue__c> queueItems = new List<CMN_WebserviceCallQueue__c>();

		//US:435211 - trigger Prospect sync for new adviser Account
		for(Account account : ACCOUNTS_TO_SYNCHRONISE)
		{
			queueItems.add(CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RestOutboundClientUpdated.SERVICE_NAME, account.Id));
		}

		CMN_DAL_SObjectDomain.insertDBObjects(queueItems);
	}

	/**
	 * @description Will add a consultant party using the consultant code provided on the request
	 *
	 * @param dtoRequest The contract request
	 */
	private static void addConsultantParty(DTO_ContractRequest dtoRequest)
	{
		consultantCode = (SC_ConsultantCodes__c)CONSULTANT_CODE_BY_CODE_MAP.get(dtoRequest.consultant_code);

		if(consultantCode != null)
		{
			DTO_Party dtoParty = new DTO_Party();

			dtoParty.rel_party_email = consultantCode.RSC_AdviserEmail__c;
			dtoParty.rel_party_firstname = consultantCode.RSC_AdviserFirstName__c;
			dtoParty.rel_party_surname = consultantCode.RSC_AdviserLastName__c;
			dtoParty.role_type = CONSULTANT_ROLE;
			dtoRequest.parties = dtoRequest.parties == null ? new List<DTO_Party>() : dtoRequest.parties;

			dtoRequest.parties.add(dtoParty);
		}
	}

	/**
	 * @description Populates Insurance Policy record with DTO_ContractRequest from event
	 *
	 * @param dtoRequest Contract request
	 * @param upsertPolicy New or existing insurance policy record
	 *
	 * @return populated InsurancePolicy
	 */
	private static InsurancePolicy populateInsurancePolicy(DTO_ContractRequest dtoRequest, InsurancePolicy upsertPolicy)
	{
		upsertPolicy.Name = dtoRequest.policy_number;
		upsertPolicy.AW_StatusReason__c = dtoRequest.status_desc;
		upsertPolicy.AW_CommencementDate__c = dtoRequest.commencement_date.date();
		upsertPolicy.PremiumAmount = dtoRequest.premium_amt;
		upsertPolicy.CMN_PaidToDate__c = getPaidToDate(dtoRequest.paidto_dt);
		upsertPolicy.AW_PremiumFrequencyCode__c = dtoRequest.frequency;
		upsertPolicy.AW_Frequency__c = dtoRequest.frequency_desc;
		upsertPolicy.PolicyName = dtoRequest.product_type_desc;
		return upsertPolicy;
	}

	/**
	 * @description Populates Financial Account record with DTO_ContractRequest from event
	 *
	 * @param dtoRequest Contract request
	 * @param upsertAccount New or existing Financial Account record
	 * @param foundProductCode Product code
	 *
	 * @return populated Financial Account
	 */
	private static FinServ__FinancialAccount__c populateFinancialAccount(DTO_ContractRequest dtoRequest, FinServ__FinancialAccount__c upsertAccount,
			AW_ProductCodeAndCategoryMapping__mdt foundProductCode)
	{
		upsertAccount.FinServ__FinancialAccountNumber__c = dtoRequest.policy_number;
		//Removing the status mapping for now from contract sync, as EDP is not sending the In Force and Out Of Force for Status.
		upsertAccount.AW_StatusReason__c = dtoRequest.status_desc;
		upsertAccount.FinServ__OpenDate__c = dtoRequest.commencement_date.date();
		upsertAccount.AW_ActualPremiumAmount__c = dtoRequest.premium_amt;
		upsertAccount.CMN_PaidtoDate__c = getPaidToDate(dtoRequest.paidto_dt);
		upsertAccount.FinServ__PaymentFrequency__c = dtoRequest.frequency_desc;
		upsertAccount.Name = dtoRequest.product_type_desc;

		String recordTypeName = INVESTMENT_PRODUCT_CATEGORY.equalsIgnoreCase(foundProductCode.AW_ProductCategory__c) ?
				AW_DAL_FinancialAccount.RT_INVESTMENT_ACCOUNT : AW_DAL_FinancialAccount.RT_RETIREMENT_ACCOUNT;
		upsertAccount.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(FinServ__FinancialAccount__c.SObjectType, recordTypeName);
		upsertAccount.AW_ProductCategory__c = foundProductCode.AW_ProductCategory__c;
		upsertAccount.AW_ProductSubCategory__c = foundProductCode.AW_ProductSubCategory__c;
		return upsertAccount;
	}

	/**
	 * @description Populates InsurancePolicyParticipant record with DTO_Party from event
	 *
	 * @param dtoParty Party from event
	 * @param upsertParticipant New or existing InsurancePolicyParticipant record
	 */
	private static void populateInsurancePolicyParticipant(DTO_Party dtoParty, InsurancePolicyParticipant upsertParticipant)
	{
		if(String.isNotBlank(dtoParty.rel_party_company_reg_no))
		{
			upsertParticipant.CMN_RegistrationNumber__c = dtoParty.rel_party_company_reg_no;
			upsertParticipant.CMN_OrganizationName__c = dtoParty.rel_party_firstname + dtoParty.rel_party_surname;
		}
		else
		{
			upsertParticipant.AW_FirstName__c = dtoParty.rel_party_firstname;
			upsertParticipant.AW_IdentificationNumber__c = dtoParty.rel_party_national_id;
			upsertParticipant.AW_LastName__c = dtoParty.rel_party_surname;
			upsertParticipant.AW_Salutation__c = dtoParty.title;
		}

		upsertParticipant.AW_PercentageSplit__c = String.isNotBlank(dtoParty.beneficiary_percentage) ? Decimal.valueOf(dtoParty.beneficiary_percentage) : null;
		upsertParticipant.CMN_Email__c = dtoParty.rel_party_email;
		upsertParticipant.CMN_PassportNumber__c = dtoParty.rel_party_passport_no;
		upsertParticipant.CMN_PhoneNumber__c = dtoParty.rel_party_tel_no;

		upsertParticipant.IsActiveParticipant = true;
		upsertParticipant.RelatedParticipantContactId = null;
		upsertParticipant.Role = String.isNotBlank(dtoParty.relatedto) && RELATED_TO_ROLES.contains(dtoParty.relatedto) ?
				dtoParty.relatedto + CMN_UTIL_String.SPACE + dtoParty.role_type : dtoParty.role_type;

		if(BENEFICIARY_ROLE.equalsIgnoreCase(dtoParty.role_type))
		{
			if(String.isNotBlank(dtoParty.relatedto))
			{
				upsertParticipant.AW_RelationshipToLifeAssured__c = dtoParty.relationship;
			}
			else
			{
				upsertParticipant.CMN_RelationshipToOwner__c = dtoParty.relationship;
			}

		}
		else if(CONSULTANT_ROLE.equalsIgnoreCase(dtoParty.role_type) && consultantCode != null)
		{
			//TODO: Logic to be changed once we received consultant roles in the parties list
			upsertParticipant.AW_ConsultantCode__c = consultantCode.Name;
			upsertParticipant.RelatedParticipantContactId = consultantCode.SC_ContactId__c;
			upsertParticipant.Role = CONSULTANT_ROLE;
			upsertParticipant.SC_ConsultantCode__c = consultantCode.Id;
			upsertParticipant.SC_ConsultantStatus__c = consultantCode.SC_AgreementStatus__c ? INTERMEDIATE_POLICY : ORPHAN_POLICY;
		}
	}

	/**
	 * @description Populates Financial Account role record with DTO_Party from event
	 *
	 * @param dtoParty Party from event
	 * @param upsertRole New or existing Financial Account role record
	 */
	private static void populateFinancialAccountRole(DTO_Party dtoParty, FinServ__FinancialAccountRole__c upsertRole)
	{
		upsertRole.CMN_Email__c = dtoParty.rel_party_email;
		upsertRole.CMN_PercentageSplit__c = String.isNotBlank(dtoParty.beneficiary_percentage) ? Decimal.valueOf(dtoParty.beneficiary_percentage) : null;
		upsertRole.CMN_PhoneNumber__c = dtoParty.rel_party_tel_no;
		upsertRole.FinServ__Active__c = true;
		upsertRole.FinServ__RelatedContact__c = null;
		upsertRole.FinServ__Role__c = String.isNotBlank(dtoParty.relatedto) && RELATED_TO_ROLES.contains(dtoParty.relatedto) ?
				dtoParty.relatedto + CMN_UTIL_String.SPACE + dtoParty.role_type : dtoParty.role_type;

		if(String.isNotBlank(dtoParty.rel_party_company_reg_no))
		{
			upsertRole.CMN_RegistrationNumber__c = dtoParty.rel_party_company_reg_no;
			upsertRole.CMN_OrganizationName__c = dtoParty.rel_party_firstname + dtoParty.rel_party_surname;
		}
		else
		{
			upsertRole.AW_RoleFirstName__c = dtoParty.rel_party_firstname;
			upsertRole.AW_RoleIdentificationNumber__c = dtoParty.rel_party_national_id;
			upsertRole.AW_RoleLastName__c = dtoParty.rel_party_surname;
			upsertRole.AW_RoleTitle__c = dtoParty.title;
			upsertRole.CMN_PassportNumber__c = dtoParty.rel_party_passport_no;
		}

		if(BENEFICIARY_ROLE.equalsIgnoreCase(dtoParty.role_type))
		{
			if(String.isNotBlank(dtoParty.relatedto))
			{
				upsertRole.CMN_RelationshipToLifeAssured__c = dtoParty.relationship;
			}
			else
			{
				upsertRole.CMN_RelationshipToOwner__c = dtoParty.relationship;
			}
		}
		else if(consultantCode != null && CONSULTANT_ROLE.equals(dtoParty.role_type))
		{
			//TODO: Logic to be changed once we received consultant roles in the parties list
			upsertRole.CMN_ConsultantCode__c = consultantCode.Name;
			upsertRole.FinServ__RelatedContact__c = consultantCode.SC_ContactId__c;
			upsertRole.FinServ__Role__c = CONSULTANT_ROLE;
			upsertRole.SC_ConsultantCode__c = consultantCode.Id;
			upsertRole.SC_ConsultantStatus__c = consultantCode.SC_AgreementStatus__c ? INTERMEDIATE_POLICY : ORPHAN_POLICY;
		}
	}

	/**
	 * @description Method to get the Payer information to be stored on the policy
	 *
	 * @param dtoParties parties received via event
	 *
	 * @return return payer name if found else returns null
	 */
	private static String getPayerBankAccountName(List<DTO_Party> dtoParties)
	{
		if(dtoParties != null)
		{
			for(DTO_Party party : dtoParties)
			{
				if(PAYER_ROLE.equalsIgnoreCase(party.role_type))
				{
					return party.bank_acct_name;
				}
			}
		}

		return null;
	}

	/**
	 * @description Method to get the paid to date to be set on the policy
	 *
	 * @param paidToDate paid date and time received from the API
	 *
	 * @return return paid to date if not set to default value else return null
	 */
	private static Date getPaidToDate(Datetime paidToDate)
	{
		//adding this logic as EDP cannot send null when the paid to date is empty.
		return paidToDate != null ? paidToDate.date() != DEFAULT_DATE ? paidToDate.date() : null : null;
	}

	/**
	 * @description Populates and Inserts or Updates an insurance policy record from the contract in the event
	 *
	 * @param foundPolicy Insurance Policy record
	 * @param dtoRequest Contract from event
	 */
	@TestVisible
	private static void upsertInsurancePolicy(InsurancePolicy foundPolicy, DTO_ContractRequest dtoRequest)
	{
		if(foundPolicy == null)
		{
			foundPolicy = new InsurancePolicy();
			//TODO: This is a temporary solution assuming all the new policies are in In Force, will be changed when EDP sends the Status
			foundPolicy.Status = SC_UTIL_Contracts.STATUS_IN_FORCE;
		}

		foundPolicy.RecordTypeId = SC_DAL_InsurancePolicy.RT_INSURANCE_POLICY_ID;

		InsurancePolicy policy = populateInsurancePolicy(dtoRequest, foundPolicy);
		policy.CMN_BankAccountHolderName__c = getPayerBankAccountName(dtoRequest.parties);
		UNIT_OF_WORK.registerChange(policy);

		if(String.isNotBlank(policy.Id))
		{
			existingPolicyIds.add(policy.Id);
		}

		if(accountToLinkPolicy != null)
		{
			policy.NameInsuredId = accountToLinkPolicy.Id;
			policy.AW_MasterAccount__c = accountToLinkPolicy.AW_ParentAccount__c != null ? accountToLinkPolicy.AW_ParentAccount__c : accountToLinkPolicy.Id;
			policy.OwnerId = accountToLinkPolicy.OwnerId;
			UNIT_OF_WORK.registerRelationship(policy, InsurancePolicy.NameInsuredId, accountToLinkPolicy);
		}

		List<InsurancePolicyParticipant> existingParticipants = (List<InsurancePolicyParticipant>)existingPartyMap.get(foundPolicy.Id);

		if(existingParticipants != null)
		{
			for(InsurancePolicyParticipant existingParticipant : existingParticipants)
			{
				existingParticipant.IsActiveParticipant = false;
				UNIT_OF_WORK.registerChange(existingParticipant);
			}
		}

		if(dtoRequest.parties != null)
		{
			for(DTO_Party dtoParty : dtoRequest.parties)
			{
				if(String.isNotBlank(dtoParty.rel_party_firstname) || String.isNotBlank(dtoParty.rel_party_surname))
				{
					InsurancePolicyParticipant upsertParticipant = new InsurancePolicyParticipant();
					upsertParticipant.RecordTypeId = SC_DAL_InsurancePolicyParticipant.RT_LIBERTY_INSURANCE_POLICY_PARTICIPANT_ID;
					UNIT_OF_WORK.registerRelationship(upsertParticipant, InsurancePolicyParticipant.InsurancePolicyId, foundPolicy);

					populateInsurancePolicyParticipant(dtoParty, upsertParticipant);

					UNIT_OF_WORK.registerChange(upsertParticipant);

					if(upsertParticipant.RelatedParticipantContactId == null)
					{
						UNIT_OF_WORK.registerRelationship(upsertParticipant, InsurancePolicyParticipant.RelatedParticipantAccountId, accountToLinkPolicy);
					}
				}
				else
				{
					CMN_UTIL_Logger.info(String.format(SC_UTIL_Contracts.ERROR_ROLE_NOT_PROCESSED, new List<String> {dtoParty.role_type}), CONTRACT_SYNC_METHOD);
				}
			}
		}
	}

	/**
	 * @description Populates and Inserts or Updates a Financial Account record from the contract in the event
	 *
	 * @param upsertAccount Financial Account record
	 * @param dtoContractRequest Contract from event
	 * @param foundProductCode Product code
	 */
	@TestVisible
	private static void upsertFinancialAccount(FinServ__FinancialAccount__c upsertAccount, DTO_ContractRequest dtoContractRequest,
			AW_ProductCodeAndCategoryMapping__mdt foundProductCode)
	{
		if(upsertAccount == null)
		{
			upsertAccount = new FinServ__FinancialAccount__c();
			upsertAccount.FinServ__Status__c = SC_UTIL_Contracts.STATUS_IN_FORCE;
		}

		FinServ__FinancialAccount__c policy = populateFinancialAccount(dtoContractRequest, upsertAccount, foundProductCode);
		policy.CMN_BankAccountHolderName__c = getPayerBankAccountName(dtoContractRequest.parties);

		UNIT_OF_WORK.registerChange(policy);

		if(String.isNotBlank(policy.Id))
		{
			existingFinancialAccountIds.add(policy.Id);
		}

		if(accountToLinkPolicy != null)
		{
			upsertAccount.FinServ__PrimaryOwner__c = accountToLinkPolicy.Id;
			upsertAccount.AW_MasterAccount__c = accountToLinkPolicy.AW_ParentAccount__c != null ? accountToLinkPolicy.AW_ParentAccount__c : accountToLinkPolicy.Id;
			upsertAccount.OwnerId = accountToLinkPolicy.OwnerId;
			UNIT_OF_WORK.registerRelationship(upsertAccount, FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c, accountToLinkPolicy);
		}

		List<FinServ__FinancialAccountRole__c> existingRoles = (List<FinServ__FinancialAccountRole__c>)existingPartyMap.get(upsertAccount.Id);
		if(existingRoles != null)
		{
			for(FinServ__FinancialAccountRole__c existingRole : existingRoles)
			{
				if(existingRole.FinServ__Role__c != SC_DAL_FinancialAccountRole.PRIMARY_OWNER_ROLE)
				{
					existingRole.FinServ__Active__c = false;
					UNIT_OF_WORK.registerChange(existingRole);
				}
			}
		}

		if(dtoContractRequest.parties != null)
		{
			for(DTO_Party dtoParty : dtoContractRequest.parties)
			{
				if(String.isNotBlank(dtoParty.rel_party_firstname) || String.isNotBlank(dtoParty.rel_party_surname))
				{
					FinServ__FinancialAccountRole__c upsertRole = new FinServ__FinancialAccountRole__c();
					upsertRole.RecordTypeId = SC_DAL_FinancialAccountRole.RT_LIBERTY_FINANCIAL_ACCOUNT_ROLE_ID;
					UNIT_OF_WORK.registerRelationship(upsertRole, FinServ__FinancialAccountRole__c.FinServ__FinancialAccount__c, upsertAccount);

					populateFinancialAccountRole(dtoParty, upsertRole);

					UNIT_OF_WORK.registerChange(upsertRole);

					if(upsertRole.FinServ__RelatedContact__c == null)
					{
						UNIT_OF_WORK.registerRelationship(upsertRole, FinServ__FinancialAccountRole__c.FinServ__RelatedAccount__c, accountToLinkPolicy);
					}
				}
				else
				{
					CMN_UTIL_Logger.info(String.format(SC_UTIL_Contracts.ERROR_ROLE_NOT_PROCESSED, new List<String> {dtoParty.role_type}), CONTRACT_SYNC_METHOD);
				}
			}
		}
	}

	/**
	 * @description method used to insert Adviser Account
	 *
	 * @return foundAccount if adviser copy exists, it returns the same, else if consultant code exists in Salesforce,
	 * creates a new client and returns else return the master account
	 */
	private static Account initialiseAdviserOwnerAccount()
	{
		Account newAdviserAccount;

		User foundAdviser = masterAccount != null ? (User)USER_BY_CONSULTANT_CODE.get(consultantCode?.Name) : null;

		if(foundAdviser != null)
		{
			newAdviserAccount = new Account();

			String recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName
					(
							Account.SObjectType,
							masterAccount.IsPersonAccount ? AW_DAL_Account.RT_PERSON_ACCOUNT : AW_DAL_Account.RT_BUSINESS_ACCOUNT
					);

			newAdviserAccount.AW_BypassValidationRules__c = true;
			newAdviserAccount.AW_ParentAccount__c = masterAccount.Id;
			newAdviserAccount.AW_SKF_Id__c = masterAccount.AW_SKF_Id__c;
			newAdviserAccount.FinServ__Status__c = AW_DAL_Account.STATUS_ACTIVE;
			newAdviserAccount.OwnerId = foundAdviser.Id;
			newAdviserAccount.RecordTypeId = recordTypeId;

			Map<String, Schema.FieldSet> fieldSetMap = CMN_UTIL_SObjectDescribe.getDescribe(Account.SObjectType).getFieldSetsMap();

			if(!fieldSetMap.isEmpty())
			{
				String fieldSetName = masterAccount.IsPersonAccount ? AW_DAL_Account.FIELDSET_PERSON : AW_DAL_Account.FIELDSET_BUSINESS;

				FieldSet fieldsToUse = fieldSetMap.get(fieldSetName);

				if(fieldsToUse != null)
				{
					for(FieldSetMember fields : fieldsToUse.getFields())
					{
						newAdviserAccount.put(fields.getFieldPath(), masterAccount.get(fields.getFieldPath()));
					}
				}
			}

			NATIONAL_ID_TO_NON_MASTER_ACCOUNT_MAP.put(identityNumber + foundAdviser.AW_ConsultantCode__c, newAdviserAccount);

			UNIT_OF_WORK.registerNew(newAdviserAccount, Account.AW_ParentAccount__c, masterAccount);

			ACCOUNTS_TO_SYNCHRONISE.add(newAdviserAccount);
		}

		return newAdviserAccount;
	}

	/**
	 * @description The DTO used to parse a request sent via Platform Event
	 */
	@SuppressWarnings('PMD.FieldNamingConventions')
	public class DTO_ContractRequest extends CMN_DTO_JsonBase
	{
		/**
		 * @description PDB Id
		 */
		public String pdb_id;
		/**
		 * @description Client National Id
		 */
		public String client_national_id;
		/**
		 * @description Client Passport Number
		 */
		public String client_passport_no;
		/**
		 * @description Company Registration Number
		 */
		public String client_company_reg_no;
		/**
		 * @description Policy Number
		 */
		public String policy_number;
		/**
		 * @description Product Type
		 */
		public String product_type_code;
		/**
		 * @description Product Type Description
		 */
		@SuppressWarnings('ApexUnusedDeclaration')
		public String product_type_desc;
		/**
		 * @description Product prototype
		 */
		public String proto_cd;
		/**
		 * @description Status
		 */
		public String status;
		/**
		 * @description Status description
		 */
		public String status_desc;
		/**
		 * @description Consultant code
		 */
		public String consultant_code;
		/**
		 * @description Commencement Date
		 */
		public Datetime commencement_date;
		/**
		 * @description Premium Amount
		 */
		public Decimal premium_amt;
		/**
		 * @description Paid To Date
		 */
		public Datetime paidto_dt;
		/**
		 * @description Frequency
		 */
		public String frequency;
		/**
		 * @description Frequency description
		 */
		public String frequency_desc;
		/**
		 * @description List of Parties
		 */
		public List<DTO_Party> parties;

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_ContractRequest.class;
		}
	}

	/**
	 * @description The DTO used to represent a party associated with a contract
	 */
	@SuppressWarnings('PMD.FieldNamingConventions')
	public class DTO_Party
	{
		/**
		 * @description Role Type
		 */
		public String role_type;
		/**
		 * @description Title
		 */
		public String title;
		/**
		 * @description Related Party First name
		 */
		public String rel_party_firstname;
		/**
		 * @description Related Party Surname
		 */
		public String rel_party_surname;
		/**
		 * @description Related Party National Id
		 */
		public String rel_party_national_id;
		/**
		 * @description Related Party Passport Number
		 */
		public String rel_party_passport_no;
		/**
		 * @description Related Party Company Reg number
		 */
		public String rel_party_company_reg_no;
		/**
		 * @description Related Party Telephone Number
		 */
		public String rel_party_tel_no;
		/**
		 * @description Related Party Email
		 */
		public String rel_party_email;
		/**
		 * @description Relationship to entity
		 */
		public String relationship;
		/**
		 * @description Which entity is the party related to
		 */
		public String relatedto;
		/**
		 * @description Beneficiary percentage
		 */
		public String beneficiary_percentage;
		/**
		 * @description Bank account name
		 */
		public String bank_acct_name;
	}
}