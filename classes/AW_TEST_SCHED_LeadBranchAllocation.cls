/**
 * @description Test class for AW_SCHED_LeadBranchAllocation.
 *
 * @see AW_SCHED_LeadBranchAllocation @story ST-170,ST-158
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=false)
private with sharing class AW_TEST_SCHED_LeadBranchAllocation
{

	/**
	 * @description Test method to run the Branch allocation batch job
	 */
	@IsTest
	private static void runSchedule()
	{
		Test.startTest();

		CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.insertJobScheduler(AW_SCHED_LeadBranchAllocation.class.getName());

		scheduler = CMN_DAL_JobSchedule.findById(scheduler.Id);

		System.assertNotEquals(null, scheduler.CMN_ScheduledJobId__c, 'AW_SCHED_LeadBranchAllocation was not started');

		Test.stopTest();
	}

}