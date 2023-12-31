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
global class CMN_UTIL_Character
{
	global static final CMN_UTIL_NumberRange.IntegerRange UPPERCASE_ASCII_RANGE = new CMN_UTIL_NumberRange.IntegerRange(65, 90);
	global static final CMN_UTIL_NumberRange.IntegerRange LOWERCASE_ASCII_RANGE = new CMN_UTIL_NumberRange.IntegerRange(97, 122);
	global static final CMN_UTIL_NumberRange.IntegerRange DIGIT_ASCII_RANGE = new CMN_UTIL_NumberRange.IntegerRange(48, 57);

	global static final Integer CONNECTOR_PUNCTUATION = 2;
	global static final Integer CONTROL = 3;
	global static final Integer CURRENCY_SYMBOL = 4;
	global static final Integer DASH_PUNCTUATION = 5;
	global static final Integer DECIMAL_DIGIT_NUMBER = 6;
	global static final Integer END_PUNCTUATION = 8;
	global static final Integer LOWERCASE_LETTER = 14;
	global static final Integer MATH_SYMBOL = 15;
	global static final Integer MODIFIER_SYMBOL = 17;
	global static final Integer OTHER_PUNCTUATION = 21;
	global static final Integer SPACE_SEPARATOR = 25;
	global static final Integer START_PUNCTUATION = 26;
	global static final Integer UNASSIGNED = 29;
	global static final Integer UPPERCASE_LETTER = 30;

	private static final Map<String, Integer> CHAR_TO_ASCII = new Map<String, Integer>();
	private static final Map<Integer, String> ASCII_TO_CHAR = new Map<Integer, String>();
	private static final Map<Integer, Integer> ASCII_TO_TYPE = new Map<Integer, Integer>();

	/**
	 * @description Returns a value indicating a character's general category.
	 * <p/>
	 * <p><b>Note:</b> This method cannot handle <a
	 * href="#supplementary"> supplementary characters</a>. To support
	 * all Unicode characters, including supplementary characters, use
	 * the {@link #getType(int)} method.
	 *
	 * @param character the character to be tested.
	 *
	 * @return a value of type {@code int} representing the
	 *          character's general category.
	 * @since   1.1
	 */
	global static Integer getType(String character)
	{
		validateChar(character);
		Integer ascii = toAscii(character);
		if(ASCII_TO_TYPE.containsKey(ascii))
		{
			return ASCII_TO_TYPE.get(ascii);
		}
		return UNASSIGNED;
	}

	/**
	 * @description returns ascii number from character
	 *
	 * @param character as input
	 *
	 * @return ascii number for char 0 to 127
	 */
	global static Integer toAscii(String character)
	{
		validateChar(character);
		if(CHAR_TO_ASCII.containsKey(character))
		{
			return CHAR_TO_ASCII.get(character);
		}
		return -1;
	}

	/**
	 * @description returned asci character based on input asci number
	 *
	 * @param ascii as input
	 *
	 * @return char mapping to number
	 */
	global static String toChar(Integer ascii)
	{
		if(ascii <= 0 || ascii > 127)
		{
			return null;
		}
		if(ASCII_TO_CHAR.containsKey(ascii))
		{
			return ASCII_TO_CHAR.get(ascii);
		}
		return null;
	}

	/**
	 * @description Converts the character argument to titlecase using case mapping
	 * information from the UnicodeData file. If a character has no
	 * explicit titlecase mapping and is not itself a titlecase char
	 * according to UnicodeData, then the uppercase mapping is
	 * returned as an equivalent titlecase mapping. If the
	 * {@code char} argument is already a titlecase
	 * {@code char}, the same {@code char} value will be
	 * returned.
	 * <p>
	 * Note that
	 * {@code Character.isTitleCase(Character.toTitleCase(ch))}
	 * does not always return {@code true} for some ranges of
	 * characters.
	 * <p/>
	 * <p><b>Note:</b> This method cannot handle <a
	 * href="#supplementary"> supplementary characters</a>. To support
	 * all Unicode characters, including supplementary characters, use
	 * the {@link #toTitleCase(int)} method.
	 *
	 * @param ch the character to be converted.
	 *
	 * @return the titlecase equivalent of the character, if any;
	 *          otherwise, the character itself.
	 * @since   1.0.2
	 */
	global static String toTitleCase(String ch)
	{
		if(inAsciiRange(ch, LOWERCASE_ASCII_RANGE))
		{
			return toChar(toAscii(ch) - 32);
		}
		return ch;
	}

	/**
	 * @description Converts the character argument to uppercase using case mapping
	 * information from the UnicodeData file.
	 * <p>
	 * Note that
	 * {@code Character.isUpperCase(Character.toUpperCase(ch))}
	 * does not always return {@code true} for some ranges of
	 * characters, particularly those that are symbols or ideographs.
	 * <p/>
	 * <p>In general, {@link String#toUpperCase()} should be used to map
	 * characters to uppercase. {@code String} case mapping methods
	 * have several benefits over {@code Character} case mapping methods.
	 * {@code String} case mapping methods can perform locale-sensitive
	 * mappings, context-sensitive mappings, and 1:M character mappings, whereas
	 * the {@code Character} case mapping methods cannot.
	 * <p/>
	 * <p><b>Note:</b> This method cannot handle <a
	 * href="#supplementary"> supplementary characters</a>. To support
	 * all Unicode characters, including supplementary characters, use
	 * the {@link #toUpperCase(int)} method.
	 *
	 * @param ch the character to be converted.
	 *
	 * @return the uppercase equivalent of the character, if any;
	 *          otherwise, the character itself.
	 *
	 * @see String #toUpperCase()
	 */
	global static String toUpperCase(String ch)
	{
		return toTitleCase(ch);
	}

	/**
	 * @description Converts the character argument to lowercase using case
	 * mapping information from the UnicodeData file.
	 * <p>
	 * Note that
	 * {@code Character.isLowerCase(Character.toLowerCase(ch))}
	 * does not always return {@code true} for some ranges of
	 * characters, particularly those that are symbols or ideographs.
	 * <p/>
	 * <p>In general, {@link String#toLowerCase()} should be used to map
	 * characters to lowercase. {@code String} case mapping methods
	 * have several benefits over {@code Character} case mapping methods.
	 * {@code String} case mapping methods can perform locale-sensitive
	 * mappings, context-sensitive mappings, and 1:M character mappings, whereas
	 * the {@code Character} case mapping methods cannot.
	 * <p/>
	 * <p><b>Note:</b> This method cannot handle <a
	 * href="#supplementary"> supplementary characters</a>. To support
	 * all Unicode characters, including supplementary characters, use
	 * the {@link #toLowerCase(int)} method.
	 *
	 * @param ch the character to be converted.
	 *
	 * @return the lowercase equivalent of the character, if any;
	 *          otherwise, the character itself.
	 *
	 * @see String #toLowerCase()
	 */
	global static String toLowerCase(String ch)
	{
		if(inAsciiRange(ch, UPPERCASE_ASCII_RANGE))
		{
			return toChar(toAscii(ch) + 32);
		}
		return ch;
	}

	/**
	 * @description Determines if the specified character is an uppercase character.
	 * <p>
	 * A character is uppercase if its general category type, provided by
	 * {@code Character.getType(ch)}, is {@code UPPERCASE_LETTER}.
	 * or it has contributory property Other_Uppercase as defined by the Unicode Standard.
	 * <p>
	 * The following are examples of uppercase characters:
	 * <blockquote><pre>
	 * A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
	 * '&#92;u00C0' '&#92;u00C1' '&#92;u00C2' '&#92;u00C3' '&#92;u00C4' '&#92;u00C5' '&#92;u00C6' '&#92;u00C7'
	 * '&#92;u00C8' '&#92;u00C9' '&#92;u00CA' '&#92;u00CB' '&#92;u00CC' '&#92;u00CD' '&#92;u00CE' '&#92;u00CF'
	 * '&#92;u00D0' '&#92;u00D1' '&#92;u00D2' '&#92;u00D3' '&#92;u00D4' '&#92;u00D5' '&#92;u00D6' '&#92;u00D8'
	 * '&#92;u00D9' '&#92;u00DA' '&#92;u00DB' '&#92;u00DC' '&#92;u00DD' '&#92;u00DE'
	 * </pre></blockquote>
	 * <p> Many other Unicode characters are uppercase too.
	 * <p/>
	 * <p><b>Note:</b> This method cannot handle <a
	 * href="#supplementary"> supplementary characters</a>. To support
	 * all Unicode characters, including supplementary characters, use
	 * the {@link #isUpperCase(int)} method.
	 *
	 * @param character the character to be tested.
	 *
	 * @return {@code true} if the character is uppercase;
	 *          {@code false} otherwise.
	 * @since   1.0
	 */
	global static Boolean isUpperCase(String character)
	{
		return inAsciiRange(character, UPPERCASE_ASCII_RANGE);
	}

	/**
	 * @description Determines if the specified character is a titlecase character.
	 * <p>
	 * A character is a titlecase character if its general
	 * category type, provided by {@code Character.getType(ch)},
	 * is {@code TITLECASE_LETTER}.
	 * <p>
	 * Some characters look like pairs of Latin letters. For example, there
	 * is an uppercase letter that looks like "LJ" and has a corresponding
	 * lowercase letter that looks like "lj". A third form, which looks like "Lj",
	 * is the appropriate form to use when rendering a word in lowercase
	 * with initial capitals, as for a book title.
	 * <p>
	 * These are some of the Unicode characters for which this method returns
	 * {@code true}:
	 * <ul>
	 * <li>{@code LATIN CAPITAL LETTER D WITH SMALL LETTER Z WITH CARON}
	 * <li>{@code LATIN CAPITAL LETTER L WITH SMALL LETTER J}
	 * <li>{@code LATIN CAPITAL LETTER N WITH SMALL LETTER J}
	 * <li>{@code LATIN CAPITAL LETTER D WITH SMALL LETTER Z}
	 * </ul>
	 * <p> Many other Unicode characters are titlecase too.
	 * <p/>
	 * <p><b>Note:</b> This method cannot handle <a
	 * href="#supplementary"> supplementary characters</a>. To support
	 * all Unicode characters, including supplementary characters, use
	 * the {@link #isTitleCase(int)} method.
	 *
	 * @param character the character to be tested.
	 *
	 * @return {@code true} if the character is titlecase;
	 *          {@code false} otherwise.
	 * @since   1.0.2
	 */
	global static Boolean isTitleCase(String character)
	{
		return inAsciiRange(character, UPPERCASE_ASCII_RANGE);
	}

	/**
	 * @description Determines if the specified character is a lowercase character.
	 * <p>
	 * A character is lowercase if its general category type, provided
	 * by {@code Character.getType(ch)}, is
	 * {@code LOWERCASE_LETTER}, or it has contributory property
	 * Other_Lowercase as defined by the Unicode Standard.
	 * <p>
	 * The following are examples of lowercase characters:
	 * <blockquote><pre>
	 * a b c d e f g h i j k l m n o p q r s t u v w x y z
	 * '&#92;u00DF' '&#92;u00E0' '&#92;u00E1' '&#92;u00E2' '&#92;u00E3' '&#92;u00E4' '&#92;u00E5' '&#92;u00E6'
	 * '&#92;u00E7' '&#92;u00E8' '&#92;u00E9' '&#92;u00EA' '&#92;u00EB' '&#92;u00EC' '&#92;u00ED' '&#92;u00EE'
	 * '&#92;u00EF' '&#92;u00F0' '&#92;u00F1' '&#92;u00F2' '&#92;u00F3' '&#92;u00F4' '&#92;u00F5' '&#92;u00F6'
	 * '&#92;u00F8' '&#92;u00F9' '&#92;u00FA' '&#92;u00FB' '&#92;u00FC' '&#92;u00FD' '&#92;u00FE' '&#92;u00FF'
	 * </pre></blockquote>
	 * <p> Many other Unicode characters are lowercase too.
	 * <p/>
	 * <p><b>Note:</b> This method cannot handle <a
	 * href="#supplementary"> supplementary characters</a>. To support
	 * all Unicode characters, including supplementary characters, use
	 * the {@link #isLowerCase(int)} method.
	 *
	 * @param character the character to be tested.
	 *
	 * @return {@code true} if the character is lowercase;
	 *          {@code false} otherwise.
	 */
	global static Boolean isLowerCase(String character)
	{
		return inAsciiRange(character, LOWERCASE_ASCII_RANGE);
	}

	/**
	 * @description Determines if the specified character is a digit.
	 * <p>
	 * A character is a digit if its general category type, provided
	 * by {@code Character.getType(ch)}, is
	 * {@code DECIMAL_DIGIT_NUMBER}.
	 * <p>
	 * Some Unicode character ranges that contain digits:
	 * <ul>
	 * <li>{@code '\u005Cu0030'} through {@code '\u005Cu0039'},
	 *     ISO-LATIN-1 digits ({@code '0'} through {@code '9'})
	 * <li>{@code '\u005Cu0660'} through {@code '\u005Cu0669'},
	 *     Arabic-Indic digits
	 * <li>{@code '\u005Cu06F0'} through {@code '\u005Cu06F9'},
	 *     Extended Arabic-Indic digits
	 * <li>{@code '\u005Cu0966'} through {@code '\u005Cu096F'},
	 *     Devanagari digits
	 * <li>{@code '\u005CuFF10'} through {@code '\u005CuFF19'},
	 *     Fullwidth digits
	 * </ul>
	 * <p/>
	 * Many other character ranges contain digits as well.
	 * <p/>
	 * <p><b>Note:</b> This method cannot handle <a
	 * href="#supplementary"> supplementary characters</a>. To support
	 * all Unicode characters, including supplementary characters, use
	 * the {@link #isDigit(int)} method.
	 *
	 * @param character the character to be tested.
	 *
	 * @return {@code true} if the character is a digit;
	 *          {@code false} otherwise.
	 */
	global static Boolean isDigit(String character)
	{
		return inAsciiRange(character, DIGIT_ASCII_RANGE);
	}

	/**
	 * @description Determines if the specified character is a letter.
	 * <p>
	 * A character is considered to be a letter if its general
	 * category type, provided by {@code Character.getType(ch)},
	 * is any of the following:
	 * <ul>
	 * <li> {@code UPPERCASE_LETTER}
	 * <li> {@code LOWERCASE_LETTER}
	 * <li> {@code TITLECASE_LETTER}
	 * <li> {@code MODIFIER_LETTER}
	 * <li> {@code OTHER_LETTER}
	 * </ul>
	 * <p/>
	 * Not all letters have case. Many characters are
	 * letters but are neither uppercase nor lowercase nor titlecase.
	 * <p/>
	 * <p><b>Note:</b> This method cannot handle <a
	 * href="#supplementary"> supplementary characters</a>. To support
	 * all Unicode characters, including supplementary characters, use
	 * the {@link #isLetter(int)} method.
	 *
	 * @param character the character to be tested.
	 *
	 * @return {@code true} if the character is a letter;
	 *          {@code false} otherwise.
	 */
	global static Boolean isLetter(String character)
	{
		return isLowerCase(character) || isUpperCase(character);
	}

	/**
	 * @description Determines if the specified character is a letter or digit.
	 * <p>
	 * A character is considered to be a letter or digit if either
	 * {@code Character.isLetter(char ch)} or
	 * {@code Character.isDigit(char ch)} returns
	 * {@code true} for the character.
	 * <p/>
	 * <p><b>Note:</b> This method cannot handle <a
	 * href="#supplementary"> supplementary characters</a>. To support
	 * all Unicode characters, including supplementary characters, use
	 * the {@link #isLetterOrDigit(int)} method.
	 *
	 * @param character the character to be tested.
	 *
	 * @return {@code true} if the character is a letter or digit;
	 *          {@code false} otherwise.
	 * @since   1.0.2
	 */
	global static Boolean isLetterOrDigit(String character)
	{
		return isLetter(character) || isDigit(character);
	}

	/**
	 * @description Determines if the specified character is white space according to Java.
	 * A character is a Java whitespace character if and only if it satisfies
	 * one of the following criteria:
	 * <ul>
	 * <li> It is a Unicode space character ({@code SPACE_SEPARATOR},
	 *      {@code LINE_SEPARATOR}, or {@code PARAGRAPH_SEPARATOR})
	 *      but is not also a non-breaking space ({@code '\u005Cu00A0'},
	 *      {@code '\u005Cu2007'}, {@code '\u005Cu202F'}).
	 * <li> It is {@code '\u005Ct'}, U+0009 HORIZONTAL TABULATION.
	 * <li> It is {@code '\u005Cn'}, U+000A LINE FEED.
	 * <li> It is {@code '\u005Cu000B'}, U+000B VERTICAL TABULATION.
	 * <li> It is {@code '\u005Cf'}, U+000C FORM FEED.
	 * <li> It is {@code '\u005Cr'}, U+000D CARRIAGE RETURN.
	 * <li> It is {@code '\u005Cu001C'}, U+001C FILE SEPARATOR.
	 * <li> It is {@code '\u005Cu001D'}, U+001D GROUP SEPARATOR.
	 * <li> It is {@code '\u005Cu001E'}, U+001E RECORD SEPARATOR.
	 * <li> It is {@code '\u005Cu001F'}, U+001F UNIT SEPARATOR.
	 * </ul>
	 * <p/>
	 * <p><b>Note:</b> This method cannot handle <a
	 * href="#supplementary"> supplementary characters</a>. To support
	 * all Unicode characters, including supplementary characters, use
	 * the {@link #isWhitespace(int)} method.
	 *
	 * @param character the character to be tested.
	 *
	 * @return {@code true} if the character is a Java whitespace
	 *          character; {@code false} otherwise.
	 * @since   1.1
	 */
	global static Boolean isWhitespace(String character)
	{
		validateChar(character);
		return ' '.equals(character)
				|| '\n'.equals(character)
				|| '\t'.equals(character)
				|| '\f'.equals(character)
				|| '\r'.equals(character);
	}

	/**
	 * @description <p>Checks whether the character is ASCII 7 bit.</p>
	 * <p/>
	 * <pre>
	 *   CharUtils.isAscii('a')  = true
	 *   CharUtils.isAscii('A')  = true
	 *   CharUtils.isAscii('3')  = true
	 *   CharUtils.isAscii('-')  = true
	 *   CharUtils.isAscii('\n') = true
	 *   CharUtils.isAscii('&copy;') = false
	 * </pre>
	 *
	 * @param character the character to check
	 *
	 * @return true if less than 128
	 */
	global static Boolean isAscii(String character)
	{
		Integer ascii = toAscii(character);
		return ascii >= 0 && ascii < 128;
	}

	/**
	 * @description <p>Checks whether the character is ASCII 7 bit printable.</p>
	 * <p/>
	 * <pre>
	 *   CharUtils.isAsciiPrintable('a')  = true
	 *   CharUtils.isAsciiPrintable('A')  = true
	 *   CharUtils.isAsciiPrintable('3')  = true
	 *   CharUtils.isAsciiPrintable('-')  = true
	 *   CharUtils.isAsciiPrintable('\n') = false
	 *   CharUtils.isAsciiPrintable('&copy;') = false
	 * </pre>
	 *
	 * @param character the character to check
	 *
	 * @return true if between 32 and 126 inclusive
	 */
	global static Boolean isAsciiPrintable(String character)
	{
		Integer ascii = toAscii(character);
		return ascii >= 32 && ascii < 127;
	}

	/**
	 * @description <p>Checks whether the character is ASCII 7 bit control.</p>
	 * <p/>
	 * <pre>
	 *   CharUtils.isAsciiControl('a')  = false
	 *   CharUtils.isAsciiControl('A')  = false
	 *   CharUtils.isAsciiControl('3')  = false
	 *   CharUtils.isAsciiControl('-')  = false
	 *   CharUtils.isAsciiControl('\n') = true
	 *   CharUtils.isAsciiControl('&copy;') = false
	 * </pre>
	 *
	 * @param character the character to check
	 *
	 * @return true if less than 32 or equals 127
	 */
	global static Boolean isAsciiControl(String character)
	{
		Integer ascii = toAscii(character);
		return (ascii >= 0 && ascii < 32) || ascii == 127;
	}

	/**
	 * @description <p>Checks whether the character is ASCII 7 bit alphabetic.</p>
	 * <p/>
	 * <pre>
	 *   CharUtils.isAsciiAlpha('a')  = true
	 *   CharUtils.isAsciiAlpha('A')  = true
	 *   CharUtils.isAsciiAlpha('3')  = false
	 *   CharUtils.isAsciiAlpha('-')  = false
	 *   CharUtils.isAsciiAlpha('\n') = false
	 *   CharUtils.isAsciiAlpha('&copy;') = false
	 * </pre>
	 *
	 * @param character the character to check
	 *
	 * @return true if between 65 and 90 or 97 and 122 inclusive
	 */
	global static Boolean isAsciiAlpha(String character)
	{
		return inAsciiRange(character, UPPERCASE_ASCII_RANGE) || inAsciiRange(character, LOWERCASE_ASCII_RANGE);
	}

	/**
	 * @description <p>Checks whether the character is ASCII 7 bit alphabetic upper case.</p>
	 * <p/>
	 * <pre>
	 *   CharUtils.isAsciiAlphaUpper('a')  = false
	 *   CharUtils.isAsciiAlphaUpper('A')  = true
	 *   CharUtils.isAsciiAlphaUpper('3')  = false
	 *   CharUtils.isAsciiAlphaUpper('-')  = false
	 *   CharUtils.isAsciiAlphaUpper('\n') = false
	 *   CharUtils.isAsciiAlphaUpper('&copy;') = false
	 * </pre>
	 *
	 * @param character the character to check
	 *
	 * @return true if between 65 and 90 inclusive
	 */
	global static Boolean isAsciiAlphaUpper(String character)
	{
		return inAsciiRange(character, UPPERCASE_ASCII_RANGE);
	}

	/**
	 * @description <p>Checks whether the character is ASCII 7 bit alphabetic lower case.</p>
	 * <p/>
	 * <pre>
	 *   CharUtils.isAsciiAlphaLower('a')  = true
	 *   CharUtils.isAsciiAlphaLower('A')  = false
	 *   CharUtils.isAsciiAlphaLower('3')  = false
	 *   CharUtils.isAsciiAlphaLower('-')  = false
	 *   CharUtils.isAsciiAlphaLower('\n') = false
	 *   CharUtils.isAsciiAlphaLower('&copy;') = false
	 * </pre>
	 *
	 * @param character the character to check
	 *
	 * @return true if between 97 and 122 inclusive
	 */
	global static Boolean isAsciiAlphaLower(String character)
	{
		return inAsciiRange(character, LOWERCASE_ASCII_RANGE);
	}

	/**
	 * @description <p>Checks whether the character is ASCII 7 bit numeric.</p>
	 * <p/>
	 * <pre>
	 *   CharUtils.isAsciiNumeric('a')  = false
	 *   CharUtils.isAsciiNumeric('A')  = false
	 *   CharUtils.isAsciiNumeric('3')  = true
	 *   CharUtils.isAsciiNumeric('-')  = false
	 *   CharUtils.isAsciiNumeric('\n') = false
	 *   CharUtils.isAsciiNumeric('&copy;') = false
	 * </pre>
	 *
	 * @param character the character to check
	 *
	 * @return true if between 48 and 57 inclusive
	 */
	global static Boolean isAsciiNumeric(String character)
	{
		return inAsciiRange(character, DIGIT_ASCII_RANGE);
	}

	/**
	 * @description <p>Checks whether the character is ASCII 7 bit numeric.</p>
	 * <p/>
	 * <pre>
	 *   CharUtils.isAsciiAlphanumeric('a')  = true
	 *   CharUtils.isAsciiAlphanumeric('A')  = true
	 *   CharUtils.isAsciiAlphanumeric('3')  = true
	 *   CharUtils.isAsciiAlphanumeric('-')  = false
	 *   CharUtils.isAsciiAlphanumeric('\n') = false
	 *   CharUtils.isAsciiAlphanumeric('&copy;') = false
	 * </pre>
	 *
	 * @param character the character to check
	 *
	 * @return true if between 48 and 57 or 65 and 90 or 97 and 122 inclusive
	 */
	global static Boolean isAsciiAlphanumeric(String character)
	{
		return inAsciiRange(character, UPPERCASE_ASCII_RANGE)
				|| inAsciiRange(character, LOWERCASE_ASCII_RANGE)
				|| inAsciiRange(character, DIGIT_ASCII_RANGE);
	}

	/**
	 * @description checks if character is valid
	 *
	 * @param character as input
	 */
	global static void validateChar(String character)
	{
		if(character != null && character.length() != 1)
		{
			throw new CMN_UTIL_Exceptions.InvalidCharacterStringException('Invalid character string: ' + character);
		}
	}

	/**
	 * @description checks if character is within ascii range
	 *
	 * @param character as input
	 * @param range as input
	 *
	 * @return in range or not
	 */
	private static Boolean inAsciiRange(String character, CMN_UTIL_NumberRange.IntegerRange range)
	{
		return range == null ? false : range.contains(toAscii(character));
	}

	static
	{
		CHAR_TO_ASCII.put(null, 0);
		CHAR_TO_ASCII.put('\t', 9);
		CHAR_TO_ASCII.put('\n', 10);
		CHAR_TO_ASCII.put('\f', 12);
		CHAR_TO_ASCII.put('\r', 13);
		CHAR_TO_ASCII.put(' ', 32);
		CHAR_TO_ASCII.put('!', 33);
		CHAR_TO_ASCII.put('"', 34);
		CHAR_TO_ASCII.put('#', 35);
		CHAR_TO_ASCII.put('$', 36);
		CHAR_TO_ASCII.put('%', 37);
		CHAR_TO_ASCII.put('&', 38);
		CHAR_TO_ASCII.put('\'', 39);
		CHAR_TO_ASCII.put('(', 40);
		CHAR_TO_ASCII.put(')', 41);
		CHAR_TO_ASCII.put('*', 42);
		CHAR_TO_ASCII.put('+', 43);
		CHAR_TO_ASCII.put(',', 44);
		CHAR_TO_ASCII.put('-', 45);
		CHAR_TO_ASCII.put('.', 46);
		CHAR_TO_ASCII.put('/', 47);
		CHAR_TO_ASCII.put('0', 48);
		CHAR_TO_ASCII.put('1', 49);
		CHAR_TO_ASCII.put('2', 50);
		CHAR_TO_ASCII.put('3', 51);
		CHAR_TO_ASCII.put('4', 52);
		CHAR_TO_ASCII.put('5', 53);
		CHAR_TO_ASCII.put('6', 54);
		CHAR_TO_ASCII.put('7', 55);
		CHAR_TO_ASCII.put('8', 56);
		CHAR_TO_ASCII.put('9', 57);
		CHAR_TO_ASCII.put(':', 58);
		CHAR_TO_ASCII.put(';', 59);
		CHAR_TO_ASCII.put('<', 60);
		CHAR_TO_ASCII.put('=', 61);
		CHAR_TO_ASCII.put('>', 62);
		CHAR_TO_ASCII.put('?', 63);
		CHAR_TO_ASCII.put('@', 64);
		CHAR_TO_ASCII.put('A', 65);
		CHAR_TO_ASCII.put('B', 66);
		CHAR_TO_ASCII.put('C', 67);
		CHAR_TO_ASCII.put('D', 68);
		CHAR_TO_ASCII.put('E', 69);
		CHAR_TO_ASCII.put('F', 70);
		CHAR_TO_ASCII.put('G', 71);
		CHAR_TO_ASCII.put('H', 72);
		CHAR_TO_ASCII.put('I', 73);
		CHAR_TO_ASCII.put('J', 74);
		CHAR_TO_ASCII.put('K', 75);
		CHAR_TO_ASCII.put('L', 76);
		CHAR_TO_ASCII.put('M', 77);
		CHAR_TO_ASCII.put('N', 78);
		CHAR_TO_ASCII.put('O', 79);
		CHAR_TO_ASCII.put('P', 80);
		CHAR_TO_ASCII.put('Q', 81);
		CHAR_TO_ASCII.put('R', 82);
		CHAR_TO_ASCII.put('S', 83);
		CHAR_TO_ASCII.put('T', 84);
		CHAR_TO_ASCII.put('U', 85);
		CHAR_TO_ASCII.put('V', 86);
		CHAR_TO_ASCII.put('W', 87);
		CHAR_TO_ASCII.put('X', 88);
		CHAR_TO_ASCII.put('Y', 89);
		CHAR_TO_ASCII.put('Z', 90);
		CHAR_TO_ASCII.put('[', 91);
		CHAR_TO_ASCII.put('\\', 92);
		CHAR_TO_ASCII.put(']', 93);
		CHAR_TO_ASCII.put('^', 94);
		CHAR_TO_ASCII.put('_', 95);
		CHAR_TO_ASCII.put('`', 96);
		CHAR_TO_ASCII.put('a', 97);
		CHAR_TO_ASCII.put('b', 98);
		CHAR_TO_ASCII.put('c', 99);
		CHAR_TO_ASCII.put('d', 100);
		CHAR_TO_ASCII.put('e', 101);
		CHAR_TO_ASCII.put('f', 102);
		CHAR_TO_ASCII.put('g', 103);
		CHAR_TO_ASCII.put('h', 104);
		CHAR_TO_ASCII.put('i', 105);
		CHAR_TO_ASCII.put('j', 106);
		CHAR_TO_ASCII.put('k', 107);
		CHAR_TO_ASCII.put('l', 108);
		CHAR_TO_ASCII.put('m', 109);
		CHAR_TO_ASCII.put('n', 110);
		CHAR_TO_ASCII.put('o', 111);
		CHAR_TO_ASCII.put('p', 112);
		CHAR_TO_ASCII.put('q', 113);
		CHAR_TO_ASCII.put('r', 114);
		CHAR_TO_ASCII.put('s', 115);
		CHAR_TO_ASCII.put('t', 116);
		CHAR_TO_ASCII.put('u', 117);
		CHAR_TO_ASCII.put('v', 118);
		CHAR_TO_ASCII.put('w', 119);
		CHAR_TO_ASCII.put('x', 120);
		CHAR_TO_ASCII.put('y', 121);
		CHAR_TO_ASCII.put('z', 122);
		CHAR_TO_ASCII.put('{', 123);
		CHAR_TO_ASCII.put('|', 124);
		CHAR_TO_ASCII.put('}', 125);
		CHAR_TO_ASCII.put('~', 126);
		for(String key : CHAR_TO_ASCII.keySet())
		{
			ASCII_TO_CHAR.put(CHAR_TO_ASCII.get(key), key);
		}

		ASCII_TO_TYPE.put(0, CONTROL);
		ASCII_TO_TYPE.put(9, CONTROL);
		ASCII_TO_TYPE.put(10, CONTROL);
		ASCII_TO_TYPE.put(12, CONTROL);
		ASCII_TO_TYPE.put(13, CONTROL);
		ASCII_TO_TYPE.put(32, SPACE_SEPARATOR);
		ASCII_TO_TYPE.put(33, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(34, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(35, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(36, CURRENCY_SYMBOL);
		ASCII_TO_TYPE.put(37, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(38, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(39, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(40, START_PUNCTUATION);
		ASCII_TO_TYPE.put(41, END_PUNCTUATION);
		ASCII_TO_TYPE.put(42, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(43, MATH_SYMBOL);
		ASCII_TO_TYPE.put(44, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(45, DASH_PUNCTUATION);
		ASCII_TO_TYPE.put(46, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(47, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(48, DECIMAL_DIGIT_NUMBER);
		ASCII_TO_TYPE.put(49, DECIMAL_DIGIT_NUMBER);
		ASCII_TO_TYPE.put(50, DECIMAL_DIGIT_NUMBER);
		ASCII_TO_TYPE.put(51, DECIMAL_DIGIT_NUMBER);
		ASCII_TO_TYPE.put(52, DECIMAL_DIGIT_NUMBER);
		ASCII_TO_TYPE.put(53, DECIMAL_DIGIT_NUMBER);
		ASCII_TO_TYPE.put(54, DECIMAL_DIGIT_NUMBER);
		ASCII_TO_TYPE.put(55, DECIMAL_DIGIT_NUMBER);
		ASCII_TO_TYPE.put(56, DECIMAL_DIGIT_NUMBER);
		ASCII_TO_TYPE.put(57, DECIMAL_DIGIT_NUMBER);
		ASCII_TO_TYPE.put(58, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(59, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(60, MATH_SYMBOL);
		ASCII_TO_TYPE.put(61, MATH_SYMBOL);
		ASCII_TO_TYPE.put(62, MATH_SYMBOL);
		ASCII_TO_TYPE.put(63, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(64, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(65, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(66, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(67, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(68, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(69, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(70, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(71, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(72, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(73, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(74, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(75, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(76, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(77, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(78, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(79, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(80, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(81, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(82, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(83, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(84, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(85, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(86, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(87, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(88, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(89, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(90, UPPERCASE_LETTER);
		ASCII_TO_TYPE.put(91, START_PUNCTUATION);
		ASCII_TO_TYPE.put(92, OTHER_PUNCTUATION);
		ASCII_TO_TYPE.put(93, END_PUNCTUATION);
		ASCII_TO_TYPE.put(94, MODIFIER_SYMBOL);
		ASCII_TO_TYPE.put(95, CONNECTOR_PUNCTUATION);
		ASCII_TO_TYPE.put(96, MODIFIER_SYMBOL);
		ASCII_TO_TYPE.put(97, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(98, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(99, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(100, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(101, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(102, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(103, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(104, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(105, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(106, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(107, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(108, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(109, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(110, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(111, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(112, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(113, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(114, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(115, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(116, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(117, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(118, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(119, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(120, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(121, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(122, LOWERCASE_LETTER);
		ASCII_TO_TYPE.put(123, START_PUNCTUATION);
		ASCII_TO_TYPE.put(124, MATH_SYMBOL);
		ASCII_TO_TYPE.put(125, END_PUNCTUATION);
		ASCII_TO_TYPE.put(126, MATH_SYMBOL);
		ASCII_TO_TYPE.put(127, CONTROL);
	}
}