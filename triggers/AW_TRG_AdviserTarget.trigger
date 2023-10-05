/**
 * @description Trigger to execute custom actions when DML event occurs on Adviser Target
 *
 * @see AW_TH_AdviserTarget
 *
 * @author Accenture
 *
 * @date 2019
 */
trigger AW_TRG_AdviserTarget on AW_AdviserTarget__c (before insert)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_AdviserTarget.class);
}