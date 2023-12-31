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
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_UTIL_Number_TEST
{

	@IsTest
	private static void testMaxIntegerValue()
	{
		System.assert(CMN_UTIL_Number.MAX_INTEGER == 2147483647);
	}
	@IsTest
	private static void testMinIntegerValue()
	{
		System.assert(CMN_UTIL_Number.MIN_INTEGER == -2147483647);
	}

	@IsTest
	private static void testParseIntBadRadix()
	{
		//test: global static Integer parseInt(String str, Integer radix){
		Boolean exceptionCaught = false;
		try
		{
			CMN_UTIL_Number.parseInt('01', 1);
		}
		catch(IllegalArgumentException e)
		{
			exceptionCaught = true;
		}
		System.assert(exceptionCaught, 'CMN_UTIL_Number.parseInt(\'01\',1) did not throw IllegalArgumentException');
		exceptionCaught = false;
		try
		{
			CMN_UTIL_Number.parseInt('01', 37);
		}
		catch(IllegalArgumentException e)
		{
			exceptionCaught = true;
		}
		System.assert(exceptionCaught, 'CMN_UTIL_Number.parseInt(\'01\',37) did not throw IllegalArgumentException');
	}

	@IsTest
	private static void testParseIntEmptyNumber()
	{
		//test: global static Integer parseInt(String str, Integer radix){
		Boolean exceptionCaught = false;
		try
		{
			CMN_UTIL_Number.parseInt(null, 2);
		}
		catch(CMN_UTIL_Number.NumberFormatException e)
		{
			exceptionCaught = true;
		}
		System.assert(exceptionCaught, 'CMN_UTIL_Number.parseInt(null,2) did not throw CMN_UTIL_Exceptions.CMN_UTIL_Exceptions.NumberFormatException');
		exceptionCaught = false;
		try
		{
			CMN_UTIL_Number.parseInt('  ', 2);
		}
		catch(CMN_UTIL_Number.NumberFormatException e)
		{
			exceptionCaught = true;
		}
		System.assert(exceptionCaught, 'CMN_UTIL_Number.parseInt(\'  \',2) did not throw CMN_UTIL_Exceptions.CMN_UTIL_Exceptions.NumberFormatException');
	}

	@IsTest
	private static void testParseIntInvalidNumber()
	{
		//test: global static Integer parseInt(String str, Integer radix){
		for(Integer i = 2; i < 37; i++)
		{
			assertParseIntNumberFormatException(
					'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ$'.substring(0, i + 1)
					, i);
		}
	}

	private static void assertParseIntNumberFormatException(String str, Integer radix)
	{
		Boolean exceptionCaught = false;
		try
		{
			CMN_UTIL_Number.parseInt(str, radix);
		}
		catch(CMN_UTIL_Number.NumberFormatException e)
		{
			exceptionCaught = true;
		}
		System.assert(exceptionCaught, 'CMN_UTIL_Number.parseInt(\'' + str + '\',' + radix + ') did not throw CMN_UTIL_Exceptions.CMN_UTIL_Exceptions.NumberFormatException');
	}

	@IsTest
	private static void testParseIntBase2()
	{
		//test: global static Integer parseInt(String str, Integer radix){
		assertParseInt('0', 2, 0);
		assertParseInt('00', 2, 0);
		assertParseInt('1', 2, 1);
		assertParseInt('10', 2, 2);
		assertParseInt('11', 2, 3);
		assertParseInt('100', 2, 4);
	}

	@IsTest
	private static void testParseIntBase10()
	{
		//test: global static Integer parseInt(String str, Integer radix){
		assertParseInt('0', 10, 0);
		assertParseInt('-0', 10, 0);
		assertParseInt('473', 10, 473);
	}

	@IsTest
	private static void testParseIntOtherBases()
	{
		//test: global static Integer parseInt(String str, Integer radix){
		assertParseInt('1100110', 2, 102);
		assertParseInt('-FF', 16, -255);
		assertParseInt('12', 8, 10);
		assertParseInt('az', 36, 395);
	}

	private static void assertParseInt(String str, Integer radix, Integer expected)
	{
		Integer actual = CMN_UTIL_Number.parseInt(str, radix);
		System.assert(actual == expected, 'CMN_UTIL_Number.parseInt(\'' + str + '\',' + radix + ') returned '
				+ actual + '; expected ' + expected + '');
	}

	@IsTest
	private static void testIntegerToBinary()
	{
		//test: global static String toBinaryString(Integer i){
		assertIntegerToBinary(-2147483647, '-1111111111111111111111111111111');
		assertIntegerToBinary(-2147483646, '-1111111111111111111111111111110');
		assertIntegerToBinary(-4, '-100');
		assertIntegerToBinary(-3, '-11');
		assertIntegerToBinary(-2, '-10');
		assertIntegerToBinary(-1, '-1');
		assertIntegerToBinary(0, '0');
		assertIntegerToBinary(1, '1');
		assertIntegerToBinary(2, '10');
		assertIntegerToBinary(3, '11');
		assertIntegerToBinary(4, '100');
		assertIntegerToBinary(2147483646, '1111111111111111111111111111110');
		assertIntegerToBinary(2147483647, '1111111111111111111111111111111');

	}

	private static void assertIntegerToBinary(Integer i, String expected)
	{
		String actual = CMN_UTIL_Number.toBinaryString(i);
		System.assert(actual == expected, 'CMN_UTIL_Number.toBinary(' + i + ') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testIntegerToOctal()
	{
		//test: global static String toOctalString(Integer i){
		assertIntegerToOctal(-2147483647, '-17777777777');
		assertIntegerToOctal(-2147483646, '-17777777776');
		assertIntegerToOctal(-9, '-11');
		assertIntegerToOctal(-8, '-10');
		assertIntegerToOctal(-7, '-7');
		assertIntegerToOctal(-6, '-6');
		assertIntegerToOctal(-5, '-5');
		assertIntegerToOctal(-4, '-4');
		assertIntegerToOctal(-3, '-3');
		assertIntegerToOctal(-2, '-2');
		assertIntegerToOctal(-1, '-1');
		assertIntegerToOctal(0, '0');
		assertIntegerToOctal(1, '1');
		assertIntegerToOctal(2, '2');
		assertIntegerToOctal(3, '3');
		assertIntegerToOctal(4, '4');
		assertIntegerToOctal(5, '5');
		assertIntegerToOctal(6, '6');
		assertIntegerToOctal(7, '7');
		assertIntegerToOctal(8, '10');
		assertIntegerToOctal(9, '11');
		assertIntegerToOctal(2147483646, '17777777776');
		assertIntegerToOctal(2147483647, '17777777777');

	}

	private static void assertIntegerToOctal(Integer i, String expected)
	{
		String actual = CMN_UTIL_Number.toOctalString(i);
		System.assert(actual == expected, 'CMN_UTIL_Number.toOctal(' + i + ') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testIntegerToHex()
	{
		//test: global static String toHexString(Integer i){
		assertIntegerToHex(-2147483647, '-7FFFFFFF');
		assertIntegerToHex(-2147483646, '-7FFFFFFE');
		assertIntegerToHex(-19, '-13');
		assertIntegerToHex(-18, '-12');
		assertIntegerToHex(-17, '-11');
		assertIntegerToHex(-16, '-10');
		assertIntegerToHex(-15, '-F');
		assertIntegerToHex(-14, '-E');
		assertIntegerToHex(-13, '-D');
		assertIntegerToHex(-12, '-C');
		assertIntegerToHex(-11, '-B');
		assertIntegerToHex(-10, '-A');
		assertIntegerToHex(-9, '-9');
		assertIntegerToHex(-8, '-8');
		assertIntegerToHex(-7, '-7');
		assertIntegerToHex(-6, '-6');
		assertIntegerToHex(-5, '-5');
		assertIntegerToHex(-4, '-4');
		assertIntegerToHex(-3, '-3');
		assertIntegerToHex(-2, '-2');
		assertIntegerToHex(-1, '-1');
		assertIntegerToHex(0, '0');
		assertIntegerToHex(1, '1');
		assertIntegerToHex(2, '2');
		assertIntegerToHex(3, '3');
		assertIntegerToHex(4, '4');
		assertIntegerToHex(5, '5');
		assertIntegerToHex(6, '6');
		assertIntegerToHex(7, '7');
		assertIntegerToHex(8, '8');
		assertIntegerToHex(9, '9');
		assertIntegerToHex(10, 'A');
		assertIntegerToHex(11, 'B');
		assertIntegerToHex(12, 'C');
		assertIntegerToHex(13, 'D');
		assertIntegerToHex(14, 'E');
		assertIntegerToHex(15, 'F');
		assertIntegerToHex(16, '10');
		assertIntegerToHex(17, '11');
		assertIntegerToHex(2147483646, '7FFFFFFE');
		assertIntegerToHex(2147483647, '7FFFFFFF');

	}

	private static void assertIntegerToHex(Integer i, String expected)
	{
		String actual = CMN_UTIL_Number.toHexString(i);
		System.assert(actual == expected, 'CMN_UTIL_Number.toHex(' + i + ') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testIntegerToStringNullInput()
	{
		//test: global static String toString(Integer i, Integer radix){
		Integer i = null;
		System.assertEquals(null, CMN_UTIL_Number.toString(i, 2));
	}

	@IsTest
	private static void testIntegerToStringBadRadix()
	{
		//test: global static String toString(Integer i, Integer radix){
		Boolean exceptionCaught = false;
		try
		{
			CMN_UTIL_Number.toString(0, 1);
		}
		catch(IllegalArgumentException e)
		{
			exceptionCaught = true;
		}
		System.assert(exceptionCaught, 'CMN_UTIL_Number.toString(null,1) did not throw IllegalArgumentException');
		exceptionCaught = false;
		try
		{
			CMN_UTIL_Number.toString(0, 37);
		}
		catch(IllegalArgumentException e)
		{
			exceptionCaught = true;
		}
		System.assert(exceptionCaught, 'CMN_UTIL_Number.toString(null,1) did not throw IllegalArgumentException');
	}

	@IsTest
	private static void testLongToBinary()
	{
		//test: global static String toBinaryString(Long i){
		/*
		//can't do these tests b/c hitting System.Exception: Maximum stack depth reached: 66
		assertLongToBinary(-9223372036854775807L,'-111111111111111111111111111111111111111111111111111111111111111');
		assertLongToBinary(-9223372036854775806L,'-111111111111111111111111111111111111111111111111111111111111110');
		*/
		assertLongToBinary(-4L, '-100');
		assertLongToBinary(-3L, '-11');
		assertLongToBinary(-2L, '-10');
		assertLongToBinary(-1L, '-1');
		assertLongToBinary(0L, '0');
		assertLongToBinary(1L, '1');
		assertLongToBinary(2L, '10');
		assertLongToBinary(3L, '11');
		assertLongToBinary(4L, '100');
		/*
		//can't do these tests b/c hitting System.Exception: Maximum stack depth reached: 66
		assertLongToBinary(9223372036854775806L,'111111111111111111111111111111111111111111111111111111111111110');
		assertLongToBinary(9223372036854775807L,'111111111111111111111111111111111111111111111111111111111111111');
		*/
	}

	private static void assertLongToBinary(Long l, String expected)
	{
		String actual = CMN_UTIL_Number.toBinaryString(l);
		System.assert(actual == expected, 'CMN_UTIL_Number.toBinary(' + l + ') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testLongToOctal()
	{
		//test: global static String toOctalString(Long l){
		assertLongToOctal(-9223372036854775807L, '-777777777777777777777');
		assertLongToOctal(-9223372036854775806L, '-777777777777777777776');
		assertLongToOctal(-9L, '-11');
		assertLongToOctal(-8L, '-10');
		assertLongToOctal(-7L, '-7');
		assertLongToOctal(-6L, '-6');
		assertLongToOctal(-5L, '-5');
		assertLongToOctal(-4L, '-4');
		assertLongToOctal(-3L, '-3');
		assertLongToOctal(-2L, '-2');
		assertLongToOctal(-1L, '-1');
		assertLongToOctal(0L, '0');
		assertLongToOctal(1L, '1');
		assertLongToOctal(2L, '2');
		assertLongToOctal(3L, '3');
		assertLongToOctal(4L, '4');
		assertLongToOctal(5L, '5');
		assertLongToOctal(6L, '6');
		assertLongToOctal(7L, '7');
		assertLongToOctal(8L, '10');
		assertLongToOctal(9L, '11');
		assertLongToOctal(9223372036854775806L, '777777777777777777776');
		assertLongToOctal(9223372036854775807L, '777777777777777777777');

	}

	private static void assertLongToOctal(Long l, String expected)
	{
		String actual = CMN_UTIL_Number.toOctalString(l);
		System.assert(actual == expected, 'CMN_UTIL_Number.toOctal(' + l + ') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testLongToHex()
	{
		//test: global static String toHexString(Long l){
		assertLongToHex(-9223372036854775807L, '-7FFFFFFFFFFFFFFF');
		assertLongToHex(-9223372036854775806L, '-7FFFFFFFFFFFFFFE');
		assertLongToHex(-19L, '-13');
		assertLongToHex(-18L, '-12');
		assertLongToHex(-17L, '-11');
		assertLongToHex(-16L, '-10');
		assertLongToHex(-15L, '-F');
		assertLongToHex(-14L, '-E');
		assertLongToHex(-13L, '-D');
		assertLongToHex(-12L, '-C');
		assertLongToHex(-11L, '-B');
		assertLongToHex(-10L, '-A');
		assertLongToHex(-9L, '-9');
		assertLongToHex(-8L, '-8');
		assertLongToHex(-7L, '-7');
		assertLongToHex(-6L, '-6');
		assertLongToHex(-5L, '-5');
		assertLongToHex(-4L, '-4');
		assertLongToHex(-3L, '-3');
		assertLongToHex(-2L, '-2');
		assertLongToHex(-1L, '-1');
		assertLongToHex(0L, '0');
		assertLongToHex(1L, '1');
		assertLongToHex(2L, '2');
		assertLongToHex(3L, '3');
		assertLongToHex(4L, '4');
		assertLongToHex(5L, '5');
		assertLongToHex(6L, '6');
		assertLongToHex(7L, '7');
		assertLongToHex(8L, '8');
		assertLongToHex(9L, '9');
		assertLongToHex(10L, 'A');
		assertLongToHex(11L, 'B');
		assertLongToHex(12L, 'C');
		assertLongToHex(13L, 'D');
		assertLongToHex(14L, 'E');
		assertLongToHex(15L, 'F');
		assertLongToHex(16L, '10');
		assertLongToHex(17L, '11');
		assertLongToHex(9223372036854775806L, '7FFFFFFFFFFFFFFE');
		assertLongToHex(9223372036854775807L, '7FFFFFFFFFFFFFFF');

	}

	private static void assertLongToHex(Long l, String expected)
	{
		String actual = CMN_UTIL_Number.toHexString(l);
		System.assert(actual == expected, 'CMN_UTIL_Number.toHex(' + l + ') returned \''
				+ actual + '\'; expected \'' + expected + '\'');
	}

	@IsTest
	private static void testLongToStringNullInput()
	{
		//test: global static String toString(Long l, Long radix){
		Long l = null;
		System.assertEquals(null, CMN_UTIL_Number.toString(l, 2));
	}

	@IsTest
	private static void testLongToStringBadRadix()
	{
		//test: global static String toString(Long l, Integer radix){
		Boolean exceptionCaught = false;
		try
		{
			CMN_UTIL_Number.toString(0L, 1);
		}
		catch(IllegalArgumentException e)
		{
			exceptionCaught = true;
		}
		System.assert(exceptionCaught, 'CMN_UTIL_Number.toString(null,1) did not throw IllegalArgumentException');
		exceptionCaught = false;
		try
		{
			CMN_UTIL_Number.toString(0L, 37);
		}
		catch(IllegalArgumentException e)
		{
			exceptionCaught = true;
		}
		System.assert(exceptionCaught, 'CMN_UTIL_Number.toString(null,1) did not throw IllegalArgumentException');
	}

}