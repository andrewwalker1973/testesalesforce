/**
 * @description Service class to make the API call to request transunion data
 *
 * @see AW_API_TransUnionData_TEST @story 168885
 *
 * @author sukhdeep.b.singh@accenture.com vishakha.saini@liberty.co.za jason.van.beukering@accenture.com vishakha.saini@accenture.com
 *
 * @date August 2021, March 2022
 */
public inherited sharing class AW_API_TransUnionData extends CMN_API_RestBaseOutboundMule
{
	private Lead foundLead;
	private static final Integer MAX_NUMBER_OF_SUPPLIERS = 12;
	/**
	 * @description Required parameter to be passed to the handler in case if IdType is passport
	 */
	private static final String CACHE_FALSE = 'false';
	private static final String CALL_SUCCESSFUL_MESSAGE = 'Consent data retrieved successfully';
	private static final String CUSTOM_FIELD_SUFFIX = '__c';
	private static final String ERROR_NO_DATE_OF_BIRTH = 'Unable to process request as Date of Birth is blank';
	private static final String ERROR_NO_FIRST_NAME = 'Unable to process request as First Name is blank';
	private static final String ERROR_NO_IDENTITY_NUMBER = 'Unable to process request as Identity Number is blank';
	private static final String ERROR_NO_LEAD_FOUND = 'Unable to process request as no Lead was found';
	private static final String FAILED = 'Failed';
	private static final String FIELD_CREDIT_BUREAU_SUPPLIER_PREFIX = 'AW_CreditBureauSupplier';
	private static final String HTTP_HEADER_IDENTIFICATION_TYPE = 'idType';
	private static final String IDENTIFICATION_TYPE_PASSPORT = 'passportNumber';
	private static final String IDENTIFICATION_TYPE_SA_ID_NUMBER = 'saNationalIdNumber';
	private static final String IEV4_NETT = 'IEV4_NETT';
	@TestVisible
	private static final String SUCCESSFUL = 'Successful';
	private static final String TRANSUNION_DYNAMIC_URL = '?dateOfBirth={0}&firstName={1}&lastName={2}&cached={3}';

	/**
	 * @description Class Name of the service
	 */
	public static final String SERVICE_NAME = AW_API_TransUnionData.class.getName();

	/**
	 * @description To used by Client Application to return response message to users
	 */
	public String responseMessage
	{
		get
		{
			String message = CALL_SUCCESSFUL_MESSAGE;

			if(!callResult.completed)
			{
				message = !callResult.errors.isEmpty() ?
						String.join(callResult.errors, CMN_UTIL_String.LF) :
						((DTO_ErrorResponse)JSON.deserialize(callResult.responseBody, DTO_ErrorResponse.class)).error.errorMessage;

			}

			return message;
		}

	}

	/**
	 * @description Override to set request and response DTO types and any other globals which may be used
	 */
	protected override void initialise()
	{
		super.initialise();
		baseResponseDTO = new DTO_Response();
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
	 * @description Override to use Get HTTP Method for API call
	 *
	 * @return String
	 */
	protected override virtual String getVerb()
	{
		return HTTP_VERB_GET;
	}

	/**
	 * @description Construct the API endpoint URL
	 *
	 * @return final Endpoint to be called
	 */
	protected override String getWebServiceEndPoint()
	{
		String endPoint = String.format
				(
						super.getWebServiceEndPoint(),
						new List<String>
						{
								EncodingUtil.urlEncode(foundLead.AW_IdentificationNumber__c, UTF8_ENCODING_SCHEME)
						}
				);

		if(AW_DAL_Lead.IDENTIFICATION_TYPE_PASSPORT.equalsIgnoreCase(foundLead.AW_IdentificationType__c))
		{
			endPoint = endPoint + String.format
					(
							TRANSUNION_DYNAMIC_URL,
							new List<String>
							{
									CMN_UTIL_Date.fullDateString(foundLead.AW_DateOfBirth__c),
									EncodingUtil.urlEncode(foundLead.FirstName, UTF8_ENCODING_SCHEME),
									EncodingUtil.urlEncode(foundLead.LastName, UTF8_ENCODING_SCHEME),
									CACHE_FALSE
							}
					);
		}
		return endPoint;
	}

	/**
	 * @description Override to validate if all the information required to make API call is available
	 *
	 * @return Boolean Returns true if all the information is present, else will return false
	 */
	protected override Boolean abortRequest()
	{
		Boolean mustAbort = super.abortRequest();

		foundLead = AW_DAL_Lead.findById(queueItem.CMN_TriggeringObjectId__c);

		if(!mustAbort)
		{
			if(foundLead == null)
			{
				callResult.errors.add(ERROR_NO_LEAD_FOUND);
				mustAbort = true;
			}
			else
			{
				mustAbort = checkMustAbortForIncompleteLead();
			}
		}

		return mustAbort;
	}

	/**
	 * @description Will check whether lead has all the required fields populated to call the API
	 *
	 * @return true if lead is valid else false
	 */
	private Boolean checkMustAbortForIncompleteLead()
	{
		Boolean mustAbort = false;

		if(String.isBlank(foundLead.AW_IdentificationNumber__c))
		{
			callResult.errors.add(ERROR_NO_IDENTITY_NUMBER);
			mustAbort = true;
		}
		else if(AW_DAL_Lead.IDENTIFICATION_TYPE_PASSPORT.equalsIgnoreCase(foundLead.AW_IdentificationType__c))
		{
			if(String.isBlank(foundLead.FirstName))
			{
				callResult.errors.add(ERROR_NO_FIRST_NAME);
				mustAbort = true;
			}

			if(foundLead.AW_DateOfBirth__c == null)
			{
				callResult.errors.add(ERROR_NO_DATE_OF_BIRTH);
				mustAbort = true;
			}
		}

		return mustAbort;
	}

	/**
	 * @description Override to set SObject types for DML operation
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType> {Lead.SObjectType});
	}

	/**
	 * @description Will ensure that the change to Lead is registered to be committed after
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		updateLeadWithTransunionData((DTO_Response)baseResponseDTO, foundLead);
		registerChange(foundLead);
	}

	/**
	 * @description Set the lead fields from the DTO provided
	 *
	 * @param dtoResponse JSON response from MuleSoft
	 * @param updateLead Lead record
	 */
	@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
	private void updateLeadWithTransunionData(DTO_Response dtoResponse, Lead updateLead)
	{
		DTO_ConsumerInfo dtoConsumerInfo = dtoResponse.consumerInfoNO05;
		DTO_Empirica dtoEmpirica = dtoResponse.empiricaEM07;
		List <DTO_AddressDetails> dtoAddressDetails = dtoResponse.address;
		List <DTO_EmploymentDetails> dtoEmploymentDetails = dtoResponse.employmentNM04;

		updateLead.AW_CreditBureauConsent__c = true;
		updateLead.AW_CreditBureauCallStatus__c = SUCCESSFUL;
		updateLead.AW_CreditBureauLastCallDateTime__c = System.now();
		updateLead.AW_CreditBureauRequestStatusMessage__c = null;

		//Updating Consumer Info on Lead
		updateLead.AW_CreditBureauSurname__c = dtoConsumerInfo.surname;
		updateLead.AW_CreditBureauForename1__c = dtoConsumerInfo.forename1;
		updateLead.AW_CreditBureauForename2__c = dtoConsumerInfo.forename2;
		updateLead.AW_CreditBureauForename3__c = dtoConsumerInfo.forename3;
		updateLead.AW_CreditBureauTitle__c = dtoConsumerInfo.title;
		updateLead.AW_CreditBureauGender__c = dtoConsumerInfo.gender;
		updateLead.AW_CreditBureauMaritalStatus__c = dtoConsumerInfo.maritalStatusDesc;
		updateLead.AW_CreditBureauDependants__c = Integer.valueOf(dtoConsumerInfo.dependants);
		updateLead.AW_CreditBureauSpouseName1__c = dtoConsumerInfo.spouseName1;
		updateLead.AW_CreditBureauSpouseName2__c = dtoConsumerInfo.spouseName2;
		updateLead.AW_CreditBureauTelephoneNumber__c = dtoConsumerInfo.telephoneNumbers;
		updateLead.AW_CreditBureauDeceasedDate__c = dtoConsumerInfo.deceasedDate;
		updateLead.AW_CreditBureauCellNumber__c = dtoConsumerInfo.cellNumber;
		updateLead.AW_CreditBureauAlternativeEmail__c = dtoConsumerInfo.eMail;

		//Updating Credit Score on Lead
		updateLead.AW_CreditBureauCreditScore__c = Integer.valueOf(dtoEmpirica.empiricaScore);

		//Updating Address info on Lead
		if(dtoAddressDetails?.size() > 0)
		{
			dtoAddressDetails.sort();

			//Setting Address1 fields e.g. Address1Line1 etc
			if(dtoAddressDetails.size() >= 1)
			{
				DTO_AddressDetails addressDetails1 = dtoAddressDetails.get(0);
				updateLead.AW_CreditBureauAddress1Line1__c = addressDetails1.line1;
				updateLead.AW_CreditBureauAddress1Line2__c = addressDetails1.line2;
				updateLead.AW_CreditBureauAddress1Suburb__c = addressDetails1.suburb;
				updateLead.AW_CreditBureauAddress1City__c = addressDetails1.city;
				updateLead.AW_CreditBureauAddress1PostalCode__c = addressDetails1.postalCode;
				updateLead.AW_CreditBureauAddress1ProvinceCode__c = addressDetails1.provinceCode;
				updateLead.AW_CreditBureauAddress1Province__c = addressDetails1.province;
				updateLead.AW_CreditBureauAddress1OwnerTenant__c = addressDetails1.ownerTenant;
				updateLead.AW_CreditBureauAddress1Changed__c = addressDetails1.addressChanged;
				updateLead.AW_CreditBureauPeriodAtAddress1__c = Decimal.valueOf(addressDetails1.addressPeriod);
			}

			//Setting Address2 fields e.g. Address2Line1 etc
			if(dtoAddressDetails.size() >= 2)
			{
				DTO_AddressDetails addressDetails2 = dtoAddressDetails.get(1);
				updateLead.AW_CreditBureauAddress2Line1__c = addressDetails2.line1;
				updateLead.AW_CreditBureauAddress2Line2__c = addressDetails2.line2;
				updateLead.AW_CreditBureauAddress2Suburb__c = addressDetails2.suburb;
				updateLead.AW_CreditBureauAddress2City__c = addressDetails2.city;
				updateLead.AW_CreditBureauAddress2PostalCode__c = addressDetails2.postalCode;
				updateLead.AW_CreditBureauAddress2ProvinceCode__c = addressDetails2.provinceCode;
				updateLead.AW_CreditBureauAddress2Province__c = addressDetails2.province;
				updateLead.AW_CreditBureauAddress2OwnerTenant__c = addressDetails2.ownerTenant;
				updateLead.AW_CreditBureauAddress2Changed__c = addressDetails2.addressChanged;
				updateLead.AW_CreditBureauPeriodAtAddress2__c = Decimal.valueOf(addressDetails2.addressPeriod);
			}
		}

		//Updating Employment Details on Lead
		if(dtoEmploymentDetails?.size() > 0)
		{
			dtoEmploymentDetails.sort();

			//Setting 1st employment detail fields
			if(dtoEmploymentDetails.size() >= 1)
			{
				DTO_EmploymentDetails employmentDetail1 = dtoEmploymentDetails.get(0);
				updateLead.AW_CreditBureauOccupation1__c = employmentDetail1.occupation;
				updateLead.AW_CreditBureauEmployer1__c = employmentDetail1.employerName;
				updateLead.AW_CreditBureauTenure1__c = Integer.valueOf(employmentDetail1.employmentPeriod);
			}

			//Setting 2nd employment detail fields
			if(dtoEmploymentDetails.size() >= 2)
			{
				DTO_EmploymentDetails employmentDetail2 = dtoEmploymentDetails.get(1);
				updateLead.AW_CreditBureauOccupation2__c = employmentDetail2.occupation;
				updateLead.AW_CreditBureauEmployer2__c = employmentDetail2.employerName;
				updateLead.AW_CreditBureauTenure2__c = Integer.valueOf(employmentDetail2.employmentPeriod);
			}
		}

		//Updating Estimated Nett Income details on Lead
		List <DTO_IncomeEstimatorVariables> incomeEstimatorI4Variable = dtoResponse.incomeEstimatorI401.incomeEstimatorI4Variable;

		if(incomeEstimatorI4Variable?.size() > 0)
		{
			for(DTO_IncomeEstimatorVariables incomeVariable : incomeEstimatorI4Variable)
			{
				if(incomeVariable.variableName.equalsIgnoreCase(IEV4_NETT))
				{
					updateLead.AW_CreditBureauEstimatedNetIncome__c = Integer.valueOf(incomeVariable.variableValue);
					break;
				}
			}
		}

		//Updating Supplier details on Lead
		Integer supplierLoopCount = Math.min(MAX_NUMBER_OF_SUPPLIERS, dtoResponse.cPAAccountInformationExtendedP8.size());

		for(Integer i = 0; i < supplierLoopCount; i++)
		{
			String fieldName = FIELD_CREDIT_BUREAU_SUPPLIER_PREFIX + (i + 1) + CUSTOM_FIELD_SUFFIX;
			updateLead.put(fieldName, dtoResponse.cPAAccountInformationExtendedP8.get(i).supplier);
		}
	}

	/**
	 * @description Override to set header values
	 */
	protected override void setHeaders()
	{
		super.setHeaders();

		String identificationTypeQueryParameter;

		if(AW_DAL_Account.PICK_SA_ID_TYPE.equalsIgnoreCase(foundLead.AW_IdentificationType__c))
		{
			identificationTypeQueryParameter = IDENTIFICATION_TYPE_SA_ID_NUMBER;
		}
		else if(AW_DAL_Account.PICK_PASSPORT_TYPE.equalsIgnoreCase(foundLead.AW_IdentificationType__c))
		{
			identificationTypeQueryParameter = IDENTIFICATION_TYPE_PASSPORT;
		}

		request.setHeader(HTTP_HEADER_IDENTIFICATION_TYPE, identificationTypeQueryParameter);
	}

	/**
	 * @description override to set the data in case of error response
	 */
	public override void onDMLStarting()
	{
		super.onDMLStarting();

		if(!callResult.completed && foundLead != null)
		{
			updateLeadWithErrorDetails();
			registerChange(foundLead);
		}
	}

	/**
	 * @description override to set the data in case of any errors that occurred
	 *
	 * @param error the exception that needs to be managed
	 */
	public override void handleError(Exception error)
	{
		super.handleError(error);

		if(!callResult.completed && foundLead != null)
		{
			updateLeadWithErrorDetails();
			CMN_DAL_SObjectDomain.updateDBObject(foundLead);
		}
	}

	/**
	 * @description override to set the data in case of any errors that occurred
	 */
	private void updateLeadWithErrorDetails()
	{
		//Make sure we write the response on the lead object if the call didn't complete
			foundLead.AW_CreditBureauRequestStatusMessage__c = responseMessage;
			foundLead.AW_CreditBureauCallStatus__c = FAILED;
			foundLead.AW_CreditBureauLastCallDateTime__c = System.now();
			foundLead.AW_CreditBureauConsent__c = true;
	}

	/**
	 * @description Override to return mock response for test class
	 *
	 * @return CMN_API_HttpBaseOutboundMock AW_API_RestOutboundEnvelopeToSigMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new AW_API_RefreshContractsMock();
	}

	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	@TestVisible
	private class AW_API_RefreshContractsMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"rawData":"","responseStatus":"Success","processingStartDate":"2021-07-16T11:25:15.2755341+02:00",' +
				'"processingTimeSecs":"1.2968610999999999","uniqueRefGuid":"aeac8d0e-cdf0-46f1-8187-f01fe3a22dfe","address":[{"consumerNo":"885770436",' +
				'"informationDate":"20191029","line1":"19 THE PADDOCKS","line2":"19 ROCKERY LANE","suburb":"ORANGE GROVE","city":"EAST LONDON","postalCode":"2192",' +
				'"provinceCode":"GP","province":"GAUTENG","addressPeriod":"00","ownerTenant":"","addressChanged":"Y"},{"consumerNo":"885770436","informationDate":' +
				'"20210320","line1":"21TH UNIT","line2":"21TH ST","suburb":"LINKSFIELD","city":"JOHANNESBURG","postalCode":"2192","provinceCode":"GP","province":' +
				'"GAUTENG","addressPeriod":"00","ownerTenant":"","addressChanged":"Y"},{"consumerNo":"885770436","informationDate":"20210320","line1":"UNIT 20",' +
				'"line2":"20TH ST","suburb":"LINKSFIELD","city":"JOHANNESBURG","postalCode":"2001","provinceCode":"GP","province":"GAUTENG","addressPeriod":"00",' +
				'"ownerTenant":"T","addressChanged":"Y"}],"consEnqTransInfo0102":{"definiteMatchCount":"1","possibleMatchCount":"00","matchedConsumerNo":"885770436"' +
				',"possibleConsumerNo":"","possibleAdverseIndicator":""},"consumerInfoNO05":{"recordSeq":"01","part":"001","partSeq":"01","consumerNo":"885770436",' +
				'"surname":"LOURENS","forename1":"JOHANNES","forename2":"WILLEM","forename3":"CHILL","title":"MR","gender":"M","nameInfoDate":"20110804","dateOfBirth"' +
				':"19880527","identityNo1":"8805275255085","identityNo2":"","maritalStatusCode":"S","maritalStatusDesc":"SINGLE","dependants":"07","spouseName1":' +
				'"KETHRIEN","spouseName2":"LANGFORD","telephoneNumbers":"H(011)5583231 B(011)4085021","deceasedDate":"00000000","cellNumber":"000000796032296",' +
				'"eMail":"johannwlourens@gmail.com"},"cPAAccountInformationExtendedP8":[{"supplier":"SBSA - VEHICLE & ASSET FI","account":"079863350001","subAccount"' +
				':"","branch":"","extendedCPAHistory":[{"openingBalance":"00000000","currentBalance":"00000000","overDueAmount":"00000000","installmentAmount":' +
				'"00000000","transactionDate":"202107"}]},{"supplier":"SBSA - MASTERCARD","account":"0123555068511582","subAccount":"","branch":"","extendedCPAHistory":' +
				'[{"openingBalance":"00000000","currentBalance":"00000000","overDueAmount":"00000000","installmentAmount":"00000000","transactionDate":"202107"}]},' +
				'{"supplier":"SBSA - HOME LOANS","account":"533368219","subAccount":"","branch":"","extendedCPAHistory":[{"openingBalance":"00000000","currentBalance"' +
				':"00000000","overDueAmount":"00000000","installmentAmount":"00000000","transactionDate":"202107"}]},{"supplier":"TRUWORTHS","account":"10101136542957"' +
				',"subAccount":"","branch":"","extendedCPAHistory":[{"openingBalance":"00000000","currentBalance":"00000000","overDueAmount":"00000000",' +
				'"installmentAmount":"00000000","transactionDate":"201908"}]},{"supplier":"FNB CREDIT CARD","account":"4480080261486000","subAccount":"","branch":""' +
				',"extendedCPAHistory":[{"openingBalance":"00000000","currentBalance":"00000000","overDueAmount":"00000000","installmentAmount":"00000000",' +
				'"transactionDate":"202107"}]},{"supplier":"ABSA VEHICLE FINANCE","account":"91055517","subAccount":"0","branch":"00005308","extendedCPAHistory":' +
				'[{"openingBalance":"00249333","currentBalance":"00221625","overDueAmount":"00000000","installmentAmount":"00005101","transactionDate":"201908"}]},' +
				'{"supplier":"TELKOM SA LTD","account":"500412597","subAccount":"","branch":"","extendedCPAHistory":[{"openingBalance":"00000000","currentBalance"' +
				':"00000000","overDueAmount":"00000000","installmentAmount":"00000000","transactionDate":"201908"}]},{"supplier":"","account":"7000100100222562662"' +
				',"subAccount":"","branch":"","extendedCPAHistory":[{"openingBalance":"00004000","currentBalance":"00000000","overDueAmount":"00000000",' +
				'"installmentAmount":"00000000","transactionDate":"201908"}]},{"supplier":"VODACOM SP","account":"I3680068","subAccount":"","branch":"",' +
				'"extendedCPAHistory":[{"openingBalance":"00000000","currentBalance":"00000559","overDueAmount":"00000000","installmentAmount":"00000559",' +
				'"transactionDate":"201908"}]},{"supplier":"RCS GAME","account":"0005022190305932784","subAccount":"","branch":"","extendedCPAHistory":' +
				'[{"openingBalance":"00000000","currentBalance":"00000000","overDueAmount":"00000000","installmentAmount":"00000000","transactionDate":"202107"}]}],' +
				'"echoData0001":{"subscriberCode":"99823","clientReference":"","branchNumber":"","batchNumber":""},"empiricaEM07":{"consumerNo":"885770436",' +
				'"empiricaScore":"00712","exclusionCode":"","exclusionCodeDescription":"","reasonCode":{"string":"11"},"reasonDescription":{"string":' +
				'"Level of delinquency on accounts"},"expansionScore":"","expansionScoreDescription":"","empiricaVersion":"AOV5.0"},"employmentNM04":' +
				'[{"recordSeq":"01","part":"001","partSeq":"01","consumerNo":"885770436","informationDate":"20190827","occupation":"MA19","employerName":' +
				'"LIBERTY","employmentPeriod":"20"},{"recordSeq":"02","part":"001","partSeq":"01","consumerNo":"885770436","informationDate":"20210604",' +
				'"occupation":"OF21","employerName":"LIBERTY LIFE","employmentPeriod":"21"},{"recordSeq":"03","part":"001","partSeq":"01","consumerNo":"885770436"' +
				',"informationDate":"20210604","occupation":"MA20","employerName":"LIBERTY LIFE","employmentPeriod":"19"}],"incomeEstimatorI401":{"scoreVersion":"0004",' +
				'"lineNumber":"1","consumerNo":"885770436","variableCount":"9","headingLength":"10","incomeEstimatorI4Variable":[{"variableName":"IEV4_NETT",' +
				'"variableValue":"042147"}],"suburbCodesGR01":[{"consumerNo":"885770436","suburbCode":"2191068","dataDate":"20170131","loadDate":"20170209","codes"' +
				':{"string":"0134"}}]},"v1Segment":[{"code":"V1","value":"01"}]}';

		private final String errorResponse = '{"error": {"errorCode":400,"errorMessage":"Invalid Id Number","errorDescription":"error"}}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}

		/**
		 * @description Will set response in the event on exception
		 *
		 * @param response The response object on which to set the relevant body
		 */
		protected override void setErrorResponse(HttpResponse response)
		{
			super.setErrorResponse(response);
			response.setBody(errorResponse);
		}
	}

	/**
	 * @description Inner class to define structure of response body
	 */
	@TestVisible
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		@TestVisible
		private List <DTO_AddressDetails> address;
		private DTO_ConsumerInfo consumerInfoNO05;
		private DTO_Empirica empiricaEM07;
		@TestVisible
		private List <DTO_EmploymentDetails> employmentNM04;
		private DTO_IncomeEstimator incomeEstimatorI401;
		private List <DTO_PAAccountInformationExtended> cPAAccountInformationExtendedP8;

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_Response.class;
		}
	}

	/**
	 * @description Class representing Consumer Information
	 */
	private class DTO_ConsumerInfo
	{
		private String surname;
		private String forename1;
		private String forename2;
		private String forename3;
		private String title;
		private String gender;
		private String maritalStatusDesc;
		private Integer dependants;
		private String spouseName1;
		private String spouseName2;
		private String telephoneNumbers;
		private String deceasedDate;
		private String cellNumber;
		private String eMail;
	}

	/**
	 * @description Class representing a empirica details
	 */
	private class DTO_Empirica
	{
		private String empiricaScore;
	}

	/**
	 * @description Class representing Address Details
	 */
	@TestVisible
	private class DTO_AddressDetails implements Comparable
	{
		@TestVisible
		private String informationDate;
		@TestVisible
		private String line1;
		private String line2;
		private String suburb;
		private String city;
		private String postalCode;
		private String provinceCode;
		private String province;
		private String ownerTenant;
		private String addressPeriod;
		private String addressChanged;

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
			DTO_AddressDetails dtoAddressDetails = (DTO_AddressDetails)compareTo;

			if(informationDate > dtoAddressDetails.informationDate)
			{
				return -1;
			}
			else if(informationDate < dtoAddressDetails.informationDate)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}

	/**
	 * @description Class representing a Employment Details
	 */
	@TestVisible
	private class DTO_EmploymentDetails implements Comparable
	{
		@TestVisible
		private String occupation;
		private String employerName;
		private String employmentPeriod;
		@TestVisible
		private String informationDate;

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
			DTO_EmploymentDetails dtoEmploymentDetails = (DTO_EmploymentDetails)compareTo;

			if(informationDate > dtoEmploymentDetails.informationDate)
			{
				return -1;
			}
			else if(informationDate < dtoEmploymentDetails.informationDate)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}

	/**
	 * @description Class representing a Income Estimator details
	 */
	private class DTO_IncomeEstimator
	{
		private List <DTO_IncomeEstimatorVariables> incomeEstimatorI4Variable;
	}

	/**
	 * @description Class representing a Income Estimator details
	 */
	private class DTO_IncomeEstimatorVariables
	{
		private String variableName;
		private String variableValue;
	}

	/**
	 * @description Class representing a PA Account Information Extended details
	 */
	private class DTO_PAAccountInformationExtended
	{
		private String supplier;
	}

	/**
	 * @description Used to parse an error response
	 */
	private class DTO_ErrorResponse
	{
		public DTO_Error error;
	}

	/**
	 * @description Detail of error received
	 */
	private class DTO_Error
	{
		public String errorMessage;
	}

}