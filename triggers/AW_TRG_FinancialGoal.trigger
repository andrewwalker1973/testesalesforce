/**
 * @description Trigger to execute custom actions when DML event occurs on FinancialGoal and to create Share records when FinancialGoal is created or
 * owner is updated
 *
 * @see AW_TH_FinancialGoal
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author Accenture vishakha.saini@accenture.com
 *
 * @date May 2021, July 2022
 */
trigger AW_TRG_FinancialGoal on FinServ__FinancialGoal__c (before insert, after insert, after update)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_FinancialGoal.class);
	new CMN_FACTORY_TriggerAction().run();
}