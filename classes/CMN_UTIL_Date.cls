/**
 * @description Class containing utility routines focused on dates
 *
 * @see CMN_UTIL_Date_TEST
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date 2019, January 2023
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class CMN_UTIL_Date
{
	private static final Integer DAYS_IN_WEEK = 7;
	private static final Integer THURSDAY_NUMBER = 3;
	@TestVisible
	private static final String CRON_FMT = '{0} {1} {2} {3} {4} ? {5}';
	private static final String DATE_FORMATTER = 'yyyy-MM-dd';
	private static final String DAY_FMT = 'E';
	private static final String FULL_TIME_FORMATTER = 'yyyy-MM-dd hh:mm:ss';
	private static final String ISO_8601_DATE_INDICATOR = 'T';
	private static final String JSON_QUOTE = '"';
	private static final String SATURDAY = 'Sat';
	private static final String SUNDAY = 'Sun';
	/**
	 * @description Format string to use to return full month name
	 */
	public static final String WHOLE_MONTH_FMT = 'MMMMM';

	/**
	 * @description This method is used to check if a date is on a weekend
	 *
	 * @param aDateTime as input
	 *
	 * @return return true if SATURDAY or SUNDAY
	 */
	public static Boolean isWeekend(Datetime aDateTime)
	{
		return (aDateTime.format(DAY_FMT) == SATURDAY || aDateTime.format(DAY_FMT) == SUNDAY);
	}

	/**
	 * @description This method is used to check if a datetime is on a weekend
	 *
	 * @param aDate as input
	 *
	 * @return return the date
	 */
	public static Boolean isWeekend(Date aDate)
	{
		return isWeekend(Datetime.newInstance(aDate.year(), aDate.month(), aDate.day()));
	}

	/**
	 * @description This method is used to check if a day is on a holiday
	 *
	 * @param aDate as input
	 *
	 * @return return true if day is a holiday
	 */
	public static Boolean isHoliday(Date aDate)
	{
		List<Holiday> holidays = CMN_DAL_Holiday.getAll();
		Set<Date> holidayDates = new Set<Date>();

		for(Holiday aHoliday : holidays)
		{
			holidayDates.add(Date.valueOf(String.valueOf(aHoliday.ActivityDate)));
		}

		return holidayDates.contains(aDate) ? true : false;
	}

	/**
	 * @description This method is return the datetime of week day
	 *
	 * @param day as input
	 *
	 * @return return the day
	 */
	public static Boolean isWeekDay(Datetime day)
	{
		return !isWeekend(day);
	}

	/**
	 * @description This method is return the day of week day
	 *
	 * @param aDate as input
	 *
	 * @return return the day
	 */
	public static Boolean isWeekDay(Date aDate)
	{
		return isWeekDay(Datetime.newInstance(aDate.year(), aDate.month(), aDate.day()));
	}

	/**
	 * @description This method is use to convert datetime to string
	 *
	 * @param dateArg as input
	 *
	 * @return result
	 */
	public static String fullDateTimeString(Datetime dateArg)
	{
		return dateArg.format(FULL_TIME_FORMATTER);
	}

	/**
	 * @description This method is use to convert date to string
	 *
	 * @param dateArg as input
	 *
	 * @return dateArg
	 */
	public static String fullDateString(Datetime dateArg)
	{
		return dateArg.format(DATE_FORMATTER);
	}

	/**
	 * @description This method is used to add business days to a day
	 *
	 * @param startDate The date to add business days to
	 * @param businessDaysToAdd The number of business days to add to the start date
	 *
	 * @return final date
	 */
	public static Date addBusinessDays(Date startDate, Integer businessDaysToAdd)
	{
		Date finalDate = startDate;
		Integer direction = businessDaysToAdd < 0 ? -1 : 1;

		while(businessDaysToAdd != 0)
		{
			finalDate = finalDate.addDays(direction);
			if(!isWeekend(finalDate))
			{
				businessDaysToAdd -= direction;
			}
		}
		return finalDate;
	}

	/**
	 * @description returns the last day of the week prior to the one being passed, only if current day is on a weekend
	 *
	 * @param aDate The data to evaluate
	 *
	 * @return A date containing the last weekday
	 */
	public static Date lastWeekDay(Date aDate)
	{
		Date result = aDate.addDays(0);

		if(isWeekend(result))
		{
			do
			{
				result = result.addDays(-1);
			}
			while(isWeekend(result));
		}

		return result;
	}

	/**
	 * @description returns the most recent weekday before today
	 *
	 * @return A date containing the last weekday
	 */
	public static Date lastWeekDay()
	{
		return lastWeekDay(Date.today());
	}

	/**
	 * @description returns the first day of the week subsequent to the one being passed if the current date is on a weekend
	 *
	 * @param aDate The data being evaluated
	 *
	 * @return A date containing the last first weekday
	 */
	public static Date firstWeekDay(Date aDate)
	{
		Date result = aDate.addDays(0);

		if(isWeekend(result))
		{
			do
			{
				result = result.addDays(1);
			}
			while(isWeekend(result));
		}

		return result;
	}

	/**
	 * @description returns the Datetime
	 *
	 * @return result
	 */
	public static Datetime getEpochDateTime()
	{
		return Datetime.newInstance(0);
	}

	/**
	 * @description returns the date
	 *
	 * @return result
	 */
	public static Date getEpochDate()
	{
		return getEpochDateTime().date();
	}

	/**
	 * @description returns the string value of datetime in ISO8601 format
	 *
	 * @param aDateTime as input
	 *
	 * @return string
	 */
	public static String dateTimeToIso8601String(Datetime aDateTime)
	{
		if(aDateTime == null)
		{
			aDateTime = getEpochDateTime();
		}

		String jsonDate = JSON.serialize(aDateTime);

		//Remove the quotes around the JSON Datetime.
		return CMN_UTIL_String.remove(jsonDate, JSON_QUOTE);
	}

	/**
	 * @description returns the date value in ISO8601 format
	 *
	 * @param aDate as input
	 *
	 * @return string
	 */
	public static String dateToIso8601String(Date aDate)
	{
		if(aDate == null)
		{
			aDate = getEpochDate();
		}

		return fullDateString(Datetime.newInstance(aDate.year(), aDate.month(), aDate.day()));
	}

	/**
	 * @description returns the date value of datetime in ISO8601 format
	 *
	 * @param iso8601String as input
	 *
	 * @return string
	 */
	public static Datetime iso8601StringToDateTime(String iso8601String)
	{
		return String.isBlank(iso8601String) ? null : (Datetime)JSON.deserialize(JSON_QUOTE + iso8601String + JSON_QUOTE, Datetime.class);
	}

	/**
	 * @description returns the date value of date in ISO8601 format
	 *
	 * @param iso8601String as input
	 *
	 * @return string
	 */
	public static Date iso8601StringToDate(String iso8601String)
	{
		Date returnDate = null;

		if(String.isNotBlank(iso8601String))
		{
			Datetime iso8601DateTime = iso8601StringToDateTime(iso8601String);
			//If we get a full date time, we must assume that we will need to shift it to relevant timezone, otherwise assume UTC
			returnDate = iso8601String.contains(ISO_8601_DATE_INDICATOR) ? iso8601DateTime.date() : iso8601DateTime.dateGmt();
		}

		return returnDate;
	}

	/**
	 * @description returns the date value
	 *
	 * @param dateValue as input
	 *
	 * @return string
	 */
	public static String swapSeparators(String dateValue)
	{
		String year;
		String month;
		String day;

		if(dateValue.contains('-'))
		{
			year = dateValue.substringBefore('-');
			month = dateValue.substringAfter('-').substringBefore('-');
			day = dateValue.substringAfter('-').substringAfter('-');

			return year + '/' + month + '/' + day;
		}
		else
		{
			year = dateValue.substringBefore('/');
			month = dateValue.substringAfter('/').substringBefore('/');
			day = dateValue.substringAfter('/').substringAfter('/');

			return year + '-' + month + '-' + day;
		}
	}

	/**
	 * @description This method is use to returns the set of year
	 *
	 * @param iterations as input
	 *
	 * @return stringDate
	 */
	public static Set<String> yearRange(Integer iterations)
	{
		Set<String> yearsList = new Set<String>();
		Date nowDate = Date.today();

		for(Integer i = 0; i <= iterations; i++)
		{
			yearsList.add(String.valueOf(nowDate.year() - i));
		}
		return yearsList;
	}

	/**
	 * @description This method is use to returns Date from sap value
	 *
	 * @param sapDateStr as input
	 *
	 * @return sapDate
	 */
	public static Date sapStringToDate(String sapDateStr)
	{
		Date sapDate = null;

		if((sapDateStr.length() == 8) && (Integer.valueOf(sapDateStr) > 0))
		{
			Integer year = Integer.valueOf(CMN_UTIL_String.mid(sapDateStr, 0, 4));
			Integer month = Integer.valueOf(CMN_UTIL_String.mid(sapDateStr, 4, 2));
			Integer day = Integer.valueOf(CMN_UTIL_String.mid(sapDateStr, 6, 2));

			sapDate = Date.newInstance(year, month, day);
		}

		return sapDate;
	}

	/**
	 * @description This method is use to returns the number of week of the current date
	 * <p/>
	 * <p/>
	 * Based on ISO 8601 standard https://en.wikipedia.org/wiki/ISO_8601#Week_dates
	 * <p/>
	 * <p/>
	 * Adapted solution from here: https://www.sqlservercentral.com/articles/a-simple-formula-to-calculate-the-iso-week-number
	 * <p/>
	 * <p/>
	 * The key to the formula is to just count the number of Thursdays in the year.
	 *
	 * @param dt Date from which to calculate the week number
	 *
	 * @return The number of the week for the given date
	 */
	public static Integer weekNumberFromDate(Date dt)
	{
		//Step 1 - Determine how many whole weeks days have passed since calculation date (which is a Monday to simplify calculation)
		Date dateSerialNumber = Date.newInstance(1753, 1, 1);
		//This calculation will remove the decimal values
		Integer wholeWeekDaysSince = dateSerialNumber.daysBetween(dt) / DAYS_IN_WEEK * DAYS_IN_WEEK;

		//Step 2 - Calculate what the Thursday of the Week for the Current Date is. Since the start date was a Monday we just need to add 3 days to find Thursday
		Integer thursdayDaysSince = wholeWeekDaysSince + THURSDAY_NUMBER;

		//Step 3 – Convert the Date Serial to the "Day of the Year"
		Date thursdaySince = dateSerialNumber.addDays(thursdayDaysSince);

		//Step 4 – Prepare for More Integer Math, so that we can correctly use integer maths to determine the number of Thursdays, We up-rounding by adding 6
		Integer roundedUpDays = thursdaySince.dayOfYear() + DAYS_IN_WEEK - 1;

		//Step 5 – Divide the "Up-Rounded" Number of Days by 7 to Get the ISO Week Number
		Integer isoWeek = roundedUpDays / DAYS_IN_WEEK;

		return isoWeek;
	}

	/**
	 * @description This method to get the week end date based on week number and year
	 *
	 * @param weekNumber , year
	 * @param year as input
	 *
	 * @return result
	 */
	public static Date weekEndDateFromWeekNumber(Integer weekNumber, Integer year)
	{
		Date endDate;
		Datetime startOfTheYear = Datetime.newInstance(year, 1, 1); // This will get start of the year
		Integer yearStartOffset = Integer.valueOf(startOfTheYear.format('u')); // This will give the weekday Monday - 1, Tuesday - 2...

		Date startDate = startOfTheYear.date();
		endDate = startDate - yearStartOffset + weekNumber * DAYS_IN_WEEK;
		return endDate;
	}

	/**
	 * @description This method is use to returns datetime
	 *
	 * @param nextRun as input
	 *
	 * @return either null or a chron expression
	 */
	public static String getCronExpression(Datetime nextRun)
	{
		String chronExpression;

		if(nextRun != null)
		{
			chronExpression = String.format
					(
							CRON_FMT,
							new List<Object> {nextRun.second(), nextRun.minute(), nextRun.hour(), nextRun.day(), nextRun.month(), nextRun.year()}
					);
		}

		return chronExpression;
	}

	/**
	 * @description This method is use to returns datetime
	 *
	 * @param aDatetime as input
	 *
	 * @return the full english month name
	 */
	public static String monthNameFromDate(Datetime aDatetime)
	{
		return aDatetime == null ? null : aDatetime.format(WHOLE_MONTH_FMT);
	}

	/**
	 * @description This method is use to returns month from date
	 *
	 * @param aDate as input
	 *
	 * @return The full english month name
	 */
	public static String monthNameFromDate(Date aDate)
	{
		return aDate == null ? null : monthNameFromDate(Datetime.newInstance(aDate.year(), aDate.month(), aDate.day()));
	}

}