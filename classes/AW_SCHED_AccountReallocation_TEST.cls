/**
 * @description Test Class for AW_SCHED_AccountReallocation
 *
 * @see AW_SCHED_AccountReallocation @story ST-82904
 *
 * @author kiran.kumaryelisetti@lntinfotech.com
 *
 * @date July 2021
 */
@IsTest(SeeAllData=false IsParallel=false)
private class AW_SCHED_AccountReallocation_TEST
{
	/**
	 * @description Test method to test the Schedule job
	 */
	@IsTest
	private static void runSchedule()
	{
		Test.startTest();

		CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.insertJobScheduler(AW_SCHED_AccountReallocation.class.getName());

		scheduler = CMN_DAL_JobSchedule.findById(scheduler.Id);

		Test.stopTest();

		System.assertNotEquals(null, scheduler.CMN_ScheduledJobId__c, 'AW_SCHED_AccountReallocation was not started');

	}
}