@IsTest(SeeAllData=false IsParallel=true)
private class SLSC_API_RestOutboundOnlineDetails_TEST {

    private static final Integer NUM_ACCOUNTS_TO_CREATE = 1;

    @TestSetup
    static void insertTestData()
    {
        Account acc = AW_DAL_TestDataFactory.createClientAccount(NUM_ACCOUNTS_TO_CREATE)[0];
        acc.SLC_IDNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
        acc.SLSC_IDType__c = CMN_DAL_SObjectDomain.generateRandomName();
        update acc;
    }

    /**
     * @description    Method to create webservice queue records
     *
     * @return  Returns list of webservice queue records
     */
    private static List<CMN_WebserviceCallQueue__c> setup()
    {
        Account newAccount = AW_DAL_Account.getAll()[0];

        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(SLSC_API_RestOutboundOnlineDetails.SERVICE_NAME, newAccount.Id);

        return new List<CMN_WebserviceCallQueue__c> {queueItem};
    }

    /**
     * @description Test Method to validate the scenario wherein successful outbound API call is made
     */
    @IsTest
    static void successfulCall()
    {
        CMN_API_RestBaseOutboundTestHelper.successfulCall(setup());
    }

    /**
     * @description test triggering object is not found scenario
     */
    @IsTest
    static void failedNoTriggeringObjectId()
    {
        List<CMN_WebserviceCallQueue__c> queueItems = setup();
        Account acc = AW_DAL_Account.findById(queueItems[0].CMN_TriggeringObjectId__c);
        delete acc;

        validateResponse(queueItems, SLSC_API_RestOutboundOnlineDetails.EXC_ACCOUNT_ID_NOT_FOUND);
    }

    /**
     * @description test Account has Id Number not set scenario
     */
    @IsTest
    static void failedNoAccountIdNumber()
    {
        List<CMN_WebserviceCallQueue__c> queueItems = setup();
        Account acc = AW_DAL_Account.findById(queueItems[0].CMN_TriggeringObjectId__c);
        acc.SLC_IDNumber__c = null;
        update acc;

        validateResponse(queueItems, SLSC_API_RestOutboundOnlineDetails.EXC_ACCOUNT_ID_NUMBER_NOT_FOUND);
    }

    /**
     * @description test Account has Id Type not set scenario
     */
    @IsTest
    static void failedNoAccountIdType()
    {
        List<CMN_WebserviceCallQueue__c> queueItems = setup();
        Account acc = AW_DAL_Account.findById(queueItems[0].CMN_TriggeringObjectId__c);
        acc.SLSC_IDType__c = null;
        update acc;

        validateResponse(queueItems, SLSC_API_RestOutboundOnlineDetails.EXC_ACCOUNT_ID_TYPE_NOT_FOUND);
    }

    private static void validateResponse(List<CMN_WebserviceCallQueue__c> queueItems, String excMessage)
    {
        Test.startTest();

        List<CMN_API_HttpBase> responses = CMN_FACTORY_WebserviceManager.execute(queueItems);

        Test.stopTest();

        for(CMN_API_HttpBase response : responses)
        {
            System.assertNotEquals(true, response.callResult.errors.isEmpty(), 'No errors thrown');
            System.assert(response.callResult.errors[0].contains(excMessage));
            System.assertEquals(true, response.callResult.aborted, 'Expected Request to have aborted.');
        }
    }
}