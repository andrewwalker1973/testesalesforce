/**
 * @description This code is part of the "apex-lang" open-source project release 1.18 available at:
 * <p/>
 * http://code.google.com/p/apex-lang/
 * <p/>
 * Copyright (2012) richard van hook
 * <p/>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p/>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p/>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * <p/>
 * This project code has been forked and to update the latest salesforce APIs.
 *
 * @see CMN_UTIL_Random
 *
 * @author richard van hook prashant.k.jain@accenture.com jason.van.beukering@accenture.com
 *
 * @date January 2023
 */
@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity, PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_UTIL_Random_TEST
{
	private static final String ASSERT_MESSAGE_RANDOM = 'CMN_UTIL_Random.random(';
	private static final String ASSERT_MESSAGE_RANDOM_ALPHA = 'CMN_UTIL_Random.randomAlphabetic(';
	private static final String ASSERT_MESSAGE_RANDOM_ALPHA_NUM = 'CMN_UTIL_Random.randomAlphanumeric(';
	private static final String ASSERT_MESSAGE_RANDOM_ASCII = 'CMN_UTIL_Random.randomAscii(';
	private static final String ASSERT_MESSAGE_RANDOM_NUMERIC = 'CMN_UTIL_Random.randomNumeric(';
	private static final String ERROR_COMMA = ',\'';
	private static final String ERROR_EXPECTED = '\'; expected \'\'';
	private static final String ERROR_INVALID_NUMBER_OF_ITEMS = 'Invalid number of random items retrieved';
	private static final String ERROR_NON_ASCII_CHARS = '\' (unexpected non-ascii characters present)';
	private static final String ERROR_NON_NUMERIC_CHARS = '\' (unexpected non-numeric characters present)';
	private static final String ERROR_QUOTE = '\'';
	private static final String ERROR_RETURNED = ') returned \'';
	private static final String ERROR_RETURNED_2 = '\') returned \'';
	private static final String ERROR_UNEXPECTED_ALPHA = '\' (unexpected non-alphanumeric characters present)';
	private static final String ERROR_UNEXPECTED_CHARS = '\' (unexpected characters present)';
	private static final String ERROR_UNEXPECTED_LENGTH = '\' (unexpected length)';
	private static final String ERROR_UNEXPECTED_NON_ALPHA = '\' (unexpected non-alpha characters present)';
	private static final String ERROR_UNEXPECTED_NON_ASCII = '\' (unexpected non-ascii printable characters present)';
	private static final String ERROR_VALUE_NOT_EXPECTED = 'Value not as expected.';

	@IsTest
	private static void nextBoolean()
	{
		Assert.isNotNull(CMN_UTIL_Random.nextBoolean(), ERROR_VALUE_NOT_EXPECTED);
	}

	@IsTest
	private static void nextInteger()
	{
		assertNextInteger(CMN_UTIL_Number.MAX_INTEGER_RANGE, true, CMN_UTIL_Random.nextInteger());
	}

	@IsTest
	private static void nextTwoInteger()
	{
		CMN_UTIL_NumberRange.IntegerRange inputRange = null;
		for(Integer i = -2; i <= 2; i++)
		{
			inputRange = new CMN_UTIL_NumberRange.IntegerRange(0, Math.abs(i));
			assertNextInteger(inputRange, true, CMN_UTIL_Random.nextInteger(i));
		}
	}

	@IsTest
	private static void nextTwoIntegerBoolean()
	{
		CMN_UTIL_NumberRange.IntegerRange inputRange = null;
		for(Integer i = -2; i <= 2; i++)
		{
			inputRange = new CMN_UTIL_NumberRange.IntegerRange(0, Math.abs(i));
			assertNextInteger(inputRange, true, CMN_UTIL_Random.nextInteger(i, true));
			assertNextInteger(inputRange, false, CMN_UTIL_Random.nextInteger(i, false));
		}
	}

	@IsTest
	private static void nextThreeInteger()
	{
		CMN_UTIL_NumberRange.IntegerRange inputRange = null;
		for(Integer i = -2; i <= 2; i++)
		{
			for(Integer j = -2; j <= 2; j++)
			{
				inputRange = new CMN_UTIL_NumberRange.IntegerRange(i, j);
				assertNextInteger(inputRange, true, CMN_UTIL_Random.nextInteger(i, j));
			}
		}
	}

	@IsTest
	private static void nextThreeIntegerBoolean()
	{
		CMN_UTIL_NumberRange.IntegerRange inputRange = null;
		for(Integer i = -2; i <= 2; i++)
		{
			for(Integer j = -2; j <= 2; j++)
			{
				inputRange = new CMN_UTIL_NumberRange.IntegerRange(i, j);
				assertNextInteger(inputRange, true, CMN_UTIL_Random.nextInteger(i, j, true));
				assertNextInteger(inputRange, false, CMN_UTIL_Random.nextInteger(i, j, false));
			}
		}
	}

	@IsTest
	private static void nextIntegerRange()
	{
		CMN_UTIL_NumberRange.IntegerRange inputRange = null;
		for(Integer i = -2; i <= 2; i++)
		{
			for(Integer j = -2; j <= 2; j++)
			{
				inputRange = new CMN_UTIL_NumberRange.IntegerRange(i, j);
				assertNextInteger(inputRange, true, CMN_UTIL_Random.nextInteger(inputRange));
			}
		}
	}

	@IsTest
	private static void nextIntegerRangeBoolean()
	{
		CMN_UTIL_NumberRange.IntegerRange inputRange = null;
		for(Integer i = -2; i <= 2; i++)
		{
			for(Integer j = -2; j <= 2; j++)
			{
				inputRange = new CMN_UTIL_NumberRange.IntegerRange(i, j);
				assertNextInteger(inputRange, true, CMN_UTIL_Random.nextInteger(inputRange, true));
				assertNextInteger(inputRange, false, CMN_UTIL_Random.nextInteger(inputRange, false));
			}
		}
	}

	@IsTest
	private static void nextIntegerRangeBooleanNull()
	{
		final CMN_UTIL_NumberRange.IntegerRange nullRange = null;
		Assert.isNull(CMN_UTIL_Random.nextInteger(nullRange, true), ERROR_VALUE_NOT_EXPECTED);
	}

	private static void assertNextInteger(CMN_UTIL_NumberRange.IntegerRange inputRange, Boolean inclusive, Integer actual)
	{
		CMN_UTIL_NumberRange.IntegerRange acceptableRange = null;
		if(!inclusive && (inputRange.max() - inputRange.min()) <= 2)
		{
			acceptableRange = new CMN_UTIL_NumberRange.IntegerRange(inputRange.min(), inputRange.min());
		}
		else
		{
			Integer inclusiveChange = 1;
			if(inclusive)
			{
				inclusiveChange = 0;
			}
			acceptableRange = new CMN_UTIL_NumberRange.IntegerRange(
					(Integer)inputRange.min() - inclusiveChange
					, (Integer)inputRange.max() - inclusiveChange
			);
		}
		Assert.isTrue(
				acceptableRange.contains(actual),
				'CMN_UTIL_Random.nextInteger(' + inputRange.toArrayString() + CMN_UTIL_String.COMMA + inclusive + ') returned ' + actual);
	}

	@IsTest
	private static void nextLong()
	{
		assertNextLong(CMN_UTIL_Number.MAX_LONG_RANGE, true, CMN_UTIL_Random.nextLong());
	}

	@IsTest
	private static void nextTwoLong()
	{
		CMN_UTIL_NumberRange.LongRange inputRange = null;
		for(Long i = -2; i <= 2; i++)
		{
			inputRange = new CMN_UTIL_NumberRange.LongRange(0, Math.abs(i));
			assertNextLong(inputRange, true, CMN_UTIL_Random.nextLong(i));
		}
	}

	@IsTest
	private static void nextTwoLongBoolean()
	{
		CMN_UTIL_NumberRange.LongRange inputRange = null;
		for(Long i = -2; i <= 2; i++)
		{
			inputRange = new CMN_UTIL_NumberRange.LongRange(0, Math.abs(i));
			assertNextLong(inputRange, true, CMN_UTIL_Random.nextLong(i, true));
			assertNextLong(inputRange, false, CMN_UTIL_Random.nextLong(i, false));
		}
	}

	@IsTest
	private static void nextThreeLong()
	{
		CMN_UTIL_NumberRange.LongRange inputRange = null;
		for(Long i = -2; i <= 2; i++)
		{
			for(Long j = -2; j <= 2; j++)
			{
				inputRange = new CMN_UTIL_NumberRange.LongRange(i, j);
				assertNextLong(inputRange, true, CMN_UTIL_Random.nextLong(i, j));
			}
		}
	}

	@IsTest
	private static void nextThreeLongBoolean()
	{
		CMN_UTIL_NumberRange.LongRange inputRange = null;
		for(Long i = -2; i <= 2; i++)
		{
			for(Long j = -2; j <= 2; j++)
			{
				inputRange = new CMN_UTIL_NumberRange.LongRange(i, j);
				assertNextLong(inputRange, true, CMN_UTIL_Random.nextLong(i, j, true));
				assertNextLong(inputRange, false, CMN_UTIL_Random.nextLong(i, j, false));
			}
		}
	}

	@IsTest
	private static void nextLongRange()
	{
		CMN_UTIL_NumberRange.LongRange inputRange = null;
		for(Long i = -2; i <= 2; i++)
		{
			for(Long j = -2; j <= 2; j++)
			{
				inputRange = new CMN_UTIL_NumberRange.LongRange(i, j);
				assertNextLong(inputRange, true, CMN_UTIL_Random.nextLong(inputRange));
			}
		}
	}

	@IsTest
	private static void nextLongRangeBoolean()
	{
		CMN_UTIL_NumberRange.LongRange inputRange = null;
		for(Long i = -2; i <= 2; i++)
		{
			for(Long j = -2; j <= 2; j++)
			{
				inputRange = new CMN_UTIL_NumberRange.LongRange(i, j);
				assertNextLong(inputRange, true, CMN_UTIL_Random.nextLong(inputRange, true));
				assertNextLong(inputRange, false, CMN_UTIL_Random.nextLong(inputRange, false));
			}
		}
	}

	@IsTest
	private static void nextLongRangeBooleanNull()
	{
		final CMN_UTIL_NumberRange.LongRange nullRange = null;
		Assert.isNull(CMN_UTIL_Random.nextLong(nullRange, true), ERROR_VALUE_NOT_EXPECTED);
	}

	private static void assertNextLong(CMN_UTIL_NumberRange.LongRange inputRange, Boolean inclusive, Long actual)
	{
		CMN_UTIL_NumberRange.LongRange acceptableRange = null;
		if(!inclusive && (inputRange.max() - inputRange.min()) <= 2)
		{
			acceptableRange = new CMN_UTIL_NumberRange.LongRange(inputRange.min(), inputRange.min());
		}
		else
		{
			Integer inclusiveChange = 1;
			if(inclusive)
			{
				inclusiveChange = 0;
			}

			acceptableRange = new CMN_UTIL_NumberRange.LongRange(
					inputRange.min() - inclusiveChange
					, inputRange.max() - inclusiveChange
			);
		}
		Assert.isTrue(acceptableRange.contains(actual),
				'CMN_UTIL_Random.nextLong(' + inputRange.toArrayString() + CMN_UTIL_String.COMMA + inclusive + ') returned ' + actual);
	}

	@IsTest
	private static void random()
	{
		for(Integer i = -5; i < 5; i++)
		{
			assertRandom(i);
		}
	}

	private static void assertRandom(Integer count)
	{
		String actual = CMN_UTIL_Random.random(count);

		if(count < 0)
		{
			Assert.isTrue(String.isBlank(actual), ASSERT_MESSAGE_RANDOM + count + ERROR_RETURNED + actual + ERROR_EXPECTED);
		}
		else
		{
			Assert.areEqual(count, CMN_UTIL_String.length(actual), ASSERT_MESSAGE_RANDOM + count
					+ ERROR_RETURNED + actual + ERROR_UNEXPECTED_LENGTH);
			Assert.isTrue(CMN_UTIL_String.isAsciiPrintable(actual), ASSERT_MESSAGE_RANDOM + count
					+ ERROR_RETURNED + actual + ERROR_NON_ASCII_CHARS);
		}
	}

	@IsTest
	private static void randomAscii()
	{
		for(Integer i = -5; i < 5; i++)
		{
			assertRandomAscii(i);
		}
	}

	private static void assertRandomAscii(Integer count)
	{
		String actual = CMN_UTIL_Random.randomAscii(count);
		if(count < 0)
		{
			Assert.isTrue(String.isBlank(actual), ASSERT_MESSAGE_RANDOM_ASCII + count
					+ ERROR_RETURNED + actual + ERROR_EXPECTED);
		}
		else
		{
			Assert.areEqual(count, CMN_UTIL_String.length(actual), ASSERT_MESSAGE_RANDOM_ASCII + count
					+ ERROR_RETURNED + actual + ERROR_UNEXPECTED_LENGTH);
			Assert.isTrue(CMN_UTIL_String.isAsciiPrintable(actual), ASSERT_MESSAGE_RANDOM_ASCII + count
					+ ERROR_RETURNED + actual + ERROR_NON_ASCII_CHARS);
		}
	}

	@IsTest
	private static void randomAlphabetic()
	{
		for(Integer i = -5; i < 5; i++)
		{
			assertRandomAlphabetic(i);
		}
	}

	private static void assertRandomAlphabetic(Integer count)
	{
		String actual = CMN_UTIL_Random.randomAlphabetic(count);
		if(count < 0)
		{
			Assert.isTrue(String.isBlank(actual), ASSERT_MESSAGE_RANDOM_ALPHA + count
					+ ERROR_RETURNED + actual + ERROR_EXPECTED);
		}
		else
		{
			Assert.areEqual(count, CMN_UTIL_String.length(actual), ASSERT_MESSAGE_RANDOM_ALPHA + count
					+ ERROR_RETURNED + actual + ERROR_UNEXPECTED_LENGTH);
			Assert.isTrue(CMN_UTIL_String.isAlpha(actual), ASSERT_MESSAGE_RANDOM_ALPHA + count
			+ ERROR_RETURNED + actual + '\' (unexpected non-alphabetic characters present)');
		}
	}

	/**
	 * @description Test the generation of random alphanumeric string
	 *
	 * @see CMN_UTIL_Random.randomAlphanumeric
	 */
	@IsTest
	private static void randomAlphanumeric()
	{
		for(Integer numberOfCharacters = -1; numberOfCharacters < 2; numberOfCharacters++)
		{
			String actual = CMN_UTIL_Random.randomAlphanumeric(numberOfCharacters);
			if(numberOfCharacters < 0)
			{
				Assert.isTrue(String.isBlank(actual), ASSERT_MESSAGE_RANDOM_ALPHA_NUM + numberOfCharacters + ERROR_RETURNED + actual + ERROR_EXPECTED);
			}
			else
			{
				Assert.areEqual(numberOfCharacters, CMN_UTIL_String.length(actual), ASSERT_MESSAGE_RANDOM_ALPHA_NUM + numberOfCharacters + ERROR_RETURNED + actual + ERROR_UNEXPECTED_LENGTH);
				Assert.isTrue(CMN_UTIL_String.isAlphanumeric(actual), ASSERT_MESSAGE_RANDOM_ALPHA_NUM + numberOfCharacters + ERROR_RETURNED + actual + ERROR_UNEXPECTED_ALPHA);
			}
		}
	}

	/**
	 * @description tests random number generator
	 *
	 * @see CMN_UTIL_Random.randomNumeric
	 */
	@IsTest
	private static void randomNumeric()
	{
		//Check both above and below zero
		for(Integer numberOfDigits = -1; numberOfDigits < 2; numberOfDigits++)
		{
			String actual = CMN_UTIL_Random.randomNumeric(numberOfDigits);

			//A number must have more than 0 digits
			if(numberOfDigits <= 0)
			{
				Assert.isTrue(String.isBlank(actual), ASSERT_MESSAGE_RANDOM_NUMERIC + numberOfDigits + ERROR_RETURNED + actual + ERROR_EXPECTED);
			}
			else
			{
				Assert.areEqual(numberOfDigits, CMN_UTIL_String.length(actual), ASSERT_MESSAGE_RANDOM_NUMERIC + numberOfDigits + ERROR_RETURNED + actual + ERROR_UNEXPECTED_LENGTH);
				Assert.isTrue(CMN_UTIL_String.isNumeric(actual), ASSERT_MESSAGE_RANDOM_NUMERIC + numberOfDigits + ERROR_RETURNED + actual + ERROR_NON_NUMERIC_CHARS);
			}
		}
	}

	@IsTest
	private static void randomTwoArgs()
	{
		for(Integer i = -1; i < 2; i++)
		{
			assertRandomTwoArgs(i, 'abc');
		}
		for(Integer i = -1; i < 2; i++)
		{
			assertRandomTwoArgs(i, '4938%(#*@x)');
		}
	}

	private static void assertRandomTwoArgs(Integer count, String chars)
	{
		String actual = CMN_UTIL_Random.random(count, chars);
		if(count <= 0)
		{
			Assert.isTrue(String.isBlank(actual), ASSERT_MESSAGE_RANDOM + count + ERROR_COMMA + chars + ERROR_RETURNED_2 + actual + ERROR_QUOTE);
		}
		else
		{
			Assert.areEqual(count, CMN_UTIL_String.length(actual), ASSERT_MESSAGE_RANDOM + count + ERROR_COMMA + chars + ERROR_RETURNED_2 + actual + ERROR_UNEXPECTED_LENGTH);
			Assert.isTrue(CMN_UTIL_String.containsOnly(actual, chars), ASSERT_MESSAGE_RANDOM + count + ERROR_COMMA + chars + ERROR_RETURNED_2 + actual + ERROR_UNEXPECTED_CHARS);
		}
	}

	@IsTest
	private static void randomThreeArgs()
	{
		for(Integer i = -1; i < 5; i++)
		{
			for(Integer j = 0; j < 4; j++)
			{
				assertRandomThreeArgs(i, Math.mod(Math.round(j / 2), 2) == 1, Math.mod(j, 2) == 1);
			}
		}
	}

	@SuppressWarnings('PMD.CyclomaticComplexity')
	private static void assertRandomThreeArgs(Integer count, Boolean letters, Boolean numbers)
	{
		String actual = CMN_UTIL_Random.random(count, letters, numbers);
		if(count <= 0)
		{
			Assert.isTrue(String.isBlank(actual), ASSERT_MESSAGE_RANDOM + count
					+ CMN_UTIL_String.COMMA + letters + CMN_UTIL_String.COMMA + numbers + ERROR_RETURNED + actual + ERROR_QUOTE);
		}
		else
		{
			Assert.areEqual(count, CMN_UTIL_String.length(actual), ASSERT_MESSAGE_RANDOM + count
					+ CMN_UTIL_String.COMMA + letters + CMN_UTIL_String.COMMA + numbers + ERROR_RETURNED + actual + ERROR_UNEXPECTED_LENGTH);
			if(!letters && !numbers)
			{
				Assert.isTrue(CMN_UTIL_String.isAsciiPrintable(actual), ASSERT_MESSAGE_RANDOM + count
						+ CMN_UTIL_String.COMMA + letters + CMN_UTIL_String.COMMA + numbers + ERROR_RETURNED + actual + ERROR_UNEXPECTED_NON_ASCII);
			}
			else if(!letters && numbers)
			{
				Assert.isTrue(CMN_UTIL_String.isNumeric(actual), ASSERT_MESSAGE_RANDOM + count
						+ CMN_UTIL_String.COMMA + letters + CMN_UTIL_String.COMMA + numbers + ERROR_RETURNED + actual + ERROR_NON_NUMERIC_CHARS);
			}
			else if(letters && !numbers)
			{
				Assert.isTrue(CMN_UTIL_String.isAlpha(actual), ASSERT_MESSAGE_RANDOM + count
						+ CMN_UTIL_String.COMMA + letters + CMN_UTIL_String.COMMA + numbers + ERROR_RETURNED + actual + ERROR_UNEXPECTED_NON_ALPHA);
			}
			else if(letters && numbers)
			{
				Assert.isTrue(CMN_UTIL_String.isAlphanumeric(actual), ASSERT_MESSAGE_RANDOM + count
						+ CMN_UTIL_String.COMMA + letters + CMN_UTIL_String.COMMA + numbers + ERROR_RETURNED + actual + ERROR_UNEXPECTED_ALPHA);
			}
		}
	}

	@IsTest
	private static void randomFiveArgs()
	{
		for(Integer i = -1; i < 2; i++)
		{
			for(Integer j = 0; j < 4; j++)
			{
				assertRandomFiveArgs(i, -1, 0, Math.mod(Math.round(j / 2), 2) == 1, Math.mod(j, 2) == 1);
				assertRandomFiveArgs(i, 0, 4, Math.mod(Math.round(j / 2), 2) == 1, Math.mod(j, 2) == 1);
				assertRandomFiveArgs(i, 2, 10, Math.mod(Math.round(j / 2), 2) == 1, Math.mod(j, 2) == 1);
				assertRandomFiveArgs(i, 2, 1000, Math.mod(Math.round(j / 2), 2) == 1, Math.mod(j, 2) == 1);
			}
		}
	}

	@SuppressWarnings('PMD.CyclomaticComplexity,PMD.ExcessiveParameterList')
	private static void assertRandomFiveArgs(Integer count, Integer startIndex, Integer endIndex, Boolean letters, Boolean numbers)
	{
		String actual = CMN_UTIL_Random.random(count, startIndex, endIndex, letters, numbers);

		if(count <= 0)
		{
			Assert.isTrue
					(
							String.isBlank(actual),
							ASSERT_MESSAGE_RANDOM + count + CMN_UTIL_String.COMMA + startIndex + CMN_UTIL_String.COMMA + endIndex + CMN_UTIL_String.COMMA
									+ letters + CMN_UTIL_String.COMMA + numbers + ERROR_RETURNED + actual + ERROR_QUOTE
					);
		}
		else
		{
			Assert.areEqual(count, CMN_UTIL_String.length(actual), ASSERT_MESSAGE_RANDOM + count
					+ CMN_UTIL_String.COMMA + startIndex + CMN_UTIL_String.COMMA + endIndex + CMN_UTIL_String.COMMA + letters +
					CMN_UTIL_String.COMMA + numbers + ERROR_RETURNED + actual + ERROR_UNEXPECTED_LENGTH);

			if(!letters && !numbers)
			{
				Assert.isTrue
						(
								CMN_UTIL_String.isAsciiPrintable(actual),
								ASSERT_MESSAGE_RANDOM + count + CMN_UTIL_String.COMMA + startIndex + CMN_UTIL_String.COMMA + endIndex +
										CMN_UTIL_String.COMMA + letters + CMN_UTIL_String.COMMA + numbers + ERROR_RETURNED + actual + ERROR_UNEXPECTED_NON_ASCII
						);
			}
			else if(!letters && numbers)
			{
				Assert.isTrue(CMN_UTIL_String.isNumeric(actual), ASSERT_MESSAGE_RANDOM + count
						+ CMN_UTIL_String.COMMA + startIndex + CMN_UTIL_String.COMMA + endIndex + CMN_UTIL_String.COMMA + letters +
						CMN_UTIL_String.COMMA + numbers + ERROR_RETURNED + actual + ERROR_NON_NUMERIC_CHARS);
			}
			else if(letters && !numbers)
			{
				Assert.isTrue(CMN_UTIL_String.isAlpha(actual), ASSERT_MESSAGE_RANDOM + count
						+ CMN_UTIL_String.COMMA + startIndex + CMN_UTIL_String.COMMA + endIndex + CMN_UTIL_String.COMMA + letters +
						CMN_UTIL_String.COMMA + numbers + ERROR_RETURNED + actual + ERROR_UNEXPECTED_NON_ALPHA);
			}
			else if(letters && numbers)
			{
				Assert.isTrue(CMN_UTIL_String.isAlphanumeric(actual), ASSERT_MESSAGE_RANDOM + count
						+ CMN_UTIL_String.COMMA + startIndex + CMN_UTIL_String.COMMA + endIndex + CMN_UTIL_String.COMMA + letters +
						CMN_UTIL_String.COMMA + numbers + ERROR_RETURNED + actual + ERROR_UNEXPECTED_ALPHA);
			}
		}
	}

	@IsTest
	private static void randomSixArgs()
	{
		for(Integer i = -1; i < 2; i++)
		{
			for(Integer j = 0; j < 4; j++)
			{
				assertRandomSixArgs(i, -1, 0, Math.mod(Math.round(j / 2), 2) == 1, Math.mod(j, 2) == 1, null);
				assertRandomSixArgs(i, 0, 4, Math.mod(Math.round(j / 2), 2) == 1, Math.mod(j, 2) == 1, null);
				assertRandomSixArgs(i, 2, 10, Math.mod(Math.round(j / 2), 2) == 1, Math.mod(j, 2) == 1, null);
				assertRandomSixArgs(i, 2, 1000, Math.mod(Math.round(j / 2), 2) == 1, Math.mod(j, 2) == 1, null);
				assertRandomSixArgs(i, -1, 0, Math.mod(Math.round(j / 2), 2) == 1, Math.mod(j, 2) == 1, 'abc$8532(*)');
				assertRandomSixArgs(i, 0, 4, Math.mod(Math.round(j / 2), 2) == 1, Math.mod(j, 2) == 1, 'abc$8532(*)');
				assertRandomSixArgs(i, 2, 10, Math.mod(Math.round(j / 2), 2) == 1, Math.mod(j, 2) == 1, 'abc$8532(*)');
				assertRandomSixArgs(i, 2, 1000, Math.mod(Math.round(j / 2), 2) == 1, Math.mod(j, 2) == 1, 'abc$8532(*)');
			}
		}
	}

	@SuppressWarnings('PMD.CyclomaticComplexity, PMD.CognitiveComplexity, PMD.ExcessiveParameterList')
	private static void assertRandomSixArgs(Integer count, Integer startIndex, Integer endIndex, Boolean letters, Boolean numbers, String chars)
	{
		String actual = CMN_UTIL_Random.random(count, startIndex, endIndex, letters, numbers, chars);
		if(count <= 0)
		{
			Assert.isTrue(String.isBlank(actual), ASSERT_MESSAGE_RANDOM + count
					+ CMN_UTIL_String.COMMA + startIndex + CMN_UTIL_String.COMMA + endIndex + CMN_UTIL_String.COMMA + letters +
					CMN_UTIL_String.COMMA + numbers + ERROR_COMMA + chars + ERROR_RETURNED_2 + actual + ERROR_QUOTE);
		}
		else
		{
			if(chars == null)
			{
				Assert.areEqual(count, CMN_UTIL_String.length(actual), ASSERT_MESSAGE_RANDOM + count
						+ CMN_UTIL_String.COMMA + startIndex + CMN_UTIL_String.COMMA + endIndex + CMN_UTIL_String.COMMA + letters +
						CMN_UTIL_String.COMMA + numbers + ERROR_COMMA + chars + ERROR_RETURNED_2 + actual + ERROR_UNEXPECTED_LENGTH);
				if(!letters && !numbers)
				{
					Assert.isTrue
							(
									CMN_UTIL_String.isAsciiPrintable(actual),
									ASSERT_MESSAGE_RANDOM + count + CMN_UTIL_String.COMMA + startIndex + CMN_UTIL_String.COMMA + endIndex +
											CMN_UTIL_String.COMMA + letters + CMN_UTIL_String.COMMA + numbers + ERROR_COMMA + chars + ERROR_RETURNED_2 + actual
											+ ERROR_UNEXPECTED_NON_ASCII
							);
				}
				else if(!letters && numbers)
				{
					Assert.isTrue
							(
									CMN_UTIL_String.isNumeric(actual),
									ASSERT_MESSAGE_RANDOM + count + CMN_UTIL_String.COMMA + startIndex + CMN_UTIL_String.COMMA + endIndex +
											CMN_UTIL_String.COMMA + letters + CMN_UTIL_String.COMMA + numbers + ERROR_COMMA + chars + ERROR_RETURNED_2 + actual
											+ ERROR_NON_NUMERIC_CHARS
							);
				}
				else if(letters && !numbers)
				{
					Assert.isTrue
							(
									CMN_UTIL_String.isAlpha(actual),
									ASSERT_MESSAGE_RANDOM + count + CMN_UTIL_String.COMMA + startIndex + CMN_UTIL_String.COMMA + endIndex +
											CMN_UTIL_String.COMMA + letters + CMN_UTIL_String.COMMA + numbers + ERROR_COMMA + chars + ERROR_RETURNED_2 + actual
											+ ERROR_UNEXPECTED_NON_ALPHA
							);
				}
				else if(letters && numbers)
				{
					Assert.isTrue
							(
									CMN_UTIL_String.isAlphanumeric(actual),
									ASSERT_MESSAGE_RANDOM + count + CMN_UTIL_String.COMMA + startIndex + CMN_UTIL_String.COMMA + endIndex +
											CMN_UTIL_String.COMMA + letters + CMN_UTIL_String.COMMA + numbers + ERROR_COMMA + chars + ERROR_RETURNED_2 + actual
											+ ERROR_UNEXPECTED_ALPHA
							);
				}
			}
			else
			{
				Assert.isTrue(CMN_UTIL_String.containsOnly(actual, chars), ASSERT_MESSAGE_RANDOM + count
						+ CMN_UTIL_String.COMMA + startIndex + CMN_UTIL_String.COMMA + endIndex + CMN_UTIL_String.COMMA + letters +
						CMN_UTIL_String.COMMA + numbers + ERROR_COMMA + chars + ERROR_RETURNED_2 + actual + ERROR_UNEXPECTED_CHARS);
			}
		}
	}

	/**
	 * @description Check that UUID is correctly generated and unique
	 *
	 * @see CMN_UTIL_Random.randomUUID
	 */
	@IsTest
	private static void randomUUID()
	{
		String actual = CMN_UTIL_Random.randomUUID();
		Assert.isNotNull(actual, ERROR_VALUE_NOT_EXPECTED);
		Assert.areEqual(36, actual.length(), ERROR_VALUE_NOT_EXPECTED);
		Assert.isTrue(CMN_UTIL_String.containsOnly(actual, '01234567890abcdef-'), 'The following UUID contains invalid characters: ' + actual);
		String comparison = CMN_UTIL_Random.randomUUID();
		Assert.areNotEqual(actual, comparison, 'Non unique UUID generated.');
	}

	/**
	 * @description Checks that random Id is correctly generated and is random
	 *
	 * @see CMN_UTIL_Random.getRandomId
	 */
	@IsTest
	private static void getRandomId()
	{
		String actual = CMN_UTIL_Random.getRandomId(CMN_Foobar__c.SObjectType);
		Assert.isNotNull(actual, ERROR_VALUE_NOT_EXPECTED);
		Assert.areEqual(18, actual.length(), ERROR_VALUE_NOT_EXPECTED);
		String comparison = CMN_UTIL_Random.getRandomId(CMN_Foobar__c.SObjectType);
		Assert.areNotEqual(actual, comparison, 'Non unique Id generated.');
	}

	/**
	 * @description Tests utility function to return a Random Item from an SObject list
	 * It will also test the getRandomIndex method as this is used by getRandomItem
	 *
	 * @see CMN_UTIL_Random.getRandomIndex
	 * @see CMN_UTIL_Random.getRandomItem
	 */
	@IsTest
	private static void getRandomItem()
	{
		final Integer numberOfItemsToCreate = 8;

		List<CMN_Foobar__c> newFoobars = CMN_DAL_DataFactory.newFoobars(numberOfItemsToCreate);

		Test.startTest();

		String referenceFoobarName = ((CMN_Foobar__c)CMN_UTIL_Random.getRandomItem(newFoobars)).Name;
		Boolean randomBehaviorFound = false;

		for(Integer i = 1; i < numberOfItemsToCreate; i++)
		{
			String currentFoobarName = ((CMN_Foobar__c)CMN_UTIL_Random.getRandomItem(newFoobars)).Name;

			if(!CMN_UTIL_String.equalsIgnoreCase(referenceFoobarName, currentFoobarName))
			{
				randomBehaviorFound = true;
				break;
			}
		}

		Test.stopTest();

		Assert.isTrue(randomBehaviorFound, 'Same items was retrieved, instead of Random ones');
	}

	/**
	 * @description Tests utility function to return a number of randomItems from a list
	 *
	 * @see CMN_UTIL_Random.getRandomItems
	 */
	@IsTest
	private static void getRandomItems()
	{
		final Integer numberOfItemsToCreate = 100;

		List<CMN_Foobar__c> newFoobars = CMN_DAL_DataFactory.newFoobars(numberOfItemsToCreate);

		Test.startTest();

		final Integer numberOfRandomItems = 3;
		List<SObject> randomItems = CMN_UTIL_Random.getRandomItems(newFoobars, numberOfRandomItems);

		Test.stopTest();

		Assert.areEqual(numberOfRandomItems, randomItems.size(), ERROR_INVALID_NUMBER_OF_ITEMS);
	}

	/**
	 * @description Tests utility function to return a number of randomItems from a list wit smaller number
	 *
	 * @see CMN_UTIL_Random.getRandomItems
	 */
	@IsTest
	private static void getRandomItemsWithSmallList()
	{
		final Integer numberOfItemsToCreate = 3;

		List<CMN_Foobar__c> newFoobars = CMN_DAL_DataFactory.newFoobars(numberOfItemsToCreate);

		Test.startTest();

		final Integer numberOfRandomItems = numberOfItemsToCreate + 1;
		List<SObject> randomItems = CMN_UTIL_Random.getRandomItems(newFoobars, numberOfRandomItems);

		Test.stopTest();

		Assert.areEqual(numberOfItemsToCreate, randomItems.size(), ERROR_INVALID_NUMBER_OF_ITEMS);
	}

	/**
	 * @description Tests utility function to return a number of randomItems from a list wit smaller number
	 *
	 * @see CMN_UTIL_Random.getRandomItems
	 */
	@IsTest
	private static void getRandomItemsWithNullList()
	{
		Test.startTest();

		final Integer numberOfRandomItems = 1;
		List<SObject> randomItems = CMN_UTIL_Random.getRandomItems(null, numberOfRandomItems);

		Test.stopTest();

		Assert.areEqual(numberOfRandomItems - 1, randomItems.size(), ERROR_INVALID_NUMBER_OF_ITEMS);
	}

	/**
	 * @description Tests utility function to return zero random Items when zero items are requested
	 *
	 * @see CMN_UTIL_Random.getRandomItems
	 */
	@IsTest
	private static void getZeroRandomItems()
	{
		List<CMN_Foobar__c> newFoobars = new List<CMN_Foobar__c> {CMN_DAL_DataFactory.newFoobar()};
		final Integer numberOfRandomItems = 0;

		Test.startTest();
		List<SObject> randomItems = CMN_UTIL_Random.getRandomItems(newFoobars, numberOfRandomItems);
		Test.stopTest();

		Assert.isTrue(randomItems.isEmpty(), ERROR_INVALID_NUMBER_OF_ITEMS);
	}
}