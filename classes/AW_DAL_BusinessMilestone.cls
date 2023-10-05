/**
 * @description Public class to return the record of Contact
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing class AW_DAL_BusinessMilestone
{
	public static final String MILESTONE_TYPE_AWARD = 'Award';
	public static final String OBJECT_NAME = BusinessMilestone.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				BusinessMilestone.Id.getDescribe().getLocalName(),
				BusinessMilestone.AW_MasterAccount__c.getDescribe().getLocalName(),
				BusinessMilestone.OwnerId.getDescribe().getLocalName()
		};
	}
	/**
	 * @description Will find an BusinessMileStone by Id
	 *
	 * @param milestoneId The Id of the BusinessMileStone
	 *
	 * @return Either the item found or null
	 */
	public static BusinessMilestone findById(Id milestoneId)
	{
		return (BusinessMilestone)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, milestoneId, getDefaultFields());
	}
}