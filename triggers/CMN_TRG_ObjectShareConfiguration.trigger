/**
 * @description Trigger to process changes to configuration changes
 *
 * @see CMN_TRA_ObjectShareConfiguration
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date June 2022
 */
trigger CMN_TRG_ObjectShareConfiguration on CMN_ObjectShareConfiguration__c (after insert, after update, after delete, after undelete)
{
	new CMN_FACTORY_TriggerAction().run();
}