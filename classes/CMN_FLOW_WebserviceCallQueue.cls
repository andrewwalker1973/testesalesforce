/**
 * @description This class is use to invoke the webservice call
 *
 * @see CMN_SCHED_RunBatchedOutboundApis_TEST
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date 2019, August 2023
 */
public inherited sharing class CMN_FLOW_WebserviceCallQueue
{
	@TestVisible
	private static Boolean simulateQueueableLimits = false;
	@TestVisible
	private static Integer batchSize = CMN_DAL_BatchSetting.getBatchSize(CMN_BATCH_WebserviceQueueItem.class.getName());
	@TestVisible
	private static final String CLASS_METHOD = 'CMN_FLOW_WebserviceCallQueue/invokeWebserviceCallAsynchronously';

	/**
	 * @description To call webservices asynchronously from a flow
	 *
	 * @param queueItems items to use to make API callouts
	 */
	@InvocableMethod(Callout=true Label='Invoke Callout Async' Description='This method can be called to an invoke a webservice call asynchronously')
	public static void invokeWebserviceCallAsynchronously(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		Decimal numberOfJobs = Decimal.valueOf(queueItems.size()) / batchSize;
		Integer remainingJobs = Limits.getLimitQueueableJobs() - Limits.getQueueableJobs();

		try
		{
			if(!simulateQueueableLimits && numberOfJobs <= remainingJobs)
			{
				//Check that with the remain jobs available, we can enqueue required jobs, if not move to batch job
				List<List<SObject>> splitItemsList = CMN_UTIL_System.splitSObjects(queueItems, batchSize);

				for(List<SObject> splitItems : splitItemsList)
				{
					System.enqueueJob(new AsynchronousApiCaller(splitItems)); //NOPMD
				}
			}
			else
			{
				if(Test.isRunningTest() && queueItems.size() > batchSize)
				{
					throw new IllegalArgumentException('Testing that error handling works');
				}

				//Use a batch job here if we can't fit all the queue items into remaining Queueable jobs (assuming flex queue isn't full)
				Database.executeBatch(new CMN_BATCH_WebserviceQueueItem(queueItems), batchSize);
			}
		}
		catch(Exception error)
		{
			CMN_UTIL_Logger.error(error, CLASS_METHOD);
		}
	}

	/**
	 * @description Used to execute API Callouts
	 */
	public class AsynchronousApiCaller implements Queueable, Database.AllowsCallouts, Database.RaisesPlatformEvents
	{
		private final List<CMN_WebserviceCallQueue__c> queueItems;

		/**
		 * @description Constructor that will queue Items whose Api Handlers should be called
		 *
		 * @param queueItems A list of queue items with callout details
		 */
		public AsynchronousApiCaller(List<CMN_WebserviceCallQueue__c> queueItems)
		{
			this.queueItems = new List<CMN_WebserviceCallQueue__c>();

			for(CMN_WebserviceCallQueue__c queueItem : queueItems)
			{
				this.queueItems.add(queueItem.clone(true, true, false, false));
			}
		}

		/**
		 * @description Executes the Queueable job
		 *
		 * @param context the Context for Queueable job, contains the jobId
		 *
		 * @see Queueable
		 */
		public void execute(QueueableContext context)
		{
			CMN_FACTORY_WebserviceManager.execute(queueItems);
		}
	}
}