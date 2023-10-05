/**
 * @description Scheduler class to schedule LeadAssignmentBatch
 *
 * @see AW_TEST_SCHED_LeadAssignment
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date 2019, August 2023
 */
public inherited sharing class AW_SCHED_LeadAssignment implements Schedulable
{
	private static final Integer BATCH_SIZE = CMN_DAL_BatchSetting.getBatchSize(AW_SCHED_LeadAssignment.class.getName());

	/**
	 * @description Execute method of batch job
	 *
	 * @param context Contains the job ID.
	 */
	public void execute(SchedulableContext context)
	{
		Database.executeBatch(new AW_BATCH_LeadAssignment(), BATCH_SIZE);
	}
}