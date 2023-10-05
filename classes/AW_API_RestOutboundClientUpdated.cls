/**
 * @description Service class to make the API call when Client is updated in Salesforce, to send updated client information from Salesforce to BPO and atWork
 *
 * @see AW_API_RestOutboundClientUpdated_TEST @story ST-2034,ST-56388,ST-24597
 *
 * @author prashant.k.jain@accenture.com jason.van.beukering@accenture.com vishakha.saini@accenture.com
 *
 * @date 2019, March 2023, April 2023
 */
public inherited sharing class AW_API_RestOutboundClientUpdated extends CMN_API_RestBaseOutboundMule
{
	/**
	 * @description Class name for the API
	 */
	public static final String SERVICE_NAME = AW_API_RestOutboundClientUpdated.class.getName();

	private static final Integer INT_ELEVEN = 11;
	private static final Integer INT_FIVE = 5;
	private static final Integer INT_FOUR = 4;
	private static final Integer INT_NINE = 9;
	private static final Integer INT_ONE = 1;
	private static final Integer INT_SIX = 6;
	private static final Integer INT_TEN = 10;
	private static final Integer INT_THREE = 3;
	private static final Integer INT_TWO = 2;
	private static final Integer INT_ZERO = 0;
	private static final String SOURCE_SYSTEM_SFDC = 'SFDC';
	private static final String STR_AFRIKAANS = 'Afrikaans';
	private static final String STR_DIVORCED = 'Divorced';
	private static final String STR_EMPLOYED = 'Employed';
	private static final String STR_ENGAGED = 'Engaged';
	private static final String STR_ENGLISH = 'English';
	private static final String STR_MARRIED = 'Married';
	private static final String STR_FEMALE = 'Female'; 
	private static final String STR_MALE = 'Male';
	private static final String STR_MARRIED_IN_COMMUNITY = 'Married In Community Of Property';
	private static final String STR_MARRIED_WITHOUT_ACCRUAL = 'Married Out Community Of Property without accrual';
	private static final String STR_MARRIED_WITH_ACCRUAL = 'Married Out Community Of Property with Accrual';
	private static final String STR_SEPERATED = 'Separated';
	private static final String STR_SINGLE = 'Single';
	private static final String STR_WIDOWED = 'Widowed';

	//TODO: This map should be replaced with us sending the picklist API value instead
	private static final Map<String, Integer> GENDER_CODE_MAPPING = new Map<String, Integer>
	{
			STR_FEMALE => INT_ONE,
			STR_MALE => INT_THREE
	};

	//TODO: This map should be replaced with us sending the picklist API value instead
	private static final Map<String, Integer> LANGUAGE_CODE_MAPPING = new Map<String, Integer>
	{
			STR_AFRIKAANS => INT_ONE,
			STR_ENGLISH => INT_TWO
	};

	//TODO: This map should be replaced with us sending the picklist API value instead
	private static final Map<String, Integer> MARITAL_STATUS_CODE_MAPPING = new Map<String, Integer>
	{
			STR_DIVORCED => INT_ONE,
			STR_ENGAGED => INT_TWO,
			STR_MARRIED => INT_THREE,
			STR_MARRIED_IN_COMMUNITY => INT_NINE,
			STR_MARRIED_WITHOUT_ACCRUAL => INT_TEN,
			STR_MARRIED_WITH_ACCRUAL => INT_ELEVEN,
			STR_SEPERATED => INT_FOUR,
			STR_SINGLE => INT_FIVE,
			STR_WIDOWED => INT_SIX
	};

	/**
	 * @description Override to set request and response DTO types and any other globals which may be used
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_Request();
	}

	/**
	 * @description Override to get Service name to be used when looking up custom settings for the service
	 *
	 * @return String Returns service name as string
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Override to return inner class having Mock response
	 *
	 * @return CMN_API_HttpBaseOutboundMock AW_API_RestOutboundClientUpdatedMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new AW_API_RestOutboundClientUpdatedMock();
	}

	/**
	 * @description Inner class to define structure and of request body and populate the same for API call
	 */
	@SuppressWarnings('PMD.TooManyFields, PMD.CognitiveComplexity,PMD.CyclomaticComplexity,PMD.StdCyclomaticComplexity')
	public class DTO_Request extends CMN_DTO_JsonBase
	{
		//private DTO_Address businessAddress;
		private DTO_Address postalAddress;
		private DTO_Address residentialAddress;
		private DTO_OccupationalDuties duties;
		private Date dateOfBirth;
		private Date maritalDate;
		private Decimal incomeAmount;
		private Integer educationLevelCode;
		private Integer growthStrategy;
		private Integer languageCode;
		private Integer maritalStatusCode;
		private Integer occupationCode;
		private Integer professionalBody;
		private Integer saResidentIndicator;
		private Integer selfEmployedIndicator;
		private Integer smokerIndicator;
		private Integer titleCode;
		private Integer willIndicator;
		private String bpoClientID;
		private String businessTelephoneNumber;
		private String celularNumber;
		private String consultantCode;
		private String countryOfBirth;
		private String countryOfResidence;
		private String educationLevelText;
		private String emailAddress;
		private String employerName;
		private String fifthName;
		private String firstName;
		private String fourthName;
		private String genderCode;
		private String globalKey;
		private String homeTelephoneNumber;
		private String maidenName;
		private String nationality;
		private String passportCountryOfIssueCode;
		private String passportNumber;
		private String preferredConcatMethod;
		private String preferredName;
		private String professionalBodyRegNumber;
		private String saNationalIDNumber;
		private String secondName;
		private String sourceSystemID;
		private String surname;
		private String taxNumber;
		private String thirdName;
		private String uacfId;
		private String willLocation;

		/**
		 * @description Override to populate request body
		 *
		 * @param triggeringObjectId Client Id for which API call is initiated
		 */
		public override void populate(Id triggeringObjectId)
		{
			super.populate(triggeringObjectId);

			Account clientAccount = AW_DAL_Account.findById(triggeringObjectId);
			User accountOwner = AW_DAL_User.findById(clientAccount.OwnerId);

			duties = new DTO_OccupationalDuties();

			duties.administrativePercentage = clientAccount.AW_OccupationDutyAdmin__c;
			duties.manualLightPercentage = clientAccount.AW_OccupationDutyLightManual__c;
			duties.manualHeavyPercentage = clientAccount.AW_OccupationDutyModerateHeavy__c;
			duties.travelPercentage = clientAccount.AW_OccupationDutyTravel__c;
			duties.supervisoryOfficePercentage = clientAccount.AW_OccupationDutyOfficeSupervisor__c;
			duties.supervisoryNonOfficePercentage = clientAccount.AW_OccupationDutyNonOfficeSupervisor__c;

			globalKey = clientAccount.AW_SKF_Id__c;

			businessTelephoneNumber = clientAccount.Phone;
			celularNumber = clientAccount.PersonMobilePhone;
			consultantCode = accountOwner.AW_ConsultantCode__c;
			dateOfBirth = clientAccount.PersonBirthdate;

			educationLevelCode = String.isNotBlank(clientAccount.AW_EducationLevel__pc) ? Integer.valueOf (clientAccount.AW_EducationLevel__pc) : educationLevelCode;
			educationLevelText = String.isNotBlank(clientAccount.AW_EducationLevel__pc) ? clientAccount.AW_EducationLevel__pc : educationLevelText;
			emailAddress = clientAccount.PersonEmail;
			firstName = clientAccount.FirstName;

			Integer genderCodeInt = GENDER_CODE_MAPPING.get(clientAccount.FinServ__Gender__pc);
			genderCode = genderCodeInt != null ? String.valueOf(genderCodeInt) : genderCode;

			homeTelephoneNumber = clientAccount.PersonHomePhone;
			incomeAmount = clientAccount.AW_Income__pc;

			languageCode = LANGUAGE_CODE_MAPPING.get(clientAccount.FinServ__PrimaryLanguage__pc);
			languageCode = languageCode == null ? INT_ZERO : languageCode;

			maidenName = clientAccount.AW_Maiden_Name__pc;

			growthStrategy = clientAccount.AW_Growth_Strategy__c != null ? Integer.valueOf(clientAccount.AW_Growth_Strategy__c) : growthStrategy;

			bpoClientID = clientAccount.AW_BPO_Client_Id__c;

			maritalStatusCode = MARITAL_STATUS_CODE_MAPPING.get(clientAccount.FinServ__MaritalStatus__pc);
			maritalStatusCode = maritalStatusCode == null ? INT_ZERO : maritalStatusCode;
			saResidentIndicator = SC_DAL_Account.STATUS_RESIDENT_YES.equals(clientAccount.CMN_SAResidentIndicator__c) ?
					INT_ONE : String.isNotBlank(clientAccount.CMN_SAResidentIndicator__c) ? INT_ZERO : saResidentIndicator;
			employerName = clientAccount.AW_Company__c;
			selfEmployedIndicator = clientAccount.AW_EmployedBusinessOwner__pc == STR_EMPLOYED ? INT_ZERO : INT_ONE; // US-56388
			professionalBody = String.isNotBlank(clientAccount.AW_Professional_Body__c) ? Integer.valueOf (clientAccount.AW_Professional_Body__c) : professionalBody;
			professionalBodyRegNumber = clientAccount.AW_Professional_Body_Reg_Number__c;

			List<String> engagementTypes = CMN_UTIL_System.convertStringToList(clientAccount.AW_EngagementType__c, ';');
			preferredConcatMethod = engagementTypes.isEmpty() ? CMN_UTIL_String.EMPTY : engagementTypes.iterator().next();

			willIndicator = clientAccount.AW_Will_Indicator__c ? INT_ONE : INT_ZERO; // US-56388
			willLocation = clientAccount.AW_Will_Location__c;
			maritalDate = clientAccount.FinServ__WeddingAnniversary__pc;

			Map<Id, AW_Country__c> countryMap = new Map<Id, AW_Country__c>(AW_DAL_Country.getAll());

			AW_Country__c foundCountry = countryMap.get(clientAccount.AW_Country_Of_Birth__c);
			countryOfBirth = foundCountry != null ? String.valueOf(foundCountry.AW_CountryCode__c.intValue()) : countryOfBirth;

			foundCountry = countryMap.get(clientAccount.AW_Nationality__c);
			nationality = foundCountry != null ? String.valueOf(foundCountry.AW_CountryCode__c.intValue()) : nationality;

			if(String.isNotBlank(clientAccount.FinServ__CountryOfResidence__pc))
			{
				foundCountry = AW_DAL_Country.findByName(clientAccount.FinServ__CountryOfResidence__pc);
				countryOfResidence = foundCountry != null ? String.valueOf(foundCountry.AW_CountryCode__c.intValue()) : countryOfResidence;
			}

			if(clientAccount.AW_Occupation__pc != null)
			{
				AW_Occupation__c foundOccupation = AW_DAL_Occupation.findById(clientAccount.AW_Occupation__pc);
				occupationCode = foundOccupation != null ? Integer.valueOf(foundOccupation.AW_OccupationCode__c) : occupationCode;
			}

			foundCountry = countryMap.get(clientAccount.AW_PassportCountryOfIssue__pc);
			passportCountryOfIssueCode = foundCountry != null ? String.valueOf(foundCountry.AW_CountryCode__c.intValue()) : passportCountryOfIssueCode;

			Boolean isSaIdType = AW_DAL_Account.PICK_SA_ID_TYPE.equalsIgnoreCase(clientAccount.AW_IdentificationType__pc);
			saNationalIDNumber = isSaIdType ? clientAccount.AW_IdentificationNumber__pc : CMN_UTIL_String.EMPTY;
			passportNumber = isSaIdType ? CMN_UTIL_String.EMPTY : clientAccount.AW_IdentificationNumber__pc;

			postalAddress = constructValidPostalAddress(clientAccount, countryMap);
			residentialAddress = constructValidResidentialAddress(clientAccount, countryMap);

			secondName = clientAccount.MiddleName;
			thirdName = clientAccount.AW_ThirdName__pc;
			fourthName = clientAccount.AW_FourthName__pc;
			fifthName = clientAccount.AW_FifthName__pc;
			preferredName = clientAccount.FinServ__PreferredName__pc;

			smokerIndicator = clientAccount.AW_Smoker__pc == true ? INT_ONE : INT_ZERO;

			surname = clientAccount.LastName;
			taxNumber = clientAccount.AW_TaxNumber__pc;
			titleCode = String.isNotBlank(clientAccount.Salutation) ? Integer.valueOf(clientAccount.Salutation) : INT_ZERO;

			uacfId = accountOwner.AW_UACFID__c;
			sourceSystemID = SOURCE_SYSTEM_SFDC;
		}

		/**
		 * @description Construct Residential address for request
		 *
		 * @param clientAccount Account to get Residential address fields from
		 * @param countryMap Map of Country object Id to Country object
		 *
		 * @return Object which stores Residential address fields for request
		 */
		private DTO_Address constructValidResidentialAddress(Account clientAccount, Map<Id, AW_Country__c> countryMap)
		{
			DTO_Address dtoAddress = null;

			//Only populate valid address
			if((String.isNotBlank(clientAccount.AW_ResidentialStreetLineOne__pc)
					|| String.isNotBlank(clientAccount.AW_ResidentialStreetLineTwo__pc)
					|| String.isNotBlank(clientAccount.AW_ResidentialStreetLineThree__pc)
					|| String.isNotBlank(clientAccount.AW_ResidentialSuburb__pc)
					|| String.isNotBlank(clientAccount.AW_ResidentialPostalCode__pc)
					|| String.isNotBlank(clientAccount.AW_ResidentialCountry__pc))
					&& String.isNotBlank(clientAccount.AW_ResidentialPostalCode__pc)
					&& String.isNotBlank(clientAccount.AW_ResidentialCountry__pc))
			{
				dtoAddress = new DTO_Address();

				dtoAddress.line1 = clientAccount.AW_ResidentialStreetLineOne__pc;
				dtoAddress.line2 = clientAccount.AW_ResidentialStreetLineTwo__pc;
				dtoAddress.line3 = clientAccount.AW_ResidentialStreetLineThree__pc;
				dtoAddress.suburb = clientAccount.AW_ResidentialSuburb__pc;
				dtoAddress.postalCode = clientAccount.AW_ResidentialPostalCode__pc;

				AW_Country__c foundCountry = countryMap.get(clientAccount.AW_ResidentialCountry__pc);
				dtoAddress.countryCode = foundCountry != null ? String.valueOf(foundCountry.AW_CountryCode__c.intValue()) : dtoAddress.countryCode;
			}

			return dtoAddress;
		}

		/**
		 * @description Construct Postal address for request
		 *
		 * @param clientAccount Account to get Postal address fields from
		 * @param countryMap Map of Country object Id to Country object
		 *
		 * @return Object which stores Postal address fields for request
		 */
		private DTO_Address constructValidPostalAddress(Account clientAccount, Map<Id, AW_Country__c> countryMap)
		{
			DTO_Address dtoAddress = null;

			//Only populate valid address
			if((String.isNotBlank(clientAccount.AW_PostalAddressLineOne__pc)
					|| String.isNotBlank(clientAccount.AW_PostalAddressLineTwo__pc)
					|| String.isNotBlank(clientAccount.AW_PostalAddressLineThree__pc)
					|| String.isNotBlank(clientAccount.AW_PostalSuburb__pc)
					|| String.isNotBlank(clientAccount.AW_PostalSuburb__pc)
					|| String.isNotBlank(clientAccount.AW_PostalCountry__pc))
					&& String.isNotBlank(clientAccount.AW_PostalCode__pc)
					&& String.isNotBlank(clientAccount.AW_PostalCountry__pc))
			{
				dtoAddress = new DTO_Address();

				dtoAddress.line1 = clientAccount.AW_PostalAddressLineOne__pc;
				dtoAddress.line2 = clientAccount.AW_PostalAddressLineTwo__pc;
				dtoAddress.line3 = clientAccount.AW_PostalAddressLineThree__pc;
				dtoAddress.suburb = clientAccount.AW_PostalSuburb__pc;
				dtoAddress.postalCode = clientAccount.AW_PostalCode__pc;

				AW_Country__c foundCountry = countryMap.get(clientAccount.AW_PostalCountry__pc);
				dtoAddress.countryCode = foundCountry != null ? String.valueOf(foundCountry.AW_CountryCode__c.intValue()) : dtoAddress.countryCode;
			}

			return dtoAddress;
		}
	}

	private class DTO_Address
	{
		private String countryCode;
		private String line1;
		private String line2;
		private String line3;
		private String postalCode;
		private String suburb;
	}

	private class DTO_OccupationalDuties
	{
		private Decimal administrativePercentage;
		private Decimal manualLightPercentage;
		private Decimal manualHeavyPercentage;
		private Decimal travelPercentage;
		private Decimal supervisoryOfficePercentage;
		private Decimal supervisoryNonOfficePercentage;
	}

	private class AW_API_RestOutboundClientUpdatedMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"Message": "Person created successfully"}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}