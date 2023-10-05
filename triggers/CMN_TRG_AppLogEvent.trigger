/**
 * @description App log event  trigger for handling log events
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date 2020, July 2023
 */
trigger CMN_TRG_AppLogEvent on CMN_AppLogEvent__e (after insert)
{
	CMN_FACTORY_TriggerHandler.createHandler(CMN_TRH_AppLogEvent.class);
}