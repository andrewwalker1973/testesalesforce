/**
 * @description This is batch class that calls API Factory to run web service calls asynchronously
 *
 * @author jasonv.van.beukering@accenture.com
 *
 * @date October 2022
 */
public inherited sharing class CMN_BATCH_WebserviceQueueItem implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts
{
	private final List<CMN_WebserviceCallQueue__c> queueItems;

	/**
	 * @description Constructor to get the List of webservice queue
	 *
	 * @param inputItems Items to process
	 */
	public CMN_BATCH_WebserviceQueueItem(List<CMN_WebserviceCallQueue__c> inputItems)
	{
		queueItems = new List<CMN_WebserviceCallQueue__c>();

		for(CMN_WebserviceCallQueue__c inputItem : inputItems)
		{
			queueItems.add(inputItem.clone(true, true, false, false));
		}
	}

	/**
	 * @description Start method of batch class
	 *
	 * @param context as input
	 *
	 * @return iterable result
	 */
	public Iterable<SObject> start(Database.BatchableContext context)
	{
		return queueItems;
	}

	/**
	 * @description Will perform outbound API callouts for items provided
	 *
	 * @param context as input
	 * @param itemsToProcess Items to process
	 */
	public void execute(Database.BatchableContext context, List<CMN_WebserviceCallQueue__c> itemsToProcess)
	{
		CMN_FACTORY_WebserviceManager.execute(itemsToProcess);
	}

	/**
	 * @description Finish method of batch class
	 *
	 * @param context as input
	 */
	public void finish(Database.BatchableContext context)
	{

	}
}