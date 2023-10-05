/**
 * @description Trigger to create Share records when SurveyInvitation is created or owner is updated
 *
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author vishakha.saini@accenture.com
 *
 * @date July 2022
 */
trigger AW_TRG_SurveyInvitation on SurveyInvitation (after insert, after update)
{
	new CMN_FACTORY_TriggerAction().run();
}