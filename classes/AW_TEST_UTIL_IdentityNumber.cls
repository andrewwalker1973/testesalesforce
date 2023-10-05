/**
 * @description Test Class for AW_UTIL_IdentityNumber
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_UTIL_IdentityNumber
{
	/**
	 * @description Test method is to test the Identity Number
	 */
	@IsTest
	private static void generateIdentityNumber()
	{
		Test.startTest();

		String identityNumber = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();

		Test.stopTest();

		System.assertEquals(AW_UTIL_IdentityNumber.IDENTITY_NUMBER_LENGTH, identityNumber.length(), AW_UTIL_IdentityNumber.ERROR_INVALID_LENGTH);
		System.assert(AW_UTIL_IdentityNumber.isValidIdentityNumber(identityNumber), AW_UTIL_IdentityNumber.ERROR_INVALID_ID);
	}

	/**
	 * @description Test method is to test DOB from Identity number
	 */
	@IsTest
	private static void extractDateOfBirthFromIdentityNumber()
	{
		String identityNumber = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();

		Test.startTest();

		Date birthDate = AW_UTIL_IdentityNumber.extractDateOfBirthFromIdentityNumber(identityNumber);

		Test.stopTest();

		System.assertNotEquals(null, birthDate, 'Date not extracted.');
	}

	/**
	 * @description Test method is to test the Century Id number
	 */
	@IsTest
	private static void extractCurrentCenturyDateOfBirthFromIdentityNumber()
	{
		String currentCenturyIdNumber = '0411013687081';

		Test.startTest();

		Date birthDate = AW_UTIL_IdentityNumber.extractDateOfBirthFromIdentityNumber(currentCenturyIdNumber);

		Test.stopTest();

		System.assert(birthDate.year() >= 2000, 'Year is not in the current Century');
	}

	/**
	 * @description Test method is to test the prior Century Id number
	 */
	@IsTest
	private static void extractPriorCenturyDateOfBirthFromIdentityNumber()
	{
		String priorCenturyIdNumber = '3512233070086';

		Test.startTest();

		Date birthDate = AW_UTIL_IdentityNumber.extractDateOfBirthFromIdentityNumber(priorCenturyIdNumber);

		Test.stopTest();

		System.assert(birthDate.year() < 2000, 'Year is not in the previous Century');
	}

	/**
	 * @description Test method is to test the prior Century Id number
	 */
	@IsTest
	private static void extractPriorCenturyDueToMonthDOBFromIdentityNumber()
	{

		Date today = Date.today();

		String currentYear = CMN_UTIL_String.mid(String.valueOf(today.year()), 2, 2);

		String currentMonth = String.valueOf(today.month());

		if(currentMonth.length() == 1)
		{
			currentMonth = '0' + currentMonth;
		}

		String currentDay = String.valueOf(today.day() + 1);

		if(currentDay.length() == 1)
		{
			currentDay = '0' + currentDay;
		}

		String identityNumber = currentYear + currentMonth + currentDay + '2258089';

		Test.startTest();

		Date birthDate = AW_UTIL_IdentityNumber.extractDateOfBirthFromIdentityNumber(identityNumber);

		Test.stopTest();

		System.assert(birthDate.year() < 2000, 'Year is not in the previous Century');
	}

	/**
	 * @description Test method is to test the gender
	 */
	@IsTest
	private static void checkGenderMale()
	{
		String identityNumberMale = '6809305236083';

		Test.startTest();

		Boolean isMale = AW_UTIL_IdentityNumber.isIdentityNumberGenderMale(identityNumberMale);

		Test.stopTest();

		System.assertEquals(true, isMale, 'Gender Incorrect');
	}

	/**
	 * @description Test method is to test the gender
	 */
	@IsTest
	private static void checkGenderTextMale()
	{
		String identityNumberMale = '6809305236083';

		Test.startTest();

		String genderText = AW_UTIL_IdentityNumber.getGenderFromIdentityNumber(identityNumberMale);

		Test.stopTest();

		System.assertEquals(AW_UTIL_IdentityNumber.IDENTITY_GENDER_MALE, genderText, 'Gender Incorrect');
	}

	/**
	 * @description Test method is to test the gender
	 */
	@IsTest
	private static void checkGenderFemale()
	{
		String identityNumberFemale = '2501030178086';

		Test.startTest();

		Boolean isMale = AW_UTIL_IdentityNumber.isIdentityNumberGenderMale(identityNumberFemale);

		Test.stopTest();

		System.assertEquals(false, isMale, 'Gender Incorrect');
	}

	/**
	 * @description Test method is to test the gender
	 */
	@IsTest
	private static void checkGenderTextFemale()
	{
		String identityNumberMale = '2501030178086';

		Test.startTest();

		String genderText = AW_UTIL_IdentityNumber.getGenderFromIdentityNumber(identityNumberMale);

		Test.stopTest();

		System.assertEquals(AW_UTIL_IdentityNumber.IDENTITY_GENDER_FEMALE, genderText, 'Gender Incorrect');
	}

	/**
	 * @description Test method is to test the gender
	 */
	@IsTest
	private static void checkGenderTextUndefined()
	{
		String identityNumberMale = '6809304236083';

		Test.startTest();

		String genderText = AW_UTIL_IdentityNumber.getGenderFromIdentityNumber(identityNumberMale);

		Test.stopTest();

		System.assertEquals(null, genderText, 'Gender Incorrect');
	}

	/**
	 * @description Test method is to test the Identity number
	 *
	 * @param identityNumber Identity Number
	 */
	private static void checkIdentityNumberInvalid(String identityNumber)
	{
		Test.startTest();

		System.assertEquals(false, AW_UTIL_IdentityNumber.isValidIdentityNumber(identityNumber), 'Identity Number was not found to be Invalid.');

		Test.stopTest();
	}

	@IsTest
	private static void identityNumberToShort()
	{
		checkIdentityNumberInvalid('680930523608');
	}

	@IsTest
	private static void identityNumberInvalid()
	{
		checkIdentityNumberInvalid('7610035029081');
	}

	@IsTest
	private static void identityNumberNoANumber()
	{
		checkIdentityNumberInvalid('aa09330523608');
	}

	@IsTest
	private static void identityNumberDateOfBirthInvalid()
	{
		checkIdentityNumberInvalid('5720080099086');
	}

	@IsTest
	private static void identityNumberValid()
	{
		Test.startTest();

		System.assertEquals(true, AW_UTIL_IdentityNumber.isValidIdentityNumber('7610035029080'), 'Identity Number was not found to be Valid.');

		Test.stopTest();
	}
}