/**
 * @description Trigger handler for the trigger AW_TRG_Envelope.
 *
 * @see AW_TH_Envelope_TEST
 *
 * @author Accenture
 *
 * @date 2021
 */
public inherited sharing class AW_TH_Envelope extends AW_TH_BaseLinkToMaster
{
	private User currentUser;
	private static final String ERROR_PREVENT_DELETE = 'Envelopes which have already been submitted to SigningHub may not be deleted';

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
	 * @param so To store the Opportunity
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);
		setEnvelopeOwner((AW_Envelope__c)so);
	}

	/**
	 * @description React to object being deleted and check if it should be prevented
	 *
	 * @param so object being deleted
	 */
	public override void beforeDelete(SObject so)
	{
		super.beforeDelete(so);

		AW_Envelope__c envelope = (AW_Envelope__c)so;

		if(!AW_DAL_Envelope.STATUS_NEW.equalsIgnoreCase(envelope.AW_Status__c))
		{
			envelope.addError(ERROR_PREVENT_DELETE);
		}
	}

	/**
	 * @description Will update the owner of the object to MasterAccount Owner
	 *
	 * @param newEnvelope A Envelope that's needs to be assigned to MasterAccount Owner
	 */
	private void setEnvelopeOwner(AW_Envelope__c newEnvelope)
	{
		if(AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT.equalsIgnoreCase(currentUser.Profile.Name))
		{
			newEnvelope.OwnerId = newEnvelope.AW_ParentOwnerId__c;
		}
	}
}