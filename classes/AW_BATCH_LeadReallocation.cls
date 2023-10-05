/**
 * @description - This batch class runs every 1 hour and reassign the lead that haven't been actioned within a certain time frame
 *
 * @see AW_BATCH_Reallocation
 * @see AW_BATCH_LeadReallocation_TEST
 *
 * @author prashant.k.jain@accenture.com
 *
 * @date July 2021
 */
public inherited sharing class AW_BATCH_LeadReallocation implements Database.Batchable<SObject>
{
	public Database.QueryLocator start(Database.BatchableContext bc)
	{
		AW_ReallocationSetting__mdt reallocationSetting = AW_DAL_ReallocationSetting.getInstance(AW_DAL_ReallocationSetting.DEVELOPER_NAME_LEAD_REALLOCATION);
		Datetime slaBreachedOn = BusinessHours.add(CMN_DAL_BusinessHours.getDefaultBusinessHours()?.Id, System.now(), -reallocationSetting.AW_SLADurationInMilliseconds__c.longValue());
		Set<Object> hotLeadSources = new Set<Object>{AW_DAL_Lead.LEAD_SOURCE_WEBSITE, AW_DAL_Lead.LEAD_SOURCE_CONTACT_CENTRE};
		return AW_DAL_Lead.findRecordsToBeReallocatedQuery(AW_DAL_Profile.PROFILE_ADVISER, AW_DAL_Lead.STATUS_NEW, slaBreachedOn, hotLeadSources);
	}

	public void execute(Database.BatchableContext bc, List<Lead> leads)
	{
		AW_BATCH_Reallocation.process(leads);
	}

	public void finish(Database.BatchableContext bc)
	{
	}
}