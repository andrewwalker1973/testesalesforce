/**
 * @description Trigger handler for the trigger AW_TRG_AdviserTarget.
 *
 * @author Accenture
 *
 * @date 23 July 2019
@story ST-2226
 */
public inherited sharing class AW_TH_AdviserTarget extends CMN_TRH_BaseObject
{
	@TestVisible
	private static final String ERROR_MESSAGE = 'Please enter Month, Year';

	Set<Id> userIds = new Set<Id>();

	/**
	 * @description : Context method overrides will be called before insertion of Object.
	 *
	 * @param so
	 */
	public override void beforeInsert(SObject so)
	{
		if(AW_DAL_FeatureSwitches.adviserTargetsEnabled)
		{

			AW_AdviserTarget__c target = (AW_AdviserTarget__c)so;

			userIds.add(target.OwnerId);
		}
	}

	/**
	 * @description : Context method overrides will be called after the end of trigger executions .
	 */
	public override void andFinally()
	{

		if(Trigger.isBefore && Trigger.isInsert && AW_DAL_FeatureSwitches.adviserTargetsEnabled)
		{
			List<User> users = AW_DAL_User.findById(userIds);
			Map<Id, SObject> userId2User = new Map<Id, SObject>(users);

			for(SObject advTarget : Trigger.new)
			{
				AW_AdviserTarget__c target = (AW_AdviserTarget__c)advTarget;
				String uacfId;

				User foundUser = (User)userId2User.get(target.OwnerId);

				if(foundUser != null)
				{
					uacfId = foundUser.AW_UACFID__c;
				}

				if(target.AW_Month__c != null && target.AW_Year__c != null && uacfId != null)
				{
					target.AW_AT_CompositeID__c = AW_DAL_AdviserTarget.constructTargetCompositeKey(target.AW_Month__c, target.AW_Year__c, uacfId);
				}
				else
				{
					target.addError(ERROR_MESSAGE);
				}
			}
		}
	}

	public override Boolean allowRecursion()
	{
		return false;
	}
}