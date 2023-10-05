/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_SLC_ClientExpenseTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_SLC_ClientExpenseTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new SLC_ClientExpense__c());
    }
}