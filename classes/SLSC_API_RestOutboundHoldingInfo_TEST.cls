@IsTest(SeeAllData=false IsParallel=true)
private class SLSC_API_RestOutboundHoldingInfo_TEST {

    private static final Integer NUM_RECORDS_TO_CREATE = 1;

    @TestSetup
    static void insertTestData()
    {
        AW_DAL_TestDataFactory.createClientAccount(NUM_RECORDS_TO_CREATE);
    }

    private static List<CMN_WebserviceCallQueue__c> setup()
    {
        List<Account> accounts = AW_DAL_Account.getAll();
        FinServ__FinancialAccount__c finAcc = AW_DAL_TestDataFactory.createFinancialAccounts(accounts[0], NUM_RECORDS_TO_CREATE)[0];
        finAcc.SLSC_EntityNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
        update finAcc;
        FinServ__FinancialHolding__c finHolding = AW_DAL_TestDataFactory.createFinancialHoldings(finAcc, NUM_RECORDS_TO_CREATE)[0];
        finHolding.SLSC_FundAccNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
        update finHolding;

        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(SLSC_API_RestOutboundHoldingInfo.SERVICE_NAME, finHolding.Id);

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
        FinServ__FinancialHolding__c finHolding = AW_DAL_FinancialHolding.findById(queueItems[0].CMN_TriggeringObjectId__c);
        delete finHolding;

        validateResponse(queueItems, SLSC_API_RestOutboundHoldingInfo.EXC_HOLDING_ID_NOT_FOUND);
    }

    /**
     * @description test connected to Holding Financial Account has Entity Number not set scenario
     */
    @IsTest
    static void failedNoFinancialAccountEntityNumber()
    {
        List<CMN_WebserviceCallQueue__c> queueItems = setup();
        FinServ__FinancialHolding__c finHolding = AW_DAL_FinancialHolding.findById(queueItems[0].CMN_TriggeringObjectId__c);
        FinServ__FinancialAccount__c finAccount = AW_DAL_FinancialAccount.findById(finHolding.FinServ__FinancialAccount__c);
        finAccount.SLSC_EntityNumber__c = null;
        update finAccount;

        validateResponse(queueItems, SLSC_API_RestOutboundHoldingInfo.EXC_ACCOUNT_ENTITY_NUMBER_NOT_FOUND);
    }

    /**
     * @description test Financial Holding has Fund Acc Number not set scenario
     */
    @IsTest
    static void failedNoFinancialHoldingFundAccNumber()
    {
        List<CMN_WebserviceCallQueue__c> queueItems = setup();
        FinServ__FinancialHolding__c finHolding = AW_DAL_FinancialHolding.findById(queueItems[0].CMN_TriggeringObjectId__c);
        finHolding.SLSC_FundAccNumber__c = null;
        update finHolding;

        validateResponse(queueItems, SLSC_API_RestOutboundHoldingInfo.EXC_HOLDING_FUND_ACC_NUMBER_NOT_FOUND);
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