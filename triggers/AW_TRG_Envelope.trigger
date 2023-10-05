/**
 * @description Trigger to execute custom actions when DML event occurs on Envelope and to create Share records when Envelope is created or owner is updated
 *
 * @see AW_TH_Envelope
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author Accenture vishakha.saini@accenture.com
 *
 * @date 2021, July 2022
 */
trigger AW_TRG_Envelope on AW_Envelope__c (before insert, before delete, after insert, after update)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_Envelope.class);
	new CMN_FACTORY_TriggerAction().run();
}