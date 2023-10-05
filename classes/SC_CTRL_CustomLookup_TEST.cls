/**
 * @description Test class related to the SC_CTRL_CustomLookup
 *
 * @see SC_CTRL_CustomLookup @story ST-133715
 *
 * @author aakriti.a.goyal@accenture.com jason.van.beukering@accenture.com
 *
 * @date June 2021, April 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class SC_CTRL_CustomLookup_TEST
{
	private static final Integer NUMBER_OF_RECORDS_TO_CREATE = 5;

	/**
	 * @description Setup the test data
	 */
	@TestSetup
	static void insertTestData()
	{
		SC_DAL_DataFactory.createServiceTypes(NUMBER_OF_RECORDS_TO_CREATE);
	}

	/**
	 * @description To test the search result of service type object with specified filter condition
	 */
	@IsTest
	private static void fetchLookupDataWithFilter()
	{
		SC_ServiceType__c serviceType = SC_DAL_ServiceType.getAll().iterator().next();
		String filterCriteria = SC_DAL_ServiceType.FIELD_PROCESS_NAME + '= \'' + serviceType.SC_Department__c + '\'';

		List<SObject> sObjects = fetchLookupData(serviceType.Name, String.valueOf(SC_ServiceType__c.SObjectType), SC_DAL_ServiceType.FIELD_NAME, filterCriteria);

		System.assertEquals(false, sObjects.isEmpty(), 'No Service Type was found.');
	}

	/**
	 * @description To test the search result of service type object without search key
	 */
	@IsTest
	private static void fetchLookupDataWithoutSearchKey()
	{
		SC_ServiceType__c serviceType = SC_DAL_ServiceType.getAll().iterator().next();
		String filterCriteria = SC_DAL_ServiceType.FIELD_PROCESS_NAME + '= \'' + serviceType.SC_Department__c + '\'';

		List<SObject> sObjects = fetchLookupData(CMN_UTIL_String.EMPTY, String.valueOf(SC_ServiceType__c.SObjectType), SC_DAL_ServiceType.FIELD_NAME, filterCriteria);

		System.assertEquals(false, sObjects.isEmpty(), 'No Service Type was found.');
	}

	/**
	 * @description To test the search result of service type object for no records
	 */
	@IsTest
	private static void fetchLookupDataForNoMatchedRecords()
	{
		String filterCriteria = SC_DAL_ServiceType.FIELD_PROCESS_NAME + '= \'' + CMN_DAL_SObjectDomain.generateRandomName() + '\'';

		List<SObject> sObjects = fetchLookupData(CMN_UTIL_String.EMPTY, String.valueOf(SC_ServiceType__c.SObjectType), SC_DAL_ServiceType.FIELD_NAME, filterCriteria);

		System.assertEquals(true, sObjects.isEmpty(), 'Service Type record should not be returned if filter criteria is not matched.');
	}

	/**
	 * @description To test the search result of service type object without any filter condition
	 */
	@IsTest
	private static void fetchLookupDataWithoutFilter()
	{
		SC_ServiceType__c serviceType = SC_DAL_ServiceType.getAll().iterator().next();

		List<SObject> sObjects =
				fetchLookupData(serviceType.Name, String.valueOf(SC_ServiceType__c.SObjectType), SC_DAL_ServiceType.FIELD_NAME, CMN_UTIL_String.EMPTY);

		System.assertEquals(false, sObjects.isEmpty(), 'No Service Type was found.');
	}

	/**
	 * @description To test the search result of service type object with specific record Id
	 */
	@IsTest
	private static void fetchDefaultRecordsWithValidId()
	{
		SC_ServiceType__c serviceType = SC_DAL_ServiceType.getAll().iterator().next();

		SObject record = fetchDefaultRecords(serviceType.Id);

		System.assertNotEquals(null, record, 'Service Type record was not found.');
	}

	/**
	 * @description To test the search result of service type object with invalid record Id
	 */
	@IsTest
	private static void fetchDefaultRecordsWithInvalidId()
	{
		SC_ServiceType__c serviceType = SC_DAL_ServiceType.getAll().iterator().next();
		CMN_DAL_SObjectDomain.deleteDBObject(serviceType);

		SObject record = fetchDefaultRecords(serviceType.Id);

		System.assertEquals(null, record, 'Service Type record should not be returned for invalid record id.');
	}

	/**
	 * @description To test the search result of service type object with blank record Id
	 */
	@IsTest
	private static void fetchDefaultRecordsWithBlankId()
	{
		SObject record = fetchDefaultRecords(null);

		System.assertEquals(null, record, 'Service Type record should not be returned if record id is null.');
	}

	/**
	 * @description To get the search result of service type object with the provided record Id & other parameters
	 *
	 * @param searchTerm The search keyword
	 * @param sObjectName The name of the SObject
	 * @param searchField The field to be searched
	 * @param filterCriteria The filter conditions
	 *
	 * @return List of SObjects
	 */
	private static List<SObject> fetchLookupData(String searchTerm, String sObjectName, String searchField, String filterCriteria)
	{
		Test.startTest();

		List<SObject> sObjects = SC_CTRL_CustomLookup.fetchLookupData
				(
						searchTerm,
						sObjectName,
						searchField,
						filterCriteria
				);

		Test.stopTest();

		return sObjects;
	}

	/**
	 * @description To get the search result of service type object with the provided record Id
	 *
	 * @param recordId Id of the Sobject record
	 *
	 * @return SObject
	 */
	private static SObject fetchDefaultRecords(Id recordId)
	{
		Test.startTest();

		SObject record = SC_CTRL_CustomLookup.fetchDefaultRecord(recordId, SC_DAL_ServiceType.FIELD_NAME);

		Test.stopTest();

		return record;
	}
}