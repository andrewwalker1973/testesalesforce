/**
 * @description Trigger handler for the trigger AW_TRG_Case
 *
 * @see AW_TRG_Case
 * @see AW_TEST_TH_Case
 *
 * @author Accenture
 *
 * @date June 2021
 */
public inherited sharing class AW_TH_Case extends AW_TH_BaseLinkToMaster
{
	private Map<Id, Contact> contactMap = new Map<Id, Contact>();

	/**
	 * @description Before trigger will get the current user information
	 */

	public override void bulkBefore()
	{
		super.bulkBefore();

		if(Trigger.isInsert)
		{

			Set<Id> contactIds = CMN_UTIL_System.extractListIds(Trigger.new, AW_DAL_Case.FIELD_CONTACT_ID);
			if(!contactIds.isEmpty())
			{
				contactMap = new Map<Id, Contact>(AW_DAL_Contact.findById(contactIds));

			}
		}
	}

	/**
	 * @description Context method overrides will be called before insertion of Object.
	 *
	 * @param so To store the Case
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);

		setMasterAccount((Case)so);

		setCaseOwner((Case)so);
	}

	/**
	 * @description Set Master Account on case
	 *
	 * @param newCase A case that needs to have master account updated
	 */
	private void setMasterAccount(Case newCase)
	{
		if(String.isNotBlank(newCase.ContactId) && contactMap != null)
		{
			Contact foundContact = contactMap.get(newCase.ContactId);

			if(String.isNotBlank(foundContact?.Account?.AW_ParentAccount__c))
			{
				newCase.AW_MasterAccount__c = foundContact.Account.AW_ParentAccount__c;
			}
		}
	}

	/**
	 * @description Will update the owner of the object to Parent Account Owner
	 *
	 * @param newCase A case that's needs to be assigned to Parent Account Owner
	 */
	private void setCaseOwner(Case newCase)
	{

		User currentUser = AW_DAL_User.getCurrentUser();

		if(AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT.equalsIgnoreCase(currentUser.Profile.Name) && String.isNotBlank(newCase.ContactId) && contactMap != null)
		{
			Contact foundContact = contactMap.get(newCase.ContactId);

			if(String.isNotBlank(foundContact?.Account?.OwnerId))
			{
				newCase.OwnerId = foundContact.Account.OwnerId;
			}

		}
	}
}