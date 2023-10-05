/**
 * @description Trigger to execute custom actions when DML event occurs on a Case
 *
 * @see AW_TH_Case
 *
 * @author Accenture
 *
 * @date May 2021
 */
trigger AW_TRG_Case on Case (before insert)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_Case.class);
}