/**
 * @description Trigger to execute custom actions when DML event occurs on Outstanding Requirement and to create Share records when Outstanding Requirement
 * is created or owner is updated
 *
 * @see AW_TH_OutstandingRequirement
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author Accenture vishakha.saini@accenture.com
 *
 * @date May 2021, July 2022
 */
trigger AW_TRG_OutstandingRequirement on AW_Outstanding_Requirement__c (before insert, after insert, after update)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_OutstandingRequirement.class);
	new CMN_FACTORY_TriggerAction().run();
}