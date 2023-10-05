/**
 * @description Trigger to execute custom actions when DML event occurs on Adviser Performance
 *
 * @see AW_TH_AdviserPerformance
 *
 * @author Accenture
 *
 * @date 2019
 */
trigger AW_TRG_AdviserPerformance on AW_AdviserPerformance__c (before insert)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_AdviserPerformance.class);
}