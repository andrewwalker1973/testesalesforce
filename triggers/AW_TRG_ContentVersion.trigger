/**
 * @description Trigger to execute custom actions when DML event occurs on ContentVersion
 *
 * @see AW_TH_ContentVersion
 *
 * @author Accenture
 *
 * @date 2019
 */
trigger AW_TRG_ContentVersion on ContentVersion (before insert)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_ContentVersion.class);
}