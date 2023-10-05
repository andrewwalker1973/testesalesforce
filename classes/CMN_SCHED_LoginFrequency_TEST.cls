/**
 * @description Test Class for CMN_SCHED_LoginFrequency
 *
 * @see CMN_SCHED_LoginFrequency
 *
 * @author latika.kharbanda@accenture.com
 *
 * @date November 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_SCHED_LoginFrequency_TEST
{
	@TestSetup
	private static void setup()
	{
		CMN_ScheduleSetting__c settings = new CMN_ScheduleSetting__c();
		settings.Name = CMN_SCHED_LoginFrequency.class.getName();
		settings.CMN_LastSuccessfulRunTime__c = CMN_DAL_SObjectDomain.generateRandomDateTime();
		insert settings;
	}

	/**
	 * @description Test method to test the Schedule job
	 */
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	@IsTest
	private static void runSchedule()
	{
		Test.startTest();

		CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.insertJobScheduler(CMN_SCHED_LoginFrequency.class.getName());

		scheduler = CMN_DAL_JobSchedule.findById(scheduler.Id);

		Test.stopTest();

		Assert.isNotNull(scheduler.CMN_ScheduledJobId__c, 'CMN_SCHED_LoginFrequency was not started');
	}
}