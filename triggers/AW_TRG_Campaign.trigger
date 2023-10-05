/**
 * @description Trigger to create Share records when Campaign is created or owner is updated
 *
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author vishakha.saini@accenture.com
 *
 * @date July 2022
 */
trigger AW_TRG_Campaign on Campaign (after insert, after update)
{
	new CMN_FACTORY_TriggerAction().run();
}