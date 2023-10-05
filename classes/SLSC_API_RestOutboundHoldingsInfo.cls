public with sharing class SLSC_API_RestOutboundHoldingsInfo extends SLSC_API_RestOutboundMule {

    private static final String HOLDINGS_RESPONSE = '"holdingList" :';
    public static final String SERVICE_NAME = SLSC_API_RestOutboundHoldingsInfo.class.getName();

    //Global constants for exceptions
    @TestVisible
    private static final String EXC_FINANCIAL_ACCOUNT_ID_NOT_FOUND = 'Financial Account not found, unable to process request';
    @TestVisible
    private static final String EXC_ACCOUNT_ENTITY_NUMBER_NOT_FOUND = 'Financial Account Entity Number is not found, unable to process request';

    private FinServ__FinancialAccount__c financialAccount;

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
     * @description Override to return inner class having Mock response
     *
     * @return CMN_API_HttpBaseOutboundMock SLSC_API_RestOutboundHoldingsInfoMock is extension class and contains Mock response
     */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
    {
        return new SLSC_API_RestOutboundHoldingsInfoMock();
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
                                getFinAccountEntityNumber()
                        }
                );
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
            financialAccount = AW_DAL_FinancialAccount.findById(queueItem.CMN_TriggeringObjectId__c);

            if(financialAccount == null)
            {
                mustAbort = true;
                callResult.errors.add(EXC_FINANCIAL_ACCOUNT_ID_NOT_FOUND);
            }
            else
            {
                if(String.isBlank(getFinAccountEntityNumber()))
                {
                    mustAbort = true;
                    callResult.errors.add(EXC_ACCOUNT_ENTITY_NUMBER_NOT_FOUND);
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
        return '{' + HOLDINGS_RESPONSE + responseBody + '}';
    }

    private String getFinAccountEntityNumber()
    {
        return financialAccount.SLSC_EntityNumber__c;
    }

//    public class DTO_Response extends CMN_DTO_RestBaseResponse
    public class DTO_Response extends CMN_DTO_JsonBase
    {
        public List<DTO_Holding> holdingList = new List<DTO_Holding>();

        protected override Type getObjectType()
        {
            return DTO_Response.class;
        }
    }

    public class DTO_Holding {
        public String accountGroupId;
        public String accountTypeCode;
        public String availableMarketValue;
        public String availableUnits;
        public String brokerName;
        public String brokerNumber;
        public String cededUnits;
        public String clientAccountGroupNumber;
        public String clientAccountNumber;
        public String recurringDebitOrderId;
        public String hasRecurringDebitOrder;
        public DTO_Fund fund;
        public String isActive;
        public String marketValue;
        public String totalUnits;
        public String unclearedUnits;
        public String pendingUnits;
        public String transactableUnits;
        public String transactableValue;
        public String unitPriceDate;
    }

    public class DTO_Fund {
        public String fundNumber;
        public String fundId;
        public String jseCode;
        public String isinNumber;
        public String fundName;
        public String fundClass;
        public String unitPrice;
        public String productCode;
        public String currencyCode;
        public String currencyId;
    }

    /**
     * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
     */
    public class SLSC_API_RestOutboundHoldingsInfoMock extends CMN_API_HttpBaseOutboundMock
    {
        public final String VALID_RESPONSE = '[ { "accountGroupId": "SUTTFSA", "accountTypeCode": 1, "availableMarketValue": 14350.530274, "availableUnits": 1436.1942, "brokerName": "GDTYLTHGROFINANCIALSERVI", "brokerNumber": 994400, "cededUnits": 0, "clientAccountGroupNumber": 1919506, "clientAccountNumber": 700599193, "recurringDebitOrderId": null, "hasRecurringDebitOrder": false, "fund": { "fundNumber": 153, "fundId": "INF", "jseCode": "STBI", "isinNumber": "ZAE000021481", "fundName": "1NVEST Index Fund R", "fundClass": null, "unitPrice": 999.205419, "productCode": 529, "currencyCode": "ZAR", "currencyId": 1 }, "isActive": true, "marketValue": 14350.530273763698, "totalUnits": 1436.1942, "unclearedUnits": 0, "pendingUnits": 0, "transactableUnits": 1436.1942, "transactableValue": 14350.530273763698, "unitPriceDate": "2021-11-12T00:00:00+02:00" }, { "accountGroupId": "SUTTFSA", "accountTypeCode": 1, "availableMarketValue": 13495.897466, "availableUnits": 2690.8029, "brokerName": "GDTYLTHGROFINANCIALSERVI", "brokerNumber": 994400, "cededUnits": 0, "clientAccountGroupNumber": 1919506, "clientAccountNumber": 700741539, "recurringDebitOrderId": null, "hasRecurringDebitOrder": false, "fund": { "fundNumber": 1544, "fundId": "IEFD", "jseCode": "SIEB1", "isinNumber": "ZAE000122099", "fundName": "STANLIB Global Equity Feeder Fund B1", "fundClass": null, "unitPrice": 501.556523, "productCode": 4672, "currencyCode": "ZAR", "currencyId": 1 }, "isActive": true, "marketValue": 13495.897466023167, "totalUnits": 2690.8029, "unclearedUnits": 0, "pendingUnits": 0, "transactableUnits": 2690.8029, "transactableValue": 13495.897466023167, "unitPriceDate": "2021-11-12T00:00:00+02:00" }]';

        protected override void setResponse(HttpRequest request, HttpResponse response)
        {
            super.setResponse(request, response);
            response.setBody(VALID_RESPONSE);
        }
    }
}