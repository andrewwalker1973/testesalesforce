/**
 * @description Trigger to execute custom actions when DML event occurs on Account
 *
 * @see AW_TRH_Account
 * @see AW_TRH_Account_TEST
 *
 * @author jason.van.beukering@accenture.com a.shrikrishna.pethe@accenture.com
 *
 * @date June 2022
 */
trigger AW_TRG_Account on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TRH_Account.class);
	new CMN_FACTORY_TriggerAction().run();
}