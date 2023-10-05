/**
 * @description Batch class to allow objects to be inserted asynchronously
 *
 * @see CMN_BATCH_PerformDML_TEST
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date July 2022
 */
public inherited sharing class CMN_BATCH_PerformDML implements Database.Batchable<SObject>
{
	private Boolean allOrNothing;
	private CMN_DAL_SObjectDomain.DatabaseOperation operation;
	private List<SObject> objects = new List<SObject>();

	/**
	 * @description Constructor that will get the SObjects to insert
	 *
	 * @param objectToProcess An SObject to be processed
	 * @param operation The DML operation to perform
	 */
	public CMN_BATCH_PerformDML(SObject objectToProcess, CMN_DAL_SObjectDomain.DatabaseOperation operation)
	{
		this(objectToProcess, operation, true);
	}

	/**
	 * @description Constructor that will get the SObjects to insert
	 *
	 * @param objectToProcess An SObject to be processed
	 * @param operation The DML operation to perform
	 * @param allOrNothing Whether partial update can happen; if true a single failure will abort transaction
	 */
	public CMN_BATCH_PerformDML(SObject objectToProcess, CMN_DAL_SObjectDomain.DatabaseOperation operation, Boolean allOrNothing)
	{
		this(new List<SObject> {objectToProcess}, operation, allOrNothing);
	}

	/**
	 * @description Constructor that will get the SObjects to insert
	 *
	 * @param listOfObjects A list of SObjects to be processed
	 * @param operation The DML operation to perform
	 */
	public CMN_BATCH_PerformDML(List<SObject> listOfObjects, CMN_DAL_SObjectDomain.DatabaseOperation operation)
	{
		this(listOfObjects, operation, true);
	}

	/**
	 * @description Constructor that will get the SObjects to insert
	 *
	 * @param objects A list of SObjects to be processed
	 * @param operation The DML operation to perform
	 * @param allOrNothing Whether partial update can happen; if true a single failure will abort transaction
	 */
	public CMN_BATCH_PerformDML(List<SObject> objects, CMN_DAL_SObjectDomain.DatabaseOperation operation, Boolean allOrNothing)
	{
		this.objects = objects;
		this.operation = operation;
		this.allOrNothing = allOrNothing;
	}

	/**
	 * @description Gets invoked when the batch job starts. Returns the record set as an iterable that will be batched for execution
	 *
	 * @param context Job context
	 *
	 * @return A list of objects to process
	 */
	public List<SObject> start(Database.BatchableContext context)
	{
		return objects;
	}

	/**
	 * @description Will insert the apex shares provided
	 *
	 * @param context Job Context
	 * @param sobjects The items on which to perform the DML operation
	 */
	public void execute(Database.BatchableContext context, List<SObject> sobjects)
	{
		CMN_DAL_SObjectDomain.updateDatabase(sobjects, operation, allOrNothing, true, true, false);
	}

	/**
	 * @description Any cleanup activities required
	 *
	 * @param context Job Context
	 */
	public void finish(Database.BatchableContext context)
	{
	}
}