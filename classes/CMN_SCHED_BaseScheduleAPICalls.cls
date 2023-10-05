/**
 * @description Base class to be used when creating a scheduled class for executing API calls
 *
 * @author latika.kharbanda@accenture.com, jason.van.beukering@accenture.com
 *
 * @date 2019, July 2023
 */
public inherited sharing virtual class CMN_SCHED_BaseScheduleAPICalls implements Schedulable
{
	private static final String SQL_LIMIT = ' LIMIT ';

	/**
	 * @description Interface method execute when scheduled time in cron for Scheduled job is reached
	 *
	 * @param context Contains the job id
	 */
	@SuppressWarnings('PMD.ApexSOQLInjection')
	@ReadOnly
	public void execute(SchedulableContext context)
	{
		final Integer numberOfParallelJobs = CMN_DAL_SObjectDomain.NUMBER_OF_PARALLEL_JOBS;
		final Integer batchSize = CMN_DAL_BatchSetting.getBatchSize(getScheduleName());
		Integer numberOfRowsToProcess = getNumberOfRowsToProcess();

		Integer maxNumberOfTestRows = numberOfParallelJobs * batchSize;

		//If we are running a unit  test  we may not schedule jobs which have more than one batch
		//Since we are querying a setup object this may result in 5 jobs with multiple batches
		//So we want to make sure in a test we create 5 jobs and that each job is less than or equal the batch size
		numberOfRowsToProcess = Test.isRunningTest() ? Math.min(numberOfRowsToProcess, maxNumberOfTestRows) : numberOfRowsToProcess;

		//We want to split the  results  of the query into a bunch of individual  jobs to allow processing in parallel
		//If we have less rows then  number of jobs, then  use the row count
		Double modCounterDouble = numberOfRowsToProcess < numberOfParallelJobs ? numberOfRowsToProcess : Decimal.valueOf(numberOfRowsToProcess) / numberOfParallelJobs;

		Integer modCounter = Integer.valueOf(Math.ceil(modCounterDouble));

		Integer counter = 1;
		Integer jobCount = 0;

		List<CMN_WebserviceCallQueue__c> queueItems = new List<CMN_WebserviceCallQueue__c>();

		//Ensure we limit number of rows so that in unit tests an exception isn't thrown for max number of batches in a job
		String soqlQuery = getObjectQuery() + SQL_LIMIT + String.valueOf(numberOfRowsToProcess);

		//Use a SOQL For Loop to avoid hitting limits on heap size for large number of records
		for(SObject obj : Database.query(soqlQuery))
		{
			queueItems.add(createQueueItem(obj));

			//If we hit the job boundary, then kick of a job using the batch size soft coded
			//Make sure we do not create more than the  number  of parallel jobs  allowed (as these will wait for the first jobs to finish)
			if(Math.mod(counter, modCounter) == 0 && jobCount < numberOfParallelJobs - 1)
			{
				jobCount = jobCount + 1;
				Database.executeBatch(new CMN_BATCH_WebserviceQueueItem(queueItems), batchSize);

				queueItems.clear();
			}

			counter = counter + 1;
		}

		//If any queue  items remain, ensure we execute a job for them
		if(!queueItems.isEmpty())
		{
			jobCount = jobCount + 1;
			Database.executeBatch(new CMN_BATCH_WebserviceQueueItem(queueItems), batchSize);
		}

		if(Test.isRunningTest())
		{
			System.assertEquals(numberOfParallelJobs, jobCount, 'Invalid number of batch jobs created.');
		}
	}

	/**
	 * @description Creates a queueItem based on information provided and pertinent to service being called
	 *
	 * @param obj The object for which to create a queue item
	 *
	 * @return The created item
	 */
	protected virtual CMN_WebserviceCallQueue__c createQueueItem(SObject obj)
	{
		return CMN_DAL_DataFactory.newOutboundWebserviceQueue(getWebServiceName(), (Id)obj.get(CMN_DAL_SObjectDomain.FIELD_ID));
	}

	/**
	 * @description Returns the name of the scheduled class and is used to retrieve custom metadata settings
	 *
	 * @return Schedule name
	 */
	protected virtual String getScheduleName()
	{
		return CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description Returns the name of the web service class that will be executed by this schedule
	 *
	 * @return Web service name
	 */
	protected virtual String getWebServiceName()
	{
		return CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description The total number of rows that need to be split across jobs
	 *
	 * @return Number of rows to be processed
	 */
	protected virtual Integer getNumberOfRowsToProcess()
	{
		return 0;
	}

	/**
	 * @description The query to be run for getting the object information used to construct webservice queue objects
	 *
	 * @return The query string
	 */
	protected virtual String getObjectQuery()
	{
		return CMN_UTIL_String.EMPTY;
	}
}