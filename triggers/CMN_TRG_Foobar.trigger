/**
 * @description Example trigger demonstrating how to use Trigger Handler framework
 *
 * @see CMN_TRH_Foobar
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date 2019, June 2022
 */
trigger CMN_TRG_Foobar on CMN_Foobar__c(before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	CMN_FACTORY_TriggerHandler.createHandler(CMN_TRH_Foobar.class);
	new CMN_FACTORY_TriggerAction().run();
}