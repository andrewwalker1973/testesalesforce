/**
 * @description - This class is a scheduler that launches the AW_BATCH_LeadReallocation batch
 *
 * @see AW_SCHED_LeadReallocation_TEST
 * @see AW_BATCH_LeadReallocation
 *
 * @author kiran.kumaryelisetti@lntinfotech.com, latika.kharbanda@accenture.com
 *
 * @date July 2021, October 2022
 */
public inherited sharing class AW_SCHED_LeadReallocation implements Schedulable
{
	private static final Integer BATCH_SIZE = CMN_DAL_BatchSetting.getBatchSize(AW_SCHED_LeadReallocation.class.getName());

	/**
	 * @description Will execute relevant batch
	 *
	 * @param context Contains the job ID.
	 */
	public void execute(SchedulableContext context)
	{
		Database.executeBatch(new AW_BATCH_LeadReallocation(), BATCH_SIZE);
	}
}