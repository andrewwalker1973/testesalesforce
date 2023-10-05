/**
 * @description Batch class to query all the leads from Allocation Queue and pass them to "LeadBranchAllocationHandler" class to associate leads with nearest branch
 *
 * @see AW_BATCH_LeadBranchAllocation_TEST
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date 2019, March 2023
 */
public class AW_BATCH_LeadBranchAllocation implements Database.Batchable<SObject>
{
	/**
	 * @description Start method of batch job
	 *
	 * @param context Represents the parameter type of a batch job method and contains the batch job ID
	 *
	 * @return Recordset containing the leads to process
	 */
	public Database.QueryLocator start(Database.BatchableContext context)
	{
		return CMN_DAL_Lead.findAllByOwnerIdQuery(AW_DAL_Group.getAllocationQueue().Id);
	}

	/**
	 * @description Execute method of batch class
	 *
	 * @param context Represents the parameter type of a batch job method and contains the batch job ID
	 * @param leads The leads to process in the batch
	 */
	public void execute(Database.BatchableContext context, List<Lead> leads)
	{
		AW_DAL_LeadBranchAllocation.allocateBranch(leads);
	}

	/**
	 * @description Finish method of batch class
	 *
	 * @param context Represents the parameter type of a batch job method and contains the batch job ID
	 */
	@SuppressWarnings('PMD.EmptyStatementBlock')
	public void finish(Database.BatchableContext context)
	{
	}

}