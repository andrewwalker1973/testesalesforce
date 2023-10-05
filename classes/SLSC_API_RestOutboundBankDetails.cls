public with sharing class SLSC_API_RestOutboundBankDetails extends SLSC_API_RestOutboundMule {

    private static final String FMT_QUERY_PARAMETERS = 'idType={0}&idNumber={1}';
    private static final String BANK_DETAILS_RESPONSE = '"bankDetailsList" :';
    public static final String SERVICE_NAME = SLSC_API_RestOutboundBankDetails.class.getName();

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
     * @return CMN_API_HttpBaseOutboundMock SLSC_API_RestOutboundBankDetailsMock is extension class and contains Mock response
     */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
    {
        return new SLSC_API_RestOutboundBankDetailsMock();
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

    /**
     * @description Override to inject JSON outer class in API response
     *
     * @return String Response body
     */
    protected override String getResponseBody()
    {
        String responseBody = super.getResponseBody();

        //We have to inject a JSON outer class because we are receiving an Array Response
        return '{' + BANK_DETAILS_RESPONSE + responseBody + '}';
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
        public List<DTO_BankDetails> bankDetailsList = new List<DTO_BankDetails>();

        protected override Type getObjectType()
        {
            return DTO_Response.class;
        }
    }

    public class DTO_BankDetails extends CMN_DTO_JsonBase
    {
        public String entityNumber;
        public String bankDetailNumber;
        public String accountHolderName;
        public String accountType;
        public String bankName;
        public String bankNumber;
        public String branchText;
        public String branchCode;
        public String clientOwned;
        public String verificationStatus;
        public String createdBy;
        public String dateCreated;
        public String modifiedBy;
        public String dateModified;
        public String timestamp;
        public String allowETrade;
        public String isAlreadyDisabled;
        public String isDisabled;
    }

    /**
     * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
     */
    public class SLSC_API_RestOutboundBankDetailsMock extends CMN_API_HttpBaseOutboundMock
    {
        private final String VALID_RESPONSE = '[ { "entityNumber": 1190559, "bankDetailNumber": 1845898, "accountHolderName": "SCM .jaansenva", "accountType": "Current Account", "bankName": "STANDARD BANK S.A", "bankNumber": 1, "branchText": "STANDARD BANK SOUTH AFRICA    ", "branchCode": "51001", "clientOwned": true, "verificationStatus": "Verified", "createdBy": "ARUIA", "dateCreated": "2017-06-25T23:59:59", "modifiedBy": null, "dateModified": "0001-01-01T00:00:00", "timestamp": "2017-06-25T10:36:57", "allowETrade": false, "isAlreadyDisabled": false, "isDisabled": false }, { "entityNumber": 949581, "bankDetailNumber": 33256403, "accountHolderName": "SCM tercsd", "accountType": "Savings Account", "bankName": "STANDARD BANK S.A", "bankNumber": 1, "branchText": "STANDARD BANK SOUTH AFRICA    ", "branchCode": "51001", "clientOwned": true, "verificationStatus": "Verified", "createdBy": "SMAGAGUL", "dateCreated": "2018-03-20T09:28:35", "modifiedBy": null, "dateModified": "0001-01-01T00:00:00", "timestamp": "2018-03-20T09:25:59", "allowETrade": true, "isAlreadyDisabled": false, "isDisabled": false } ]';

        protected override void setResponse(HttpRequest request, HttpResponse response)
        {
            super.setResponse(request, response);
            response.setBody(VALID_RESPONSE);
        }
    }
}