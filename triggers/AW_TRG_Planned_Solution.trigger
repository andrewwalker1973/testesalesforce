/**
 * @description Trigger to execute custom actions when DML event occurs on Planned Solution
 *
 * @see AW_TH_Planned_Solution
 *
 * @author Deloitte
 *
 * @date 2020
 */
trigger AW_TRG_Planned_Solution on AW_Planned_Solution__c (before insert, before update)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_Planned_Solution.class);
}