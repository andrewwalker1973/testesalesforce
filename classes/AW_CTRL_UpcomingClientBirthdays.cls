/**
 * @description Controller Class for awLwcUpcomingClientBirthdays
 *
 * @see AW_CTRL_UpcomingClientBirthdays_TEST
 *
 * @author pavan.t@lntinfotech.com ,k.marakalala@accenture.com
 *
 * @date April 2023, July 2023
 */
public inherited sharing  class AW_CTRL_UpcomingClientBirthdays
{
	private static final Integer MAX_NUMBER_OF_RECORDS = 15;
	private static final Integer NUMBER_OF_DAYS_FROM_TODAY = 7;
	@TestVisible
	private static final String TODAY_VALUE = 'Today';

	/**
	 * @description this method will get the upcoming client birthday details
	 *
	 * @param accountOwnerId Id of the logged in account owner
	 *@param userId
	 * @return list of contacts wrapper
	 */
	@AuraEnabled(Cacheable=true)
	public static List<DTO_Response> getClientUpcomingBirthdayDetails(Id accountOwnerId)
	{
		List<DTO_Response> dtoResponses = new List<DTO_Response>();

		List<Contact> foundContacts = AW_DAL_Contact.findByBirthdateRange
				(
						accountOwnerId,
						new CMN_SOQL_Query.DateFormula().todayX(),
						new CMN_SOQL_Query.DateFormula().next(NUMBER_OF_DAYS_FROM_TODAY, CMN_SOQL_Query.UnitOfTime.DAY),
						MAX_NUMBER_OF_RECORDS
				);

		for(Contact foundContact : foundContacts)
		{
			DTO_Response dtoResponse = new DTO_Response();

			dtoResponse.name = foundContact.Name;
			dtoResponse.accountId = foundContact.AccountId;

			Date today = Date.today();

			if(foundContact.Birthdate.month() == today.month() && foundContact.Birthdate.day() == today.day())
			{
				dtoResponse.birthDate = TODAY_VALUE;
				dtoResponse.isBirthdayToday = true;
				dtoResponse.turningToAge = foundContact.AW_Age__c;
			}
			else
			{
				dtoResponse.birthDate = CMN_UTIL_Date.dateToIso8601String(foundContact.Birthdate);
				dtoResponse.isBirthdayToday = false;
				dtoResponse.turningToAge = foundContact.AW_Age__c + 1;
			}

			dtoResponses.add(dtoResponse);
		}

		return dtoResponses;
	}

	/**
	 * @description Inner class to define structure of response body
	 */
	public class DTO_Response
	{
		/**
		 * @description client or contact name
		 */
		@AuraEnabled
		public String name;
		/**
		 * @description client or contact birthdate
		 */
		@AuraEnabled
		public String birthDate;
		/**
		 * @description client or contact birthday is today
		 */
		@AuraEnabled
		public Boolean isBirthdayToday;
		/**
		 * @description client or contact turning to age
		 */
		@AuraEnabled
		public Double turningToAge;
		/**
		 * @description client or contact accountId
		 */
		@AuraEnabled
		public String accountId;

	}
}