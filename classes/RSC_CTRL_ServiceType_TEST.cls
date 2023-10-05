/**
 * @description Test class related to the RSC_CTRL_ServiceType
 *
 * @see RSC_CTRL_ServiceType @story ST-133715
 *
 * @author aakriti.a.goyal@accenture.com kushal.a.garg@accenture.com
 *
 * @date June 2021 June 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class RSC_CTRL_ServiceType_TEST
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
	 * @description Will check if querying all distinct departments from service type object works
	 *
	 * @see RSC_CTRL_ServiceType.findAllDepartments
	 */
	@IsTest
	private static void findAllDepartments()
	{
		Test.startTest();

		List<String> departments = RSC_CTRL_ServiceType.findAllDepartments();

		Test.stopTest();

		System.assertEquals(false, departments.isEmpty(), 'No department was found.');
	}

	/**
	 * @description Will check if querying service type record from service type id works
	 *
	 * @see RSC_CTRL_ServiceType.findServiceTypeById
	 */
	@IsTest
	private static void findServiceTypeId()
	{
		Id serviceTypeId = SC_DAL_ServiceType.getAll().iterator().next().Id;
		Test.startTest();

		SC_ServiceType__c serviceType = RSC_CTRL_ServiceType.findServiceTypeById(serviceTypeId);

		Test.stopTest();

		System.assertEquals(serviceTypeId,serviceType.Id, 'Incorrect Service Type record found.');
	}
}