/**
 * @description An example Trigger Action class that acts on the "Foobar" Object and used to test the trigger action framework
 *
 * @see CMN_TRA_Foobar_TEST
 * @see CMN_TRA_BaseObject
 * @see CMN_TRA_Interfaces
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date May 2022
 */
public inherited sharing class CMN_TRA_Foobar extends CMN_TRA_BaseObject implements CMN_TRA_Interfaces.CMN_INT_BeforeInsert
{
	private static final String EXAMPLE_TEST = CMN_DAL_SObjectDomain.generateRandomName();

	/**
	 * @description Action to be performed before the provided objects are inserted
	 *
	 * @param newFoobars Items being inserted
	 */
	public void beforeInsert(List<CMN_Foobar__c> newFoobars)
	{
		for(CMN_Foobar__c newFoobar : newFoobars)
		{
			newFoobar.CMN_Text__c = EXAMPLE_TEST;
		}
	}
}