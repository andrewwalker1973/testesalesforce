/**
 * @description Service class to make the API call to notify Mulesoft to retrieve all the tac certificates associated to clients contracts.
 *
 * @see RSC_API_GetTaxCertificates_TEST @story ST-147578
 *
 * @author jayanth.kumar.s@accenture.com darrion.james.singh@accenture.com jason.van.beukering@accenture.com
 *
 * @date September 2021, April 2022
 */
public inherited sharing class RSC_API_GetTaxCertificates extends CMN_API_RestBaseOutboundMule
{
	@TestVisible
	private static String testPolicyNumber1 = '84230155000';
	@TestVisible
	private static String testPolicyNumber2 = '84230154000';

	private static final String ERROR_PERSON_NOT_FOUND = 'Unable to process request as person Id parameter is blank.';
	@TestVisible
	private static final String LOG_CLASS_METHOD = 'RSC_API_GetTaxCertificates.DTO_TransformedResponse/transform';
	private static final String WARNING_POLICY_NOT_FOUND = 'No detailed Information found for Policy "{0}"';
	/**
	 * @description The class name of the web service handler
	 */
	public static final String SERVICE_NAME = RSC_API_GetTaxCertificates.class.getName();

	/**
	 * @description Required parameter to be passed to the handler else call will be aborted
	 */
	public static final String PARAMETER_PERSON_ID = 'personId';

	/**
	 * @description Public property exposing the tax certificates retrieved successfully
	 */
	public DTO_TransformedResponse transformedResponse
	{
		get
		{
			return (DTO_TransformedResponse)baseResponseDTO;
		}
	}

	/**
	 * @description Override to set request and response DTO types and any other globals which may be used
	 */
	protected override void initialise()
	{
		super.initialise();

		baseResponseDTO = new DTO_Response();
		baseTableDTOType = DTO_Table.class;
	}

	/**
	 * @description Override to use GET HTTP Method for API call
	 *
	 * @return String
	 */
	public override virtual String getVerb()
	{
		return CMN_API_HttpBase.HTTP_VERB_GET;
	}

	/**
	 * @description Indicate if a triggering object id is required
	 *
	 * @return Boolean indicating requirement
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	protected override Boolean triggeringObjectRequired()
	{
		return false;
	}

	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Check if the JSON Response is in the form of an array without key; Parsing this using a Salesforce DTO
	 * class is not possible so it needs to be manually added to the response
	 *
	 * @return Boolean - An indicator to show if the response is an array and is withing a key node.
	 */
	protected override Boolean hasArrayResponse()
	{
		return true;
	}

	/**
	 * @description Returns the list of required parameters need to execute the request
	 *
	 * @return A list of required service parameters
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	protected override Set<String> getRequiredParameters()
	{
		Set<String> parameters = super.getRequiredParameters();
		parameters.add(PARAMETER_PERSON_ID);
		return parameters;
	}

	/**
	 * @description Override to validate if all the information required to make API call is available
	 *
	 * @return Boolean Returns true if all the information is present, else will return false
	 */
	protected override Boolean abortRequest()
	{
		Boolean mustAbort = super.abortRequest();

		if(!mustAbort)
		{
			if(String.isBlank(requestParameters.getFirst(PARAMETER_PERSON_ID)))
			{
				mustAbort = true;
				callResult.errors.add(ERROR_PERSON_NOT_FOUND);
			}
		}

		return mustAbort;
	}

	/**
	 * @description Override to construct API endpoint
	 *
	 * @return String Complete API Endpoint
	 */
	protected override String getWebServiceEndPoint()
	{
		return String.format
				(
						super.getWebServiceEndPoint(),
						new List<String> {EncodingUtil.urlEncode(requestParameters.getFirst(PARAMETER_PERSON_ID), UTF8_ENCODING_SCHEME)}
				);
	}

	protected override void parseResponse()
	{
		super.parseResponse();
		baseResponseDTO = transformResponse(DTO_TransformedResponse.class);
	}

	/**
	 * @description Inner class to define structure of response body
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		/**
		 * @description Response from API is in the following structure:
		 * [policyNumber : { DTO_Contract }] where DTO_Contract is all the fields in the DTO
		 */
		public List<Map<String, DTO_Contract>> responses = new List<Map<String, DTO_Contract>>();

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
	 * @description Represents the response after transformation into a system friendly dto
	 */
	public class DTO_TransformedResponse extends CMN_DTO_JsonBase
	{
		/**
		 * @description List of contract objects
		 */
		public List<DTO_Contract> contracts = new List<DTO_Contract>();

		/**
		 * @description Will transform the given DTO into the current class type
		 *
		 * @param dtoBase Input DTO, in this circumstance we are expecting DTO_Response
		 *
		 * @see RSC_API_GetTaxCertificates.DTO_Response
		 */
		public override void transform(CMN_DTO_Base dtoBase)
		{
			DTO_Response dtoResponse = (DTO_Response)dtoBase;

			if(!dtoResponse.responses.isEmpty())
			{
				//We are getting list of map as response : dtoResponse.responses
				Map<String, DTO_Contract> contractMap = new Map<String, DTO_Contract>();

				for(Map<String, DTO_Contract> response : dtoResponse.responses)
				{
					contractMap.putAll(response);
				}

				Set<String> policyNumbers = contractMap.keySet();
				CMN_UTIL_SObjectIndex policyMap = new CMN_UTIL_SObjectIndex(CMN_DAL_SObjectDomain.FIELD_NAME)
						.putAll(SC_DAL_InsurancePolicy.findByName(policyNumbers));
				CMN_UTIL_SObjectIndex faMap = new CMN_UTIL_SObjectIndex(SC_DAL_FinancialAccount.FIELD_FINANCIAL_ACCOUNT_NUMBER)
						.putAll(SC_DAL_FinancialAccount.findByAccountNumber(policyNumbers));

				for(String policyNumber : policyNumbers)
				{
					DTO_Contract dtoContract = contractMap.get(policyNumber);
					dtoContract.policyNumber = policyNumber;

					InsurancePolicy foundPolicy = (InsurancePolicy)policyMap.get(policyNumber);

					if(foundPolicy != null)
					{
						dtoContract.policyStart = foundPolicy.AW_CommencementDate__c;
						dtoContract.status = foundPolicy.Status;
						dtoContract.productType = foundPolicy.PolicyType;
						dtoContract.policyName = foundPolicy.PolicyName;
					}
					else
					{
						FinServ__FinancialAccount__c foundAccount = (FinServ__FinancialAccount__c)faMap.get(policyNumber);
						if(foundAccount != null)
						{
							dtoContract.policyStart = foundAccount.FinServ__OpenDate__c;
							dtoContract.status = foundAccount.FinServ__Status__c;
							dtoContract.productType = foundAccount.FinServ__FinancialAccountType__c;
							dtoContract.policyName = foundAccount.Name;
						}
						else
						{
							CMN_UTIL_Logger.warn(String.format(WARNING_POLICY_NOT_FOUND, new List<String> {policyNumber}), LOG_CLASS_METHOD);
						}
					}

					contracts.add(dtoContract);
				}
			}
		}
	}

	/**
	 * @description Represents the response after transformation into a table friendly dto
	 */
	public class DTO_Table extends CMN_API_HttpBaseOutbound.DTO_BaseTable
	{

		/**
		 * @description Will transform the given DTO into the current class type
		 *
		 * @param dtoBase Input DTO, in this circumstance we are expecting DTO_TransformedResponse
		 *
		 * @see RSC_API_GetTaxCertificates.DTO_TransformedResponse
		 */
		public override void transform(CMN_DTO_Base dtoBase)
		{
			super.transform(dtoBase);

			DTO_TransformedResponse dtoTransformedResponse = (DTO_TransformedResponse)dtoBase;

			addColumn('Policy Number', 'policyNumber', 'text', true);
			addColumn('Product Type', 'productType', 'text');
			addColumn('Policy Start', 'policyStart', 'date');
			addColumn('Status', 'status', 'text');
			addColumn('Certificate Type', 'certificateType', 'text');
			addColumn('Year', 'year', 'text');

			for(DTO_Contract contract : dtoTransformedResponse.contracts)
			{
				addRow(contract);
			}
		}

		/**
		 * @description Override addRow function to add multiple rows per IRP5/IRP5_IT3A/IT3A/LISP/contribution entry
		 *
		 * @param anObject Input object, in this case we are expecting DTO_Contract
		 */
		public override void addRow(Object anObject)
		{
			DTO_Contract dtoContract = (DTO_Contract)anObject;

			populateDTOTaxTableRow(dtoContract, dtoContract.IRP5, 'IRP5');
			populateDTOTaxTableRow(dtoContract, dtoContract.IRP5_IT3A, 'IRP5_IT3A');
			populateDTOTaxTableRow(dtoContract, dtoContract.IT3A, 'IT3A');
			populateDTOTaxTableRow(dtoContract, dtoContract.LISP, 'LISP');
			populateDTOTaxTableRow(dtoContract, dtoContract.contribution, 'Contribution');
		}

		/**
		 * @description Adds multiple rows based on the contract information, entries of the tax year list, and the tax certificate type
		 *
		 * @param dtoContract Contract object containing information about the policy
		 * @param dtoTaxYears List of tax years there are tax certificates for during a particular year
		 * @param certificateType Certificate type
		 */
		private void populateDTOTaxTableRow(DTO_Contract dtoContract, List<DTO_TaxYear> dtoTaxYears, String certificateType)
		{
			if(dtoTaxYears != null)
			{
				for(DTO_TaxYear dtoTaxYear : dtoTaxYears)
				{
					DTO_Row dtoRow = new DTO_Row();

					dtoRow.certificateType = certificateType;
					dtoRow.policyNumber = dtoContract.policyNumber;
					dtoRow.policyStart = dtoContract.policyStart;
					dtoRow.productType = dtoContract.productType;
					dtoRow.status = dtoContract.status;
					dtoRow.year = dtoTaxYear.taxYear;

					super.addRow(dtoRow);
				}
			}
		}
	}

	/**
	 * @description DTO describing the rows in a table containing transformed policy information
	 */
	private class DTO_Row
	{
		public Datetime policyStart;
		public String certificateType;
		public String policyNumber;
		public String productType;
		public String status;
		public String year;
	}

	/**
	 * @description DTO to specify contractsType structure
	 */
	@TestVisible
	private class DTO_Contract
	{
		public Datetime policyStart;
		@SuppressWarnings('PMD.FieldNamingConventions')
		public List<DTO_TaxYear> IRP5;
		@SuppressWarnings('PMD.FieldNamingConventions')
		public List<DTO_TaxYear> IRP5_IT3A;
		@SuppressWarnings('PMD.FieldNamingConventions')
		public List<DTO_TaxYear> IT3A;
		@SuppressWarnings('PMD.FieldNamingConventions')
		public List<DTO_TaxYear> LISP;
		public List<DTO_TaxYear> contribution;
		public String policyNumber;
		public String productType;
		public String status;
		public String policyName;
	}

	/**
	 * @description DTO to specify TaxYear structure
	 */
	private class DTO_TaxYear
	{
		public String taxYear;
	}

	/**
	 * @description Override to return inner class having Mock response
	 *
	 * @return CMN_API_HttpBaseOutboundMock RSC_API_GetTaxCertificatesMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new RSC_API_GetTaxCertificatesMock();
	}

	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	private class RSC_API_GetTaxCertificatesMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '[{"' + testPolicyNumber1 + '":{"Contribution":[{"taxYear":"2019"},{"taxYear":"2018"},{"taxYear":"2017"},' +
				'{"taxYear":"2016"},{"taxYear":"2015"},{"taxYear":"2014"},{"taxYear":"2013"},{"taxYear":"2012"},{"taxYear":"2011"},{"taxYear":"2010"}]}},' +
				'{"' + testPolicyNumber2 + '":{"IRP5":[{"taxYear":"2012"},{"taxYear":"2011"},{"taxYear":"2010"}]}}]';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}