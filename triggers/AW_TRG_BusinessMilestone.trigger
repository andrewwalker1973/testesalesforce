/**
 * @description Trigger to execute custom actions when DML event occurs on a BusinessMilestone
 *
 * @see AW_TH_BusinessMilestone
 *
 * @author Accenture
 *
 * @date May 2021
 */
trigger AW_TRG_BusinessMilestone on BusinessMilestone(before insert)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_BusinessMilestone.class);
}