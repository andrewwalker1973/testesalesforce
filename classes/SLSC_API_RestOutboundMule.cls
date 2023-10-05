public virtual class SLSC_API_RestOutboundMule extends CMN_API_RestBaseOutboundMule {

    public static final String AMPERSAND = '&';
    public static final String SERVICE_NAME = SLSC_API_RestOutboundMule.class.getName();

    @TestVisible
    private static final String NOT_FOUND_STATUS_CODE = '404';
    @TestVisible
    private static final String INVALID_VALUE_STATUS_CODE = '400';
    @TestVisible
    private static final String STR_UNEXPECTED_ERROR = 'An unexpected error occurred.';
    @TestVisible
    private static String responseType = '';
    @TestVisible
    private static final String RESPONSE_TYPE_VALID = 'ValidResponse';
    @TestVisible
    private static final String RESPONSE_TYPE_NOT_FOUND = 'NotFoundResponse';
    @TestVisible
    private static final String VALID_RESPONSE = '{"mocked":"true"}';

    protected virtual override String getServiceName()
    {
        return SERVICE_NAME;
    }

    protected virtual override void initialise()
    {
        super.initialise();

        baseResponseDTO =  new DTO_Response();
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
    * @description Override to return inner class having Mock response
    *
    * @return CMN_API_HttpBaseOutboundMock SLSC_API_RestOutboundMuleMock is extension class and contains Mock response
    */
    protected virtual override CMN_API_HttpBaseOutboundMock getEndpointMock()
    {
        return new SLSC_API_RestOutboundMuleMock();
    }

    /**
    * @description Used to execute an Outbound REST API Handler by its name and record Id and get response body
    *
    * @return Returns a response body as String
    */
    public static String getResponseBody(String serviceName, String recordId) {
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(serviceName, recordId);
        List<CMN_API_HttpBase> webserviceHandlers = CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c>{
                queueItem
        });

        SLSC_API_RestOutboundMule webserviceHandler = (SLSC_API_RestOutboundMule) webserviceHandlers[0];
        CMN_DAL_WebserviceCallQueue.ServiceCallResult callResult = webserviceHandler.callResult;

        return getMulesoftResponse(callResult);
    }

    private static String getMulesoftResponse(CMN_DAL_WebserviceCallQueue.ServiceCallResult callResult) {
        if (callResult.statusCode == String.valueOf(CMN_API_HttpBase.HTTP_OK) && String.valueOf(callResult.status) == CMN_DAL_WebserviceCallQueue.STATUS_COMPLETED) {
            if(String.isNotBlank(callResult.responseBody)){
                return callResult.responseBody;
            }
        } else if (String.valueOf(callResult.status) == CMN_DAL_WebserviceCallQueue.STATUS_FAILED
                && (callResult.statusCode == NOT_FOUND_STATUS_CODE || callResult.statusCode == INVALID_VALUE_STATUS_CODE)) {
            if (String.isNotBlank(callResult.responseBody)) {
                throw new CMN_API_HttpBaseOutbound.HttpOutboundRequestException(callResult.responseBody);
            }
        }

        String message = callResult.errors.isEmpty() ? STR_UNEXPECTED_ERROR : callResult.errors[0];
        throw new CMN_API_HttpBaseOutbound.HttpOutboundRequestException(message);
    }

    public class DTO_Response extends CMN_DTO_JsonBase
    {
        public String mocked;

        protected override Type getObjectType()
        {
            return DTO_Response.class;
        }
    }

    /**
    * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
    */
    public class SLSC_API_RestOutboundMuleMock extends CMN_API_HttpBaseOutboundMock
    {
        protected override void setResponse(HttpRequest request, HttpResponse response)
        {
            super.setResponse(request, response);

            if(responseType == RESPONSE_TYPE_VALID) {
                response.setStatus(CMN_DAL_WebserviceCallQueue.STATUS_COMPLETED);
                response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
                response.setBody(VALID_RESPONSE);
            }
            else if (responseType == RESPONSE_TYPE_NOT_FOUND) {
                response.setStatus(CMN_DAL_WebserviceCallQueue.STATUS_FAILED);
                response.setStatusCode(Integer.valueOf(NOT_FOUND_STATUS_CODE));
                response.setBody(RESPONSE_TYPE_NOT_FOUND);
            } else {
                super.setErrorResponse(response);
            }
        }
    }
}