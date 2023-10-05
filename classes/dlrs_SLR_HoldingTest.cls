/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_SLR_HoldingTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_SLR_HoldingTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new SLR_Holding__c());
    }
}