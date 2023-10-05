/**
 * @description Trigger to execute custom actions when DML event occurs on Lead and to create Share records when Lead is created or owner is updated
 *
 * @see AW_TH_Lead
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author Accenture vishakha.saini@accenture.com
 *
 * @date 2019, July 2022
 */
trigger AW_TRG_Lead on Lead (after insert, after update, after delete, after undelete, before insert, before update)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_Lead.class);
	new CMN_FACTORY_TriggerAction().run();
}