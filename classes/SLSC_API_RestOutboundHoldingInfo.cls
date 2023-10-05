public with sharing class SLSC_API_RestOutboundHoldingInfo extends SLSC_API_RestOutboundMule {

    public static final String SERVICE_NAME = SLSC_API_RestOutboundHoldingInfo.class.getName();

    //Global constants for exceptions
    @TestVisible
    private static final String EXC_HOLDING_ID_NOT_FOUND = 'Financial Holding not found, unable to process request';
    @TestVisible
    private static final String EXC_ACCOUNT_ENTITY_NUMBER_NOT_FOUND = 'Financial Account Entity Number is not found, unable to process request';
    @TestVisible
    private static final String EXC_HOLDING_FUND_ACC_NUMBER_NOT_FOUND = 'Holding Fund Acc Number is not found, unable to process request';

    private FinServ__FinancialHolding__c holding;

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
     * @return CMN_API_HttpBaseOutboundMock SLSC_API_RestOutboundHoldingInfoMock is extension class and contains Mock response
     */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
    {
        return new SLSC_API_RestOutboundHoldingInfoMock();
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
                                getFinAccountEntityNumber(), getHoldingFundAccNumber()
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
            holding = AW_DAL_FinancialHolding.findById(queueItem.CMN_TriggeringObjectId__c);

            if(holding == null)
            {
                mustAbort = true;
                callResult.errors.add(EXC_HOLDING_ID_NOT_FOUND);
            }
            else
            {
                if(String.isBlank(getFinAccountEntityNumber()))
                {
                    mustAbort = true;
                    callResult.errors.add(EXC_ACCOUNT_ENTITY_NUMBER_NOT_FOUND);
                }

                if(String.isBlank(getHoldingFundAccNumber()))
                {
                    mustAbort = true;
                    callResult.errors.add(EXC_HOLDING_FUND_ACC_NUMBER_NOT_FOUND);
                }
            }
        }

        return mustAbort;
    }

    private String getFinAccountEntityNumber()
    {
        return holding.FinServ__FinancialAccount__r.SLSC_EntityNumber__c;
    }

    private String getHoldingFundAccNumber()
    {
        return holding.SLSC_FundAccNumber__c;
    }

    public class DTO_Response extends CMN_DTO_JsonBase {
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

        protected override Type getObjectType()
        {
            return DTO_Response.class;
        }
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
    public class SLSC_API_RestOutboundHoldingInfoMock extends CMN_API_HttpBaseOutboundMock
    {
        private final String VALID_RESPONSE = '{ "accountGroupId": "SUTTFSA", "accountTypeCode": 1, "availableMarketValue": 14350.530274, "availableUnits": 1436.1942, "brokerName": "GDTYLTHGROFINANCIALSERVI", "brokerNumber": 994400, "cededUnits": 0, "clientAccountGroupNumber": 1919506, "clientAccountNumber": 700599193, "recurringDebitOrderId": null, "hasRecurringDebitOrder": false, "fund": { "fundNumber": 153, "fundId": "INF", "jseCode": "STBI", "isinNumber": "ZAE000021481", "fundName": "1NVEST Index Fund R", "fundClass": null, "unitPrice": 999.205419, "productCode": 529, "currencyCode": "ZAR", "currencyId": 1 }, "isActive": true, "marketValue": 14350.530273763698, "totalUnits": 1436.1942, "unclearedUnits": 0, "pendingUnits": 0, "transactableUnits": 1436.1942, "transactableValue": 14350.530273763698, "unitPriceDate": "2021-11-12T00:00:00+02:00" }';

        protected override void setResponse(HttpRequest request, HttpResponse response)
        {
            super.setResponse(request, response);
            response.setBody(VALID_RESPONSE);
        }
    }
}