/**
 * @description Trigger to execute custom actions when DML event occurs on Account and to create Share records when FinancialAccount is created or
 * owner is updated
 *
 * @see AW_TH_FinancialAccount
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author vishakha.saini@accenture.com jason.van.beukering@accenture.com
 *
 * @date 2019, December 2022
 */
trigger AW_TRG_FinancialAccount on FinServ__FinancialAccount__c (before insert, before update, after insert, after update)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_FinancialAccount.class);
	new CMN_FACTORY_TriggerAction().run();
}