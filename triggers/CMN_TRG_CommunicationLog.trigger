/**
 * @description Trigger to execute custom actions when DML event occurs on Communication Log
 *
 * @see CMN_TRA_CommunicationLog
 *
 * @author aakriti.a.goyal@accenture.com
 *
 * @date July 2022
 */
trigger CMN_TRG_CommunicationLog on CMN_CommunicationLog__c (before insert)
{
	new CMN_FACTORY_TriggerAction().run();
}