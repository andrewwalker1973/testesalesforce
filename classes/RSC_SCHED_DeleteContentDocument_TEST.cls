/**
 * @description Test Class for RSC_SCHED_DeleteContentDocument
 *
 * @see RSC_SCHED_DeleteContentDocument @story 146054
 *
 * @author rajpal.singh@accenture.com
 *
 * @date September 2021
 */
@IsTest(SeeAllData=false IsParallel=false)
private class RSC_SCHED_DeleteContentDocument_TEST
{
	/**
	 * @description Test method to test the Schedule job
	 */
	@IsTest
	private static void runSchedule()
	{
		Test.startTest();

		CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.insertJobScheduler(RSC_SCHED_DeleteContentDocument.class.getName());

		scheduler = CMN_DAL_JobSchedule.findById(scheduler.Id);

		Test.stopTest();

		System.assertNotEquals(null, scheduler.CMN_ScheduledJobId__c, 'RSC_SCHED_DeleteContentDocument was not started');
	}
}