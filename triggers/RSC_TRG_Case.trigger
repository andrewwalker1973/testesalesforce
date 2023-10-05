/**
 * @description Trigger to execute custom actions when DML event occurs on Case
 *
 * @see RSC_TRA_CaseInsertActionPlanInformation
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date December 2021
 */
trigger RSC_TRG_Case on Case (after insert, after update)
{
	new CMN_FACTORY_TriggerAction().run();
}