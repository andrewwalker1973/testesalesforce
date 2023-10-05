/**
 * @description Schedule class to ensure batched API calls are run
 *
 * @see CMN_SCHED_RunBatchedOutboundApis_TEST
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date July 2021, June 2023
 */
public inherited sharing class CMN_SCHED_RunBatchedOutboundApis implements Schedulable
{
	/**
	 * @description Execute the schedulable job override method implementation of schedulable
	 *
	 * @param context relevant context
	 */
	public void execute(SchedulableContext context)
	{
		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.findByBatchedOutbound();

		for(CMN_WebserviceCallQueue__c queueItem : queueItems)
		{
			queueItem.CMN_Status__c = CMN_DAL_WebserviceCallQueue.STATUS_QUEUED;
		}

		CMN_DAL_SObjectDomain.updateDBObjects(queueItems, false);
	}
}