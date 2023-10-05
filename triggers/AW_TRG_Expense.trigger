/**
 * @description Trigger to create Share records when Expense is created or owner is updated
 *
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author vishakha.saini@accenture.com
 *
 * @date July 2022
 */
trigger AW_TRG_Expense on AW_Expense__c (after insert, after update)
{
	new CMN_FACTORY_TriggerAction().run();
}