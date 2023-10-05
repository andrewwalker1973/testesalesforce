/**
 * @description Selector class containing common queries for the Group Object
 *
 * @see Group
 *
 * @author rajpal.singh@accenture.com
 *
 * @date August 2022
 */
public inherited sharing class SC_DAL_Group
{
	/**
	 * @description contains the queue api name for assignable service type
	 */
	private static final String QUEUE_ASSIGNABLE_CASES = 'SC_CasesAvailableForAssignment';
	/**
	 * @description contains the queue api name for assignable service type
	 */
	private static final String QUEUE_NON_ASSIGNABLE_CASES = 'SC_CasesNotAvailableForAssignment';

	/**
	 * @description To get the Assignable Cases queue
	 *
	 * @return Null or Item found
	 */
	public static Group getAssignableCasesQueue()
	{
		return CMN_DAL_Group.findQueueByDeveloperName(QUEUE_ASSIGNABLE_CASES);
	}

	/**
	 * @description To get the Non Assignable Cases queue
	 *
	 * @return Null or Item found
	 */
	public static Group getNonAssignableCasesQueue()
	{
		return CMN_DAL_Group.findQueueByDeveloperName(QUEUE_NON_ASSIGNABLE_CASES);
	}
}