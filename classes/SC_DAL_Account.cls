/**
 * @description Public class to return the records of Accounts
 *
 * @author mthobisi.ndlovu@accenture.com jason.van.beukering@accenture.com
 *
 * @date 2021, February 2022, October 2022
 */
public inherited sharing class SC_DAL_Account
{
	private static final String FIELD_COMPANY_REGISTRATION_NUMBER = Account.AW_CompanyRegistrationTrustNumber__c.getDescribe().getLocalName();
	private static final String FIELD_DATE_OF_BIRTH = Account.PersonBirthdate.getDescribe().getLocalName();
	private static final String FIELD_OWNER_CONSULTANT_CODE = 'Owner.AW_ConsultantCode__c';
	private static final String FIELD_OWNER_PROFILE = 'Owner.Profile.Name';
	private static final String FIELD_OWNER_UACFID = 'Owner.AW_UACFID__c';
	private static final String FIELD_RECORD_TYPE_NAME = 'RecordType.DeveloperName';

	/**
	 * @description stores the IdentificationNumber of an Account
	 */
	public static final String FIELD_IDENTIFICATION_NUMBER = Account.AW_IdentificationNumber__pc.getDescribe().getLocalName();
	/**
	 * @description stores the ObjectAPIName of Account
	 */
	public static final String OBJECT_NAME = CMN_DAL_Account.OBJECT_NAME;
	/**
	 * @description stores the DeveloperName of Liberty Master Business Client RecordType
	 */
	public static final String RT_BUSINESS_MASTER_ACCOUNT = AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT;
	/**
	 * @description stores the DeveloperName of Liberty Master Individual Client RecordType
	 */
	public static final String RT_PERSON_MASTER_ACCOUNT = AW_DAL_Account.RT_PERSON_MASTER_ACCOUNT;
	/**
	 * @description stores the DeveloperName of Liberty Practice Client RecordType
	 */
	public static final String RT_PRACTICE = 'AW_Practice';
	/**
	 * @description stores the constant Prospect
	 */
	public static final String STATUS_PROSPECT = AW_DAL_Account.STATUS_PROSPECT;
	/**
	 * @description stores the constant No
	 */
	public static final String STATUS_RESIDENT_NO = 'No';
	/**
	 * @description stores the DeveloperName of Liberty Master Business Client RecordType
	 */
	public static final String STATUS_RESIDENT_YES = 'Yes';
	/**
	 * @description stores the fieldAPIName of Income Category
	 */
	public static final String FIELD_INCOME_CATEGORY = Account.CMN_Income_Category__pc.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Income Type
	 */
	public static final String FIELD_INCOME_TYPE = Account.CMN_IncomeType__pc.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Occupation Industry
	 */
	public static final String FIELD_OCCUPATION_INDUSTRY = Account.CMN_OccupationIndustry__pc.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Occupation Risk Category
	 */
	public static final String FIELD_OCCUPATION_RISK_CATEGORY = Account.CMN_OccupationRiskCategory__pc.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Organisation Type
	 */
	public static final String FIELD_ORGANISATION_TYPE = Account.CMN_OrganisationType__c.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Date Of Birth
	 */
	public static final String FIELD_PERSON_BIRTHDATE = Account.PersonBirthdate.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Source Funds
	 */
	public static final String FIELD_SOURCE_OF_FUNDS = Account.CMN_SourceOfFunds__pc.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Source Of Wealth
	 */
	public static final String FIELD_SOURCE_OF_WEALTH = Account.CMN_SourceOfWealth__pc.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of SRS Id
	 */
	public static final String FIELD_SRS_ID = Account.CMN_SRSID__c.getDescribe().getLocalName();
	/**
	 * @description stores the APIName of Business Contact Detail FieldSet
	 */
	public static final String FIELD_SET_BUSINESS_CONTACT_DETAIL = 'RSC_BusinessContactDetailsSection';
	/**
	 * @description stores the APIName of Business Correspondence Address FieldSet
	 */
	public static final String FIELD_SET_BUSINESS_CORRESPONDENCE_ADDRESS = 'RSC_BusinessCorrespondenceDetailSection';
	/**
	 * @description stores the APIName of Person Contact Details FieldSet
	 */
	public static final String FIELD_SET_CONTACT_DETAIL = 'RSC_ContactDetailsSection';
	/**
	 * @description stores the APIName of Person Correspondence Address FieldSet
	 */
	public static final String FIELD_SET_PERSON_CORRESPONDENCE_ADDRESS = 'RSC_CorrespondenceDetailSection';
	/**
	 * @description stores the APIName of Physical Address Information FieldSet
	 */
	public static final String FIELD_SET_PHYSICAL_ADDRESS = 'RSC_PhysicalDetailSection';
	/**
	 * @description stores the APIName of Residential Address FieldSet
	 */
	public static final String FIELD_SET_RESIDENTIAL_ADDRESS = 'RSC_ResidentialDetailSection';
	/**
	 * @description stores the APIName of Social Media FieldSet
	 */
	public static final String FIELD_SET_SOCIAL_MEDIA = 'RSC_SocialMedia';
	/**
	 * @description stores the APIName of System Information FieldSet
	 */
	public static final String FIELD_SET_SYSTEM_INFORMATION = 'RSC_SystemInformation';
	/**
	 * @description stores the Active Adviser Account
	 */
	public static final String ACTIVE_ADVISER_ACCOUNT = 'Active Adviser Account';

	/**
	 * @description All the master account record types
	 */
	public static final Set<String> MASTER_ACCOUNT_RECORDTYPE_NAMES = new Set<String>
	{
			RT_PERSON_MASTER_ACCOUNT,
			RT_BUSINESS_MASTER_ACCOUNT
	};

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		Set<String> defaultFields = new Set<String>
		{
				Account.AW_AccountOwnerId__c.getDescribe().getLocalName(),
				Account.AW_Age__pc.getDescribe().getLocalName(),
				Account.AW_AlternativeEmail__pc.getDescribe().getLocalName(),
				Account.AW_BusinessType__c.getDescribe().getLocalName(),
				Account.AW_BypassValidationRules__c.getDescribe().getLocalName(),
				Account.AW_CompanyRegistrationTrustNumber__c.getDescribe().getLocalName(),
				Account.AW_ContactPreference__c.getDescribe().getLocalName(),
				Account.AW_CorrespondencePreference__c.getDescribe().getLocalName(),
				Account.AW_Country_Of_Birth__c.getDescribe().getLocalName(),
				Account.AW_EducationLevel__pc.getDescribe().getLocalName(),
				Account.AW_Email__c.getDescribe().getLocalName(),
				Account.AW_ExpiryDate__pc.getDescribe().getLocalName(),
				Account.AW_FifthName__pc.getDescribe().getLocalName(),
				Account.AW_FourthName__pc.getDescribe().getLocalName(),
				Account.AW_HobbiesInterests__c.getDescribe().getLocalName(),
				Account.AW_HobbyInterest__pc.getDescribe().getLocalName(),
				Account.AW_IdentificationNumber__pc.getDescribe().getLocalName(),
				Account.AW_IdentificationNumber__pc.getDescribe().getLocalName(),
				Account.AW_IdentificationType__pc.getDescribe().getLocalName(),
				Account.AW_Income__pc.getDescribe().getLocalName(),
				Account.AW_IssueDate__pc.getDescribe().getLocalName(),
				Account.AW_Last_Updated_Date_from_Source__c.getDescribe().getLocalName(),
				Account.AW_Maiden_Name__pc.getDescribe().getLocalName(),
				Account.AW_MedicalAidNumber__pc.getDescribe().getLocalName(),
				Account.AW_MedicalAidPlanName__pc.getDescribe().getLocalName(),
				Account.AW_MedicalPractitionerName__pc.getDescribe().getLocalName(),
				Account.AW_MedicalPractitionerTelNo__pc.getDescribe().getLocalName(),
				Account.AW_Mobile__c.getDescribe().getLocalName(),
				Account.AW_Nationality__c.getDescribe().getLocalName(),
				Account.AW_Occupation__pc.getDescribe().getLocalName(),
				Account.AW_OnwerId__pc.getDescribe().getLocalName(),
				Account.AW_OtherHobbyInterest__pc.getDescribe().getLocalName(),
				Account.AW_Owner_UACFID__c.getDescribe().getLocalName(),
				Account.AW_ParentAccount__c.getDescribe().getLocalName(),
				Account.AW_PassportCountryOfIssue__pc.getDescribe().getLocalName(),
				Account.AW_PhysicalCity__c.getDescribe().getLocalName(),
				Account.AW_PhysicalCountry__c.getDescribe().getLocalName(),
				Account.AW_PhysicalPostalCode__c.getDescribe().getLocalName(),
				Account.AW_PhysicalStreetLineOne__c.getDescribe().getLocalName(),
				Account.AW_PhysicalStreetLineThree__c.getDescribe().getLocalName(),
				Account.AW_PhysicalStreetLineTwo__c.getDescribe().getLocalName(),
				Account.AW_PhysicalSuburb__c.getDescribe().getLocalName(),
				Account.AW_PostalAddressLineOne__c.getDescribe().getLocalName(),
				Account.AW_PostalAddressLineOne__pc.getDescribe().getLocalName(),
				Account.AW_PostalAddressLineThree__c.getDescribe().getLocalName(),
				Account.AW_PostalAddressLineThree__pc.getDescribe().getLocalName(),
				Account.AW_PostalAddressLineTwo__c.getDescribe().getLocalName(),
				Account.AW_PostalAddressLineTwo__pc.getDescribe().getLocalName(),
				Account.AW_PostalCity__c.getDescribe().getLocalName(),
				Account.AW_PostalCity__pc.getDescribe().getLocalName(),
				Account.AW_PostalCode__c.getDescribe().getLocalName(),
				Account.AW_PostalCode__pc.getDescribe().getLocalName(),
				Account.AW_PostalCountry__c.getDescribe().getLocalName(),
				Account.AW_PostalCountry__pc.getDescribe().getLocalName(),
				Account.AW_PostalSuburb__c.getDescribe().getLocalName(),
				Account.AW_PostalSuburb__pc.getDescribe().getLocalName(),
				Account.AW_Race__pc.getDescribe().getLocalName(),
				Account.AW_ResidentialCity__pc.getDescribe().getLocalName(),
				Account.AW_ResidentialCountry__pc.getDescribe().getLocalName(),
				Account.AW_ResidentialPostalCode__pc.getDescribe().getLocalName(),
				Account.AW_ResidentialStreetLineOne__pc.getDescribe().getLocalName(),
				Account.AW_ResidentialStreetLineThree__pc.getDescribe().getLocalName(),
				Account.AW_ResidentialStreetLineTwo__pc.getDescribe().getLocalName(),
				Account.AW_ResidentialSuburb__pc.getDescribe().getLocalName(),
				Account.AW_RetirementDate__pc.getDescribe().getLocalName(),
				Account.AW_SKF_Id__c.getDescribe().getLocalName(),
				Account.AW_Smoker__pc.getDescribe().getLocalName(),
				Account.AW_Source_System_Name__c.getDescribe().getLocalName(),
				Account.AW_Suffix__c.getDescribe().getLocalName(),
				Account.AW_TaxNumber__pc.getDescribe().getLocalName(),
				Account.AW_Tenure__pc.getDescribe().getLocalName(),
				Account.AW_ThirdName__pc.getDescribe().getLocalName(),
				Account.AW_UACFID__c.getDescribe().getLocalName(),
				Account.CMN_AlternativeBusinessEmail__c.getDescribe().getLocalName(),
				Account.CMN_AlternativeBusinessEmail__pc.getDescribe().getLocalName(),
				Account.CMN_AlternativeBusinessMobile__c.getDescribe().getLocalName(),
				Account.CMN_AlternativeBusinessMobile__pc.getDescribe().getLocalName(),
				Account.CMN_AlternativeEmail__c.getDescribe().getLocalName(),
				Account.CMN_AlternativeFax__c.getDescribe().getLocalName(),
				Account.CMN_AlternativeFax__pc.getDescribe().getLocalName(),
				Account.CMN_AlternativeMobile__c.getDescribe().getLocalName(),
				Account.CMN_AlternativeMobile__pc.getDescribe().getLocalName(),
				Account.CMN_AlternativePhone__c.getDescribe().getLocalName(),
				Account.CMN_AlternativePhone__pc.getDescribe().getLocalName(),
				Account.CMN_AlternativeWorkPhone__pc.getDescribe().getLocalName(),
				Account.CMN_BusinessEmail__c.getDescribe().getLocalName(),
				Account.CMN_BusinessEmail__pc.getDescribe().getLocalName(),
				Account.CMN_BusinessMobile__c.getDescribe().getLocalName(),
				Account.CMN_BusinessMobile__pc.getDescribe().getLocalName(),
				Account.CMN_DateOfIncorporation__c.getDescribe().getLocalName(),
				Account.CMN_Instagram__pc.getDescribe().getLocalName(),
				Account.CMN_Phone__c.getDescribe().getLocalName(),
				Account.CMN_PostalCareOf__pc.getDescribe().getLocalName(),
				Account.CMN_ResidentialCareOf__pc.getDescribe().getLocalName(),
				Account.CMN_SAResidentIndicator__c.getDescribe().getLocalName(),
				Account.CMN_WorkPhone__pc.getDescribe().getLocalName(),
				Account.Fax.getDescribe().getLocalName(),
				Account.FinServ__AnnualIncome__pc.getDescribe().getLocalName(),
				Account.FinServ__ContactPreference__pc.getDescribe().getLocalName(),
				Account.FinServ__CountryOfResidence__pc.getDescribe().getLocalName(),
				Account.FinServ__CurrentEmployer__pc.getDescribe().getLocalName(),
				Account.FinServ__Facebook__pc.getDescribe().getLocalName(),
				Account.FinServ__Gender__pc.getDescribe().getLocalName(),
				Account.FinServ__LanguagesSpoken__pc.getDescribe().getLocalName(),
				Account.FinServ__LinkedIn__pc.getDescribe().getLocalName(),
				Account.FinServ__MaritalStatus__pc.getDescribe().getLocalName(),
				Account.FinServ__MotherMaidenName__pc.getDescribe().getLocalName(),
				Account.FinServ__Occupation__pc.getDescribe().getLocalName(),
				Account.FinServ__PreferredName__pc.getDescribe().getLocalName(),
				Account.FinServ__PrimaryLanguage__pc.getDescribe().getLocalName(),
				Account.FinServ__Status__c.getDescribe().getLocalName(),
				Account.FinServ__Twitter__pc.getDescribe().getLocalName(),
				Account.FinServ__WeddingAnniversary__pc.getDescribe().getLocalName(),
				Account.FirstName.getDescribe().getLocalName(),
				Account.Id.getDescribe().getLocalName(),
				Account.IsPersonAccount.getDescribe().getLocalName(),
				Account.LastName.getDescribe().getLocalName(),
				Account.MiddleName.getDescribe().getLocalName(),
				Account.Name.getDescribe().getLocalName(),
				Account.OwnerId.getDescribe().getLocalName(),
				Account.PersonBirthdate.getDescribe().getLocalName(),
				Account.PersonContactId.getDescribe().getLocalName(),
				Account.PersonEmail.getDescribe().getLocalName(),
				Account.PersonHomePhone.getDescribe().getLocalName(),
				Account.PersonMobilePhone.getDescribe().getLocalName(),
				Account.PersonOtherCity.getDescribe().getLocalName(),
				Account.PersonOtherCountry.getDescribe().getLocalName(),
				Account.PersonOtherPostalCode.getDescribe().getLocalName(),
				Account.PersonOtherState.getDescribe().getLocalName(),
				Account.PersonOtherStreet.getDescribe().getLocalName(),
				Account.Phone.getDescribe().getLocalName(),
				Account.Salutation.getDescribe().getLocalName(),
				CMN_DAL_SObjectDomain.FIELD_NAME,
				FIELD_DATE_OF_BIRTH,
				FIELD_OWNER_CONSULTANT_CODE,
				FIELD_OWNER_PROFILE,
				FIELD_OWNER_UACFID,
				FIELD_RECORD_TYPE_NAME,
				FIELD_SRS_ID
		};

		return defaultFields;
	}

	/**
	 * @description Will find an account by Id
	 *
	 * @param accountId The Id of the account
	 *
	 * @return Either the item found or null
	 */
	public static Account findById(Id accountId)
	{
		return (Account)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, accountId, getDefaultFields());
	}

	/**
	 * @description To fetch the field sets on Account based on the record type
	 *
	 * @param accountRecordTypeName The record type name of the account record
	 *
	 * @return the set of field sets
	 */
	public static Set<String> accountFieldSets(String accountRecordTypeName)
	{
		Set<String> fieldSetNameForAccount = new Set<String> ();

		fieldSetNameForAccount.add(SC_DAL_Account.FIELD_SET_SOCIAL_MEDIA);
		fieldSetNameForAccount.add(SC_DAL_Account.FIELD_SET_SYSTEM_INFORMATION);

		if(accountRecordTypeName == RT_PERSON_MASTER_ACCOUNT)
		{
			fieldSetNameForAccount.add(SC_DAL_Account.FIELD_SET_CONTACT_DETAIL);
			fieldSetNameForAccount.add(SC_DAL_Account.FIELD_SET_PERSON_CORRESPONDENCE_ADDRESS);
			fieldSetNameForAccount.add(SC_DAL_Account.FIELD_SET_RESIDENTIAL_ADDRESS);
		}
		else if(accountRecordTypeName == RT_BUSINESS_MASTER_ACCOUNT)
		{
			fieldSetNameForAccount.add(SC_DAL_Account.FIELD_SET_BUSINESS_CONTACT_DETAIL);
			fieldSetNameForAccount.add(SC_DAL_Account.FIELD_SET_BUSINESS_CORRESPONDENCE_ADDRESS);
			fieldSetNameForAccount.add(SC_DAL_Account.FIELD_SET_PHYSICAL_ADDRESS);
		}

		return fieldSetNameForAccount;
	}

	/**
	 * @description Will return all Accounts created by unit tests
	 *
	 * @return A list of accounts
	 */
	@TestVisible
	private static List<Account> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description Will find a list of Account by its name
	 *
	 * @param accountName The name of  Account
	 *
	 * @return List of found accounts
	 */
	public static Account findPracticeAccountByName(String accountName)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_NAME, new Set<String> {accountName}, getDefaultFields());
		searchParameters.searchConditions.equalsX(FIELD_RECORD_TYPE_NAME, RT_PRACTICE);
		List<Account> foundAccounts = CMN_DAL_Search.getObjects(searchParameters);

		return foundAccounts.size() == 1 ? foundAccounts.iterator().next() : null;
	}

	/**
	 * @description Will find a list of account by name,Identification number, Company Registration number
	 *
	 * @param searchKey The String of account Name,Identification number, Company Registration number
	 * @param birthDate The birth date to filter the account
	 *
	 * @return List of Accounts
	 */
	public static List<Account> findMasterAccountByNameAndDateOfBirth(String searchKey, Date birthDate)
	{
		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(CMN_SOQL_Query.inX(FIELD_RECORD_TYPE_NAME, CMN_UTIL_System.setToList(MASTER_ACCOUNT_RECORDTYPE_NAMES)));

		CMN_SOQL_Query.OrCondition orCondition = new CMN_SOQL_Query.OrCondition();

		if(!String.isBlank(searchKey))
		{
			orCondition.add(CMN_SOQL_Query.likeX(CMN_DAL_SObjectDomain.FIELD_NAME, searchKey));
			orCondition.add(CMN_SOQL_Query.equalsX(FIELD_IDENTIFICATION_NUMBER, searchKey));
			orCondition.add(CMN_SOQL_Query.equalsX(FIELD_COMPANY_REGISTRATION_NUMBER, searchKey));
		}
		if(birthDate != null)
		{

			orCondition.add(CMN_SOQL_Query.equalsX(FIELD_DATE_OF_BIRTH, birthDate));

		}

		CMN_SOQL_Builder fieldBuilder =
				new CMN_SOQL_Builder()
						.selectX(getDefaultFields())
						.fromX(OBJECT_NAME)
						.whereX(andCondition.add(orCondition));

		return Database.query(fieldBuilder.toSoql(new CMN_SOQL_Query.SoqlOptions().wildcardStringsInLikeOperators()));
	}

	/**
	 * @description This method is use to get all Master Accounts by its Identification Number/ Company Registration Number
	 *
	 * @param identityNumbers Person Identification Numbers or Company Registration Trust Number
	 *
	 * @return All the Master Accounts found
	 */
	public static List<Account> findMasterByIdentityNumber(Set<String> identityNumbers)
	{
		List<String> identityNumberList = CMN_UTIL_System.setToList(CMN_UTIL_System.trimSet(identityNumbers));

		List<Account> foundBusinessAccounts;

		//We're running two queries, as we want to leverage the indexes on the Identity number fields and it appears when combining
		//Both person account and business account fields in a single query, it tends to only use one index
		if(!identityNumberList.isEmpty())
		{
			CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());

			List<String> masterAccountRecordTypeNames = CMN_UTIL_System.setToList(MASTER_ACCOUNT_RECORDTYPE_NAMES);

			searchParameters.searchConditions.inX(FIELD_RECORD_TYPE_NAME, masterAccountRecordTypeNames);
			searchParameters.searchConditions.inX(FIELD_COMPANY_REGISTRATION_NUMBER, identityNumberList);

			foundBusinessAccounts = CMN_DAL_Search.getObjects(searchParameters);

			searchParameters.searchConditions = new CMN_SOQL_Query.AndCondition();

			searchParameters.searchConditions.inX(FIELD_RECORD_TYPE_NAME, masterAccountRecordTypeNames);
			searchParameters.searchConditions.inX(FIELD_IDENTIFICATION_NUMBER, identityNumberList);

			List<Account> foundPersonAccounts = CMN_DAL_Search.getObjects(searchParameters);

			foundBusinessAccounts.addAll(foundPersonAccounts);
		}

		return foundBusinessAccounts == null ? new List<Account>() : foundBusinessAccounts;
	}

	/**
	 * @description This method is used in test controllers to get all Accounts by its RecordType Name
	 *
	 * @param recordTypeName RecordType name to find the account
	 *
	 * @return All the Accounts associated to given record type
	 */
	public static List<Account> findAccountByRecordTypeName(String recordTypeName)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(
				OBJECT_NAME, FIELD_RECORD_TYPE_NAME, new Set<String> {recordTypeName}, getDefaultFields());

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method is used to generate a Map of existing master account records mapped by Identity Number
	 *
	 * @param identityNumbers The set of client Identity numbers extracted from the request
	 *
	 * @return Map of the Identity Numbers to the Account record
	 */
	public static Map<String, Account> getMasterAccountMapByIdNumber(Set<String> identityNumbers)
	{
		Map<String, Account> identityNumberMap = new Map<String, Account>();

		List<Account> foundAccounts = findMasterByIdentityNumber(identityNumbers);

		for(Account foundAccount : foundAccounts)
		{
			String identityNumber = SC_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT.equals(foundAccount.RecordType.DeveloperName) ?
					foundAccount.AW_CompanyRegistrationTrustNumber__c : foundAccount.AW_IdentificationNumber__pc;
			identityNumberMap.put(identityNumber, foundAccount);
		}

		return identityNumberMap;
	}
}