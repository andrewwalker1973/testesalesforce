/**
 * @description Trigger to execute custom actions when DML event occurs on a PersonLifeEvent
 *
 * @see AW_TH_PersonLifeEvents
 *
 * @author Accenture
 *
 * @date May 2021
 */
trigger AW_TRG_PersonLifeEvent on PersonLifeEvent(before insert)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_PersonLifeEvents.class);
}