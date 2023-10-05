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
 * <p/>
 * <p>Utility library that supplements the standard {@link Math} class.</p>
 * <p/>
 * <p>Caveat: Instances of {@link Math} are not cryptographically secure.</p>
 * <p/>
 * <p>Please note that the Apache Commons project provides a component
 * dedicated to pseudo-random number generation, namely
 * <a href="https://commons.apache.org/rng">Commons RNG</a>, that may be
 * a better choice for applications with more stringent requirements
 * (performance and/or correctness).</p>
 * <p/>
 * <p>Operations for random {@code String}s.</p>
 * <p>Currently <em>private high surrogate</em> characters are ignored.
 * These are Unicode characters that fall between the values 56192 (db80)
 * and 56319 (dbff) as we don't know how to handle them.
 * High and low surrogates are correctly dealt with - that is if a
 * high surrogate is randomly chosen, 55296 (d800) to 56191 (db7f)
 * then it is followed by a low surrogate. If a low surrogate is chosen,
 * 56320 (dc00) to 57343 (dfff) then it is placed after a randomly
 * chosen high surrogate.</p>
 * <p>CMN_UTIL_Random is intended for simple use cases. For more advanced
 * use cases consider using commons-text
 * <a href="https://commons.apache.org/proper/commons-text/javadocs/api-release/org/apache/commons/text/RandomStringGenerator.html">
 * RandomStringGenerator</a> instead.</p>
 * <p/>
 * <p>Caveat: Instances of {@link Math}, upon which the implementation of this
 * class relies, are not cryptographically secure.</p>
 * <p/>
 * <p>Please note that the Apache Commons project provides a component
 * dedicated to pseudo-random number generation, namely
 * <a href="https://commons.apache.org/rng">Commons RNG</a>, that may be
 * a better choice for applications with more stringent requirements
 * (performance and/or correctness).</p>
 *
 * @see CMN_UTIL_Random_TEST
 *
 * @author richard van hook jason.van.beukering@accenture.com
 *
 * @date 2019, December 2022
 */
