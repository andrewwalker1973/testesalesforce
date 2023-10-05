/**
 * @description Trigger to execute custom actions when DML event occurs on EmailMessage
 *
 * @see AW_TH_EmailMessage
 *
 * @author Accenture
 *
 * @date 2019
 */
trigger AW_TRG_EmailMessage on EmailMessage (before insert)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_EmailMessage.class);
}