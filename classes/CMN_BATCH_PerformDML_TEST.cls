/**
 * @description Batch class to allow objects to be inserted synchronously
 *
 * @see CMN_BATCH_PerformDML
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date July 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_BATCH_PerformDML_TEST
{
	/**
	 * @description Will test successful insertion of single SObject
	 */
	@IsTest
	private static void singleInsertSuccess()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();

		Test.startTest();

		Database.executeBatch(new CMN_BATCH_PerformDML(newFoobar, CMN_DAL_SObjectDomain.DatabaseOperation.DBO_INSERT));

		Test.stopTest();

		List<CMN_Foobar__c> foundFoobars = CMN_DAL_Foobar.getAll();
		System.assertEquals(1, foundFoobars.size(), 'Incorrect number of Foobars inserted');
	}

	/**
	 * @description Will test successful update of a single SObject
	 */
	@IsTest
	private static void singleUpdateSuccess()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar;

		Datetime randomDateTime = CMN_DAL_SObjectDomain.generateRandomDateTime();
		newFoobar.CMN_Datetime__c = randomDateTime;

		Test.startTest();

		Database.executeBatch(new CMN_BATCH_PerformDML(newFoobar, CMN_DAL_SObjectDomain.DatabaseOperation.DBO_UPDATE));

		Test.stopTest();

		List<CMN_Foobar__c> foundFoobars = CMN_DAL_Foobar.getAll();
		System.assertEquals(1, foundFoobars.size(), 'Incorrect number of Foobars found');
		System.assertEquals(randomDateTime, foundFoobars.iterator().next().CMN_Datetime__c, 'Foobar not updated correctly');
	}

	/**
	 * @description Will test successful deletion of a single SObject
	 */
	@IsTest
	private static void multipleDeleteSuccess()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar;

		Test.startTest();

		Database.executeBatch(new CMN_BATCH_PerformDML(new List<SObject> {newFoobar}, CMN_DAL_SObjectDomain.DatabaseOperation.DBO_DELETE));

		Test.stopTest();

		List<CMN_Foobar__c> foundFoobars = CMN_DAL_Foobar.getAll();
		System.assertEquals(true, foundFoobars.isEmpty(), 'Items not deleted as expected.');
	}

	/**
	 * @description Will test insertion of single SObject where an exception is thrown
	 */
	@IsTest
	private static void singleInsertException()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		// Setting Email to an invalid email address to cause exception
		newFoobar.CMN_Email__c = CMN_DAL_SObjectDomain.generateRandomName();

		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		Database.executeBatch(new CMN_BATCH_PerformDML(newFoobar, CMN_DAL_SObjectDomain.DatabaseOperation.DBO_INSERT));

		Test.stopTest();

		CMN_AppLog__c foundLog = CMN_DAL_AppLog.findByMethod(CMN_DAL_SObjectDomain.CLASS_METHOD_UPDATE_DATABASE);
		System.assertNotEquals(null, foundLog, 'DML Exception was not logged as expected');
	}

	/**
	 * @description Will test update of a single SObject where there is an error but exception is not thrown due to allOperationsMustSucceed = false
	 */
	@IsTest
	private static void singleEditErrorHandled()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar;

		// Setting Email to an invalid email address to cause exception
		newFoobar.CMN_Email__c = CMN_DAL_SObjectDomain.generateRandomName();
		CMN_DAL_Logger.ignoreTestMode = true;

		Test.startTest();

		Database.executeBatch(new CMN_BATCH_PerformDML(newFoobar, CMN_DAL_SObjectDomain.DatabaseOperation.DBO_UPDATE, false));

		Test.stopTest();

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CMN_DAL_SObjectDomain.CLASS_METHOD_UPDATE_DATABASE);
		System.assertNotEquals(null, appLog, 'DML error was not logged');
		System.assertEquals(newFoobar.Id, appLog.CMN_RecordId__c, 'Record Id not captured correctly on the App Log');
	}
}