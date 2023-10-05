/**
 * @description Trigger to execute custom actions when DML event occurs on FNA
 *
 * @see AW_TH_FNA
 *
 * @author Deloitte
 *
 * @date 2020
 */
trigger AW_TRG_FNA on AW_FNA__c (before insert, after insert)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_FNA.class);
}