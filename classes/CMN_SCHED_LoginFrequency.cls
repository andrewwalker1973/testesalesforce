/**
 * @description This Scheduler class runs every day and stores login information on Login Frequency records
 *
 * @see CMN_SCHED_LoginFrequency_TEST @story ST-327625
 * @see CMN_BATCH_ProcessLoginHistory
 *
 * @author latika.kharbanda@accenture.com
 *
 * @date October 2022
 */
public inherited sharing class CMN_SCHED_LoginFrequency implements Schedulable
{
	private static final Integer BATCH_SIZE = CMN_DAL_BatchSetting.getBatchSize(CMN_SCHED_LoginFrequency.class.getName());

	/**
	 * @description Executes the scheduled Apex job.
	 * @param context Contains the job id
	 */
	public void execute(SchedulableContext context)
	{
		Database.executeBatch(new CMN_BATCH_ProcessLoginHistory(), BATCH_SIZE);
	}
}