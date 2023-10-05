/**
 * @description Service class to make the API call to retrieve the policy summary
 *
 * @see AW_API_RestOutboundPolicySummary_TEST @story ST-111986
 *
 * @author Thiru
 *
 * @date June 2021
 */
public inherited sharing class AW_API_RestOutboundPolicySummary extends CMN_API_RestBaseOutboundMule
{
	public static final String SERVICE_NAME = AW_API_RestOutboundPolicySummary.class.getName();
	private String contractNumber;

	@TestVisible
	private static final String CONTRACT_HAS_NO_NUMBER = 'Contract does not have a Number';

	/**
	 * @description Initialises various class variables
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
	 * @description Override to validate if all the information required to make API call is available
	 *
	 * @return Boolean Returns true if all the information is present, else will return false
	 */
	protected override Boolean abortRequest()
	{
		Boolean mustAbort = super.abortRequest();

		if(!mustAbort)
		{
			SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(queueItem.CMN_TriggeringObjectId__c);

			if(objectType == FinServ__FinancialAccount__c.SObjectType)
			{
				FinServ__FinancialAccount__c financialAccount = AW_DAL_FinancialAccount.findById(queueItem.CMN_TriggeringObjectId__c);
				contractNumber = financialAccount?.FinServ__FinancialAccountNumber__c;
			}
			else if(objectType == InsurancePolicy.SObjectType)
			{
				InsurancePolicy policy = AW_DAL_InsurancePolicy.findByInsurancePolicyId(queueItem.CMN_TriggeringObjectId__c);
				contractNumber = policy?.Name;
			}

			if(String.isBlank(contractNumber))
			{
				mustAbort = true;
				callResult.errors.add(CONTRACT_HAS_NO_NUMBER);
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
						new List<String>
						{
								contractNumber
						}
				);
	}

	/**
	 * @description Inner class to define structure of response body
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public String fileByteStream;

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
	 * @description Override to return mock response for test class
	 *
	 * @return AW_API_RestOutboundPolicySummaryMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new AW_API_RestOutboundPolicySummaryMock();
	}
	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	private class AW_API_RestOutboundPolicySummaryMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String VALID_RESPONSE = '{"fileByteStream": "MDA2MjE4NzIyMU1VTDAxMDEyODA1MjAyMTEwMTMyOC5QREY="}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}
	}
}