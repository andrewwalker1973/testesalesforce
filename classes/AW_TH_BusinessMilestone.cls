/**
 * @description Trigger handler for the trigger AW_TRG_BusinessMilestone
 *
 * @see AW_TRG_BusinessMilestone
 *
 * @author Accenture
 *
 * @date June 2021
 */
public inherited sharing class AW_TH_BusinessMilestone extends AW_TH_BaseLinkToMaster
{
	private User currentUser = new User();

	/**
	 * @description Before trigger will get the current user information
	 */

	public override void bulkBefore()
	{
		super.bulkBefore();
		currentUser = AW_DAL_User.getCurrentUser();
	}

	/**
	 * @description Context method overrides will be called before insertion of Object.
	 *
	 * @param so To store the BusinessMilestone
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);
		setBusinessMilestoneOwner((BusinessMilestone)so);
	}

	/**
	 * @description Will update the owner of the object to Parent Account Owner
	 *
	 * @param newBusinessMilestone A BusinessMilestone that's needs to be assigned to Parent Account Owner
	 */
	private void setBusinessMilestoneOwner(BusinessMilestone newBusinessMilestone)
	{
		if(AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT.equalsIgnoreCase(currentUser.Profile.Name))
		{
			newBusinessMilestone.OwnerId = newBusinessMilestone.AW_ParentAccountOwnerId__c;
		}
	}
}