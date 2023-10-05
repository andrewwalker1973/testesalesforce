/**
 * @description Test class for AW_CTRL_UpcomingClientBirthdays
 *
 * @see AW_CTRL_UpcomingClientBirthdays
 *
 * @author pavan.t@lntinfotech.com
 *
 * @date April 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_CTRL_UpcomingClientBirthdays_TEST
{
	/**
	 * @description Check that person account contact has been found for logged in user
	 *
	 * @see AW_CTRL_UpcomingClientBirthdays.getClientUpcomingBirthdayDetails
	 */
	@IsTest
	private static void getPersonUpcomingBirthdayDetails()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		System.runAs(adviser)
		{
			Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

			newAccount.AW_IdentificationNumber__pc = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
			newAccount.AW_IdentificationType__pc = AW_DAL_Account.PICK_PASSPORT_TYPE;
			newAccount.AW_PassportCountryOfIssue__pc = AW_DAL_Country.findByName(AW_DAL_Country.UNITED_STATES).Id;
			newAccount.PersonBirthdate = Date.newInstance(1960, Date.today().month(), Date.today().day());
			CMN_DAL_SObjectDomain.updateDBObject(newAccount);

			Test.startTest();

			List<AW_CTRL_UpcomingClientBirthdays.DTO_Response> dtoResponses = AW_CTRL_UpcomingClientBirthdays.getClientUpcomingBirthdayDetails(adviser.Id);

			Test.stopTest();

			Assert.isFalse(dtoResponses.isEmpty(), 'no contacts found');

			AW_CTRL_UpcomingClientBirthdays.DTO_Response dtoResponse = dtoResponses.iterator().next();

			Assert.areEqual(AW_CTRL_UpcomingClientBirthdays.TODAY_VALUE, dtoResponse.birthDate, 'incorrect date of birth');

			newAccount = AW_DAL_Account.findById(newAccount.Id);

			Assert.areEqual(newAccount.Name, dtoResponse.name, 'incorrect name');
		}
	}
	/**
	 * @description Check that business account contact has been found for logged in user
	 *
	 * @see AW_CTRL_UpcomingClientBirthdays.getClientUpcomingBirthdayDetails
	 */
	@IsTest
	private static void getBusinessUpcomingBirthdayDetails()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		System.runAs(adviser)
		{
			Date newDateInstance = Date.newInstance(1960, Date.today().month(), Date.today().day() + 2);

			Account newAccount = AW_DAL_TestDataFactory.createBusinessAccounts().iterator().next();
			Contact newContact = AW_DAL_TestDataFactory.createContact(newAccount.Id);
			newContact.Birthdate = newDateInstance;

			CMN_DAL_SObjectDomain.updateDBObject(newContact);

			Test.startTest();

			List<AW_CTRL_UpcomingClientBirthdays.DTO_Response> dtoResponses = AW_CTRL_UpcomingClientBirthdays.getClientUpcomingBirthdayDetails(adviser.Id);

			Test.stopTest();

			Assert.isFalse(dtoResponses.isEmpty(), 'no contacts found');

			AW_CTRL_UpcomingClientBirthdays.DTO_Response dtoResponse = dtoResponses.iterator().next();

			Assert.areEqual(CMN_UTIL_Date.dateToIso8601String(newDateInstance), dtoResponse.birthDate, 'incorrect date of birth');

			newContact = AW_DAL_Contact.findById(newContact.Id);
			Assert.areEqual(dtoResponse.turningToAge, newContact.AW_Age__c + 1, 'incorrect age');
		}
	}
	/**
	 * @description Check that person account contact has not found for logged in user
	 *
	 * @see AW_CTRL_UpcomingClientBirthdays.getClientUpcomingBirthdayDetails
	 */
	@IsTest
	private static void noUpcomingBirthdaysFound()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		System.runAs(adviser)
		{
			Account clientAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

			clientAccount.AW_IdentificationNumber__pc = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
			clientAccount.AW_IdentificationType__pc = AW_DAL_Account.PICK_PASSPORT_TYPE;
			clientAccount.AW_PassportCountryOfIssue__pc = AW_DAL_Country.findByName(AW_DAL_Country.UNITED_STATES).Id;
			clientAccount.PersonBirthdate = Date.newInstance(1960, Date.today().month(), Date.today().day() + 10);

			CMN_DAL_SObjectDomain.updateDBObject(clientAccount);

			Test.startTest();

			List<AW_CTRL_UpcomingClientBirthdays.DTO_Response> dtoResponses = AW_CTRL_UpcomingClientBirthdays.getClientUpcomingBirthdayDetails(adviser.Id);

			Test.stopTest();

			Assert.isTrue(dtoResponses.isEmpty(), 'expected no contacts to be found');
		}
	}

}