/**
 * @description - This batch class runs every 1 hour and reassign the account that haven't been actioned within a certain time frame
 *
 * @see AW_BATCH_Reallocation
 * @see AW_BATCH_AccountReallocation_TEST
 *
 * @author prashant.k.jain@accenture.com
 *
 * @date July 2021
 */
public inherited sharing class AW_BATCH_AccountReallocation implements Database.Batchable<SObject>
{
	public Database.QueryLocator start(Database.BatchableContext bc)
	{
		AW_ReallocationSetting__mdt reallocationSetting = AW_DAL_ReallocationSetting.getInstance(AW_DAL_ReallocationSetting.DEVELOPER_NAME_ACCOUNT_REALLOCATION);
		Datetime slaBreachedOn = BusinessHours.add(CMN_DAL_BusinessHours.getDefaultBusinessHours()?.Id, System.now(), -reallocationSetting.AW_SLADurationInMilliseconds__c.longValue());
		return AW_DAL_Account.findRecordsToBeReallocatedQuery(AW_DAL_Profile.PROFILE_ADVISER, AW_DAL_Account.ACCOUNT_OWNERSHIP_ORPHAN, slaBreachedOn);
	}

	public void execute(Database.BatchableContext bc, List<Account> accounts)
	{
		//TODO: This will be called multiple times
		AW_BATCH_Reallocation.process(accounts);
	}

	public void finish(Database.BatchableContext bc)
	{
	}
}