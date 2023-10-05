/**
 * @description Factory to create test data.
 *
 * @author kiran.kumaryelisetti@lntinfotech.com, vishakha.saini@accenture.com
 *
 * @date 2019, March 2023
 */
@SuppressWarnings('PMD.ApexCRUDViolation,PMD.CognitiveComplexity,PMD.CyclomaticComplexity,PMD.ExcessivePublicCount')
@IsTest(SeeAllData=false)
public without sharing class AW_DAL_TestDataFactory
{
	private static Id southAfricaCountryId;
	private static final Integer INT_FOUR = 4;
	private static final Integer INT_ONE = 1;
	private static final Integer INT_SIX = 6;
	private static final Integer LUMP_SUM_AMOUNT = 150;
	private static final Integer NUM_OCCUPATIONS_TO_CREATE = 5;
	private static final Integer PREMIUM_AMOUNT = 200;
	private static final Integer TERM_MONTH = 5;
	private static final List<AW_Country__c> TEST_COUNTRIES = new List<AW_Country__c>();
	private static final List<AW_Occupation__c> TEST_OCCUPATIONS = new List<AW_Occupation__c>();
	private static final String BUSINESS_TYPE = 'Company';
	private static final String EMAIL_USAGE = 'Business';
	/**
	 * @description Error message for deprecated methods
	 *
	 * @deprecated Needs to be deleted once all references of this property are removed.
	 */
	private static final String ERROR_DEPRECATED = 'This is a deprecated method, use another method. If using, it should only be used with numberOfRecords=1.';
	private static final String GROWTH_STRATEGY = '3';
	private static final String PREMIUM_FREQUENCY = 'Annually';
	private static final String DOCUMENT_CHECKLIST_NAME = 'Test Checklist';

	@TestVisible
	private static final String CONTACT_PREFERENCE = 'Mobile';
	@TestVisible
	private static final String CORRESPONDENCE_PREFERENCE = 'Postal';
	@TestVisible
	private static final String MOBILE_USAGE = 'Business';
	@TestVisible
	private static final String PHONE_USAGE = 'Business';

	private static final List<TestAddress> TEST_ADDRESSES = new List<TestAddress>();

	/**
	 * @description Race of Client - Temporarily left here for backward compatibility on higher environments.
	 *
	 * @deprecated Needs to be deleted once all references of this property are removed.
	 */
	@SuppressWarnings('ApexUnusedDeclaration')
	@TestVisible
	private static final String RACE = 'AW_White';
	@TestVisible
	private static final String PICK_RACE_WHITE = 'AW_White';
	@TestVisible
	private static final String PRIMARY_LANGUAGE = 'English';

	/**
	 * @description Method to return the user created in createCommunityUser method
	 *
	 * @return User
	 */
	public static User newCommunityUser()
	{
		Account communityUserAccount = createClientAccount().iterator().next();
		communityUserAccount = AW_DAL_Account.findById(communityUserAccount.Id);
		User newUser = AW_DAL_User.newCommunityUser(communityUserAccount);
		return newUser;
	}

	/**
	 * @description Creates a new committed Community User
	 *
	 * @return newly created user
	 */
	public static User createCommunityUser()
	{
		User newUser = newCommunityUser();

		insert newUser;

		return newUser;
	}

	/**
	 * @description Will create an initialise a new Lead
	 *
	 * @return new item (not committed)
	 */
	public static Lead newLead()
	{
		Lead lead = new Lead();
		lead.LastName = CMN_DAL_SObjectDomain.generateRandomName();

		return lead;
	}

	/**
	 * @description Method to return the List of leads (Scenario 1)
	 *
	 * @param recordTypeDevName Developer name of the record type
	 * @param numberOfLeads Number of records to be created
	 * @param leadOwnerId Owner Id of Lead
	 *
	 * @return List of Leads
	 */
	public static List<Lead> createLeads(String recordTypeDevName, Integer numberOfLeads, Id leadOwnerId)
	{
		return createLeads(recordTypeDevName, numberOfLeads, leadOwnerId, AW_DAL_Lead.IDENTIFICATION_TYPE_SA_ID);
	}

	/**
	 * @description Method to create and return the List of leads (Scenario 2)
	 *
	 * @param recordTypeDevName Developer name of the record type
	 * @param numberOfLeads Number of records to be created
	 * @param leadOwnerId Owner Id of Lead
	 * @param identityType Identity Type
	 *
	 * @return List of Leads
	 */
	public static List<Lead> createLeads(String recordTypeDevName, Integer numberOfLeads, Id leadOwnerId, String identityType)
	{
		List<Lead> newLeads = new List<Lead>();

		Integer addressIndex = 0;

		loadAddresses();

		for(Integer i = 1; i <= numberOfLeads; i++)
		{
			Lead newLead = new Lead();

			newLead.FirstName = CMN_DAL_SObjectDomain.generateRandomName();
			newLead.LastName = CMN_DAL_SObjectDomain.generateRandomName();
			newLead.MobilePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
			newLead.AW_MaritalStatus__c = AW_DAL_Lead.MARTIAL_STATUS_MARRIED;
			newLead.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Lead.SObjectType, recordTypeDevName);

			TestAddress testAddress = getTestAddress();

			newLead.Street = testAddress.street;
			newLead.City = testAddress.city;
			newLead.State = testAddress.state;
			newLead.PostalCode = testAddress.postalCode;

			newLead.Country = testAddress.country;
			newLead.Latitude = testAddress.latitude;
			newLead.Longitude = testAddress.longitude;
			newLead.AW_IdentificationType__c = identityType;

			if(String.isNotBlank(identityType))
			{
				newLead.AW_IdentificationNumber__c = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
			}
			newLead.OwnerId = leadOwnerId;
			newLeads.add(newLead);

			addressIndex = addressIndex == TEST_ADDRESSES.size() ? 0 : addressIndex + 1;
		}

		insert newLeads;

		return newLeads;
	}

	/**
	 * @description Method to create and return the List of Business leads (Scenario 3)
	 *
	 * @param numberOfLeads Number of records to be created
	 * @param leadOwnerId Owner Id of Lead
	 *
	 * @return List of Leads
	 */
	public static List<Lead> createBusinessLead(Integer numberOfLeads, Id leadOwnerId)
	{
		List<Lead> newLeads = new List<Lead>();

		Integer addressIndex = 0;

		loadAddresses();

		for(Integer i = 1; i <= numberOfLeads; i++)
		{
			Lead newLead = new Lead();

			newLead.FirstName = CMN_DAL_SObjectDomain.generateRandomName();
			newLead.LastName = CMN_DAL_SObjectDomain.generateRandomName();
			newLead.MobilePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
			newLead.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Lead.SObjectType, AW_DAL_Lead.RECORDTYPE_BUSINESS);

			TestAddress testAddress = getTestAddress();

			newLead.Street = testAddress.street;
			newLead.City = testAddress.city;
			newLead.State = testAddress.state;
			newLead.PostalCode = testAddress.postalCode;

			newLead.Country = testAddress.country;
			newLead.Latitude = testAddress.latitude;
			newLead.Longitude = testAddress.longitude;
			newLead.AW_CompanyRegistrationTrustNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
			newLead.OwnerId = leadOwnerId;
			newLeads.add(newLead);

			addressIndex = addressIndex == TEST_ADDRESSES.size() ? 0 : addressIndex + 1;
		}

		insert newLeads;

		return newLeads;
	}

	/**
	 * @description Method to return the List of Opportunity (Scenario 1)
	 *
	 * @param newAccount The account to which to link the opportunities
	 * @param numberOfRecords Number of records to be created
	 *
	 * @return List of Opportunity created
	 */
	public static List<Opportunity> createDefaultOpportunities(Account newAccount, Integer numberOfRecords)
	{
		return createOpportunities(newAccount, numberOfRecords, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY);
	}

	/**
	 * @description Method to create and return the List of Opportunity (Scenario 2)
	 *
	 * @param newAccount The account to which to link the opportunities
	 * @param numberOfRecords Number of records to be created
	 * @param recordTypeDevName Developer name of the record type
	 *
	 * @return List of Opportunity created
	 */
	public static List<Opportunity> createOpportunities(Account newAccount, Integer numberOfRecords, String recordTypeDevName)
	{
		List<Opportunity> newOpportunities = new List<Opportunity>();
		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Opportunity.SObjectType, recordTypeDevName);

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			Opportunity newOpportunity = new Opportunity();
			newOpportunity.RecordTypeId = recordTypeId;
			newOpportunity.AccountId = newAccount.Id;

			newOpportunity.Name = CMN_DAL_SObjectDomain.generateRandomName();
			newOpportunity.CreatedDate = CMN_DAL_SObjectDomain.generateRandomDate();
			newOpportunity.CloseDate = CMN_DAL_SObjectDomain.generateRandomDate();
			newOpportunity.StageName = AW_DAL_Opportunity.OPPORTUNITY_STAGE_QUALIFIED;

			newOpportunities.add(newOpportunity);
		}

		insert newOpportunities;

		return newOpportunities;
	}

	/**
	 * @description Method to create and return the List of Opportunity (Scenario 3)
	 *
	 * @param opportunityAccount The account to which to link the opportunities
	 * @param owner User record of Owner
	 * @param numberOfRecords Number of records to be created
	 * @param recordTypeDevName Developer name of the record type
	 *
	 * @return List of Opportunity
	 */
	public static List<Opportunity> newOpportunities(Account opportunityAccount, User owner, Integer numberOfRecords, String recordTypeDevName)
	{
		List<Opportunity> newOpportunities = new List<Opportunity>();
		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Opportunity.SObjectType, recordTypeDevName);

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			Opportunity newOpportunity = new Opportunity();

			newOpportunity.RecordTypeId = recordTypeId;
			newOpportunity.AccountId = opportunityAccount.Id;
			newOpportunity.Name = CMN_DAL_SObjectDomain.generateRandomName();
			newOpportunity.CloseDate = CMN_DAL_SObjectDomain.generateRandomDate();
			newOpportunity.StageName = AW_DAL_Opportunity.OPPORTUNITY_STAGE_QUALIFIED;
			newOpportunity.OwnerId = owner.Id;

			newOpportunities.add(newOpportunity);
		}

		return newOpportunities;
	}

	/**
	 * @description Method to create and return the List of Opportunity (Scenario 4)
	 *
	 * @param opportunityAccount The account to which to link the opportunities
	 * @param owner User record of Owner
	 * @param numberOfRecords Number of records to be created
	 * @param recordTypeDevName Developer name of the record type
	 *
	 * @return List of Opportunity
	 */
	public static List<Opportunity> createOpportunities(Account opportunityAccount, User owner, Integer numberOfRecords, String recordTypeDevName)
	{
		List<Opportunity> newOpportunities = newOpportunities(opportunityAccount, owner, numberOfRecords, recordTypeDevName);

		insert newOpportunities;

		return newOpportunities;
	}

	/**
	 * @description Will create an initialise a new financial account
	 *
	 * @param primaryOwner The account which should be the primary owner of the newly created item
	 * @param recordTypeId The recordtype to use for the new item
	 *
	 * @return new item (not committed)
	 */
	public static FinServ__FinancialAccount__c newFinancialAccount(Account primaryOwner, Id recordTypeId)
	{
		FinServ__FinancialAccount__c newAccount = new FinServ__FinancialAccount__c();

		newAccount.AW_AUMSourceExternalId__c = String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger(INT_SIX));
		newAccount.AW_ValueAsAt__c = CMN_DAL_SObjectDomain.generateRandomDateTime();
		newAccount.FinServ__FinancialAccountNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		newAccount.FinServ__FinancialAccountType__c = CMN_DAL_SObjectDomain.generateRandomName();
		newAccount.FinServ__HeldAway__c = false;
		newAccount.FinServ__PrimaryOwner__c = primaryOwner.Id;
		newAccount.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newAccount.RecordTypeId = recordTypeId;

		return newAccount;
	}

	/**
	 * @description Method to create and return the List of Financial Account (Scenario 1)
	 *
	 * @param primaryOwner The account against to which financial account should be linked
	 * @param numberOfFinancialAccounts Number of records to be created
	 *
	 * @return List of Financial Account
	 */
	public static List<FinServ__FinancialAccount__c> createFinancialAccounts(Account primaryOwner, Integer numberOfFinancialAccounts)
	{
		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(FinServ__FinancialAccount__c.SObjectType, AW_DAL_FinancialAccount.RT_INVESTMENT_ACCOUNT);

		List<FinServ__FinancialAccount__c> newFinancialAccounts = new List<FinServ__FinancialAccount__c>();

		for(Integer i = 0; i <= numberOfFinancialAccounts - 1; i++)
		{
			newFinancialAccounts.add(newFinancialAccount(primaryOwner, recordTypeId));
		}

		insert newFinancialAccounts;

		return newFinancialAccounts;
	}

	/**
	 * @description Method to create and return the List of Financial Account (Scenario 2)
	 *
	 * @param clientAccount The account against to which financial account should be linked
	 * @param recordTypeDevName Developer name of the record type
	 * @param numberOfFinancialAccounts Number of records to be created
	 *
	 * @return List of Financial Account
	 */
	public static List<FinServ__FinancialAccount__c> createFinancialAccounts(Account clientAccount, String recordTypeDevName, Integer numberOfFinancialAccounts)
	{

		List<FinServ__FinancialAccount__c> financialAccounts = new List<FinServ__FinancialAccount__c>();
		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(FinServ__FinancialAccount__c.SObjectType, recordTypeDevName);

		for(Integer i = 0; i < numberOfFinancialAccounts; i++)
		{
			FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();

			financialAccount.AW_AUMSourceExternalId__c = String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger(INT_SIX));
			financialAccount.FinServ__FinancialAccountNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
			financialAccount.FinServ__FinancialAccountType__c = CMN_DAL_SObjectDomain.generateRandomName();
			financialAccount.FinServ__HeldAway__c = false;
			financialAccount.FinServ__PrimaryOwner__c = clientAccount.Id;
			financialAccount.Name = CMN_DAL_SObjectDomain.generateRandomName();
			financialAccount.RecordTypeId = recordTypeId;

			financialAccounts.add(financialAccount);

		}

		insert financialAccounts;
		return financialAccounts;

	}

	/**
	 * @description Method to create and return the List of Asset and Liabilities
	 *
	 * @param primaryOwner The account against to which asset should be linked
	 * @param numberOfItems Number of records to be created
	 *
	 * @return List of Assets & Liabilities
	 */
	public static List<FinServ__AssetsAndLiabilities__c> createAssetsAndLiabilities(Account primaryOwner, Integer numberOfItems)
	{
		List<FinServ__AssetsAndLiabilities__c> newAssetsAndLiabilities = new List<FinServ__AssetsAndLiabilities__c>();

		for(Integer i = 0; i < numberOfItems; i++)
		{
			newAssetsAndLiabilities.add(newAssetAndLiability(primaryOwner));
		}

		insert newAssetsAndLiabilities;

		return newAssetsAndLiabilities;
	}

	/**
	 * @description Will create and initialise an FinServ__AssetsAndLiabilities__c object
	 *
	 * @param primaryOwner The account that owns the asset
	 *
	 * @return A newly created item (not committed)
	 */
	public static FinServ__AssetsAndLiabilities__c newAssetAndLiability(Account primaryOwner)
	{
		FinServ__AssetsAndLiabilities__c newAsset = new FinServ__AssetsAndLiabilities__c();

		newAsset.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newAsset.AW_AUMSourceExternalId__c = String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger(INT_SIX));
		newAsset.AW_AccountNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		newAsset.AW_ContractNumber__c = CMN_DAL_SObjectDomain.generateRandomName();
		newAsset.FinServ__PrimaryOwner__c = primaryOwner.Id;
		newAsset.AW_InceptionDate__c = CMN_DAL_SObjectDomain.generateRandomDate();
		newAsset.AW_CurrentValue__c = Decimal.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber());
		newAsset.AW_PurchasePrice__c = Decimal.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber());

		return newAsset;
	}

	/**
	 * @description Method to create and return the List of Account
	 *
	 * @return List of Account
	 */
	//TODO: Priority 2: Change the method to return a single account record rather than a list.
	// Also change method name from createBusinessAccounts to createBusinessAccount
	public static List<Account> createBusinessAccounts()
	{
		return createBusinessAccounts(INT_ONE);
	}

	/**
	 * @description Method to create and return the List of Account
	 *
	 * @param numberOfAccounts Number of records to be created
	 *
	 * @return List of Account
	 */
	public static List<Account> createBusinessAccounts(Integer numberOfAccounts)
	{
		return createBusinessAccounts(AW_DAL_Account.RT_BUSINESS_ACCOUNT, numberOfAccounts);
	}

	/**
	 * @description Method to create and return the List of Account
	 *
	 * @param recordTypeName Record Type Name
	 * @param numberOfAccounts Number of records to be created
	 *
	 * @return List of Account
	 */
	public static List<Account> createBusinessAccounts(String recordTypeName, Integer numberOfAccounts)
	{
		List<Account> accounts = new List<Account>();
		for(Integer i = 0; i < numberOfAccounts; i++)
		{
			Account newAccount = AW_DAL_TestDataFactory.newBusinessAccount(recordTypeName);
			accounts.add(newAccount);
		}
		insert accounts;

		return accounts;
	}

	/**
	 * @description Method to return a new Business Account
	 *
	 * @param recordTypeName Record Type Name
	 *
	 * @return New Account
	 *
	 * @author prashant.k.jain@accenture.com
	 */
	public static Account newBusinessAccount(String recordTypeName)
	{
		loadAddresses();

		Id accountRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, recordTypeName);
		southAfricaCountryId = String.isBlank(southAfricaCountryId) ? AW_DAL_Country.findByName(AW_DAL_Country.SOUTH_AFRICA).Id : southAfricaCountryId;

		Account newAccount = new Account();

		newAccount.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newAccount.AW_SKF_Id__c = CMN_DAL_SObjectDomain.generateRandomNumber(); // Populating UUID
		newAccount.FinServ__Status__c = AW_DAL_Account.STATUS_PROSPECT;
		newAccount.AW_CompanyRegistrationTrustNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		newAccount.AW_CorrespondencePreference__c = CORRESPONDENCE_PREFERENCE;
		newAccount.AW_ContactPreference__c = CONTACT_PREFERENCE;
		newAccount.AW_BusinessType__c = BUSINESS_TYPE;

		newAccount.RecordTypeId = accountRecordTypeId;

		TestAddress testAddress = getTestAddress();

		newAccount.ShippingStreet = testAddress.street;
		newAccount.ShippingCity = testAddress.city;
		newAccount.ShippingState = testAddress.state;
		newAccount.ShippingPostalCode = testAddress.postalCode;
		newAccount.ShippingCountry = testAddress.country;
		newAccount.ShippingLatitude = testAddress.latitude;
		newAccount.ShippingLongitude = testAddress.longitude;

		TestAddress testPhysicalAddress = getTestAddress();
		newAccount.AW_PhysicalStreetLineOne__c = testPhysicalAddress.street;
		newAccount.AW_PhysicalStreetLineTwo__c = testPhysicalAddress.street;
		newAccount.AW_PhysicalStreetLineThree__c = testPhysicalAddress.street;
		newAccount.AW_PhysicalCity__c = testPhysicalAddress.city;
		newAccount.AW_PhysicalSuburb__c = testPhysicalAddress.city;
		newAccount.AW_PhysicalPostalCode__c = testPhysicalAddress.postalCode;
		newAccount.AW_PhysicalCountry__c = southAfricaCountryId;

		TestAddress testPostalAddress = getTestAddress();
		newAccount.AW_PostalAddressLineOne__c = testPostalAddress.street;
		newAccount.AW_PostalAddressLineTwo__c = testPostalAddress.street;
		newAccount.AW_PostalAddressLineThree__c = testPostalAddress.street;
		newAccount.AW_PostalCity__c = testPostalAddress.city;
		newAccount.AW_PostalSuburb__c = testPostalAddress.city;
		newAccount.AW_PostalCode__c = testPostalAddress.postalCode;
		newAccount.AW_PostalCountry__c = southAfricaCountryId;

		return newAccount;
	}

	/**
	 * @description Method to return the List of Account with record Type - AW_LibertyMasterIndividualClient
	 *
	 * @return List of Account
	 */
	//TODO: Priority 2: Change the method to return a single account record rather than a list
	public static List<Account> createMasterPersonAccount()
	{
		return createMasterPersonAccount(INT_ONE);
	}

	/**
	 * @description Method to return the List of Account with record Type - AW_LibertyMasterIndividualClient
	 *
	 * @param numberOfRecords Number of records to be created
	 *
	 * @return List of Account
	 */
	public static List<Account> createMasterPersonAccount(Integer numberOfRecords)
	{
		return createPersonAccounts(AW_DAL_Account.RT_PERSON_MASTER_ACCOUNT, numberOfRecords);
	}

	/**
	 * @description Method to return the List of Account as Master
	 *
	 * @param identificationNumber The identity number of the account
	 *
	 * @return List of Account
	 */
	//TODO: Priority 2: Change the method to return a single account record rather than a list
	public static List<Account> createMasterPersonAccount(String identificationNumber)
	{
		return createPersonAccounts(AW_DAL_Account.RT_PERSON_MASTER_ACCOUNT, identificationNumber);
	}

	/**
	 * @description Method to return the List of Account as Master
	 *
	 * @param identificationNumber The identity number of the account
	 * @param numberOfRecords Number of records to be created
	 *
	 * @return List of Account
	 *
	 * @deprecated Needs to be deleted once all references of this method are removed.
	 * This method is left here for backward compatibility on higher environments.
	 */
	public static List<Account> createMasterPersonAccount(String identificationNumber, Integer numberOfRecords)
	{
		throwExceptionIfNumberOfRecordsInvalid(numberOfRecords);
		return createPersonAccounts(AW_DAL_Account.RT_PERSON_MASTER_ACCOUNT, identificationNumber);
	}

	/**
	 * @description Checks the number of records, anything not equal to 1 will throw an exception
	 *
	 * @param numberOfRecords Number of records to check
	 *
	 * @deprecated Needs to be deleted once all references of this method are removed.
	 */
	private static void throwExceptionIfNumberOfRecordsInvalid(Integer numberOfRecords)
	{
		if(numberOfRecords != 1)
		{
			throw new IllegalArgumentException(ERROR_DEPRECATED);
		}
	}

	/**
	 * @description Method to return the List of Account as client (Scenario 2)
	 *
	 * @return List of Account
	 */
	//TODO: Priority 2: Change the method to return a single account record rather than a list
	public static List<Account> createClientAccount()
	{
		return createClientAccount(INT_ONE);
	}

	/**
	 * @description Method to return the List of Account as client (Scenario 2)
	 *
	 * @param numberOfRecords Number of records to be created
	 *
	 * @return List of Account
	 */
	public static List<Account> createClientAccount(Integer numberOfRecords)
	{
		return createPersonAccounts(AW_DAL_Account.RT_PERSON_ACCOUNT, numberOfRecords);
	}

	/**
	 * @description Method to return the List of Account as client (Scenario 1)
	 *
	 * @param identificationNumber Identity Number
	 *
	 * @return List of Account
	 */
	//TODO: Priority 2: Change the method to return a single account record rather than a list
	public static List<Account> createClientAccount(String identificationNumber)
	{
		return createPersonAccounts(AW_DAL_Account.RT_PERSON_ACCOUNT, identificationNumber);
	}

	/**
	 * @description Method to return the List of Account as client (Scenario 1)
	 *
	 * @param identificationNumber Identity Number
	 * @param numberOfRecords Number of records to be created
	 *
	 * @return List of Account
	 *
	 * @deprecated Needs to be deleted once all references of this method are removed.
	 * This method is left here for backward compatibility on higher environments.
	 */
	public static List<Account> createClientAccount(String identificationNumber, Integer numberOfRecords)
	{
		throwExceptionIfNumberOfRecordsInvalid(numberOfRecords);
		return createPersonAccounts(AW_DAL_Account.RT_PERSON_ACCOUNT, identificationNumber);
	}

	/**
	 * @description Method to create and return the List of Person Account with random Identity Numbers
	 *
	 * @param recordTypeName Developer name of the record type
	 * @param numberOfRecords Number of records to be created
	 *
	 * @return List of Account
	 */
	public static List<Account> createPersonAccounts(String recordTypeName, Integer numberOfRecords)
	{
		List<Account> newAccounts = new List<Account>();
		for(Integer i = 0; i < numberOfRecords; i++)
		{
			String identificationNumber = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
			Account newAccount = AW_DAL_TestDataFactory.newPersonAccount(recordTypeName, identificationNumber);
			newAccounts.add(newAccount);
		}
		insert newAccounts;

		return newAccounts;
	}

	/**
	 * @description Method to create a Person Account with provided Identity Number and returns as a list
	 *
	 * @param recordTypeName Developer name of the record type
	 * @param identificationNumber Identity Number
	 *
	 * @return List of Account
	 */
	//TODO: Priority 2: Change the method to return a single account record rather than a list
	public static List<Account> createPersonAccounts(String recordTypeName, String identificationNumber)
	{
		List<Account> newAccounts = new List<Account>();
		Account newAccount = newPersonAccount(recordTypeName, identificationNumber);
		newAccounts.add(newAccount);

		insert newAccounts;

		return newAccounts;
	}

	/**
	 * @description Method to return a new Person Account
	 *
	 * @param recordTypeName Record Type Name
	 * @param identificationNumber ID Number
	 *
	 * @return New Account
	 *
	 * @author prashant.k.jain@accenture.com
	 */
	public static Account newPersonAccount(String recordTypeName, String identificationNumber)
	{
		loadAddresses();

		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, recordTypeName);
		southAfricaCountryId = String.isBlank(southAfricaCountryId) ? AW_DAL_Country.findByName(AW_DAL_Country.SOUTH_AFRICA).Id : southAfricaCountryId;

		Account newAccount = new Account();

		newAccount.AW_BPO_Client_Id__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		newAccount.AW_ClientId__c = CMN_DAL_SObjectDomain.generateRandomNumber(Account.AW_ClientId__c.getDescribe().length);
		newAccount.AW_ContactPreference__c = CONTACT_PREFERENCE;
		newAccount.AW_CorrespondencePreference__c = CORRESPONDENCE_PREFERENCE;
		newAccount.AW_Country_Of_Birth__c = southAfricaCountryId;
		newAccount.AW_EducationLevel__pc = AW_DAL_Account.EDUCATION_LEVEL_MATRIC;
		newAccount.AW_EmailUsage__c = EMAIL_USAGE;
		newAccount.AW_EngagementType__c = AW_DAL_Account.ENGAGEMENT_TYPES;
		newAccount.AW_ExpiryDate__pc = System.today();
		newAccount.AW_FifthName__pc = CMN_DAL_SObjectDomain.generateRandomName();
		newAccount.AW_FourthName__pc = CMN_DAL_SObjectDomain.generateRandomName();
		newAccount.AW_Growth_Strategy__c = 10;
		newAccount.AW_IdentificationNumber__pc = identificationNumber;
		newAccount.AW_IdentificationType__pc = AW_DAL_Account.PICK_SA_ID_TYPE;
		newAccount.AW_Income__pc = CMN_DAL_SObjectDomain.generateRandomInteger();
		newAccount.AW_IssueDate__pc = System.today();
		newAccount.AW_Maiden_Name__pc = CMN_DAL_SObjectDomain.generateRandomName();
		newAccount.AW_MobileUsage__c = MOBILE_USAGE;
		newAccount.AW_Nationality__c = southAfricaCountryId;
		newAccount.AW_Occupation__pc = getOccupation().Id;
		newAccount.AW_PassportCountryOfIssue__pc = null;
		newAccount.AW_PhoneUsage__c = PHONE_USAGE;
		newAccount.AW_Race__pc = PICK_RACE_WHITE;
		newAccount.AW_RetirementDate__pc = Date.today();
		newAccount.CMN_SAResidentIndicator__c = SC_DAL_Account.STATUS_RESIDENT_NO;
		newAccount.AW_SKF_Id__c = CMN_DAL_SObjectDomain.generateRandomNumber(); // Populating UUID
		newAccount.AW_Smoker__pc = true;
		newAccount.AW_TaxNumber__pc = CMN_DAL_SObjectDomain.generateRandomNumber();
		newAccount.AW_ThirdName__pc = CMN_DAL_SObjectDomain.generateRandomName();
		newAccount.FinServ__AnnualIncome__pc = CMN_DAL_SObjectDomain.generateRandomInteger();
		newAccount.FinServ__CountryOfResidence__pc = AW_DAL_Country.SOUTH_AFRICA;
		newAccount.FinServ__Gender__pc = AW_UTIL_IdentityNumber.getGenderFromIdentityNumber(identificationNumber);
		newAccount.FinServ__MaritalStatus__pc = AW_DAL_Account.PICK_MARRIED;
		newAccount.FinServ__PreferredName__pc = CMN_DAL_SObjectDomain.generateRandomName();
		newAccount.FinServ__PrimaryLanguage__pc = PRIMARY_LANGUAGE;
		newAccount.FinServ__Status__c = AW_DAL_Account.STATUS_PROSPECT;
		newAccount.FinServ__WeddingAnniversary__pc = Date.today();
		newAccount.FirstName = CMN_DAL_SObjectDomain.generateRandomName();
		newAccount.LastName = CMN_DAL_SObjectDomain.generateRandomName();
		newAccount.MiddleName = CMN_DAL_SObjectDomain.generateRandomName();
		newAccount.PersonBirthdate = AW_UTIL_IdentityNumber.extractDateOfBirthFromIdentityNumber(identificationNumber);
		newAccount.PersonMobilePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		newAccount.PersonOtherCountry = AW_DAL_Country.SOUTH_AFRICA;
		newAccount.Phone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		newAccount.RecordTypeId = recordTypeId;
		newAccount.Salutation = CMN_UTIL_System.getPicklistValue(Account.SObjectType, AW_DAL_Account.FIELD_SALUTATION, AW_DAL_Account.PICK_SALUTATION_MR);

		TestAddress testResidentialAddress = getTestAddress();
		newAccount.AW_ResidentialStreetLineOne__pc = testResidentialAddress.street;
		newAccount.AW_ResidentialStreetLineTwo__pc = testResidentialAddress.street;
		newAccount.AW_ResidentialStreetLineThree__pc = testResidentialAddress.street;
		newAccount.AW_ResidentialSuburb__pc = testResidentialAddress.city;
		newAccount.AW_ResidentialCountry__pc = southAfricaCountryId;
		newAccount.AW_ResidentialPostalCode__pc = testResidentialAddress.postalCode;
		newAccount.AW_ResidentialCity__pc = testResidentialAddress.city;

		TestAddress testPostalAddress = getTestAddress();
		newAccount.AW_PostalAddressLineOne__pc = testPostalAddress.street;
		newAccount.AW_PostalAddressLineTwo__pc = testPostalAddress.street;
		newAccount.AW_PostalAddressLineThree__pc = testPostalAddress.street;
		newAccount.AW_PostalSuburb__pc = testPostalAddress.city;
		newAccount.AW_PostalCountry__pc = southAfricaCountryId;
		newAccount.AW_PostalCode__pc = testPostalAddress.postalCode;
		newAccount.AW_PostalCity__pc = testPostalAddress.city;

		TestAddress testBillingAddress = getTestAddress();
		newAccount.BillingCity = testBillingAddress.city;
		newAccount.BillingCountry = testBillingAddress.country;
		newAccount.BillingPostalCode = testBillingAddress.postalCode;
		newAccount.BillingState = testBillingAddress.state;
		newAccount.BillingStreet = testBillingAddress.street;

		TestAddress testShippingAddress = getTestAddress();
		newAccount.ShippingCity = testShippingAddress.city;
		newAccount.ShippingCountry = testShippingAddress.country;
		newAccount.ShippingPostalCode = testShippingAddress.postalCode;
		newAccount.ShippingState = testShippingAddress.state;
		newAccount.ShippingStreet = testShippingAddress.street;

		newAccount.AW_OccupationDutyAdmin__c = 10;
		newAccount.AW_OccupationDutyLightManual__c = 20;
		newAccount.AW_OccupationDutyModerateHeavy__c = 10;
		newAccount.AW_OccupationDutyNonOfficeSupervisor__c = 20;
		newAccount.AW_OccupationDutyOfficeSupervisor__c = 20;
		newAccount.AW_OccupationDutyTravel__c = 20;

		return newAccount;
	}

	/**
	 * @description Method to create and return the Account team member
	 *
	 * @param acc to store the account record
	 * @param users List of user who have are account team member
	 * @param role To store the team member role
	 *
	 * @return List of Account team member
	 */
	public static List<AccountTeamMember> createAccountTeamMembers(Account acc, List<User> users, String role)
	{
		List<AccountTeamMember> newTeamMembers = new List<AccountTeamMember>();

		for(Integer i = 0; i < users.size(); i++)
		{
			AccountTeamMember newTeamMember = new AccountTeamMember();

			newTeamMember.AccountId = acc.Id;
			newTeamMember.UserId = users[i].Id;
			newTeamMember.TeamMemberRole = role;

			newTeamMembers.add(newTeamMember);
		}

		insert newTeamMembers;

		return newTeamMembers;
	}

	/**
	 * @description Method to create and return the Person Life event record
	 *
	 * @param contactId To store the contact
	 * @param numberOfRecords store the number of records
	 * @param visibleToClient To store the value of AW_VisibleToClient__c
	 *
	 * @return List of Person Life Event
	 */
	public static List<PersonLifeEvent> createPersonLifeEvents(Id contactId, Integer numberOfRecords, Boolean visibleToClient)
	{
		List<PersonLifeEvent> newLifeEvents = new List<PersonLifeEvent>();

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			PersonLifeEvent newLifeEvent = new PersonLifeEvent();

			newLifeEvent.Name = CMN_DAL_SObjectDomain.generateRandomName();
			newLifeEvent.PrimaryPersonId = contactId;
			newLifeEvent.EventType = AW_DAL_PersonLifeEvent.MARRIAGE_EVENT_TYPE;
			newLifeEvent.EventDate = CMN_DAL_SObjectDomain.generateRandomDate();
			newLifeEvent.AW_VisibleToClient__c = visibleToClient;

			newLifeEvents.add(newLifeEvent);
		}

		insert newLifeEvents;

		return newLifeEvents;
	}

	/**
	 * @description Method to create and return the content version record
	 *
	 * @param linkToObjectId The object to which the content version should be published
	 * @param numberOfRecords store the number of records
	 *
	 * @return List of Content Versions
	 */
	public static List<ContentVersion> createContentVersions(Id linkToObjectId, Integer numberOfRecords)
	{
		List<ContentVersion> newContentVersions = new List<ContentVersion>();

		User currentUser = AW_DAL_User.getCurrentUser();

		Network community;

		if(currentUser.ContactId != null)
		{
			community = CMN_DAL_Community.findByName(AW_DAL_Community.CLIENT_PORTAL_NAME);
		}

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			//noinspection ApexUnresolvableReference
			ContentVersion newContentVersion = CMN_DAL_ContentVersion.newItem
					(
							linkToObjectId,
							CMN_DAL_SObjectDomain.generateRandomName() + CMN_UTIL_String.DOT + CMN_DAL_ContentVersion.FILE_TYPE_PDF,
							CMN_DAL_SObjectDomain.generateRandomName(),
							Blob.valueOf(CMN_DAL_SObjectDomain.generateRandomDescription()),
							currentUser.ContactId != null ? community.Id : null,
							null
					);

			newContentVersions.add(newContentVersion);
		}

		insert newContentVersions;

		return newContentVersions;
	}

	/**
	 * @description Method to create and return Financial Goal
	 *
	 * @param accountId The account against which the goal should be linked
	 * @param numberOfRecords Number of records to be created
	 *
	 * @return List of Financial Goal
	 */
	public static List<FinServ__FinancialGoal__c> createGoals(Id accountId, Integer numberOfRecords)
	{
		List<FinServ__FinancialGoal__c> newGoals = new List<FinServ__FinancialGoal__c>();

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			FinServ__FinancialGoal__c newGoal = new FinServ__FinancialGoal__c();
			newGoal.FinServ__PrimaryOwner__c = accountId;
			newGoal.Name = CMN_DAL_SObjectDomain.generateRandomName();

			newGoals.add(newGoal);
		}

		insert newGoals;

		return newGoals;
	}

	/**
	 * @description Method to create and return an Adviser performance
	 *
	 * @param uacfIds A unique list of users UACF Ids to link adviser performance to
	 *
	 * @return List of Adviser performances
	 */
	public static List<AW_AdviserPerformance__c> createAdviserPerformances(Set<String> uacfIds)
	{
		return createAdviserPerformances(uacfIds, CMN_DAL_SObjectDomain.generateRandomDate());
	}

	/**
	 * @description Method to create and return an Adviser performance
	 *
	 * @param uacfIds A unique list of users UACF Ids to link adviser performance to
	 * @param performanceDate Date to be used for creating Performance record
	 *
	 * @return List of Adviser performances
	 */
	public static List<AW_AdviserPerformance__c> createAdviserPerformances(Set<String> uacfIds, Date performanceDate)
	{
		List<AW_AdviserPerformance__c> newPerformances = new List<AW_AdviserPerformance__c>();

		for(String uacfId : uacfIds)
		{
			AW_AdviserPerformance__c newPerformance = new AW_AdviserPerformance__c();

			newPerformance.AW_UACFID__c = uacfId;
			newPerformance.CreatedDate = performanceDate;
			newPerformance.AW_WeekNumber__c = Decimal.valueOf(CMN_UTIL_Date.weekNumberFromDate(performanceDate));
			newPerformance.AW_Year__c = String.valueOf(performanceDate.year());
			newPerformance.AW_LastYearsProductionClubStatus__c = AW_DAL_AdviserPerformance.ACHIEVER_PRODUCTION_CLUB_STATUS;

			newPerformances.add(newPerformance);
		}

		insert newPerformances;

		return newPerformances;
	}

	/**
	 * @description Method to create and return the Adviser Target
	 *
	 * @param advisers users against which targets should be created
	 * @param month The month of the target
	 * @param year The year of the target
	 *
	 * @return List of Adviser Target
	 */
	public static List<AW_AdviserTarget__c> createAdviserTargets(List<User> advisers, String month, String year)
	{
		List<AW_AdviserTarget__c> targets = new List<AW_AdviserTarget__c>();

		for(User usr : advisers)
		{
			AW_AdviserTarget__c target = new AW_AdviserTarget__c();

			target.AW_Month__c = month;
			target.AW_Year__c = year;
			target.OwnerId = usr.Id;

			targets.add(target);
		}
		insert targets;
		return targets;

	}

	/**
	 * @description Creates a feature switch record
	 */
	public static void createFeatureSwitch()
	{
		AW_FeatureSwitches__c featureSwitch = AW_FeatureSwitches__c.getInstance();

		featureSwitch.AW_AdviserTargetsOn__c = true;
		featureSwitch.AW_DisableAccountAPICall__c = false;
		featureSwitch.AW_DisableAccountValidationRules__c = false;
		featureSwitch.AW_DisableAdviserPerformanceValidation__c = false;
		featureSwitch.AW_DisableAdviserTargetValidationRule__c = false;
		featureSwitch.AW_DisableAllAPICalls__c = false;
		featureSwitch.AW_DoNotAuthenticateWithAzureB2C__c = false;

		upsert featureSwitch;
	}

	@TestVisible
	private class TestAddress
	{
		public String street;
		public String city;
		public String state;
		public String postalCode;
		public String country;
		public Decimal latitude;
		public Decimal longitude;

		@SuppressWarnings('PMD.ExcessiveParameterList')
		private TestAddress(String street, String city, String state, String postalCode, String country, Decimal latitude, Decimal longitude)
		{
			//The second part of the street address represents a suburb.
			this.street = street + ', ' + CMN_DAL_SObjectDomain.generateRandomName();
			this.city = city;
			this.postalCode = postalCode;
			this.state = state;
			this.country = country;
			this.latitude = latitude;
			this.longitude = longitude;
		}
	}

	@TestVisible
	private static void loadAddresses()
	{
		if(!TEST_ADDRESSES.isEmpty())
		{
			return;
		}

		TEST_ADDRESSES.add(new TestAddress('87 Frikkie De Beer Street', 'Pretoria', 'Gauteng', '0063', AW_DAL_Country.SOUTH_AFRICA, -25.731340, 28.218370));
		TEST_ADDRESSES.add(new TestAddress('43 Bradford Road', 'Germiston', 'Gauteng', '2008', AW_DAL_Country.SOUTH_AFRICA, -26.232590, 28.240967));
		TEST_ADDRESSES.add(new TestAddress('Sector-21', 'Gurugram', 'Haryana', '122016', AW_DAL_Country.INDIA, 28.457523, 77.026344));
		TEST_ADDRESSES.add(new TestAddress('Test', 'Redmond', 'Washington', '98052', AW_DAL_Country.UNITED_STATES, 47.673988, -122.121513));
		TEST_ADDRESSES.add(new TestAddress('2455 Rus St, Blackheath', 'Johannesburg', 'Gauteng', '7580', AW_DAL_Country.SOUTH_AFRICA, -26.202531, 27.928028));
		TEST_ADDRESSES.add(new TestAddress('831 Gleemoor Rd', 'Kimberley', 'Northern Cape', '8700', AW_DAL_Country.SOUTH_AFRICA, -28.729928, 24.851905));
		TEST_ADDRESSES.add(new TestAddress('R Tradição 15', 'BREJOS DE AZEITÃO', '', '2925-565', AW_DAL_Country.SOUTH_AFRICA, 38.590478, -9.070332));

		Set<String> countryNames = new Set<String>();

		for(TestAddress address : TEST_ADDRESSES)
		{
			countryNames.add(address.country);
		}

		for(String countryName : countryNames)
		{
			AW_Country__c country = new AW_Country__c();

			country.Name = countryName;
			country.AW_CountryCode__c = Decimal.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber(AW_DAL_Country.COUNTRY_CODE_LENGTH));

			TEST_COUNTRIES.add(country);
		}

		upsert TEST_COUNTRIES Name;
	}

	/**
	 * @description Method is use to return the value of Occupation created in loadOccupations() method
	 *
	 * @return size of occupation
	 */
	public static AW_Occupation__c getOccupation()
	{
		loadOccupations();

		Integer occupationIndex = CMN_UTIL_Random.nextInteger(TEST_OCCUPATIONS.size() - 1);

		return TEST_OCCUPATIONS[occupationIndex];
	}

	private static void loadOccupations()
	{
		if(!TEST_OCCUPATIONS.isEmpty())
		{
			return;
		}

		for(Integer i = 0; i < NUM_OCCUPATIONS_TO_CREATE; i++)
		{
			AW_Occupation__c occupation = new AW_Occupation__c();

			occupation.Name = CMN_DAL_SObjectDomain.generateRandomName();
			occupation.AW_OccupationCode__c = CMN_DAL_SObjectDomain.generateRandomNumber(AW_DAL_Occupation.OCCUPATION_CODE_LENGTH);

			TEST_OCCUPATIONS.add(occupation);
		}

		insert TEST_OCCUPATIONS;
	}

	@TestVisible
	private static TestAddress getTestAddress()
	{
		loadAddresses();

		Integer addressIndex = CMN_UTIL_Random.nextInteger(TEST_ADDRESSES.size() - 1);

		return TEST_ADDRESSES[addressIndex];
	}

	@TestVisible
	private static List<AW_FLOW_CreateMeetingRequestTask.DTO_Task> createAppointmentTasksDTO(Integer numberOfRecords, String creatingUser)
	{
		List<AW_FLOW_CreateMeetingRequestTask.DTO_Task> dtoTasks = new List<AW_FLOW_CreateMeetingRequestTask.DTO_Task>();

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			AW_FLOW_CreateMeetingRequestTask.DTO_Task dtoTask = new AW_FLOW_CreateMeetingRequestTask.DTO_Task();

			dtoTask.description = CMN_DAL_SObjectDomain.generateRandomDescription();
			dtoTask.dueDate = System.today();
			dtoTask.loggedInUserName = creatingUser;

			dtoTasks.add(dtoTask);
		}

		return dtoTasks;

	}

	/**
	 * @description Method to return the record of AW_FLOW_NewLead
	 *
	 * @param numberOfRecords Number of records to be created
	 * @param loggedInUserName Username of the logged in User
	 *
	 * @return List of AW_FLOW_NewLead
	 */
	public static List<AW_FLOW_NewLead.DTO_Lead> createReferralLeadsDTO(Integer numberOfRecords, String loggedInUserName)
	{
		List<AW_FLOW_NewLead.DTO_Lead> dtoLeads = new List<AW_FLOW_NewLead.DTO_Lead>();

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			AW_FLOW_NewLead.DTO_Lead dtoLead = new AW_FLOW_NewLead.DTO_Lead();

			dtoLead.firstName = CMN_DAL_SObjectDomain.generateRandomName();
			dtoLead.lastName = CMN_DAL_SObjectDomain.generateRandomName();
			dtoLead.phone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
			dtoLead.email = CMN_DAL_SObjectDomain.generateRandomEmail();

			dtoLead.loggedInUserName = loggedInUserName;

			dtoLeads.add(dtoLead);
		}

		return dtoLeads;
	}

	/**
	 * @description Method to return the record of AW_FLOW_BotGetSnapInsPreChatData class
	 *
	 * @param numberOfRecords Number of records to be created
	 *
	 * @return List of AW_FLOW_BotGetSnapInsPreChatData
	 */
	public static List<AW_FLOW_BotGetSnapInsPreChatData.DTO_PreChatInput> createChatScript(Integer numberOfRecords)
	{

		List<AW_FLOW_BotGetSnapInsPreChatData.DTO_PreChatInput> dtoPreChatInputs = new List<AW_FLOW_BotGetSnapInsPreChatData.DTO_PreChatInput>();

		for(Integer i = 0; i <= numberOfRecords; i++)
		{
			AW_FLOW_BotGetSnapInsPreChatData.DTO_PreChatInput dtoPreChatInput = new AW_FLOW_BotGetSnapInsPreChatData.DTO_PreChatInput();

			//TODO Priority 1: Do we need to be creating multiple of these? If so shouldn't it be bulkified?
			dtoPreChatInput.sChatKey = createChatTranscript();

			dtoPreChatInputs.add(dtoPreChatInput);
		}

		return dtoPreChatInputs;
	}

	/**
	 * @description Method to create and return the record of LiveChatTranscript
	 *
	 * @return ChatKey of LiveChatTranscript
	 */
	public static String createChatTranscript()
	{
		//create a Live Chat Visitor
		LiveChatVisitor visitor = new LiveChatVisitor();

		insert visitor;
		update visitor;//TODO Priority 1: Why  are  we doing  an update  after an insert?

		LiveChatTranscript trans = new LiveChatTranscript();

		trans.LiveChatVisitorId = visitor.Id;
		trans.ChatKey = CMN_DAL_SObjectDomain.generateRandomName();

		insert trans;

		return trans.ChatKey;

	}

	/**
	 * @description Will create an initialise a new FinancialGoal
	 *
	 * @param primaryOwner PrimaryOwner
	 *
	 * @return new item (not committed)
	 */
	public static FinServ__FinancialGoal__c newFinancialGoal(Account primaryOwner)
	{
		FinServ__FinancialGoal__c newGoal = new FinServ__FinancialGoal__c();
		newGoal.FinServ__PrimaryOwner__c = primaryOwner.Id;

		return newGoal;
	}

	@TestVisible
	private static List<FinServ__FinancialGoal__c> createFinancialGoals(Account primaryOwner, Integer numberOfItems)
	{
		List<FinServ__FinancialGoal__c> newFinancialGoals = new List<FinServ__FinancialGoal__c>();

		for(Integer i = 1; i <= numberOfItems; i++)
		{
			FinServ__FinancialGoal__c newGoals = new FinServ__FinancialGoal__c();

			newGoals.Name = CMN_DAL_SObjectDomain.generateRandomName();
			newGoals.FinServ__PrimaryOwner__c = primaryOwner.Id;
			newGoals.FinServ__TargetDate__c = CMN_DAL_SObjectDomain.generateRandomDate();
			newGoals.FinServ__ActualValue__c = Decimal.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber());
			newGoals.FinServ__InitialValue__c = Decimal.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber());

			newFinancialGoals.add(newGoals);
		}

		insert newFinancialGoals;

		return newFinancialGoals;
	}

	/**
	 * @description Will create an initialise a new income
	 *
	 * @return new item (not committed)
	 */
	public static AW_Income__c newIncome()
	{
		AW_Income__c income = new AW_Income__c();
		income.Name = CMN_DAL_SObjectDomain.generateRandomName();

		return income;
	}

	/**
	 * @description Will create an initialise a new insurance policy
	 *
	 * @param insuredId The primary owner of the policy
	 * @param recordTypeId The record type of the insurance policy
	 *
	 * @return new item (not committed)
	 */
	public static InsurancePolicy newInsurancePolicy(Id insuredId, Id recordTypeId)
	{
		InsurancePolicy newPolicy = new InsurancePolicy();

		newPolicy.AW_AUMSourceExternalId__c = CMN_DAL_SObjectDomain.generateRandomNumber(INT_SIX);
		newPolicy.AW_CurrentValue__c = Decimal.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger());
		newPolicy.Name = CMN_DAL_SObjectDomain.generateRandomNumber();
		newPolicy.NameInsuredId = insuredId;
		newPolicy.RecordTypeId = recordTypeId;

		return newPolicy;
	}

	/**
	 * @description Method to create and return the record of Insurance Policy (Scenario1)
	 *
	 * @param primaryOwner The Account to which the insurance policy should be linked
	 * @param financialGoal Record of Financial Goal Object
	 * @param numberOfPolicies Number of records to be created
	 *
	 * @return List of Insurance Policy
	 */
	public static List<InsurancePolicy> createInsurancePolicies(Account primaryOwner, FinServ__FinancialGoal__c financialGoal, Integer numberOfPolicies)
	{
		List<InsurancePolicy> newPolicies = new List<InsurancePolicy>();

		for(Integer i = 1; i <= numberOfPolicies; i++)
		{
			InsurancePolicy newPolicy = newInsurancePolicy(primaryOwner.Id, SC_DAL_InsurancePolicy.RT_INSURANCE_POLICY_ID);

			newPolicy.AW_FinancialGoal__c = financialGoal?.Id;

			newPolicies.add(newPolicy);
		}

		insert newPolicies;

		return newPolicies;
	}

	/**
	 * @description Method to create and return the record of Insurance Policy (Scenario2)
	 *
	 * @param primaryOwner The Account to which the insurance policy should be linked
	 * @param numberOfPolicies Number of records to be created
	 *
	 * @return List of Insurance Policy
	 */
	public static List<InsurancePolicy> createInsurancePolicies(Account primaryOwner, Integer numberOfPolicies)
	{
		return createInsurancePolicies(primaryOwner, null, numberOfPolicies);
	}

	/**
	 * @description Method to create and return the record of FNA
	 *
	 * @param accountId The Account to link the FNA too
	 * @param numberOfRecords Number of records to be created
	 *
	 * @return List of FNA
	 */
	public static List<AW_FNA__c> createFNA(Id accountId, Integer numberOfRecords)
	{
		List<AW_FNA__c> newFnaList = new List<AW_FNA__c>();

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			AW_FNA__c newFna = new AW_FNA__c();

			newFna.AW_Account__c = accountId;
			newFna.AW_FNADate__c = CMN_DAL_SObjectDomain.generateRandomDate();
			newFna.AW_FNADescription__c = CMN_DAL_SObjectDomain.generateRandomName();
			newFna.AW_FNAID__c = CMN_DAL_SObjectDomain.generateRandomNumber(INT_FOUR);

			newFnaList.add(newFna);
		}

		insert newFnaList;

		return newFnaList;
	}

	/**
	 * @description Method to create and return the record of Insurance policy coverage
	 *
	 * @param insurancePolicy To store the record of Insurance policy
	 * @param coverageTypes Type of coverage store in string
	 *
	 * @return List of InsurancePolicyCoverage
	 */
	public static List<InsurancePolicyCoverage> newInsurancePolicyCoverages(InsurancePolicy insurancePolicy, Set<String> coverageTypes)
	{
		List<InsurancePolicyCoverage> newInsurancePolicyCoverages = new List<InsurancePolicyCoverage>();

		for(String coverageType : coverageTypes)
		{
			InsurancePolicyCoverage insuranceCoverage = new InsurancePolicyCoverage();

			insuranceCoverage.InsurancePolicyId = insurancePolicy.Id;
			insuranceCoverage.AW_Type__c = coverageType;
			insuranceCoverage.AW_Amount__c = CMN_DAL_SObjectDomain.generateRandomDecimal();

			newInsurancePolicyCoverages.add(insuranceCoverage);
		}

		return newInsurancePolicyCoverages;
	}

	/**
	 * @description Method to create and return the record of Insurance policy participant
	 *
	 * @param insurancePolicy To store the record of Insurance policy
	 * @param roleTypes Type of Roles store in a set of string
	 * @param newContact The contact to which to link the participant
	 * @param newAccount The account to which to link the participant
	 *
	 * @return List of InsurancePolicyParticipant
	 */
	public static List<InsurancePolicyParticipant> createInsurancePolicyParticipants
			(InsurancePolicy insurancePolicy, Set<String> roleTypes, Contact newContact, Account newAccount)
	{
		List<InsurancePolicyParticipant> newInsurancePolicyParticipants = newInsurancePolicyParticipants(insurancePolicy, roleTypes, newContact, newAccount);
		insert newInsurancePolicyParticipants;
		return newInsurancePolicyParticipants;
	}

	/**
	 * @description Method to create and return the record of Insurance policy participant
	 *
	 * @param insurancePolicy To store the record of Insurance policy
	 * @param roleTypes Type of Roles store in a set of string
	 * @param newContact The contact to which to link the participant
	 * @param newAccount The account to which to link the participant
	 *
	 * @return List of InsurancePolicyParticipant
	 */
	public static List<InsurancePolicyParticipant> newInsurancePolicyParticipants
			(InsurancePolicy insurancePolicy, Set<String> roleTypes, Contact newContact, Account newAccount)
	{
		List<InsurancePolicyParticipant> newInsurancePolicyParticipants = new List<InsurancePolicyParticipant>();

		for(String roleType : roleTypes)
		{
			InsurancePolicyParticipant insuranceParticipant = new InsurancePolicyParticipant();

			insuranceParticipant.InsurancePolicyId = insurancePolicy.Id;
			insuranceParticipant.AW_FirstName__c = CMN_DAL_SObjectDomain.generateRandomName();
			insuranceParticipant.AW_LastName__c = CMN_DAL_SObjectDomain.generateRandomName();
			insuranceParticipant.Role = roleType;
			if(roleType == AW_DAL_FinancialAccountRole.PICK_FINANCIAL_ADVISOR)
			{
				insuranceParticipant.RelatedParticipantContactId = newContact.Id;
			}
			else
			{
				insuranceParticipant.RelatedParticipantAccountId = newAccount.Id;
			}
			newInsurancePolicyParticipants.add(insuranceParticipant);
		}
		return newInsurancePolicyParticipants;
	}

	/**
	 * @description Method to create and return the instance of Financial Account Role
	 *
	 * @param newAccount To store the record of Account
	 * @param newContact To store the record of Contact
	 * @param financialAccount To store the record of financial Account
	 * @param roleTypes Type of Roles store in a set of string
	 * @param consultantCode To store consultant code
	 *
	 * @return List of FinServ__FinancialAccountRole__c
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static List<FinServ__FinancialAccountRole__c> newFinancialAccountRoles
			(Account newAccount, Contact newContact, FinServ__FinancialAccount__c financialAccount, Set<String> roleTypes, String consultantCode)
	{
		List<FinServ__FinancialAccountRole__c> newRoles = new List<FinServ__FinancialAccountRole__c>();

		for(String roleType : roleTypes)
		{
			FinServ__FinancialAccountRole__c newRole = new FinServ__FinancialAccountRole__c();

			newRole.AW_RoleFirstName__c = CMN_DAL_SObjectDomain.generateRandomName();
			newRole.AW_RoleLastName__c = CMN_DAL_SObjectDomain.generateRandomName();
			newRole.FinServ__Active__c = true;
			newRole.FinServ__FinancialAccount__c = financialAccount.Id;
			newRole.FinServ__Role__c = roleType;

			if(roleType == AW_DAL_FinancialAccountRole.PICK_FINANCIAL_ADVISOR)
			{
				newRole.FinServ__RelatedContact__c = newContact?.Id;
				newRole.CMN_ConsultantCode__c = String.isNotBlank(consultantCode) ? consultantCode : AW_DAL_User.generateRandomConsultantCode();
			}
			else
			{
				newRole.FinServ__RelatedAccount__c = newAccount.Id;
			}

			newRoles.add(newRole);
		}

		return newRoles;
	}

	/**
	 * @description Method to create and return the record of Financial Account Role
	 *
	 * @param newAccount To store the record of Account
	 * @param newContact To store the record of Contact
	 * @param financialAccount To store the record of financial Account
	 * @param roleTypes Type of Roles store in a set of string
	 * @param consultantCode To store consultant code
	 *
	 * @return List of FinServ__FinancialAccountRole__c
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static List<FinServ__FinancialAccountRole__c> createFinancialAccountRoles
			(Account newAccount, Contact newContact, FinServ__FinancialAccount__c financialAccount, Set<String> roleTypes, String consultantCode)
	{
		List<FinServ__FinancialAccountRole__c> newFinancialAccountRoles =
				newFinancialAccountRoles(newAccount, newContact, financialAccount, roleTypes, consultantCode);
		insert newFinancialAccountRoles;
		return newFinancialAccountRoles;
	}

	/**
	 * @description Method to initialise and return the a list of Financial Holdings
	 *
	 * @param financialAccount Financial account to link the holding too
	 * @param numberOfHoldings Number of items to create
	 *
	 * @return List of Financial Holdings, not committed
	 */
	@TestVisible
	private static List<FinServ__FinancialHolding__c> newFinancialHoldings(FinServ__FinancialAccount__c financialAccount, Integer numberOfHoldings)
	{
		List<FinServ__FinancialHolding__c> newHoldings = new List<FinServ__FinancialHolding__c>();

		for(Integer i = 1; i <= numberOfHoldings; i++)
		{
			FinServ__FinancialHolding__c newHolding = new FinServ__FinancialHolding__c();

			newHolding.Name = CMN_DAL_SObjectDomain.generateRandomName();
			newHolding.AW_AUMSourceExternalId__c = String.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber());
			newHolding.FinServ__FinancialAccount__c = financialAccount.Id;
			newHoldings.add(newHolding);
		}

		return newHoldings;
	}

	/**
	 * @description Method to initialise and return the a list of Financial Holdings
	 *
	 * @param financialAccount Financial account to link the holding too
	 * @param numberOfHoldings Number of items to create
	 *
	 * @return List of Financial Holdings, committed
	 */
	@TestVisible
	private static List<FinServ__FinancialHolding__c> createFinancialHoldings(FinServ__FinancialAccount__c financialAccount, Integer numberOfHoldings)
	{
		List<FinServ__FinancialHolding__c> newHoldings = newFinancialHoldings(financialAccount, numberOfHoldings);

		insert newHoldings;

		return newHoldings;
	}

	/**
	 * @description Method to create and return the Workflow Task
	 *
	 * @param newAccount The account against which to link the workflow task
	 *
	 * @return Workflow Task
	 */
	public static AW_Outstanding_Requirement__c createWorkflowTask(Account newAccount)
	{
		AW_Outstanding_Requirement__c newWorkFlowTask = new AW_Outstanding_Requirement__c();

		newWorkFlowTask.AW_IdentityNumber__c = newAccount.AW_IdentificationNumber__pc;
		newWorkFlowTask.AW_UpdateISN__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		newWorkFlowTask.AW_Account__c = newAccount.Id;
		newWorkFlowTask.AW_ContractNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		newWorkFlowTask.AW_Role__c = CMN_DAL_SObjectDomain.generateRandomName();
		newWorkFlowTask.AW_Description__c = CMN_DAL_SObjectDomain.generateRandomDescription();
		newWorkFlowTask.AW_RequirementDate__c = System.today();
		newWorkFlowTask.AW_Key__c = CMN_DAL_SObjectDomain.generateRandomNumber();

		insert newWorkFlowTask;

		return newWorkFlowTask;
	}

	@TestVisible
	private static List<AW_FLOW_VerifyObjectAccess.DTO_Object> createObjectAccessCheckDTO(List<String> objects)
	{
		List<AW_FLOW_VerifyObjectAccess.DTO_Object> dtoObjects = new List<AW_FLOW_VerifyObjectAccess.DTO_Object>();

		for(String sObj : objects)
		{
			AW_FLOW_VerifyObjectAccess.DTO_Object dtoObject = new AW_FLOW_VerifyObjectAccess.DTO_Object();
			dtoObject.objectApiName = sObj;
			dtoObjects.add(dtoObject);
		}

		return dtoObjects;
	}

	/**
	 * @description : this method creates a test user to be used in test classes
	 *
	 * @param profileName The profile name to use when creating user
	 * @param doInsert Indicate if we should commit the record or not
	 *
	 * @return newly created user (may be committed)
	 */
	public static User createTestUser(String profileName, Boolean doInsert)
	{
		//TODO: Priority 2 Cleanup to allow creation of multiple users, remove the "do insert" flag
		//TODO: Priority 2 Check if we need to create at all
		User newUser = AW_DAL_User.newUser(profileName);

		if(doInsert)
		{
			insert newUser;
		}

		return newUser;
	}

	/**
	 * @description Method to create and return the record of FNA
	 *
	 * @param goalId The Goal against which the solution should be linked
	 * @param numberOfRecords Number of records to be created
	 *
	 * @return List of Solutions
	 */
	public static List<AW_Planned_Solution__c> createSolutions(Id goalId, Integer numberOfRecords)
	{
		List<AW_Planned_Solution__c> plannedSolutions = new List<AW_Planned_Solution__c>();

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			AW_Planned_Solution__c newPlannedSolution = new AW_Planned_Solution__c();
			newPlannedSolution.Name = CMN_DAL_SObjectDomain.generateRandomName();
			newPlannedSolution.AW_Financial_Goal__c = goalId;
			newPlannedSolution.AW_SourceSystemId__c = CMN_DAL_SObjectDomain.generateRandomNumber();
			newPlannedSolution.AW_Term_Months__c = TERM_MONTH;
			newPlannedSolution.AW_Lumpsum_Amount__c = LUMP_SUM_AMOUNT;
			newPlannedSolution.AW_Growth_Strategy__c = GROWTH_STRATEGY;
			newPlannedSolution.AW_Premium_Amount__c = PREMIUM_AMOUNT;
			newPlannedSolution.AW_PremiumFrequency__c = PREMIUM_FREQUENCY;
			plannedSolutions.add(newPlannedSolution);
		}

		insert plannedSolutions;

		return plannedSolutions;
	}

	/**
	 * @description Will create a new Quote
	 *
	 * @param opportunityId Opportunity to which to link the quote
	 * @param quoteNumber The number to be given to the quote
	 * @param doInsert Flag that determines if quote is insert (true = inserted)
	 *
	 * @return newly created quote
	 */
	public static Quote createQuoteWithQuoteNumber(Id opportunityId, String quoteNumber, Boolean doInsert)
	{
		Quote newQuote = new Quote
				(
						Name = CMN_DAL_SObjectDomain.generateRandomName(),
						OpportunityId = opportunityId,
						AW_Quote_Solution_Number__c = quoteNumber
				);
		if(doInsert)
		{
			insert newQuote;
		}
		return newQuote;
	}

	/**
	 * @description Will create a new Quoted Solution
	 *
	 * @param quoteId The Quote to which this solution should be linked
	 * @param contractNumber The contract number for the solution
	 * @param doInsert A flag that if set to true will insert the quote
	 *
	 * @return Newly created solution
	 */
	public static AW_Quoted_Solution__c createQuoteSolution(Id quoteId, String contractNumber, Boolean doInsert)
	{
		AW_Quoted_Solution__c newQuoteSolution = new AW_Quoted_Solution__c
				(
						Name = CMN_DAL_SObjectDomain.generateRandomName(),
						AW_Quote_Name__c = quoteId,
						AW_Contract_Number__c = contractNumber
				);
		if(doInsert)
		{
			insert newQuoteSolution;
		}
		return newQuoteSolution;
	}

	/**
	 * @description Method to create and return the record of Envelope, not committed
	 *
	 * @return An Envelope
	 *
	 * @author accenture
	 */
	public static AW_Envelope__c newEnvelope()
	{
		AW_Envelope__c newEnvelope = new AW_Envelope__c
				(
						Name = CMN_DAL_SObjectDomain.generateRandomName()
				);

		return newEnvelope;
	}

	/**
	 * @description Method to create and return the record of Envelope, committed
	 *
	 * @return An Envelope
	 *
	 * @author accenture
	 */
	public static AW_Envelope__c insertEnvelope()
	{
		AW_Envelope__c newEnvelope = newEnvelope();

		insert newEnvelope;

		return newEnvelope;
	}

	/**
	 * @description Will create an initialise a new OutstandingRequirement
	 *
	 * @return new item (not committed)
	 */
	public static AW_Outstanding_Requirement__c newOutstandingRequirement()
	{
		AW_Outstanding_Requirement__c newOutstandingRequirement = new AW_Outstanding_Requirement__c();

		return newOutstandingRequirement;
	}

	/**
	 * @description Method to create and return the record of Outstanding Requirement
	 *
	 * @return An Outstanding Requirement
	 *
	 * @author accenture
	 */
	public static AW_Outstanding_Requirement__c insertOutstandingRequirement()
	{
		AW_Outstanding_Requirement__c newOutstandingRequirement = new AW_Outstanding_Requirement__c();

		insert newOutstandingRequirement;

		return newOutstandingRequirement;
	}

	/**
	 * @description Method to create and return the record of EnvelopeWithActiveAccount
	 *
	 * @param accountId Id of the Account
	 *
	 * @return An Envelope
	 *
	 * @author accenture
	 */
	public static AW_Envelope__c insertEnvelopeWithActiveAccount(Id accountId)
	{
		AW_Envelope__c newEnvelope = newEnvelope();

		newEnvelope.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newEnvelope.AW_Account__c = accountId;
		insert newEnvelope;

		return newEnvelope;
	}

	/**
	 * @description Will create an initialise a new DocumentCheckListItem
	 *
	 * @param parentId The parent object against which the check list items should be created
	 *
	 * @return new item (not committed)
	 */
	public static DocumentChecklistItem newDocumentCheckListItem(Id parentId)
	{
		DocumentChecklistItem newListItem = new DocumentChecklistItem();

		newListItem.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newListItem.ParentRecordId = parentId;

		return newListItem;
	}

	/**
	 * @description Method to create and return document check list item
	 *
	 * @param parentId The parent object against which the check list items should be created
	 *
	 * @return A new Check List Item that's been committed
	 */
	public static DocumentChecklistItem insertDocumentCheckListItem(Id parentId)
	{
		DocumentChecklistItem newListItem = newDocumentCheckListItem(parentId);
		newListItem.Name = DOCUMENT_CHECKLIST_NAME;
		insert newListItem;
		return newListItem;
	}

	/**
	 * @description Will create an initialise a new Expense
	 *
	 * @return new item (not committed)
	 */
	public static AW_Expense__c newExpense()
	{
		AW_Expense__c expense = new AW_Expense__c();
		expense.Name = CMN_DAL_SObjectDomain.generateRandomName();

		return expense;
	}

	/**
	 * @description Will create an initialise a new Case
	 *
	 * @return new item (not committed)
	 */
	public static Case newCase()
	{
		Case caseRecord = new Case();

		return caseRecord;
	}

	/**
	 * @description Method to return the new Case related to Account
	 *
	 * @param contactId The Id of the account
	 *
	 * @return A newly created and inserted case
	 */
	public static Case createCase(Id contactId)
	{
		Case caseObj = new Case();

		caseObj.ContactId = contactId;
		caseObj.Status = AW_DAL_Case.PICK_STATUS_WORKING;
		caseObj.Origin = AW_DAL_Case.PICK_ORIGIN_PHONE;

		insert caseObj;

		return caseObj;
	}

	/**
	 * @description Method to return the new Contact related to Account
	 *
	 * @param accountId The account to which the contact should be linked
	 *
	 * @return Contact
	 */
	public static Contact createContact(Id accountId)
	{
		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Contact.SObjectType, AW_DAL_Contact.AW_INDIVIDUAL);
		Contact newContact = new Contact();
		newContact.RecordTypeId = recordTypeId;
		newContact.FirstName = CMN_DAL_SObjectDomain.generateRandomName();
		newContact.LastName = CMN_DAL_SObjectDomain.generateRandomName();
		newContact.Email = CMN_DAL_SObjectDomain.generateRandomEmail();
		newContact.Phone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		newContact.AccountId = accountId;

		insert newContact;
		return newContact;
	}

	/**
	 * @description Method to return the new Envelope Role(Recipient)
	 *
	 * @param contactId The contact for which to create a role
	 * @param envelopeId The envelope for which to create a role
	 *
	 * @return new created item
	 */
	public static AW_EnvelopeRole__c createEnvelopeRole(Id contactId, Id envelopeId)
	{
		AW_EnvelopeRole__c envelopeRole = new AW_EnvelopeRole__c();
		envelopeRole.AW_Contact__c = contactId;
		envelopeRole.AW_Envelope__c = envelopeId;
		insert envelopeRole;
		return envelopeRole;
	}

	/**
	 * @description Method to Create a Person master and child account
	 *
	 * @return Child Account
	 */
	public static Account createPersonChildAccountWithMaster()
	{
		String identityNumber = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();

		Account masterAccount = createMasterPersonAccount(identityNumber).iterator().next();
		Account childAccount = createClientAccount(identityNumber).iterator().next();

		childAccount.AW_ParentAccount__c = masterAccount.Id;
		childAccount.FinServ__Status__c = AW_DAL_Account.STATUS_ACTIVE;
		childAccount.AW_SKF_Id__c = masterAccount.AW_SKF_Id__c;
		childAccount.AW_BypassValidationRules__c = true;

		update childAccount;

		return childAccount;
	}

	/**
	 * @description Method to Create a Business master and child account
	 *
	 * @return Child Account
	 */
	public static Account createBusinessChildAccountWithMaster()
	{
		Account masterAccount = AW_DAL_TestDataFactory.createBusinessAccounts(AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT, INT_ONE).iterator().next();
		Account childAccount = AW_DAL_TestDataFactory.createBusinessAccounts().iterator().next();

		childAccount.AW_SKF_Id__c = masterAccount.AW_SKF_Id__c;
		childAccount.AW_ParentAccount__c = masterAccount.Id;
		childAccount.FinServ__Status__c = AW_DAL_Account.STATUS_ACTIVE;
		childAccount.AW_BypassValidationRules__c = true;

		update childAccount;

		return childAccount;
	}

	/**
	 * @description Method to return the new EmailMessage related to Account
	 *
	 * @param relatedToId The id of the object to which this email should be related too
	 *
	 * @return newly created item
	 */
	public static EmailMessage createEmailMessage(Id relatedToId)
	{
		EmailMessage newEmailMessage = new EmailMessage();

		newEmailMessage.FromAddress = CMN_DAL_SObjectDomain.generateRandomEmail();
		newEmailMessage.Incoming = true;
		newEmailMessage.ToAddress = CMN_DAL_SObjectDomain.generateRandomEmail();
		newEmailMessage.Subject = CMN_DAL_SObjectDomain.generateRandomName();
		newEmailMessage.HtmlBody = CMN_DAL_SObjectDomain.generateRandomName();
		newEmailMessage.RelatedToId = relatedToId;
		insert newEmailMessage;

		return newEmailMessage;

	}

	/**
	 * @description Method to return the new BusinessMilestone related to Account
	 *
	 * @param primaryAccountId Contains the AccountId to which BusinessMilestone to be related
	 * @param numberOfRecords Number of BusinessMilestone records to be created
	 *
	 * @return list of BusinessMilestone records created
	 */
	public static List<BusinessMilestone> createBusinessMilestone(Id primaryAccountId, Integer numberOfRecords)
	{
		List<BusinessMilestone> newMileStones = new List<BusinessMilestone>();

		for(Integer i = 1; i <= numberOfRecords; i++)
		{
			BusinessMilestone newBusinessMilestone = new BusinessMilestone();

			newBusinessMilestone.Name = CMN_DAL_SObjectDomain.generateRandomName();
			newBusinessMilestone.PrimaryAccountId = primaryAccountId;
			newBusinessMilestone.MilestoneDate = System.today();
			newBusinessMilestone.MilestoneType = AW_DAL_BusinessMilestone.MILESTONE_TYPE_AWARD;

			newMileStones.add(newBusinessMilestone);
		}

		insert newMileStones;

		return newMileStones;
	}

	/**
	 * @description Method to return the new Tasks with relatedToId
	 *
	 * @param recordtypeName The recordtype developer name
	 * @param whatId Contains the RelatedTo to which Task has to be related
	 * @param ownerId Contains the Id of the owner to whom the Task has to be assigned
	 * @param numberOfRecords Number of Task records to be created
	 *
	 * @return list of Tasks records created
	 */
	public static List<Task> createTasks(String recordtypeName, Id whatId, Id ownerId, Integer numberOfRecords)
	{
		return createTasks(recordtypeName, whatId, ownerId, numberOfRecords, true);
	}

	/**
	 * @description Method to return the new Tasks with relatedToId
	 *
	 * @param recordtypeName The recordtype developer name
	 * @param whoId Contains the Name (WhoId) to which Task has to be related
	 * @param ownerId Contains the Id of the owner to whom the Task has to be assigned
	 * @param numberOfRecords Number of Task records to be created
	 *
	 * @return list of Tasks records created
	 */
	public static List<Task> createTasksWithWhoId(String recordtypeName, Id whoId, Id ownerId, Integer numberOfRecords)
	{
		return createTasks(recordtypeName, whoId, ownerId, numberOfRecords, false);
	}

	/**
	 * @description Method to return the new Tasks with relatedToId
	 *
	 * @param recordtypeName The recordtype developer name
	 * @param whatIdWhoId Contains the RelatedTo (WhatId) OR Name (WhoId) to which Task has to be related
	 * @param ownerId Contains the Id of the owner to whom the Task has to be assigned
	 * @param numberOfRecords Number of Task records to be created
	 * @param isWhatId Flag to indicate whether whatIdWhoId is WhatId or WhoId
	 *
	 * @return list of Tasks records created
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static List<Task> createTasks(String recordtypeName, Id whatIdWhoId, Id ownerId, Integer numberOfRecords, Boolean isWhatId)
	{
		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Task.SObjectType, recordtypeName);

		List<Task> newTasks = new List<Task>();

		for(Integer i = 1; i <= numberOfRecords; i++)
		{
			Task newTask = new Task();

			newTask.RecordTypeId = recordTypeId;
			newTask.Subject = Label.AW_Change_of_Consultant_Form;
			newTask.Status = AW_DAL_Task.STATUS_IN_PROGRESS;
			if(isWhatId)
			{
				newTask.WhatId = whatIdWhoId;
			}
			else
			{
				newTask.WhoId = whatIdWhoId;
			}
			newTask.OwnerId = ownerId;

			newTasks.add(newTask);
		}

		insert newTasks;

		return newTasks;
	}

	/**
	 * @description Will create an initialise a new Campaign
	 *
	 * @return new item (not committed)
	 */
	public static Campaign newCampaign()
	{
		Campaign campaign = new Campaign();
		campaign.Name = CMN_DAL_SObjectDomain.generateRandomName();

		return campaign;
	}

	/**
	 * @description Will create an initialise a new SurveyInvitation
	 *
	 * @param personContactId personContactId
	 * @param surveyId survey Id
	 * @param communityId community id
	 *
	 * @return new item (not committed)
	 */
	public static SurveyInvitation newSurveyInvitation(Id personContactId, String surveyId, String communityId)
	{
		SurveyInvitation surveyInvitation = new SurveyInvitation();
		surveyInvitation.SurveyId = surveyId;
		surveyInvitation.Name = CMN_DAL_SObjectDomain.generateRandomName();
		surveyInvitation.ParticipantId = personContactId;
		surveyInvitation.CommunityId = communityId;

		return surveyInvitation;
	}

	/**
	 * @description Will create a new Embedded URL
	 *
	 * @param name Name of the embedded URL
	 * @param externalService External Service contains the URL
	 *
	 * @return newly created item (committed)
	 */
	public static AW_embeddedURL__c createEmbeddedURL(String name, String externalService)
	{
		AW_embeddedURL__c embeddedUrl = new AW_embeddedURL__c();

		embeddedUrl.Name = name;
		embeddedUrl.AW_External_Services__c = externalService;

		insert embeddedUrl;

		return embeddedUrl;
	}
}