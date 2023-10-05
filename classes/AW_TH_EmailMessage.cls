/**
 * @description Trigger handler for the trigger AW_TRG_EmailMessage
 *
 * @see AW_TRG_EmailMessage
 * @see AW_TH_BaseLinkToMaster_TEST
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date May 2021, February 2023
 */
public inherited sharing class AW_TH_EmailMessage extends AW_TH_BaseLinkToMaster
{
	private final List<EmailMessage> newEmailMessages = Trigger.new;
	private final Map<Id, Account> relatedIdToMasterAccountIdMap = new Map<Id, Account>();

	/**
	 * @description Will retrieve the relevant information required for later processing
	 */
	public override void bulkBefore()
	{
		super.bulkBefore();

		Set<Id> relatedAccountIds = new Set<Id>();

		for(EmailMessage newEmailMessage : newEmailMessages)
		{
			//We only want to link this email to master account if the email is actually linked to an account
			if(CMN_UTIL_System.getSObjectTypeById(newEmailMessage.RelatedToId) == Account.SObjectType)
			{
				relatedAccountIds.add(newEmailMessage.RelatedToId);
			}
		}

		if(!relatedAccountIds.isEmpty())
		{
			relatedIdToMasterAccountIdMap.putAll(AW_DAL_Account.findActiveAccountWithParent(relatedAccountIds));
		}
	}

	/**
	 * @description Will get the master account Id for the given object
	 *
	 * @param anObject A object that's needs to be linked to a master
	 *
	 * @return Master account Id or null
	 */
	protected override Id getMasterAccountId(SObject anObject)
	{
		EmailMessage newEmailMessage = (EmailMessage)anObject;
		return relatedIdToMasterAccountIdMap.get(newEmailMessage.RelatedToId)?.AW_ParentAccount__c;
	}
}