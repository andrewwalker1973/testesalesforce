public with sharing class SLSC_API_RestOutboundOnlineDetails extends SLSC_API_RestOutboundMule {

    private static final String FMT_QUERY_PARAMETERS = 'idType={0}&idNumber={1}';
    public static final String SERVICE_NAME = SLSC_API_RestOutboundOnlineDetails.class.getName();

    //Global constants for exceptions
    @TestVisible
    private static final String EXC_ACCOUNT_ID_NOT_FOUND = 'Account not found, unable to process request';
    @TestVisible
    private static final String EXC_ACCOUNT_ID_NUMBER_NOT_FOUND = 'Account Id Number is not found, unable to process request';
    @TestVisible
    private static final String EXC_ACCOUNT_ID_TYPE_NOT_FOUND = 'Account Id Type is not found, unable to process request';

    private Account account;

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
 * @description Override to return query params
 *
 * @return String
 */
    protected override String getQueryParameters()
    {
        String existingParams = super.getQueryParameters();

        String clientQueryParams = String.format(FMT_QUERY_PARAMETERS, new List<String> { getAccountIdType(), getAccountIdNumber() });

        return String.isBlank(existingParams) ? clientQueryParams : existingParams + AMPERSAND + clientQueryParams;
    }


    /**
     * @description Override to return inner class having Mock response
     *
     * @return CMN_API_HttpBaseOutboundMock SLSC_API_RestOutboundOnlineDetailsMock is extension class and contains Mock response
     */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
    {
        return new SLSC_API_RestOutboundOnlineDetailsMock();
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
            account = AW_DAL_Account.findById(queueItem.CMN_TriggeringObjectId__c);

            if(account == null)
            {
                mustAbort = true;
                callResult.errors.add(EXC_ACCOUNT_ID_NOT_FOUND);
            }
            else
            {
                if(String.isBlank(getAccountIdNumber()))
                {
                    mustAbort = true;
                    callResult.errors.add(EXC_ACCOUNT_ID_NUMBER_NOT_FOUND);
                }

                if(String.isBlank(getAccountIdType()))
                {
                    mustAbort = true;
                    callResult.errors.add(EXC_ACCOUNT_ID_TYPE_NOT_FOUND);
                }
            }
        }

        return mustAbort;
    }

    private String getAccountIdNumber()
    {
        return account.SLC_IDNumber__c;
    }

    private String getAccountIdType()
    {
        return account.SLSC_IDType__c;
    }

    public class DTO_Response extends CMN_DTO_JsonBase
    {
        public DTO_Online Online;
        public DTO_SSO SSO;

        protected override Type getObjectType()
        {
            return DTO_Response.class;
        }
    }

    public class DTO_Online
    {
        public String email;
        public String firstName;
        public String surname;
        public String idNumberOrPassport;
        public String lastModified;
        public String mobileNumber;
        public String stanlibId;
    }

    public class DTO_SSO
    {
        public String masterId;
        public String active;
        public String title;
        public String firstname;
        public String surname;
        public String id;
        public String cell;
        public String email;
        public String lastLogin;
    }

    /**
     * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
     */
    public class SLSC_API_RestOutboundOnlineDetailsMock extends CMN_API_HttpBaseOutboundMock
    {
        private final String VALID_RESPONSE = '{ "Online": { "email": "marion.meikle@stanlib.com", "firstName": "Cornelus", "surname": "Schelling", "idNumberOrPassport": "123456789", "lastModified": "2017-03-13T09:51:29.0000000", "mobileNumber": "082 579 2366", "stanlibId": "1973004" }, "SSO": { "masterId": "1973004", "active": true, "title": "Mr", "firstname": "Cornelus", "surname": "Schelling", "id": "123456789", "cell": "082 579 2366", "email": "support@iamrex.com", "lastLogin": null } }';

        protected override void setResponse(HttpRequest request, HttpResponse response)
        {
            super.setResponse(request, response);
            response.setBody(VALID_RESPONSE);
        }
    }
}