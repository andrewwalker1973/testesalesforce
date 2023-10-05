/**
 * @description Test class to check behavior of CMN_SCHED_RunBatchedOutboundApis
 *
 * @see CMN_SCHED_RunBatchedOutboundApis
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date July 2021, July 2022
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_SCHED_RunBatchedOutboundApis_TEST
{

	/**
	 * @description Will check that any batched APIs are run via Queueable apex
	 *
	 * @see CMN_FLOW_WebserviceCallQueue.AsynchronousApiCaller.execute
	 * @see CMN_FLOW_WebserviceCallQueue.invokeWebserviceCallAsynchronously
	 * @see CMN_SCHED_RunBatchedOutboundApis.execute
	 */
	@IsTest
	private static void runQueueable()
	{
		final Integer numberOfJobs = 2;
		CMN_FLOW_WebserviceCallQueue.batchSize = 1;

		//The number of jobs we expect to be enqueued
		insertBatchedQueueItems(numberOfJobs);

		CMN_SCHED_RunBatchedOutboundApis scheduler = new CMN_SCHED_RunBatchedOutboundApis();

		Test.startTest();

		scheduler.execute(null);

		Assert.areEqual(numberOfJobs, Limits.getQueueableJobs(), 'Incorrect Number of Jobs');

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(CMN_API_RestOutboundExample.class.getName());
	}

	/**
	 * @description Will create queue Items
	 *
	 * @param multipleOfBatchSize How many times bigger than batch size, used to test splitting across jobs
	 */
	private static void insertBatchedQueueItems(Integer multipleOfBatchSize)
	{
		List<CMN_WebserviceCallQueue__c> queueItems = new List<CMN_WebserviceCallQueue__c>();

		for(Integer i = 0; i < CMN_FLOW_WebserviceCallQueue.batchSize * multipleOfBatchSize; i++)
		{
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_RestOutboundExample.class.getName(), UserInfo.getUserId());
			queueItem.CMN_Status__c = CMN_DAL_WebserviceCallQueue.STATUS_BATCHED;
			queueItems.add(queueItem);
		}

		insert queueItems;
	}

	/**
	 * @description Will check that any batched APIs are run via Batch job
	 *
	 * @see CMN_BATCH_WebserviceQueueItem.execute
	 * @see CMN_FLOW_WebserviceCallQueue.invokeWebserviceCallAsynchronously
	 * @see CMN_SCHED_RunBatchedOutboundApis.execute
	 */
	@IsTest
	private static void runBatch()
	{
		CMN_FLOW_WebserviceCallQueue.simulateQueueableLimits = true;

		final Integer numberOfJobs = 1;
		CMN_FLOW_WebserviceCallQueue.batchSize = 1;

		insertBatchedQueueItems(numberOfJobs);

		CMN_SCHED_RunBatchedOutboundApis scheduler = new CMN_SCHED_RunBatchedOutboundApis();

		Test.startTest();

		scheduler.execute(null);

		Assert.areEqual(0, Limits.getQueueableJobs(), 'No Queueable jobs should be launched');

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(CMN_API_RestOutboundExample.class.getName());
	}

	/**
	 * @description Will check error is logged if we failed to launch a job to execute API callouts
	 *
	 * @see CMN_FLOW_WebserviceCallQueue.invokeWebserviceCallAsynchronously
	 */
	@IsTest
	private static void failed()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		//Should induce a failure due to exceeding number of items to enqueue
		final Integer numberOfJobs = Limits.getLimitQueueableJobs() + 1;
		CMN_FLOW_WebserviceCallQueue.batchSize = 1;

		insertBatchedQueueItems(numberOfJobs);

		CMN_SCHED_RunBatchedOutboundApis scheduler = new CMN_SCHED_RunBatchedOutboundApis();

		Test.startTest();

		scheduler.execute(null);

		Test.stopTest();

		Assert.isNotNull(CMN_DAL_AppLog.findByMethod(CMN_FLOW_WebserviceCallQueue.CLASS_METHOD), 'Exception was not logged as expected');
	}
}