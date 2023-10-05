/**
 * @description Will retrieve quotes performed for clients at regular intervals
 *
 * @see AW_SCHED_RestOutboundQuoteInfo @story ST-3089
 *
 * @author prashant.k.jain@accenture.com, jason.van.beukering@accenture.com
 *
 * @date 2019, July 2023
 */
@IsTest(SeeAllData=false IsParallel=false)
private class AW_TEST_SCHED_QuoteInfo
{
	//By creating 6 account scheduler will create 5 batches, one with 2 records
	private static final Integer NUMBER_OF_ACCOUNT_ROWS = 6;
	private static final Integer NUMBER_OF_OPPORTUNITY_ROWS = 1;

	@TestSetup
	private static void setup()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		System.runAs(adviser)
		{
			for(Account newAccount : AW_DAL_TestDataFactory.createClientAccount(NUMBER_OF_ACCOUNT_ROWS))
			{
				AW_DAL_TestDataFactory.createDefaultOpportunities(newAccount, NUMBER_OF_OPPORTUNITY_ROWS);
			}
		}
	}

	/**
	 * @description Method to test the schedule job class
	 */
	@IsTest
	private static void runSchedule()
	{
		Test.startTest();

		CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.insertJobScheduler(AW_SCHED_RestOutboundQuoteInfo.class.getName());

		scheduler = CMN_DAL_JobSchedule.findById(scheduler.Id);

		Assert.isNotNull(scheduler.CMN_ScheduledJobId__c, 'AW_SCHED_RestOutboundQuoteInfo was not started');

		Test.stopTest();
	}
}