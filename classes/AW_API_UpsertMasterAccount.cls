/**
 * @description API handler to support master account sync
 *
 * @see AW_URL_MasterAccount @story ST-128255, ST-173604
 * @see AW_API_UpsertMasterAccount_TEST
 *
 * @author jayanth.kumar.s@accenture.com pavan.t@lntinfotech.com
 *
 * @date May 2021, February 2023
 */
@SuppressWarnings('PMD.CognitiveComplexity,PMD.CyclomaticComplexity,PMD.StdCyclomaticComplexity,PMD.ExcessivePublicCount')
public inherited sharing class AW_API_UpsertMasterAccount extends CMN_API_RestBaseInbound
{
	private Account masterAccount = new Account();
	private Boolean isPersonAccount = false;
	private Map<String, SObject> countryByCodeMap;

	@TestVisible
	private static final String ERROR_UUID_NOT_PROVIDED = 'UUID was not provided with the request';
	@TestVisible
	private static final String PERSON_RECORD_TYPE = 'PERSON';
	@TestVisible
	private static final String BUSINESS_RECORD_TYPE = 'BUSINESS';
	@TestVisible
	private static final String MOBILE_TYPE = 'CELL';
	@TestVisible
	private static final String PHONE_TYPE = 'LL';
	@TestVisible
	private static final String FAX_TYPE = 'FAX';
	@TestVisible
	private static final String SA_RESIDENT_INDICATOR = 'Yes';
	@TestVisible
	private static final String PRIVATE_USAGE_TYPE = 'Private';
	@TestVisible
	private static final String ALTERNATIVE_PRIVATE_USAGE_TYPE = 'Alternative Private';
	@TestVisible
	private static final String BUSINESS_USAGE_TYPE = 'Business';
	@TestVisible
	private static final String ALTERNATIVE_BUSINESS_USAGE_TYPE = 'Alternative Business';
	@TestVisible
	private static final String USAGE_CODE_BUSINESS = 'BUS';
	@TestVisible
	private static final String USAGE_CODE_RESIDENTIAL = 'RES';
	@TestVisible
	private static final String USAGE_CODE_CORRESPONDENCE_CORR = 'CORR';
	@TestVisible
	private static final String USAGE_CODE_CORRESPONDENCE_CON = 'CON';
	@TestVisible
	private static final String STREET_FACILITY_CODE = 'STREET';
	@TestVisible
	private static final String FOREIGN_FACILITY_CODE = 'FOREIGN';
	@TestVisible
	private static final String PRIVATE_BAG_FACILITY_CODE = 'PRIVATE_BAG';
	@TestVisible
	private static final String POSTBOX_FACILITY_CODE = 'POSTBOX';
	@TestVisible
	private static final String SOUTH_AFRICAN_ID = 'South African ID';
	@TestVisible
	private static final String PASSPORT = 'Passport';
	@TestVisible
	private static final String TAX_NUMBER = 'TAX_NO';
	@TestVisible
	private static final String COMPANY_REGISTRATION_TRUST_NUMBER = 'Co Registration No';
	@TestVisible
	private static final String TRUST_REGISTRATION_NUMBER = 'Trust Registration Number';

	/**
	 * @description Class name of the web service handler
	 */
	public static final String SERVICE_NAME = AW_API_UpsertMasterAccount.class.getName();
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

		addSObjectTypes(new List<Schema.SObjectType> {Account.SObjectType});
	}

	/**
	 * @description Will check that the information received is valid and query any related data
	 */

	protected override void processRequest()
	{
		super.processRequest();

		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;
		isPersonAccount = PERSON_RECORD_TYPE.equalsIgnoreCase(dtoRequest.accountType);
		if(String.isNotEmpty(dtoRequest.uuid))
		{
			List<Account> foundAccounts = AW_DAL_Account.findMasterBySkfId(new Set<String> {dtoRequest.uuid}, !isPersonAccount);

			if(!foundAccounts.isEmpty())
			{
				masterAccount = foundAccounts.iterator().next();
			}
		}
		else
		{
			throw new SearchException(ERROR_UUID_NOT_PROVIDED);
		}
	}
	/**
	 * @description Will ensure that the change to master account is registered to be committed after
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;
		if(String.isBlank(masterAccount.Id))
		{

			String recordTypeName = isPersonAccount ? AW_DAL_Account.RT_PERSON_MASTER_ACCOUNT : AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT;
			masterAccount.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, recordTypeName);
		}

		populateAccountData(dtoRequest);
		registerChange(masterAccount);
		
		updateActiveChildAccounts();
	}
	/**
	 * @description populate account data
	 *
	 * @param dtoRequest The DTO that represents the JSON sent in a request
	 */
	private void populateAccountData(DTO_Request dtoRequest)
	{
		countryByCodeMap = AW_DAL_Country.getCodeMap();
		populateAccountDetails(dtoRequest);
		populateAddressDetails(dtoRequest.addresses);
		populateTelephoneDetails(dtoRequest.telephones);
		populateEmailDetails(dtoRequest.emailAddresses);
		populateOccupationDetails(dtoRequest.occupations);
		populateRegistrationDetails(dtoRequest.registrations);
	}
	/**
	 * @description Will ensure that the change to master account is registered to be committed after
	 */
	private void updateActiveChildAccounts()
	{
		//Execute different queries as we don't want person account fields to be retrieved with business accounts this will cause update errors
		List<Account> childAccounts = isPersonAccount ?
				AW_DAL_Account.findActivePersonChildBySkfId(masterAccount.AW_SKF_Id__c) : AW_DAL_Account.findActiveBusinessChildBySkfId(masterAccount.AW_SKF_Id__c);

		for(Account childAccount : childAccounts)
		{
			AW_DAL_Account.copyAccountData(masterAccount, childAccount);
			registerDirty(childAccount, Account.AW_ParentAccount__c, masterAccount);
		}
	}

	/**
	 * @description Will populate general information on Master account
	 *
	 * @param dtoRequest The DTO that represents the JSON sent in a request
	 */
	private void populateAccountDetails(DTO_Request dtoRequest)
	{
		if(isPersonAccount)
		{
			masterAccount.FirstName = dtoRequest.firstName;
			masterAccount.MiddleName = dtoRequest.secondName;
			masterAccount.LastName = dtoRequest.lastName;
			masterAccount.Salutation = dtoRequest.salutation;
			masterAccount.AW_ThirdName__pc = dtoRequest.thirdName;
			masterAccount.AW_FourthName__pc = dtoRequest.fourthName;
			masterAccount.AW_FifthName__pc = dtoRequest.fifthName;
			masterAccount.AW_Maiden_Name__pc = dtoRequest.maidenName;
			masterAccount.FinServ__PreferredName__pc = dtoRequest.preferredName;
			masterAccount.FinServ__Gender__pc = dtoRequest.gender;
			masterAccount.FinServ__MaritalStatus__pc = dtoRequest.maritalStatus;
			masterAccount.FinServ__WeddingAnniversary__pc = dtoRequest.marriageDate;
			masterAccount.PersonBirthdate = dtoRequest.birthDate;
			masterAccount.AW_EducationLevel__pc = dtoRequest.qualification;
			masterAccount.CMN_SAResidentIndicator__c = dtoRequest.saResidentIndicator;
			masterAccount.AW_Income__pc = dtoRequest.annualGrossIncomeAmount;
			masterAccount.FinServ__AnnualIncome__pc = dtoRequest.annualNettIncomeAmount;
			masterAccount.AW_RetirementDate__pc = dtoRequest.retirementDate;
			masterAccount.AW_Race__pc = dtoRequest.race;
			masterAccount.FinServ__PrimaryLanguage__pc = dtoRequest.preferredLanguage;
			masterAccount.CMN_BirthPlace__pc = dtoRequest.birthPlace;
			masterAccount.CMN_CountryOfResidence__pc = dtoRequest.countryOfResidenceDescription;
			masterAccount.CMN_IncomeType__pc = dtoRequest.incomeTypeCode;
			masterAccount.CMN_Income_Category__pc = dtoRequest.incomeCategoryCode;
			masterAccount.CMN_SourceOfFunds__pc = dtoRequest.sourceOfFundsCode;
			masterAccount.CMN_SourceOfWealth__pc = dtoRequest.sourceOfWealthCode;
			masterAccount.CMN_DateOfDeath__pc = dtoRequest.deceasedDt;
			masterAccount.CMN_TaxPayingIndicator__pc = dtoRequest.taxPayingInd;
			masterAccount.CMN_Initials__pc = dtoRequest.initials;
			masterAccount.CMN_DateOfDivorce__pc = dtoRequest.divorceDt;
			masterAccount.AW_Country_Of_Birth__c = ((AW_Country__c)countryByCodeMap.get(dtoRequest.countryOfBirth))?.Id;
		}
		else
		{
			masterAccount.Name = dtoRequest.name;
			masterAccount.AW_CompanyRegistrationTrustNumber__c = dtoRequest.companyRegistrationTrustNumber;

			masterAccount.CMN_OrganisationType__c = dtoRequest.organizationTypeCode;
			masterAccount.CMN_CountryOfIncorporation__c = dtoRequest.countryOfIncorporationDescription;
			masterAccount.CMN_OrganisationName__c = dtoRequest.orgNm;
			masterAccount.CMN_TradingName__c = dtoRequest.tradingNm;
			masterAccount.CMN_DateOfIncorporation__c = dtoRequest.incorpDt;
			masterAccount.CMN_ForeignTradingName__c = dtoRequest.foreignTradingNm;
			masterAccount.AW_Suffix__c = dtoRequest.suffixDescription;
		}

		masterAccount.AW_CorrespondencePreference__c = dtoRequest.correspondencePreference;
		masterAccount.AW_SKF_Id__c = dtoRequest.uuid;
		masterAccount.AW_Source_System_Name__c = AW_DAL_Account.SKF_SOURCE_SYSTEM;
	}

	/**
	 * @description Will populate address information on Master account
	 *
	 * @param dtoAddresses The List of Address DTOs
	 */
	private void populateAddressDetails(List<DTO_Address> dtoAddresses)
	{
		if(dtoAddresses != null)
		{
			dtoAddresses.sort();
			for(DTO_Address dtoAddress : dtoAddresses)
			{
				if(isPersonAccount)
				{
					if(isPostalAddress(dtoAddress))
					{
						masterAccount.CMN_PostalCareOf__pc = dtoAddress.careOf;
						masterAccount.AW_PostalAddressLineOne__pc = dtoAddress.addressLine1;
						masterAccount.AW_PostalAddressLineTwo__pc = dtoAddress.addressLine2;
						masterAccount.AW_PostalAddressLineThree__pc = dtoAddress.addressLine3;
						masterAccount.AW_PostalSuburb__pc = dtoAddress.subTown;
						masterAccount.AW_PostalCode__pc = dtoAddress.postalCode;
						masterAccount.AW_PostalCity__pc = dtoAddress.town;
						masterAccount.AW_PostalCountry__pc = ((AW_Country__c)countryByCodeMap.get(dtoAddress.country))?.Id;
					}
					else if(USAGE_CODE_RESIDENTIAL.equalsIgnoreCase(dtoAddress.usageCode) && (STREET_FACILITY_CODE.equalsIgnoreCase(dtoAddress.facilityCode)
							|| FOREIGN_FACILITY_CODE.equalsIgnoreCase(dtoAddress.facilityCode)))
					{
						masterAccount.CMN_ResidentialCareOf__pc = dtoAddress.careOf;
						masterAccount.AW_ResidentialStreetLineOne__pc = dtoAddress.addressLine1;
						masterAccount.AW_ResidentialStreetLineTwo__pc = dtoAddress.addressLine2;
						masterAccount.AW_ResidentialStreetLineThree__pc = dtoAddress.addressLine3;
						masterAccount.AW_ResidentialSuburb__pc = dtoAddress.subTown;
						masterAccount.AW_ResidentialPostalCode__pc = dtoAddress.postalCode;
						masterAccount.AW_ResidentialCity__pc = dtoAddress.town;
						masterAccount.AW_ResidentialCountry__pc = ((AW_Country__c)countryByCodeMap.get(dtoAddress.country))?.Id;
					}
				}
				else
				{
					if(isPostalAddress(dtoAddress))
					{
						masterAccount.AW_PostalAddressLineOne__c = dtoAddress.addressLine1;
						masterAccount.AW_PostalAddressLineTwo__c = dtoAddress.addressLine2;
						masterAccount.AW_PostalAddressLineThree__c = dtoAddress.addressLine3;
						masterAccount.AW_PostalSuburb__c = dtoAddress.subTown;
						masterAccount.AW_PostalCity__c = dtoAddress.town;
						masterAccount.AW_PostalCode__c = dtoAddress.postalCode;
						masterAccount.AW_PostalCountry__c = ((AW_Country__c)countryByCodeMap.get(dtoAddress.country))?.Id;
					}
					else if((USAGE_CODE_BUSINESS.equalsIgnoreCase(dtoAddress.usageCode) || USAGE_CODE_RESIDENTIAL.equalsIgnoreCase(dtoAddress.usageCode))
							&& (STREET_FACILITY_CODE.equalsIgnoreCase(dtoAddress.facilityCode) || (FOREIGN_FACILITY_CODE.equalsIgnoreCase(dtoAddress.facilityCode))))
					{
						masterAccount.AW_PhysicalStreetLineOne__c = dtoAddress.addressLine1;
						masterAccount.AW_PhysicalStreetLineTwo__c = dtoAddress.addressLine2;
						masterAccount.AW_PhysicalStreetLineThree__c = dtoAddress.addressLine3;
						masterAccount.AW_PhysicalSuburb__c = dtoAddress.subTown;
						masterAccount.AW_PhysicalCity__c = dtoAddress.town;
						masterAccount.AW_PhysicalPostalCode__c = dtoAddress.postalCode;
						masterAccount.AW_PhysicalCountry__c = ((AW_Country__c)countryByCodeMap.get(dtoAddress.country))?.Id;
					}
				}
			}
		}
	}

	/**
	 * @description Will check the address details and determine if the address is a postal address or not
	 *
	 * @param dtoAddress Address DTO
	 *
	 * @return True if a postal address
	 */
	private static Boolean isPostalAddress(DTO_Address dtoAddress)
	{
		return (USAGE_CODE_CORRESPONDENCE_CORR.equalsIgnoreCase(dtoAddress.usageCode) || USAGE_CODE_CORRESPONDENCE_CON.equalsIgnoreCase(dtoAddress.usageCode))
				&& (STREET_FACILITY_CODE.equalsIgnoreCase(dtoAddress.facilityCode) || FOREIGN_FACILITY_CODE.equalsIgnoreCase(dtoAddress.facilityCode)
				|| PRIVATE_BAG_FACILITY_CODE.equalsIgnoreCase(dtoAddress.facilityCode) || POSTBOX_FACILITY_CODE.equalsIgnoreCase(dtoAddress.facilityCode));
	}

	/**
	 * @description Will populate telephone information on Master account
	 *
	 * @param dtoTelephones The List of Telephone DTOs
	 */
	@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity, PMD.AvoidDeeplyNestedIfStmts')
	private void populateTelephoneDetails(List<DTO_Telephone> dtoTelephones)
	{
		//The list of DTO Telephone will store the telephone array records in the ascending order
		if(dtoTelephones != null)
		{
			dtoTelephones.sort();
			for(DTO_Telephone telephone : dtoTelephones)
			{
				if(isPersonAccount)
				{
					if(telephone.facilityCode == MOBILE_TYPE)
					{
						if(telephone.usageCode == PRIVATE_USAGE_TYPE) //Usage : Private
						{
							masterAccount.PersonMobilePhone = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
						else if(telephone.usageCode == BUSINESS_USAGE_TYPE) //Usage : Business
						{
							masterAccount.CMN_BusinessMobile__pc = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
						else if(telephone.usageCode == ALTERNATIVE_PRIVATE_USAGE_TYPE) //Usage : Alternative Private
						{
							masterAccount.CMN_AlternativeMobile__pc = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
						else if(telephone.usageCode == ALTERNATIVE_BUSINESS_USAGE_TYPE) //Usage : Alternative Business
						{
							masterAccount.CMN_AlternativeBusinessMobile__pc = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
					}
					else if(telephone.facilityCode == PHONE_TYPE)
					{
						if(telephone.usageCode == PRIVATE_USAGE_TYPE) //Usage : Private
						{
							masterAccount.Phone = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
						else if(telephone.usageCode == BUSINESS_USAGE_TYPE) //Usage : Business
						{
							masterAccount.CMN_WorkPhone__pc = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
						else if(telephone.usageCode == ALTERNATIVE_PRIVATE_USAGE_TYPE) //Usage : Alternative Private
						{
							masterAccount.CMN_AlternativePhone__pc = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
						else if(telephone.usageCode == ALTERNATIVE_BUSINESS_USAGE_TYPE) //Usage : Alternative Business
						{
							masterAccount.CMN_AlternativeWorkPhone__pc = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
					}
					else if(telephone.facilityCode == FAX_TYPE)
					{
						if(telephone.usageCode == PRIVATE_USAGE_TYPE) //Usage : Private
						{
							masterAccount.Fax = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
						else if(telephone.usageCode == ALTERNATIVE_PRIVATE_USAGE_TYPE) //Usage : Alternative Private
						{
							masterAccount.CMN_AlternativeFax__pc = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
					}
				}
				else
				{
					if(telephone.facilityCode == MOBILE_TYPE)
					{
						if(telephone.usageCode == PRIVATE_USAGE_TYPE) //Usage : Private
						{
							masterAccount.AW_Mobile__c = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
						else if(telephone.usageCode == BUSINESS_USAGE_TYPE) //Usage : Business
						{
							masterAccount.CMN_BusinessMobile__c = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
						else if(telephone.usageCode == ALTERNATIVE_PRIVATE_USAGE_TYPE) //Usage : Alternative Private
						{
							masterAccount.CMN_AlternativeMobile__c = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
						else if(telephone.usageCode == ALTERNATIVE_BUSINESS_USAGE_TYPE) //Usage : Alternative Business
						{
							masterAccount.CMN_AlternativeBusinessMobile__c = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
					}
					else if(telephone.facilityCode == PHONE_TYPE)
					{
						if(telephone.usageCode == BUSINESS_USAGE_TYPE) //Usage : Business
						{
							masterAccount.Phone = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
						else if(telephone.usageCode == ALTERNATIVE_BUSINESS_USAGE_TYPE) //Usage : Alternative Business
						{
							masterAccount.CMN_AlternativePhone__c = telephone.telephoneNumber;
							masterAccount.AW_ContactPreference__c = telephone.contactPreference;
						}
					}
					else if(telephone.facilityCode == FAX_TYPE)
					{
						if(telephone.usageCode == BUSINESS_USAGE_TYPE) //Usage : Business
						{
							masterAccount.Fax = telephone.telephoneNumber;
						}
						else if(telephone.usageCode == ALTERNATIVE_BUSINESS_USAGE_TYPE) //Usage : Alternative Business
						{
							masterAccount.CMN_AlternativeFax__c = telephone.telephoneNumber;
						}
					}
				}
			}
		}
	}

	/**
	 * @description Will populate email information on Master account
	 *
	 * @param dtoEmailAddress List of Email DTOs
	 */
	@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
	private void populateEmailDetails(List<DTO_EmailAddress> dtoEmailAddress)
	{
		//The list of DTO Email Address will store the Email Address array records in the ascending order
		if(dtoEmailAddress != null)
		{
			dtoEmailAddress.sort();
			for(DTO_EmailAddress emailAddress : dtoEmailAddress)
			{
				if(isPersonAccount)
				{
					if(emailAddress.usageCode == PRIVATE_USAGE_TYPE) //Usage : Private
					{
						masterAccount.PersonEmail = emailAddress.emailAddress;
					}
					else if(emailAddress.usageCode == BUSINESS_USAGE_TYPE) //Usage : Business
					{
						masterAccount.CMN_BusinessEmail__pc = emailAddress.emailAddress;
					}
					else if(emailAddress.usageCode == ALTERNATIVE_PRIVATE_USAGE_TYPE) //Usage : Alternative Private
					{
						masterAccount.AW_AlternativeEmail__pc = emailAddress.emailAddress;
					}
					else if(emailAddress.usageCode == ALTERNATIVE_BUSINESS_USAGE_TYPE) //Usage : Alternative Business
					{
						masterAccount.CMN_AlternativeBusinessEmail__pc = emailAddress.emailAddress;
					}
				}
				else
				{
					if(emailAddress.usageCode == PRIVATE_USAGE_TYPE) //Usage : Private
					{
						masterAccount.AW_Email__c = emailAddress.emailAddress;
					}
					else if(emailAddress.usageCode == BUSINESS_USAGE_TYPE) //Usage : Business
					{
						masterAccount.CMN_BusinessEmail__c = emailAddress.emailAddress;
					}
					else if(emailAddress.usageCode == ALTERNATIVE_PRIVATE_USAGE_TYPE) //Usage : Alternative Private
					{
						masterAccount.CMN_AlternativeEmail__c = emailAddress.emailAddress;
					}
					else if(emailAddress.usageCode == ALTERNATIVE_BUSINESS_USAGE_TYPE) //Usage : Alternative Business
					{
						masterAccount.CMN_AlternativeBusinessEmail__c = emailAddress.emailAddress;
					}
				}
			}
		}
	}

	/**
	 * @description Will populate occupation information on Master account
	 *
	 * @param dtoOccupations List of Occupation DTOs
	 */
	private void populateOccupationDetails(List<DTO_Occupations> dtoOccupations)
	{
		if(dtoOccupations != null)
		{
			//The list of DTO Occupations will store the occupation array records in the ascending order
			dtoOccupations.sort();
			for(DTO_Occupations occupations : dtoOccupations)
			{
				if(isPersonAccount)
				{
					AW_Occupation__c occupation = AW_DAL_Occupation.findByOccupationCode(occupations.occupation);
					masterAccount.AW_Occupation__pc = occupation?.Id;
					masterAccount.CMN_OccupationIndustry__pc = occupations.occupationIndustry;
					masterAccount.CMN_OccupationRiskCategory__pc = occupations.occupationRiskCategory;
				}
			}
		}
	}

	/**
	 * @description Will populate registration information on Master account
	 *
	 * @param dtoRegistrations List of Registration DTOs
	 */
	private void populateRegistrationDetails(List<DTO_Registrations> dtoRegistrations)
	{
		if(dtoRegistrations != null)
		{
			Boolean isIdentificationNumber = false;

			//The list of DTO Registrations will store the registration array records in the ascending order
			dtoRegistrations.sort();
			for(DTO_Registrations registrations : dtoRegistrations)
			{
				if(isPersonAccount)
				{
					masterAccount.CMN_CountryOfCitizenship__pc = registrations.citizenshipOfDescription;
					if(registrations.registrationTypeDescription == TAX_NUMBER)
					{
						masterAccount.AW_TaxNumber__pc = registrations.taxNumber;
					}

					/* If isIdentificationNumber is true then the Identification Type and Identification Number fields need to be mapped
					against the respective values under the registration array with the registrationTypeDescription = ID Number even if the
					registrationTypeDescription == PASSPORT is the latest entry in the array */
					if(registrations.registrationTypeDescription == SOUTH_AFRICAN_ID)
					{
						isIdentificationNumber = true;
						masterAccount.AW_IdentificationType__pc = registrations.registrationTypeDescription;
						masterAccount.AW_IdentificationNumber__pc = registrations.regNo;
						masterAccount.AW_PassportCountryOfIssue__pc = null;
						masterAccount.AW_IssueDate__pc = null;
						masterAccount.AW_ExpiryDate__pc = null;
					}
					else if(!isIdentificationNumber && registrations.registrationTypeDescription == PASSPORT)
					{
						masterAccount.AW_IdentificationType__pc = registrations.registrationTypeDescription;
						masterAccount.AW_IdentificationNumber__pc = registrations.regNo;
						masterAccount.AW_PassportCountryOfIssue__pc = ((AW_Country__c)countryByCodeMap.get(registrations.passportCountryOfIssue))?.Id;
						masterAccount.AW_IssueDate__pc = registrations.issueDt;
						masterAccount.AW_ExpiryDate__pc = registrations.expDt;
					}
				}
				else if(registrations.registrationTypeDescription == COMPANY_REGISTRATION_TRUST_NUMBER ||
						registrations.registrationTypeDescription == TRUST_REGISTRATION_NUMBER)
				{
					masterAccount.AW_CompanyRegistrationTrustNumber__c = registrations.regNo;
				}
			}
		}
	}

	/**
	 * @description The DTO representing the request being sent
	 */
	@TestVisible
	@SuppressWarnings('PMD.TooManyFields, PMD.ExcessivePublicCount')
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public Date birthDate;
		public Date deceasedDt;
		public Date divorceDt;
		public Date incorpDt;
		public Date marriageDate;
		public Date retirementDate;
		public Integer annualGrossIncomeAmount;
		public Integer annualNettIncomeAmount;
		public List<DTO_Address> addresses;
		public List<DTO_EmailAddress> emailAddresses;
		public List<DTO_Occupations> occupations;
		public List<DTO_Registrations> registrations;
		public List<DTO_Telephone> telephones;
		public String accountType;
		public String birthPlace;
		public String companyRegistrationTrustNumber;
		public String correspondencePreference;
		public String countryOfBirth;
		public String countryOfIncorporationDescription;
		public String countryOfResidenceDescription;
		public String fifthName;
		public String firstName;
		public String foreignTradingNm;
		public String fourthName;
		public String gender;
		public String identificationNumber;
		public String identificationType;
		public String incomeCategoryCode;
		public String incomeTypeCode;
		public String initials;
		public String lastName;
		public String maidenName;
		public String maritalStatus;
		public String name;
		public String occupation;
		public String orgNm;
		public String organizationTypeCode;
		@SuppressWarnings('ApexUnusedDeclaration')
		public String passportCountryOfIssue;
		public String preferredLanguage;
		public String preferredName;
		public String qualification;
		public String race;
		public String saResidentIndicator;
		public String salutation;
		public String secondName;
		public String sourceOfFundsCode;
		public String sourceOfWealthCode;
		public String suffixDescription;
		public String taxPayingInd;
		public String thirdName;
		public String tradingNm;
		public String uuid;

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

	/**
	 * @description Class representing an address
	 */
	@TestVisible
	private class DTO_Address implements Comparable
	{
		public String facilityCode;
		public String addressLine1;
		public String addressLine2;
		public String addressLine3;
		public String postalCode;
		public String country;
		public String subTown;
		public String town;
		public String careOf;
		public String usageCode;
		public Datetime addressSysStartTime;

		/**
		 * @description The implementation of this method returns the following values:
		 * <p/>
		 * 0 if this instance and objectToCompareTo are equal
		 * > 0 if this instance is greater than objectToCompareTo
		 * < 0 if this instance is less than objectToCompareTo
		 * If this object instance and objectToCompareTo are incompatible, a System.TypeException is thrown
		 *
		 * @param compareTo Object instance
		 *
		 * @return Returns an Integer value that is the result of the comparison.
		 */
		public Integer compareTo(Object compareTo)
		{
			DTO_Address dtoAddress = (DTO_Address)compareTo;

			if(addressSysStartTime > dtoAddress.addressSysStartTime)
			{
				return 1;
			}
			else if(addressSysStartTime < dtoAddress.addressSysStartTime)
			{
				return -1;
			}
			else
			{
				return 0;
			}
		}
	}

	/**
	 * @description Class representing a telephone
	 */
	@TestVisible
	private class DTO_Telephone implements Comparable
	{
		public String usageCode;
		public String facilityCode;
		public String telephoneNumber;
		public Datetime telephoneSysStartTime;
		public String contactPreference;

		/**
		 * @description The implementation of this method returns the following values:
		 * <p/>
		 * 0 if this instance and objectToCompareTo are equal
		 * > 0 if this instance is greater than objectToCompareTo
		 * < 0 if this instance is less than objectToCompareTo
		 * If this object instance and objectToCompareTo are incompatible, a System.TypeException is thrown
		 *
		 * @param compareTo Object instance
		 *
		 * @return Returns an Integer value that is the result of the comparison.
		 */
		public Integer compareTo(Object compareTo)
		{
			DTO_Telephone dtoTelephone = (DTO_Telephone)compareTo;

			if(telephoneSysStartTime > dtoTelephone.telephoneSysStartTime)
			{
				return 1;
			}
			else if(telephoneSysStartTime < dtoTelephone.telephoneSysStartTime)
			{
				return -1;
			}
			else
			{
				return 0;
			}
		}
	}

	/**
	 * @description Class representing an email address
	 */
	@TestVisible
	private class DTO_EmailAddress implements Comparable
	{
		public String usageCode;
		public String emailAddress;
		public Datetime emailsSysStartTime;

		/**
		 * @description The implementation of this method returns the following values:
		 * <p/>
		 * 0 if this instance and objectToCompareTo are equal
		 * > 0 if this instance is greater than objectToCompareTo
		 * < 0 if this instance is less than objectToCompareTo
		 * If this object instance and objectToCompareTo are incompatible, a System.TypeException is thrown
		 *
		 * @param compareTo Object instance
		 *
		 * @return Returns an Integer value that is the result of the comparison.
		 */
		public Integer compareTo(Object compareTo)
		{
			DTO_EmailAddress dtoEmailAddress = (DTO_EmailAddress)compareTo;

			if(emailsSysStartTime > dtoEmailAddress.emailsSysStartTime)
			{
				return 1;
			}
			else if(emailsSysStartTime < dtoEmailAddress.emailsSysStartTime)
			{
				return -1;
			}
			else
			{
				return 0;
			}
		}
	}

	/**
	 * @description Class representing occupations
	 */
	@TestVisible
	private class DTO_Occupations implements Comparable
	{
		public String occupation;
		public String occupationIndustry;
		public String occupationRiskCategory;
		public Datetime occupationSysStartTime;

		/**
		 * @description The implementation of this method returns the following values:
		 * <p/>
		 * 0 if this instance and objectToCompareTo are equal
		 * > 0 if this instance is greater than objectToCompareTo
		 * < 0 if this instance is less than objectToCompareTo
		 * If this object instance and objectToCompareTo are incompatible, a System.TypeException is thrown
		 *
		 * @param compareTo Object instance
		 *
		 * @return Returns an Integer value that is the result of the comparison.
		 */
		public Integer compareTo(Object compareTo)
		{
			DTO_Occupations dtoOccupations = (DTO_Occupations)compareTo;

			if(occupationSysStartTime > dtoOccupations.occupationSysStartTime)
			{
				return 1;
			}
			else if(occupationSysStartTime < dtoOccupations.occupationSysStartTime)
			{
				return -1;
			}
			else
			{
				return 0;
			}
		}
	}

	/**
	 * @description Class representing registrations
	 */
	@TestVisible
	private class DTO_Registrations implements Comparable
	{
		public String citizenshipOfDescription;
		public String regNo;
		public Datetime registrationsSysStartTime;
		public String taxNumber;
		public String registrationTypeDescription;
		public String passportCountryOfIssue;
		public Date issueDt;
		public Date expDt;

		/**
		 * @description The implementation of this method returns the following values:
		 * <p/>
		 * 0 if this instance and objectToCompareTo are equal
		 * > 0 if this instance is greater than objectToCompareTo
		 * < 0 if this instance is less than objectToCompareTo
		 * If this object instance and objectToCompareTo are incompatible, a System.TypeException is thrown
		 *
		 * @param compareTo Object instance
		 *
		 * @return Returns an Integer value that is the result of the comparison.
		 */
		public Integer compareTo(Object compareTo)
		{
			DTO_Registrations dtoRegistrations = (DTO_Registrations)compareTo;

			if(registrationsSysStartTime > dtoRegistrations.registrationsSysStartTime)
			{
				return 1;
			}
			else if(registrationsSysStartTime < dtoRegistrations.registrationsSysStartTime)
			{
				return -1;
			}
			else
			{
				return 0;
			}
		}
	}

	/**
	 * @description DTO representing a successful response
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		//public String message = MASTER_ACCOUNT_SYNC;
	}
}