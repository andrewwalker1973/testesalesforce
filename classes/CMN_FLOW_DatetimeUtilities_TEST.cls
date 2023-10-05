/**
 * @description Tests the date time utility methods accessible to flows and process builders
 *
 * @see CMN_FLOW_DatetimeUtilities https://bitbucket.org/truecloudconsulting/flow-datetime-methods/src/main/
 *
 * @author https://bitbucket.org/truecloudconsulting/ jason.van.beukering@accenture.com
 *
 * @date 22 March 2021, July 2023
 */
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_FLOW_DatetimeUtilities_TEST
{
	private static final String DEFAULT_DATE_TIME_FORMAT = 'd MMM yy, h:m a';

	/**
	 * @description Tests all available methods
	 */
	@IsTest
	private static void allMethods()
	{
		User newUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_STANDARD_USER);
		// to ensure the user locale is aligned to the expected test dtoResponses
		newUser.LocaleSidKey = 'en_ZA';
		newUser.TimeZoneSidKey = 'Australia/Sydney';

		System.runAs(newUser)
		{
			final String defaultDateTime = Datetime.newInstance(2021, 1, 1, 15, 47, 0).format();

			CMN_FLOW_DatetimeUtilities.DTO_Request dtoRequest = new CMN_FLOW_DatetimeUtilities.DTO_Request();

			dtoRequest.methodName = 'Datetime.addDays';
			dtoRequest.dateTimeString = defaultDateTime; // flow datetime string format
			dtoRequest.increment = 1;
			dtoRequest.returnFormat = null;
			dtoRequest.timeZone = null;

			Test.startTest();

			assertDateMethodSuccessful(dtoRequest, '2021-01-02 15:47:00');

			dtoRequest.methodName = 'Datetime.addHours';
			assertDateMethodSuccessful(dtoRequest, '2021-01-01 16:47:00');

			//Expected error to be thrown if the dateTimeString is empty and its a method requiring it
			dtoRequest.dateTimeString = CMN_UTIL_String.EMPTY;
			assertDateMethodFailed(dtoRequest);

			dtoRequest.dateTimeString = defaultDateTime;
			dtoRequest.methodName = 'Datetime.addMinutes';
			assertDateMethodSuccessful(dtoRequest, '2021-01-01 15:48:00');

			dtoRequest.dateTimeString = defaultDateTime;
			dtoRequest.methodName = 'Datetime.addSeconds';
			assertDateMethodSuccessful(dtoRequest, '2021-01-01 15:47:01');

			dtoRequest.dateTimeString = defaultDateTime;
			dtoRequest.methodName = 'Datetime.addMonths';
			assertDateMethodSuccessful(dtoRequest, '2021-02-01 15:47:00');

			dtoRequest.dateTimeString = defaultDateTime;
			dtoRequest.methodName = 'Datetime.addYears';
			assertDateMethodSuccessful(dtoRequest, '2022-01-01 15:47:00');

			dtoRequest.dateTimeString = defaultDateTime;
			dtoRequest.methodName = 'Datetime.formatGmt';
			assertDateMethodSuccessful(dtoRequest, '2021-01-01 04:47:00');

			dtoRequest.methodName = 'Datetime.format';
			assertDateMethodSuccessful(dtoRequest, '2021-01-01 15:47:00');

			dtoRequest.timeZone = 'non-existent';
			assertDateMethodSuccessful(dtoRequest, '2021-01-01 04:47:00');

			dtoRequest.timeZone = 'Australia/Sydney';
			assertDateMethodSuccessful(dtoRequest, '2021-01-01 15:47:00');

			dtoRequest.timeZone = 'America/Los_Angeles';
			assertDateMethodSuccessful(dtoRequest, '2020-12-31 20:47:00');

			dtoRequest.methodName = 'invalidMethod';
			assertDateMethodFailed(dtoRequest);

			dtoRequest.methodName = 'Datetime.formatLong';
			assertDateMethodSuccessful(dtoRequest, '2021/01/01 3:47:00 PM');

			dtoRequest.methodName = 'Datetime.getTime';
			assertDateMethodSuccessful(dtoRequest, '1609476420000');

			dtoRequest.methodName = 'Datetime.time';
			assertDateMethodSuccessful(dtoRequest, '15:47:00.000Z');

			dtoRequest.methodName = 'Datetime.timeGmt';
			assertDateMethodSuccessful(dtoRequest, '04:47:00.000Z');

			dtoRequest.methodName = 'Datetime.year';
			assertDateMethodSuccessful(dtoRequest, '2021');

			dtoRequest.methodName = 'Datetime.hour';
			assertDateMethodSuccessful(dtoRequest, '15');

			dtoRequest.methodName = 'Datetime.minute';
			assertDateMethodSuccessful(dtoRequest, '47');

			dtoRequest.methodName = 'Datetime.second';
			assertDateMethodSuccessful(dtoRequest, '0');

			dtoRequest.methodName = 'Datetime.yearGmt';
			assertDateMethodSuccessful(dtoRequest, '2021');

			dtoRequest.methodName = 'Datetime.monthGmt';
			assertDateMethodSuccessful(dtoRequest, '1');

			dtoRequest.methodName = 'Datetime.dayGmt';
			assertDateMethodSuccessful(dtoRequest, '1');

			dtoRequest.methodName = 'Datetime.hourGmt';
			assertDateMethodSuccessful(dtoRequest, '4');

			dtoRequest.methodName = 'Datetime.minuteGmt';
			assertDateMethodSuccessful(dtoRequest, '47');

			dtoRequest.methodName = 'Datetime.secondGmt';
			assertDateMethodSuccessful(dtoRequest, '0');

			dtoRequest.methodName = 'Datetime.month';
			assertDateMethodSuccessful(dtoRequest, '1');

			dtoRequest.methodName = 'Datetime.day';
			assertDateMethodSuccessful(dtoRequest, '1');

			dtoRequest.methodName = 'Datetime.millisecond';
			assertDateMethodSuccessful(dtoRequest, '0');

			dtoRequest.methodName = 'Datetime.millisecondGmt';
			assertDateMethodSuccessful(dtoRequest, '0');

			dtoRequest.methodName = 'Datetime.now';
			dtoRequest.returnFormat = DEFAULT_DATE_TIME_FORMAT;
			CMN_FLOW_DatetimeUtilities.executeMethod(new List<CMN_FLOW_DatetimeUtilities.DTO_Request> {dtoRequest});

			dtoRequest.dateTimeString = '2021/01/01';
			dtoRequest.returnFormat = 'D/M/YYYY';
			dtoRequest.methodName = 'Date.addDays';
			assertDateMethodSuccessful(dtoRequest, '2021/01/02');

			dtoRequest.methodName = 'Date.addMonths';
			assertDateMethodSuccessful(dtoRequest, '2021/02/01');

			dtoRequest.methodName = 'Date.addYears';
			assertDateMethodSuccessful(dtoRequest, '2022/01/01');

			dtoRequest.methodName = 'Date.day';
			assertDateMethodSuccessful(dtoRequest, '1');

			dtoRequest.methodName = 'Date.year';
			assertDateMethodSuccessful(dtoRequest, '2021');

			dtoRequest.methodName = 'Date.month';
			assertDateMethodSuccessful(dtoRequest, '1');

			dtoRequest.methodName = 'Date.dayOfYear';
			assertDateMethodSuccessful(dtoRequest, '1');

			dtoRequest.secondDateString = '2021/01/02';
			dtoRequest.methodName = 'Date.daysBetween';
			assertDateMethodSuccessful(dtoRequest, '1');

			dtoRequest.secondDateString = '2022/01/01';
			dtoRequest.methodName = 'Date.monthsBetween';
			assertDateMethodSuccessful(dtoRequest, '12');

			dtoRequest.methodName = 'Date.daysInMonth';
			assertDateMethodSuccessful(dtoRequest, '31');

			dtoRequest.methodName = 'Date.isLeapYear';
			assertDateMethodSuccessful(dtoRequest, 'false');

			dtoRequest.dateTimeString = CMN_UTIL_String.EMPTY;
			dtoRequest.methodName = 'Date.today';
			assertDateMethodSuccessful(dtoRequest, Date.today().format());

			dtoRequest.dateTimeString = '2021/01/10';
			dtoRequest.methodName = 'Date.toStartOfMonth';
			assertDateMethodSuccessful(dtoRequest, '2021/01/01');

			dtoRequest.dateTimeString = '2021/01/09';
			dtoRequest.methodName = 'Date.toStartOfWeek';
			assertDateMethodSuccessful(dtoRequest, '2021/01/03');

			//optional testing of the BusinessHours logic only if business hours setup
			Id defaultBusinessHours;
			try
			{
				//Make sure exception is thrown if no business hours exist
				CMN_FLOW_DatetimeUtilities.simulateMissingBusinessHours = true;
				defaultBusinessHours = CMN_FLOW_DatetimeUtilities.defaultBusinessHoursId;
				Assert.fail('Exception not thrown as expected');
			}
			catch(Exception error)
			{
				Assert.isTrue(true, 'Exception thrown as expected');
			}

			try
			{
				CMN_FLOW_DatetimeUtilities.simulateMissingBusinessHours = false;
				defaultBusinessHours = CMN_FLOW_DatetimeUtilities.defaultBusinessHoursId; // will throw error if b hours not setup
			}
			catch(Exception error)
			{
				CMN_UTIL_Logger.debug
						(
								'** No Business Hours setup so testing of these methods will be bypassed at expense of coverage % **',
								'DateTimeUtilityTest/allMethods'
						);
			}

			if(defaultBusinessHours != null)
			{
				// execute additional tests that rely on business hours being setup
				dtoRequest.dateTimeString = defaultDateTime;
				dtoRequest.methodName = 'BusinessHours.add';
				dtoRequest.returnFormat = DEFAULT_DATE_TIME_FORMAT;

				assertBusinessHoursMethodSuccessful(dtoRequest);

				dtoRequest.methodName = 'BusinessHours.addGmt';
				dtoRequest.returnFormat = DEFAULT_DATE_TIME_FORMAT;
				assertBusinessHoursMethodSuccessful(dtoRequest);

				dtoRequest.methodName = 'BusinessHours.isWithin';
				dtoRequest.returnFormat = DEFAULT_DATE_TIME_FORMAT;
				assertBusinessHoursMethodSuccessful(dtoRequest);

				dtoRequest.methodName = 'BusinessHours.diff';
				dtoRequest.returnFormat = DEFAULT_DATE_TIME_FORMAT;
				dtoRequest.secondDateString = CMN_UTIL_String.EMPTY;
				assertDateMethodFailed(dtoRequest);

				dtoRequest.secondDateString = Datetime.newInstance(2021, 1, 10, 9, 0, 0).format();
				assertBusinessHoursMethodSuccessful(dtoRequest);

				dtoRequest.methodName = 'BusinessHours.nextStartDate';
				dtoRequest.returnFormat = DEFAULT_DATE_TIME_FORMAT;
				assertBusinessHoursMethodSuccessful(dtoRequest);
			}

			Test.stopTest();
		}
	}

	/**
	 * @description Will check if a date method was executed successfully
	 *
	 * @param dtoRequest The request to execute
	 * @param expected The expected response
	 */
	private static void assertDateMethodSuccessful(CMN_FLOW_DatetimeUtilities.DTO_Request dtoRequest, Object expected)
	{
		List<CMN_FLOW_DatetimeUtilities.DTO_Response> dtoResponses = CMN_FLOW_DatetimeUtilities.executeMethod(new List<CMN_FLOW_DatetimeUtilities.DTO_Request> {dtoRequest});
		CMN_FLOW_DatetimeUtilities.DTO_Response dtoResponse = dtoResponses.iterator().next();
		Assert.isFalse(dtoResponse.errorOccurred, 'Error was throw: ' + dtoResponse.errorMessage);
		Assert.areEqual(expected, dtoResponse.result, dtoRequest.methodName + ' did not return what we expected');
	}

	/**
	 * @description Will check if a date method failed as expected
	 *
	 * @param dtoRequest The request to execute
	 */
	private static void assertDateMethodFailed(CMN_FLOW_DatetimeUtilities.DTO_Request dtoRequest)
	{
		List<CMN_FLOW_DatetimeUtilities.DTO_Response> dtoResponses = CMN_FLOW_DatetimeUtilities.executeMethod(new List<CMN_FLOW_DatetimeUtilities.DTO_Request> {dtoRequest});
		CMN_FLOW_DatetimeUtilities.DTO_Response dtoResponse = dtoResponses.iterator().next();
		Assert.isTrue(dtoResponse.errorOccurred, 'Error was not thrown as expected');
	}

	/**
	 * @description Will check if a Business Hours method was executed successfully
	 *
	 * @param dtoRequest The request to execute
	 */
	private static void assertBusinessHoursMethodSuccessful(CMN_FLOW_DatetimeUtilities.DTO_Request dtoRequest)
	{
		List<CMN_FLOW_DatetimeUtilities.DTO_Response> dtoResponses = CMN_FLOW_DatetimeUtilities.executeMethod(new List<CMN_FLOW_DatetimeUtilities.DTO_Request> {dtoRequest});
		CMN_FLOW_DatetimeUtilities.DTO_Response dtoResponse = dtoResponses.iterator().next();
		Assert.isFalse(dtoResponse.errorOccurred, 'Error was throw: ' + dtoResponse.errorMessage);
		Assert.isTrue(String.isNotBlank(dtoResponse.result), dtoRequest.methodName + ' did not return a result');
	}
}