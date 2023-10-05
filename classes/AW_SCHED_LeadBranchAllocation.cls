/**
 * @description Scheduler class to schedule LeadBranchAllocationBatch
 *
 * @see AW_TEST_SCHED_LeadBranchAllocation
 *
 * @author Accenture, latika.kharbanda@accenture.com
 *
 * @date 2019, October 2022
 */
public inherited sharing class AW_SCHED_LeadBranchAllocation implements Schedulable
{
	private static final Integer BATCH_SIZE = CMN_DAL_BatchSetting.getBatchSize(AW_SCHED_LeadBranchAllocation.class.getName());

	/**
	 * @description This method is use to run the batch job context
	 *
	 * @param context Contains the job ID.
	 */
	public void execute(SchedulableContext context)
	{
		Database.executeBatch(new AW_BATCH_LeadBranchAllocation(), BATCH_SIZE);
	}
}