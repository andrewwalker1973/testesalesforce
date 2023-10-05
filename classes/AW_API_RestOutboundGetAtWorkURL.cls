/**
 * @description Service class to make the API call, to get atWork Client URL using atWork username
 *
 * @see AW_API_RestOutboundGetAtWorkURL_TEST @story ST-2375
 * @see AW_CTR_GetAtWorkURL
 * @see AW_TEST_CTR_GetAtWorkURL
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date November 2021, March 2023
 */
public inherited sharing class AW_API_RestOutboundGetAtWorkURL extends CMN_API_RestBaseOutbound
{
	/**
	 * @description API name of the webservice handler
	 */
	public static final String SERVICE_NAME = AW_API_RestOutboundGetAtWorkURL.class.getName();

	/**
	 * @description If set to true, will ensure mock class returns an error in payload if thought the response has HTTP code of 200
	 */
	@TestVisible
	private static Boolean returnErrorInResponse = false;

	private Account adviserAccount;
	private String currentUserUACFID;

	private static final String FMT_QUERY_PARAMETERS = 'secureKey={0}&userName={1}&UACFID={2}&consultantCode={3}&RSAIDNumber={4}';
	private static final String AMPERSAND = '&';

	@TestVisible
	private static final String ERROR_USERNAME_BLANK = 'Username is blank, unable to process request.';
	@TestVisible
	private static final String ERROR_ACCOUNT_NOT_FOUND = 'Account is not found, unable to process request.';
	@TestVisible
	private static final String ERROR_UACFID_NOT_FOUND = 'Adviser\'s UACF Id is not found, unable to process request';
	@TestVisible
	private static final String ERROR_CONSULTANT_CODE_NOT_FOUND = 'Adviser\'s Consultant Code is not found, unable to process request';

	/**
	 * @description The Success or Fail Message for the Call
	 */
	public String message
	{
		get
		{
			return ((DTO_Response)baseResponseDTO).message;
		}
	}

	/**
	 * @description Returns the URL to be used when accessing atWork
	 */
	public String secureUrl
	{
		get
		{
			return ((DTO_Response)baseResponseDTO).secureUrl;
		}
	}

	/**
	 * @description The Success or Fail status for the Call
	 */
	public Boolean success
	{
		get
		{
			return CMN_UTIL_Boolean.stringToBoolean(((DTO_Response)baseResponseDTO).success);
		}
	}

	/**
	 * @description Override to set request and response DTO types and any other globals which may be used
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new CMN_DTO_JsonBase();
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
	 * @description Override to return inner class having Mock response
	 *
	 * @return CMN_API_HttpBaseOutboundMock AW_API_RestOutboundGetAtWorkURLMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new AW_API_RestOutboundGetAtWorkURLMock();
	}

	/**
	 * @description Override to validate if all the information required to make API call is available
	 *
	 * @return Boolean Returns true if all the information is present, else will return false
	 */
	@SuppressWarnings('PMD.CognitiveComplexity')
	protected override Boolean abortRequest()
	{
		Boolean mustAbort = super.abortRequest();

		if(!mustAbort)
		{
			if(String.isBlank(queueItem.CMN_SourceID__c))
			{
				mustAbort = true;
				callResult.errors.add(ERROR_USERNAME_BLANK);
			}

			adviserAccount = AW_DAL_Account.findById(queueItem.CMN_TriggeringObjectId__c);

			if(adviserAccount == null)
			{
				mustAbort = true;
				callResult.errors.add(ERROR_ACCOUNT_NOT_FOUND);
			}
			else
			{
				User accountOwner = AW_DAL_User.findById(adviserAccount.OwnerId);
				User currentUser = AW_DAL_User.findById(UserInfo.getUserId());

				if(String.isBlank(accountOwner.AW_ConsultantCode__c))
				{
					mustAbort = true;
					callResult.errors.add(ERROR_CONSULTANT_CODE_NOT_FOUND);
				}

				currentUserUACFID = currentUser.AW_UACFID__c;
				if(String.isBlank(currentUserUACFID))
				{
					mustAbort = true;
					callResult.errors.add(ERROR_UACFID_NOT_FOUND);
				}
			}
		}

		return mustAbort;
	}

	/**
	 * @description Override to return query params
	 *
	 * @return String
	 */
	protected override String getQueryParameters()
	{
		String existingParams = super.getQueryParameters();

		String clientQueryParams = String.format
				(
						FMT_QUERY_PARAMETERS,
						new List<String> {getSecureKey(), queueItem.CMN_SourceID__c, currentUserUACFID, adviserAccount.Owner.AW_ConsultantCode__c, adviserAccount.AW_IdentificationNumber__pc}
				);

		return String.isBlank(existingParams) ? clientQueryParams : existingParams + AMPERSAND + clientQueryParams;
	}

	/**
	 * @description Override to return secure key
	 *
	 * @return String
	 */
	private String getSecureKey()
	{
		return settings != null ? settings.CMN_ApiKey__c : CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description Extension of CMN_DTO_JsonBase class to specify response structure
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public String message;
		public String secureUrl;
		public String success;

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
	 * @description Mock Response class to be used in test classes for unit testing
	 */
	private class AW_API_RestOutboundGetAtWorkURLMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String errorResponse = '{"success":"false","message":"Uacf Id is not valid for this user.","secureUrl":"https://libdev.atwork.co.za/login"}';
		private final String validResponse = '{"success":"true","message":"Login successful","secureUrl":"https://libuat.atwork.co.za/gamma/account/Sessionredirect?' +
				'ClientID=4887782&SessionID=d5ce8eb2-f756-4fa6-8ead-1f0d1255cb89&GenSec=J2M_Pz8_Pz8_FmE_P0okPw2"}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(returnErrorInResponse ? errorResponse : validResponse);
		}
	}
}