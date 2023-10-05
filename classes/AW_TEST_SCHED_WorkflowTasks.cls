/**
 * @description Retrieving internal system workflow's
 *
 * @see AW_SCHED_RestOutboundWorkflowTasks @story ST-2338
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date 2019, July 2023
 */
@IsTest(SeeAllData=false IsParallel=false)
private with sharing class AW_TEST_SCHED_WorkflowTasks
{
	/**
	 * @description This test method to test the CMN_DAL_JobSchedule class
	 */
	@IsTest
	private static void runSchedule()
	{
		Test.startTest();

		CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.insertJobScheduler(AW_SCHED_RestOutboundWorkflowTasks.class.getName());

		scheduler = CMN_DAL_JobSchedule.findById(scheduler.Id);

		Assert.isNotNull(scheduler.CMN_ScheduledJobId__c, 'AW_SCHED_RestOutboundWorkflowTasks was not started');

		Test.stopTest();
	}
}