/**
 * @description Trigger handler for the trigger AW_TRG_PersonLifeEvents
 *
 * @see AW_TRG_PersonLifeEvents
 *
 * @author Accenture
 *
 * @date June 2021
 */
public inherited sharing class AW_TH_PersonLifeEvents extends AW_TH_BaseLinkToMaster
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
	 * @param so To store the PersonLifeEvents
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);
		setEventOwner((PersonLifeEvent)so);
	}

	/**
	 * @description Will update the owner of the object to Parent Account Owner
	 *
	 * @param newEvent A PersonLifeEvent that's needs to be assigned to Parent Account Owner
	 */
	private void setEventOwner(PersonLifeEvent newEvent)
	{
		if(AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT.equalsIgnoreCase(currentUser.Profile.Name))
		{
			newEvent.OwnerId = newEvent.AW_ParentAccountOwnerId__c;
		}
	}
}