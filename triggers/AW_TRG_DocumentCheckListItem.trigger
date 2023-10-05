/**
 * @description Trigger to execute custom actions when DML event occurs on DocumentCheckListItem and to create Share records when DocumentCheckListItem is
 * created or owner is updated
 *
 * @see AW_TH_DocumentCheckListItem
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author Accenture vishakha.saini@accenture.com
 *
 * @date 2021, July 2022
 */
trigger AW_TRG_DocumentCheckListItem on DocumentChecklistItem (before delete, before insert, after insert, after update)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_DocumentCheckListItem.class);
	new CMN_FACTORY_TriggerAction().run();
}