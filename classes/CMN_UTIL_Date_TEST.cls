/**
 * @description Test class of CMN_UTIL_DATE class
 *
 * @see CMN_UTIL_DATE
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date 2019, January 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs,PMD.ApexAssertionsShouldIncludeMessage')
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_UTIL_Date_TEST
{
	/**
	 * @description Method to test the Date of weekdays.
	 */
	@IsTest
	private static void testDateMethods()
	{
		// This is a wednesday
		Date weekDay = Date.newInstance(2014, 7, 30);
		// This is a saturday
		Date weekendDay = Date.newInstance(2014, 8, 2);
		Date lastWeekDay = CMN_UTIL_Date.lastWeekDay();
		Date dateBeforeAddingWorkDays = Date.newInstance(2015, 1, 1); // 1 jan 2015 is a thursday
		Integer businessDaysToAdd = 5; // when added to 2015/1/1
		Date dateAfterAddingWorkDays = Date.newInstance(2015, 1, 8); // 5 days after the 1st excl weekends

		Date holidayDate = CMN_DAL_SObjectDomain.generateRandomDate();
		Holiday holiday = CMN_DAL_DataFactory.newRecurringHoliday(holidayDate);
		insert holiday;

		Test.startTest();
		Boolean checker = CMN_UTIL_Date.isWeekend(weekendDay);
		Assert.areEqual(checker, true, 'This date should be weekend day. Value must be True');

		checker = CMN_UTIL_Date.isWeekDay(weekDay);
		Assert.areEqual(checker, true, 'This date should be week day. Value must be True');

		checker = CMN_UTIL_Date.isWeekDay(lastWeekDay);
		Assert.areEqual(checker, true, 'This date should be week day. Value must be True');

		checker = CMN_UTIL_Date.isHoliday(holidayDate);
		Assert.areEqual(checker, true, 'This date should be holiday. Value must be True');
		Test.stopTest();

		Date dateCheck = CMN_UTIL_Date.addBusinessDays(dateBeforeAddingWorkDays, businessDaysToAdd);
		Assert.areEqual(dateCheck, dateAfterAddingWorkDays, 'This date should exclude weekends, Value must be true');
	}

	/**
	 * @description Method to test the Datetime which return the in string
	 */
	@IsTest
	private static void testFullDateTime()
	{
		Datetime testDateTime = Datetime.newInstance(2017, 4, 18, 9, 13, 0);
		String fullDateTimeString = String.valueOf(testDateTime);

		Test.startTest();

		String returnedString = CMN_UTIL_Date.fullDateTimeString(testDateTime);

		Test.stopTest();

		Assert.areEqual(fullDateTimeString, returnedString);
	}

	/**
	 * @description Method to test datetime
	 */
	@IsTest
	private static void testFullDate()
	{
		Datetime testDateTime = Datetime.newInstance(2017, 4, 18, 9, 13, 0);
		String fullDateString = String.valueOf(testDateTime.date());

		Test.startTest();

		String returnedString = CMN_UTIL_Date.fullDateString(testDateTime);

		Test.stopTest();

		Assert.areEqual(fullDateString, returnedString);
	}

	/**
	 * @description Method to test the Datetime converted to string ISO8601
	 */
	@IsTest
	private static void testDateTimeToIso8601String()
	{
		Datetime testDateTime = Datetime.now();

		Integer milliseconds = testDateTime.millisecondGmt();
		String millisecondsString;

		if(milliseconds < 10)
		{
			millisecondsString = '00' + milliseconds;
		}
		else if((milliseconds >= 10) && (milliseconds < 100))
		{
			millisecondsString = '0' + milliseconds;
		}
		else
		{
			millisecondsString = String.valueOf(milliseconds);
		}

		List<String> deconstructedDateTime = new List<String>
		{
				String.valueOf(testDateTime.yearGmt()),
				(testDateTime.monthGmt() < 10) ? '0' + String.valueOf(testDateTime.monthGmt()) : String.valueOf(testDateTime.monthGmt()),
				(testDateTime.dayGmt() < 10) ? '0' + String.valueOf(testDateTime.dayGmt()) : String.valueOf(testDateTime.dayGmt()),
				(testDateTime.hourGmt() < 10) ? '0' + String.valueOf(testDateTime.hourGmt()) : String.valueOf(testDateTime.hourGmt()),
				(testDateTime.minuteGmt() < 10) ? '0' + String.valueOf(testDateTime.minuteGmt()) : String.valueOf(testDateTime.minuteGmt()),
				(testDateTime.secondGmt() < 10) ? '0' + String.valueOf(testDateTime.secondGmt()) : String.valueOf(testDateTime.secondGmt()),
				String.valueOf(millisecondsString)
		};

		String referenceDateTimeString = String.format('{0}-{1}-{2}T{3}:{4}:{5}.{6}Z', deconstructedDateTime);

		Test.startTest();

		String formattedDateTime = CMN_UTIL_Date.dateTimeToIso8601String(testDateTime);

		Test.stopTest();

		Assert.areEqual(referenceDateTimeString, formattedDateTime);
	}

	/**
	 * @description Method to test the null Datetime converted to string ISO8601
	 */
	@IsTest
	private static void testNullDateTimeToIso8601String()
	{
		Datetime testDateTime = null;

		Test.startTest();

		String isoDateTime = CMN_UTIL_Date.dateTimeToIso8601String(testDateTime);

		Test.stopTest();

		testDateTime = CMN_UTIL_Date.iso8601StringToDateTime(isoDateTime);

		Assert.areEqual(CMN_UTIL_Date.getEpochDateTime(), testDateTime);
	}

	/**
	 * @description Method to test the Date converted to string ISO8601
	 */
	@IsTest
	private static void testNullDateToIso8601String()
	{
		Date testDate = null;

		Test.startTest();

		String isoDate = CMN_UTIL_Date.dateToIso8601String(testDate);

		Test.stopTest();

		testDate = CMN_UTIL_Date.iso8601StringToDate(isoDate);

		Assert.areEqual(CMN_UTIL_Date.getEpochDate(), testDate);
	}

	/**
	 * @description Method to test the Date converted to string ISO8601
	 */
	@IsTest
	private static void testDateToIso8601String()
	{
		Date testDate = Date.today();

		List<String> deconstructedDate = new List<String>
		{
				String.valueOf(testDate.year()),
				(testDate.month() < 10) ? '0' + String.valueOf(testDate.month()) : String.valueOf(testDate.month()),
				(testDate.day() < 10) ? '0' + String.valueOf(testDate.day()) : String.valueOf(testDate.day())
		};

		String referenceDateString = String.format('{0}-{1}-{2}T00:00:00.000Z', deconstructedDate);

		Test.startTest();

		String formattedDate = CMN_UTIL_Date.dateTimeToIso8601String(testDate);

		Test.stopTest();

		Assert.areEqual(referenceDateString, formattedDate);
	}

	/**
	 * @description Method to test the Datetime converted to string ISO8601
	 */
	@IsTest
	private static void testIso8601StringToDateTime()
	{
		Datetime testDateTime = Datetime.now();

		String formattedDateTime = CMN_UTIL_Date.dateTimeToIso8601String(testDateTime);

		Test.startTest();

		Datetime convertedDatetime = CMN_UTIL_Date.iso8601StringToDateTime(formattedDateTime);

		Test.stopTest();

		Assert.areEqual(testDateTime, convertedDatetime, 'Datetime values are not equal');
	}

	/**
	 * @description Method to test the string ISO8601 to datetime
	 */
	@IsTest
	private static void testIso8601StringToDate()
	{
		Datetime testDateTime = Datetime.now();

		Date testDate = testDateTime.date();

		String formattedDateTime = CMN_UTIL_Date.dateTimeToIso8601String(testDateTime);

		Test.startTest();

		Date convertedDate = CMN_UTIL_Date.iso8601StringToDate(formattedDateTime);

		Test.stopTest();

		Assert.areEqual(testDate, convertedDate, 'Date values are not equal');
	}

	/**
	 * @description Will check that the swapSeparators function works as expected
	 *
	 * @param aDate Date object for the associated dateString
	 * @param dateString A Date formatted with different separators
	 * @param dateFormat The format to apply when check date string
	 */
	private static void testSwapSeparators(Date aDate, String dateString, String dateFormat)
	{
		List<String> deconstructedDate = new List<String>
		{
				String.valueOf(aDate.year()),
				(aDate.month() < 10) ? '0' + String.valueOf(aDate.month()) : String.valueOf(aDate.month()),
				(aDate.day() < 10) ? '0' + String.valueOf(aDate.day()) : String.valueOf(aDate.day())
		};

		String referenceDateString = String.format(dateFormat, deconstructedDate);

		Test.startTest();

		String returnedDateString = CMN_UTIL_Date.swapSeparators(dateString);

		Test.stopTest();

		Assert.areEqual(referenceDateString, returnedDateString);
	}

	/**
	 * @description Method to test date format
	 */
	@IsTest
	private static void testSwapDashSeparators()
	{
		Date testDate = Date.today();
		String testDateString = String.valueOf(testDate);
		testSwapSeparators(testDate, testDateString, '{0}/{1}/{2}');
	}

	/**
	 * @description Method to test date format
	 */
	@IsTest
	private static void testSwapSlashSeparators()
	{
		Date testDate = Date.today();
		String testDateString = String.valueOf(testDate).replaceAll('-', '/');
		testSwapSeparators(testDate, testDateString, '{0}-{1}-{2}');
	}

	/**
	 * @description Various date function tests
	 */
	@IsTest
	private static void testVariousDateMethods()
	{
		Date friday = Date.newInstance(2018, 01, 26);
		Date saturday = Date.newInstance(2018, 01, 27);
		Date workingDay = Date.newInstance(2018, 01, 31);

		//Since this is not a weekend, returns the date
		Assert.areEqual(workingDay, CMN_UTIL_Date.lastWeekDay(workingDay));
		//Since the date given is a weekend, it will give first working day prior to the weekend
		Assert.areEqual(friday, CMN_UTIL_Date.lastWeekDay(saturday));

		Assert.areEqual(Date.newInstance(2018, 01, 29), CMN_UTIL_Date.firstWeekDay(saturday));
		Assert.areEqual(workingDay, CMN_UTIL_Date.firstWeekDay(workingDay));

		Assert.areEqual('2018-01-27', CMN_UTIL_Date.dateToIso8601String(saturday));
		Assert.areEqual
				(
						new Set<String>
						{
								String.valueOf(System.today().year() - 1),
								String.valueOf(System.today().year())
						},
						CMN_UTIL_Date.yearRange(1)
				);

		Assert.areEqual(Datetime.newInstance(0), CMN_UTIL_Date.getEpochDateTime());
		Assert.areEqual(Datetime.newInstance(0).date(), CMN_UTIL_Date.getEpochDate());
	}

	/**
	 * @description Method to test the converted SAP string to Date
	 */
	@IsTest
	private static void testSAPStringToDate()
	{
		String dateStr = '20190221';

		Test.startTest();

		Date convertedDate = CMN_UTIL_Date.sapStringToDate(dateStr);

		Test.stopTest();

		Assert.areEqual(21, convertedDate.day(), 'Invalid day.');
		Assert.areEqual(2, convertedDate.month(), 'Invalid month.');
		Assert.areEqual(2019, convertedDate.year(), 'Invalid year.');
	}

	/**
	 * @description Method to test the week number of the current date
	 *
	 * @see CMN_UTIL_Date.weekNumberFromDate
	 */
	@IsTest
	private static void weekNumberFromDate()
	{
		assertWeekNumber(2012, 12, 30, 52);//Sun
		assertWeekNumber(2012, 12, 31, 1);//Mon
		assertWeekNumber(2013, 1, 1, 1);//Tue
		assertWeekNumber(2013, 1, 2, 1);//Wed
		assertWeekNumber(2013, 1, 7, 2);//Mon
		assertWeekNumber(2015, 12, 28, 53);//Mon
		assertWeekNumber(2016, 1, 3, 53);//Sun
		assertWeekNumber(2016, 1, 4, 1);//Mon
	}

	/**
	 * @description Will check that the week number extract from the date provided match the expected value
	 *
	 * @param year the year to use when constructing a date
	 * @param month the month to use when constructing a date
	 * @param day the day to use when constructing a date
	 * @param expectedWeekNumber The week number to check
	 *
	 * @see CMN_UTIL_Date.weekNumberFromDate
	 */
	private static void assertWeekNumber(Integer year, Integer month, Integer day, Integer expectedWeekNumber)
	{
		Date dt = Date.newInstance(year, month, day);
		Assert.areEqual(expectedWeekNumber, CMN_UTIL_Date.weekNumberFromDate(dt));
	}

	/**
	 * @description Method to test the week end date of a week number
	 *
	 * @see CMN_UTIL_Date.weekEndDateFromWeekNumber
	 */
	@IsTest
	private static void weekEndDateFromWeekNumber()
	{
		Test.startTest();

		Date weekEndDate1 = CMN_UTIL_Date.weekEndDateFromWeekNumber(1, 2019);
		Date weekEndDate2 = CMN_UTIL_Date.weekEndDateFromWeekNumber(2, 2019);
		Date weekEndDate3 = CMN_UTIL_Date.weekEndDateFromWeekNumber(3, 2019);
		Date weekEndDate4 = CMN_UTIL_Date.weekEndDateFromWeekNumber(53, 2015);

		Test.stopTest();

		Assert.areEqual(Date.newInstance(2019, 1, 6), weekEndDate1);
		Assert.areEqual(Date.newInstance(2019, 1, 13), weekEndDate2);
		Assert.areEqual(Date.newInstance(2019, 1, 20), weekEndDate3);
		Assert.areEqual(Date.newInstance(2016, 1, 3), weekEndDate4);
	}

	/**
	 * @description Method to test the name of the month based on the date.
	 */
	@IsTest
	private static void monthNameFromDate()
	{
		Test.startTest();

		Date epochDate = CMN_UTIL_Date.getEpochDate();

		String month = CMN_UTIL_Date.monthNameFromDate(epochDate);

		Test.stopTest();

		Datetime epochDateTime = Datetime.newInstance(epochDate.year(), epochDate.month(), epochDate.day());

		Assert.areEqual(epochDateTime.format(CMN_UTIL_Date.WHOLE_MONTH_FMT), month, 'Invalid  Month Returned.');
	}

	/**
	 * @description Method to test the format expression
	 */
	@IsTest
	private static void getCronExpression()
	{
		Test.startTest();

		Datetime epochDateTime = CMN_UTIL_Date.getEpochDateTime();

		String cron = CMN_UTIL_Date.getCronExpression(epochDateTime);

		Test.stopTest();

		String second = String.valueOf(epochDateTime.second());
		String minute = String.valueOf(epochDateTime.minute());
		String hour = String.valueOf(epochDateTime.hour());
		String day = String.valueOf(epochDateTime.day());
		String month = String.valueOf(epochDateTime.month());
		String year = String.valueOf(epochDateTime.year());

		String expectedCron = String.format(CMN_UTIL_Date.CRON_FMT, new List<String> {second, minute, hour, day, month, year});

		Assert.areEqual(expectedCron, cron, 'Invalid Cron expression returned');
	}
}