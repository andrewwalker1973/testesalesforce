/**
 * @description Scheduler class to schedule RSC_BATCH_DeleteContentDocument
 *
 * @see RSC_SCHED_DeleteContentDocument_TEST @story 146054
 * @see RSC_BATCH_DeleteContentDocument
 *
 * @author rajpal.singh@accenture.com, latika.kharbanda@accenture.com
 *
 * @date 2021, October 2022
 */
public inherited sharing class RSC_SCHED_DeleteContentDocument implements Schedulable
{
	private static final Integer BATCH_SIZE = CMN_DAL_BatchSetting.getBatchSize(RSC_SCHED_DeleteContentDocument.class.getName());

	/**
	 * @description Execute method of batch job
	 *
	 * @param context Default parameter in execute method
	 */
	public void execute(SchedulableContext context)
	{
		Database.executeBatch(new RSC_BATCH_DeleteContentDocument(), BATCH_SIZE);
	}
}