@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity, PMD.ExcessivePublicCount')
public inherited sharing class CMN_UTIL_Random
{
	private static final CMN_UTIL_NumberRange.IntegerRange BINARY_RANGE = new CMN_UTIL_NumberRange.IntegerRange(0, 1);
	private static final String HEX_CHARS = '0123456789abcdefABCDEF';

	/**
	 * @description <p>
	 * Returns a random boolean value
	 * </p>
	 *
	 * @return the random boolean
	 *
	 * @since 3.5
	 */
	public static Boolean nextBoolean()
	{
		return nextInteger(BINARY_RANGE, true) == 1;
	}

	/**
	 * @description <p> Returns a random int within 0 - Integer.MAX_VALUE </p>
	 *
	 * @return the random integer
	 */
	public static Integer nextInteger()
	{
		return nextInteger(CMN_UTIL_Number.MAX_INTEGER_RANGE, true);
	}

	/**
	 * @description <p> Returns a random int within 0 - Integer.MAX_VALUE </p>
	 *
	 * @param max the upper bound (included)
	 *
	 * @return the random integer
	 *
	 * @since 3.5
	 */
	public static Integer nextInteger(Integer max)
	{
		return nextInteger(new CMN_UTIL_NumberRange.IntegerRange(0, Math.abs(max)), true);
	}

	/**
	 * @description <p> Returns a random int within 0 - Integer.MAX_VALUE </p>
	 *
	 * @param max the upper bound (included)
	 * @param inclusive of upper as input
	 *
	 * @return the random integer
	 *
	 * @since 3.5
	 */
	public static Integer nextInteger(Integer max, Boolean inclusive)
	{
		return nextInteger(new CMN_UTIL_NumberRange.IntegerRange(0, Math.abs(max)), inclusive);
	}

	/**
	 * @description <p>
	 * Returns a random integer within the specified range.
	 * </p>
	 *
	 * @param min the smallest value that can be returned, must be non-negative
	 * @param max the upper bound (not included)
	 *
	 * @return the random integer
	 *
	 * @throws IllegalArgumentException if {@code startInclusive > endExclusive} or if
	 *             {@code startInclusive} is negative
	 */
	public static Integer nextInteger(Integer min, Integer max)
	{
		return nextInteger(new CMN_UTIL_NumberRange.IntegerRange(min, max), true);
	}

	/**
	 * @description Returns a random integer within the specified range.
	 *
	 * @param min as input
	 * @param max as input
	 * @param inclusive as input
	 *
	 * @return next random integer
	 */
	public static Integer nextInteger(Integer min, Integer max, Boolean inclusive)
	{
		return nextInteger(new CMN_UTIL_NumberRange.IntegerRange(min, max), inclusive);
	}

	/**
	 * @description returns a random integer within the specified range.
	 *
	 * @param range as input
	 *
	 * @return next random integer
	 */
	public static Integer nextInteger(CMN_UTIL_NumberRange.IntegerRange range)
	{
		return nextInteger(range, true);
	}

	/**
	 * @description returns a random integer within the specified range.
	 *
	 * @param range as input
	 * @param inclusive as if range is inclusive
	 *
	 * @return next random integer
	 */
	public static Integer nextInteger(CMN_UTIL_NumberRange.IntegerRange range, Boolean inclusive)
	{
		if(range == null)
		{
			return null;
		}
		if(inclusive && (range.max() - range.min()) <= 0)
		{
			return range.min();
		}
		if(!inclusive && (range.max() - range.min()) <= 2)
		{
			return range.min();
		}
		Integer inclusiveChange1 = -1;
		if(inclusive)
		{
			inclusiveChange1 = 1;
		}
		Integer inclusiveChange2 = 1;
		if(inclusive)
		{
			inclusiveChange2 = 0;
		}
		return (Integer)(
				Math.round(
						Math.floor(
								Math.random()
										* ((range.max() - range.min() + inclusiveChange1))
						)
				)
						+ range.min()
						+ inclusiveChange2
		);
	}

	/**
	 * @description <p> Returns a random long within 0 - Long.MAX_VALUE </p>
	 *
	 * @return the random long
	 *
	 * @since 3.5
	 */
	public static Long nextLong()
	{
		return nextLong(CMN_UTIL_Number.MAX_LONG_RANGE, true);
	}

	/**
	 * @description returned next random long (inclusive of upper max)
	 *
	 * @param max as input
	 *
	 * @return next random long
	 */
	public static Long nextLong(Long max)
	{
		return nextLong(new CMN_UTIL_NumberRange.LongRange(0, Math.abs(max)), true);
	}

	/**
	 * @description returned next random long (optional inclusive of upper max)
	 *
	 * @param max max as input
	 * @param inclusive max as input
	 *
	 * @return next random long
	 */
	public static Long nextLong(Long max, Boolean inclusive)
	{
		return nextLong(new CMN_UTIL_NumberRange.LongRange(0, Math.abs(max)), inclusive);
	}

	/**
	 * @description <p>
	 * Returns a random long within the specified range.
	 * </p>
	 *
	 * @param min the smallest value that can be returned, must be non-negative
	 * @param max the upper bound (not included)
	 *
	 * @return the random long
	 *
	 * @throws IllegalArgumentException if {@code startInclusive > endExclusive} or if
	 *             {@code startInclusive} is negative
	 */
	public static Long nextLong(Long min, Long max)
	{
		return nextLong(new CMN_UTIL_NumberRange.LongRange(min, max), true);
	}

	/**
	 * @description Returns a random long within the specified range and optional inclusive
	 *
	 * @param min as input
	 * @param max as input
	 * @param inclusive as input
	 *
	 * @return next random long
	 */
	public static Long nextLong(Long min, Long max, Boolean inclusive)
	{
		return nextLong(new CMN_UTIL_NumberRange.LongRange(min, max), inclusive);
	}

	/**
	 * @description Returns a random long within the specified range
	 *
	 * @param range as input
	 *
	 * @return next random long
	 */
	public static Long nextLong(CMN_UTIL_NumberRange.LongRange range)
	{
		return nextLong(range, true);
	}

	/**
	 * @description return random long within range and if inclusive
	 *
	 * @param range as input
	 * @param inclusive as input
	 *
	 * @return next random long
	 */
	public static Long nextLong(CMN_UTIL_NumberRange.LongRange range, Boolean inclusive)
	{
		if(range == null)
		{
			return null;
		}
		if(inclusive && (range.max() - range.min()) <= 0)
		{
			return range.min();
		}
		if(!inclusive && (range.max() - range.min()) <= 2)
		{
			return range.min();
		}
		Integer inclusiveChange1 = -1;
		if(inclusive)
		{
			inclusiveChange1 = 1;
		}
		Integer inclusiveChange2 = 1;
		if(inclusive)
		{
			inclusiveChange2 = 0;
		}
		return Math.round(Math.floor(Math.random() * (((Long)range.max() - (Long)range.min() + inclusiveChange1))))
				+ (Long)range.min() + inclusiveChange2;
	}

	/**
	 * @description <p>Creates a random string whose length is the number of characters
	 * specified.</p>
	 * <p/>
	 * <p>Characters will be chosen from the set of all characters.</p>
	 *
	 * @param count the length of random string to create
	 *
	 * @return the random string
	 */
	public static String random(Integer count)
	{
		return random(count, false, false);
	}

	/**
	 * @description <p>Creates a random string whose length is the number of characters
	 * specified.</p>
	 * <p/>
	 * <p>Characters will be chosen from the set of characters whose
	 * ASCII value is between {@code 32} and {@code 126} (inclusive).</p>
	 *
	 * @param count the length of random string to create
	 *
	 * @return the random string
	 */
	public static String randomAscii(Integer count)
	{
		return random(count, 32, 127, false, false);
	}

	/**
	 * @description <p>Creates a random string whose length is the number of characters
	 * specified.</p>
	 * <p/>
	 * <p>Characters will be chosen from the set of Latin alphabetic
	 * characters (a-z, A-Z).</p>
	 *
	 * @param count the length of random string to create
	 *
	 * @return the random string
	 */
	public static String randomAlphabetic(Integer count)
	{
		return random(count, true, false);
	}

	/**
	 * @description <p>Creates a random string whose length is the number of characters
	 * specified.</p>
	 * <p/>
	 * <p>Characters will be chosen from the set of Latin alphabetic
	 * characters (a-z, A-Z) and the digits 0-9.</p>
	 *
	 * @param count the length of random string to create
	 *
	 * @return the random string
	 */
	public static String randomAlphanumeric(Integer count)
	{
		return random(count, true, true);
	}

	/**
	 * @description <p>Creates a random string whose length is the number of characters
	 * specified.</p>
	 * <p/>
	 * <p>Characters will be chosen from the set of numeric
	 * characters.</p>
	 *
	 * @param count the length of random string to create
	 *
	 * @return the random string
	 */
	public static String randomNumeric(Integer count)
	{
		return random(count, false, true);
	}

	/**
	 * @description <p>Creates a random string whose length is the number of characters
	 * specified.</p>
	 * <p/>
	 * <p>Characters will be chosen from the set of characters
	 * specified by the string, must not be empty.
	 * If null, the set of all characters is used.</p>
	 *
	 * @param count the length of random string to create
	 * @param chars the String containing the set of characters to use,
	 *  may be null, but must not be empty
	 *
	 * @return the random string
	 *
	 * @throws IllegalArgumentException if {@code count} &lt; 0 or the string is empty.
	 */
	public static String random(Integer count, String chars)
	{
		return random(count, 0, (chars == null ? 0 : chars.length()), false, false, chars);
	}

	/**
	 * @description <p>Creates a random string whose length is the number of characters
	 * specified.</p>
	 * <p/>
	 * <p>Characters will be chosen from the set of alpha-numeric
	 * characters as indicated by the arguments.</p>
	 *
	 * @param count the length of random string to create
	 * @param letters if {@code true}, generated string may include
	 *  alphabetic characters
	 * @param numbers if {@code true}, generated string may include
	 *  numeric characters
	 *
	 * @return the random string
	 */
	public static String random(Integer count, Boolean letters, Boolean numbers)
	{
		return random(count, 0, 0, letters, numbers);
	}

	/**
	 * @description <p>Creates a random string whose length is the number of characters
	 * specified.</p>
	 * <p/>
	 * <p>Characters will be chosen from the set of alpha-numeric
	 * characters as indicated by the arguments.</p>
	 *
	 * @param count the length of random string to create
	 * @param startIndex the position in set of chars to start at
	 * @param endIndex the position in set of chars to end before
	 * @param letters if {@code true}, generated string may include
	 *  alphabetic characters
	 * @param numbers if {@code true}, generated string may include
	 *  numeric characters
	 *
	 * @return the random string
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static String random(Integer count, Integer startIndex, Integer endIndex, Boolean letters, Boolean numbers)
	{
		return random(count, startIndex, endIndex, letters, numbers, null);
	}

	/**
	 * @description <p>Creates a random string based on a variety of options, using
	 * default source of randomness.</p>
	 * <p/>
	 * <p>This method has exactly the same semantics as
	 * {@link #random(int,int,int,boolean,boolean,List<char>,Random)}, but
	 * instead of using an externally supplied source of randomness, it uses
	 * the internal static {@link Math} instance.</p>
	 *
	 * @param count the length of random string to create
	 * @param startIndex the position in set of chars to start at
	 * @param endIndex the position in set of chars to end before
	 * @param letters only allow letters?
	 * @param numbers only allow numbers?
	 * @param chars the string  chars to choose randoms from.
	 *  If {@code null}, then it will use the set of all chars.
	 *
	 * @return the random string
	 */
	@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity,PMD.ExcessiveParameterList')
	public static String random(Integer count, Integer startIndex, Integer endIndex, Boolean letters, Boolean numbers, String chars)
	{
		if(count <= 0)
		{
			return '';
		}
		if(chars == null && (letters || numbers))
		{
			chars = '';
			startIndex = 0;
			if(letters)
			{
				endIndex += 52;
				for(Integer i = CMN_UTIL_Character.toAscii('a'), max = CMN_UTIL_Character.toAscii('z'); i <= max; i++)
				{
					chars += CMN_UTIL_Character.toChar(i);
				}
				for(Integer i = CMN_UTIL_Character.toAscii('A'), max = CMN_UTIL_Character.toAscii('Z'); i <= max; i++)
				{
					chars += CMN_UTIL_Character.toChar(i);
				}
			}
			if(numbers)
			{
				endIndex += 10;
				for(Integer i = CMN_UTIL_Character.toAscii('0'), max = CMN_UTIL_Character.toAscii('9'); i <= max; i++)
				{
					chars += CMN_UTIL_Character.toChar(i);
				}
			}
		}
		CMN_UTIL_NumberRange.IntegerRange allowableRange = null;
		if(chars == null)
		{
			allowableRange = new CMN_UTIL_NumberRange.IntegerRange(32, 127);
		}
		else
		{
			allowableRange = new CMN_UTIL_NumberRange.IntegerRange(0, chars.length());
		}
		if(!allowableRange.contains(new CMN_UTIL_NumberRange.IntegerRange(startIndex, endIndex)))
		{
			startIndex = allowableRange.min();
			endIndex = allowableRange.max();
		}

		CMN_UTIL_StringBuilder buffer = new CMN_UTIL_StringBuilder();
		buffer.add(CMN_UTIL_String.EMPTY);
		String ch;
		Integer gap = endIndex - startIndex;
		Integer next = 0;

		while(count-- > 0)
		{
			next = Math.round(Math.floor(Math.random() * gap)) + startIndex;
			if(chars == null)
			{
				ch = CMN_UTIL_Character.toChar(next);
			}
			else
			{
				ch = CMN_UTIL_String.charAt(chars, next);
			}
			buffer.add(ch);
		}

		return buffer.toString();
	}

	/**
	 * @description Implementation ported from Java Library at http://jug.safehaus.org
	 *
	 * @return uuid string
	 */
	public static String randomUUID()
	{
		String returnValue = '';
		Integer nextByte = 0;
		for(Integer i = 0; i < 16; i++)
		{
			if(i == 4 || i == 6 || i == 8 || i == 10)
			{
				returnValue += '-';
			}
			//generate a "byte"; i.e., number in range [-2^7,2^7-1]
			nextByte = (Math.round(Math.random() * 255) - 128) & 255;

			if(i == 6)
			{
				nextByte = nextByte & 15;
				nextByte = nextByte | (4 << 4);
			}
			if(i == 8)
			{
				nextByte = nextByte & 63;
				nextByte = nextByte | 128;
			}

			returnValue += CMN_UTIL_String.charAt(HEX_CHARS, nextByte >> 4);
			returnValue += CMN_UTIL_String.charAt(HEX_CHARS, nextByte & 15);
		}
		return returnValue;
	}

	/**
	 * @description for mock testing produces 18 length mock sobject id
	 *
	 * @param objectType as input
	 *
	 * @return fake sobject id (not generated by database)
	 */
	public static Id randomSObjectId(SObjectType objectType)
	{
		return getRandomId(objectType);
	}

	/**
	 * @description for mock testing produces 18 length mock sobject id
	 *
	 * @param objectType as input
	 *
	 * @return fake sobject id (not generated by database)
	 */
	public static Id getRandomId(SObjectType objectType)
	{
		String result = String.valueOf(randomNumeric(10));
		return (objectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(12 - result.length()) + result);
	}

	/**
	 * @description Will generate a random positive integer
	 *
	 * @param maxInteger the largest size the random integer may be that is generated, sets the bounds
	 *
	 * @return Either null or integer
	 */
	public static Integer getRandomInteger(Integer maxInteger)
	{
		return maxInteger == null ? null : CMN_UTIL_Random.nextInteger(maxInteger);
	}

	/**
	 * @description Will return a random valid index for a List, note, whilst passing a list of object, any list should be passable
	 *
	 * @param objects A list, we are just using a list of objects, lists aren't typed
	 *
	 * @return Either null or a random valid list index
	 */
	public static Integer getRandomIndex(List<Object> objects)
	{
		return objects == null || objects.isEmpty() ? null : getRandomInteger(objects.size() - 1);
	}

	/**
	 * @description Method will return an random item from the list
	 *
	 * @param objects A List of SObjects
	 *
	 * @return Depending on List being Empty or not, a Random SObject or Null will be returned;
	 */
	public static SObject getRandomItem(List<SObject> objects)
	{
		List<SObject> randomItems = getRandomItems(objects, 1);

		return randomItems.isEmpty() ? null : randomItems.iterator().next();

	}

	/**
	 * @description Returns a list of random objects from a list of Objects
	 *
	 * @param sourceItems List of Objects to select items from
	 * @param numberOfItems Maximum, Number of Items to return, if objects size is less or or equal to number of items, all the items from objects is returned
	 *
	 * @return List of random items
	 */
	public static List<SObject> getRandomItems(List<SObject> sourceItems, Integer numberOfItems)
	{
		List<SObject> randomItems = new List<SObject>();

		if((numberOfItems > 0) && (sourceItems != null))
		{
			if(sourceItems.size() <= numberOfItems)
			{
				randomItems.addAll(sourceItems);
			}
			else
			{
				// Make a copy so that the original list is not affected
				List<SObject> copyObjects = new List<SObject>(sourceItems);
				while(randomItems.size() < numberOfItems)
				{
					randomItems.add(copyObjects.remove(getRandomIndex(copyObjects)));
				}
			}
		}
		return randomItems;
	}
}