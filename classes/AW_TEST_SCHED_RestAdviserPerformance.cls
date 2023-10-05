/**
 * @description Test class for AW_SCHED_RestOutboundAdviserPerformance
 *
 * @see AW_SCHED_RestOutboundAdviserPerformance ST-3495
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date 2019, July 2023
 */
@IsTest(SeeAllData=false IsParallel=false)
private class AW_TEST_SCHED_RestAdviserPerformance
{
	@IsTest
	private static void runSchedule()
	{
		Test.startTest();

		CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.insertJobScheduler(AW_SCHED_RestOutboundAdviserPerformance.class.getName());

		scheduler = CMN_DAL_JobSchedule.findById(scheduler.Id);

		Assert.isNotNull(scheduler.CMN_ScheduledJobId__c, 'AW_SCHED_RestOutboundAdviserPerformance was not started');

		Test.stopTest();
	}
}