/**
 * @description A class that has utility methods related to South African Identification Numbers
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_UTIL_IdentityNumber
{
	private static final Integer CHECK_SUM_ROUTINE_SWITCH = 10;
	private static final Integer CITIZENSHIP_SECTION_LENGTH = 1;
	private static final Integer CURRENT_CENTURY = 2000;
	@TestVisible
	private static final Integer GENDER_DIGIT_FEMALE = 4;
	@TestVisible
	private static final Integer GENDER_DIGIT_POSITION = 6;
	private static final Integer GENDER_SECTION_LENGTH = 4;
	private static final Integer PREVIOUS_CENTURY = 1900;
	private static final String DATE_FORMAT_PATTERN = 'yyMMdd';
	private static final String ERROR_INVALID_DATE = 'Invalid Date Format';
	@TestVisible
	private static final String ERROR_INVALID_ID = 'Invalid South African Id.';
	@TestVisible
	private static final String ERROR_INVALID_LENGTH = 'South African Id should contain 13 digits.';
	private static final String ERROR_NOT_NUMERIC = 'South African Id should contain numbers only.';
	private static final String STATIC_A_DIGIT = '8';
	public static final Integer IDENTITY_NUMBER_LENGTH = 13;
	public static final String IDENTITY_GENDER_FEMALE = 'Female';
	public static final String IDENTITY_GENDER_MALE = 'Male';

	private class IDValidationException extends Exception
	{
	}

	/**
	 * @description an RSA Identity number of 13 characters
	 *
	 * @return Random Identity Number
	 */
	public static String generateRandomIdentityNumber()
	{
		Datetime randomDateOfBirth = CMN_DAL_SObjectDomain.generateRandomDate();
		String randomGenderString = CMN_DAL_SObjectDomain.generateRandomNumber(GENDER_SECTION_LENGTH);
		String randomCitizenshipString = String.valueOf(Math.mod(CMN_DAL_SObjectDomain.generateRandomInteger(CITIZENSHIP_SECTION_LENGTH), 2));

		String twelveDigitIdentityNumber = randomDateOfBirth.format(DATE_FORMAT_PATTERN) + randomGenderString + randomCitizenshipString + STATIC_A_DIGIT;
		Integer checksumDigit = AW_UTIL_IdentityNumber.getChecksumDigit(twelveDigitIdentityNumber);
		return twelveDigitIdentityNumber + checksumDigit;
	}

	/**
	 * @description Will extract the Date of Birth from an Identity Number
	 *
	 * @param identityNumber Identity Number
	 *
	 * @return date
	 */
	public static Date extractDateOfBirthFromIdentityNumber(String identityNumber)
	{
		Date birthDate = null;

		if(String.isNotBlank(identityNumber) && identityNumber.length() == IDENTITY_NUMBER_LENGTH && CMN_UTIL_String.isNumeric(identityNumber))
		{
			Integer idYear = Integer.valueOf(CMN_UTIL_String.mid(identityNumber, 0, 2));
			Integer idMonth = Integer.valueOf(CMN_UTIL_String.mid(identityNumber, 2, 2));
			Integer idDay = Integer.valueOf(CMN_UTIL_String.mid(identityNumber, 4, 2));

			Date currentDate = Date.today();

			Integer currentYear = Integer.valueOf(CMN_UTIL_String.mid(String.valueOf(currentDate.year()), 2, 4));
			Integer currentDayInMonth = currentDate.day();
			Integer currentMonth = currentDate.month();

			if(idYear < currentYear)
			{
				idYear = CURRENT_CENTURY + idYear;
			}
			else if(idYear > currentYear)
			{
				idYear = PREVIOUS_CENTURY + idYear;
			}
			else
			{
				idYear = idMonth == currentMonth && idDay > currentDayInMonth ? PREVIOUS_CENTURY + idYear : CURRENT_CENTURY + idYear;
			}

			birthDate = Date.newInstance(idYear, idMonth, idDay);
		}

		return birthDate;
	}

	/**
	 * @description Method use to check the Identity number for Male gender
	 *
	 * @param identityNumber Identity Number
	 *
	 * @return boolean
	 */
	public static Boolean isIdentityNumberGenderMale(String identityNumber)
	{
		Boolean isMale;

		if(isValidIdentityNumber(identityNumber))
		{

			Integer genderDigit = Integer.valueOf(CMN_UTIL_String.mid(identityNumber, GENDER_DIGIT_POSITION, 1));
			isMale = genderDigit > GENDER_DIGIT_FEMALE;
		}

		return isMale;
	}

	/**
	 * @description Will generate gender text from RSA  Identification Number
	 *
	 * @param identityNumber Identity Number
	 *
	 * @return Gender as string
	 */
	public static String getGenderFromIdentityNumber(String identityNumber)
	{
		String gender;

		Boolean isMale = isIdentityNumberGenderMale(identityNumber);

		if(isMale != null)
		{
			gender = isMale ? IDENTITY_GENDER_MALE : IDENTITY_GENDER_FEMALE;
		}

		return gender;
	}

	/**
	 * @description Method use to check the Identity number
	 *
	 * @param identityNumber Identity Number
	 *
	 * @return A boolean flag to indicate if provided Identity number is valid or not
	 */
	public static Boolean isValidIdentityNumber(final String identityNumber)
	{
		try
		{
			validate(identityNumber);
			return true;
		}
		catch(Exception error)
		{
			return false;
		}
	}

	/**
	 * @description Comprehensive validation of RSA Identity Number, will throw exception if error detected
	 *
	 * @param identityNumber Identity number
	 */
	public static void validate(final String identityNumber)
	{
		//Check the Id number is the correct length
		if(CMN_UTIL_String.length((identityNumber)) != IDENTITY_NUMBER_LENGTH)
		{
			throw new IDValidationException(ERROR_INVALID_LENGTH);
		}

		if(!identityNumber.isNumeric())
		{
			throw new IDValidationException(ERROR_NOT_NUMERIC);
		}

		try
		{
			//Check if the ID Number is Passes Date Format
			Integer century = Integer.valueOf(identityNumber.substring(0, 2)) <= Integer.valueOf(String.valueOf(System.today().year()).substring(0, 2)) ? 20 : 19;
			Date.parse(century + identityNumber.substring(0, 2) + '/' + identityNumber.substring(2, 4) + '/' + identityNumber.substring(4, 6));
		}
		catch(Exception e)
		{
			throw new IDValidationException(ERROR_INVALID_DATE);
		}

		Integer indexLastCharacter = Integer.valueOf(identityNumber.mid(IDENTITY_NUMBER_LENGTH - 1, 1));
		Integer calculatedChecksumDigit = getChecksumDigit(identityNumber.left(IDENTITY_NUMBER_LENGTH - 1));
		Boolean isValid = indexLastCharacter == calculatedChecksumDigit;

		if(!isValid)
		{
			throw new IDValidationException(ERROR_INVALID_ID);
		}
	}

	/**
	 * @description Method to calculate the checksum digit for the first 12 digits of ID Number
	 *
	 * @param twelveDigitIdentityNumber First 12 digits of ID Number
	 *
	 * @return Checksum digit
	 */
	private static Integer getChecksumDigit(final String twelveDigitIdentityNumber)
	{
		Integer sumOfOddPositions = 0;

		for(Integer i = 0; i < IDENTITY_NUMBER_LENGTH - 1; i = i + 2)
		{
			sumOfOddPositions = sumOfOddPositions + Integer.valueOf(twelveDigitIdentityNumber.mid(i, 1));
		}

		String joined = CMN_UTIL_String.EMPTY;

		for(Integer i = 1; i < IDENTITY_NUMBER_LENGTH; i = i + 2)
		{
			joined = joined + twelveDigitIdentityNumber.mid(i, 1);
		}

		Integer sumOfEvenPositions = Integer.valueOf(joined);
		sumOfEvenPositions = sumOfEvenPositions * 2;
		String evenPosition = String.valueOf(sumOfEvenPositions);
		sumOfEvenPositions = 0;

		for(Integer i = 0; i < evenPosition.length(); i++)
		{
			sumOfEvenPositions = sumOfEvenPositions + Integer.valueOf(evenPosition.mid(i, 1));
		}

		Integer intCheckSum = sumOfOddPositions + sumOfEvenPositions;

		// Takes the result of odd and even numbers and mod's them by 10
		Integer sumModTen = Math.mod(intCheckSum, 10);

		Integer finalResult = 10 - sumModTen;

		return finalResult == CHECK_SUM_ROUTINE_SWITCH ? 0 : finalResult;
	}
}