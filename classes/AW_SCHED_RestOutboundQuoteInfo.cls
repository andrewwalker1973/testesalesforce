/**
 * @description :  Will retrieve quotes performed for clients at regular intervals
 *
 * @see AW_TEST_SCHED_QuoteInfo @story ST-3089
 *
 * @author latika.kharbanda@accenture.com, jason.van.beukering@accenture.com
 *
 * @date 2019, July 2023
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public inherited sharing class AW_SCHED_RestOutboundQuoteInfo implements Schedulable
{
	private static final Integer BATCH_SIZE = CMN_DAL_BatchSetting.getBatchSize(AW_SCHED_RestOutboundQuoteInfo.class.getName());

	/**
	 * @description Will execute the relevant batch
	 *
	 * @param context Contains the job ID.
	 */
	@ReadOnly
	public void execute(SchedulableContext context)
	{
		//Determine if we have any  clients with identification numbers and valid owner that have open opportunities
		//We will then check if any quotes have  been performed for this clients recently
		//TODO: Build query using CMN Library classes
		List<AggregateResult> opportunitiesPerAccount =
		[
				SELECT
						AccountId,
						COUNT(Id)
				FROM Opportunity
				WHERE StageName IN :AW_DAL_Opportunity.OPEN_OPPORTUNITY_STAGES
				AND Owner.AW_UACFID__c != NULL
				AND Owner.AW_ConsultantCode__c != NULL
				AND Owner.IsActive = TRUE
				AND Account.AW_IdentificationNumber__pc != NULL
				GROUP BY AccountId
				LIMIT :CMN_DAL_Search.LIMIT_NUMBER_OF_RECORDS
		];

		Integer rowCount = opportunitiesPerAccount.size();

		//We want to split the  results  of the query into a bunch of individual  jobs to allow processing in parallel
		//If we have less rows then  number of jobs, then  use the row count
		Integer modCounter = rowCount < CMN_DAL_SObjectDomain.NUMBER_OF_PARALLEL_JOBS ? rowCount : rowCount / CMN_DAL_SObjectDomain.NUMBER_OF_PARALLEL_JOBS;
		Integer counter = 1;
		Integer jobCount = 0;

		List<CMN_WebserviceCallQueue__c> queueItems = new List<CMN_WebserviceCallQueue__c>();

		for(AggregateResult opportunityPerAccount : opportunitiesPerAccount)
		{
			Id accountId = (Id)opportunityPerAccount.get(Opportunity.AccountId.getDescribe().getName());
			queueItems.add(CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RestOutboundQuoteInfo.SERVICE_NAME, accountId));

			//If we hit the job boundary, then kick of a job using the batch size soft coded
			//Make sure we do not create more than the  number  of parallel jobs  allowed (as these will wait for the first jobs to finish)
			if(Math.mod(counter, modCounter) == 0 && jobCount < CMN_DAL_SObjectDomain.NUMBER_OF_PARALLEL_JOBS - 1)
			{
				jobCount = jobCount + 1;

				//Use a batch job here if we can't fit all the queue items into remaining Queueable jobs (assuming flex queue isn't full)
				Database.executeBatch(new CMN_BATCH_WebserviceQueueItem(queueItems), BATCH_SIZE);

				queueItems.clear();
			}

			counter = counter + 1;
		}

		//If any queue  items remain, ensure we execute a job for them
		if(!queueItems.isEmpty())
		{
			jobCount = jobCount + 1;
			Database.executeBatch(new CMN_BATCH_WebserviceQueueItem(queueItems), BATCH_SIZE);
		}

		if(Test.isRunningTest())
		{
			System.assertEquals(CMN_DAL_SObjectDomain.NUMBER_OF_PARALLEL_JOBS, jobCount, 'Invalid number of batch jobs created.');
		}
	}
}