/**
 * @description Service class to make the API call to refresh the contracts
 *
 * @see AW_API_RefreshContracts_TEST @story ST-127570
 *
 * @author jason.van.beukering@accenture.com, jayanth.kumar.s@accenture.com
 *
 * @date May 2021, May 2023
 */
public inherited sharing class AW_API_RefreshContracts extends CMN_API_RestBaseOutboundMule
{
	private Account client;
	private static final String ERROR_NO_CLIENT_FOUND = 'Unable to process request as no Client was found.';
	private static final String ERROR_NO_COMPANY_REGISTRATION = 'Unable to process request as Company Registration Number is blank.';
	private static final String ERROR_NO_IDENTITY_NUMBER = 'Unable to process request as Identity Number is blank.';
	private static final String HTTP_HEADER_IDENTIFICATION_TYPE = 'idType';
	private static final String IDENTIFICATION_TYPE_ORGANIZATION = 'Company Registration';
	private static final String IDENTIFICATION_TYPE_PASSPORT = 'passport';
	private static final String IDENTIFICATION_TYPE_SA_ID_NUMBER = 'saNationalIdNumber';
	private static final String ORGANIZATION_CONTRACTS_DYNAMIC_URL = '/Organizations/Contracts?IsOwnerRole=true&organizationId={0}';
	private static final String PERSON_CONTRACTS_DYNAMIC_URL = '/Persons/{0}/Contracts?IsOwnerRole=true';

	/**
	 * @description Class Name of the service
	 */
	public static final String SERVICE_NAME = AW_API_RefreshContracts.class.getName();

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
	public override virtual String getVerb()
	{
		return HTTP_VERB_GET;
	}

	/**
	 * @description Define which objects are valid for data manipulation
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType> {Account.SObjectType});
	}

	/**
	 * @description Override to set header values
	 */
	protected override void setHeaders()
	{
		super.setHeaders();

		String identificationTypeQueryParameter;

		if(AW_DAL_Account.PICK_SA_ID_TYPE.equalsIgnoreCase(client.AW_IdentificationType__pc))
		{
			identificationTypeQueryParameter = IDENTIFICATION_TYPE_SA_ID_NUMBER;
		}
		else if(AW_DAL_Account.PICK_PASSPORT_TYPE.equalsIgnoreCase(client.AW_IdentificationType__pc))
		{
			identificationTypeQueryParameter = IDENTIFICATION_TYPE_PASSPORT;
		}
		else
		{
			identificationTypeQueryParameter = IDENTIFICATION_TYPE_ORGANIZATION;
		}

		request.setHeader(HTTP_HEADER_IDENTIFICATION_TYPE, identificationTypeQueryParameter);
	}

	/**
	 * @description Override to validate if all the information required to make API call is available
	 *
	 * @return Boolean Returns true if all the information is present, else will return false
	 */
	protected override Boolean abortRequest() // NOPMD Method cannot be made less complex
	{
		Boolean mustAbort = super.abortRequest();

		if(!mustAbort)
		{
			client = AW_DAL_Account.findById(Id.valueOf(queueItem.CMN_TriggeringObjectId__c));

			if(client == null)
			{
				mustAbort = true;
				callResult.errors.add(ERROR_NO_CLIENT_FOUND);
			}
			else
			{
				if(client.IsPersonAccount)
				{
					if(String.isBlank(client.AW_IdentificationNumber__pc))
					{
						mustAbort = true;
						callResult.errors.add(ERROR_NO_IDENTITY_NUMBER);
					}

				}
				else if(String.isBlank(client.AW_CompanyRegistrationTrustNumber__c))
				{
					mustAbort = true;
					callResult.errors.add(ERROR_NO_COMPANY_REGISTRATION);
				}
			}
		}

		return mustAbort;
	}

	/**
	 * @description Construct the API endpoint URL
	 *
	 * @return final Endpoint to be called
	 */
	protected override String getWebServiceEndPoint()
	{
		String clientType = client.IsPersonAccount ? PERSON_CONTRACTS_DYNAMIC_URL : ORGANIZATION_CONTRACTS_DYNAMIC_URL;
		String identificationNumber = client.IsPersonAccount ? client.AW_IdentificationNumber__pc : client.AW_CompanyRegistrationTrustNumber__c;
		return super.getWebServiceEndPoint() + String.format
				(
						clientType,
						new List<String>
						{
								EncodingUtil.urlEncode(identificationNumber, UTF8_ENCODING_SCHEME)
						}
				);

	}

	/**
	 * @description Takes all the work that has been registered with the UnitOfWork and commits it to the database
	 */
	public override void commitWork()
	{
		//May be triggered by a user who does not have the ability to update the account (like an Agent)
		super.commitWork(false);
	}

	/**
	 * @description Will ensure that the change to Sobjects is registered to be committed after
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		Account updatedAccount = new Account();

		updatedAccount.Id = client.Id;
		updatedAccount.AW_PoliciesRefreshStatus__c = AW_DAL_Account.PICK_REFRESH_REQUESTED;
		updatedAccount.AW_PoliciesRefreshStatusDate__c = Datetime.now();

		registerDirty(updatedAccount);
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
	private class AW_API_RefreshContractsMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"message": "Refresh acknowledged"}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}

	/**
	 * @description Inner class to define structure of response body
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		@SuppressWarnings('ApexUnusedDeclaration')
		public String message;

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
}