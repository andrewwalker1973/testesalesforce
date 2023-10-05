@IsTest(SeeAllData=false IsParallel=true)
private class SLSC_API_RestOutboundMule_TEST {

    private static final Integer NUM_ACCOUNTS_TO_CREATE = 1;

    @TestSetup
    static void insertTestData()
    {
        AW_DAL_TestDataFactory.createClientAccount(NUM_ACCOUNTS_TO_CREATE);
    }

    /**
     * @description test Rest Outbound Call get valid response
     */
    @IsTest
    static void checkValidResponse() {
        Account acc = AW_DAL_Account.getAll()[0];
        SLSC_API_RestOutboundMule.responseType = SLSC_API_RestOutboundMule.RESPONSE_TYPE_VALID;

        String responseBody;
        Test.startTest();
        try {
            responseBody = SLSC_API_RestOutboundMule.getResponseBody(SLSC_API_RestOutboundMule.SERVICE_NAME, acc.Id);
        } catch (CMN_API_HttpBaseOutbound.HttpOutboundRequestException error) {
            System.assert(false, 'Error was thrown');
        }
        Test.stopTest();

        System.assertEquals(SLSC_API_RestOutboundMule.VALID_RESPONSE, responseBody);
    }

    /**
     * @description test Rest Outbound Call was successful but get response body with not found error
     */
    @IsTest
    static void checkNotFoundResponse() {
        Account acc = AW_DAL_Account.getAll()[0];
        SLSC_API_RestOutboundMule.responseType = SLSC_API_RestOutboundMule.RESPONSE_TYPE_NOT_FOUND;

        Test.startTest();
        try {
            SLSC_API_RestOutboundMule.getResponseBody(SLSC_API_RestOutboundMule.SERVICE_NAME, acc.Id);
        } catch (CMN_API_HttpBaseOutbound.HttpOutboundRequestException error) {
            System.assertEquals(SLSC_API_RestOutboundMule.RESPONSE_TYPE_NOT_FOUND, error.getMessage());
        }
        Test.stopTest();
    }

    /**
     * @description test Rest Outbound Call get invalid response scenario
     */
    @IsTest
    static void checkUnexpectedResponse() {
        Account acc = AW_DAL_Account.getAll()[0];

        Test.startTest();
        try {
            SLSC_API_RestOutboundMule.getResponseBody(SLSC_API_RestOutboundMule.SERVICE_NAME, acc.Id);
        } catch (CMN_API_HttpBaseOutbound.HttpOutboundRequestException error) {
            System.assertEquals(SLSC_API_RestOutboundMule.STR_UNEXPECTED_ERROR, error.getMessage());
        }
        Test.stopTest();
    }
}