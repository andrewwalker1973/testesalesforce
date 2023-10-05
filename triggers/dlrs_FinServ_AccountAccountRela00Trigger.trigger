/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_FinServ_AccountAccountRela00Trigger on FinServ__AccountAccountRelation__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(FinServ__AccountAccountRelation__c.SObjectType);
}