@IsTest(SeeAllData=false IsParallel=true)
public with sharing class SLSC_CTRL_InvestorsMulesoftData_TEST {

    private static final Integer NUM_RECORDS_TO_CREATE = 1;

    @TestSetup
    static void insertTestData()
    {
        Account acc = AW_DAL_TestDataFactory.createClientAccount(NUM_RECORDS_TO_CREATE)[0];
        acc.SLC_IDNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
        acc.SLSC_IDType__c = CMN_DAL_SObjectDomain.generateRandomName();
        update acc;
    }

    /**
     * @description Test method to check valid converting json response into list of financial holding fields according to custom metadata
     */
    @IsTest
    static void getHoldingDetailsTest() {
        Id finHoldingId = setupFinHolding();

        Test.startTest();
        List<Object> result = SLSC_CTRL_InvestorsMulesoftData.getHoldingDetails(finHoldingId);
        Test.stopTest();

        System.assertNotEquals(0, result.size());
    }

    /**
     * @description Test method to check valid converting json response into list of financial holdings with fields according to custom metadata
     */
    @IsTest
    static void getHoldingsTest() {
        Id finAccountId = setupFinAccount();

        Test.startTest();
        List<Object> result = SLSC_CTRL_InvestorsMulesoftData.getHoldings(finAccountId);
        Test.stopTest();

        System.assertNotEquals(0, result.size());
    }

    /**
     * @description Test method to check valid converting json response into list of online details fields according to custom metadata
     */
    @IsTest
    static void getOnlineDetailsTest() {
        Account acc = AW_DAL_Account.getAll()[0];

        Test.startTest();
        List<Object> result = SLSC_CTRL_InvestorsMulesoftData.getInvestorRegistrationOnlineDetails(acc.Id);
        Test.stopTest();

        System.assertNotEquals(0, result.size());
    }

    /**
     * @description Test method to check valid converting json response into list of sso details fields according to custom metadata
     */
    @IsTest
    static void getSsoTest() {
        Account acc = AW_DAL_Account.getAll()[0];

        Test.startTest();
        List<Object> result = SLSC_CTRL_InvestorsMulesoftData.getInvestorRegistrationSso(acc.Id);
        Test.stopTest();

        System.assertNotEquals(0, result.size());
    }

    /**
     * @description Test method to check valid converting json response into list of bank details fields according to custom metadata
     */
    @IsTest
    static void getBankDetailsTest() {
        Account acc = AW_DAL_Account.getAll()[0];

        Test.startTest();
        List<Object> result = SLSC_CTRL_InvestorsMulesoftData.getBankDetails(acc.Id);
        Test.stopTest();

        System.assertNotEquals(0, result.size());
    }

    private static Id setupFinHolding() {
        List<Account> accounts = AW_DAL_Account.getAll();
        FinServ__FinancialAccount__c finAcc = AW_DAL_TestDataFactory.createFinancialAccounts(accounts[0], NUM_RECORDS_TO_CREATE)[0];
        finAcc.SLSC_EntityNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
        update finAcc;
        FinServ__FinancialHolding__c finHolding = AW_DAL_TestDataFactory.createFinancialHoldings(finAcc, NUM_RECORDS_TO_CREATE)[0];
        finHolding.SLSC_FundAccNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
        update finHolding;
        return finHolding.Id;
    }

    private static Id setupFinAccount() {
        List<Account> accounts = AW_DAL_Account.getAll();
        FinServ__FinancialAccount__c finAcc = AW_DAL_TestDataFactory.createFinancialAccounts(accounts[0], NUM_RECORDS_TO_CREATE)[0];
        finAcc.SLSC_EntityNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
        update finAcc;
        return finAcc.Id;
    }
}