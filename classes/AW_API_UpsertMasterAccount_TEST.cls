/**
 * @description Will test the inbound service class AW_API_UpsertMasterAccount
 *
 * @see AW_API_UpsertMasterAccount
 *
 * @author nihal.desai@accenture.com pavan.t@lntinfotech.com
 *
 * @date May 2021, February 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class AW_API_UpsertMasterAccount_TEST
{
	private static final Datetime TIME_NOW = System.now();
	private static final Integer DEFAULT_INITIALS_LEN = 2;

	/**
	 * @description set up test data
	 */
	@TestSetup
	private static void setup()
	{
		AW_DAL_TestDataFactory.loadAddresses();
	}

	/**
	 * @description Will check that a person account is inserted successfully
	 */
	@IsTest
	private static void insertPersonMaster()
	{
		AW_API_UpsertMasterAccount.DTO_Request dtoRequest = populateDtoRequestData(AW_UTIL_IdentityNumber.generateRandomIdentityNumber(), true);
		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_MasterAccount.masterAccountSync();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_UpsertMasterAccount.SERVICE_NAME);
		List<Account> foundAccounts = AW_DAL_Account.findMasterBySkfId(new Set<String> {dtoRequest.uuid});
		Assert.isFalse(foundAccounts.isEmpty(), 'Master Account was not inserted as expected');

		Account foundAccount = foundAccounts.iterator().next();

		Assert.areEqual(dtoRequest.fourthName, foundAccount.AW_FourthName__pc, 'Fourth Name was not set correctly');
		Assert.areEqual(dtoRequest.gender, foundAccount.FinServ__Gender__pc, 'Gender was not set correctly');
	}

	/**
	 * @description Will check that a business account is inserted successfully
	 */
	@IsTest
	private static void insertBusinessMaster()
	{
		AW_API_UpsertMasterAccount.DTO_Request dtoRequest = populateDtoRequestData(CMN_UTIL_String.EMPTY, false);
		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_MasterAccount.masterAccountSync();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_UpsertMasterAccount.SERVICE_NAME);
		List<Account> foundAccounts = AW_DAL_Account.findMasterBySkfId(new Set<String> {dtoRequest.uuid});
		Assert.isFalse(foundAccounts.isEmpty(), 'Master Account was not inserted as expected');

		Account foundAccount = foundAccounts.iterator().next();

		Assert.areEqual
				(
						dtoRequest.companyRegistrationTrustNumber,
						foundAccount.AW_CompanyRegistrationTrustNumber__c,
						'Company Registration was not set correctly'
				);
		Assert.areEqual(dtoRequest.correspondencePreference, foundAccount.AW_CorrespondencePreference__c, 'Preference was not set correctly');
	}

	/**
	 * @description Will check that a person account is updated successfully
	 */
	@IsTest
	private static void updatePersonMaster()
	{
		Account childAccount = AW_DAL_TestDataFactory.createPersonChildAccountWithMaster();

		AW_API_UpsertMasterAccount.DTO_Request dtoRequest = populateDtoRequestData(childAccount.AW_IdentificationNumber__pc, true);
		dtoRequest.uuid = childAccount.AW_SKF_Id__c;

		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_MasterAccount.masterAccountSync();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_UpsertMasterAccount.SERVICE_NAME);

		Account updatedMasterAccount = AW_DAL_Account.findMasterBySkfId(new Set<String> {dtoRequest.uuid}, false).iterator().next();
		Account updatedChildAccount = AW_DAL_Account.findActivePersonChildBySkfId(updatedMasterAccount.AW_SKF_Id__c).iterator().next();

		Assert.areEqual(updatedMasterAccount.AW_FourthName__pc, dtoRequest.fourthName, 'Fourth Name not set correctly');
		Assert.areEqual(updatedChildAccount.AW_ParentAccount__c, updatedMasterAccount.Id, 'parent account not set correctly');
	}

	/**
	 * @description Will check that a business account is updated successfully
	 */
	@IsTest
	private static void updateBusinessMaster()
	{
		Account childAccount = AW_DAL_TestDataFactory.createBusinessChildAccountWithMaster();

		AW_API_UpsertMasterAccount.DTO_Request dtoRequest = populateDtoRequestData(CMN_UTIL_String.EMPTY, false);
		dtoRequest.uuid = childAccount.AW_SKF_Id__c;

		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_MasterAccount.masterAccountSync();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_UpsertMasterAccount.SERVICE_NAME);

		Account updatedMasterAccount = AW_DAL_Account.findMasterBySkfId(new Set<String> {dtoRequest.uuid}, true).iterator().next();
		Account updatedChildAccount = AW_DAL_Account.findActiveBusinessChildBySkfId(updatedMasterAccount.AW_SKF_Id__c).iterator().next();

		Assert.areEqual(dtoRequest.name, updatedMasterAccount.Name, 'Name not set correctly');
		Assert.areEqual(updatedMasterAccount.Id, updatedChildAccount.AW_ParentAccount__c, 'Parent account not set correctly');
	}

	/**
	 * @description Will test that exception is thrown if the UUID not provided
	 */
	@IsTest
	private static void skfIdNotProvided()
	{
		AW_API_UpsertMasterAccount.DTO_Request dtoRequest = populateDtoRequestData(AW_UTIL_IdentityNumber.generateRandomIdentityNumber(), true);
		dtoRequest.uuid = CMN_UTIL_String.EMPTY;
		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_MasterAccount.masterAccountSync();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(AW_API_UpsertMasterAccount.SERVICE_NAME, AW_API_UpsertMasterAccount.ERROR_UUID_NOT_PROVIDED);
	}

	/**
	 * @description Will populate the dtoRequest data
	 *
	 * @param identificationNumber identification number value
	 * @param isPersonAccount isPersonAccount value
	 *
	 * @return dtoRequest
	 */
	@SuppressWarnings('PMD.NcssMethodCount')
	private static AW_API_UpsertMasterAccount.DTO_Request populateDtoRequestData(String identificationNumber, Boolean isPersonAccount)
	{
		AW_API_UpsertMasterAccount.DTO_Request dtoRequest = new AW_API_UpsertMasterAccount.DTO_Request();
		List<AW_API_UpsertMasterAccount.DTO_Address> addresses = new List <AW_API_UpsertMasterAccount.DTO_Address> ();
		AW_Country__c country = AW_DAL_Country.findByName(AW_DAL_Country.SOUTH_AFRICA);
		String countryCode = String.valueOf(country.AW_CountryCode__c);

		List<AW_API_UpsertMasterAccount.DTO_EmailAddress> emailAddressList = new List<AW_API_UpsertMasterAccount.DTO_EmailAddress> ();

		List<AW_API_UpsertMasterAccount.DTO_Telephone> telephoneList = new List<AW_API_UpsertMasterAccount.DTO_Telephone> ();

		List<AW_API_UpsertMasterAccount.DTO_Occupations> occupations = new List<AW_API_UpsertMasterAccount.DTO_Occupations> ();

		dtoRequest.uuid = CMN_DAL_SObjectDomain.generateRandomNumber();

		if(isPersonAccount)
		{
			dtoRequest.accountType = AW_API_UpsertMasterAccount.PERSON_RECORD_TYPE;

			dtoRequest.firstName = CMN_DAL_SObjectDomain.generateRandomName();
			dtoRequest.secondName = CMN_DAL_SObjectDomain.generateRandomName();
			dtoRequest.lastName = CMN_DAL_SObjectDomain.generateRandomName();
			dtoRequest.salutation = AW_DAL_Account.PICK_SALUTATION_MR;
			dtoRequest.thirdName = CMN_DAL_SObjectDomain.generateRandomName();
			dtoRequest.fourthName = CMN_DAL_SObjectDomain.generateRandomName();
			dtoRequest.fifthName = CMN_DAL_SObjectDomain.generateRandomName();
			dtoRequest.maidenName = CMN_DAL_SObjectDomain.generateRandomName();
			dtoRequest.preferredName = CMN_DAL_SObjectDomain.generateRandomName();
			dtoRequest.initials = CMN_UTIL_Random.randomAlphabetic(DEFAULT_INITIALS_LEN);
			dtoRequest.gender = AW_UTIL_IdentityNumber.getGenderFromIdentityNumber(identificationNumber);
			dtoRequest.maritalStatus = AW_DAL_Account.PICK_MARRIED;
			dtoRequest.marriageDate = Date.today();
			dtoRequest.preferredLanguage = AW_DAL_TestDataFactory.PRIMARY_LANGUAGE;
			dtoRequest.birthDate = AW_UTIL_IdentityNumber.extractDateOfBirthFromIdentityNumber(identificationNumber);
			dtoRequest.qualification = AW_DAL_Account.EDUCATION_LEVEL_MATRIC;
			dtoRequest.saResidentIndicator = AW_API_UpsertMasterAccount.SA_RESIDENT_INDICATOR;
			dtoRequest.annualGrossIncomeAmount = CMN_DAL_SObjectDomain.generateRandomInteger();
			dtoRequest.annualNettIncomeAmount = CMN_DAL_SObjectDomain.generateRandomInteger();
			dtoRequest.retirementDate = Date.today();
			dtoRequest.race = AW_DAL_TestDataFactory.PICK_RACE_WHITE;
			dtoRequest.correspondencePreference = AW_DAL_TestDataFactory.CORRESPONDENCE_PREFERENCE;

			addresses.add(populateAddressDtoData(AW_API_UpsertMasterAccount.FOREIGN_FACILITY_CODE, AW_API_UpsertMasterAccount.USAGE_CODE_RESIDENTIAL,
					countryCode, System.now()));
			addresses.add(populateAddressDtoData(AW_API_UpsertMasterAccount.FOREIGN_FACILITY_CODE, AW_API_UpsertMasterAccount.USAGE_CODE_RESIDENTIAL,
					countryCode, System.now().addDays(1)));
			addresses.add
					(populateAddressDtoData(AW_API_UpsertMasterAccount.POSTBOX_FACILITY_CODE, AW_API_UpsertMasterAccount.USAGE_CODE_CORRESPONDENCE_CON,
							countryCode, System.now()));
			addresses.add
					(populateAddressDtoData(AW_API_UpsertMasterAccount.POSTBOX_FACILITY_CODE, AW_API_UpsertMasterAccount.USAGE_CODE_CORRESPONDENCE_CON,
							countryCode, TIME_NOW));
			addresses.add
					(populateAddressDtoData(AW_API_UpsertMasterAccount.POSTBOX_FACILITY_CODE, AW_API_UpsertMasterAccount.USAGE_CODE_CORRESPONDENCE_CON,
							countryCode, TIME_NOW));
			dtoRequest.addresses = addresses;

			dtoRequest.birthPlace = SC_DAL_DataFactory.PLACE_OF_BIRTH;
			dtoRequest.countryOfResidenceDescription = SC_DAL_DataFactory.COUNTRY_SOUTH_AFRICA;
			dtoRequest.incomeTypeCode = SC_DAL_DataFactory.INCOME_TYPE;
			dtoRequest.incomeCategoryCode = SC_DAL_DataFactory.INCOME_CATEGORY;
			dtoRequest.sourceOfFundsCode = SC_DAL_DataFactory.SOURCE_OF_FUNDS;
			dtoRequest.sourceOfWealthCode = SC_DAL_DataFactory.SOURCE_OF_WEALTH;
			dtoRequest.taxPayingInd = SC_DAL_DataFactory.TAX_PAYING_INDICATOR;
			dtoRequest.deceasedDt = null;
			dtoRequest.divorceDt = null;

			//OCCUPATION MAPPING:
			AW_API_UpsertMasterAccount.DTO_Occupations occupation1 = populateOccupationData(System.now());
			occupations.add(occupation1);

			AW_API_UpsertMasterAccount.DTO_Occupations occupation2 = populateOccupationData(System.now().addDays(1));
			occupations.add(occupation2);

			AW_API_UpsertMasterAccount.DTO_Occupations occupation3 = populateOccupationData(System.now());
			occupations.add(occupation3);

			AW_API_UpsertMasterAccount.DTO_Occupations occupation4 = populateOccupationData(System.now().addDays(-1));
			occupations.add(occupation4);

			AW_API_UpsertMasterAccount.DTO_Occupations occupation5 = populateOccupationData(System.now());
			occupations.add(occupation5);

			dtoRequest.occupations = occupations;

			//EMAIL ADDRESS MAPPING:
			AW_API_UpsertMasterAccount.DTO_EmailAddress privateEmailAddress = populateEmailAddressData(AW_API_UpsertMasterAccount.PRIVATE_USAGE_TYPE, System.now());
			emailAddressList.add(privateEmailAddress);

			AW_API_UpsertMasterAccount.DTO_EmailAddress privateEmailAddress1 = populateEmailAddressData(AW_API_UpsertMasterAccount.PRIVATE_USAGE_TYPE, System.now());
			emailAddressList.add(privateEmailAddress1);

			AW_API_UpsertMasterAccount.DTO_EmailAddress businessEmailAddress = populateEmailAddressData(AW_API_UpsertMasterAccount.BUSINESS_USAGE_TYPE, System.now());
			emailAddressList.add(businessEmailAddress);

			AW_API_UpsertMasterAccount.DTO_EmailAddress businessEmailAddress1 =
					populateEmailAddressData(AW_API_UpsertMasterAccount.BUSINESS_USAGE_TYPE, System.now().addDays(1));
			emailAddressList.add(businessEmailAddress1);

			AW_API_UpsertMasterAccount.DTO_EmailAddress alternativePrivateBusinessEmailAddress =
					populateEmailAddressData(AW_API_UpsertMasterAccount.ALTERNATIVE_PRIVATE_USAGE_TYPE, System.now());
			emailAddressList.add(alternativePrivateBusinessEmailAddress);

			AW_API_UpsertMasterAccount.DTO_EmailAddress alternativeBusinessEmailAddress =
					populateEmailAddressData(AW_API_UpsertMasterAccount.ALTERNATIVE_BUSINESS_USAGE_TYPE, System.now());
			emailAddressList.add(alternativeBusinessEmailAddress);

			dtoRequest.emailAddresses = emailAddressList;

			//MOBILE, PHONE AND FAX MAPPING:

			//1.Mobile

			AW_API_UpsertMasterAccount.DTO_Telephone mobileDetail =
					populateTelephoneData(AW_DAL_TestDataFactory.MOBILE_USAGE, AW_API_UpsertMasterAccount.MOBILE_TYPE, System.now());
			mobileDetail.contactPreference = AW_DAL_TestDataFactory.CONTACT_PREFERENCE;
			telephoneList.add(mobileDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone privateMobileDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.PRIVATE_USAGE_TYPE, AW_API_UpsertMasterAccount.MOBILE_TYPE, TIME_NOW);
			telephoneList.add(privateMobileDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone privateMobileDetail1 =
					populateTelephoneData(AW_API_UpsertMasterAccount.PRIVATE_USAGE_TYPE, AW_API_UpsertMasterAccount.MOBILE_TYPE, TIME_NOW);
			telephoneList.add(privateMobileDetail1);

			AW_API_UpsertMasterAccount.DTO_Telephone privateMobileDetail2 =
					populateTelephoneData(AW_API_UpsertMasterAccount.PRIVATE_USAGE_TYPE, AW_API_UpsertMasterAccount.MOBILE_TYPE, System.now().addDays(1));
			telephoneList.add(privateMobileDetail2);

			AW_API_UpsertMasterAccount.DTO_Telephone alternateBusinessMobileDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.ALTERNATIVE_BUSINESS_USAGE_TYPE, AW_API_UpsertMasterAccount.MOBILE_TYPE, System.now());
			telephoneList.add(alternateBusinessMobileDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone alternatePrivateMobileDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.ALTERNATIVE_PRIVATE_USAGE_TYPE, AW_API_UpsertMasterAccount.MOBILE_TYPE, System.now());
			telephoneList.add(alternatePrivateMobileDetail);

			//2.Phone

			AW_API_UpsertMasterAccount.DTO_Telephone telephoneDetail =
					populateTelephoneData(AW_DAL_TestDataFactory.PHONE_USAGE, AW_API_UpsertMasterAccount.PHONE_TYPE, System.now());
			telephoneList.add(telephoneDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone privateTelephoneDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.PRIVATE_USAGE_TYPE, AW_API_UpsertMasterAccount.PHONE_TYPE, System.now());
			telephoneList.add(privateTelephoneDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone alternateBusinessTelephoneDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.ALTERNATIVE_BUSINESS_USAGE_TYPE, AW_API_UpsertMasterAccount.PHONE_TYPE, System.now());
			telephoneList.add(alternateBusinessTelephoneDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone alternatePrivateTelephoneDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.ALTERNATIVE_PRIVATE_USAGE_TYPE, AW_API_UpsertMasterAccount.PHONE_TYPE, System.now());
			telephoneList.add(alternatePrivateTelephoneDetail);

			//3.Fax

			AW_API_UpsertMasterAccount.DTO_Telephone privateFaxDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.PRIVATE_USAGE_TYPE, AW_API_UpsertMasterAccount.FAX_TYPE, System.now());
			telephoneList.add(privateFaxDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone alternatePrivateFaxDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.ALTERNATIVE_PRIVATE_USAGE_TYPE, AW_API_UpsertMasterAccount.FAX_TYPE, System.now());
			telephoneList.add(alternatePrivateFaxDetail);

			dtoRequest.telephones = telephoneList;
		}
		else
		{
			dtoRequest.accountType = AW_API_UpsertMasterAccount.BUSINESS_RECORD_TYPE;
			dtoRequest.name = CMN_DAL_SObjectDomain.generateRandomName();
			dtoRequest.companyRegistrationTrustNumber = CMN_DAL_SObjectDomain.generateRandomNumber();
			dtoRequest.correspondencePreference = AW_DAL_TestDataFactory.CORRESPONDENCE_PREFERENCE;
			addresses.add
					(populateAddressDtoData(AW_API_UpsertMasterAccount.PRIVATE_BAG_FACILITY_CODE, AW_API_UpsertMasterAccount.USAGE_CODE_CORRESPONDENCE_CORR,
							countryCode, System.now()));
			addresses.add(populateAddressDtoData(AW_API_UpsertMasterAccount.FOREIGN_FACILITY_CODE, AW_API_UpsertMasterAccount.USAGE_CODE_BUSINESS,
					countryCode, System.now()));

			dtoRequest.addresses = addresses;

			dtoRequest.organizationTypeCode = SC_DAL_DataFactory.ORGANISATION_TYPE;
			dtoRequest.countryOfIncorporationDescription = SC_DAL_DataFactory.COUNTRY_SOUTH_AFRICA;
			dtoRequest.orgNm = CMN_DAL_SObjectDomain.generateRandomName();
			dtoRequest.tradingNm = CMN_DAL_SObjectDomain.generateRandomName();
			dtoRequest.foreignTradingNm = CMN_DAL_SObjectDomain.generateRandomName();
			dtoRequest.incorpDt = Date.today();
			dtoRequest.suffixDescription = CMN_DAL_SObjectDomain.generateRandomName();

			//EMAIL ADDRESS MAPPING:

			AW_API_UpsertMasterAccount.DTO_EmailAddress privateEmailAddress =
					populateEmailAddressData(AW_API_UpsertMasterAccount.PRIVATE_USAGE_TYPE, System.now());
			emailAddressList.add(privateEmailAddress);

			AW_API_UpsertMasterAccount.DTO_EmailAddress businessEmailAddress =
					populateEmailAddressData(AW_API_UpsertMasterAccount.BUSINESS_USAGE_TYPE, System.now());
			emailAddressList.add(businessEmailAddress);

			AW_API_UpsertMasterAccount.DTO_EmailAddress alternatePrivateEmailAddress =
					populateEmailAddressData(AW_API_UpsertMasterAccount.ALTERNATIVE_PRIVATE_USAGE_TYPE, TIME_NOW);
			emailAddressList.add(alternatePrivateEmailAddress);

			AW_API_UpsertMasterAccount.DTO_EmailAddress alternateBusinessEmailAddress =
					populateEmailAddressData(AW_API_UpsertMasterAccount.ALTERNATIVE_BUSINESS_USAGE_TYPE, System.now());
			emailAddressList.add(alternateBusinessEmailAddress);

			AW_API_UpsertMasterAccount.DTO_EmailAddress alternativePrivateBusinessEmailAddress =
					populateEmailAddressData(AW_API_UpsertMasterAccount.ALTERNATIVE_PRIVATE_USAGE_TYPE, TIME_NOW);
			emailAddressList.add(alternativePrivateBusinessEmailAddress);

			AW_API_UpsertMasterAccount.DTO_EmailAddress alternativeBusinessEmailAddress =
					populateEmailAddressData(AW_API_UpsertMasterAccount.ALTERNATIVE_BUSINESS_USAGE_TYPE, System.now());
			emailAddressList.add(alternativeBusinessEmailAddress);

			dtoRequest.emailAddresses = emailAddressList;

			//MOBILE, PHONE AND FAX MAPPING:

			AW_API_UpsertMasterAccount.DTO_Telephone mobileDetail =
					populateTelephoneData(AW_DAL_TestDataFactory.MOBILE_USAGE, AW_API_UpsertMasterAccount.MOBILE_TYPE, System.now());
			telephoneList.add(mobileDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone privateMobileDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.PRIVATE_USAGE_TYPE, AW_API_UpsertMasterAccount.MOBILE_TYPE, System.now());
			telephoneList.add(privateMobileDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone alternatePrivateMobileDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.PRIVATE_USAGE_TYPE, AW_API_UpsertMasterAccount.MOBILE_TYPE, System.now());
			telephoneList.add(alternatePrivateMobileDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone alternateBusinessMobileDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.ALTERNATIVE_BUSINESS_USAGE_TYPE, AW_API_UpsertMasterAccount.MOBILE_TYPE, System.now());
			telephoneList.add(alternateBusinessMobileDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone alternativePrivateMobileDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.ALTERNATIVE_PRIVATE_USAGE_TYPE, AW_API_UpsertMasterAccount.MOBILE_TYPE, System.now());
			telephoneList.add(alternativePrivateMobileDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone telephoneDetail =
					populateTelephoneData(AW_DAL_TestDataFactory.PHONE_USAGE, AW_API_UpsertMasterAccount.PHONE_TYPE, System.now());
			telephoneList.add(telephoneDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone alternateBusinessTelephoneDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.ALTERNATIVE_BUSINESS_USAGE_TYPE, AW_API_UpsertMasterAccount.PHONE_TYPE, System.now());
			telephoneList.add(alternateBusinessTelephoneDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone businessFaxDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.BUSINESS_USAGE_TYPE, AW_API_UpsertMasterAccount.FAX_TYPE, System.now());
			telephoneList.add(businessFaxDetail);

			AW_API_UpsertMasterAccount.DTO_Telephone alternateBusinessFaxDetail =
					populateTelephoneData(AW_API_UpsertMasterAccount.ALTERNATIVE_BUSINESS_USAGE_TYPE, AW_API_UpsertMasterAccount.FAX_TYPE, System.now());
			telephoneList.add(alternateBusinessFaxDetail);

			dtoRequest.telephones = telephoneList;
		}
		return dtoRequest;
	}

	/**
	 * @description Will generate registration data of type ID Number for request dto along with the other fields.
	 *
	 * @return dtoRequest
	 */
	private static AW_API_UpsertMasterAccount.DTO_Request populateIDNumberData()
	{
		AW_API_UpsertMasterAccount.DTO_Request dtoRequest = populateDtoRequestData(AW_UTIL_IdentityNumber.generateRandomIdentityNumber(), true);

		List<AW_API_UpsertMasterAccount.DTO_Registrations> registrations = new List<AW_API_UpsertMasterAccount.DTO_Registrations> ();

		AW_API_UpsertMasterAccount.DTO_Registrations registrationIDNumber = new AW_API_UpsertMasterAccount.DTO_Registrations();
		registrationIDNumber.citizenshipOfDescription = SC_DAL_DataFactory.COUNTRY_SOUTH_AFRICA;
		registrationIDNumber.registrationTypeDescription = AW_API_UpsertMasterAccount.SOUTH_AFRICAN_ID;
		registrationIDNumber.regNo = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
		registrationIDNumber.registrationsSysStartTime = System.now();
		registrations.add(registrationIDNumber);

		AW_API_UpsertMasterAccount.DTO_Registrations registrationTaxNumber = new AW_API_UpsertMasterAccount.DTO_Registrations();
		registrationTaxNumber.registrationTypeDescription = AW_API_UpsertMasterAccount.TAX_NUMBER;
		registrationTaxNumber.taxNumber = CMN_DAL_SObjectDomain.generateRandomNumber();
		registrationTaxNumber.registrationsSysStartTime = System.now();
		registrations.add(registrationTaxNumber);

		dtoRequest.registrations = registrations;

		return dtoRequest;
	}

	/**
	 * @description Will generate registration data of type Passport for request dto along with the other fields.
	 *
	 * @return dtoRequest
	 */
	private static AW_API_UpsertMasterAccount.DTO_Request populatePassportData()
	{
		AW_Country__c country = AW_DAL_Country.findByName(AW_DAL_Country.SOUTH_AFRICA);
		String countryCode = String.valueOf(country.AW_CountryCode__c);
		AW_API_UpsertMasterAccount.DTO_Request dtoRequest = populateDtoRequestData(AW_UTIL_IdentityNumber.generateRandomIdentityNumber(), true);

		List<AW_API_UpsertMasterAccount.DTO_Registrations> registrations = new List<AW_API_UpsertMasterAccount.DTO_Registrations> ();

		AW_API_UpsertMasterAccount.DTO_Registrations registrationPassport = new AW_API_UpsertMasterAccount.DTO_Registrations();
		registrationPassport.citizenshipOfDescription = SC_DAL_DataFactory.COUNTRY_SOUTH_AFRICA;
		registrationPassport.registrationTypeDescription = AW_API_UpsertMasterAccount.PASSPORT;
		registrationPassport.regNo = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
		registrationPassport.issueDt = System.today();
		registrationPassport.expDt = System.today();
		registrationPassport.passportCountryOfIssue = countryCode;
		registrationPassport.registrationsSysStartTime = System.now();
		registrations.add(registrationPassport);

		dtoRequest.registrations = registrations;

		return dtoRequest;
	}

	/**
	 * @description Will generate registration data of type Company Reg No for request dto along with the other fields.
	 *
	 * @return dtoRequest
	 */
	private static AW_API_UpsertMasterAccount.DTO_Request populateCompanyRegTrustNumber()
	{
		AW_API_UpsertMasterAccount.DTO_Request dtoRequest = populateDtoRequestData(CMN_UTIL_String.EMPTY, false);

		List<AW_API_UpsertMasterAccount.DTO_Registrations> registrations = new List<AW_API_UpsertMasterAccount.DTO_Registrations> ();

		AW_API_UpsertMasterAccount.DTO_Registrations registrationCompanyRegTrustNumber1 = populateCompanyRegOrTrustRegNumber
				(AW_API_UpsertMasterAccount.COMPANY_REGISTRATION_TRUST_NUMBER, TIME_NOW);
		registrations.add(registrationCompanyRegTrustNumber1);

		AW_API_UpsertMasterAccount.DTO_Registrations registrationCompanyRegTrustNumber2 = populateCompanyRegOrTrustRegNumber
				(AW_API_UpsertMasterAccount.COMPANY_REGISTRATION_TRUST_NUMBER, TIME_NOW);
		registrations.add(registrationCompanyRegTrustNumber2);

		AW_API_UpsertMasterAccount.DTO_Registrations registrationCompanyRegTrustNumber3 = populateCompanyRegOrTrustRegNumber
				(AW_API_UpsertMasterAccount.COMPANY_REGISTRATION_TRUST_NUMBER, System.now().addDays(1));
		registrations.add(registrationCompanyRegTrustNumber3);

		AW_API_UpsertMasterAccount.DTO_Registrations registrationCompanyRegTrustNumber4 = populateCompanyRegOrTrustRegNumber
				(AW_API_UpsertMasterAccount.COMPANY_REGISTRATION_TRUST_NUMBER, System.now().addDays(-2));
		registrations.add(registrationCompanyRegTrustNumber4);

		dtoRequest.registrations = registrations;

		return dtoRequest;
	}

	/**
	 * @description Will generate registration data of type Trust Reg No for request dto along with the other fields.
	 *
	 * @return dtoRequest
	 */
	private static AW_API_UpsertMasterAccount.DTO_Request populateTrustRegistrationNumber()
	{
		AW_API_UpsertMasterAccount.DTO_Request dtoRequest = populateDtoRequestData(CMN_UTIL_String.EMPTY, false);

		List<AW_API_UpsertMasterAccount.DTO_Registrations> registrations = new List<AW_API_UpsertMasterAccount.DTO_Registrations> ();

		AW_API_UpsertMasterAccount.DTO_Registrations trustRegistrationNumber1 = populateCompanyRegOrTrustRegNumber
				(AW_API_UpsertMasterAccount.TRUST_REGISTRATION_NUMBER, TIME_NOW);
		registrations.add(trustRegistrationNumber1);

		AW_API_UpsertMasterAccount.DTO_Registrations trustRegistrationNumber2 = populateCompanyRegOrTrustRegNumber
				(AW_API_UpsertMasterAccount.TRUST_REGISTRATION_NUMBER, System.now().addDays(1));
		registrations.add(trustRegistrationNumber2);

		AW_API_UpsertMasterAccount.DTO_Registrations trustRegistrationNumber3 = populateCompanyRegOrTrustRegNumber
				(AW_API_UpsertMasterAccount.TRUST_REGISTRATION_NUMBER, System.now().addDays(-2));
		registrations.add(trustRegistrationNumber3);

		dtoRequest.registrations = registrations;

		return dtoRequest;
	}

	/**
	 * @description Will check that a person account is inserted successfully with registration type as ID Number
	 */
	@IsTest
	private static void insertPersonMasterWithRegistrationIDNumber()
	{
		AW_API_UpsertMasterAccount.DTO_Request dtoRequest = populateIDNumberData();
		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_MasterAccount.masterAccountSync();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_UpsertMasterAccount.SERVICE_NAME);
		List<Account> foundAccounts = AW_DAL_Account.findMasterBySkfId(new Set<String> {dtoRequest.uuid});
		Assert.isFalse(foundAccounts.isEmpty(), 'Master Account was not inserted as expected');

		Account foundAccount = foundAccounts.iterator().next();

		Assert.areEqual(AW_API_UpsertMasterAccount.SOUTH_AFRICAN_ID, foundAccount.AW_IdentificationType__pc, 'The Identification Type is not South African ID');
		Assert.isNotNull(foundAccount.AW_TaxNumber__pc, 'Tax Number is not populated');
	}

	/**
	 * @description Will check that a person account is inserted successfully with registration type as ID Number
	 */
	@IsTest
	private static void insertPersonMasterWithRegistrationPassport()
	{
		AW_API_UpsertMasterAccount.DTO_Request dtoRequest = populatePassportData();
		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_MasterAccount.masterAccountSync();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_UpsertMasterAccount.SERVICE_NAME);
		List<Account> foundAccounts = AW_DAL_Account.findMasterBySkfId(new Set<String> {dtoRequest.uuid});
		Assert.isFalse(foundAccounts.isEmpty(), 'Master Account was not inserted as expected');

		Account foundAccount = foundAccounts.iterator().next();
		Assert.areEqual(AW_API_UpsertMasterAccount.PASSPORT, foundAccount.AW_IdentificationType__pc, 'The Identification Type is not Passport');
	}

	/**
	 * @description Will check that a business account is inserted successfully and Company Registration Number is populated
	 */
	@IsTest
	private static void insertBusinessMasterWithCompanyRegOrTrustRegNumber()
	{
		AW_API_UpsertMasterAccount.DTO_Request dtoRequest = populateCompanyRegTrustNumber();
		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_MasterAccount.masterAccountSync();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_UpsertMasterAccount.SERVICE_NAME);
		List<Account> foundAccounts = AW_DAL_Account.findMasterBySkfId(new Set<String> {dtoRequest.uuid});
		Assert.isFalse(foundAccounts.isEmpty(), 'Master Account was not inserted as expected');

		Account foundAccount = foundAccounts.iterator().next();
		Assert.isNotNull(foundAccount.AW_CompanyRegistrationTrustNumber__c, 'Company Registration Trust Number not populated');
	}

	/**
	 * @description Will check that a business account is inserted successfully and Trust Registration Number is populated
	 */
	@IsTest
	private static void insertBusinessMasterWithTrustRegistrationNumber()
	{
		AW_API_UpsertMasterAccount.DTO_Request dtoRequest = populateTrustRegistrationNumber();
		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_MasterAccount.masterAccountSync();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_UpsertMasterAccount.SERVICE_NAME);
		List<Account> foundAccounts = AW_DAL_Account.findMasterBySkfId(new Set<String> {dtoRequest.uuid});
		Assert.isFalse(foundAccounts.isEmpty(), 'Master Account was not inserted as expected');

		Account foundAccount = foundAccounts.iterator().next();
		Assert.isNotNull(foundAccount.AW_CompanyRegistrationTrustNumber__c, 'Trust Registration Number not populated');
	}

	/**
	 * @description Will generate address data for request dto.
	 *
	 * @param facilityCode facility code value
	 * @param usageCode Usage Code value
	 * @param countryCode Country Code value
	 * @param systemTime System Start Time
	 *
	 * @return address
	 */
	private static AW_API_UpsertMasterAccount.DTO_Address populateAddressDtoData(String facilityCode, String usageCode, String countryCode, Datetime systemTime)
	{
		AW_API_UpsertMasterAccount.DTO_Address address = new AW_API_UpsertMasterAccount.DTO_Address();

		AW_DAL_TestDataFactory.TestAddress testResidentialAddress = AW_DAL_TestDataFactory.getTestAddress();

		address.facilityCode = facilityCode;
		address.addressLine1 = testResidentialAddress.street;
		address.addressLine2 = testResidentialAddress.street;
		address.addressLine3 = testResidentialAddress.street;
		address.subTown = testResidentialAddress.city;
		address.country = countryCode;
		address.postalCode = testResidentialAddress.postalCode;
		address.town = testResidentialAddress.city;
		address.usageCode = usageCode;
		address.addressSysStartTime = systemTime;

		return address;
	}

	/**
	 * @description Will populate the test data needed for Occupations DTO
	 *
	 * @param daysValue Registrations startTime value
	 *
	 * @return occupation
	 */
	private static AW_API_UpsertMasterAccount.DTO_Occupations populateOccupationData(Datetime daysValue)
	{
		AW_API_UpsertMasterAccount.DTO_Occupations occupation = new AW_API_UpsertMasterAccount.DTO_Occupations();
		occupation.occupation = AW_DAL_TestDataFactory.getOccupation().AW_OccupationCode__c;
		occupation.occupationIndustry = SC_DAL_DataFactory.OCCUPATION_INDUSTRY;
		occupation.occupationRiskCategory = SC_DAL_DataFactory.OCCUPATION_RISK_CATEGORY;
		occupation.occupationSysStartTime = daysValue;

		return occupation;
	}

	/**
	 * @description Will populate the test data needed for registrations DTO
	 *
	 * @param regNumberType Registration number type COMPANY_REGISTRATION_TRUST_NUMBER or TRUST_REGISTRATION_NUMBER
	 * @param daysValue Registrations startTime value
	 *
	 * @return companyOrTrustRegNumber
	 */
	private static AW_API_UpsertMasterAccount.DTO_Registrations populateCompanyRegOrTrustRegNumber(String regNumberType, Datetime daysValue)
	{
		AW_API_UpsertMasterAccount.DTO_Registrations companyOrTrustRegNumber = new AW_API_UpsertMasterAccount.DTO_Registrations();
		companyOrTrustRegNumber.registrationTypeDescription = regNumberType;
		companyOrTrustRegNumber.regNo = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
		companyOrTrustRegNumber.registrationsSysStartTime = daysValue;

		return companyOrTrustRegNumber;
	}

	/**
	 * @description Will populate the test data needed for Email Address DTO
	 *
	 * @param usageCode Usage code for the Email Address
	 * @param daysValue Email Address startTime value
	 *
	 * @return emailAddress
	 */
	private static AW_API_UpsertMasterAccount.DTO_EmailAddress populateEmailAddressData(String usageCode, Datetime daysValue)
	{
		AW_API_UpsertMasterAccount.DTO_EmailAddress emailAddress = new AW_API_UpsertMasterAccount.DTO_EmailAddress();
		emailAddress.usageCode = usageCode;
		emailAddress.emailAddress = CMN_DAL_SObjectDomain.generateRandomEmail();
		emailAddress.emailsSysStartTime = daysValue;

		return emailAddress;
	}

	/**
	 * @description Will populate the test data needed for Telephone DTO
	 *
	 * @param usageCode Usage code for the Telephone
	 * @param facilityCode Facility code for the Telephone
	 * @param daysValue Telephone startTime value
	 *
	 * @return telephone
	 */
	private static AW_API_UpsertMasterAccount.DTO_Telephone populateTelephoneData(String usageCode, String facilityCode, Datetime daysValue)
	{
		AW_API_UpsertMasterAccount.DTO_Telephone telephone = new AW_API_UpsertMasterAccount.DTO_Telephone();
		telephone.usageCode = usageCode;
		telephone.facilityCode = facilityCode;
		telephone.telephoneNumber = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		telephone.telephoneSysStartTime = daysValue;

		return telephone;
	}
}