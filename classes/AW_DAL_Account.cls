/**
 * @description Public class to return the records of Accounts
 *
 * @author jason.van.beukering@accenture.com, pavan.t@lntinfotech.com
 *
 * @date 2019, June 2023
 */
public inherited sharing class AW_DAL_Account
{
	private static final String FIELD_BRANCH_NAME = Account.FinServ__BranchName__c.getDescribe().getLocalName();
	private static final String FIELD_COMPANY_REGISTRATION_NUMBER = Account.AW_CompanyRegistrationTrustNumber__c.getDescribe().getLocalName();
	private static final String FIELD_OWNER_CONSULTANT_CODE = 'Owner.AW_ConsultantCode__c';
	private static final String FIELD_OWNER_EMAIL = 'Owner.Email';
	private static final String FIELD_PARENT_ACCOUNT_ID = Account.AW_ParentAccount__c.getDescribe().getLocalName();
	private static final String FIELD_PARENT_ID = Account.ParentId.getDescribe().getLocalName();
	private static final String FIELD_STATUS = Account.FinServ__Status__c.getDescribe().getLocalName();
	private static final String RELATED_FINANCIAL_ACCOUNTS = 'FinServ__ClientFinancialAccounts__r';
	private static final String RELATED_FINANCIAL_GOALS = 'FinServ__ClientFinancialGoals__r';
	private static final String RELATED_INSURANCE_POLICIES = 'Insurance_Policies__r';

	/**
	 * @description stores the constant 2
	 */
	public static final String EDUCATION_LEVEL_MATRIC = '2';
	/**
	 * @description stores the engagement types
	 */
	public static final String ENGAGEMENT_TYPES = 'Phone;Email';
	/**
	 * @description stores the DeveloperName of AW_BusinessAccount FieldSet
	 */
	public static final String FIELDSET_BUSINESS = 'AW_BusinessAccount';
	/**
	 * @description stores the DeveloperName of AW_RefreshAdviserDemographicsInfoSection FieldSet
	 */
	public static final String FIELDSET_DEMOGRAPHIC_INFO = 'AW_RefreshAdviserDemographicsInfoSection';
    /**
	 * @description stores the DeveloperName of AW_RefreshAdviserEmploymentDetailSection FieldSet
	 */
	public static final String FIELDSET_EMPLOYMENT_INFO = 'AW_RefreshAdviserEmploymentDetailSection';
	/**
	 * @description stores the DeveloperName of AW_PersonAccount FieldSet
	 */
	public static final String FIELDSET_PERSON = 'AW_PersonAccount';
	/**
	 * @description stores the DeveloperName of LBL.Label_Field_Set_Person_Account FieldSet
	 */
	public static final String FIELDSET_PROSPECT = 'LBL_Label_Field_Set_Prospect';
	/**
	 * @description stores the constant Orphan
	 */
	public static final String ACCOUNT_OWNERSHIP_ORPHAN = 'Orphan';
	/**
	 * @description stores the fieldAPIName of Ownership Category
	 */
	public static final String FIELD_ACCOUNT_OWNERSHIP = Account.AW_Account_Ownership__c.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Correspondence Preference
	 */
	public static final String FIELD_CORRESPONDENCE_PREFERENCE = Account.AW_CorrespondencePreference__c.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Education Level
	 */
	public static final String FIELD_EDUCATION_LEVEL = Account.AW_EducationLevel__pc.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Email Usage
	 */
	public static final String FIELD_EMAIL_USAGE = Account.AW_EmailUsage__c.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Gender
	 */
	public static final String FIELD_GENDER = Account.FinServ__Gender__pc.getDescribe().getLocalName();
	/**
	 * @description API name of the field that stores the accounts identification number
	 */
	public static final String FIELD_IDENTIFICATION_NUMBER = Account.AW_IdentificationNumber__pc.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Identification Type
	 */
	public static final String FIELD_IDENTIFICATION_TYPE = Account.AW_IdentificationType__pc.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Is Reallocated
	 */
	public static final String FIELD_IS_REALLOCATED = Account.AW_IsReallocated__c.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Marital Status
	 */
	public static final String FIELD_MARITAL_STATUS = Account.FinServ__MaritalStatus__pc.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Master Account Lookup
	 */
	public static final String FIELD_MASTER_ACCOUNT_LOOKUP = 'AW_MasterAccount__c';
	/**
	 * @description stores the fieldAPIName of Mobile Usage
	 */
	public static final String FIELD_MOBILE_USAGE = Account.AW_MobileUsage__c.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Owner Changed Date
	 */
	public static final String FIELD_OWNER_CHANGED_DATE = Account.AW_OwnerChangedDate__c.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Owner UACFID
	 */
	public static final String FIELD_OWNER_UACFID = Account.AW_Owner_UACFID__c.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Phone Usage
	 */
	public static final String FIELD_PHONE_USAGE = Account.AW_PhoneUsage__c.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Primary Language
	 */
	public static final String FIELD_PRIMARY_LANGUAGE = Account.FinServ__PrimaryLanguage__pc.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Race
	 */
	public static final String FIELD_RACE = Account.AW_Race__pc.getDescribe().getLocalName();
	/**
	 * @description The developer name of the current record's recordtype
	 */
	public static final String FIELD_RECORD_TYPE_NAME = 'RecordType.DeveloperName';
	/**
	 * @description stores the fieldAPIName of Salutation
	 */
	public static final String FIELD_SALUTATION = Account.Salutation.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of SKF Id
	 */
	public static final String FIELD_SKF_ID = Account.AW_SKF_Id__c.getDescribe().getLocalName();
	/**
	 * @description stores the fieldAPIName of Source System Name
	 */
	public static final String FIELD_SOURCE_SYSTEM_NAME = Account.AW_Source_System_Name__c.getDescribe().getLocalName();
	/**
	 * @description stores the ObjectAPIName of Account
	 */
	public static final String OBJECT_NAME = CMN_DAL_Account.OBJECT_NAME;
	/**
	 * @description stores the field name of Owner Profile
	 */
	private static final String FIELD_OWNER_PROFILE = 'Owner.Profile.Name';
	/**
	 * @description stores the picklist value Failed
	 */
	public static final String PICK_FAILED = 'Failed';
	/**
	 * @description stores the picklist value Married
	 */
	public static final String PICK_MARRIED = 'Married';
	/**
	 * @description stores the picklist value Onboarding
	 */
	public static final String PICK_ONBOARDING = 'Onboarding';
	/**
	 * @description stores the picklist value Passport
	 */
	public static final String PICK_PASSPORT_TYPE = 'Passport';
	/**
	 * @description stores the picklist value that indicates a policy refresh was requested
	 */
	public static final String PICK_REFRESH_REQUESTED = 'Requested';
	/**
	 * @description stores the picklist value Mr
	 */
	public static final String PICK_SALUTATION_MR = 'Mr';
	/**
	 * @description stores the picklist value South African ID
	 */
	public static final String PICK_SA_ID_TYPE = 'South African ID';
	/**
	 * @description stores the picklist value Successful
	 */
	public static final String PICK_SUCCESSFUL = 'Successful';
	/**
	 * @description stores the DeveloperName of Liberty Business Client RecordType
	 */
	public static final String RT_BUSINESS_ACCOUNT = 'AW_Business';
	/**
	 * @description stores the DeveloperName of Liberty Master Business Client RecordType
	 */
	public static final String RT_BUSINESS_MASTER_ACCOUNT = 'AW_LibertyMasterBusinessClient';
	/**
	 * @description stores the DeveloperName of Liberty Individual Client RecordType
	 */
	public static final String RT_PERSON_ACCOUNT = 'AW_PersonAccount';
	/**
	 * @description stores the DeveloperName of Liberty Master Individual Client RecordType
	 */
	public static final String RT_PERSON_MASTER_ACCOUNT = 'AW_LibertyMasterIndividualClient';
	/**
	 * @description stores the constant SKF
	 */
	public static final String SKF_SOURCE_SYSTEM = 'SKF';
	/**
	 * @description stores the constant Active
	 */
	public static final String STATUS_ACTIVE = 'Active';
	/**
	 * @description stores the constant Prospect
	 */
	public static final String STATUS_PROSPECT = 'Prospect';
	/**
	 * @description stores the field name of Residential Country
	 */
	public static final String FIELD_RESIDENTIAL_COUNTRY_NAME = 'AW_ResidentialCountry__pr.Name';
	/**
	 * @description stores the field name of Postal Country
	 */
	public static final String FIELD_POSTAL_COUNTRY_NAME = 'AW_PostalCountry__pr.Name';

	/**
	 * @description account field sets
	 */
	public static final List<String> ACCOUNT_FIELD_SETS = new List<String>
	{
			'AW_RefreshAdviserCoreDetailSection',
			'AW_RefreshAdviserContactDetailSection',
			'AW_RefreshAdviserDemographicsInfoSection',
			'AW_RefreshAdviserAddressInfoSection',
			'AW_RefreshAdviserBankingDetailSection',
			'AW_RefreshAdviserEmploymentDetailSection',
			'AW_RefreshAdviserAdditionalInfoSection',
			'AW_RefreshAdviserSystemInfoSection'
	};

	/**
	 * @description All the master account record types
	 */
	public static final Set<String> MASTER_ACCOUNT_RECORDTYPE_NAMES = new Set<String>
	{
			RT_PERSON_MASTER_ACCOUNT,
			RT_BUSINESS_MASTER_ACCOUNT
	};

	/**
	 * @description A list of the child object relationship names
	 */
	public static final Set<String> SUPPORTED_CHILD_RELATIONSHIPS = new Set<String>
	{
			'AW_PersonLifeEvents__r',
			'BusinessMilestones',
			'Cases',
			'Emails',
			'Envelopes__r',
			'FNA__r',
			'FinServ__ClientAssetsAndLiabilities__r',
			'FinServ__ClientFinancialAccounts__r',
			RELATED_FINANCIAL_GOALS,
			'InsurancePolicies',
			'Opportunities',
			'Outstanding_Requirements__r'
	};

	/**
	 * @description All workbench record types
	 */
	private static final Set<String> ALL_ACCOUNT_RECORD_TYPES = new Set<String>
	{
			RT_BUSINESS_ACCOUNT,
			RT_BUSINESS_MASTER_ACCOUNT,
			RT_PERSON_ACCOUNT,
			RT_PERSON_MASTER_ACCOUNT
	};

	/**
	 * @description Method to define the fields to retrieve business accounts
	 *
	 * @return A list of fields for both business and person accounts
	 */
	@SuppressWarnings('PMD.NcssMethodCount')
	private static Set<String> getBusinessDefaultFields()
	{
		return new Set<String>
		{
				//TODO: SL fields to be removed from AW and moved to SL DAL
				Account.AW_AUMSourceExternalId__c.getDescribe().getLocalName(),
				Account.AW_AUM__c.getDescribe().getLocalName(),
				Account.AW_AccountOwnerId__c.getDescribe().getLocalName(),
				Account.AW_Account_Ownership__c.getDescribe().getLocalName(),
				Account.AW_BPO_Client_Id__c.getDescribe().getLocalName(),
				Account.AW_BirthdaysThisMonth__c.getDescribe().getLocalName(),
				Account.AW_BranchId__c.getDescribe().getLocalName(),
				Account.AW_BusinessType__c.getDescribe().getLocalName(),
				Account.AW_BypassValidationRules__c.getDescribe().getLocalName(),
				Account.AW_CLIENT_TotalAssets__c.getDescribe().getLocalName(),
				Account.AW_ClientId__c.getDescribe().getLocalName(),
				Account.AW_CommunityUserCreationInitiated__c.getDescribe().getLocalName(),
				Account.AW_CompanyRegistrationTrustNumber__c.getDescribe().getLocalName(),
				Account.AW_Company__c.getDescribe().getLocalName(),
				Account.AW_ContactPreference__c.getDescribe().getLocalName(),
				Account.AW_Country_Of_Birth__c.getDescribe().getLocalName(),
				Account.AW_DateOfTheInitialLoad__c.getDescribe().getLocalName(),
				Account.AW_Email__c.getDescribe().getLocalName(),
				Account.AW_EngagementFrequency__c.getDescribe().getLocalName(),
				Account.AW_EngagementType__c.getDescribe().getLocalName(),
				Account.AW_FA_TotalAssets__c.getDescribe().getLocalName(),
				Account.AW_FA_TotalHeldAwayBank__c.getDescribe().getLocalName(),
				Account.AW_FA_TotalHeldAwayCreditCard__c.getDescribe().getLocalName(),
				Account.AW_FA_TotalHeldAwayInvestments__c.getDescribe().getLocalName(),
				Account.AW_FA_TotalHeldAwayOtherLiabilities__c.getDescribe().getLocalName(),
				Account.AW_FA_TotalHeldAwayRetirement__c.getDescribe().getLocalName(),
				Account.AW_FA_TotalHeld_Away_Loan_account__c.getDescribe().getLocalName(),
				Account.AW_FA_TotalLiabilities__c.getDescribe().getLocalName(),
				Account.AW_Financial_Advisor__c.getDescribe().getLocalName(),
				Account.AW_GroupType__c.getDescribe().getLocalName(),
				Account.AW_Growth_Strategy__c.getDescribe().getLocalName(),
				Account.AW_HobbiesInterests__c.getDescribe().getLocalName(),
				Account.AW_Last_Synch_Date__c.getDescribe().getLocalName(),
				Account.AW_Last_Updated_Date_from_Source__c.getDescribe().getLocalName(),
				Account.AW_Mobile__c.getDescribe().getLocalName(),
				Account.AW_MonthlyIncome__c.getDescribe().getLocalName(),
				Account.AW_NameofOrphansPreviousAdviser__c.getDescribe().getLocalName(),
				Account.AW_Nationality__c.getDescribe().getLocalName(),
				Account.AW_NetWorth__c.getDescribe().getLocalName(),
				Account.AW_OccupationDutyAdmin__c.getDescribe().getLocalName(),
				Account.AW_OccupationDutyLightManual__c.getDescribe().getLocalName(),
				Account.AW_OccupationDutyModerateHeavy__c.getDescribe().getLocalName(),
				Account.AW_OccupationDutyNonOfficeSupervisor__c.getDescribe().getLocalName(),
				Account.AW_OccupationDutyOfficeSupervisor__c.getDescribe().getLocalName(),
				Account.AW_OccupationDutyTravel__c.getDescribe().getLocalName(),
				Account.AW_Orphan_Indicator__c.getDescribe().getLocalName(),
				Account.AW_OtherEngagementFrequency__c.getDescribe().getLocalName(),
				Account.AW_OtherEngagementPreferenceType__c.getDescribe().getLocalName(),
				Account.AW_OtherInformation__c.getDescribe().getLocalName(),
				Account.AW_Outcome__c.getDescribe().getLocalName(),
				Account.AW_ParentAccount__c.getDescribe().getLocalName(),
				Account.AW_PhysicalCity__c.getDescribe().getLocalName(),
				Account.AW_PhysicalCountry__c.getDescribe().getLocalName(),
				Account.AW_PhysicalPostalCode__c.getDescribe().getLocalName(),
				Account.AW_PhysicalStreetLineOne__c.getDescribe().getLocalName(),
				Account.AW_PhysicalStreetLineThree__c.getDescribe().getLocalName(),
				Account.AW_PhysicalStreetLineTwo__c.getDescribe().getLocalName(),
				Account.AW_PhysicalSuburb__c.getDescribe().getLocalName(),
				Account.AW_PoliciesRefreshStatusDate__c.getDescribe().getLocalName(),
				Account.AW_PoliciesRefreshStatus__c.getDescribe().getLocalName(),
				Account.AW_PostalAddressLineOne__c.getDescribe().getLocalName(),
				Account.AW_PostalAddressLineThree__c.getDescribe().getLocalName(),
				Account.AW_PostalAddressLineTwo__c.getDescribe().getLocalName(),
				Account.AW_PostalCity__c.getDescribe().getLocalName(),
				Account.AW_PostalCode__c.getDescribe().getLocalName(),
				Account.AW_PostalCountry__c.getDescribe().getLocalName(),
				Account.AW_PostalSuburb__c.getDescribe().getLocalName(),
				Account.AW_PreviousBranch__c.getDescribe().getLocalName(),
				Account.AW_Professional_Body_Reg_Number__c.getDescribe().getLocalName(),
				Account.AW_Professional_Body__c.getDescribe().getLocalName(),
				Account.AW_RegionId__c.getDescribe().getLocalName(),
				Account.AW_Region__c.getDescribe().getLocalName(),
				Account.AW_SKF_Id__c.getDescribe().getLocalName(),
				Account.AW_SubRegionId__c.getDescribe().getLocalName(),
				Account.AW_SubRegion__c.getDescribe().getLocalName(),
				Account.AW_Suffix__c.getDescribe().getLocalName(),
				Account.AW_Synch_Error__c.getDescribe().getLocalName(),
				Account.AW_TotalAmountInsurancePolicy__c.getDescribe().getLocalName(),
				Account.AW_TotalAssets__c.getDescribe().getLocalName(),
				Account.AW_TotalCriticalIllnessCover__c.getDescribe().getLocalName(),
				Account.AW_TotalDisabilityCoverLumpsum__c.getDescribe().getLocalName(),
				Account.AW_TotalDisabilityCoverMonth__c.getDescribe().getLocalName(),
				Account.AW_TotalHeldAwayAsset__c.getDescribe().getLocalName(),
				Account.AW_TotalHeldAwayBank__c.getDescribe().getLocalName(),
				Account.AW_TotalHeldAwayCreditCard__c.getDescribe().getLocalName(),
				Account.AW_TotalHeldAwayInvestments__c.getDescribe().getLocalName(),
				Account.AW_TotalHeldAwayLoanAccount__c.getDescribe().getLocalName(),
				Account.AW_TotalHeldAwayRetirement__c.getDescribe().getLocalName(),
				Account.AW_TotalHeldBank__c.getDescribe().getLocalName(),
				Account.AW_TotalHeldCreditCard__c.getDescribe().getLocalName(),
				Account.AW_TotalHeldInvestments__c.getDescribe().getLocalName(),
				Account.AW_TotalHeldLoan__c.getDescribe().getLocalName(),
				Account.AW_TotalHeldRetirement__c.getDescribe().getLocalName(),
				Account.AW_TotalInvestments__c.getDescribe().getLocalName(),
				Account.AW_TotalLiabilities__c.getDescribe().getLocalName(),
				Account.AW_TotalLifeCover__c.getDescribe().getLocalName(),
				Account.AW_TotalOccupationDuty__c.getDescribe().getLocalName(),
				Account.AW_TotalRetirement__c.getDescribe().getLocalName(),
				Account.AW_UACFID__c.getDescribe().getLocalName(),
				Account.AW_UnitId__c.getDescribe().getLocalName(),
				Account.AW_UpcomingBirthdaysThisMonth__c.getDescribe().getLocalName(),
				Account.AW_VATNumber__c.getDescribe().getLocalName(),
				Account.AW_Will_Indicator__c.getDescribe().getLocalName(),
				Account.AW_Will_Location__c.getDescribe().getLocalName(),
				Account.BillingAddress.getDescribe().getLocalName(),
				Account.BillingCity.getDescribe().getLocalName(),
				Account.BillingCountry.getDescribe().getLocalName(),
				Account.BillingPostalCode.getDescribe().getLocalName(),
				Account.BillingState.getDescribe().getLocalName(),
				Account.BillingStreet.getDescribe().getLocalName(),
				Account.CMN_AlternativeBusinessEmail__c.getDescribe().getLocalName(),
				Account.CMN_AlternativeBusinessEmail__c.getDescribe().getLocalName(),
				Account.CMN_AlternativeBusinessMobile__c.getDescribe().getLocalName(),
				Account.CMN_AlternativeEmail__c.getDescribe().getLocalName(),
				Account.CMN_AlternativeFax__c.getDescribe().getLocalName(),
				Account.CMN_AlternativeMobile__c.getDescribe().getLocalName(),
				Account.CMN_AlternativePhone__c.getDescribe().getLocalName(),
				Account.CMN_BusinessEmail__c.getDescribe().getLocalName(),
				Account.CMN_BusinessMobile__c.getDescribe().getLocalName(),
				Account.CMN_DateOfIncorporation__c.getDescribe().getLocalName(),
				Account.CMN_ForeignTradingName__c.getDescribe().getLocalName(),
				Account.CMN_OrganisationName__c.getDescribe().getLocalName(),
				Account.CMN_OrganisationType__c.getDescribe().getLocalName(),
				Account.CMN_PostalCareOf__pc.getDescribe().getLocalName(),
				Account.CMN_ResidentialCareOf__pc.getDescribe().getLocalName(),
				Account.CMN_SAResidentIndicator__c.getDescribe().getLocalName(),
				Account.CMN_TradingName__c.getDescribe().getLocalName(),
				Account.IsPersonAccount.getDescribe().getLocalName(),
				Account.Name.getDescribe().getLocalName(),
				Account.OwnerId.getDescribe().getLocalName(),
				Account.Phone.getDescribe().getLocalName(),
				Account.SLC_IDNumber__c.getDescribe().getLocalName(),
				Account.SLSC_IDType__c.getDescribe().getLocalName(),
				Account.ShippingAddress.getDescribe().getLocalName(),
				Account.ShippingCity.getDescribe().getLocalName(),
				Account.ShippingCountry.getDescribe().getLocalName(),
				Account.ShippingPostalCode.getDescribe().getLocalName(),
				Account.ShippingState.getDescribe().getLocalName(),
				Account.ShippingStreet.getDescribe().getLocalName(),
				FIELD_CORRESPONDENCE_PREFERENCE,
				FIELD_EMAIL_USAGE,
				FIELD_IS_REALLOCATED,
				FIELD_MOBILE_USAGE,
				FIELD_OWNER_CHANGED_DATE,
				FIELD_OWNER_CONSULTANT_CODE,
				FIELD_OWNER_EMAIL,
				FIELD_OWNER_UACFID,
				FIELD_PARENT_ACCOUNT_ID,
				FIELD_PHONE_USAGE,
				FIELD_RECORD_TYPE_NAME,
				FIELD_SKF_ID,
				FIELD_SOURCE_SYSTEM_NAME,
				FIELD_STATUS
		};
	}

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields for both business and person accounts
	 */
	private static Set<String> getAllDefaultFields()
	{
		Set<String> defaultFields = getBusinessDefaultFields();
		defaultFields.addAll
				(
						new Set<String>
						{
								Account.AW_AccountRecordType__c.getDescribe().getLocalName(),
								Account.AW_AdviserBranch__pc.getDescribe().getLocalName(),
								Account.AW_Age__pc.getDescribe().getLocalName(),
								Account.AW_AlternativeEmail__pc.getDescribe().getLocalName(),
								Account.AW_AnnualReviewDateCompleted__pc.getDescribe().getLocalName(),
								Account.AW_AnnualReviewDate__pc.getDescribe().getLocalName(),
								Account.AW_BankAccountHolderName__pc.getDescribe().getLocalName(),
								Account.AW_BankAccountNumber__pc.getDescribe().getLocalName(),
								Account.AW_BankAccountType__pc.getDescribe().getLocalName(),
								Account.AW_BankBranchCode__pc.getDescribe().getLocalName(),
								Account.AW_BankBranchName__pc.getDescribe().getLocalName(),
								Account.AW_BankName__pc.getDescribe().getLocalName(),
								Account.AW_Birthdate_for_Lead_Conversion__pc.getDescribe().getLocalName(),
								Account.AW_BirthdayMonth__pc.getDescribe().getLocalName(),
								Account.AW_EmployedBusinessOwner__pc.getDescribe().getLocalName(),
								Account.AW_ExpiryDate__pc.getDescribe().getLocalName(),
								Account.AW_FamilyId__pc.getDescribe().getLocalName(),
								Account.AW_FamilyMemberType__pc.getDescribe().getLocalName(),
								Account.AW_FifthName__pc.getDescribe().getLocalName(),
								Account.AW_FourthName__pc.getDescribe().getLocalName(),
								Account.AW_HobbyInterest__pc.getDescribe().getLocalName(),
								Account.AW_IdentificationNumber__pc.getDescribe().getLocalName(),
								Account.AW_Income__pc.getDescribe().getLocalName(),
								Account.AW_IssueDate__pc.getDescribe().getLocalName(),
								Account.AW_Maiden_Name__pc.getDescribe().getLocalName(),
								Account.AW_MedicalAidNumber__pc.getDescribe().getLocalName(),
								Account.AW_MedicalAidPlanName__pc.getDescribe().getLocalName(),
								Account.AW_MedicalPractitionerName__pc.getDescribe().getLocalName(),
								Account.AW_MedicalPractitionerTelNo__pc.getDescribe().getLocalName(),
								Account.AW_Mobile__c.getDescribe().getLocalName(),
								Account.AW_MonthtoNumber__pc.getDescribe().getLocalName(),
								Account.AW_Occupation__pc.getDescribe().getLocalName(),
								Account.AW_OnwerId__pc.getDescribe().getLocalName(),
								Account.AW_OtherHobbyInterest__pc.getDescribe().getLocalName(),
								Account.AW_PB_OccupationName__pc.getDescribe().getLocalName(),
								Account.AW_PassportCountryOfIssue__pc.getDescribe().getLocalName(),
								Account.AW_PositionRole__pc.getDescribe().getLocalName(),
								Account.AW_PostalAddressLineOne__pc.getDescribe().getLocalName(),
								Account.AW_PostalAddressLineThree__pc.getDescribe().getLocalName(),
								Account.AW_PostalAddressLineTwo__pc.getDescribe().getLocalName(),
								Account.AW_PostalCity__pc.getDescribe().getLocalName(),
								Account.AW_PostalCode__pc.getDescribe().getLocalName(),
								Account.AW_PostalCountry__pc.getDescribe().getLocalName(),
								Account.AW_PostalSuburb__pc.getDescribe().getLocalName(),
								Account.AW_ResidentialCity__pc.getDescribe().getLocalName(),
								Account.AW_ResidentialCountry__pc.getDescribe().getLocalName(),
								Account.AW_ResidentialPostalCode__pc.getDescribe().getLocalName(),
								Account.AW_ResidentialStreetLineOne__pc.getDescribe().getLocalName(),
								Account.AW_ResidentialStreetLineThree__pc.getDescribe().getLocalName(),
								Account.AW_ResidentialStreetLineTwo__pc.getDescribe().getLocalName(),
								Account.AW_ResidentialSuburb__pc.getDescribe().getLocalName(),
								Account.AW_RetirementDate__pc.getDescribe().getLocalName(),
								Account.AW_ReviewDone__pc.getDescribe().getLocalName(),
								Account.AW_ReviewMonth__pc.getDescribe().getLocalName(),
								Account.AW_Smoker__pc.getDescribe().getLocalName(),
								Account.AW_SyncErrorMessage__c.getDescribe().getLocalName(),
								Account.AW_TaxNumber__pc.getDescribe().getLocalName(),
								Account.AW_Tenure__pc.getDescribe().getLocalName(),
								Account.AW_ThirdName__pc.getDescribe().getLocalName(),
								Account.AW_TotalInvestmentAmount__c.getDescribe().getLocalName(),
								Account.AW_Username__pc.getDescribe().getLocalName(),
								Account.AW_WhatsApp__pc.getDescribe().getLocalName(),
								Account.CMN_AQCCode__pc.getDescribe().getLocalName(),
								Account.CMN_AlternativeBusinessEmail__pc.getDescribe().getLocalName(),
								Account.CMN_AlternativeBusinessMobile__pc.getDescribe().getLocalName(),
								Account.CMN_AlternativeFax__pc.getDescribe().getLocalName(),
								Account.CMN_AlternativeMobile__pc.getDescribe().getLocalName(),
								Account.CMN_AlternativePhone__pc.getDescribe().getLocalName(),
								Account.CMN_AlternativeWorkPhone__pc.getDescribe().getLocalName(),
								Account.CMN_BirthPlace__pc.getDescribe().getLocalName(),
								Account.CMN_BusinessEmail__pc.getDescribe().getLocalName(),
								Account.CMN_BusinessMobile__pc.getDescribe().getLocalName(),
								Account.CMN_CountryOfCitizenship__pc.getDescribe().getLocalName(),
								Account.CMN_CountryOfIncorporation__c.getDescribe().getLocalName(),
								Account.CMN_CountryOfResidence__pc.getDescribe().getLocalName(),
								Account.CMN_DateOfDeath__pc.getDescribe().getLocalName(),
								Account.CMN_DateOfDivorce__pc.getDescribe().getLocalName(),
								Account.CMN_IncomeType__pc.getDescribe().getLocalName(),
								Account.CMN_Income_Category__pc.getDescribe().getLocalName(),
								Account.CMN_Initials__pc.getDescribe().getLocalName(),
								Account.CMN_OccupationIndustry__pc.getDescribe().getLocalName(),
								Account.CMN_OccupationRiskCategory__pc.getDescribe().getLocalName(),
								Account.CMN_SourceOfFunds__pc.getDescribe().getLocalName(),
								Account.CMN_SourceOfWealth__pc.getDescribe().getLocalName(),
								Account.CMN_TaxPayingIndicator__pc.getDescribe().getLocalName(),
								Account.CMN_WorkPhone__pc.getDescribe().getLocalName(),
								Account.Fax.getDescribe().getLocalName(),
								Account.FinServ__AnnualIncome__pc.getDescribe().getLocalName(),
								Account.FinServ__ContactPreference__pc.getDescribe().getLocalName(),
								Account.FinServ__CountryOfResidence__pc.getDescribe().getLocalName(),
								Account.FinServ__CurrentEmployer__pc.getDescribe().getLocalName(),
								Account.FinServ__LanguagesSpoken__pc.getDescribe().getLocalName(),
								Account.FinServ__MotherMaidenName__pc.getDescribe().getLocalName(),
								Account.FinServ__Occupation__pc.getDescribe().getLocalName(),
								Account.FinServ__PreferredName__pc.getDescribe().getLocalName(),
								Account.FinServ__SourceSystemId__c.getDescribe().getLocalName(),
								Account.FinServ__Status__c.getDescribe().getLocalName(),
								Account.FinServ__WeddingAnniversary__pc.getDescribe().getLocalName(),
								Account.FirstName.getDescribe().getLocalName(),
								Account.IsPersonAccount.getDescribe().getLocalName(),
								Account.LastName.getDescribe().getLocalName(),
								Account.MiddleName.getDescribe().getLocalName(),
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
								Account.PersonTitle.getDescribe().getLocalName(),
								Account.Phone.getDescribe().getLocalName(),
								Account.Salutation.getDescribe().getLocalName(),
								FIELD_EDUCATION_LEVEL,
								FIELD_GENDER,
								FIELD_IDENTIFICATION_NUMBER,
								FIELD_IDENTIFICATION_TYPE,
								FIELD_MARITAL_STATUS,
								FIELD_OWNER_PROFILE,
								FIELD_PARENT_ID,
								FIELD_POSTAL_COUNTRY_NAME,
								FIELD_PRIMARY_LANGUAGE,
								FIELD_RACE,
								FIELD_RESIDENTIAL_COUNTRY_NAME
						}
				);

		return defaultFields;
	}

	/**
	 * @description This method is use to get the List of Account with given Identification Number
	 *
	 * @param identificationNumber Identity Number for Account
	 *
	 * @return null or an Account
	 */
	@TestVisible
	private static Account findByIdentityNumber(String identificationNumber)
	{
		List<Account> foundAccounts = findByIdentityNumber(new Set<String> {identificationNumber});
		return foundAccounts.isEmpty() ? null : foundAccounts.iterator().next();
	}

	/**
	 * @description This method is use to get the an Account without given Identification Number
	 *
	 * @param identificationNumber Identity Number for Account
	 *
	 * @return Null or item
	 */
	@TestVisible
	private static Account findAccountWithDifferentIdentificationNumber(String identificationNumber)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getAllDefaultFields());

		searchParameters.searchConditions.notEquals(FIELD_IDENTIFICATION_NUMBER, identificationNumber);

		List<Account> foundAccounts = CMN_DAL_Search.getObjects(searchParameters);

		return foundAccounts.isEmpty() ? null : foundAccounts.iterator().next();
	}

	/**
	 * @description This method is use to get the List of Account
	 *
	 * @param accountIds A List of account Ids
	 *
	 * @return List of items found
	 */
	public static List<Account> findById(Set<Id> accountIds)
	{
		return findById(accountIds, getAllDefaultFields());
	}

	/**
	 * @description This method is use to get the List of Account
	 *
	 * @param accountIds A List of account Ids
	 * @param requiredFields The fields that should be queried
	 *
	 * @return List of items found
	 */
	public static List<Account> findById(Set<Id> accountIds, Set<String> requiredFields)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, accountIds, requiredFields);
	}

	/**
	 * @description Gets an Account based on Id
	 *
	 * @param accountId Id of the account
	 *
	 * @return Null or Item
	 */
	public static Account findById(Id accountId)
	{
		return (Account)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, accountId, getAllDefaultFields());
	}

	/**
	 * @description This method is use to get the List of Account by Owner and Identification Number
	 *
	 * @param owner Account Owner
	 * @param identificationNumbers List of Identification Numbers
	 *
	 * @return List of items
	 */
	public static List<Account> findAccountsByOwnerAndIdNumbers(User owner, Set<String> identificationNumbers)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_IDENTIFICATION_NUMBER, identificationNumbers, getAllDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(CMN_DAL_SObjectDomain.FIELD_OWNER_ID, CMN_SOQL_Query.Operator.EQUALS, owner.Id));
		searchParameters.searchConditions.add(andCondition);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Will find any  master account by SKF Id
	 *
	 * @param skfIds A list of SKF ids
	 *
	 * @return list of items
	 */
	public static List<Account> findMasterBySkfId(Set<String> skfIds)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_SKF_ID, skfIds, getAllDefaultFields());

		searchParameters.searchConditions.inX(FIELD_RECORD_TYPE_NAME, CMN_UTIL_System.setToList(MASTER_ACCOUNT_RECORDTYPE_NAMES));
		searchParameters.searchConditions.equalsX(FIELD_PARENT_ACCOUNT_ID, null);

		return CMN_DAL_Search.getObjects(searchParameters);
	}
	/**
	 * @description Will find either a person or a business master accounts based on Ids provided
	 *
	 * @param skfIds A list of SKF ids
	 * @param isBusinessMaster A boolean to check if its a person account or business account
	 *
	 * @return list of items
	 */
	public static List<Account> findMasterBySkfId(Set<String> skfIds, Boolean isBusinessMaster)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters;
		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		Set<String> selectFields = isBusinessMaster ? getBusinessDefaultFields() : getAllDefaultFields();
		String recordTypeName = isBusinessMaster ? RT_BUSINESS_MASTER_ACCOUNT : RT_PERSON_MASTER_ACCOUNT;

		searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_SKF_ID, skfIds, selectFields);
		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_RECORD_TYPE_NAME, CMN_SOQL_Query.Operator.EQUALS, recordTypeName));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_PARENT_ACCOUNT_ID, CMN_SOQL_Query.Operator.EQUALS, null));

		searchParameters.searchConditions.add(andCondition);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Will find all active person accounts related by SKF Id
	 *
	 * @param skfId of the account
	 *
	 * @return A list of items
	 */
	public static List<Account> findActivePersonChildBySkfId(String skfId)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_SKF_ID, new Set<String> {skfId}, getAllDefaultFields());

		searchParameters.searchConditions.equalsX(FIELD_RECORD_TYPE_NAME, RT_PERSON_ACCOUNT);
		searchParameters.searchConditions.equalsX(FIELD_STATUS, STATUS_ACTIVE);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Will find all active business accounts related by SKF Id
	 *
	 * @param skfId of the account
	 *
	 * @return A list of items
	 */
	public static List<Account> findActiveBusinessChildBySkfId(String skfId)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_SKF_ID, new Set<String> {skfId}, getBusinessDefaultFields());

		searchParameters.searchConditions.equalsX(FIELD_RECORD_TYPE_NAME, RT_BUSINESS_ACCOUNT);
		searchParameters.searchConditions.equalsX(FIELD_STATUS, STATUS_ACTIVE);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Will find all active accounts related by a master account
	 *
	 * @param accountIds list of account ids
	 *
	 * @return List of items found
	 */
	public static List<Account> findActiveAccountWithParent(Set<Id> accountIds)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters
				(
						OBJECT_NAME,
						CMN_DAL_SObjectDomain.FIELD_ID,
						CMN_UTIL_System.convertIdSetToStringSet(accountIds),
						getBusinessDefaultFields()
				);

		searchParameters.searchConditions.notEquals(FIELD_PARENT_ACCOUNT_ID, null);
		searchParameters.searchConditions.equalsX(FIELD_STATUS, STATUS_ACTIVE);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method is use to get the record of Account with multiple related objects
	 *
	 * @param accountIds A set of account Ids
	 *
	 * @return a List of items
	 */
	public static List<Account> findByIdWithRelatedObjects(Set<Id> accountIds)
	{
		Set<String> requiredFields = new Set<String>
		{
				Account.PersonContactId.getDescribe().getLocalName(),
				FIELD_PARENT_ACCOUNT_ID,
				FIELD_PARENT_ID
		};

		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, requiredFields);
		searchParameters.searchConditions.inX(CMN_DAL_SObjectDomain.FIELD_ID, CMN_UTIL_System.setToList(accountIds));

		Set<String> financialGoalFields = new Set<String> {FIELD_MASTER_ACCOUNT_LOOKUP, AW_DAL_FinancialGoal.FIELD_PRIMARY_OWNER};
		Set<String> leadFields = new Set<String> {AW_DAL_Lead.FIELD_ADVISER_UACFID};
		Set<String> masterAccountFields = new Set<String> {FIELD_MASTER_ACCOUNT_LOOKUP};

		searchParameters.childSearchParameters.add(new CMN_DAL_Search.SOQLSearchParameters
						(
						AW_DAL_FinancialGoal.OBJECT_NAME,
						financialGoalFields,
						RELATED_FINANCIAL_GOALS
				));

		searchParameters.childSearchParameters.add(new CMN_DAL_Search.SOQLSearchParameters
						(
						AW_DAL_Lead.OBJECT_NAME,
						leadFields,
						'Leads__r'
				));

		Set<String> childRelationshipNames = new Set<String>(SUPPORTED_CHILD_RELATIONSHIPS);
		childRelationshipNames.remove(RELATED_FINANCIAL_GOALS);

		for(String childRelationshipName : childRelationshipNames)
		{
			searchParameters.childSearchParameters.add(new CMN_DAL_Search.SOQLSearchParameters
						(
							OBJECT_NAME, //Object Name doesn't matter for child queries
							masterAccountFields,
							childRelationshipName
					));
		}

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Will copy source account to parent field on child account
	 *
	 * @param sourceAccount Master Account
	 * @param destinationAccount Child Account
	 */
	@SuppressWarnings('PMD.CognitiveComplexity')
	public static void copyAccountData(Account sourceAccount, Account destinationAccount)
	{
		if(sourceAccount != null && destinationAccount != null)
		{
			//Ensure that the validation rule block updates don't fire
			destinationAccount.AW_BypassValidationRules__c = true;
			destinationAccount.AW_ParentAccount__c = sourceAccount.Id;
		}

	}

	/**
	 * @description This method is use to get all Non Masters Accounts with given Identity Numbers
	 *
	 * @param identityNumbers Person Identification Numbers
	 *
	 * @return All the accounts found
	 */
	public static List<Account> findByIdentityNumber(Set<String> identityNumbers)
	{
		Set<String> requiredFields = new Set<String>
		{
				CMN_DAL_SObjectDomain.FIELD_NAME,
				CMN_DAL_SObjectDomain.FIELD_OWNER_ID,
				FIELD_OWNER_CONSULTANT_CODE,
				FIELD_PARENT_ID,
				FIELD_RECORD_TYPE_NAME
		};

		requiredFields.addAll(getAllDefaultFields());

		List<String> identityNumberList = CMN_UTIL_System.setToList(CMN_UTIL_System.trimSet(identityNumbers));

		List<Account> foundBusinessAccounts;

		//We're running two queries, as we want to leverage the indexes on the Identity number fields and it appears when combining
		//Both person account and business account fields in a single query, it tends to only use one index
		if(!identityNumberList.isEmpty())
		{
			CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, requiredFields);

			List<String> allAccountRecordTypes = CMN_UTIL_System.setToList(ALL_ACCOUNT_RECORD_TYPES);

			searchParameters.searchConditions.inX(FIELD_RECORD_TYPE_NAME, allAccountRecordTypes);
			searchParameters.searchConditions.inX(FIELD_COMPANY_REGISTRATION_NUMBER, identityNumberList);

			foundBusinessAccounts = CMN_DAL_Search.getObjects(searchParameters);

			searchParameters.searchConditions = new CMN_SOQL_Query.AndCondition();

			searchParameters.searchConditions.inX(FIELD_RECORD_TYPE_NAME, allAccountRecordTypes);
			searchParameters.searchConditions.inX(FIELD_IDENTIFICATION_NUMBER, identityNumberList);

			List<Account> foundPersonAccounts = CMN_DAL_Search.getObjects(searchParameters);

			foundBusinessAccounts.addAll(foundPersonAccounts);
		}

		return foundBusinessAccounts == null ? new List<Account>() : foundBusinessAccounts;
	}

	/**
	 * @description This method is use to get the List of Account by Id with prediction scores //Investment & Risk Model//
	 *
	 * @param accountIds Set of Account Ids
	 *
	 * @return A list of items
	 */
	public static List<Account> findPredictionScoresById(Set<Id> accountIds)
	{
		Set<String> requiredFields = new Set<String>
		{
				Account.AW_PredictionAnnuityModelScore__c.getDescribe().getLocalName(),
				Account.AW_PredictionAnnuityModelStatus__c.getDescribe().getLocalName(),
				Account.AW_PredictionBondModelScore__c.getDescribe().getLocalName(),
				Account.AW_PredictionBondModelStatus__c.getDescribe().getLocalName(),
				Account.AW_PredictionEducationModelScore__c.getDescribe().getLocalName(),
				Account.AW_PredictionEducationModelStatus__c.getDescribe().getLocalName(),
				Account.AW_PredictionInvestmentModelScore__c.getDescribe().getLocalName(),
				Account.AW_PredictionInvestmentModelStatus__c.getDescribe().getLocalName(),
				Account.AW_PredictionRetirementModelScore__c.getDescribe().getLocalName(),
				Account.AW_PredictionRetirementModelStatus__c.getDescribe().getLocalName(),
				Account.AW_PredictionLifeCoverModelScore__c.getDescribe().getLocalName(),
				Account.AW_PredictionLifeCoverModelStatus__c.getDescribe().getLocalName(),
				Account.AW_PredictionPolicyPremiumModelScore__c.getDescribe().getLocalName(),
				Account.AW_PredictionPolicyPremiumModelStatus__c.getDescribe().getLocalName(),
				Account.AW_PredictionChildEducationModelScore__c.getDescribe().getLocalName(),
				Account.AW_PredictionChildEducationModelStatus__c.getDescribe().getLocalName(),
				Account.AW_PredictionPHDreadDiseaseScore__c.getDescribe().getLocalName(),
				Account.AW_PredictionPHDreadDiseaseModelStatus__c.getDescribe().getLocalName(),
				Account.AW_PredictionPHDisablementModelScore__c.getDescribe().getLocalName(),
				Account.AW_PredictionPHDisablementModelStatus__c.getDescribe().getLocalName(),
				Account.Name.getDescribe().getLocalName()
		};

		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, accountIds, requiredFields);
	}

	/**
	 * @description This method is used to get the records to be reallocated by soql query locator
	 *
	 * @param ownerProfileName Owner profile name
	 * @param accountOwnership Account Ownership value
	 * @param slaBreachedOn Datetime on which SLA breaches
	 *
	 * @return QueryLocator
	 *
	 * @author kiran.kumaryelisetti@lntinfotech.com
	 */
	public static Database.QueryLocator findRecordsToBeReallocatedQuery(String ownerProfileName, String accountOwnership, Datetime slaBreachedOn)
	{
		CMN_SOQL_Builder relatedActivities =
				new CMN_SOQL_Builder()
						.selectX(CMN_DAL_SObjectDomain.FIELD_ID)
						.fromX(CMN_DAL_SObjectDomain.RELATED_OPEN_ACTIVITIES);

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();
		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_OWNER_PROFILE, CMN_SOQL_Query.Operator.EQUALS, ownerProfileName));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_ACCOUNT_OWNERSHIP, CMN_SOQL_Query.Operator.EQUALS, accountOwnership));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_OWNER_CHANGED_DATE, CMN_SOQL_Query.Operator.LESS_THAN_OR_EQUAL_TO, slaBreachedOn));

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(CMN_DAL_SObjectDomain.FIELD_ID)
						.selectX(FIELD_ACCOUNT_OWNERSHIP)
						.selectX(FIELD_BRANCH_NAME)
						.selectX(FIELD_IS_REALLOCATED)
						.selectX(FIELD_OWNER_CHANGED_DATE)
						.selectX(FIELD_OWNER_UACFID)
						.selectX(FIELD_OWNER_PROFILE)
						.selectX(relatedActivities)
						.fromX(OBJECT_NAME)
						.whereX(andCondition);

		return Database.getQueryLocator(builder.toSoql());
	}

	/**
	 * @description Will return all Accounts created by unit tests
	 *
	 * @return A list of accounts
	 */
	@TestVisible
	private static List<Account> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getAllDefaultFields());
	}
	/**
	 * @description Will find a Account and include their related Insurance Policy and Financial Accounts
	 *
	 * @param accountIds A set of account Ids
	 *
	 * @return a list of found items
	 */
	public static List<Account> findByIdWithPolicyDetails(Set<Id> accountIds)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters
				(
						OBJECT_NAME,
						CMN_DAL_SObjectDomain.FIELD_ID,
						CMN_UTIL_System.convertIdSetToStringSet(accountIds),
						getAllDefaultFields()
				);

		searchParameters.childSearchParameters.add(new CMN_DAL_Search.SOQLSearchParameters
				(
						AW_DAL_FinancialAccount.OBJECT_NAME,
						AW_DAL_FinancialAccount.getDefaultFields(),
						RELATED_FINANCIAL_ACCOUNTS
				));

		searchParameters.childSearchParameters.add(new CMN_DAL_Search.SOQLSearchParameters
				(
						AW_DAL_InsurancePolicy.OBJECT_NAME,
						AW_DAL_InsurancePolicy.getDefaultFields(),
						RELATED_INSURANCE_POLICIES
				));

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Will find account by Id but bypassing sharing
	 *
	 * @param accountId The Id to filter on
	 * @param requiredFields A set of Required Fields
	 * 
	 * @return Null or the found Item
	 */
	public static Account findByIdWithoutSharing(Id accountId, Set<String> requiredFields)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, requiredFields);

		searchParameters.searchConditions.equalsX(CMN_DAL_SObjectDomain.FIELD_ID, accountId);
		searchParameters.enforceSharing = false;

		return (Account)CMN_DAL_SObjectSelector.first(CMN_DAL_Search.getObjects(searchParameters));
	}
}