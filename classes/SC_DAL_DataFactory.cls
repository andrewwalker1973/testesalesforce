/**
 * @description Service Common Factory to create test data.
 *
 * @author rajpal.singh@accenture.com, Vijay.jayswal@accenture.com
 *
 * @date April 2022, May 2023
 */
@SuppressWarnings('PMD.ApexCRUDViolation,PMD.CyclomaticComplexity,PMD.ExcessiveClassLength')
public without sharing class SC_DAL_DataFactory
{
	private static final Integer INT_2 = 2;
	private static final Integer INT_5 = 5;
	private static final Integer INT_FOUR = 4;
	private static final Integer INT_ONE = 1;
	private static final String CORE_GENDER_FEMALE = 'Female';
	private static final String PICK_RACE_WHITE = 'AW_White';
	@TestVisible
	private static final String WEEKLY_FREQUENCY = 'WEEKLY';
	@TestVisible
	private static final String CORRESPONDENCE_PREFERENCE = 'Postal';
	@TestVisible
	private static final String CONTACT_PREFERENCE = 'Mobile';
	@TestVisible
	private static final String COUNTRY_SOUTH_AFRICA = 'South Africa';
	@TestVisible
	private static final String INCOME_CATEGORY = '1';
	@TestVisible
	private static final String INCOME_TYPE = '2';
	@TestVisible
	private static final String OCCUPATION_INDUSTRY = '10';
	@TestVisible
	private static final String OCCUPATION_RISK_CATEGORY = '4';
	@TestVisible
	private static final String ORGANISATION_TYPE = 'COR';
	@TestVisible
	private static final String PLACE_OF_BIRTH = 'Johannesburg';
	@TestVisible
	private static final String SOURCE_OF_FUNDS = '5';
	@TestVisible
	private static final String SOURCE_OF_WEALTH = '3';
	@TestVisible
	private static final String TAX_PAYING_INDICATOR = 'Y';
	private static final Decimal ESTIMATED_DURATION_MINUTES = 60.0;
	@TestVisible
	private static final String DURATION_TYPE = 'Hours';

	/**
	 * @description Will create a Service Type Object
	 *
	 * @return newly created item (not committed)
	 */
	private static SC_ServiceType__c newServiceType()
	{
		SC_ServiceType__c newServiceType = new SC_ServiceType__c();

		newServiceType.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newServiceType.SC_ServiceType__c = CMN_DAL_SObjectDomain.generateRandomInteger(INT_FOUR);
		newServiceType.SC_Department__c = CMN_DAL_SObjectDomain.generateRandomName();

		return newServiceType;
	}

	/**
	 * @description Method to create and return the Service Type record with Assignable value
	 *
	 * @param numberOfRecords store the number of records
	 * @param isAssignable flag to indicate the service type is to be processed on Salesforce (and assigned to an agent)
	 *
	 * @return newly created items (committed)
	 */
	@TestVisible
	private static List<SC_ServiceType__c> createServiceTypesWithAssignableValue(Integer numberOfRecords, Boolean isAssignable)
	{
		List<SC_ServiceType__c> newServiceTypes = new List<SC_ServiceType__c>();

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			SC_ServiceType__c newServiceType = newServiceType();
			newServiceType.SC_Assignable__c = isAssignable;
			newServiceTypes.add(newServiceType);
		}

		insert newServiceTypes;

		return newServiceTypes;
	}

	/**
	 * @description Method to create and return the Service Type record
	 *
	 * @param numberOfRecords store the number of records
	 *
	 * @return newly created items (committed)
	 */
	@TestVisible
	private static List<SC_ServiceType__c> createServiceTypes(Integer numberOfRecords)
	{
		return createServiceTypesWithAssignableValue(numberOfRecords, false);
	}

	/**
	 * @description Will create and initialise a new Case Object
	 *
	 * @return newly created item (not committed)
	 */
	@TestVisible
	private static Case newCase()
	{
		Case newCase = new Case();

		newCase.Description = CMN_DAL_SObjectDomain.generateRandomName();
		newCase.Origin = SC_DAL_Case.PICK_ORIGIN;
		newCase.RSC_WorkflowCaseNumber__c = Decimal.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber());
		newCase.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Case.SObjectType, SC_DAL_Case.RT_RETAIL);
		newCase.Status = SC_DAL_Case.STATUS_IN_PROGRESS;
		newCase.Subject = CMN_DAL_SObjectDomain.generateRandomName();

		return newCase;
	}

	/**
	 * @description Will create and initialise a new Case Object
	 *
	 * @param accountId The account to which the case should be linked
	 *
	 * @return newly created item (not committed)
	 */
	@TestVisible
	private static Case newCase(Id accountId)
	{
		Case newCase = newCase();

		newCase.AccountId = accountId;
		newCase.SC_RequesterEmail__c = CMN_DAL_SObjectDomain.generateRandomEmail();

		return newCase;
	}

	/**
	 * @description Method to return the new Case related to Account
	 *
	 * @param numberOfRecords number of records to created
	 * @param accountId account to which to relate the cases
	 *
	 * @return newly created items (committed)
	 */
	@TestVisible
	private static List<Case> createCase(Integer numberOfRecords, Id accountId)
	{
		SC_ServiceType__c newType = createServiceTypes(INT_ONE).iterator().next();

		List<Case> cases = new List<Case>();

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			Case newCase = newCase(accountId);

			newCase.RSC_ServiceType__c = newType.Id;

			cases.add(newCase);
		}

		insert cases;

		return cases;
	}

	/**
	 * @description Method to return the new Case
	 *
	 * @param numberOfRecords number of records to create
	 *
	 * @return newly created items (committed)
	 */
	@TestVisible
	private static List<Case> createCase(Integer numberOfRecords)
	{
		List<Case> newCases = new List<Case>();

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			newCases.add(newCase());
		}

		insert newCases;

		return newCases;
	}

	/**
	 * @description Method to create and return the instance of Insurance Policy
	 *
	 * @param primaryOwner The Account to which the insurance policy should be linked
	 * @param numberOfPolicies Number of records to be created
	 *
	 * @return List of Insurance Policy
	 */
	public static List<InsurancePolicy> newInsurancePolicies(Account primaryOwner, Integer numberOfPolicies)
	{
		List<InsurancePolicy> newPolicies = new List<InsurancePolicy>();

		for(Integer i = 1; i <= numberOfPolicies; i++)
		{
			InsurancePolicy newPolicy = new InsurancePolicy();

			newPolicy.AW_AUMSourceExternalId__c = CMN_DAL_SObjectDomain.generateRandomNumber(6);
			newPolicy.AW_CurrentValue__c = Decimal.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger());
			newPolicy.Name = CMN_DAL_SObjectDomain.generateRandomNumber();
			newPolicy.NameInsuredId = primaryOwner.Id;
			newPolicy.RecordTypeId = SC_DAL_InsurancePolicy.RT_INSURANCE_POLICY_ID;
			if(primaryOwner.AW_ParentAccount__c != null)
			{
				newPolicy.AW_MasterAccount__c = primaryOwner.AW_ParentAccount__c;
			}

			newPolicies.add(newPolicy);
		}

		return newPolicies;
	}

	/**
	 * @description Method to create and return the record of Insurance Policy (Scenario1)
	 *
	 * @param primaryOwner The Account to which the insurance policy should be linked
	 * @param numberOfPolicies Number of records to be created
	 *
	 * @return List of Insurance Policy
	 */
	public static List<InsurancePolicy> createInsurancePolicies(Account primaryOwner, Integer numberOfPolicies)
	{
		List<InsurancePolicy> newPolicies = newInsurancePolicies(primaryOwner, numberOfPolicies);
		insert newPolicies;
		return newPolicies;
	}

	/**
	 * @description Method to create and return the instance List of Financial Account
	 *
	 * @param primaryOwner The account against to which financial account should be linked
	 * @param numberOfFinancialAccounts Number of records to be created
	 *
	 * @return List of Financial Account
	 */
	public static List<FinServ__FinancialAccount__c> newFinancialAccounts(Account primaryOwner, Integer numberOfFinancialAccounts)
	{
		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(FinServ__FinancialAccount__c.SObjectType, 
			AW_DAL_FinancialAccount.RT_INVESTMENT_ACCOUNT);

		List<FinServ__FinancialAccount__c> newFinancialAccounts = new List<FinServ__FinancialAccount__c>();

		for(Integer i = 0; i <= numberOfFinancialAccounts - 1; i++)
		{
			FinServ__FinancialAccount__c newAccount = new FinServ__FinancialAccount__c();

			newAccount.AW_AUMSourceExternalId__c = String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger(6));
			newAccount.AW_ValueAsAt__c = CMN_DAL_SObjectDomain.generateRandomDateTime();
			newAccount.FinServ__FinancialAccountNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
			newAccount.FinServ__FinancialAccountType__c = CMN_DAL_SObjectDomain.generateRandomName();
			newAccount.FinServ__HeldAway__c = false;
			newAccount.FinServ__PrimaryOwner__c = primaryOwner.Id;
			newAccount.Name = CMN_DAL_SObjectDomain.generateRandomName();
			newAccount.RecordTypeId = recordTypeId;
			if(primaryOwner.AW_ParentAccount__c != null)
			{
				newAccount.AW_MasterAccount__c = primaryOwner.AW_ParentAccount__c;
			}

			newFinancialAccounts.add(newAccount);
		}

        return newFinancialAccounts;

	}

	/**
	 * @description Method to create and return the List of Financial Account
	 *
	 * @param primaryOwner The account against to which financial account should be linked
	 * @param numberOfFinancialAccounts Number of records to be created
	 *
	 * @return List of Financial Account
	 */
	public static List<FinServ__FinancialAccount__c> createFinancialAccounts(Account primaryOwner, Integer numberOfFinancialAccounts)
	{
		List<FinServ__FinancialAccount__c> financialAccounts = newFinancialAccounts(primaryOwner, numberOfFinancialAccounts);
		insert financialAccounts;
		return financialAccounts;
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
    @TestVisible
    private static List<SC_AssociatedContract__c> insertAssociatedContracts(Id caseId, Integer numberOfRecords, Id financialAccountId, Id insurancePolicyId)
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

        insert newContracts;

        return newContracts;
    }

    /**
     * @description Method to return the new Case related to Account
     *
     * @param numberOfRecords store the number of records
     * @param accountId store the parent account Id
     *
     * @return created items
     */
    @TestVisible
    private static List<InsurancePolicy> createInsurancePolicies(Integer numberOfRecords, Id accountId)
    {
        List<InsurancePolicy> newPolicies = new List<InsurancePolicy>();

        for(Integer i = 0; i < numberOfRecords; i++)
        {
			InsurancePolicy newPolicy = AW_DAL_TestDataFactory.newInsurancePolicy(accountId, SC_DAL_InsurancePolicy.RT_INSURANCE_POLICY_ID);

            newPolicy.AW_CommencementDate__c = CMN_DAL_SObjectDomain.generateRandomDate();
            newPolicy.PolicyType = SC_DAL_InsurancePolicy.TYPE_HOME;
            newPolicy.PremiumAmount = Decimal.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber());
            newPolicy.Status = SC_DAL_InsurancePolicy.STATUS_IN_FORCE;

            newPolicies.add(newPolicy);
        }

        insert newPolicies;

        return newPolicies;
    }

    /**
	 * @description Method to create document check list item
     *
     * @param parentId The parent object against which the check list items should be created
     * @param numberOfRecords store the number of records
     *
	 * @return List of Document Check List Items that are created
	 */
	@TestVisible
	private static List<DocumentChecklistItem> newDocumentCheckListItems(Id parentId, Integer numberOfRecords)
    {
        List<DocumentChecklistItem> documentChecklistItems = new List<DocumentChecklistItem>();

        Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(DocumentChecklistItem.SObjectType, SC_DAL_DocumentChecklistItem.RT_CASE_DOCUMENT);

        for(Integer i = 0; i < numberOfRecords; i++)
        {
            DocumentChecklistItem newListItem = new DocumentChecklistItem();

            DocumentType docType = SC_DAL_DocumentType.findRandomActive();

			newListItem.Name = docType?.MasterLabel;
			newListItem.AW_DateVaulted__c = System.today();
			newListItem.AW_Vaulted__c = true;
			newListItem.CMN_VaultedId__c = CMN_DAL_SObjectDomain.generateRandomNumber();
			newListItem.DocumentTypeId = docType?.Id;
            newListItem.ParentRecordId = parentId;
            newListItem.RecordTypeId = recordTypeId;
            newListItem.Status = SC_DAL_DocumentChecklistItem.STATUS_NEW;

            documentChecklistItems.add(newListItem);
        }

		return documentChecklistItems;
	}

	/**
	 * @description Method to create and return document check list item
	 *
	 * @param parentId The parent object against which the check list items should be created
	 * @param numberOfRecords store the number of records
	 *
	 * @return List of Document Check List Items that are inserted
	 */
	@TestVisible
	private static List<DocumentChecklistItem> insertDocumentCheckListItems(Id parentId, Integer numberOfRecords)
	{
		List<DocumentChecklistItem> documentChecklistItems = newDocumentCheckListItems(parentId, numberOfRecords);
        insert documentChecklistItems;
        return documentChecklistItems;
    } 

	/**
	 * @description Method to create an instance of knowledge article
	 *
	 * @param numberOfRecords store the number of records
	 *
	 * @return List of instance Knowledge article that is created
	 */
	@TestVisible
	private static List<Knowledge__kav> newKnowledgeArticles(Integer numberOfRecords)
	{
		List<Knowledge__kav> knowledgeArticles = new List<Knowledge__kav>();

		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Knowledge__kav.SObjectType, SC_DAL_Knowledge.RT_RETAIL_AGENT_SCRIPT);

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			Knowledge__kav newKnowledgeArticle = new Knowledge__kav();

			newKnowledgeArticle.Title = CMN_DAL_SObjectDomain.generateRandomName();
			newKnowledgeArticle.UrlName = CMN_DAL_SObjectDomain.generateRandomName();
			newKnowledgeArticle.AW_Text__c = CMN_DAL_SObjectDomain.generateRandomDescription();
			newKnowledgeArticle.RecordTypeId = recordTypeId;

			knowledgeArticles.add(newKnowledgeArticle);
		}

		return knowledgeArticles;
	}

	/**
	 * @description Method to create and return knowledge articles
	 *
	 * @param numberOfRecords store the number of records
	 *
	 * @return List of Knowledge Articles that are inserted
	 */
	@TestVisible
	private static List<Knowledge__kav> insertKnowledgeArticles(Integer numberOfRecords)
	{
		List<Knowledge__kav> knowledgeArticles = newKnowledgeArticles(numberOfRecords);
		insert knowledgeArticles;
		return knowledgeArticles;
	}

	/**
	 * @description Method to create an instance of case extension
	 *
	 * @param numberOfRecords store the number of records
	 *
	 * @return List of created instances of Case Extension
	 */
	@TestVisible
	private static List<SC_CaseExtension__c> newCaseExtensions(Integer numberOfRecords)
	{
		List<SC_CaseExtension__c> caseExtensions = new List<SC_CaseExtension__c>();

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			SC_CaseExtension__c caseExtension = new SC_CaseExtension__c();
			caseExtension.SC_CaseRecordType__c = SC_DAL_Case.RT_RETAIL;
			caseExtensions.add(caseExtension);
		}

		return caseExtensions;
	}

	/**
	 * @description Method to create and return case extension records
	 *
	 * @param numberOfRecords store the number of records
	 *
	 * @return List of Case Extension records that are inserted
	 */
	@TestVisible
	private static List<SC_CaseExtension__c> insertCaseExtensions(Integer numberOfRecords)
	{
		List<SC_CaseExtension__c> caseExtensions = newCaseExtensions(numberOfRecords);
		insert caseExtensions;
		return caseExtensions;
	}

	/**
	 * @description Method to create an instance of contract extension
	 *
	 * @param numberOfRecords The number of records to be created
	 *
	 * @return List of associated contract extension instances
	 */
	@TestVisible
	private static List<SC_AssociatedContractExtension__c> newAssociatedContractExtensions(Integer numberOfRecords)
	{
		List<SC_AssociatedContractExtension__c> contractExtensions = new List<SC_AssociatedContractExtension__c>();

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			SC_AssociatedContractExtension__c contractExtension = new SC_AssociatedContractExtension__c();
			contractExtension.SC_CaseRecordType__c = SC_DAL_Case.RT_RETAIL;
			contractExtension.RSC_PolicyNumber__c = String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger(INT_5));
			contractExtensions.add(contractExtension);
		}

		return contractExtensions;
	}

	/**
	 * @description Method to create and return associated contract extension records
	 *
	 * @param numberOfRecords The the number of records to be created
	 *
	 * @return List of Associated Contract Extension records
	 */
	@TestVisible
	private static List<SC_AssociatedContractExtension__c> insertAssociatedContractExtensions(Integer numberOfRecords)
	{
		List<SC_AssociatedContractExtension__c> contractExtensions = newAssociatedContractExtensions(numberOfRecords);
		insert contractExtensions;
		return contractExtensions;
	}

	/**
	 * @description method to create and link financial account to master account
	 *
	 * @param isMasterIndividual flag to indicate to link Financial Account to Master Person or Master Individual Account
	 *
	 * @return new Financial Account
	 */
	public static FinServ__FinancialAccount__c linkFinancialAccountToMasterAccount(Boolean isMasterIndividual)
	{
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork();
		unitOfWork.addSObjectTypes(new List<Schema.SObjectType>
		{
				Account.SObjectType, FinServ__FinancialAccount__c.SObjectType
		});

		Account masterAccount = newActiveMasterAccount(isMasterIndividual);
		unitOfWork.registerChange(masterAccount);

		FinServ__FinancialAccount__c newFinancialAccount = AW_DAL_TestDataFactory.newFinancialAccount(
				masterAccount, CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(FinServ__FinancialAccount__c.SObjectType,
						AW_DAL_FinancialAccount.RT_INVESTMENT_ACCOUNT));
		newFinancialAccount.AW_MasterAccount__c = masterAccount.Id;

		unitOfWork.registerNew(newFinancialAccount, FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c, masterAccount);
		unitOfWork.registerRelationship(newFinancialAccount, FinServ__FinancialAccount__c.AW_MasterAccount__c, masterAccount);
		unitOfWork.commitWork();

		return newFinancialAccount;
	}

	/**
	 * @description method to create and link Insurance Policy to master account
	 *
	 * @param isMasterIndividual flag to indicate to link Financial Account to Master Person or Master Individual Account
	 *
	 * @return new InsurancePolicy
	 */
	public static InsurancePolicy linkInsurancePolicyToMasterAccount(Boolean isMasterIndividual)
	{
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork();
		unitOfWork.addSObjectTypes(new List<Schema.SObjectType>
		{
				Account.SObjectType, InsurancePolicy.SObjectType
		});

		Account masterAccount = newActiveMasterAccount(isMasterIndividual);
		unitOfWork.registerChange(masterAccount);

		InsurancePolicy newPolicy = AW_DAL_TestDataFactory.newInsurancePolicy(masterAccount.Id, SC_DAL_InsurancePolicy.RT_INSURANCE_POLICY_ID);
		newPolicy.AW_MasterAccount__c = masterAccount.Id;

		unitOfWork.registerNew(newPolicy, InsurancePolicy.NameInsuredId, masterAccount);
		unitOfWork.registerRelationship(newPolicy, InsurancePolicy.AW_MasterAccount__c, masterAccount);
		unitOfWork.commitWork();

		return newPolicy;
	}

	/**
	 * @description method to create instance of either Person or Business Master Account
	 *
	 * @param isMasterIndividual flag to indicate to link Financial Account to Master Person or Master Individual Account
	 *
	 * @return new Active Account
	 */
	private static Account newActiveMasterAccount(Boolean isMasterIndividual)
	{
		Account masterAccount = isMasterIndividual ? AW_DAL_TestDataFactory.newPersonAccount(AW_DAL_Account.RT_PERSON_MASTER_ACCOUNT,
				AW_UTIL_IdentityNumber.generateRandomIdentityNumber()) :
				AW_DAL_TestDataFactory.newBusinessAccount(AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT);

		masterAccount.FinServ__Status__c = AW_DAL_Account.STATUS_ACTIVE;

		return masterAccount;
	}
	
	/**
	 * @description Assigns a product code to a ContractRequest based on an object api name
	 *
	 * @param dtoRequest Contract request to populate
	 * @param objectName Object Api Name
	 */
	@TestVisible
	private static void assignRandomProductCode(SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest, String objectName)
	{
		AW_ProductCodeAndCategoryMapping__mdt foundMapping = AW_DAL_ProductCodeAndCategoryMapping.findRandomByObjectName(objectName);

		dtoRequest.product_type_code = foundMapping?.AW_ProductCode__c;
		dtoRequest.proto_cd = foundMapping?.AW_Prototype__c;
	}

	/**
	 * @description method to generate party related to policy
	 *
	 * @return single party
	 */
	@TestVisible
	private static SC_FLOW_SynchroniseContracts.DTO_Party generateParty()
	{
		SC_FLOW_SynchroniseContracts.DTO_Party dtoParty = new SC_FLOW_SynchroniseContracts.DTO_Party();

		dtoParty.rel_party_surname = CMN_DAL_SObjectDomain.generateRandomName();
		dtoParty.rel_party_firstname = CMN_DAL_SObjectDomain.generateRandomName();
		dtoParty.rel_party_email = CMN_DAL_SObjectDomain.generateRandomEmail();
		dtoParty.rel_party_tel_no = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		dtoParty.rel_party_national_id = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
		dtoParty.rel_party_passport_no = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
		dtoParty.role_type = SC_DAL_InsurancePolicyParticipant.ROLE_BENEFICIARY;

		return dtoParty;
	}

	/**
	 * @description method to generate multiple parties to a Policy
	 *
	 * @param numberOfParties indicates the number of parties to be related to Policy
	 *
	 * @return multiple parties
	 */
	@TestVisible
	private static List<SC_FLOW_SynchroniseContracts.DTO_Party> generateParties(Integer numberOfParties)
	{
		List<SC_FLOW_SynchroniseContracts.DTO_Party> dtoParties = new List<SC_FLOW_SynchroniseContracts.DTO_Party>();

		for(Integer i = 0; i < numberOfParties; i++)
		{
			dtoParties.add(generateParty());
		}

		return dtoParties;
	}

	/**
	 * @description method to generate the DTO request related to Master Account with Parties
	 *
	 * @param isPerson flag to identify to relate Person or Business account
	 * @param usePassport flag to identify to relate Passport number
	 * @param objectName name of the object for the policy i.e financial account/insurance policy
	 * @param numberOfParties number of parties to be related to policy
	 *
	 * @return dto request with policies and parties
	 */
	@TestVisible
	private static SC_FLOW_SynchroniseContracts.DTO_ContractRequest generateMasterDtoRequestWithParties(Boolean isPerson, Boolean usePassport,
			String objectName, Integer numberOfParties)
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoContractRequest = generateMasterDtoRequest(isPerson, usePassport, objectName);
		List<SC_FLOW_SynchroniseContracts.DTO_Party> parties = generateParties(numberOfParties);
		dtoContractRequest.parties = parties;
		return dtoContractRequest;
	}

	/**
	 * @description Generates a DTO request for a master account
	 *
	 * @param isPerson Boolean to indicate whether to use a person account or business account
	 * @param usePassport Boolean to indicate whether to use a passport number or an SA Id
	 * @param objectName Object API name to decide if it is a Insurance Policy or Financial Account
	 *
	 * @return DTO_ContractRequest
	 */
	@TestVisible
	private static SC_FLOW_SynchroniseContracts.DTO_ContractRequest generateMasterDtoRequest(Boolean isPerson, Boolean usePassport, String objectName)
	{
		return generateDtoRequest(isPerson, usePassport, objectName, true);
	}

	/**
	 * @description Generate Contract request for a Master Person account using SA Id
	 *
	 * @param numberOfRecords Number of contract requests to generate
	 * @param objectName Object API Name
	 *
	 * @return List SC_FLOW_SynchroniseContracts.DTO_ContractRequest
	 */
	@TestVisible
	private static List<SC_FLOW_SynchroniseContracts.DTO_ContractRequest> generateMasterPersonIdDtoRequests(Integer numberOfRecords, String objectName)
	{
		List<SC_FLOW_SynchroniseContracts.DTO_ContractRequest> dtoRequests = new List<SC_FLOW_SynchroniseContracts.DTO_ContractRequest>();

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			dtoRequests.add(generateMasterDtoRequest(true, false, objectName));
		}

		return dtoRequests;
	}

	/**
	 * @description Generates a DTO request for a non master account
	 *
	 * @param isPerson Boolean to indicate whether to use a person account or business account
	 * @param usePassport Boolean to indicate whether to use a passport number or an SA Id
	 * @param objectName Object API name to decide if it is a Insurance Policy or Financial Account
	 *
	 * @return DTO_ContractRequest
	 */
	@TestVisible
	private static SC_FLOW_SynchroniseContracts.DTO_ContractRequest generateNonMasterDtoRequest(Boolean isPerson, Boolean usePassport, String objectName)
	{
		return generateDtoRequest(isPerson, usePassport, objectName, false);
	}

	/**
	 * @description Generates a DTO request
	 *
	 * @param isPerson Boolean to indicate whether to use a person account or business account
	 * @param usePassport Boolean to indicate whether to use a passport number or an SA Id
	 * @param objectName Object API name to decide if it is a Insurance Policy or Financial Account
	 * @param useMaster Boolean to indicate whether to create a master record type
	 *
	 * @return DTO_ContractRequest
	 */
	@TestVisible
	private static SC_FLOW_SynchroniseContracts.DTO_ContractRequest generateDtoRequest(Boolean isPerson, Boolean usePassport,
			String objectName, Boolean useMaster)
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoRequest;
		Account newAccount;

		if(isPerson)
		{
			if(useMaster)
			{
				newAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
			}
			else
			{
				newAccount = AW_DAL_TestDataFactory.createPersonChildAccountWithMaster();
			}

			dtoRequest = createDtoPersonContractRequest(usePassport);
			if(usePassport)
			{
				dtoRequest.client_passport_no = newAccount.AW_IdentificationNumber__pc;
			}
			else
			{
				dtoRequest.client_national_id = newAccount.AW_IdentificationNumber__pc;
			}
		}
		else
		{
			if(useMaster)
			{
				newAccount = AW_DAL_TestDataFactory.createBusinessAccounts(AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT, 1).iterator().next();
			}
			else
			{
				newAccount = AW_DAL_TestDataFactory.createBusinessChildAccountWithMaster();
			}

			dtoRequest = createDtoBusinessContractRequest();
			dtoRequest.client_company_reg_no = newAccount.AW_CompanyRegistrationTrustNumber__c;
		}

		assignRandomProductCode(dtoRequest, objectName);

		if(SC_DAL_FinancialAccount.OBJECT_NAME.equalsIgnoreCase(objectName))
		{
			dtoRequest.frequency = WEEKLY_FREQUENCY;
		}

		return dtoRequest;
	}

	/**
	 * @description Will generate Contract Request Data Transfer Objects
	 *
	 * @return List of items
	 */
	@TestVisible
	private static SC_FLOW_SynchroniseContracts.DTO_ContractRequest createDtoContractRequest()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoContractRequest = new SC_FLOW_SynchroniseContracts.DTO_ContractRequest();

		dtoContractRequest.pdb_id = CMN_UTIL_Random.randomUUID();
		dtoContractRequest.policy_number = CMN_DAL_SObjectDomain.generateRandomNumber();
		dtoContractRequest.status = SC_DAL_InsurancePolicy.STATUS_IN_FORCE;
		dtoContractRequest.commencement_date = CMN_DAL_SObjectDomain.generateRandomDateTime();
		dtoContractRequest.premium_amt = CMN_DAL_SObjectDomain.generateRandomDecimal();
		dtoContractRequest.paidto_dt = CMN_DAL_SObjectDomain.generateRandomDateTime();
		dtoContractRequest.frequency = CMN_DAL_SObjectDomain.generateRandomName();
		dtoContractRequest.consultant_code = CMN_DAL_SObjectDomain.generateRandomNumber();

		return dtoContractRequest;
	}

	/**
	 * @description Will generate Contract Request Data Transfer Objects
	 *
	 * @param usePassport Indicates if passport is used instead of Id number
	 *
	 * @return List of items
	 */
	@TestVisible
	private static SC_FLOW_SynchroniseContracts.DTO_ContractRequest createDtoPersonContractRequest(Boolean usePassport)
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoContractRequest = createDtoContractRequest();

		if(usePassport)
		{
			dtoContractRequest.client_passport_no = CMN_DAL_SObjectDomain.generateRandomNumber();
		}
		else
		{
			dtoContractRequest.client_national_id = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
		}

		return dtoContractRequest;
	}

	/**
	 * @description Will generate Contract Request Data Transfer Objects
	 *
	 * @return List of items
	 */
	@TestVisible
	private static SC_FLOW_SynchroniseContracts.DTO_ContractRequest createDtoBusinessContractRequest()
	{
		SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoContractRequest = createDtoContractRequest();
		dtoContractRequest.client_company_reg_no = CMN_DAL_SObjectDomain.generateRandomNumber();
		return dtoContractRequest;
	}

	/**
	 * @description method to generate the platform event for the contracts received via EDP
	 *
	 * @param dtoRequests contains all the requests received from the event
	 *
	 * @return List of items
	 */
	@TestVisible
	private static List<RSC_ContractEvent__e> generateContractEvents(List<SC_FLOW_SynchroniseContracts.DTO_ContractRequest> dtoRequests)
	{
		List<RSC_ContractEvent__e> contractEvents = new List<RSC_ContractEvent__e>();

		for(SC_FLOW_SynchroniseContracts.DTO_ContractRequest dtoContractRequest : dtoRequests)
		{
			contractEvents.add(new RSC_ContractEvent__e(RSC_ContractData__c = JSON.serialize(dtoContractRequest)));
		}

		return contractEvents;
	}
	
	/**
	 * @description This method will create the Consultant Codes
	 *
	 * @return consultant Code
	 */
	public static SC_ConsultantCodes__c createConsultantCodes()
	{
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork();
		unitOfWork.addSObjectTypes(new List<Schema.SObjectType>
		{
				Account.SObjectType, Contact.SObjectType, SC_ConsultantCodes__c.SObjectType
		});

		Account practiceAccount = RSC_DAL_TestDataFactory.newPracticeAccounts(SC_DAL_Account.RT_PRACTICE, INT_ONE).iterator().next();
		practiceAccount.Name = SC_DAL_Account.ACTIVE_ADVISER_ACCOUNT;
		unitOfWork.registerChange(practiceAccount);

		Contact newContact = RSC_DAL_TestDataFactory.newPracticeContacts(SC_DAL_Contact.RT_ADVISER, INT_ONE, practiceAccount).iterator().next();
		unitOfWork.registerNew(newContact, Contact.AccountId, practiceAccount);

		SC_ConsultantCodes__c newConsultantCode = RSC_DAL_TestDataFactory.newConsultantCodeRecords(newContact.Id, INT_ONE, true).iterator().next();
		unitOfWork.registerNew(newConsultantCode, SC_ConsultantCodes__c.SC_ContactId__c, newContact);

		unitOfWork.commitWork();
		return newConsultantCode;
	}

	/**
	 * @description This method will create the Consultant Codes
	 *
	 * @param activeAdviserConsultantCode A consultant code that's active
	 *
	 * @return consultant Code
	 */
	public static SC_ConsultantCodes__c createConsultantCodesForExistingUser(String activeAdviserConsultantCode)
	{
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork();
		unitOfWork.addSObjectTypes(new List<Schema.SObjectType>
		{
				Account.SObjectType, Contact.SObjectType, SC_ConsultantCodes__c.SObjectType
		});

		Account practiceAccount = RSC_DAL_TestDataFactory.newPracticeAccounts(SC_DAL_Account.RT_PRACTICE, INT_ONE).iterator().next();
		practiceAccount.Name = SC_DAL_Account.ACTIVE_ADVISER_ACCOUNT;
		unitOfWork.registerChange(practiceAccount);

		Contact newContact = RSC_DAL_TestDataFactory.newPracticeContacts(SC_DAL_Contact.RT_ADVISER, INT_ONE, practiceAccount).iterator().next();
		unitOfWork.registerNew(newContact, Contact.AccountId, practiceAccount);

		SC_ConsultantCodes__c newConsultantCode = RSC_DAL_TestDataFactory.newConsultantCodeRecords(newContact.Id, INT_ONE, true).iterator().next();
		newConsultantCode.Name = activeAdviserConsultantCode;
		unitOfWork.registerNew(newConsultantCode, SC_ConsultantCodes__c.SC_ContactId__c, newContact);

		unitOfWork.commitWork();
		return newConsultantCode;
	}

	/**
	 * @description Method to return the new WorkOrders with caseId
	 *
	 * @param caseId The related case
	 * @param ownerId Contains the Id of the owner to whom the WorkOrder has to be assigned
	 * @param numberOfRecords Number of WorkOrder records to be created
	 *
	 * @return list of WorkOrder records created
	 */
	public static List<WorkOrder> createWorkOrder(Id caseId, Id ownerId, Integer numberOfRecords)
	{
		List<WorkOrder> newWorkOrders = new List<WorkOrder>();
		for(Integer i = 1; i <= numberOfRecords; i++)
		{
			WorkOrder newWorkOrder = new WorkOrder();
			newWorkOrder.CaseId = caseId;
			newWorkOrder.OwnerId = ownerId;
			newWorkOrders.add(newWorkOrder);
		}
		insert newWorkOrders;
		return newWorkOrders;
	}
	/**
	 * @description Method to return the new WorkOrderLineItem with caseId
	 *
	 * @param workOrderId The related WorkOrder
	 * @param numberOfRecords Number of WorkOrderLineItem records to be created
	 *
	 * @return list of WorkOrderLineItem records created
	 */
	public static List<WorkOrderLineItem> createWorkOrderLineItem(Id workOrderId, Integer numberOfRecords)
	{
		List<WorkOrderLineItem> newWorkOrdersLineItems = new List<WorkOrderLineItem>();

		for(Integer i = 1; i <= numberOfRecords; i++)
		{
			WorkOrderLineItem newWorkOrderLineItem = new WorkOrderLineItem();
			newWorkOrderLineItem.WorkOrderId = workOrderId;
			newWorkOrdersLineItems.add(newWorkOrderLineItem);
		}

		insert newWorkOrdersLineItems;
		return newWorkOrdersLineItems;
	}
	/**
	 * @description Method to return the new WorkType with caseId
	 *
	 * @return list of WorkType records created
	 */
	public static List<WorkType> createWorkType()
	{
		return createWorkType(INT_ONE);
	}
	/**
	 * @description Method to return the new WorkType with caseId
	 *
	 * @param numberOfRecords Number of records to be created
	 *
	 * @return list of WorkType records created
	 */
	public static List<WorkType> createWorkType(Integer numberOfRecords)
	{
		List<WorkType> newWorkTypes = new List<WorkType>();
		for(Integer i = 0; i < numberOfRecords; i++)
		{
			WorkType newWorkType = new WorkType();

			newWorkType.DurationType = DURATION_TYPE;
			newWorkType.EstimatedDuration = ESTIMATED_DURATION_MINUTES;
			newWorkType.Name = CMN_DAL_SObjectDomain.generateRandomName();

			newWorkTypes.add(newWorkType);
		}
		insert newWorkTypes;
		return newWorkTypes;
	}
}