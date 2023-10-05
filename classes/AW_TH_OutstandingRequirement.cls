/**
 * @description Trigger handler for the trigger AW_TRG_OutstandingRequirement
 *
 * @see AW_TRG_OutstandingRequirement
 * @see AW_TEST_TH_OutStandingRequirement
 *
 * @author Accenture
 *
 * @date June 2021
 */
public inherited sharing class AW_TH_OutstandingRequirement extends AW_TH_BaseLinkToMaster
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
	 * @param so To store the OutStandingRequirement
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);
		setOutStandingRequirementOwner((AW_Outstanding_Requirement__c)so);
	}

	/**
	 * @description Will update the owner of the object to Parent Account Owner
	 *
	 * @param newRequirement A OutStandingRequirement that's needs to be assigned to Parent Account Owner
	 */
	private void setOutStandingRequirementOwner(AW_Outstanding_Requirement__c newRequirement)
	{
		if(AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT.equalsIgnoreCase(currentUser.Profile.Name))
		{
			newRequirement.OwnerId = newRequirement.AW_ParentAccountOwnerId__c;
		}
	}
}