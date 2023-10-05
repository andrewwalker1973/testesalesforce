/**
 * @description Trigger to create Share records when Income is created or owner is updated
 *
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author vishakha.saini@accenture.com
 *
 * @date July 2022
 */
trigger AW_TRG_Income on AW_Income__c (after insert, after update)
{
	new CMN_FACTORY_TriggerAction().run();
}