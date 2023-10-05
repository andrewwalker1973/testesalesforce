/**
 * @description Trigger to execute custom actions when DML event occurs on Insurance Policy and to create Share records when Insurance Policy is created or
 * owner is updated
 *
 * @see AW_TH_InsurancePolicy
 * @see CMN_TRA_ObjectShareOwnerChanged
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date May 2021, December 2022
 */
trigger AW_TRG_InsurancePolicy on InsurancePolicy (before insert, before update, after insert, after update, after delete, after undelete)
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_InsurancePolicy.class);
	new CMN_FACTORY_TriggerAction().run();
}