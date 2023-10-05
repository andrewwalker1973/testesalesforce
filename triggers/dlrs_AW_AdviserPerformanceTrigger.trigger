/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_AW_AdviserPerformanceTrigger on AW_AdviserPerformance__c(before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	dlrs.RollupService.triggerHandler(AW_AdviserPerformance__c.SObjectType);
}