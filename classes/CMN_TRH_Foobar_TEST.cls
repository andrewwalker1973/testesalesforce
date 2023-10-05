/**
 * @description Test class is use to test the base object methods that support the INT_Trigger interface
 *
 * @see CMN_TRH_Foobar
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date December 2021, June 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_TRH_Foobar_TEST
{
	/**
	 * @description test insert of single object
	 *
	 * @see CMN_DAL_SObjectDomain.insertDBObject
	 */
	@IsTest
	private static void insertDBObject()
	{
		/* Setting insertNewFoo to true to test recursions */
		CMN_TRH_Foobar.insertNewFoo = true;

		CMN_Foobar__c foobar = CMN_DAL_DataFactory.newFoobar();

		Test.startTest();

		CMN_DAL_SObjectDomain.insertDBObject(foobar);

		System.assertEquals(2, Limits.getQueries(), 'Expected only two queries to be run to check if trigger or trigger action is enabled');

		Test.stopTest();

		List<CMN_Foobar__c> newFoobars = CMN_DAL_Foobar.getAll();

		//Please note due to the following setting, two foobars will exist: CMN_TRH_Foobar.insertNewFoo
		System.assertEquals(2, newFoobars.size(), 'The trigger either executed multiple times or did not fire');
	}

	/**
	 * @description Tests the framework when an exception is thrown by the Trigger Handler
	 */
	@IsTest
	private static void throwException()
	{
		CMN_Foobar__c foobar = CMN_DAL_DataFactory.newFoobar();

		CMN_TRH_Foobar.initiateException = true;

		Test.startTest();

		try
		{
			CMN_DAL_SObjectDomain.insertDBObject(foobar);
			System.assert(false, 'No Exception Thrown');
		}
		catch(Exception error)
		{
			System.assert(true, 'Exception thrown as expected');
		}

		Test.stopTest();
	}

	/**
	 * @description Will confirm that trigger doesn't execute
	 *
	 * @see CMN_DAL_DataFactory.disableTrigger
	 */
	@IsTest
	private static void disableTrigger()
	{
		CMN_Foobar__c foobar = CMN_DAL_DataFactory.newFoobar();

		CMN_DAL_DataFactory.disableTrigger(CMN_TRH_Foobar.class.getName());

		Test.startTest();

		CMN_DAL_SObjectDomain.insertDBObject(foobar);

		Test.stopTest();

		List<CMN_Foobar__c> newFoobars = CMN_DAL_Foobar.getAll();
		System.assertEquals(1, newFoobars.size(), 'Trigger Fired and created additional row');
	}

	/**
	 * @description Tests deletion of object
	 *
	 * @see CMN_DAL_SObjectDomain.deleteDBObject
	 */
	@IsTest
	private static void deleteDBObject()
	{
		CMN_Foobar__c foobar = CMN_DAL_DataFactory.newFoobar();

		CMN_DAL_SObjectDomain.insertDBObject(foobar);

		Test.startTest();

		CMN_DAL_SObjectDomain.deleteDBObject(foobar);

		Test.stopTest();

		System.assertEquals(0, CMN_DAL_Foobar.getAll().size(), 'Object not deleted as expected');
	}

	/**
	 * @description Tests restoring an object
	 *
	 * @see CMN_DAL_SObjectDomain.undeleteDBObject
	 */
	@IsTest
	private static void undeleteDBObject()
	{
		CMN_Foobar__c foobar = CMN_DAL_DataFactory.newFoobar();

		CMN_DAL_SObjectDomain.insertDBObject(foobar);

		CMN_DAL_SObjectDomain.deleteDBObject(foobar);

		Test.startTest();

		CMN_DAL_SObjectDomain.undeleteDBObject(foobar);

		Test.stopTest();

		System.assertNotEquals(true, CMN_DAL_Foobar.getAll().isEmpty(), 'Object not undeleted as expected');
	}

	/**
	 * @description Tests the restore of multiple objects
	 *
	 * @see CMN_DAL_SObjectDomain.undeleteDBObjects
	 */
	@IsTest
	private static void undeleteDBObjects()
	{
		List<CMN_Foobar__c> foobars = new List<CMN_Foobar__c>
		{
				CMN_DAL_DataFactory.newFoobar(),
				CMN_DAL_DataFactory.newFoobar()
		};

		CMN_DAL_SObjectDomain.insertDBObjects(foobars);
		CMN_DAL_SObjectDomain.deleteDBObjects(foobars);

		Test.startTest();

		CMN_DAL_SObjectDomain.undeleteDBObjects(foobars);

		Test.stopTest();

		System.assertEquals(foobars.size(), CMN_DAL_Foobar.getAll()?.size(), 'Objects not undeleted as expected');
	}

	/**
	 * @description Tests to see behaviour for a restore where it fails
	 *
	 * @see CMN_DAL_SObjectDomain.undeleteDBObject
	 */
	@IsTest
	private static void undeleteDBObjectFailed()
	{
		CMN_Foobar__c foobar = CMN_DAL_DataFactory.newFoobar();

		CMN_DAL_SObjectDomain.insertDBObject(foobar);

		Test.startTest();

		Boolean successful = CMN_DAL_SObjectDomain.undeleteDBObject(foobar, false).success;

		Test.stopTest();

		System.assertNotEquals(true, successful, 'Operation did not fail as expected');
	}

	/**
	 * @description Tests updating an Object
	 *
	 * @see CMN_DAL_SObjectDomain.updateDBObject
	 */
	@IsTest
	private static void updateDBObject()
	{
		List<String> pickValues = CMN_UTIL_System.getPicklistValues(CMN_DAL_Foobar.OBJECT_NAME, CMN_DAL_Foobar.FIELD_PICKLIST);
		CMN_Foobar__c foobar = CMN_DAL_DataFactory.newFoobar();

		foobar.CMN_Picklist__c = pickValues[0];
		CMN_DAL_SObjectDomain.insertDBObject(foobar);

		Test.startTest();

		foobar.CMN_Picklist__c = pickValues[1];
		CMN_DAL_SObjectDomain.updateDBObject(foobar);

		Test.stopTest();

		foobar = CMN_DAL_Foobar.getAll().iterator().next();

		System.assertEquals(pickValues[1], foobar.CMN_Picklist__c, 'Object not updated as expected');
	}

	/**
	 * @description This method is use to test the exceptions
	 */
	@IsTest
	private static void handlerCreationError()
	{
		Test.startTest();
		try
		{
			CMN_FACTORY_TriggerHandler.createHandler(null);
			System.assert(false, 'Exception was not thrown.');
		}
		catch(CMN_FACTORY_TriggerHandler.TriggerFactoryException error)
		{
			System.assert(true, 'Exception was thrown as expected.');
		}
		Test.stopTest();
	}
}