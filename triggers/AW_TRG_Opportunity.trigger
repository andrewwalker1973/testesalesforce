/**
 * @description Trigger to execute custom actions when DML event occurs on Opportunity and to create Share records when Opportunity is created or
 * owner is updated
 *
 * @see AW_TH_Opportunity
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author Accenture vishakha.saini@accenture.com
 *
 * @date 2019, July 2022
 */
trigger AW_TRG_Opportunity on Opportunity (before insert, after insert, after update, after delete, after undelete)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_Opportunity.class);
	new CMN_FACTORY_TriggerAction().run();
}