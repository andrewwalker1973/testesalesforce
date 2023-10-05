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
 * @see CMN_UTIL_String
 *
 * @author richard van hook, christopher.de.buys@accenture.com
 *
 * @date December 2022, July 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs,PMD.CyclomaticComplexity')
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_UTIL_String_TEST
{
	@IsTest
	private static void testAbbreviateTwoArgs()
	{
		assertAbbreviateTwoArgs(null, -1, null, false);
		assertAbbreviateTwoArgs('', 4, '', false);
		assertAbbreviateTwoArgs('abcdefg', 6, 'abc...', false);
		assertAbbreviateTwoArgs('abcdefg', 7, 'abcdefg', false);
		assertAbbreviateTwoArgs('abcdefg', 8, 'abcdefg', false);
		assertAbbreviateTwoArgs('abcdefg', 4, 'a...', false);
		assertAbbreviateTwoArgs('abcdefg', 3, null, true);
	}

	private static void assertAbbreviateTwoArgs(String str, Integer maxWidth,
			String expected, Boolean excepExpected)
	{

		String actual = null;
		Boolean excepActual = false;
		try
		{
			actual = CMN_UTIL_String.abbreviate(str, maxWidth);
		}
		catch(IllegalArgumentException e)
		{
			excepActual = true;
		}
		if(excepExpected && excepActual)
		{
			return;
		}
		System.assert(excepExpected == excepActual, 'CMN_UTIL_String.abbreviate(\''
				+ str + '\',' + maxWidth + ') '
				+ (excepExpected ? 'did not throw' : 'unexpectedly threw')
				+ ' IllegalArgumentException');
		if(!excepExpected && !excepActual)
		{
			System.assert(actual == expected, 'CMN_UTIL_String.abbreviate(\'' + str + '\','
					+ maxWidth + ') returned ' + actual + '; expected ' + expected);
		}
	}

	@IsTest
	private static void testAbbreviateThreeArgs()
	{
		assertAbbreviateThreeArgs(null, -1, -1, null, false);
		assertAbbreviateThreeArgs('', 0, 4, '', false);
		assertAbbreviateThreeArgs('abcdefghijklmno', -1, 10, 'abcdefg...', false);
		assertAbbreviateThreeArgs('abcdefghijklmno', 0, 10, 'abcdefg...', false);
		assertAbbreviateThreeArgs('abcdefghijklmno', 1, 10, 'abcdefg...', false);
		assertAbbreviateThreeArgs('abcdefghijklmno', 4, 10, 'abcdefg...', false);
		assertAbbreviateThreeArgs('abcdefghijklmno', 5, 10, '...fghi...', false);
		assertAbbreviateThreeArgs('abcdefghijklmno', 6, 10, '...ghij...', false);
		assertAbbreviateThreeArgs('abcdefghijklmno', 8, 10, '...ijklmno', false);
		assertAbbreviateThreeArgs('abcdefghijklmno', 10, 10, '...ijklmno', false);
		assertAbbreviateThreeArgs('abcdefghijklmno', 12, 10, '...ijklmno', false);
		assertAbbreviateThreeArgs('abcdefghijklmno', 20, 10, '...ijklmno', false);
		assertAbbreviateThreeArgs('abcdefghij', 0, 3, null, true);
		assertAbbreviateThreeArgs('abcdefghij', 5, 6, null, true);
	}

	private static void assertAbbreviateThreeArgs(String str, Integer offset, Integer maxWidth,
			String expected, Boolean excepExpected)
	{

		String actual = null;
		Boolean excepActual = false;
		try
		{
			actual = CMN_UTIL_String.abbreviate(str, offset, maxWidth);
		}
		catch(IllegalArgumentException e)
		{
			excepActual = true;
		}
		if(excepExpected && excepActual)
		{
			return;
		}
		System.assert(excepExpected == excepActual, 'CMN_UTIL_String.abbreviate(\''
				+ str + '\',' + offset + ',' + maxWidth + ') '
				+ (excepExpected ? 'did not throw' : 'unexpectedly threw')
				+ ' IllegalArgumentException');
		if(!excepExpected && !excepActual)
		{
			System.assert(actual == expected, 'CMN_UTIL_String.abbreviate(\'' + str + '\','
					+ offset + ',' + maxWidth + ') returned ' + actual + '; expected ' + expected);
		}
	}

	@IsTest
	private static void testIndexOfAny()
	{
		//test: global static int indexOfAny(String str, String searchChars) {
		assertIndexOfAny(null, null, -1);
		assertIndexOfAny('', null, -1);
		assertIndexOfAny(null, '', -1);
		assertIndexOfAny('zzabyycdxx', 'za', 0);
		assertIndexOfAny('zzabyycdxx', 'by', 3);
		assertIndexOfAny('aba', 'z', -1);
	}

	private static void assertIndexOfAny(String str, String searchChars, Integer expected)
	{
		Integer actual = CMN_UTIL_String.indexOfAny(str, searchChars);
		System.assert(actual == expected, 'CMN_UTIL_String.indexOfAny(\'' + str + '\','
				+ searchChars + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testLastIndexOfAny()
	{
		//test: global static Integer lastIndexOfAny(String str, List<String> searchStrs) {
		assertLastIndexOfAny(null, null, -1);
		assertLastIndexOfAny('', null, -1);
		assertLastIndexOfAny(null, new List<String> {}, -1);
		assertLastIndexOfAny(null, new List<String> {null}, -1);
		assertLastIndexOfAny('', new List<String> {null}, -1);
		assertLastIndexOfAny('zzabyycdxx', new List<String> {'ab', 'cd'}, 6);
		assertLastIndexOfAny('zzabyycdxx', new List<String> {'cd', 'ab'}, 6);
		assertLastIndexOfAny('zzabyycdxx', new List<String> {'mn', 'op'}, -1);
		assertLastIndexOfAny('zzabyycdxx', new List<String> {'mn', 'op'}, -1);
		assertLastIndexOfAny('zzabyycdxx', new List<String> {'mn', ''}, 10);
	}

	private static void assertLastIndexOfAny(String str, List<String> searchStrs, Integer expected)
	{
		Integer actual = CMN_UTIL_String.lastIndexOfAny(str, searchStrs);
		System.assert(actual == expected, 'CMN_UTIL_String.lastIndexOfAny(\'' + str + '\','
				+ CMN_UTIL_Array.toString(searchStrs) + ') returned ' + actual + '; expected ' + expected);
	}

	@IsTest
	private static void testLastIndexOfTwoArgs()
	{
		//test: global static Integer lastIndexOf(String str, String searchStr) {
		assertLastIndexOfTwoArgs(null, '', -1);
		assertLastIndexOfTwoArgs('', null, -1);
		assertLastIndexOfTwoArgs('', '', 0);
		assertLastIndexOfTwoArgs('aabaabaa', 'a', 7);
		assertLastIndexOfTwoArgs('aabaabaa', 'b', 5);
		assertLastIndexOfTwoArgs('aabaabaa', 'ab', 4);
		assertLastIndexOfTwoArgs('aabaabaa', '', 8);
	}

	private static void assertLastIndexOfTwoArgs(String str, String searchStr, Integer expected)
	{
		Integer actual = CMN_UTIL_String.lastIndexOf(str, searchStr);
		System.assert(actual == expected, 'CMN_UTIL_String.lastIndexOf(\'' + str + '\',\''
				+ searchStr + '\') returned ' + actual + '; expected ' + expected);
	}

	@IsTest
	private static void testLastIndexOfThreeArgs()
	{
		//test: global static Integer lastIndexOf(String str, String searchStr, Integer startPos) {
		assertLastIndexOfThreeArgs(null, null, -1, -1);
		assertLastIndexOfThreeArgs('', null, -1, -1);
		assertLastIndexOfThreeArgs('aabaabaa', 'a', 8, 7);
		assertLastIndexOfThreeArgs('aabaabaa', 'b', 8, 5);
		assertLastIndexOfThreeArgs('aabaabaa', 'ab', 8, 4);
		assertLastIndexOfThreeArgs('aabaabaa', 'b', 9, 5);
		assertLastIndexOfThreeArgs('aabaabaa', 'b', -1, -1);
		assertLastIndexOfThreeArgs('aabaabaa', 'a', 0, 0);
		assertLastIndexOfThreeArgs('aabaabaa', 'b', 0, -1);
	}

	private static void assertLastIndexOfThreeArgs(String str, String searchStr, Integer startPos, Integer expected)
	{
		Integer actual = CMN_UTIL_String.lastIndexOf(str, searchStr, startPos);
		System.assert(actual == expected, 'CMN_UTIL_String.lastIndexOf(\'' + str + '\',\''
				+ searchStr + '\',' + startPos + ') returned ' + actual + '; expected ' + expected);
	}

	@IsTest
	private static void testIndexOfAnyStringArray()
	{
		//test: global static Integer indexOfAny(String str, List<String> searchStrs) {
		assertIndexOfAnyStringArray(null, null, -1);
		assertIndexOfAnyStringArray(null, new List<String> {}, -1);
		assertIndexOfAnyStringArray('zzabyycdxx', new List<String> {null}, -1);
		assertIndexOfAnyStringArray('zzabyycdxx', new List<String> {'ab', 'cd'}, 2);
		assertIndexOfAnyStringArray('zzabyycdxx', new List<String> {'cd', 'ab'}, 2);
		assertIndexOfAnyStringArray('zzabyycdxx', new List<String> {'mn', 'op'}, -1);
		assertIndexOfAnyStringArray('zzabyycdxx', new List<String> {'zab', 'aby'}, 1);
		assertIndexOfAnyStringArray('zzabyycdxx', new List<String> {''}, 0);
		assertIndexOfAnyStringArray('', new List<String> {''}, 0);
		assertIndexOfAnyStringArray('', new List<String> {'a'}, -1);
	}

	private static void assertIndexOfAnyStringArray(String str, List<String> searchStrs, Integer expected)
	{
		Integer actual = CMN_UTIL_String.indexOfAny(str, searchStrs);
		System.assert(actual == expected, 'CMN_UTIL_String.indexOfAny(\'' + str + '\','
				+ CMN_UTIL_Array.toString(searchStrs) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testCenterTwoArgs()
	{
		assertCenterTwoArgs(null, -1, null);
		assertCenterTwoArgs('', 4, '    ');
		assertCenterTwoArgs('ab', -1, 'ab');
		assertCenterTwoArgs('ab', 4, ' ab ');
		assertCenterTwoArgs('abcd', 2, 'abcd');
		assertCenterTwoArgs('a', 4, ' a  ');
	}

	private static void assertCenterTwoArgs(String str, Integer size, String expected)
	{
		String actual = CMN_UTIL_String.center(str, size);
		System.assert(actual == expected, 'CMN_UTIL_String.center(\'' + str + '\','
				+ size + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testChompOneArg()
	{
		assertChompOneArg(null, null);
		assertChompOneArg('', '');
		assertChompOneArg('abc \r', 'abc ');
		assertChompOneArg('abc\n', 'abc');
		assertChompOneArg('abc\r\n', 'abc');
		assertChompOneArg('abc\r\n\r\n', 'abc\r\n');
		assertChompOneArg('abc\n\r', 'abc\n');
		assertChompOneArg('abc\n\rabc', 'abc\n\rabc');
		assertChompOneArg('\t', '\t');
		assertChompOneArg('\r', '');
		assertChompOneArg('\n', '');
		assertChompOneArg('\r\n', '');
	}

	private static void assertChompOneArg(String str, String expected)
	{
		String actual = CMN_UTIL_String.chomp(str);
		System.assert(actual == expected, 'CMN_UTIL_String.chomp(\'' + str + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testChompTwoArgs()
	{
		assertChompTwoArgs(null, null, null);
		assertChompTwoArgs('', null, '');
		assertChompTwoArgs('foobar', 'bar', 'foo');
		assertChompTwoArgs('foobar', 'baz', 'foobar');
		assertChompTwoArgs('foo', 'foo', '');
		assertChompTwoArgs('foo ', 'foo', 'foo ');
		assertChompTwoArgs(' foo', 'foo', ' ');
		assertChompTwoArgs('foo', 'foooo', 'foo');
		assertChompTwoArgs('foo', '', 'foo');
		assertChompTwoArgs('foo', null, 'foo');
	}

	private static void assertChompTwoArgs(String str, String separator, String expected)
	{
		String actual = CMN_UTIL_String.chomp(str, separator);
		System.assert(actual == expected, 'CMN_UTIL_String.chomp(\'' + str + '\', \'' + separator + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testCenterThreeArgs()
	{
		assertCenterThreeArgs(null, -1, null, null);
		assertCenterThreeArgs('', 4, ' ', '    ');
		assertCenterThreeArgs('ab', -1, ' ', 'ab');
		assertCenterThreeArgs('ab', 4, ' ', ' ab ');
		assertCenterThreeArgs('abcd', 2, ' ', 'abcd');
		assertCenterThreeArgs('a', 4, ' ', ' a  ');
		assertCenterThreeArgs('a', 4, 'yz', 'yayz');
		assertCenterThreeArgs('abc', 7, null, '  abc  ');
		assertCenterThreeArgs('abc', 7, '', '  abc  ');
	}

	private static void assertCenterThreeArgs(String str, Integer size, String padStr, String expected)
	{
		String actual = CMN_UTIL_String.center(str, size, padStr);
		System.assert(actual == expected, 'CMN_UTIL_String.center(\'' + str + '\','
				+ size + ',\'' + padStr + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testChop()
	{
		assertChop(null, null);
		assertChop('', '');
		assertChop('abc \r', 'abc ');
		assertChop('abc\n', 'abc');
		assertChop('abc\r\n', 'abc');
		assertChop('abc', 'ab');
		assertChop('abc\nabc', 'abc\nab');
		assertChop('a', '');
		assertChop('\r', '');
		assertChop('\n', '');
		assertChop('\r\n', '');
	}

	private static void assertChop(String str, String expected)
	{
		String actual = CMN_UTIL_String.chop(str);
		System.assert(actual == expected, 'CMN_UTIL_String.chop(\'' + str + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testContainsAny()
	{
		assertContainsAny(null, null, false);
		assertContainsAny('', null, false);
		assertContainsAny(null, null, false);
		assertContainsAny(null, '', false);
		assertContainsAny('zzabyycdxx', 'za', true);
		assertContainsAny('zzabyycdxx', 'by', true);
		assertContainsAny('aba', 'z', false);
	}

	private static void assertContainsAny(String str, String searchChars, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.containsAny(str, searchChars);
		System.assert(actual == expected, 'CMN_UTIL_String.containsAny(\'' + str + '\',\'' + searchChars + '\') returned '
				+ actual);
	}

	@IsTest
	private static void testContainsNone()
	{
		//test: global static Boolean containsNone(String str, String invalidChars) {
		assertContainsNone(null, null, true);
		assertContainsNone(null, null, true);
		assertContainsNone('', null, true);
		assertContainsNone('ab', '', true);
		assertContainsNone('abab', 'xyz', true);
		assertContainsNone('ab1', 'xyz', true);
		assertContainsNone('abz', 'xyz', false);
	}

	private static void assertContainsNone(String str, String invalidChars, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.containsNone(str, invalidChars);
		System.assert(actual == expected, 'CMN_UTIL_String.containsNone(\'' + str + '\',\'' + invalidChars + '\') returned '
				+ actual);
	}

	@IsTest
	private static void testContainsOnly()
	{
		//test: global static Boolean containsOnly(String str, String valid) {
		assertContainsOnly(null, null, false);
		assertContainsOnly(null, null, false);
		assertContainsOnly('', null, false);
		assertContainsOnly('', '', true);
		assertContainsOnly('ab', '', false);
		assertContainsOnly('abab', 'abc', true);
		assertContainsOnly('ab1', 'abc', false);
		assertContainsOnly('abz', 'abc', false);
	}

	private static void assertContainsOnly(String str, String valid, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.containsOnly(str, valid);
		System.assert(actual == expected, 'CMN_UTIL_String.containsOnly(\'' + str + '\',\'' + valid + '\') returned '
				+ actual);
	}

	@IsTest
	private static void testCountMatches()
	{
		//test: global static Integer countMatches(String str, String sub) {
		assertCountMatches(null, null, 0);
		assertCountMatches('', null, 0);
		assertCountMatches('abba', null, 0);
		assertCountMatches('abba', '', 0);
		assertCountMatches('abba', 'a', 2);
		assertCountMatches('abba', 'ab', 1);
		assertCountMatches('abba', 'xxx', 0);
	}

	private static void assertCountMatches(String str, String sub, Integer expected)
	{
		Integer actual = CMN_UTIL_String.countMatches(str, sub);
		System.assert(actual == expected, 'CMN_UTIL_String.countMatches(\'' + str + '\',\'' + sub + '\') returned '
				+ actual + '; expected ' + expected);
	}

	@IsTest
	private static void testDefaultIfEmpty()
	{
		//test: global static String defaultIfEmpty(String str, String defaultStr) {
		assertDefaultIfEmpty(null, 'NULL', 'NULL');
		assertDefaultIfEmpty('', 'NULL', 'NULL');
		assertDefaultIfEmpty('bat', 'NULL', 'bat');
	}

	private static void assertDefaultIfEmpty(String str, String defaultStr, String expected)
	{
		String actual = CMN_UTIL_String.defaultIfEmpty(str, defaultStr);
		System.assert(actual == expected, 'CMN_UTIL_String.defaultIfEmpty(\'' + str + '\',\'' + defaultStr + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testDefaultStringOneArg()
	{
		//test: global static String defaultString(String str) {
		assertDefaultStringOneArg(null, '');
		assertDefaultStringOneArg('', '');
		assertDefaultStringOneArg('bat', 'bat');
	}

	private static void assertDefaultStringOneArg(String str, String expected)
	{
		String actual = CMN_UTIL_String.defaultString(str);
		System.assert(actual == expected, 'CMN_UTIL_String.defaultString(\'' + str + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testDefaultStringTwoArgs()
	{
		//test: global static String defaultString(String str, String defaultStr) {
		assertDefaultStringTwoArgs(null, 'NULL', 'NULL');
		assertDefaultStringTwoArgs('', 'NULL', '');
		assertDefaultStringTwoArgs('bat', 'NULL', 'bat');
	}

	private static void assertDefaultStringTwoArgs(String str, String defaultStr, String expected)
	{
		String actual = CMN_UTIL_String.defaultString(str, defaultStr);
		System.assert(actual == expected, 'CMN_UTIL_String.defaultString(\'' + str + '\',\'' + defaultStr + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testDeleteWhitespace()
	{
		//test: global static String deleteWhitespace(String str) {
		assertDeleteWhitespace(null, null);
		assertDeleteWhitespace('', '');
		assertDeleteWhitespace('abc', 'abc');
		assertDeleteWhitespace('   ab  c  ', 'abc');
	}

	private static void assertDeleteWhitespace(String str, String expected)
	{
		String actual = CMN_UTIL_String.deleteWhitespace(str);
		System.assert(actual == expected, 'CMN_UTIL_String.deleteWhitespace(\'' + str + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testDifference()
	{
		//test: global static String difference(String str1, String str2) {
		assertDifference(null, null, null);
		assertDifference('', null, '');
		assertDifference('', '', '');
		assertDifference('', 'abc', 'abc');
		assertDifference('abc', '', '');
		assertDifference('abc', 'abc', '');
		assertDifference('ab', 'abxyz', 'xyz');
		assertDifference('abcde', 'abxyz', 'xyz');
		assertDifference('abcde', 'xyz', 'xyz');
	}

	private static void assertDifference(String str1, String str2, String expected)
	{
		String actual = CMN_UTIL_String.difference(str1, str2);
		System.assert(actual == expected, 'CMN_UTIL_String.difference(\'' + str1 + '\',\'' + str2 + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testEquals()
	{
		//test: global static Boolean equals(String str1, String str2) {
		assertEquals(null, null, true);
		assertEquals(null, 'abc', false);
		assertEquals('abc', null, false);
		assertEquals('abc', 'abc', true);
		assertEquals('abc', 'ABC', false);
	}

	private static void assertEquals(String str1, String str2, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.equals(str1, str2);
		System.assert(actual == expected, 'CMN_UTIL_String.equals(\'' + str1 + '\',\'' + str2 + '\') returned ' + actual);
	}

	@IsTest
	private static void testEqualsIgnoreCase()
	{
		//test: global static Boolean equalsIgnoreCase(String str1, String str2) {
		assertEqualsIgnoreCase(null, null, true);
		assertEqualsIgnoreCase(null, 'abc', false);
		assertEqualsIgnoreCase('abc', null, false);
		assertEqualsIgnoreCase('abc', 'abc', true);
		assertEqualsIgnoreCase('abc', 'ABC', true);
	}

	private static void assertEqualsIgnoreCase(String str1, String str2, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.equalsIgnoreCase(str1, str2);
		System.assert(actual == expected, 'CMN_UTIL_String.equalsIgnoreCase(\'' + str1 + '\',\'' + str2 + '\') returned ' + actual);
	}

	@IsTest
	private static void testIndexOf()
	{
		//test: global static Integer indexOf(String str, String searchStr) {
		assertIndexOf(null, null, -1);
		assertIndexOf('', null, -1);
		assertIndexOf('aabaabaa', 'a', 0);
		assertIndexOf('aabaabaa', 'b', 2);
	}

	private static void assertIndexOf(String str1, String searchStr, Integer expected)
	{
		Integer actual = CMN_UTIL_String.indexOf(str1, searchStr);
		System.assert(actual == expected, 'CMN_UTIL_String.indexOf(\'' + str1 + '\',\'' + searchStr + '\') returned '
				+ actual + '; expected ' + expected);
	}

	@IsTest
	private static void testIndexOfDifference()
	{
		//test: global static Integer indexOfDifference(String str1, String str2) {
		assertIndexOfDifference(null, null, -1);
		assertIndexOfDifference(null, '', 0);
		assertIndexOfDifference('', null, 0);
		assertIndexOfDifference('', '', -1);
		assertIndexOfDifference('', 'abc', 0);
		assertIndexOfDifference('abc', '', 0);
		assertIndexOfDifference('abc', 'abc', -1);
		assertIndexOfDifference('ab', 'abxyz', 2);
		assertIndexOfDifference('abcde', 'abxyz', 2);
		assertIndexOfDifference('abcde', 'xyz', 0);
	}

	private static void assertIndexOfDifference(String str1, String str2, Integer expected)
	{
		Integer actual = CMN_UTIL_String.indexOfDifference(str1, str2);
		System.assert(actual == expected, 'CMN_UTIL_String.indexOfDifference(\'' + str1 + '\',\'' + str2 + '\') returned '
				+ actual + '; expected ' + expected);
	}

	@IsTest
	private static void testIndexOfAnyBut()
	{
		//test: global static int indexOfAnyBut(String str, String searchChars) {
		assertIndexOfAnyBut(null, null, -1);
		assertIndexOfAnyBut('', null, -1);
		assertIndexOfAnyBut(null, null, -1);
		assertIndexOfAnyBut(null, '', -1);
		assertIndexOfAnyBut('zzabyycdxx', 'za', 3);
		assertIndexOfAnyBut('zzabyycdxx', '', 0);
		assertIndexOfAnyBut('aba', 'ab', -1);
	}

	private static void assertIndexOfAnyBut(String str, String searchChars, Integer expected)
	{
		Integer actual = CMN_UTIL_String.indexOfAnyBut(str, searchChars);
		System.assert(actual == expected, 'CMN_UTIL_String.indexOfAnyBut(\'' + str + '\',\'' + searchChars + '\') returned '
				+ actual + '; expected ' + expected);
	}

	@IsTest
	private static void testLowerCase()
	{
		assertLowerCase(null, null);
		assertLowerCase('ABC', 'abc');
		assertLowerCase('abc', 'abc');
		assertLowerCase('aBc', 'abc');
	}

	private static void assertLowerCase(String str, String expected)
	{
		String actual = CMN_UTIL_String.lowerCase(str);
		System.assert(actual == expected, 'CMN_UTIL_String.lowerCase(\'' + str + '\') returned ' + actual);
	}

	@IsTest
	private static void testUpperCase()
	{
		assertUpperCase(null, null);
		assertUpperCase('ABC', 'ABC');
		assertUpperCase('abc', 'ABC');
		assertUpperCase('aBc', 'ABC');
	}

	private static void assertUpperCase(String str, String expected)
	{
		String actual = CMN_UTIL_String.upperCase(str);
		System.assert(actual == expected, 'CMN_UTIL_String.upperCase(\'' + str + '\') returned ' + actual);
	}

	@IsTest
	private static void testCapitalize()
	{
		assertCapitalize(null, null);
		assertCapitalize('ABC', 'ABC');
		assertCapitalize('abc', 'Abc');
		assertCapitalize('aBc', 'ABc');
	}

	private static void assertCapitalize(String str, String expected)
	{
		String actual = CMN_UTIL_String.capitalize(str);
		System.assert(actual == expected, 'CMN_UTIL_String.capitalize(\'' + str + '\') returned ' + actual);
	}

	/**
	 * @description Will test the behaviour of the relevant method
	 *
	 * @see CMN_UTIL_String.capitalizeSentence
	 */
	@IsTest
	private static void capitalizeSentence()
	{
		assertCapitalizeSentence(null, null);
		assertCapitalizeSentence('joe soap', 'Joe Soap');
		assertCapitalizeSentence('JOE SOAP', 'Joe Soap');
		assertCapitalizeSentence('jOe sOaP', 'Joe Soap');
		assertCapitalizeSentence('joe', 'Joe');
	}

	/**
	 * @description Executes method and then checks that the strings match as expected
	 *
	 * @param str String to capitalize
	 * @param expected Expected output
	 */
	private static void assertCapitalizeSentence(String str, String expected)
	{
		String actual = CMN_UTIL_String.capitalizeSentence(str);
		System.assert(actual == expected, 'CMN_UTIL_String.capitalizeSentence(\'' + str + '\') returned ' + actual);
	}

	@IsTest
	private static void testUncapitalize()
	{
		assertUncapitalize(null, null);
		assertUncapitalize('ABC', 'aBC');
		assertUncapitalize('abc', 'abc');
		assertUncapitalize('aBc', 'aBc');
	}

	private static void assertUncapitalize(String str, String expected)
	{
		String actual = CMN_UTIL_String.uncapitalize(str);
		System.assert(actual == expected, 'CMN_UTIL_String.uncapitalize(\'' + str + '\') returned ' + actual);
	}

	@IsTest
	private static void testSwapCase()
	{
		assertSwapCase(null, null);
		assertSwapCase('', '');
		assertSwapCase('The dog has a BONE', 'tHE DOG HAS A bone');
	}

	private static void assertSwapCase(String str, String expected)
	{
		String actual = CMN_UTIL_String.swapCase(str);
		System.assert(actual == expected, 'CMN_UTIL_String.swapCase(\'' + str + '\') returned ' + actual);
	}

	@IsTest
	private static void testIsEmpty()
	{
		assertIsEmpty(null, true);
		assertIsEmpty('', true);
		assertIsEmpty(' ', false);
		assertIsEmpty('bob', false);
		assertIsEmpty('  bob  ', false);
	}

	private static void assertIsEmpty(String str, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.isEmpty(str);
		System.assert(actual == expected, 'CMN_UTIL_String.IsEmpty(\'' + str + '\') returned ' + actual);
	}

	@IsTest
	private static void testIsNotEmpty()
	{
		assertIsNotEmpty(null, false);
		assertIsNotEmpty('', false);
		assertIsNotEmpty(' ', true);
		assertIsNotEmpty('bob', true);
		assertIsNotEmpty('  bob  ', true);
	}

	private static void assertIsNotEmpty(String str, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.isNotEmpty(str);
		System.assert(actual == expected, 'CMN_UTIL_String.IsNotEmpty(\'' + str + '\') returned ' + actual);
	}

	@IsTest
	private static void testIsAlpha()
	{
		//test: global static Boolean isAlpha(String str) {
		assertIsAlpha(null, false);
		assertIsAlpha('', true);
		assertIsAlpha('  ', false);
		assertIsAlpha('abc', true);
		assertIsAlpha('ab2c', false);
		assertIsAlpha('ab-c', false);
	}

	private static void assertIsAlpha(String str, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.isAlpha(str);
		System.assert(actual == expected, 'CMN_UTIL_String.isAlpha(\'' + str + '\') returned ' + actual);
	}

	@IsTest
	private static void testIsAlphaSpace()
	{
		//test: global static Boolean isAlphaSpace(String str) {
		assertIsAlphaSpace(null, false);
		assertIsAlphaSpace('', true);
		assertIsAlphaSpace('  ', true);
		assertIsAlphaSpace('abc', true);
		assertIsAlphaSpace('ab c', true);
		assertIsAlphaSpace('ab2c', false);
		assertIsAlphaSpace('ab-c', false);
	}

	private static void assertIsAlphaSpace(String str, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.isAlphaSpace(str);
		System.assert(actual == expected, 'CMN_UTIL_String.isAlphaSpace(\'' + str + '\') returned ' + actual);
	}

	@IsTest
	private static void testIsAlphanumeric()
	{
		//test: global static Boolean isAlphanumeric(String str) {
		assertIsAlphanumeric(null, false);
		assertIsAlphanumeric('', true);
		assertIsAlphanumeric('  ', false);
		assertIsAlphanumeric('abc', true);
		assertIsAlphanumeric('ab c', false);
		assertIsAlphanumeric('ab2c', true);
		assertIsAlphanumeric('ab-c', false);
	}

	private static void assertIsAlphanumeric(String str, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.isAlphanumeric(str);
		System.assert(actual == expected, 'CMN_UTIL_String.isAlphanumeric(\'' + str + '\') returned ' + actual);
	}

	@IsTest
	private static void testIsAlphanumericSpace()
	{
		//test: global static Boolean isAlphanumericSpace(String str) {
		assertIsAlphanumericSpace(null, false);
		assertIsAlphanumericSpace('', true);
		assertIsAlphanumericSpace('  ', true);
		assertIsAlphanumericSpace('abc', true);
		assertIsAlphanumericSpace('ab c', true);
		assertIsAlphanumericSpace('ab2c', true);
		assertIsAlphanumericSpace('ab-c', false);
	}

	private static void assertIsAlphanumericSpace(String str, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.isAlphanumericSpace(str);
		System.assert(actual == expected, 'CMN_UTIL_String.isAlphanumericSpace(\'' + str + '\') returned ' + actual);
	}

	@IsTest
	private static void testIsAsciiPrintable()
	{
		//test: global static Boolean isAsciiPrintable(String str) {
		assertIsAsciiPrintable(null, false);
		assertIsAsciiPrintable('', true);
		assertIsAsciiPrintable(' ', true);
		assertIsAsciiPrintable('Ceki', true);
		assertIsAsciiPrintable('ab2c', true);
		assertIsAsciiPrintable('!ab-c~', true);
		assertIsAsciiPrintable(' ', true);
		assertIsAsciiPrintable('!', true);
		assertIsAsciiPrintable('~', true);
		assertIsAsciiPrintable('', false);
		assertIsAsciiPrintable('Ceki Gülcü', false);
	}

	private static void assertIsAsciiPrintable(String str, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.isAsciiPrintable(str);
		System.assert(actual == expected, 'CMN_UTIL_String.isAsciiPrintable(\'' + str + '\') returned ' + actual);
	}

	/**
	 * @description Tests the behaviour of related method
	 *
	 * @see CMN_UTIL_String.isNumeric
	 */
	@IsTest
	private static void isNumeric()
	{
		assertIsNumeric('  ', false);
		assertIsNumeric(' 123', false);
		assertIsNumeric('', false);
		assertIsNumeric('12 3', false);
		assertIsNumeric('12-3', false);
		assertIsNumeric('12.3', false);
		assertIsNumeric('123', true);
		assertIsNumeric('ab2c', false);
		assertIsNumeric(null, false);
	}

	private static void assertIsNumeric(String str, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.isNumeric(str);
		Assert.areEqual(expected, actual, 'CMN_UTIL_String.isNumeric(\'' + str + '\') returned ' + actual);
	}

	/**
	 * @description Tests the behaviour of related method
	 *
	 * @see CMN_UTIL_String.isWhitespace
	 */
	@IsTest
	private static void isWhitespace()
	{
		assertIsWhitespace('  ', true);
		assertIsWhitespace('', true);
		assertIsWhitespace('ab-c', false);
		assertIsWhitespace('ab2c', false);
		assertIsWhitespace('abc', false);
		assertIsWhitespace(null, false);
	}

	private static void assertIsWhitespace(String str, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.isWhitespace(str);
		Assert.areEqual(expected, actual, 'CMN_UTIL_String.isWhitespace(\'' + str + '\') returned ' + actual);
	}

	@IsTest
	private static void testLength()
	{
		assertLength(null, 0);
		assertLength('', 0);
		assertLength(' ', 1);
		assertLength('bob', 3);
		assertLength('  bob  ', 7);
	}

	private static void assertLength(String str, Integer expected)
	{
		Integer actual = CMN_UTIL_String.length(str);
		System.assert(actual == expected, 'CMN_UTIL_String.length(\'' + str + '\') returned ' + actual);
	}

	@IsTest
	private static void testIsBlank()
	{
		assertOnIsBlank(true, null);
		assertOnIsBlank(true, '');
		assertOnIsBlank(true, '     ');
		assertOnIsBlank(true, '\n');
		assertOnIsBlank(false, 'x');
		assertOnIsBlank(false, ' x');
		assertOnIsBlank(false, 'asdfasdfasdf ');
	}

	private static void assertOnIsBlank(Boolean expectedReturnValue, String theString)
	{
		System.assert(CMN_UTIL_String.isBlank(theString) == expectedReturnValue,
				'CMN_UTIL_String.isBlank(\'' + (theString == null ? 'null' : theString) + '\') returned ' + !expectedReturnValue);
	}

	@IsTest
	private static void testIsNotBlank()
	{
		assertOnIsNotBlank(false, null);
		assertOnIsNotBlank(false, '');
		assertOnIsNotBlank(false, '     ');
		assertOnIsNotBlank(false, '\n');
		assertOnIsNotBlank(true, 'x');
		assertOnIsNotBlank(true, ' x');
		assertOnIsNotBlank(true, 'asdfasdfasdf ');
	}

	private static void assertOnIsNotBlank(Boolean expectedReturnValue, String theString)
	{
		System.assert(CMN_UTIL_String.isNotBlank(theString) == expectedReturnValue,
				'CMN_UTIL_String.isNotBlank(\'' + (theString == null ? 'null' : theString) + '\') returned ' + !expectedReturnValue);
	}

	@IsTest
	private static void testTrim()
	{
		assertTrim(null, null);
		assertTrim('', '');
		assertTrim('a', 'a');
		assertTrim('\n', '');
		assertTrim('   ', '');
	}

	private static void assertTrim(String str, String expected)
	{
		String actual = CMN_UTIL_String.trim(str);
		System.assert(actual == expected, 'CMN_UTIL_String.trim(\'' + str + '\') returned [' + actual + '], expected [' + expected + ']');
	}

	@IsTest
	private static void testJoinStrings()
	{
		assertJoinStrings(null, null, null);
		assertJoinStrings(new Set<String>(), ':', null);
		assertJoinStrings(new Set<String> {'a', 'b', 'c'}, ':', 'a:c:b');
		assertJoinStrings(new Set<String> {' ', 'b', 'c'}, ':', 'c:b');
	}

	private static void assertJoinStrings(Set<String> strings, String separator, String expectedReturnValue)
	{
		String actual = CMN_UTIL_String.joinStrings(strings, separator);
		if(strings == null || strings.size() <= 0)
		{
			System.assert(CMN_UTIL_String.isBlank(expectedReturnValue), 'CMN_UTIL_String.joinStrings(Set<String>, \'' +
					(separator == null ? 'null' : separator) + '\') returned ' + actual);
			return;
		}
		Set<String> actualAsSet = new Set<String>(CMN_UTIL_String.split(actual, separator));
		Set<String> expectedAsSet = new Set<String>(CMN_UTIL_String.split(expectedReturnValue, separator));
		System.assert(actualAsSet.containsAll(expectedAsSet) && expectedAsSet.containsAll(actualAsSet),
				'CMN_UTIL_String.joinStrings(Set<String>, \'' + (separator == null ? 'null' : separator) + '\') returned ' +
				actual + '; expected: ' + expectedReturnValue);
	}

	@IsTest
	private static void testJoinStringsList()
	{
		assertJoinStringsList(null, null, null);
		assertJoinStringsList(new List<String>(), ':', null);
		assertJoinStringsList(new List<String> {'a', 'b', 'c'}, ':', 'a:c:b');
		assertJoinStringsList(new List<String> {' ', 'b', 'c'}, ':', 'c:b');
	}

	private static void assertJoinStringsList(List<String> strings, String separator, String expectedReturnValue)
	{
		String actual = CMN_UTIL_String.joinStrings(strings, separator);
		if(strings == null || strings.size() <= 0)
		{
			System.assert(CMN_UTIL_String.isBlank(expectedReturnValue), 'CMN_UTIL_String.joinStrings(List<String>, \'' +
					(separator == null ? 'null' : separator) + '\') returned ' + actual);
			return;
		}
		Set<String> actualAsSet = new Set<String>(CMN_UTIL_String.split(actual, separator));
		Set<String> expectedAsSet = new Set<String>(CMN_UTIL_String.split(expectedReturnValue, separator));
		System.assert(actualAsSet.containsAll(expectedAsSet) && expectedAsSet.containsAll(actualAsSet),
				'CMN_UTIL_String.joinStrings(List<String>, \'' + (separator == null ? 'null' : separator) + '\') returned ' +
				actual + '; expected: ' + expectedReturnValue);
	}

	@IsTest
	private static void testEndsWith()
	{
		assertEndsWith(null, null, true);
		assertEndsWith('abcdef', null, false);
		assertEndsWith(null, 'def', false);
		assertEndsWith('abcdef', 'def', true);
		assertEndsWith('ABCDEF', 'def', false);
	}

	@IsTest
	private static void testEndsWithIgnoreCase()
	{
		assertEndsWithIgnoreCase(null, null, true);
		assertEndsWithIgnoreCase('abcdef', null, false);
		assertEndsWithIgnoreCase(null, 'def', false);
		assertEndsWithIgnoreCase('abcdef', 'def', true);
		assertEndsWithIgnoreCase('ABCDEF', 'def', true);
		assertEndsWithIgnoreCase('ABCDEF', 'ABCDEFA', false);
	}

	private static void assertEndsWith(String str, String suffix, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.endsWith(str, suffix);
		System.assert(actual == expected, 'CMN_UTIL_String.endsWith(\'' + str + '\',\'' + suffix + '\') returned ' + actual);
	}

	private static void assertEndsWithIgnoreCase(String str, String suffix, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.endsWithIgnoreCase(str, suffix);
		System.assert(actual == expected, 'CMN_UTIL_String.endsWithIgnoreCase(\'' + str + '\',\'' + suffix + '\') returned ' + actual);
	}

	@IsTest
	private static void testContains()
	{
		assertContains(null, null, false);
		assertContains('abcdef', null, false);
		assertContains(null, 'def', false);
		assertContains('abcdef', 'ab', true);
		assertContains('abcdef', 'xab', false);
		assertContains('ABCDEF', 'AB', true);
		assertContains('ABCDEF', 'Ab', false);

		assertContains('abcdef', 'ef', true);
		assertContains('abcdef', 'xef', false);
		assertContains('ABCDEF', 'EF', true);
		assertContains('ABCDEF', 'Ef', false);

		assertContains('abcdef', 'cde', true);
		assertContains('abcdef', 'xcde', false);
		assertContains('ABCDEF', 'CDE', true);
		assertContains('ABCDEF', 'CDe', false);
	}

	private static void assertContains(String str, String searchStr, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.contains(str, searchStr);
		System.assert(actual == expected, 'CMN_UTIL_String.contains(\'' + str + '\',\'' + searchStr + '\') returned ' + actual);
	}

	@IsTest
	private static void testContainsIgnoreCase()
	{
		assertContainsIgnoreCase(null, null, false);
		assertContainsIgnoreCase('abcdef', null, false);
		assertContainsIgnoreCase(null, 'def', false);
		assertContainsIgnoreCase('abcdef', 'ab', true);
		assertContainsIgnoreCase('abcdef', 'xab', false);
		assertContainsIgnoreCase('ABCDEF', 'AB', true);
		assertContainsIgnoreCase('ABCDEF', 'Ab', true);
	}

	private static void assertContainsIgnoreCase(String str, String searchStr, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.containsIgnoreCase(str, searchStr);
		System.assert(actual == expected, 'CMN_UTIL_String.containsIgnoreCase(\'' + str + '\',\'' + searchStr + '\') returned ' + actual);
	}

	@IsTest
	private static void testSplitOneArg()
	{
		assertSplitOneArg(null, null);
		assertSplitOneArg('', new List<String> {''});
		assertSplitOneArg('abc def', new List<String> {'abc', 'def'});
		assertSplitOneArg('abc  def', new List<String> {'abc', 'def'});
		assertSplitOneArg(' abc ', new List<String> {'abc'});
	}

	private static void assertSplitOneArg(String str, List<String> expected)
	{
		List<String> actual = CMN_UTIL_String.split(str);
		if(actual == null)
		{
			System.assert(expected == null, 'CMN_UTIL_String.split(\'' + str + '\') returned ' + CMN_UTIL_Array.toString(actual));
			return;
		}
		for(Integer i = 0; i < actual.size(); i++)
		{
			System.assert(expected[i] == actual[i], 'CMN_UTIL_String.split(\'' + str + '\') returned ' + CMN_UTIL_Array.toString(actual));
		}
	}

	/**
	 * @description Will check that a string is split into equal chunks (except, potentially for last chunk)
	 *
	 * @see CMN_UTIL_String.split
	 */
	@IsTest
	private static void splitIntoChunks()
	{
		Test.startTest();

		assertChunks('12345', 1, new List<String> {'1', '2', '3', '4', '5'});
		assertChunks('', 1, new List<String> {''});
		assertChunks(null, 1, new List<String>());
		assertChunks('12345', 0, new List<String>());
		assertChunks('123451234', 5, new List<String> {'12345', '1234'});

		Test.stopTest();
	}

	/**
	 * @description Will split the string into chunks and then check that the outcome is as expected
	 *
	 * @param aStr The string to split
	 * @param chunkSize The size of the chunk
	 * @param expectedChunks A list that should matched the split strings list
	 */
	private static void assertChunks(String aStr, Integer chunkSize, List<String> expectedChunks)
	{
		List<String> chunks = CMN_UTIL_String.split(aStr, chunkSize);
		Assert.areEqual(expectedChunks, chunks, 'String was not split correctly');
	}

	@IsTest
	private static void testSplitOneArgPreserveAllTokens()
	{
		assertSplitOneArgPreserveAllTokens(null, null);
		assertSplitOneArgPreserveAllTokens('', new List<String> {''});
		assertSplitOneArgPreserveAllTokens('abc def', new List<String> {'abc', 'def'});
		assertSplitOneArgPreserveAllTokens('abc  def', new List<String> {'abc', '', 'def'});
		assertSplitOneArgPreserveAllTokens(' abc ', new List<String> {'', 'abc', ''});
		assertSplitOneArgPreserveAllTokens('a b c', new List<String> {'a', 'b', 'c'});
	}

	private static void assertSplitOneArgPreserveAllTokens(String str, List<String> expected)
	{
		List<String> actual = CMN_UTIL_String.splitPreserveAllTokens(str);
		if(actual == null)
		{
			System.assert(expected == null, 'CMN_UTIL_String.splitPreserveAllTokens(\'' + str + '\') returned ' + CMN_UTIL_Array.toString(actual));
			return;
		}
		for(Integer i = 0; i < actual.size(); i++)
		{
			System.assert(expected[i] == actual[i], 'CMN_UTIL_String.splitPreserveAllTokens(\'' + str + '\') returned ' + CMN_UTIL_Array.toString(actual));
		}
	}

	@IsTest
	private static void testCharAt()
	{
		assertCharAt(null, -1, null);
		assertCharAt(null, 0, null);
		assertCharAt('abc', -1, null);
		assertCharAt('abc', 3, null);
		assertCharAt('abc', 0, 'a');
		assertCharAt('abc', 2, 'c');
		assertCharAt('abcde', -2, null);
		assertCharAt('abcde', 0, 'a');
		assertCharAt('abcde', 1, 'b');
		assertCharAt('abcde', 4, 'e');
		assertCharAt('abcde', 5, null);
		assertCharAt('', 0, '');
		assertCharAt(' ', 0, ' ');
	}

	private static void assertCharAt(String str, Integer index, String expected)
	{
		String actual = CMN_UTIL_String.charAt(str, index);
		System.assert(actual == expected, 'CMN_UTIL_String.charAt(\'' + str + '\',' + index + ') returned ' + actual);
	}

	@IsTest
	private static void testSplitTwoArgs()
	{
		assertSplitTwoArgs(null, null, null);
		assertSplitTwoArgs('', null, new List<String> {''});
		assertSplitTwoArgs('', 'abc', new List<String> {''});
		assertSplitTwoArgs('a.b.c', '.', new List<String> {'a', 'b', 'c'});
		assertSplitTwoArgs('a..b.c', '.', new List<String> {'a', 'b', 'c'});
		assertSplitTwoArgs('a..b..c', '..', new List<String> {'a', 'b', 'c'});
		assertSplitTwoArgs('a:b:c', '.', new List<String> {'a:b:c'});
		assertSplitTwoArgs('a b c', ' ', new List<String> {'a', 'b', 'c'});
	}

	private static void assertSplitTwoArgs(String str, String separator, List<String> expected)
	{
		List<String> actual = CMN_UTIL_String.split(str, separator);
		if(actual == null)
		{
			System.assert(expected == null, 'CMN_UTIL_String.split(\'' + str + '\',\'' + separator + '\') returned ' + CMN_UTIL_Array.toString(actual));
			return;
		}
		for(Integer i = 0; i < actual.size(); i++)
		{
			System.assert(expected[i] == actual[i], 'CMN_UTIL_String.split(\'' + str + '\',\'' + separator + '\') returned ' + CMN_UTIL_Array.toString(actual));
		}
	}

	@IsTest
	private static void testSplitThreeArgs()
	{
		assertSplitThreeArgs(null, '', 1, null);
		assertSplitThreeArgs('', '', 1, new List<String> {''});
		assertSplitThreeArgs('ab cd ef', null, 0, new List<String> {'ab', 'cd', 'ef'});
		assertSplitThreeArgs('ab   cd ef', null, 0, new List<String> {'ab', 'cd', 'ef'});
		assertSplitThreeArgs('ab:cd:ef', ':', 0, new List<String> {'ab', 'cd', 'ef'});
		assertSplitThreeArgs('ab:cd:ef', ':', 2, new List<String> {'ab', 'cd:ef'});
	}

	private static void assertSplitThreeArgs(String str, String separator, Integer max, List<String> expected)
	{
		List<String> actual = CMN_UTIL_String.split(str, separator, max);
		if(actual == null)
		{
			System.assert(expected == null, 'CMN_UTIL_String.split(\'' + str + '\',\'' + separator + '\',' +
					max + ') returned ' + CMN_UTIL_Array.toString(actual));
			return;
		}
		for(Integer i = 0; i < actual.size(); i++)
		{
			System.assert(expected[i] == actual[i], 'CMN_UTIL_String.split(\'' + str + '\',\'' + separator + '\',' +
					max + ') returned ' + CMN_UTIL_Array.toString(actual));
		}
	}

	@IsTest
	private static void testSplitByWholeSeparatorTwoArg()
	{
		assertSplitByWholeSeparatorTwoArg(null, null, null);
		assertSplitByWholeSeparatorTwoArg('', null, new List<String> {''});
		assertSplitByWholeSeparatorTwoArg('ab cd ef', null, new List<String> {'ab', 'cd', 'ef'});
		assertSplitByWholeSeparatorTwoArg('ab cd ef', ' ', new List<String> {'ab', 'cd', 'ef'});
		assertSplitByWholeSeparatorTwoArg('ab     cd ef', null, new List<String> {'ab', 'cd', 'ef'});
		assertSplitByWholeSeparatorTwoArg('ab:cd:ef', ':', new List<String> {'ab', 'cd', 'ef'});
		assertSplitByWholeSeparatorTwoArg('ab-!-cd-!-ef', '-!-', new List<String> {'ab', 'cd', 'ef'});
	}

	private static void assertSplitByWholeSeparatorTwoArg(String str, String separator, List<String> expected)
	{
		List<String> actual = CMN_UTIL_String.splitByWholeSeparator(str, separator);
		if(actual == null)
		{
			System.assert(expected == null, 'CMN_UTIL_String.splitByWholeSeparator(\'' + str + '\',\'' +
					separator + '\') returned ' + CMN_UTIL_Array.toString(actual));
			return;
		}
		for(Integer i = 0; i < actual.size(); i++)
		{
			System.assert(expected[i] == actual[i], 'CMN_UTIL_String.splitByWholeSeparator(\'' + str + '\',\'' +
					separator + '\') returned ' + CMN_UTIL_Array.toString(actual));
		}
	}

	@IsTest
	private static void testSplitPreserveAllTokensTwoArg()
	{
		//test global static List<String> splitPreserveAllTokens(String str, String separatorChars) {
		assertSplitPreserveAllTokensTwoArg(null, null, null);
		assertSplitPreserveAllTokensTwoArg('', null, new List<String> {''});
		assertSplitPreserveAllTokensTwoArg('abc def', null, new List<String> {'abc', 'def'});
		assertSplitPreserveAllTokensTwoArg('abc def', ' ', new List<String> {'abc', 'def'});
		assertSplitPreserveAllTokensTwoArg('abc  def', ' ', new List<String> {'abc', '', 'def'});
		assertSplitPreserveAllTokensTwoArg('ab:cd:ef', ':', new List<String> {'ab', 'cd', 'ef'});
		assertSplitPreserveAllTokensTwoArg('ab:cd:ef:', ':', new List<String> {'ab', 'cd', 'ef', ''});
		assertSplitPreserveAllTokensTwoArg('ab:cd:ef::', ':', new List<String> {'ab', 'cd', 'ef', '', ''});
		assertSplitPreserveAllTokensTwoArg('ab::cd:ef', ':', new List<String> {'ab', '', 'cd', 'ef'});
		assertSplitPreserveAllTokensTwoArg(':cd:ef', ':', new List<String> {'', 'cd', 'ef'});
		assertSplitPreserveAllTokensTwoArg('::cd:ef', ':', new List<String> {'', '', 'cd', 'ef'});
		assertSplitPreserveAllTokensTwoArg(':cd:ef:', ':', new List<String> {'', 'cd', 'ef', ''});
	}

	private static void assertSplitPreserveAllTokensTwoArg(String str, String separator, List<String> expected)
	{
		List<String> actual = CMN_UTIL_String.splitPreserveAllTokens(str, separator);
		if(actual == null)
		{
			System.assert(expected == null, 'CMN_UTIL_String.splitPreserveAllTokens(\'' + str + '\',\'' +
					separator + '\') returned ' + CMN_UTIL_Array.toString(actual));
			return;
		}
		for(Integer i = 0; i < actual.size(); i++)
		{
			System.assert(expected[i] == actual[i], 'CMN_UTIL_String.splitPreserveAllTokens(\'' + str + '\',\'' +
					separator + '\') returned ' + CMN_UTIL_Array.toString(actual));
		}
	}

	@IsTest
	private static void testSplitPreserveAllTokensThreeArgs()
	{
		//test global static List<String> splitPreserveAllTokens(String str, String separatorChars, Integer max) {
		assertSplitPreserveAllTokensThreeArgs(null, null, -1, null);
		assertSplitPreserveAllTokensThreeArgs('', null, -1, new List<String> {''});
		assertSplitPreserveAllTokensThreeArgs('ab cd ef', null, 0, new List<String> {'ab', 'cd', 'ef'});
		assertSplitPreserveAllTokensThreeArgs('ab   cd ef', null, 0, new List<String> {'ab', '', '', 'cd', 'ef'});
		assertSplitPreserveAllTokensThreeArgs('ab:cd:ef', ':', 0, new List<String> {'ab', 'cd', 'ef'});
		assertSplitPreserveAllTokensThreeArgs('ab:cd:ef', ':', 2, new List<String> {'ab', 'cd:ef'});
		assertSplitPreserveAllTokensThreeArgs('ab::cd::ef', '::', 2, new List<String> {'ab', ':cd::ef'});
		assertSplitPreserveAllTokensThreeArgs('ab   de fg', null, 2, new List<String> {'ab', '  de fg'});
		assertSplitPreserveAllTokensThreeArgs('ab   de fg', null, 3, new List<String> {'ab', '', ' de fg'});
		assertSplitPreserveAllTokensThreeArgs('ab   de fg', null, 4, new List<String> {'ab', '', '', 'de fg'});
	}

	private static void assertSplitPreserveAllTokensThreeArgs(String str, String separatorChars,
			Integer max, List<String> expected)
	{

		List<String> actual = CMN_UTIL_String.splitPreserveAllTokens(str, separatorChars, max);
		if(actual == null)
		{
			System.assert(expected == null, 'CMN_UTIL_String.splitPreserveAllTokens(\'' + str + '\',\'' +
					separatorChars + '\',' + max + ') returned ' + CMN_UTIL_Array.toString(actual));
			return;
		}
		for(Integer i = 0; i < actual.size(); i++)
		{
			System.assert(expected[i] == actual[i], 'CMN_UTIL_String.splitPreserveAllTokens(\'' + str + '\',\'' +
					separatorChars + '\',' + max + ') returned ' + CMN_UTIL_Array.toString(actual));
		}
	}

	@IsTest
	private static void testSplitByWholeSeparatorThreeArgs()
	{
		//test global static List<String> splitByWholeSeparator(String str, String separator, Integer max ) {

		assertTestSplitByWholeSeparatorThreeArgs(null, null, 0, null);
		assertTestSplitByWholeSeparatorThreeArgs('', null, 0, new List<String> {''});
		assertTestSplitByWholeSeparatorThreeArgs('ab cd ef', null, 0, new List<String> {'ab', 'cd', 'ef'});
		assertTestSplitByWholeSeparatorThreeArgs('ab cd ef', ' ', 0, new List<String> {'ab', 'cd', 'ef'});
		assertTestSplitByWholeSeparatorThreeArgs('ab     cd ef', null, 0, new List<String> {'ab', 'cd', 'ef'});
		assertTestSplitByWholeSeparatorThreeArgs('ab:cd:ef', ':', 1, new List<String> {'ab:cd:ef'});
		assertTestSplitByWholeSeparatorThreeArgs('ab:cd:ef', ':', 2, new List<String> {'ab', 'cd:ef'});
		assertTestSplitByWholeSeparatorThreeArgs('ab:cd:ef', ':', 3, new List<String> {'ab', 'cd', 'ef'});
		assertTestSplitByWholeSeparatorThreeArgs('ab-!-cd-!-ef', '-!-', 5, new List<String> {'ab', 'cd', 'ef'});
		assertTestSplitByWholeSeparatorThreeArgs('ab-!-cd-!-ef', '-!-', 2, new List<String> {'ab', 'cd-!-ef'});
	}
	private static void assertTestSplitByWholeSeparatorThreeArgs(String str, String separator,
			Integer max, List<String> expected)
	{

		List<String> actual = CMN_UTIL_String.splitByWholeSeparator(str, separator, max);
		if(actual == null)
		{
			System.assert(expected == null, 'CMN_UTIL_String.splitByWholeSeparator(\'' + str + '\',\'' +
					separator + '\',' + max + ') returned ' + CMN_UTIL_Array.toString(actual));
			return;
		}
		for(Integer i = 0; i < actual.size(); i++)
		{
			System.assert(expected[i] == actual[i], 'CMN_UTIL_String.splitByWholeSeparator(\'' + str + '\',\'' +
					separator + '\',' + max + ') returned ' + CMN_UTIL_Array.toString(actual));
		}
	}

	@IsTest
	private static void testSplitByWholeSeparatorPreserveAllTokensTwoArgs()
	{
		//test global static List<String> splitByWholeSeparatorPreserveAllTokens(String str, String separator) {
		assertSplitByWholeSeparatorPreserveAllTokensTwoArgs(null, null, null);
		assertSplitByWholeSeparatorPreserveAllTokensTwoArgs('', null, new List<String> {''});
		assertSplitByWholeSeparatorPreserveAllTokensTwoArgs('ab cd ef', null, new List<String> {'ab', 'cd', 'ef'});
		assertSplitByWholeSeparatorPreserveAllTokensTwoArgs('ab cd ef', ' ', new List<String> {'ab', 'cd', 'ef'});
		assertSplitByWholeSeparatorPreserveAllTokensTwoArgs('ab   cd ef', null, new List<String> {'ab', '', '', 'cd', 'ef'});
		assertSplitByWholeSeparatorPreserveAllTokensTwoArgs('ab:cd:ef', ':', new List<String> {'ab', 'cd', 'ef'});
		assertSplitByWholeSeparatorPreserveAllTokensTwoArgs('ab-!-cd-!-ef', '-!-', new List<String> {'ab', 'cd', 'ef'});
		assertSplitByWholeSeparatorPreserveAllTokensTwoArgs('ab-!--!-cd-!-ef', '-!-', new List<String> {'ab', '', 'cd', 'ef'});
	}
	private static void assertSplitByWholeSeparatorPreserveAllTokensTwoArgs(String str, String separator, List<String> expected)
	{

		List<String> actual = CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens(str, separator);
		if(actual == null)
		{
			System.assert(expected == null, 'CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens(\'' + str + '\',\'' +
					separator + '\') returned ' + CMN_UTIL_Array.toString(actual));
			return;
		}
		for(Integer i = 0; i < actual.size(); i++)
		{
			System.assert(expected[i] == actual[i], 'CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens(\'' + str + '\',\'' +
					separator + '\') returned ' + CMN_UTIL_Array.toString(actual));
		}
	}

	@IsTest
	private static void testSplitByWholeSeparatorPreserveAllTokensThreeArgs()
	{
		//test global static List<String> splitByWholeSeparatorPreserveAllTokens(String str, String separator, Integer max) {

		assertSplitByWholeSeparatorPreserveAllTokensThreeArgs(null, null, 0, null);
		assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('', null, 0, new List<String> {''});
		assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab cd ef', null, 0, new List<String> {'ab', 'cd', 'ef'});
		assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab cd ef', ' ', 0, new List<String> {'ab', 'cd', 'ef'});
		assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab   cd ef', ' ', 0, new List<String> {'ab', '', '', 'cd', 'ef'});
		assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab:cd:ef', ':', 1, new List<String> {'ab:cd:ef'});
		assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab:cd:ef', ':', 2, new List<String> {'ab', 'cd:ef'});
		assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab:cd:ef', ':', 3, new List<String> {'ab', 'cd', 'ef'});
		assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab::cd:ef', ':', 2, new List<String> {'ab', ':cd:ef'});
		assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab-!-cd-!-ef', '-!-', 5, new List<String> {'ab', 'cd', 'ef'});
		assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab-!-cd-!-ef', '-!-', 2, new List<String> {'ab', 'cd-!-ef'});
	}
	private static void assertSplitByWholeSeparatorPreserveAllTokensThreeArgs(String str, String separator,
			Integer max, List<String> expected)
	{

		List<String> actual = CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens(str, separator, max);
		if(actual == null)
		{
			System.assert(expected == null, 'CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens(\'' + str + '\',\'' +
					separator + '\',' + max + ') returned ' + CMN_UTIL_Array.toString(actual));
			return;
		}
		for(Integer i = 0; i < actual.size(); i++)
		{
			System.assert(expected[i] == actual[i], 'CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens(\'' + str + '\',\'' +
					separator + '\',' + max + ') returned ' + CMN_UTIL_Array.toString(actual));
		}
	}

	@IsTest
	private static void testLeftPadTwoArgs()
	{
		// test: global static String leftPad(String str, Integer size) {
		assertLeftPadTwoArgs(null, -1, null);
		assertLeftPadTwoArgs('', 3, '   ');
		assertLeftPadTwoArgs('bat', 3, 'bat');
		assertLeftPadTwoArgs('bat', 5, '  bat');
		assertLeftPadTwoArgs('bat', 1, 'bat');
		assertLeftPadTwoArgs('bat', -1, 'bat');
	}

	private static void assertLeftPadTwoArgs(String str, Integer size, String expected)
	{
		String actual = CMN_UTIL_String.leftPad(str, size);
		System.assert(actual == expected, 'CMN_UTIL_String.leftPad(\'' + str + '\','
				+ size + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testLeftPadThreeArgs()
	{
		//test: global static String leftPad(String str, Integer size, String padStr) {
		assertLeftPadThreeArgs(null, -1, null, null);
		assertLeftPadThreeArgs('', 3, 'z', 'zzz');
		assertLeftPadThreeArgs('bat', 3, 'yz', 'bat');
		assertLeftPadThreeArgs('bat', 5, 'yz', 'yzbat');
		assertLeftPadThreeArgs('bat', 8, 'yz', 'yzyzybat');
		assertLeftPadThreeArgs('bat', 1, 'yz', 'bat');
		assertLeftPadThreeArgs('bat', -1, 'yz', 'bat');
		assertLeftPadThreeArgs('bat', 5, null, '  bat');
		assertLeftPadThreeArgs('bat', 5, '', '  bat');
	}

	private static void assertLeftPadThreeArgs(String str, Integer size, String padStr, String expected)
	{
		String actual = CMN_UTIL_String.leftPad(str, size, padStr);
		System.assert(actual == expected, 'CMN_UTIL_String.leftPad(\'' + str + '\','
				+ size + ',\'' + padStr + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testRightPadTwoArgs()
	{
		//test: global static String rightPad(String str, Integer size) {
		assertRightPadTwoArgs(null, -1, null);
		assertRightPadTwoArgs('', 3, '   ');
		assertRightPadTwoArgs('bat', 3, 'bat');
		assertRightPadTwoArgs('bat', 5, 'bat  ');
		assertRightPadTwoArgs('bat', 1, 'bat');
		assertRightPadTwoArgs('bat', -1, 'bat');
	}

	private static void assertRightPadTwoArgs(String str, Integer size, String expected)
	{
		String actual = CMN_UTIL_String.rightPad(str, size);
		System.assert(actual == expected, 'CMN_UTIL_String.rightPad(\'' + str + '\','
				+ size + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testRightPadThreeArgs()
	{
		//test: global static String rightPad(String str, Integer size, String padStr) {
		assertRightPadThreeArgs(null, -1, null, null);
		assertRightPadThreeArgs('', 3, '', '   ');
		assertRightPadThreeArgs('', 3, 'z', 'zzz');
		assertRightPadThreeArgs('bat', 3, 'z', 'bat');
		assertRightPadThreeArgs('bat', 5, 'z', 'batzz');
		assertRightPadThreeArgs('bat', 1, 'z', 'bat');
		assertRightPadThreeArgs('bat', -1, 'z', 'bat');
		assertRightPadThreeArgs('bat', 6, 'abcd', 'batabc');
	}

	private static void assertRightPadThreeArgs(String str, Integer size, String padStr, String expected)
	{
		String actual = CMN_UTIL_String.rightPad(str, size, padStr);
		System.assert(actual == expected, 'CMN_UTIL_String.rightPad(\'' + str + '\','
				+ size + ',\'' + padStr + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testGetCommonPrefix()
	{
		//test: global static String getCommonPrefix(List<String> strs) {
		assertGetCommonPrefix(null, '');
		assertGetCommonPrefix(null, '');
		assertGetCommonPrefix(new List<String> {}, '');
		assertGetCommonPrefix(new List<String> {'abc'}, 'abc');
		assertGetCommonPrefix(new List<String> {null, null}, '');
		assertGetCommonPrefix(new List<String> {'', ''}, '');
		assertGetCommonPrefix(new List<String> {'', null}, '');
		assertGetCommonPrefix(new List<String> {'abc', null, null}, '');
		assertGetCommonPrefix(new List<String> {null, null, 'abc'}, '');
		assertGetCommonPrefix(new List<String> {'', 'abc'}, '');
		assertGetCommonPrefix(new List<String> {'abc', ''}, '');
		assertGetCommonPrefix(new List<String> {'abc', 'abc'}, 'abc');
		assertGetCommonPrefix(new List<String> {'abc', 'a'}, 'a');
		assertGetCommonPrefix(new List<String> {'ab', 'abxyz'}, 'ab');
		assertGetCommonPrefix(new List<String> {'abcde', 'abxyz'}, 'ab');
		assertGetCommonPrefix(new List<String> {'abcde', 'xyz'}, '');
		assertGetCommonPrefix(new List<String> {'xyz', 'abcde'}, '');
		assertGetCommonPrefix(new List<String> {'i am a machine', 'i am a robot'}, 'i am a ');
	}

	private static void assertGetCommonPrefix(List<String> strs, String expected)
	{
		String actual = CMN_UTIL_String.getCommonPrefix(strs);
		System.assert(actual == expected, 'CMN_UTIL_String.getCommonPrefix(' + CMN_UTIL_Array.toString(strs)
				+ ') returned \'' + actual + '\', expected \'' + expected + '\'');
	}

	@IsTest
	private static void testIndexOfDifferenceArrayInput()
	{
		//test: global static Integer indexOfDifference(List<String> strs) {
		assertIndexOfDifferenceArrayInput(null, -1);
		assertIndexOfDifferenceArrayInput(new List<String> {}, -1);
		assertIndexOfDifferenceArrayInput(new List<String> {'abc'}, -1);
		assertIndexOfDifferenceArrayInput(new List<String> {null, null}, -1);
		assertIndexOfDifferenceArrayInput(new List<String> {'', ''}, -1);
		assertIndexOfDifferenceArrayInput(new List<String> {'', null}, 0);
		assertIndexOfDifferenceArrayInput(new List<String> {'abc', null, null}, 0);
		assertIndexOfDifferenceArrayInput(new List<String> {null, null, 'abc'}, 0);
		assertIndexOfDifferenceArrayInput(new List<String> {'', 'abc'}, 0);
		assertIndexOfDifferenceArrayInput(new List<String> {'abc', ''}, 0);
		assertIndexOfDifferenceArrayInput(new List<String> {'abc', 'abc'}, -1);
		assertIndexOfDifferenceArrayInput(new List<String> {'abc', 'a'}, 1);
		assertIndexOfDifferenceArrayInput(new List<String> {'ab', 'abxyz'}, 2);
		assertIndexOfDifferenceArrayInput(new List<String> {'abcde', 'abxyz'}, 2);
		assertIndexOfDifferenceArrayInput(new List<String> {'abcde', 'xyz'}, 0);
		assertIndexOfDifferenceArrayInput(new List<String> {'xyz', 'abcde'}, 0);
		assertIndexOfDifferenceArrayInput(new List<String> {'i am a machine', 'i am a robot'}, 7);
	}

	private static void assertIndexOfDifferenceArrayInput(List<String> strs, Integer expected)
	{
		Integer actual = CMN_UTIL_String.indexOfDifference(strs);
		System.assert(actual == expected, 'CMN_UTIL_String.indexOfDifference(' + CMN_UTIL_Array.toString(strs)
				+ ') returned ' + actual + '; expected ' + expected);
	}

	@IsTest
	private static void testGetLevenshteinDistance()
	{
		//test: global static Integer getLevenshteinDistance(String s, String t) {
		assertGetLevenshteinDistance(null, null, -1, true);
		assertGetLevenshteinDistance(null, null, -1, true);
		assertGetLevenshteinDistance('', '', 0, false);
		assertGetLevenshteinDistance('', 'a', 1, false);
		assertGetLevenshteinDistance('aaapppp', '', 7, false);
		assertGetLevenshteinDistance('frog', 'fog', 1, false);
		assertGetLevenshteinDistance('fly', 'ant', 3, false);
		assertGetLevenshteinDistance('elephant', 'hippo', 7, false);
		assertGetLevenshteinDistance('hippo', 'elephant', 7, false);
		assertGetLevenshteinDistance('hippo', 'zzzzzzzz', 8, false);
		assertGetLevenshteinDistance('hello', 'hallo', 1, false);
	}

	private static void assertGetLevenshteinDistance(String s, String t,
			Integer expected, Boolean excepExpected)
	{

		Integer actual = null;
		Boolean excepActual = false;
		try
		{
			actual = CMN_UTIL_String.getLevenshteinDistance(s, t);
		}
		catch(IllegalArgumentException e)
		{
			excepActual = true;
		}
		if(excepExpected && excepActual)
		{
			return;
		}
		System.assert(excepExpected == excepActual, 'CMN_UTIL_String.getLevenshteinDistance(\''
				+ s + '\',\'' + t + '\') '
				+ (excepExpected ? 'did not throw' : 'unexpectedly threw')
				+ ' IllegalArgumentException');
		if(!excepExpected && !excepActual)
		{
			System.assert(actual == expected, 'CMN_UTIL_String.getLevenshteinDistance(\'' + s + '\',\''
					+ t + '\') returned ' + actual + '; expected ' + expected);
		}
	}

	@IsTest
	private static void testIndexOfThreeArgs()
	{
		//test: global static Integer indexOf(String str, String searchStr, Integer startPos) {
		assertIndexOfThreeArgs(null, null, -1, -1);
		assertIndexOfThreeArgs('', '', 0, 0);
		assertIndexOfThreeArgs('aabaabaa', 'a', 0, 0);
		assertIndexOfThreeArgs('aabaabaa', 'b', 0, 2);
		assertIndexOfThreeArgs('aabaabaa', 'ab', 0, 1);
		assertIndexOfThreeArgs('aabaabaa', 'b', 3, 5);
		assertIndexOfThreeArgs('aabaabaa', 'b', 9, -1);
		assertIndexOfThreeArgs('aabaabaa', 'b', -1, 2);
		assertIndexOfThreeArgs('aabaabaa', '', 2, 2);
		assertIndexOfThreeArgs('abc', '', 9, 3);
	}

	private static void assertIndexOfThreeArgs(String str, String searchStr, Integer startPos, Integer expected)
	{
		Integer actual = CMN_UTIL_String.indexOf(str, searchStr, startPos);
		System.assert(actual == expected, 'CMN_UTIL_String.indexOf(\'' + str + '\',\''
				+ searchStr + '\',' + startPos + ') returned ' + actual + '; expected ' + expected);
	}

	@IsTest
	private static void testOrdinalIndexOf()
	{
		//test: global static Integer ordinalIndexOf(String str, String searchStr, Integer ordinal) {
		assertOrdinalIndexOf(null, null, -1, -1);
		assertOrdinalIndexOf('', '', -1, -1);
		assertOrdinalIndexOf('aabaabaa', 'a', 1, 0);
		assertOrdinalIndexOf('aabaabaa', 'a', 2, 1);
		assertOrdinalIndexOf('aabaabaa', 'b', 1, 2);
		assertOrdinalIndexOf('aabaabaa', 'b', 2, 5);
		assertOrdinalIndexOf('aabaabaa', 'ab', 1, 1);
		assertOrdinalIndexOf('aabaabaa', 'ab', 2, 4);
		assertOrdinalIndexOf('aabaabaa', 'z', 1, -1);
		assertOrdinalIndexOf('aabaabaa', '', 1, 0);
		assertOrdinalIndexOf('aabaabaa', '', 2, 0);
	}

	private static void assertOrdinalIndexOf(String str, String searchStr, Integer ordinal, Integer expected)
	{
		Integer actual = CMN_UTIL_String.ordinalIndexOf(str, searchStr, ordinal);
		System.assert(actual == expected, 'CMN_UTIL_String.ordinalIndexOf(\'' + str + '\',\''
				+ searchStr + '\',' + ordinal + ') returned ' + actual + '; expected ' + expected);
	}

	@IsTest
	private static void testValidateChar()
	{
		try
		{
			CMN_UTIL_Character.validateChar('ab'); //should throw exception since string has > 1 chars
			System.assert(false, 'CMN_UTIL_Character.validateChar(\'ab\') did not throw CMN_UTIL_Exceptions.InvalidCharacterStringException');
		}
		catch(CMN_UTIL_Exceptions.InvalidCharacterStringException e)
		{
		}
	}

	@IsTest
	private static void testJoinArrayOneArg()
	{
		//test: global static String joinArray(List<Object> objectArray) {
		assertJoinArrayOneArg(null, null);
		assertJoinArrayOneArg(new List<String> {}, '');
		assertJoinArrayOneArg(new List<String> {null}, '');
		assertJoinArrayOneArg(new List<String> {'a', 'b', 'c'}, 'abc');
		assertJoinArrayOneArg(new List<String> {null, '', 'a'}, 'a');
	}

	private static void assertJoinArrayOneArg(List<Object> objectArray, String expected)
	{
		String actual = CMN_UTIL_String.joinArray(objectArray);
		System.assert(actual == expected, 'CMN_UTIL_String.joinArray(\'' + CMN_UTIL_Array.toString(objectArray) + '\') returned \'' +
				actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testJoinArrayTwoArgs()
	{
		//test: global static String joinArray(List<Object> objectArray, String separator) {
		assertJoinArrayTwoArgs(null, null, null);
		assertJoinArrayTwoArgs(new List<String> {}, null, '');
		assertJoinArrayTwoArgs(new List<String> {null}, null, '');
		assertJoinArrayTwoArgs(new List<String> {'a', 'b', 'c'}, ';', 'a;b;c');
		assertJoinArrayTwoArgs(new List<String> {'a', 'b', 'c'}, null, 'abc');
		assertJoinArrayTwoArgs(new List<String> {null, '', 'a'}, ';', ';a');
	}

	private static void assertJoinArrayTwoArgs(List<Object> objectArray, String separator, String expected)
	{
		String actual = CMN_UTIL_String.joinArray(objectArray, separator);
		System.assert(actual == expected, 'CMN_UTIL_String.joinArray(\'' + CMN_UTIL_Array.toString(objectArray) + '\',\''
				+ separator + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testJoinArrayFourArgs()
	{
		//test: global static String joinArray(List<Object> objectArray, String separator, Integer startIndex, Integer endIndex) {
		assertJoinArrayFourArgs(null, null, 0, 2, null);
		assertJoinArrayFourArgs(new List<String> {}, null, 0, 1, '');
		assertJoinArrayFourArgs(new List<String> {null}, null, 0, 1, '');
		assertJoinArrayFourArgs(new List<String> {'a', 'b', 'c'}, '--', 0, 3, 'a--b--c');
		assertJoinArrayFourArgs(new List<String> {'a', 'b', 'c'}, null, 0, 3, 'abc');
		assertJoinArrayFourArgs(new List<String> {'a', 'b', 'c'}, '', 0, 0, '');
		assertJoinArrayFourArgs(new List<String> {'a', 'b', 'c'}, '', 0, 1, 'a');
		assertJoinArrayFourArgs(new List<String> {'a', 'b', 'c'}, '', 0, 2, 'ab');
		assertJoinArrayFourArgs(new List<String> {'a', 'b', 'c'}, '', 0, 3, 'abc');
		assertJoinArrayFourArgs(new List<String> {'a', 'b', 'c'}, '', -1, 4, 'abc');
		assertJoinArrayFourArgs(new List<String> {'a', 'b', 'c'}, '', 1, 1, '');
		assertJoinArrayFourArgs(new List<String> {'a', 'b', 'c'}, '', 1, 2, 'b');
		assertJoinArrayFourArgs(new List<String> {'a', 'b', 'c'}, '', 1, 3, 'bc');
		assertJoinArrayFourArgs(new List<String> {'a', 'b', 'c'}, '', 2, 2, '');
		assertJoinArrayFourArgs(new List<String> {'a', 'b', 'c'}, '', 2, 3, 'c');
		assertJoinArrayFourArgs(new List<String> {null, '', 'a'}, ',', 0, 3, ',a');
		assertJoinArrayFourArgs(new List<Long> {3, 4, -1}, 'xyz', 0, 3, '3xyz4xyz-1');
	}

	private static void assertJoinArrayFourArgs(List<Object> objectArray, String separator, Integer startIndex, Integer endIndex, String expected)
	{
		String actual = CMN_UTIL_String.joinArray(objectArray, separator, startIndex, endIndex);
		System.assert(actual == expected, 'CMN_UTIL_String.joinArray(\'' + CMN_UTIL_Array.toString(objectArray) + '\',\''
				+ separator + '\',' + startIndex + ',' + endIndex + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testJoinSetBlobSet()
	{
		//global static String joinSet(Set<Blob> blobSet, String separator)
		assertJoinSetBlobSet(null, '|', null);
		assertJoinSetBlobSet(new Set<Blob> {}, '|', '');
		Blob blob1 = generateRandomBlob();
		Blob blob2 = generateRandomBlob();
		assertJoinSetBlobSet(new Set<Blob> {blob1}, '|', '\'' + blob1.toString() + '\'');
		assertJoinSetBlobSet(new Set<Blob> {blob1, blob2}, '|', '\'' + blob1.toString() + '\'|\'' + blob2.toString() + '\'');
	}

	@IsTest
	private static void testJoinSetBooleanSet()
	{
		//global static String joinSet(Set<Boolean> BooleanSet, String separator)
		assertJoinSetBooleanSet(null, '|', null);
		assertJoinSetBooleanSet(new Set<Boolean> {}, '|', '');
		assertJoinSetBooleanSet(new Set<Boolean> {true}, '|', 'true');
		assertJoinSetBooleanSet(new Set<Boolean> {true, false}, '|', 'false|true');
	}

	@IsTest
	private static void testJoinSetDateSet()
	{
		//global static String joinSet(Set<Date> dateSet, String separator)
		assertJoinSetDateSet(null, '|', null);
		assertJoinSetDateSet(new Set<Date> {}, '|', '');
		Date date1 = Date.newInstance(2009, 1, 1);
		Date date2 = Date.newInstance(2009, 1, 2);
		assertJoinSetDateSet(new Set<Date> {date1}, '|', '' + date1 + '');
		assertJoinSetDateSet(new Set<Date> {date1, date2}, '|', '' + date1 + '|' + date2 + '');
	}

	@IsTest
	private static void testJoinSetDatetimeSet()
	{
		//global static String joinSet(Set<Datetime> datetimeSet, String separator)
		assertJoinSetDatetimeSet(null, '|', null);
		assertJoinSetDatetimeSet(new Set<Datetime> {}, '|', '');
		Datetime date1 = Datetime.newInstance(2009, 1, 1);
		Datetime date2 = Datetime.newInstance(2009, 1, 2);
		assertJoinSetDatetimeSet(new Set<Datetime> {date1}, '|', '' + date1 + '');
		assertJoinSetDatetimeSet(new Set<Datetime> {date1, date2}, '|', '' + date1 + '|' + date2 + '');
	}

	@IsTest
	private static void testJoinSetDecimalSet()
	{
		//global static String joinSet(Set<Decimal> decimalSet, String separator)
		assertJoinSetDecimalSet(null, '|', null);
		assertJoinSetDecimalSet(new Set<Decimal> {}, '|', '');
		Decimal dec1 = 4.0;
		Decimal dec2 = 5.0;
		assertJoinSetDecimalSet(new Set<Decimal> {dec1}, '|', '' + dec1 + '');
		assertJoinSetDecimalSet(new Set<Decimal> {dec1, dec2}, '|', '' + dec1 + '|' + dec2 + '');
	}

	@IsTest
	private static void testJoinSetDoubleSet()
	{
		//global static String joinSet(Set<Double> doubleSet, String separator)
		assertJoinSetDoubleSet(null, '|', null);
		assertJoinSetDoubleSet(new Set<Double> {}, '|', '');
		Double doub1 = 4.0;
		Double doub2 = 5.0;
		assertJoinSetDoubleSet(new Set<Double> {doub1}, '|', '' + doub1 + '');
		assertJoinSetDoubleSet(new Set<Double> {doub1, doub2}, '|', '' + doub1 + '|' + doub2 + '');
	}

	/**
	 * @description update test to mock id creation and not test I/O which doesn't make sense for testing
	 * a general purpose string utility class.
	 */
	@IsTest
	private static void testJoinSetIdSet()
	{
		//global static String joinSet(Set<Id> idSet, String separator)
		assertJoinSetIdSet(null, '|', null);
		assertJoinSetIdSet(new Set<Id> {}, '|', '');

		CMN_Foobar__c foo1 = new CMN_Foobar__c(Id = CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType), Name = 'foo1');
		CMN_Foobar__c foo2 = new CMN_Foobar__c(Id = CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType), Name = 'foo2');

		assertJoinSetIdSet(new Set<Id> {foo1.Id}, '|', '' + foo1.Id + '');
		assertJoinSetIdSet(new Set<Id> {foo1.Id, foo2.Id}, '|', '' + foo1.Id + '|' + foo2.Id + '');
	}

	@IsTest
	private static void testJoinSetIntegerSet()
	{
		//global static String joinSet(Set<Integer> integerSet, String separator)
		assertJoinSetIntegerSet(null, '|', null);
		assertJoinSetIntegerSet(new Set<Integer> {}, '|', '');
		Integer int1 = 4;
		Integer int2 = 5;
		assertJoinSetIntegerSet(new Set<Integer> {int1}, '|', '' + int1 + '');
		assertJoinSetIntegerSet(new Set<Integer> {int1, int2}, '|', '' + int1 + '|' + int2 + '');
	}

	@IsTest
	private static void testJoinSetLongSet()
	{
		//global static String joinSet(Set<Long> longSet, String separator)
		assertJoinSetLongSet(null, '|', null);
		assertJoinSetLongSet(new Set<Long> {}, '|', '');
		Long long1 = 4;
		Long long2 = 5;
		assertJoinSetLongSet(new Set<Long> {long1}, '|', '' + long1 + '');
		assertJoinSetLongSet(new Set<Long> {long1, long2}, '|', '' + long1 + '|' + long2 + '');
	}

	@IsTest
	private static void testJoinSetTimeSet()
	{
		//global static String joinSet(Set<Time> timeSet, String separator)
		assertJoinSetTimeSet(null, '|', null);
		assertJoinSetTimeSet(new Set<Time> {}, '|', '');
		Time time1 = Time.newInstance(18, 30, 2, 20);
		Time time2 = Time.newInstance(18, 30, 2, 21);
		assertJoinSetTimeSet(new Set<Time> {time1}, '|', '' + time1 + '');
		assertJoinSetTimeSet(new Set<Time> {time1, time2}, '|', '' + time1 + '|' + time2 + '');
	}

	@IsTest
	private static void testJoinSetStringSet()
	{
		//global static String joinSet(Set<String> stringSet, String separator)
		assertJoinSetStringSet(null, '|', null);
		assertJoinSetStringSet(new Set<String> {}, '|', '');
		String str1 = 'xyz';
		String str2 = 'abc';
		assertJoinSetStringSet(new Set<String> {str1}, '|', '' + str1 + '');
		assertJoinSetStringSet(new Set<String> {str1, str2}, '|', '' + str1 + '|' + str2 + '');
	}

	private static void assertJoinSetBlobSet(Set<Blob> blobSet, String separator, String expected)
	{
		System.assert(!((blobSet == null && expected != null) || (blobSet != null && expected == null)),
				'Invalid test input: both parameters should be null.');
		String actual = CMN_UTIL_String.joinSet(blobSet, separator);
		Set<String> actualAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((actual == null ? '' : actual),
				'{}\'', ''), separator));
		Set<String> expectedAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((expected == null ? '' : expected),
				'{}\'', ''), separator));
		if(expected != null && actual != null)
	{
			System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),
					'CMN_UTIL_String.joinSet(' + CMN_UTIL_Set.toString(blobSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}
	}
	private static void assertJoinSetBooleanSet(Set<Boolean> BooleanSet, String separator, String expected)
	{
		System.assert(!((BooleanSet == null && expected != null) || (BooleanSet != null && expected == null)),
				'Invalid test input: both parameters should be null.');
		String actual = CMN_UTIL_String.joinSet(BooleanSet, separator);
		Set<String> actualAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((actual == null ? '' : actual),
				'{}\'', ''), separator));
		Set<String> expectedAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((expected == null ? '' : expected),
				'{}\'', ''), separator));
		if(expected != null && actual != null)
	{
			System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),
					'CMN_UTIL_String.joinSet(' + CMN_UTIL_Set.toString(BooleanSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}
	}
	private static void assertJoinSetDateSet(Set<Date> dateSet, String separator, String expected)
	{
		System.assert(!((dateSet == null && expected != null) || (dateSet != null && expected == null)), 'Invalid test input: both parameters should be null.');
		String actual = CMN_UTIL_String.joinSet(dateSet, separator);
		Set<String> actualAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((actual == null ? '' : actual),
				'{}\'', ''), separator));
		Set<String> expectedAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((expected == null ? '' : expected),
				'{}\'', ''), separator));
		if(expected != null && actual != null)
	{
			System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),
					'CMN_UTIL_String.joinSet(' + CMN_UTIL_Set.toString(dateSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}
	}
	private static void assertJoinSetDatetimeSet(Set<Datetime> datetimeSet, String separator, String expected)
	{
		System.assert(!((datetimeSet == null && expected != null) || (datetimeSet != null && expected == null)),
				'Invalid test input: both parameters should be null.');
		String actual = CMN_UTIL_String.joinSet(datetimeSet, separator);
		Set<String> actualAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((actual == null ? '' : actual),
				'{}\'', ''), separator));
		Set<String> expectedAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((expected == null ? '' : expected),
				'{}\'', ''), separator));
		if(expected != null && actual != null)
	{
			System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),
					'CMN_UTIL_String.joinSet(' + CMN_UTIL_Set.toString(datetimeSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}
	}
	private static void assertJoinSetDecimalSet(Set<Decimal> decimalSet, String separator, String expected)
	{
		System.assert(!((decimalSet == null && expected != null) || (decimalSet != null && expected == null)),
				'Invalid test input: both parameters should be null.');
		String actual = CMN_UTIL_String.joinSet(decimalSet, separator);
		Set<String> actualAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((actual == null ? '' : actual),
				'{}\'', ''), separator));
		Set<String> expectedAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((expected == null ? '' : expected),
				'{}\'', ''), separator));
		if(expected != null && actual != null)
	{
			System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),
					'CMN_UTIL_String.joinSet(' + CMN_UTIL_Set.toString(decimalSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}
	}
	private static void assertJoinSetDoubleSet(Set<Double> doubleSet, String separator, String expected)
	{
		System.assert(!((doubleSet == null && expected != null) || (doubleSet != null && expected == null)),
				'Invalid test input: both parameters should be null.');
		String actual = CMN_UTIL_String.joinSet(doubleSet, separator);
		Set<String> actualAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((actual == null ? '' : actual),
				'{}\'', ''), separator));
		Set<String> expectedAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((expected == null ? '' : expected),
				'{}\'', ''), separator));
		if(expected != null && actual != null)
	{
			System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),
					'CMN_UTIL_String.joinSet(' + CMN_UTIL_Set.toString(doubleSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}
	}
	private static void assertJoinSetIdSet(Set<Id> idSet, String separator, String expected)
	{
		System.assert(!((idSet == null && expected != null) || (idSet != null && expected == null)), 'Invalid test input: both parameters should be null.');
		String actual = CMN_UTIL_String.joinSet(idSet, separator);
		Set<String> actualAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((actual == null ? '' : actual),
				'{}\'', ''), separator));
		Set<String> expectedAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((expected == null ? '' : expected),
				'{}\'', ''), separator));
		if(expected != null && actual != null)
	{
			System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),
					'CMN_UTIL_String.joinSet(' + CMN_UTIL_Set.toString(idSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}
	}
	private static void assertJoinSetIntegerSet(Set<Integer> integerSet, String separator, String expected)
	{
		System.assert(!((integerSet == null && expected != null) || (integerSet != null && expected == null)),
				'Invalid test input: both parameters should be null.'); String actual = CMN_UTIL_String.joinSet(integerSet, separator);
		Set<String> actualAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((actual == null ? '' : actual),
				'{}\'', ''), separator));
		Set<String> expectedAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((expected == null ? '' : expected),
				'{}\'', ''), separator));
		if(expected != null && actual != null)
	{
			System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),
					'CMN_UTIL_String.joinSet(' + CMN_UTIL_Set.toString(integerSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}
	}
	private static void assertJoinSetLongSet(Set<Long> longSet, String separator, String expected)
	{
		System.assert(!((longSet == null && expected != null) || (longSet != null && expected == null)),
				'Invalid test input: both parameters should be null.');
		String actual = CMN_UTIL_String.joinSet(longSet, separator);
		Set<String> actualAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((actual == null ? '' : actual),
				'{}\'', ''), separator));
		Set<String> expectedAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((expected == null ? '' : expected),
				'{}\'', ''), separator));
		if(expected != null && actual != null)
	{
			System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),
					'CMN_UTIL_String.joinSet(' + CMN_UTIL_Set.toString(longSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}
	}
	private static void assertJoinSetTimeSet(Set<Time> timeSet, String separator, String expected)
	{
		System.assert(!((timeSet == null && expected != null) || (timeSet != null && expected == null)), 'Invalid test input: both parameters should be null.');
		String actual = CMN_UTIL_String.joinSet(timeSet, separator);
		Set<String> actualAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((actual == null ? '' : actual),
				'{}\'', ''), separator));
		Set<String> expectedAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((expected == null ? '' : expected),
				'{}\'', ''), separator));
		if(expected != null && actual != null)
	{
			System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),
					'CMN_UTIL_String.joinSet(' + CMN_UTIL_Set.toString(timeSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}
	}
	private static void assertJoinSetStringSet(Set<String> stringSet, String separator, String expected)
	{
		System.assert(!((stringSet == null && expected != null) || (stringSet != null && expected == null)),
				'Invalid test input: both parameters should be null.'); String actual = CMN_UTIL_String.joinSet(stringSet, separator);
		Set<String> actualAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((actual == null ? '' : actual),
				'{}\'', ''), separator));
		Set<String> expectedAsStringSet = new Set<String>(CMN_UTIL_String.split(CMN_UTIL_String.replaceChars((expected == null ? '' : expected),
				'{}\'', ''), separator));
		if(expected != null && actual != null)
	{
			System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),
					'CMN_UTIL_String.joinSet(' + CMN_UTIL_Set.toString(stringSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}
	}

	private static Blob generateRandomBlob()
	{
		return EncodingUtil.base64Decode('ABC');
	}

	@IsTest
	private static void testReplaceChars()
	{
		//test: global static String replaceChars(String str, String searchChars, String replaceChars)
		assertReplaceChars(null, null, null, null);
		assertReplaceChars('', null, null, '');
		assertReplaceChars('abc', null, null, 'abc');
		assertReplaceChars('abc', '', null, 'abc');
		assertReplaceChars('abc', 'b', null, 'ac');
		assertReplaceChars('abc', 'b', '', 'ac');
		assertReplaceChars('abcba', 'bc', 'yz', 'ayzya');
		assertReplaceChars('abcba', 'bc', 'y', 'ayya');
		assertReplaceChars('abcba', 'bc', 'yzx', 'ayzya');
	}

	private static void assertReplaceChars(String str, String searchChars, String replaceChars, String expected)
	{
		String actual = CMN_UTIL_String.replaceChars(str, searchChars, replaceChars);
		System.assert(actual == expected, 'CMN_UTIL_String.replaceChars(\'' + str + '\',\''
				+ searchChars + '\',\'' + replaceChars + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testJoinSet()
	{
		//test: global static String joinSet(Set<Object> objectSet, String separator){
		assertJoinSet(null, null, null);
		assertJoinSet(new Set<Object>(), ':', null);
		assertJoinSet(new Set<Object> {'a', 'b', 'c'}, ':', 'a:c:b');
		assertJoinSet(new Set<Object> {' ', 'b', 'c'}, ':', 'c:b');
		assertJoinSet(new Set<Object> {true, false}, '|', 'true|false');
	}

	private static void assertJoinSet(Set<Object> objectSet, String separator, String expected)
	{
		String actual = CMN_UTIL_String.joinSet(objectSet, separator);
		if(objectSet == null || objectSet.size() <= 0)
		{
			System.assert(CMN_UTIL_String.isBlank(expected),
					'CMN_UTIL_String.joinSet(Set<Object>, \'' + (separator == null ? 'null' : separator)
					+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
			return;
		}
		Set<String> actualAsSet = new Set<String>(CMN_UTIL_String.split(actual, separator));
		Set<String> expectedAsSet = new Set<String>(CMN_UTIL_String.split(expected, separator));
		System.assert(actualAsSet.containsAll(expectedAsSet) && expectedAsSet.containsAll(actualAsSet),
				'CMN_UTIL_String.joinSet(Set<Object>, \'' + (separator == null ? 'null' : separator) + '\') returned \'' +
				actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testSubstringTwoArgs()
	{
		//test: global static String substring(String str, Integer startIndex) {
		assertSubstringTwoArgs(null, -1, null);
		assertSubstringTwoArgs('', -2, '');
		assertSubstringTwoArgs('', -1, '');
		assertSubstringTwoArgs('', 0, '');
		assertSubstringTwoArgs('', 1, '');
		assertSubstringTwoArgs('abc', 0, 'abc');
		assertSubstringTwoArgs('abc', 2, 'c');
		assertSubstringTwoArgs('abc', 4, '');
		assertSubstringTwoArgs('abc', -2, 'bc');
		assertSubstringTwoArgs('abc', -4, 'abc');
	}

	private static void assertSubstringTwoArgs(String str, Integer startIndex, String expected)
	{
		String actual = CMN_UTIL_String.substring(str, startIndex);
		System.assert(actual == expected, 'CMN_UTIL_String.substring(\'' + str + '\','
				+ startIndex + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testSubstringThreeArgs()
	{
		//test: global static String substring(String str, Integer startIndex, Integer endIndex) {
		assertSubstringThreeArgs(null, -1, -1, null);
		assertSubstringThreeArgs('', -1, -1, '');
		assertSubstringThreeArgs('abc', 0, 2, 'ab');
		assertSubstringThreeArgs('abc', 2, 0, '');
		assertSubstringThreeArgs('abc', 2, 4, 'c');
		assertSubstringThreeArgs('abc', 4, 6, '');
		assertSubstringThreeArgs('abc', 2, 2, '');
		assertSubstringThreeArgs('abc', -2, -1, 'b');
		assertSubstringThreeArgs('abc', -4, 2, 'ab');
		assertSubstringThreeArgs('abc', -5, -4, '');

	}

	private static void assertSubstringThreeArgs(String str, Integer startIndex, Integer endIndex, String expected)
	{
		String actual = CMN_UTIL_String.substring(str, startIndex, endIndex);
		System.assert(actual == expected, 'CMN_UTIL_String.substring(\'' + str + '\','
				+ startIndex + ',' + endIndex + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testLeft()
	{
		//test: global static String left(String str, Integer len) {
		assertLeft(null, -1, null);
		assertLeft(null, 0, null);
		assertLeft('xyz', -1, '');
		assertLeft('', -1, '');
		assertLeft('', 0, '');
		assertLeft('abc', 0, '');
		assertLeft('abc', 2, 'ab');
		assertLeft('abc', 4, 'abc');
	}

	private static void assertLeft(String str, Integer len, String expected)
	{
		String actual = CMN_UTIL_String.left(str, len);
		System.assert(actual == expected, 'CMN_UTIL_String.left(\'' + str + '\','
				+ len + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testRepeat()
	{
		//test: global static String repeat(String str, Integer repeat)
		assertRepeat(null, 2, null);
		assertRepeat('', 0, '');
		assertRepeat('', 2, '');
		assertRepeat('a', 3, 'aaa');
		assertRepeat('ab', 2, 'abab');
		assertRepeat('a', -2, '');
	}

	private static void assertRepeat(String str, Integer repeat, String expected)
	{
		String actual = CMN_UTIL_String.repeat(str, repeat);
		System.assert(actual == expected, 'CMN_UTIL_String.repeat(\'' + str + '\',\''
				+ repeat + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testMid()
	{
		//test: global static String mid(String str, Integer pos, Integer len) {
		assertMid(null, 0, 0, null);
		assertMid('', 0, -1, '');
		assertMid('', 0, 0, '');
		assertMid('abc', 0, 2, 'ab');
		assertMid('abc', 0, 4, 'abc');
		assertMid('abc', 2, 4, 'c');
		assertMid('abc', 4, 2, '');
		assertMid('abc', -2, 2, 'ab');

	}

	private static void assertMid(String str, Integer pos, Integer len, String expected)
	{
		String actual = CMN_UTIL_String.mid(str, pos, len);
		System.assert(actual == expected, 'CMN_UTIL_String.mid(\'' + str + '\',' + pos
				+ ',' + len + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testOverlay()
	{
		//test: global static String overlay(String str, String overlay, Integer startIndex, Integer endIndex) {
		assertOverlay(null, null, 0, 0, null);
		assertOverlay('', 'abc', 0, 0, 'abc');
		assertOverlay('abcdef', null, 2, 4, 'abef');
		assertOverlay('abcdef', '', 2, 4, 'abef');
		assertOverlay('abcdef', '', 4, 2, 'abef');
		assertOverlay('abcdef', 'zzzz', 2, 4, 'abzzzzef');
		assertOverlay('abcdef', 'zzzz', 4, 2, 'abzzzzef');
		assertOverlay('abcdef', 'zzzz', -1, 4, 'zzzzef');
		assertOverlay('abcdef', 'zzzz', 2, 8, 'abzzzz');
		assertOverlay('abcdef', 'zzzz', -2, -3, 'zzzzabcdef');
		assertOverlay('abcdef', 'zzzz', 8, 10, 'abcdefzzzz');

	}

	private static void assertOverlay(String str, String overlay, Integer startIndex, Integer endIndex, String expected)
	{
		String actual = CMN_UTIL_String.overlay(str, overlay, startIndex, endIndex);
		System.assert(actual == expected, 'CMN_UTIL_String.overlay(\'' + str + '\',\'' + overlay
				+ '\',' + startIndex + ',' + endIndex + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testRemove()
	{
		//test: global static String remove(String str, String remove) {
		assertRemove(null, null, null);
		assertRemove('', null, '');
		assertRemove('xyz', null, 'xyz');
		assertRemove('xyz', '', 'xyz');
		assertRemove('queued', 'ue', 'qd');
		assertRemove('queued', 'zz', 'queued');

	}

	private static void assertRemove(String str, String remove, String expected)
	{
		String actual = CMN_UTIL_String.remove(str, remove);
		System.assert(actual == expected, 'CMN_UTIL_String.remove(\'' + str + '\',\'' + remove
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testRemoveStart()
	{
		//test: global static String removeStart(String str, String remove) {
		assertRemoveStart(null, null, null);
		assertRemoveStart('', null, '');
		assertRemoveStart('xyz', null, 'xyz');
		assertRemoveStart('/', '/', '');
		assertRemoveStart('www.domain.com', 'www.', 'domain.com');
		assertRemoveStart('domain.com', 'www.', 'domain.com');
		assertRemoveStart('www.domain.com', 'domain', 'www.domain.com');
		assertRemoveStart('abc', '', 'abc');
	}

	private static void assertRemoveStart(String str, String remove, String expected)
	{
		String actual = CMN_UTIL_String.removeStart(str, remove);
		System.assert(actual == expected, 'CMN_UTIL_String.removeStart(\'' + str + '\',\'' + remove
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testRemoveStartIgnoreCase()
	{
		//test: global static String removeStartIgnoreCase(String str, String remove) {
		assertRemoveStartIgnoreCase(null, null, null);
		assertRemoveStartIgnoreCase('', null, '');
		assertRemoveStartIgnoreCase('xyz', null, 'xyz');
		assertRemoveStartIgnoreCase('www.domain.com', 'www.', 'domain.com');
		assertRemoveStartIgnoreCase('www.domain.com', 'WWW.', 'domain.com');
		assertRemoveStartIgnoreCase('domain.com', 'www.', 'domain.com');
		assertRemoveStartIgnoreCase('www.domain.com', 'domain', 'www.domain.com');
		assertRemoveStartIgnoreCase('abc', '', 'abc');
	}

	private static void assertRemoveStartIgnoreCase(String str, String remove, String expected)
	{
		String actual = CMN_UTIL_String.removeStartIgnoreCase(str, remove);
		System.assert(actual == expected, 'CMN_UTIL_String.removeStartIgnoreCase(\'' + str + '\',\'' + remove
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testRemoveEnd()
	{
		//test: global static String removeEnd(String str, String remove) {
		assertRemoveEnd(null, null, null);
		assertRemoveEnd('', null, '');
		assertRemoveEnd('xyz', null, 'xyz');
		assertRemoveEnd('www.domain.com', '.com.', 'www.domain.com');
		assertRemoveEnd('www.domain.com', '.com', 'www.domain');
		assertRemoveEnd('www.domain.com', 'domain', 'www.domain.com');
		assertRemoveEnd('abc', '', 'abc');
	}

	private static void assertRemoveEnd(String str, String remove, String expected)
	{
		String actual = CMN_UTIL_String.removeEnd(str, remove);
		System.assert(actual == expected, 'CMN_UTIL_String.removeEnd(\'' + str + '\',\'' + remove
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testRemoveEndIgnoreCase()
	{
		//test: global static String removeEndIgnoreCase(String str, String remove) {
		assertRemoveEndIgnoreCase(null, null, null);
		assertRemoveEndIgnoreCase('', null, '');
		assertRemoveEndIgnoreCase('xyz', null, 'xyz');
		assertRemoveEndIgnoreCase('www.domain.com', '.com.', 'www.domain.com');
		assertRemoveEndIgnoreCase('www.domain.com', '.com', 'www.domain');
		assertRemoveEndIgnoreCase('www.domain.com', 'domain', 'www.domain.com');
		assertRemoveEndIgnoreCase('abc', '', 'abc');
	}

	private static void assertRemoveEndIgnoreCase(String str, String remove, String expected)
	{
		String actual = CMN_UTIL_String.removeEndIgnoreCase(str, remove);
		System.assert(actual == expected, 'CMN_UTIL_String.removeEndIgnoreCase(\'' + str + '\',\'' + remove
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testRegionMatchesCaseSensitive()
	{
		//test: global static Boolean regionMatches(String str, Boolean ignoreCase,
		//            Integer toffset, String other, Integer ooffset, Integer len){
		assertRegionMatchesCaseSensitive(null, 0, null, 0, 0, true);
		assertRegionMatchesCaseSensitive('aaaxyzaaa', 3, 'aaaaxyzaa', 4, 3, true);
		assertRegionMatchesCaseSensitive('aaaXYZaaa', 3, 'aaaaxyzaa', 4, 3, false);
	}

	private static void assertRegionMatchesCaseSensitive(String str, Integer toffset,
			String other, Integer ooffset, Integer len, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.regionMatches(str, toffset, other, ooffset, len);
		System.assert(actual == expected, 'CMN_UTIL_String.regionMatches(\''
				+ str + '\',' + toffset + ',\'' + other + '\',' + ooffset + ',' + len
				+ ') returned ' + actual + '; expected ' + expected);
	}

	@IsTest
	private static void testRegionMatchesCaseInsensitive()
	{
		//test: global static Boolean regionMatches(String str, Boolean ignoreCase,
		//            Integer toffset, String other, Integer ooffset, Integer len){
		assertRegionMatchesCaseInsensitive(null, 0, null, 0, 0, true);
		assertRegionMatchesCaseInsensitive('aaaxyzaaa', 3, 'aaaaxyzaa', 4, 3, true);
		assertRegionMatchesCaseInsensitive('aaaXYZaaa', 3, 'aaaaxyzaa', 4, 3, true);
	}

	private static void assertRegionMatchesCaseInsensitive(String str, Integer toffset,
			String other, Integer ooffset, Integer len, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.regionMatchesIgnoreCase(str, toffset, other, ooffset, len);
		System.assert(actual == expected, 'CMN_UTIL_String.regionMatchesIgnoreCase(\''
				+ str + '\',' + toffset + ',\'' + other + '\',' + ooffset + ',' + len
				+ ') returned ' + actual + '; expected ' + expected);
	}

	@IsTest
	private static void testRegionMatches()
	{
		//test: global static Boolean regionMatches(String str, Boolean ignoreCase,
		//            Integer toffset, String other, Integer ooffset, Integer len){
		assertRegionMatches(null, false, 0, null, 0, 0, true);
		assertRegionMatches('aaaxyzaaa', false, 3, 'aaaaxyzaa', 4, 3, true);
		assertRegionMatches('aaaXYZaaa', false, 3, 'aaaaxyzaa', 4, 3, false);
		assertRegionMatches('aaaXYZaaa', true, 3, 'aaaaxyzaa', 4, 3, true);
		assertRegionMatches(
				'Java is a wonderful language',
				// 0    5    10   15   20   25
				false, 20,
				'It is an object-oriented language', 25, 6, true);
		// 0    5    10   15   20   25   30
	}

	private static void assertRegionMatches(String str, Boolean ignoreCase, Integer toffset,
			String other, Integer ooffset, Integer len, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.regionMatches(str, ignoreCase, toffset, other, ooffset, len);
		System.assert(actual == expected, 'CMN_UTIL_String.regionMatches(\''
				+ str + '\',' + ignoreCase + ',' + toffset + ',\''
				+ other + '\',' + ooffset + ',' + len
				+ ') returned ' + actual + '; expected ' + expected);
	}

	@IsTest
	private static void testReplaceThreeArgs()
	{
		//test: global static String replace(String text, String searchString, String replacement) {

		assertReplaceThreeArgs(null, null, null, null);
		assertReplaceThreeArgs('', null, null, '');
		assertReplaceThreeArgs('any', null, null, 'any');
		assertReplaceThreeArgs('any', null, null, 'any');
		assertReplaceThreeArgs('any', '', null, 'any');
		assertReplaceThreeArgs('aba', 'a', null, 'aba');
		assertReplaceThreeArgs('aba', 'a', '', 'b');
		assertReplaceThreeArgs('aba', 'a', 'z', 'zbz');
	}

	private static void assertReplaceThreeArgs(String text, String searchString, String replacement, String expected)
	{
		String actual = CMN_UTIL_String.replace(text, searchString, replacement);
		System.assert(actual == expected, 'CMN_UTIL_String.replace(\'' + text + '\',\''
				+ searchString + '\',\'' + replacement + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testReplaceFourArgs()
	{
		//test: global static String replace(String text, String searchString, String replacement, Integer max) {
		assertReplaceFourArgs(null, null, null, -1, null);
		assertReplaceFourArgs('', null, null, -1, '');
		assertReplaceFourArgs('any', null, null, -1, 'any');
		assertReplaceFourArgs('any', null, null, -1, 'any');
		assertReplaceFourArgs('any', '', null, -1, 'any');
		assertReplaceFourArgs('any', null, null, 0, 'any');
		assertReplaceFourArgs('abaa', 'a', null, -1, 'abaa');
		assertReplaceFourArgs('abaa', 'a', '', -1, 'b');
		assertReplaceFourArgs('abaa', 'a', 'z', 0, 'abaa');
		assertReplaceFourArgs('abaa', 'a', 'z', 1, 'zbaa');
		assertReplaceFourArgs('abaa', 'a', 'z', 2, 'zbza');
		assertReplaceFourArgs('abaa', 'a', 'z', -1, 'zbzz');
	}

	private static void assertReplaceFourArgs(String text, String searchString, String replacement, Integer max, String expected)
	{
		String actual = CMN_UTIL_String.replace(text, searchString, replacement, max);
		System.assert(actual == expected, 'CMN_UTIL_String.replace(\'' + text + '\',\''
				+ searchString + '\',\'' + replacement + '\',' + max + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testReplaceEachThreeArgs()
	{
		//test: global static String replaceEach(String text, List<String> searchList, List<String> replacementList) {
		assertReplaceEachThreeArgs(null, null, null, null);
		assertReplaceEachThreeArgs('', null, null, '');
		assertReplaceEachThreeArgs('aba', null, null, 'aba');
		assertReplaceEachThreeArgs('aba', new String[0], null, 'aba');
		assertReplaceEachThreeArgs('aba', null, new String[0], 'aba');
		assertReplaceEachThreeArgs('aba', new List<String> {'a'}, null, 'aba');
		assertReplaceEachThreeArgs('aba', new List<String> {'a'}, new List<String> {''}, 'b');
		assertReplaceEachThreeArgs('aba', new List<String> {null}, new List<String> {'a'}, 'aba');
		assertReplaceEachThreeArgs('abcde', new List<String> {'ab', 'd'}, new List<String> {'w', 't'}, 'wcte');
		assertReplaceEachThreeArgs('abcde', new List<String> {'ab', 'd'}, new List<String> {'d', 't'}, 'dcte');
	}

	private static void assertReplaceEachThreeArgs(String text, List<String> searchList, List<String> replacementList, String expected)
	{
		String actual = CMN_UTIL_String.replaceEach(text, searchList, replacementList);
		System.assert(actual == expected, 'CMN_UTIL_String.replaceEach(\'' + text + '\','
				+ CMN_UTIL_Array.toString(searchList) + ',' + CMN_UTIL_Array.toString(replacementList) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testReplaceEachRepeatedly()
	{
		//test: global static String replaceEachRepeatedly(String text, List<String> searchList, List<String> replacementList, Boolean repeat) {
		assertReplaceEachRepeatedly(null, null, null, false, null);
		assertReplaceEachRepeatedly('', null, null, false, '');
		assertReplaceEachRepeatedly('aba', null, null, false, 'aba');
		assertReplaceEachRepeatedly('aba', new String[0], null, false, 'aba');
		assertReplaceEachRepeatedly('aba', null, new String[0], false, 'aba');
		assertReplaceEachRepeatedly('aba', new List<String> {'a'}, null, false, 'aba');
		assertReplaceEachRepeatedly('aba', new List<String> {'a'}, new List<String> {''}, false, 'b');
		assertReplaceEachRepeatedly('aba', new List<String> {null}, new List<String> {'a'}, false, 'aba');
		assertReplaceEachRepeatedly('abcde', new List<String> {'ab', 'd'}, new List<String> {'w', 't'}, false, 'wcte');
		assertReplaceEachRepeatedly('abcde', new List<String> {'ab', 'd'}, new List<String> {'d', 't'}, false, 'dcte');
		assertReplaceEachRepeatedly('abcde', new List<String> {'ab', 'd'}, new List<String> {'d', 't'}, true, 'tcte');
		assertReplaceEachRepeatedly('abcde', new List<String> {'ab', 'd'}, new List<String> {'d', 'ab'}, false, 'dcabe');
	}

	private static void assertReplaceEachRepeatedly(String text, List<String> searchList, List<String> replacementList, Boolean repeat, String expected)
	{
		String actual = CMN_UTIL_String.replaceEachRepeatedly(text, searchList, replacementList, repeat);
		System.assert(actual == expected, 'CMN_UTIL_String.replaceEachRepeatedly(\'' + text + '\','
				+ CMN_UTIL_Array.toString(searchList) + ',' + CMN_UTIL_Array.toString(replacementList) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testReplaceEachFiveArgExceptions()
	{
		//test: global static String replaceEachRepeatedly(String text, List<String> searchList, List<String> replacementList, Boolean repeat) {
		CMN_UTIL_Exceptions.IllegalStateException illegalState = null;
		try
		{
			CMN_UTIL_String.replaceEach('abcde', new List<String> {'ab', 'd'}, new List<String> {'d', 'ab'}, false, -1);
		}
		catch(CMN_UTIL_Exceptions.IllegalStateException e)
		{
			illegalState = e;
		}
		System.assertNotEquals(null, illegalState);

		IllegalArgumentException illegalArgument = null;
		try
		{
			CMN_UTIL_String.replaceEach('abcde', new List<String> {'ab', 'd'}, new List<String> {'ab'}, false, 0);
		}
		catch(IllegalArgumentException e)
		{
			illegalArgument = e;
		}
		System.assertNotEquals(null, illegalArgument);
	}

	@IsTest
	private static void testStartsWith()
	{
		//test:global static Boolean startsWith(String str, String prefix)
		assertStartsWith(null, null, true);
		assertStartsWith(null, 'abcdef', false);
		assertStartsWith('abc', null, false);
		assertStartsWith('abc', 'abcdef', false);
		assertStartsWith('abcdef', 'abc', true);
		assertStartsWith('ABCDEF', 'abc', false);
	}

	private static void assertStartsWith(String str, String prefix, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.startsWith(str, prefix);
		System.assert(actual == expected, 'CMN_UTIL_String.startsWith(\'' + str + '\',\'' + prefix
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testStartsWithIgnoreCase()
	{
		//test:global static Boolean startsWithIgnoreCase(String str, String prefix)
		assertStartsWithIgnoreCase(null, null, true);
		assertStartsWithIgnoreCase(null, 'abcdef', false); assertStartsWithIgnoreCase('abc', null, false);
		assertStartsWithIgnoreCase('abcdef', 'abc', true);
		assertStartsWithIgnoreCase('ABCDEF', 'abc', true);
	}

	private static void assertStartsWithIgnoreCase(String str, String prefix, Boolean expected)
	{
		Boolean actual = CMN_UTIL_String.startsWithIgnoreCase(str, prefix);
		System.assert(actual == expected, 'CMN_UTIL_String.startsWithIgnoreCase(\'' + str + '\',\'' + prefix
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testReplaceOnce()
	{
		//test: global static String replaceOnce(String text, String searchString, String replacement)
		assertReplaceOnce(null, null, null, null);
		assertReplaceOnce('', null, null, '');
		assertReplaceOnce('any', null, null, 'any');
		assertReplaceOnce('any', null, null, 'any');
		assertReplaceOnce('any', '', null, 'any');
		assertReplaceOnce('aba', 'a', null, 'aba');
		assertReplaceOnce('aba', 'a', '', 'ba');
		assertReplaceOnce('aba', 'a', 'z', 'zba');
	}

	private static void assertReplaceOnce(String text, String searchString, String replacement, String expected)
	{
		String actual = CMN_UTIL_String.replaceOnce(text, searchString, replacement);
		System.assert(actual == expected, 'CMN_UTIL_String.replaceOnce(\'' + text + '\',\'' + searchString
				+ '\',\'' + replacement + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testReverse()
	{
		//test: global static String reverse(String str)
		assertReverse(null, null);
		assertReverse('', '');
		assertReverse('bat', 'tab');
	}

	private static void assertReverse(String str, String expected)
	{
		String actual = CMN_UTIL_String.reverse(str);
		System.assert(actual == expected, 'CMN_UTIL_String.reverse(\'' + str
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testReverseDelimited()
	{
		//test: global static String reverseDelimited(String str, String separatorChar)
		assertReverseDelimited(null, null, null);
		assertReverseDelimited('', null, '');
		assertReverseDelimited('a.b.c', 'x', 'a.b.c');
		assertReverseDelimited('a.b.c', '.', 'c.b.a');
	}

	private static void assertReverseDelimited(String str, String separatorChar, String expected)
	{
		String actual = CMN_UTIL_String.reverseDelimited(str, separatorChar);
		System.assert(actual == expected, 'CMN_UTIL_String.reverseDelimited(\'' + str + '\',\'' + separatorChar
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testRight()
	{
		//test: global static String right(String str, Integer len)
		assertRight(null, 0, null);
		assertRight('abcdefg', -1, '');
		assertRight('', -1, '');
		assertRight('abc', 0, '');
		assertRight('abc', 2, 'bc');
		assertRight('abc', 4, 'abc');
	}

	private static void assertRight(String str, Integer len, String expected)
	{
		String actual = CMN_UTIL_String.right(str, len);
		System.assert(actual == expected, 'CMN_UTIL_String.right(\'' + str + '\',' + len
				+ ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testSplitByCharacterTypeCamelCase()
	{
		//test: global static List<String> splitByCharacterTypeCamelCase(String str)
		assertSplitByCharacterTypeCamelCase(null, null);
		assertSplitByCharacterTypeCamelCase('', new List<String> {});
		assertSplitByCharacterTypeCamelCase('ab de fg', new List<String> {'ab', ' ', 'de', ' ', 'fg'});
		assertSplitByCharacterTypeCamelCase('ab   de fg', new List<String> {'ab', '   ', 'de', ' ', 'fg'});
		assertSplitByCharacterTypeCamelCase('ab:cd:ef', new List<String> {'ab', ':', 'cd', ':', 'ef'});
		assertSplitByCharacterTypeCamelCase('number5', new List<String> {'number', '5'});
		assertSplitByCharacterTypeCamelCase('fooBar', new List<String> {'foo', 'Bar'});
		assertSplitByCharacterTypeCamelCase('foo200Bar', new List<String> {'foo', '200', 'Bar'});
		assertSplitByCharacterTypeCamelCase('ASFRules', new List<String> {'ASF', 'Rules'});
	}

	private static void assertSplitByCharacterTypeCamelCase(String str, List<Object> expected)
	{
		CMN_UTIL_Array.assertArraysAreEqual(expected, CMN_UTIL_String.splitByCharacterTypeCamelCase(str));
	}

	@IsTest
	private static void testSplitByCharacterType()
	{
		//test:  global static List<String> splitByCharacterType(String str)
		assertSplitByCharacterType(null, null);
		assertSplitByCharacterType('', new List<String> {});
		assertSplitByCharacterType('ab de fg', new List<String> {'ab', ' ', 'de', ' ', 'fg'});
		assertSplitByCharacterType('ab   de fg', new List<String> {'ab', '   ', 'de', ' ', 'fg'});
		assertSplitByCharacterType('ab:cd:ef', new List<String> {'ab', ':', 'cd', ':', 'ef'});
		assertSplitByCharacterType('number5', new List<String> {'number', '5'});
		assertSplitByCharacterType('fooBar', new List<String> {'foo', 'B', 'ar'});
		assertSplitByCharacterType('foo200Bar', new List<String> {'foo', '200', 'B', 'ar'});
		assertSplitByCharacterType('ASFRules', new List<String> {'ASFR', 'ules'});
	}

	private static void assertSplitByCharacterType(String str, List<Object> expected)
	{
		CMN_UTIL_Array.assertArraysAreEqual(expected, CMN_UTIL_String.splitByCharacterType(str));
	}

	@IsTest
	private static void testTrimToEmpty()
	{
		//test: global static String trimToEmpty(String str) {
		assertTrimToEmpty(null, '');
		assertTrimToEmpty('', '');
		assertTrimToEmpty('     ', '');
		assertTrimToEmpty('abc', 'abc');
		assertTrimToEmpty('    abc    ', 'abc');
	}

	private static void assertTrimToEmpty(String str, String expected)
	{
		String actual = CMN_UTIL_String.trimToEmpty(str);
		System.assert(actual == expected, 'CMN_UTIL_String.trimToEmpty(\'' + str + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testTrimToNull()
	{
		//test:  global static String trimToNull(String str) {
		assertTrimToNull(null, null);
		assertTrimToNull('', null);
		assertTrimToNull('     ', null);
		assertTrimToNull('abc', 'abc');
		assertTrimToNull('    abc    ', 'abc');
	}

	private static void assertTrimToNull(String str, String expected)
	{
		String actual = CMN_UTIL_String.trimToNull(str);
		System.assert(actual == expected, 'CMN_UTIL_String.trimToNull(\'' + str + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testStripOneArg()
	{
		//test: global static String strip(String str)
		assertStripOneArg(null, null);
		assertStripOneArg('', '');
		assertStripOneArg('   ', '');
		assertStripOneArg('abc', 'abc');
		assertStripOneArg('  abc', 'abc');
		assertStripOneArg('abc  ', 'abc');
		assertStripOneArg(' abc ', 'abc');
		assertStripOneArg(' ab c ', 'ab c');
	}

	private static void assertStripOneArg(String str, String expected)
	{
		String actual = CMN_UTIL_String.strip(str);
		System.assert(actual == expected, 'CMN_UTIL_String.strip(\'' + str + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testStripToNull()
	{
		//test: global static String stripToNull(String str) {
		assertStripToNull(null, null);
		assertStripToNull('', null);
		assertStripToNull('   ', null);
		assertStripToNull('abc', 'abc');
		assertStripToNull('  abc', 'abc');
		assertStripToNull('abc  ', 'abc');
		assertStripToNull(' abc ', 'abc');
		assertStripToNull(' ab c ', 'ab c');
	}

	private static void assertStripToNull(String str, String expected)
	{
		String actual = CMN_UTIL_String.stripToNull(str);
		System.assert(actual == expected, 'CMN_UTIL_String.stripToNull(\'' + str + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testStripToEmpty()
	{
		//test: global static String stripToEmpty(String str) {
		assertStripToEmpty(null, '');
		assertStripToEmpty('', '');
		assertStripToEmpty('   ', '');
		assertStripToEmpty('abc', 'abc');
		assertStripToEmpty('  abc', 'abc');
		assertStripToEmpty('abc  ', 'abc');
		assertStripToEmpty(' abc ', 'abc');
		assertStripToEmpty(' ab c ', 'ab c');
	}

	private static void assertStripToEmpty(String str, String expected)
	{
		String actual = CMN_UTIL_String.stripToEmpty(str);
		System.assert(actual == expected, 'CMN_UTIL_String.stripToEmpty(\'' + str + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testStripTwoArgs()
	{
		//test: global static String strip(String str, String stripChars)
		assertStripTwoArgs(null, null, null);
		assertStripTwoArgs('', null, '');
		assertStripTwoArgs('abc', null, 'abc');
		assertStripTwoArgs('  abc', null, 'abc');
		assertStripTwoArgs('abc  ', null, 'abc');
		assertStripTwoArgs(' abc ', null, 'abc');
		assertStripTwoArgs('  abcyx', 'xyz', '  abc');
	}

	private static void assertStripTwoArgs(String str, String stripChars, String expected)
	{
		String actual = CMN_UTIL_String.strip(str, stripChars);
		System.assert(actual == expected, 'CMN_UTIL_String.strip(\'' + str + '\',\'' + stripChars + '\') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testStripStart()
	{
		//test:  global static String stripStart(String str, String stripChars)
		assertStripStart(null, null, null);
		assertStripStart('', null, '');
		assertStripStart('abc', '', 'abc');
		assertStripStart('abc', null, 'abc');
		assertStripStart('  abc', null, 'abc');
		assertStripStart('abc  ', null, 'abc  ');
		assertStripStart(' abc ', null, 'abc ');
		assertStripStart('yxabc  ', 'xyz', 'abc  ');
	}

	private static void assertStripStart(String str, String stripChars, String expected)
	{
		String actual = CMN_UTIL_String.stripStart(str, stripChars);
		System.assert(actual == expected, 'CMN_UTIL_String.stripStart(\'' + str + '\',\'' + stripChars
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testStripEnd()
	{
		//test: global static String stripEnd(String str, String stripChars)
		assertStripEnd(null, null, null);
		assertStripEnd('', null, '');
		assertStripEnd('abc', '', 'abc');
		assertStripEnd('abc', null, 'abc');
		assertStripEnd('  abc', null, '  abc');
		assertStripEnd('abc  ', null, 'abc');
		assertStripEnd(' abc ', null, ' abc');
		assertStripEnd('  abcyx', 'xyz', '  abc');
	}

	private static void assertStripEnd(String str, String stripChars, String expected)
	{
		String actual = CMN_UTIL_String.stripEnd(str, stripChars);
		System.assert(actual == expected, 'CMN_UTIL_String.stripEnd(\'' + str + '\', \'' + stripChars
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testStripAllOneArg()
	{
		//test: global static List<String> stripAll(List<String> strs)
		assertStripAllOneArg(null, null);
		assertStripAllOneArg(new List<String> {}, new List<String> {});
		assertStripAllOneArg(new List<String> {'abc', '  abc'}, new List<String> {'abc', 'abc'});
		assertStripAllOneArg(new List<String> {'abc  ', null}, new List<String> {'abc', null});
	}

	private static void assertStripAllOneArg(List<String> strs, List<String> expected)
	{
		CMN_UTIL_Array.assertArraysAreEqual(expected, CMN_UTIL_String.stripAll(strs));
	}

	@IsTest
	private static void testStripAllTwoArgs()
	{
		//test: global static List<String> stripAll(List<String> strs, String stripChars)
		assertStripAllTwoArgs(null, null, null);
		assertStripAllTwoArgs(new List<String> {}, null, new List<String> {});
		assertStripAllTwoArgs(new List<String> {'abc', '  abc'}, null, new List<String> {'abc', 'abc'});
		assertStripAllTwoArgs(new List<String> {'abc  ', null}, null, new List<String> {'abc', null});
		assertStripAllTwoArgs(new List<String> {'abc  ', null}, 'yz', new List<String> {'abc  ', null});
		assertStripAllTwoArgs(new List<String> {'yabcz', null}, 'yz', new List<String> {'abc', null});
	}

	private static void assertStripAllTwoArgs(List<String> strs, String stripChars, List<String> expected)
	{
		CMN_UTIL_Array.assertArraysAreEqual(expected, CMN_UTIL_String.stripAll(strs, stripChars));
	}

	@IsTest
	private static void testSubstringBefore()
	{
		//test: global static String substringBefore(String str, String separator)
		assertSubstringBefore(null, null, null);
		assertSubstringBefore('', null, '');
		assertSubstringBefore('abc', 'a', '');
		assertSubstringBefore('abcba', 'b', 'a');
		assertSubstringBefore('abc', 'c', 'ab');
		assertSubstringBefore('abc', 'd', 'abc');
		assertSubstringBefore('abc', '', '');
		assertSubstringBefore('abc', null, 'abc');
	}

	private static void assertSubstringBefore(String str, String separator, String expected)
	{
		String actual = CMN_UTIL_String.substringBefore(str, separator);
		System.assert(actual == expected, 'CMN_UTIL_String.substringBefore(\'' + str + '\', \'' + separator
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testSubstringAfter()
	{
		//test: global static String substringAfter(String str, String separator)
		assertSubstringAfter(null, null, null);
		assertSubstringAfter('', null, '');
		assertSubstringAfter('asdf', null, '');
		assertSubstringAfter(null, null, null);
		assertSubstringAfter('abc', 'a', 'bc');
		assertSubstringAfter('abcba', 'b', 'cba');
		assertSubstringAfter('abc', 'c', '');
		assertSubstringAfter('abc', 'd', '');
		assertSubstringAfter('abc', '', 'abc');
	}

	private static void assertSubstringAfter(String str, String separator, String expected)
	{
		String actual = CMN_UTIL_String.substringAfter(str, separator);
		System.assert(actual == expected, 'CMN_UTIL_String.substringAfter(\'' + str + '\', \'' + separator
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testSubstringBeforeLast()
	{
		//test: global static String substringBeforeLast(String str, String separator)
		assertSubstringBeforeLast(null, null, null);
		assertSubstringBeforeLast('', null, '');
		assertSubstringBeforeLast('abcba', 'b', 'abc');
		assertSubstringBeforeLast('abc', 'c', 'ab');
		assertSubstringBeforeLast('a', 'a', '');
		assertSubstringBeforeLast('a', 'z', 'a');
		assertSubstringBeforeLast('a', null, 'a');
		assertSubstringBeforeLast('a', '', 'a');
	}

	private static void assertSubstringBeforeLast(String str, String separator, String expected)
	{
		String actual = CMN_UTIL_String.substringBeforeLast(str, separator);
		System.assert(actual == expected, 'CMN_UTIL_String.substringBeforeLast(\'' + str + '\', \'' + separator
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testSubstringAfterLast()
	{
		//test: global static String substringAfterLast(String str, String separator)
		assertSubstringAfterLast(null, null, null);
		assertSubstringAfterLast('', null, '');
		assertSubstringAfterLast('adsfa', null, '');
		assertSubstringAfterLast(null, '', null);
		assertSubstringAfterLast('abc', 'a', 'bc');
		assertSubstringAfterLast('abcba', 'b', 'a');
		assertSubstringAfterLast('abc', 'c', '');
		assertSubstringAfterLast('a', 'a', '');
		assertSubstringAfterLast('a', 'z', '');
	}

	private static void assertSubstringAfterLast(String str, String separator, String expected)
	{
		String actual = CMN_UTIL_String.substringAfterLast(str, separator);
		System.assert(actual == expected, 'CMN_UTIL_String.substringAfterLast(\'' + str + '\', \'' + separator
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	/**
	 * @description Will ensure the substring functionality works as expectedd
	 */
	@IsTest
	private static void substringBetweenIgnoreCase()
	{
		String sampleContent = 'The quick brown fox jumped over the lazy dog';
		String startTag = '<SaMpLeStRiNg>';
		String endTag = '</<samplestring>';
		String mixedCaseTest = startTag + sampleContent + endTag;

		assertSubstringBetweenIgnoreCase(mixedCaseTest, startTag, endTag, sampleContent);
		assertSubstringBetweenIgnoreCase(mixedCaseTest, null, null, null);
		assertSubstringBetweenIgnoreCase(null, null, null, null);
		assertSubstringBetweenIgnoreCase(CMN_UTIL_String.EMPTY, CMN_UTIL_String.EMPTY, CMN_UTIL_String.EMPTY, CMN_UTIL_String.EMPTY);
		assertSubstringBetweenIgnoreCase(mixedCaseTest, endTag, startTag, null);
	}

	@IsTest
	private static void testSubstringBetweenTwoArgs()
	{
		//test: global static String substringBetween(String str, String tag)
		assertSubstringBetweenTwoArgs(null, null, null);
		assertSubstringBetweenTwoArgs('', '', '');
		assertSubstringBetweenTwoArgs('', 'tag', null);
		assertSubstringBetweenTwoArgs('tagabctag', null, null);
		assertSubstringBetweenTwoArgs('tagabctag', '', '');
		assertSubstringBetweenTwoArgs('tagabctag', 'tag', 'abc');
	}

	private static void assertSubstringBetweenTwoArgs(String str, String tag, String expected)
	{
		String actual = CMN_UTIL_String.substringBetween(str, tag);
		System.assert(actual == expected, 'CMN_UTIL_String.substringBetween(\'' + str + '\', \'' + tag
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	private static void assertSubstringBetweenIgnoreCase(String str, String tagStart, String tagEnd, String expected)
	{
		String actual = CMN_UTIL_String.substringBetweenIgnoreCase(str, tagStart, tagEnd);
		System.assert(actual == expected, 'CMN_UTIL_String.substringBetweenIgnoreCase(\'' + str + '\', \'' + tagStart
				+ '\'' + tagEnd + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testSubstringBetweenThreeArgs()
	{
		//test: global static String substringBetween(String str, String open, String close)
		assertSubstringBetweenThreeArgs('wx[b]yz', '[', ']', 'b');
		assertSubstringBetweenThreeArgs(null, null, null, null);
		assertSubstringBetweenThreeArgs(null, null, null, null);
		assertSubstringBetweenThreeArgs(null, null, null, null);
		assertSubstringBetweenThreeArgs('', '', '', '');
		assertSubstringBetweenThreeArgs('', '', ']', null);
		assertSubstringBetweenThreeArgs('', '[', ']', null);
		assertSubstringBetweenThreeArgs('yabcz', '', '', '');
		assertSubstringBetweenThreeArgs('yabcz', 'y', 'z', 'abc');
		assertSubstringBetweenThreeArgs('yabczyabcz', 'y', 'z', 'abc');
	}

	private static void assertSubstringBetweenThreeArgs(String str, String open, String close, String expected)
	{
		String actual = CMN_UTIL_String.substringBetween(str, open, close);
		System.assert(actual == expected, 'CMN_UTIL_String.substringBetween(\'' + str + '\',\'' + open + '\', \'' + close
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testSubstringsBetween()
	{
		//test: global static List<String> substringsBetween(String str, String open, String close)
		assertSubstringsBetween('[a][b][c]', '[', ']', new List<String> {'a', 'b', 'c'});
		assertSubstringsBetween(null, null, null, null);
		assertSubstringsBetween('asdf', '[', ']', null);
		assertSubstringsBetween('a[df', '[', ']', null);
		assertSubstringsBetween('', '[', ']', new List<String> {});
	}

	private static void assertSubstringsBetween(String str, String open, String close, List<String> expected)
	{
		CMN_UTIL_Array.assertArraysAreEqual(expected, CMN_UTIL_String.substringsBetween(str, open, close));
	}

	@IsTest
	private static void testEnsureStringStartsEndsWithChar()
	{
		//test: global static String ensureStringStartsEndsWithChar(String str, String charc){
		assertEnsureStringStartsEndsWithChar(null, null, null);
		assertEnsureStringStartsEndsWithChar(null, 'abc', null);
		assertEnsureStringStartsEndsWithChar('', 'abc', 'abcabc');
		assertEnsureStringStartsEndsWithChar('test123', null, 'test123');
		assertEnsureStringStartsEndsWithChar('test123', 'abc', 'abctest123abc');
	}

	private static void assertEnsureStringStartsEndsWithChar(String str, String charc, String expected)
	{
		String actual = CMN_UTIL_String.ensureStringStartsEndsWithChar(str, charc);
		System.assert(actual == expected, 'CMN_UTIL_String.ensureStringStartsEndsWithChar(\'' + str + '\', \'' + charc
				+ '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testToCharArray()
	{
		//test: global static List<String> toCharArray(String str){
		CMN_UTIL_Array.assertArraysAreEqual(new List<String> {}, CMN_UTIL_String.toCharArray(null));
		CMN_UTIL_Array.assertArraysAreEqual(new List<String> {}, CMN_UTIL_String.toCharArray(''));
		CMN_UTIL_Array.assertArraysAreEqual(new List<String> {' '}, CMN_UTIL_String.toCharArray(' '));
		CMN_UTIL_Array.assertArraysAreEqual(new List<String> {' ', ' '}, CMN_UTIL_String.toCharArray('  '));
		CMN_UTIL_Array.assertArraysAreEqual(new List<String> {'a', 'b', 'c'}, CMN_UTIL_String.toCharArray('abc'));
	}

	@IsTest
	private static void testTrimAllSet()
	{
		Set<String> NULL_SET = null;
		System.assertEquals(null, CMN_UTIL_String.trimAll(NULL_SET));
		CMN_UTIL_Set.assertEquals(new Set<String> {'a', 'b'}, CMN_UTIL_String.trimAll(new Set<String> {' a ', ' b '}));
	}

	@IsTest
	private static void testTrimAllList()
	{
		List<String> NULL_LIST = null;
		System.assertEquals(null, CMN_UTIL_String.trimAll(NULL_LIST));
		CMN_UTIL_Array.assertArraysAreEqual(new List<String> {'a', 'b'}, CMN_UTIL_String.trimAll(new List<String> {' a ', ' b '}));
	}

	@IsTest
	private static void testTrimLower()
	{
		//test: global static String trimLower(String str)
		System.assertEquals(null, CMN_UTIL_String.trimLower(null));
		System.assertEquals('', CMN_UTIL_String.trimLower(''));
		System.assertEquals('abc', CMN_UTIL_String.trimLower('  abc  '));
		System.assertEquals('abc', CMN_UTIL_String.trimLower('  ABC  '));
	}

	@IsTest
	private static void testStripMarkup()
	{
		//test: global static String trimLower(String str)
		System.assertEquals(null, CMN_UTIL_String.stripMarkup(null));
		System.assertEquals('', CMN_UTIL_String.stripMarkup(''));
		System.assertEquals('Title! ABC 123', CMN_UTIL_String.stripMarkup('  Title!   ABC 123  '));
		System.assertEquals('Title! ABC 123', CMN_UTIL_String.stripMarkup('<html><body><h1>Title!</h1><p>ABC 123</p></html>'));
	}

	/**
	 * @description To test the string which length is 10
	 */
	@IsTest
	private static void testCheckInvalidId()
	{
		String invalidID = CMN_UTIL_String.generateRandomString(10);

		Test.startTest();

		Id validatedID = CMN_UTIL_String.validateId(invalidID);

		Test.stopTest();

		System.assertEquals(null, validatedID, 'A null Id should be returned.');
	}

	/**
	 * @description To test the Id generated
	 */
	@IsTest
	private static void testCheckValidId()
	{
		CMN_Foobar__c obj = new CMN_Foobar__c();

		Test.startTest();

		Id validatedID = CMN_UTIL_String.validateId(obj.Id);

		Test.stopTest();

		System.assertEquals(obj.Id, validatedID, 'Ids do not match.');
	}

	/**
	 * @description To test the string generated randomly
	 */
	@IsTest
	private static void testGenerateRandomString()
	{
		Test.startTest();

		System.assert(CMN_UTIL_String.generateRandomString(80) != null);

		String string1 = CMN_UTIL_String.generateRandomString(10);
		String string2 = CMN_UTIL_String.generateRandomString(10);

		Test.stopTest();

		System.assertNotEquals(string1, string2, 'Strings are the same.');

		System.assertEquals(10, string1.length(), 'String not the correct length.');
	}

	/**
	 * @description To test the input string from ellipses
	 */
	@IsTest
	private static void testEllipsisTrim()
	{

		String finalString = 'ABCDEF...';
		Integer finalStringLength = finalString.length();

		Test.startTest();

		String trimmedString = CMN_UTIL_String.ellipsisTrim('ABCDEFGHIJKLMNO', finalStringLength, 0);

		Test.stopTest();

		System.assertEquals(finalString, trimmedString, 'Strings not trimmed correctly.');
	}

	/**
	 * @description To test the input string from ellipses
	 */
	@IsTest
	private static void testEllipsisFail()
	{
		Integer finalLength = 2;

		Test.startTest();

		try
		{
			CMN_UTIL_String.ellipsisTrim('ABCDEFGHIJKLMNO', finalLength, 0);
			System.assert (false, 'Exception not thrown');
		}
		catch(Exception e)
		{
			System.assert(true, 'Exception thrown as expected');
		}

		Test.stopTest();
	}

	/**
	 * @description To test the input string from ellipses if no changes done
	 */
	@IsTest
	private static void testEllipsisTrimNoChange()
	{
		Test.startTest();

		String trimmedString = CMN_UTIL_String.ellipsisTrim('ABCDEFGHIJKLMNO', 'ABCDEFGHIJKLMNO'.length(), 0);

		Test.stopTest();

		System.assertEquals('ABCDEFGHIJKLMNO', trimmedString, 'Strings not matching.');
	}

	/**
	 * @description Will test trimDecimal method
	 */
	@IsTest
	private static void trimDecimal()
	{
		Decimal decimalValue = CMN_DAL_SObjectDomain.generateRandomDecimal();
		String valueToTrim = String.valueOf(decimalValue);

		System.assertEquals(true, valueToTrim.contains(CMN_UTIL_String.DOT));

		Test.startTest();

		String returnedValue = CMN_UTIL_String.trimDecimal(decimalValue);

		Test.stopTest();

		System.assertEquals(false, returnedValue.contains(CMN_UTIL_String.DOT), 'Decimal point not trimmed');
	}
}