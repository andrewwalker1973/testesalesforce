/**
 * @description Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 */
@IsTest(SeeAllData=false IsParallel=true)
private class dlrs_FinServ_AssetsAndLiabilitiesTest
{
	@IsTest
	private static void testTrigger()
	{
		// Force the dlrs_FinServ_AssetsAndLiabilitiesTrigger to be invoked, fails the test if org config or other Apex code prevents this.
		dlrs.RollupService.testHandler(new FinServ__AssetsAndLiabilities__c());
	}
}