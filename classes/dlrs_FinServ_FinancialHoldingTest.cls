/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_FinServ_FinancialHoldingTest
{
    @IsTest
    private static void testTrigger()
    {
        //Create Account
        Account priOwner = new Account();
        priOwner.Name = 'test account';
        insert priOwner;
        
        //Create Financial Account
        FinServ__FinancialAccount__c finAcct = new FinServ__FinancialAccount__c();
        finAcct.Name = 'test finAccount';
        finAcct.FinServ__PrimaryOwner__c = priOwner.id;
        insert finAcct;
            
        // Force the dlrs_FinServ_FinancialHoldingTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new FinServ__FinancialHolding__c(
        FinServ__FinancialAccount__c = finAcct.id
        ));
    }
}