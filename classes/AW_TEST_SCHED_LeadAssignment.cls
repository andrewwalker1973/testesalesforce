/**
 * @description Test Class for AW_SCHED_LeadAssignment
 *
 * @see AW_SCHED_LeadAssignment
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date 2019, August 2023
 *
 * @since @story ST-170,ST-158
 */
@IsTest(SeeAllData=false IsParallel=false)
private with sharing class AW_TEST_SCHED_LeadAssignment
{
	/**
	 * @description Test method to test the Schedule job
	 */
	@IsTest
	private static void runSchedule()
	{
		Test.startTest();

		CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.insertJobScheduler(AW_SCHED_LeadAssignment.class.getName());

		scheduler = CMN_DAL_JobSchedule.findById(scheduler.Id);

		System.assertNotEquals(null, scheduler.CMN_ScheduledJobId__c, 'AW_SCHED_LeadAssignment was not started');

		Test.stopTest();
	}
}