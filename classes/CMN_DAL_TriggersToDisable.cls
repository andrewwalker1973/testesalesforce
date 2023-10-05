/**
 * @description Provides Query methods related for TriggersToDisable Custom Setting
 *
 * @see CMN_TriggersToDisable__c
 * @see CMN_FACTORY_TriggerHandler
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date 2020, June 2022
 */
public inherited sharing class CMN_DAL_TriggersToDisable
{
	/**
	 * @description Use this per transaction to hold all the disabled triggers so
	 * that we don't run the same query for before and after triggers or during recursion
	 */
	private static Set<String> disabledTriggerNames;

	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of Trigger To Enable Custom Setting fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_TriggersToDisable__c.CMN_ClassName__c.getDescribe().getLocalName(),
				CMN_TriggersToDisable__c.Name.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will check if a trigger has been disabled
	 *
	 * @param triggerName The name of the trigger to check (must be the class name)
	 *
	 * @return Returns true if a row is NOT found for the given triggerName
	 */
	public static Boolean isTriggerEnabled(String triggerName)
	{
		if(disabledTriggerNames == null)
		{
			disabledTriggerNames = CMN_UTIL_System.extractSetValues
					(
							CMN_DAL_Search.getAll
									(
											CMN_TriggersToDisable__c.SObjectType,
											getDefaultFields()
									),
							CMN_TriggersToDisable__c.CMN_ClassName__c.getDescribe().getLocalName()
					);
		}

		return !disabledTriggerNames.contains(triggerName);
	}
}