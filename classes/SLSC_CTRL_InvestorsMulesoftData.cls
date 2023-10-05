public with sharing class SLSC_CTRL_InvestorsMulesoftData {

    /**
     * @description Used to retrieve a list of FinServ__FinancialHoldings__c by FinServ__FinancialAccount__c Id
     *
     * @param finAccountId Financial Account Id
     *
     * @return Returns a list of FinServ__FinancialHoldings__c records
     */
    @AuraEnabled
    public static List<Object> getHoldings(String finAccountId) {
        String responseBody = SLSC_API_RestOutboundMule.getResponseBody(SLSC_API_RestOutboundHoldingsInfo.SERVICE_NAME, finAccountId);

        return SLSC_UTIL_InvestorsMulesoftData.parseHoldingsJson(responseBody);
    }

    /**
     * @description Used to retrieve a list of FinServ__FinancialHoldings__c fields by Id
     *
     * @param holdingId Financial Holding Id
     *
     * @return Returns a list of FinServ__FinancialHoldings__c fields
     */
    @AuraEnabled
    public static List<Object> getHoldingDetails(String holdingId) {
        String responseBody = SLSC_API_RestOutboundMule.getResponseBody(SLSC_API_RestOutboundHoldingInfo.SERVICE_NAME, holdingId);

        return SLSC_UTIL_InvestorsMulesoftData.parseHoldingJson(responseBody);
    }

    /**
     * @description Used to retrieve a list of bank details fields by Id
     *
     * @param accountId Account Id
     *
     * @return Returns a list of bank details fields
     */
    @AuraEnabled
    public static List<Object> getBankDetails(String accountId) {
        String responseBody = SLSC_API_RestOutboundMule.getResponseBody(SLSC_API_RestOutboundBankDetails.SERVICE_NAME, accountId);

        return SLSC_UTIL_InvestorsMulesoftData.parseBankDetailsJson(responseBody);
    }

    /**
     * @description Used to retrieve a list of online details fields by Id
     *
     * @param accountId Account Id
     *
     * @return Returns a list of online details fields
     */
    @AuraEnabled
    public static List<Object> getInvestorRegistrationOnlineDetails(String accountId) {
        String responseBody = SLSC_API_RestOutboundMule.getResponseBody(SLSC_API_RestOutboundOnlineDetails.SERVICE_NAME, accountId);

        return SLSC_UTIL_InvestorsMulesoftData.parseOnlineDetailsJson(responseBody);
    }

    /**
     * @description Used to retrieve a list of sso details fields by Id
     *
     * @param accountId Account Id
     *
     * @return Returns a list of sso details fields
     */
    @AuraEnabled
    public static List<Object> getInvestorRegistrationSso(String accountId) {
        String responseBody = SLSC_API_RestOutboundMule.getResponseBody(SLSC_API_RestOutboundOnlineDetails.SERVICE_NAME, accountId);

        return SLSC_UTIL_InvestorsMulesoftData.parseSsoJson(responseBody);
    }

}