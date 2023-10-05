/**
 * @description Test Class for AW_API_RestOutboundAdviserPerformance
 *
 * @see AW_API_RestOutboundAdviserPerformance @story ST-3495
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=false)
private class AW_TEST_API_AdviserPerformance
{
	public static final Integer NUMBER_OF_PERFORMANCE_RECORDS = 11;

	@TestSetup
	private static void insertTestData()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		AW_DAL_TestDataFactory.createFeatureSwitch();

		//Ensure that we create community account and user and community account owned by an adviser
		System.runAs(adviser)
		{
			AW_DAL_TestDataFactory.createCommunityUser();
		}
	}

	/**
	 * @description Method to create webservice queue records
	 *
	 * @return      List of webservice queue records
	 */
	public static List<CMN_WebserviceCallQueue__c> setup()
	{
		Account newAccount = AW_DAL_Account.getAll().iterator().next();
		User adviser = AW_DAL_User.findAdviserById(newAccount.OwnerId);

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RestOutboundAdviserPerformance.SERVICE_NAME, adviser.Id);

		return new List<CMN_WebserviceCallQueue__c> {queueItem};
	}

	@IsTest
	private static void successfulCall()
	{
		List<CMN_WebserviceCallQueue__c> queueItem = setup();
		User adviser = AW_DAL_User.findAdviserById(queueItem[0].CMN_TriggeringObjectId__c);
		adviser.AW_LastPerformanceAPIRunDate__c = null;
		update adviser;

		Date performanceDate;
		AW_API_RestOutboundAdviserPerformance.MOCK_YEAR_WEEKS = new List<String>();
		AW_API_RestOutboundAdviserPerformance.MOCK_WEEK_NUMBERS = new List<Integer>();
		AW_API_RestOutboundAdviserPerformance.MOCK_UACFID = adviser.AW_UACFID__c;

		while(AW_API_RestOutboundAdviserPerformance.MOCK_YEAR_WEEKS.size() < NUMBER_OF_PERFORMANCE_RECORDS)
		{
			Date randomDate = CMN_DAL_SObjectDomain.generateRandomDate(); //Generate random date
			performanceDate = performanceDate == null ? randomDate : performanceDate; //Set the first random date as the performance date
			Integer weekNumber = CMN_UTIL_Date.weekNumberFromDate(randomDate); //Calculate week number
			String yearWeek = String.valueOf(randomDate.year()) + String.valueOf(weekNumber).leftPad(2, '0'); //Calculate year week

			//Add to the list if yearWeek is not already present. This is to ensure no duplicates are added to the list.
			if(!AW_API_RestOutboundAdviserPerformance.MOCK_YEAR_WEEKS.contains(yearWeek))
			{
				AW_API_RestOutboundAdviserPerformance.MOCK_YEAR_WEEKS.add(yearWeek);
				AW_API_RestOutboundAdviserPerformance.MOCK_WEEK_NUMBERS.add(weekNumber);
			}
		}

		AW_DAL_TestDataFactory.createAdviserPerformances(new Set<String> {adviser.AW_UACFID__c}, performanceDate);

		List<AW_API_RestOutboundAdviserPerformance.DTO_AdviserPerformance> dtoAdviserPerformance = getDTOPerformance();

		CMN_API_RestBaseOutboundTestHelper.successfulCall(queueItem);

		List<AW_AdviserPerformance__c> newPerformances = AW_DAL_AdviserPerformance.findByUACFIDs(new Set<String> {adviser.AW_UACFID__c});
		adviser = AW_DAL_User.findById(adviser.Id);

		//This section is to calculate the highest date based on highest year week. This should be equal to adviser.AW_LastPerformanceAPIRunDate__c field.
		AW_API_RestOutboundAdviserPerformance.MOCK_YEAR_WEEKS.sort();
		String highestYearWeek = AW_API_RestOutboundAdviserPerformance.MOCK_YEAR_WEEKS[AW_API_RestOutboundAdviserPerformance.MOCK_YEAR_WEEKS.size() - 1];
		Date highestWeekEndDate = CMN_UTIL_Date.weekEndDateFromWeekNumber(Integer.valueOf(highestYearWeek.substring(4, 6)), Integer.valueOf(highestYearWeek.substring(0, 4)));

		System.assertEquals(dtoAdviserPerformance.size(), newPerformances.size(), 'Correct number of Performance records not created');
		System.assertEquals(highestWeekEndDate, adviser.AW_LastPerformanceAPIRunDate__c, 'Last Performance API Run Date not updated correctly for the adviser');
	}

	@IsTest
	private static void checkAdviserIdForRequest()
	{
		List<CMN_WebserviceCallQueue__c> queueItems = setup();

		User adviser = AW_DAL_User.findAdviserById(queueItems[0].CMN_TriggeringObjectId__c);

		adviser.AW_UACFID__c = CMN_UTIL_String.EMPTY;

		System.runAs(AW_DAL_User.findActiveAdministrator())
		{
			update adviser;
		}

		checkException(queueItems, AW_API_RestOutboundAdviserPerformance.EXC_UACFID_NOT_FOUND);
	}

	private static void checkException(List<CMN_WebserviceCallQueue__c> queueItems, String excMessage)
	{
		Test.startTest();

		List<CMN_API_HttpBase> responses = CMN_FACTORY_WebserviceManager.execute(queueItems);

		Test.stopTest();

		for(CMN_API_HttpBase response : responses)
		{
			System.assertNotEquals(true, response.callResult.errors.isEmpty(), 'No errors thrown');
			System.assert(response.callResult.errors.contains(excMessage));
			System.assertEquals(true, response.callResult.aborted, 'Expected Request to have aborted.');
		}
	}

	/**
 * @description Method to get performance 
	 *
 * @return   :List<AW_API_RestOutboundAdviserPerformance.DTO_AdviserPerformance>
 */
	private static List<AW_API_RestOutboundAdviserPerformance.DTO_AdviserPerformance> getDTOPerformance()
	{
		AW_API_RestOutboundAdviserPerformance.AW_API_RestOutboundAdviserPerformanceMock mock = new AW_API_RestOutboundAdviserPerformance.AW_API_RestOutboundAdviserPerformanceMock();
		String response = mock.VALID_RESPONSE;

		String res = '{' + AW_API_RestOutboundAdviserPerformance.FMT_JSON_OUTER_ATTR_NAME + response + '}';

		AW_API_RestOutboundAdviserPerformance.DTO_Response dtoResponse = (AW_API_RestOutboundAdviserPerformance.DTO_Response)JSON.deserialize(res, AW_API_RestOutboundAdviserPerformance.DTO_Response.class);

		return dtoResponse.adviserPerformances;
	}

}