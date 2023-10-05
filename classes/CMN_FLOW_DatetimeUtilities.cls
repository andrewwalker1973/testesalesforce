/**
 * @description Exposes various Date & Time utility methods to Flows and Process Builders
 *
 * @see CMN_FLOW_DatetimeUtilities_TEST https://bitbucket.org/truecloudconsulting/flow-datetime-methods/src/main/
 *
 * @author https://bitbucket.org/truecloudconsulting/ jason.van.beukering@accenture.com
 *
 * @date 22 March 2021, July 2023
 */
@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
public inherited sharing class CMN_FLOW_DatetimeUtilities
{
	/**
	 * @description This variable is used to simulate business hours not being found to ensure relevant code is fired
	 */
	@TestVisible
	private static Boolean simulateMissingBusinessHours = false;

	/**
	 * @description Takes a list of requests against which to perform date time functions
	 *
	 * @param dtoRequests List of requests
	 *
	 * @return a list of responses containing operation result
	 */
	@InvocableMethod(Label='Datetime, Date and BusinessHours methods' Description='Exposes date, datetime and business hours methods.')
	public static List<DTO_Response> executeMethod(List<DTO_Request> dtoRequests)
	{
		// The datetime input should use the standard flow datetime string format “dd/mm/yy hh:mm a” in the local time zone.
		List<DTO_Response> dtoResponses = new List<DTO_Response>();

		for(DTO_Request dtoRequest : dtoRequests)
		{
			CMN_UTIL_Logger.info(JSON.serialize(dtoRequest), 'CMN_FLOW_DatetimeUtilities/executeMethod/' + dtoRequest.methodName);

			DTO_Response dtoResponse = new DTO_Response();
			dtoResponses.add(dtoResponse);

			Datetime aDatetime;
			Date aDate;

			try
			{
				if(String.isBlank(dtoRequest.dateTimeString) && dtoRequest.methodName != 'Date.today')
				{
					throw new IllegalArgumentException('Datetime string cannot be null.');
				}
				else
				{
					aDate = Date.today();
					aDatetime = Datetime.now(); // avoid null error handling
				}

				Boolean isDateMethod = (dtoRequest.methodName.left(5) == 'Date.') ? true : false;

				if(String.isBlank(dtoRequest.returnFormat))
				{
					dtoRequest.returnFormat = (isDateMethod) ? 'yyyy-MM-dd' : 'yyyy-MM-dd HH:mm:ss';
				}

				if(dtoRequest.methodName != 'Date.today')
				{
					// set initial datetime or date values
					if(isDateMethod)
					{
						aDate = Date.parse(dtoRequest.dateTimeString); // expecting only date portion to parse
					}
					else
					{
						aDatetime = Datetime.parse(dtoRequest.dateTimeString);
					}
				}

				// process by method
				switch on dtoRequest.methodName
				{
					when 'Datetime.addDays'
					{
						aDatetime = aDatetime.addDays(dtoRequest.increment);
					}
					when 'Datetime.addHours'
					{
						aDatetime = aDatetime.addHours(dtoRequest.increment);
					}
					when 'Datetime.addMinutes'
					{
						aDatetime = aDatetime.addMinutes(dtoRequest.increment);
					}
					when 'Datetime.addSeconds'
					{
						aDatetime = aDatetime.addSeconds(dtoRequest.increment);
					}
					when 'Datetime.addMonths'
					{
						aDatetime = aDatetime.addMonths(dtoRequest.increment);
					}
					when 'Datetime.addYears'
					{
						aDatetime = aDatetime.addYears(dtoRequest.increment);
					}
					when 'Datetime.formatGmt'
					{
						dtoResponse.result = aDatetime.formatGmt(dtoRequest.returnFormat);
					}
					when 'Datetime.format'
					{
						// multiple signatures to consider
						dtoResponse.result = (dtoRequest.timeZone > CMN_UTIL_String.EMPTY) ?
								aDatetime.format(dtoRequest.returnFormat, dtoRequest.timeZone) :
								aDatetime.format(dtoRequest.returnFormat);
					}
					when 'Datetime.formatLong'
					{
						dtoResponse.result = aDatetime.formatLong();
					}
					when 'Datetime.getTime'
					{
						dtoResponse.result = String.valueOf(aDatetime.getTime());
					}
					when 'Datetime.hour'
					{
						dtoResponse.result = String.valueOf(aDatetime.hour());
					}
					when 'Datetime.hourGmt'
					{
						dtoResponse.result = String.valueOf(aDatetime.hourGmt());
					}
					when 'Datetime.millisecond'
					{
						dtoResponse.result = String.valueOf(aDatetime.millisecond());
					}
					when 'Datetime.millisecondGmt'
					{
						dtoResponse.result = String.valueOf(aDatetime.millisecondGmt());
					}
					when 'Datetime.minute'
					{
						dtoResponse.result = String.valueOf(aDatetime.minute());
					}
					when 'Datetime.minuteGmt'
					{
						dtoResponse.result = String.valueOf(aDatetime.minuteGmt());
					}
					when 'Datetime.month'
					{
						dtoResponse.result = String.valueOf(aDatetime.month());
					}
					when 'Datetime.monthGmt'
					{
						dtoResponse.result = String.valueOf(aDatetime.monthGmt());
					}
					when 'Datetime.second'
					{
						dtoResponse.result = String.valueOf(aDatetime.second());
					}
					when 'Datetime.secondGmt'
					{
						dtoResponse.result = String.valueOf(aDatetime.secondGmt());
					}
					when 'Datetime.time'
					{
						dtoResponse.result = String.valueOf(aDatetime.time());
					}
					when 'Datetime.timeGmt'
					{
						dtoResponse.result = String.valueOf(aDatetime.timeGmt());
					}
					when 'Datetime.year'
					{
						dtoResponse.result = String.valueOf(aDatetime.year());
					}
					when 'Datetime.yearGmt'
					{
						dtoResponse.result = String.valueOf(aDatetime.yearGmt());
					}
					when 'Datetime.day'
					{
						dtoResponse.result = String.valueOf(aDatetime.day());
					}
					when 'Datetime.dayGmt'
					{
						dtoResponse.result = String.valueOf(aDatetime.dayGmt());
					}
					when 'Datetime.now'
					{
						aDatetime = Datetime.now(); // will be formatted to user preference later
					}
					// additional business hours specific methods
					when 'BusinessHours.add'
					{
						aDatetime = BusinessHours.add(defaultBusinessHoursId, aDatetime, (Long)dtoRequest.increment);
					}
					when 'BusinessHours.addGmt'
					{
						aDatetime = BusinessHours.addGmt(defaultBusinessHoursId, aDatetime, (Long)dtoRequest.increment);
						dtoResponse.result = aDatetime.format(dtoRequest.returnFormat);
					}
					when 'BusinessHours.diff'
					{
						if(String.isBlank(dtoRequest.secondDateString))
						{
							throw new IllegalArgumentException('Diff method requires secondDateString.');
						}

						dtoResponse.result = String.valueOf(BusinessHours.diff(defaultBusinessHoursId, aDatetime, Datetime.parse(dtoRequest.secondDateString)));

					}
					when 'BusinessHours.isWithin'
					{
						dtoResponse.result = BusinessHours.isWithin(defaultBusinessHoursId, aDatetime) ? 'true' : 'false';
					}
					when 'BusinessHours.nextStartDate'
					{
						aDatetime = BusinessHours.nextStartDate(defaultBusinessHoursId, aDatetime);
					}
					when 'Date.addDays'
					{
						aDate = aDate.addDays(dtoRequest.increment);
					}
					when 'Date.addMonths'
					{
						aDate = aDate.addMonths(dtoRequest.increment);
					}
					when 'Date.addYears'
					{
						aDate = aDate.addYears(dtoRequest.increment);
					}
					when 'Date.day'
					{
						dtoResponse.result = String.valueOf(aDate.day());
					}
					when 'Date.dayOfYear'
					{
						dtoResponse.result = String.valueOf(aDate.dayOfYear());
					}
					when 'Date.daysBetween'
					{
						dtoResponse.result = String.valueOf(aDate.daysBetween(Date.parse(dtoRequest.secondDateString)));
					}
					when 'Date.daysInMonth'
					{
						// uses the date passed in for its year and month inputs
						dtoResponse.result = String.valueOf(Date.daysInMonth(aDate.year(), aDate.month()));
					}
					when 'Date.isLeapYear'
					{
						// uses the date passed in for its year value
						dtoResponse.result = String.valueOf(Date.isLeapYear(aDate.year()));
					}
					when 'Date.month'
					{
						dtoResponse.result = String.valueOf(aDate.month());
					}
					when 'Date.monthsBetween'
					{
						dtoResponse.result = String.valueOf(aDate.monthsBetween(Date.parse(dtoRequest.secondDateString)));
					}
					when 'Date.today'
					{
						dtoResponse.result = Date.today().format();
					}
					when 'Date.toStartOfMonth'
					{
						dtoResponse.result = aDate.toStartOfMonth().format();
					}
					when 'Date.toStartOfWeek'
					{
						dtoResponse.result = aDate.toStartOfWeek().format();
					}
					when 'Date.year'
					{
						dtoResponse.result = String.valueOf(aDate.year());
					}
					when else
					{
						throw new IllegalArgumentException('No method called "' + dtoRequest.methodName + '" found.');
					}
				}

				if(String.isBlank(dtoResponse.result))
				{
					if(isDateMethod)
					{
						dtoResponse.result = aDate.format();
					}
					else
					{
						dtoResponse.result = (dtoRequest.timeZone > CMN_UTIL_String.EMPTY) ?
								aDatetime.format(dtoRequest.returnFormat, dtoRequest.timeZone) :
								aDatetime.format(dtoRequest.returnFormat);
					}
				}
			}
			catch(Exception error)
			{
				dtoResponse.errorOccurred = true;
				dtoResponse.errorMessage = error.getMessage();
				CMN_UTIL_Logger.error(error, 'CMN_FLOW_DatetimeUtilities/executeMethod/' + dtoRequest.methodName);
			}
		}

		return dtoResponses;
	}

	/**
	 * @description The request DTO containing the information required to perform the requested operation
	 */
	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public class DTO_Request
	{
		@InvocableVariable(Label='Apex Datetime method to apply' Required=true)
		public String methodName;
		@InvocableVariable(Label='Datetime input' Description='expecting local timezone datetime input variable' Required=true)
		public String dateTimeString;
		@InvocableVariable(Label='Additional days, hours, minutes, months, years or seconds' Description='see add methods' Required=false)
		public Integer increment;
		@InvocableVariable(Label='Returned datetime format' Description='see java see Java SimpleDateFormat spec for patterns' Required=false)
		public String returnFormat;
		@InvocableVariable(Label='Timezone to convert to' Description='see java spec for patterns' Required=false)
		public String timeZone;
		@InvocableVariable(Label='Additional date input where required' Description='see java spec for patterns' Required=false)
		public String secondDateString;
	}

	/**
	 * @description Response DTO containing the outcome, result of the requested operation
	 */
	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public class DTO_Response
	{
		@InvocableVariable(Label='error' Description='Indicates whether an error was encountered when performing a request' Required=true)
		public Boolean errorOccurred;
		@InvocableVariable(Label='error Message' Description='If an error occurred then this variable will contain the error message' Required=false)
		public String errorMessage;
		@InvocableVariable(Label='result' Description='If call was successful then this variable will contain the result of the call' Required=false)
		public String result;

		/**
		 * @description Default constructor the the response object
		 */
		public DTO_Response()
		{
			this.errorOccurred = false;
			this.errorMessage = CMN_UTIL_String.EMPTY;
			this.result = CMN_UTIL_String.EMPTY;
		}
	}

	/**
	 * @description this retrieves default business hours id. will throw error at run time if bh method called and no business hours are set.
	 */
	@TestVisible
	private static String defaultBusinessHoursId
	{
		get
		{
			if(String.isBlank(defaultBusinessHoursId))
			{
				defaultBusinessHoursId = CMN_DAL_BusinessHours.getDefaultBusinessHours()?.Id;

				if(String.isBlank(defaultBusinessHoursId) || simulateMissingBusinessHours)
				{
					throw new QueryException('No default business hours set.');
				}
			}

			return defaultBusinessHoursId;
		}

		private set;
	}
}