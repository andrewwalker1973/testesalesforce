/**
 * @description Will Test the behaviour of the associated trigger action to ensure framework is operating as expected
 *
 * @see CMN_TRA_Foobar
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date June 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_TRA_Foobar_TEST
{
	/**
	 * @description Checks that action executed as per expected
	 */
	@IsTest
	private static void successfulExecution()
	{
		CMN_Foobar__c beforeInsertFoobar = CMN_DAL_DataFactory.newFoobar();

		Test.startTest();

		CMN_DAL_SObjectDomain.insertDBObject(beforeInsertFoobar);

		Test.stopTest();

		List<CMN_Foobar__c> afterInsertFoobars = CMN_DAL_Foobar.getAll();

		System.assertEquals(1, afterInsertFoobars.size(), 'Incorrect number of Foobars inserted');
		System.assertNotEquals(beforeInsertFoobar.CMN_Text__c, afterInsertFoobars.iterator().next().CMN_Text__c, 'Action did not update object as expected');
	}
}