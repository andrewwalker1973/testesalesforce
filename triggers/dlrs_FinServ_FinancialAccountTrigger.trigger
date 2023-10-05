/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_FinServ_FinancialAccountTrigger on FinServ__FinancialAccount__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	dlrs.RollupService.triggerHandler(FinServ__FinancialAccount__c.SObjectType);
}