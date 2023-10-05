/**
 * @description Public class to return the data of Groups
 *
 * @author kushal.a.garg@accenture.com
 *
 * @date June 2022
 */
public inherited sharing class AW_DAL_Group
{
	private static final String QUEUE_ALLOCATION_QUEUE = 'AW_Allocation';
	private static final String QUEUE_DISTRIBUTION_QUEUE = 'AW_Distribution';
	private static final String QUEUE_UNALLOCATED = 'AW_Unallocated';

	/**
	 * @description stores the Object API name of Group
	 */
	public static final String OBJECT_NAME = Group.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method use to get the set of fields of SObject
	 *
	 * @return A list of commonly queried User fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				Group.Name.getDescribe().getLocalName()
		};
	}

	/**
	 * @description To get the Distribution queue
	 *
	 * @return Null or Item Found
	 */
	public static Group getDistributionQueue()
	{
		return CMN_DAL_Group.findQueueByDeveloperName(QUEUE_DISTRIBUTION_QUEUE);
	}

	/**
	 * @description To get the Unallocated queue
	 *
	 * @return Null or Item Found
	 */
	public static Group getUnallocatedQueue()
	{
		return CMN_DAL_Group.findQueueByDeveloperName(QUEUE_UNALLOCATED);
	}

	/**
	 * @description To get the Allocation queue
	 *
	 * @return Null or Item found
	 */
	public static Group getAllocationQueue()
	{
		return CMN_DAL_Group.findQueueByDeveloperName(QUEUE_ALLOCATION_QUEUE);
	}

	/**
	 * @description To get the Allocation queue group
	 *
	 * @param recordId The id to find the group by
	 *
	 * @return Null or the item found
	 */
	public static Group findById(Id recordId)
	{
		return (Group)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, recordId, getDefaultFields());
	}

}