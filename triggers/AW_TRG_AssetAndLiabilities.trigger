/**
 * @description Trigger to execute custom actions when DML event occurs on Asset and Liabilities and to create Share records when Asset and Liabilities
  * is created or owner is updated
 *
 * @see AW_TH_AssetsAndLiabilities
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author Accenture vishakha.saini@accenture.com
 *
 * @date May 2021, July 2022
 */
trigger AW_TRG_AssetAndLiabilities on FinServ__AssetsAndLiabilities__c (before insert, before update, after insert, after update)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_AssetsAndLiabilities.class);
	new CMN_FACTORY_TriggerAction().run();
}