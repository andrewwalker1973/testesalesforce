/**
 * @description Utility class to streamline parsing nested JSON data structures.
 * <p/>
 * <p/>
 * MIT License
 * <p/>
 * Copyright (c) 2018 open-force https://github.com/open-force/jsonparse
 * <p/>
 * <p/>
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * <p/>
 * <p/>
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * <p/>
 * <p/>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * @see CMN_UTIL_JsonPath_TEST
 *
 * @author open-force, jason.van.beukering@accenture.com
 *
 * @date 2018, September 2022
 */
@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
public inherited sharing class CMN_UTIL_JsonPath
{
	private static final Pattern ARRAY_NOTATION = Pattern.compile('\\[(\\d+)]');
	private static final String SEPARATOR = '\\.';

	/**
	 * @description Every JSONParse instance is a wrapper around some actual data, which we store here.
	 */
	private final Object value;

	/**
	 * @description Create a JSONParse instance from a serialized JSON string.
	 *
	 * @param jsonData JSON data to parse
	 */
	public CMN_UTIL_JsonPath(String jsonData)
	{
		value = JSON.deserializeUntyped(jsonData);
	}

	/**
	 * @description Create a JSONParse instance from data that has already been unmarshalled from a JSON string.
	 *
	 * @param value An already-decoded value (such as a Map<String,Object>, or List<Object>, or a primitive)
	 */
	private CMN_UTIL_JsonPath(Object value)
	{
		this.value = value;
	}

	/**
	 * @description Drill into a nested structure to get to some subtree in the document. We allow the path to include a mix
	 * of array notation and string keys.
	 *
	 * @param path Specially-formatted string that describes where to find a data value
	 *
	 * @return A new JSONParse wrapper that wraps the targeted subtree.
	 *
	 * @throws ListException if part of the path can't be resolved because an array index is used that is out of bounds
	 * @throws MissingKeyException if part of the path can't be resolved because there is no match on that key
	 * @throws NotAnArrayException if we try to apply an array notation to a node that isn't an array
	 * @throws NotAnObjectException if we try to apply a map key to a node that isn't an object
	 */
	public CMN_UTIL_JsonPath get(String path)
	{
		CMN_UTIL_JsonPath currentNode = this;

		// drill down through the nested structure
		for(String key : path.split(SEPARATOR))
		{
			// check to see if we are going to parse this key as a reference to an array item
			Matcher arrayMatcher = ARRAY_NOTATION.matcher(key);

			if(arrayMatcher.matches())
			{
				Integer index = Integer.valueOf(arrayMatcher.group(1));
				currentNode = currentNode.asList().get(index);
			}
			else
			{
				// otherwise, treat this key as a normal map key
				Map<String, CMN_UTIL_JsonPath> wrappedMap = currentNode.asMap();

				if(!wrappedMap.containsKey(key))
				{
					throw new MissingKeyException('No match found for <' + key + '>: ' + wrappedMap.keySet());
				}

				currentNode = wrappedMap.get(key);
			}
		}

		return currentNode;
	}

	/**
	 * @description Test a get() path to see if that final property exists or not.
	 *
	 * @param path Specially-formatted string that describes where to find a data value
	 *
	 * @return True if the property exists, or false if the property or any part of the path didn't exist.
	 */
	public Boolean exists(String path)
	{
		return exists(path, false);
	}

	/**
	 * @description Test a get() path to see if that final property exists or not.
	 *
	 * @param path Specially-formatted string that describes where to find a data value
	 * @param notNull If true, this check will also assert the resulting value is not null
	 *
	 * @return True if the property exists, or false if the property or any part of the path didn't exist.
	 */
	public Boolean exists(String path, Boolean notNull)
	{
		CMN_UTIL_JsonPath foundNode = findNode(path);

		Boolean exists = foundNode != null;

		if(exists && notNull == true)
		{
			exists = foundNode.getValue() != null;
		}

		return exists;
	}

	/**
	 * @description Drill into a nested structure to get to some subtree in the document. We allow the path to include a mix
	 * of array notation and string keys.
	 *
	 * @param path Specially-formatted string that describes where to find a data value
	 *
	 * @return A new JSONParse wrapper that wraps the targeted subtree.
	 */
	public CMN_UTIL_JsonPath findNode(String path)
	{
		CMN_UTIL_JsonPath currentNode = this; // we start with ourselves and drill deeper

		// drill down through the nested structure
		for(String key : path.split(SEPARATOR))
		{
			// check to see if we are going to parse this key as a reference to an array item
			Matcher arrayMatcher = ARRAY_NOTATION.matcher(key);

			if(arrayMatcher.matches())
			{
				Integer index = Integer.valueOf(arrayMatcher.group(1));
				List<CMN_UTIL_JsonPath> nodeAsList = currentNode.asList();
				if(0 < index && index < nodeAsList.size())
				{
					currentNode = currentNode.asList().get(index);
				}
				else
				{
					return null; // index out of bounds
				}
			}
			else
			{
				// otherwise, treat this key as a normal map key
				Map<String, CMN_UTIL_JsonPath> wrappedMap = currentNode.asMap();
				currentNode = wrappedMap.get(key);

				if(currentNode == null)
				{
					return null;
				}
			}
		}

		return currentNode;
	}

	/**
	 * @description Make an assumption that this JSONParse instance wraps a JSON object, and attempt to return a Map of the values.
	 *
	 * @return A Map of JSONParse instances
	 *
	 * @throws NotAnObjectException if the internal wrapped value is not a JSON object
	 */
	public Map<String, CMN_UTIL_JsonPath> asMap()
	{
		if(!isObject())
		{
			throw new NotAnObjectException('The wrapped value is not a JSON object:\n' + toStringPretty());
		}

		Map<String, Object> valueAsMap = (Map<String, Object>)value;
		Map<String, CMN_UTIL_JsonPath> wrappers = new Map<String, CMN_UTIL_JsonPath>();
		for(String key : valueAsMap.keySet())
		{
			wrappers.put(key, new CMN_UTIL_JsonPath(valueAsMap.get(key)));
		}

		return wrappers;
	}

	/**
	 * @description Make an assumption that this JSONParse instance wraps a List, and attempt to return an iterable version
	 * of the values.
	 *
	 * @return A List of JSONParse instances, each wrapping one of the List items
	 *
	 * @throws NotAnArrayException if the internal wrapped value is not a List instance
	 */
	public List<CMN_UTIL_JsonPath> asList()
	{
		if(!isArray())
		{
			throw new NotAnArrayException('The wrapped value is not a JSON array:\n' + toStringPretty());
		}

		List<CMN_UTIL_JsonPath> wrappers = new List<CMN_UTIL_JsonPath>();
		for(Object item : (List<Object>)value)
		{
			wrappers.add(new CMN_UTIL_JsonPath(item));
		}

		return wrappers;
	}

	/**
	 * @description Checks to see if the item in path is an object
	 *
	 * @return True if its an object
	 */
	public Boolean isObject()
	{
		return value instanceof Map<String, Object>;
	}

	/**
	 * @description Checks to see if the item in path is an array
	 *
	 * @return True if its an array
	 */
	public Boolean isArray()
	{
		return value instanceof List<Object>;
	}

	/**
	 * @description Will serialise the object found in the path
	 *
	 * @return String containing the object in JSON notation
	 */
	public String toStringPretty()
	{
		return JSON.serializePretty(value);
	}

	/**
	 * @description Will return the found object as a Blob
	 *
	 * @return The item in binary format
	 *
	 * @throws InvalidConversionException Is thrown if the object isn't a string
	 */
	public Blob getBlobValue()
	{
		if(value instanceof String)
		{
			return EncodingUtil.base64Decode((String)value);
		}
		throw new InvalidConversionException('Only String values can be converted to a Blob: ' + toStringPretty());
	}

	/**
	 * @description Will return the found object as a boolean
	 *
	 * @return True of false
	 */
	public Boolean getBooleanValue()
	{
		if(value instanceof Boolean)
		{
			return (Boolean)value;
		}

		return Boolean.valueOf(value);
	}

	/**
	 * @description Will return the found object as a date time
	 *
	 * @return New DateTime
	 *
	 * @throws InvalidConversionException Is thrown if the object isn't a string or long
	 */
	public Datetime getDatetimeValue()
	{
		if(value instanceof Long)
		{
			return Datetime.newInstance((Long)value);
		}

		if(value instanceof String)
		{
			return CMN_UTIL_Date.iso8601StringToDateTime((String)value);
		}

		throw new InvalidConversionException('Only Long and String values can be converted to a Datetime: ' + toStringPretty());
	}

	/**
	 * @description Will return the found object as a date
	 *
	 * @return New Date
	 *
	 * @throws InvalidConversionException Is thrown if the object isn't a string or long
	 */
	public Date getDateValue()
	{
		if(value instanceof Long)
		{
			return Datetime.newInstance((Long)value).dateGmt();
		}
		if(value instanceof String)
		{
			return CMN_UTIL_Date.iso8601StringToDate((String)value);
		}

		throw new InvalidConversionException('Only Long and String values can be converted to a Date: ' + toStringPretty());
	}

	/**
	 * @description Will return the found object as a Decimal
	 *
	 * @return value as a decimal
	 *
	 * @throws InvalidConversionException Is thrown if the object isn't a string or decimal
	 */
	public Decimal getDecimalValue()
	{
		if(value instanceof Decimal)
		{
			return (Decimal)value;
		}

		if(value instanceof String)
		{
			return Decimal.valueOf((String)value);
		}

		throw new InvalidConversionException('This value cannot be converted to a Decimal: ' + toStringPretty());
	}

	/**
	 * @description Will return the found object as a Double
	 *
	 * @return value as a double
	 *
	 * @throws InvalidConversionException Is thrown if the object isn't a string or double
	 */
	public Double getDoubleValue()
	{
		if(value instanceof Double)
		{
			return (Double)value;
		}
		if(value instanceof String)
		{
			return Double.valueOf((String)value);
		}

		throw new InvalidConversionException('This value cannot be converted to a Double: ' + toStringPretty());
	}

	/**
	 * @description Will return the found object as an Id
	 *
	 * @return value as an Id
	 *
	 * @throws InvalidConversionException Is thrown if the object isn't a string
	 * @throws StringException Is thrown if the contents of the string is not a valid Id
	 */
	public Id getIdValue()
	{
		if(value instanceof String)
		{
			return Id.valueOf((String)value);
		}

		throw new InvalidConversionException('This value cannot be converted to an Id: ' + toStringPretty());
	}

	/**
	 * @description Will return the found object as an integer
	 *
	 * @return value as an integer
	 *
	 * @throws InvalidConversionException Is thrown if the object isn't a string, integer of decimal
	 */
	public Integer getIntegerValue()
	{
		if(value instanceof Integer)
		{
			return (Integer)value;
		}

		if(value instanceof Decimal)
		{
			return ((Decimal)value).intValue();
		}

		if(value instanceof String)
		{
			return Integer.valueOf((String)value);
		}

		throw new InvalidConversionException('This value cannot be converted to an Integer: ' + toStringPretty());
	}

	/**
	 * @description Will return the found object as a long
	 *
	 * @return value as a long
	 *
	 * @throws InvalidConversionException Is thrown if the object isn't a string, long of decimal
	 */
	public Long getLongValue()
	{
		if(value instanceof Long)
		{
			return (Long)value;
		}
		if(value instanceof Decimal)
		{
			return ((Decimal)value).longValue();
		}
		if(value instanceof String)
		{
			return Long.valueOf((String)value);
		}

		throw new InvalidConversionException('This value cannot be converted to a Long: ' + toStringPretty());
	}

	/**
	 * @description Will return the found object as a string
	 *
	 * @return value as a string
	 *
	 * @throws InvalidConversionException Is thrown if the item is a complex object or array
	 */
	public String getStringValue()
	{
		if(isObject() || isArray())
		{
			throw new InvalidConversionException('Objects and arrays are not Strings: ' + toStringPretty());
		}

		if(value instanceof String)
		{
			return (String)value;
		}

		return String.valueOf(value);
	}

	/**
	 * @description Will return the found object as a time
	 *
	 * @return value as a time
	 *
	 * @throws InvalidConversionException Is thrown if the object isn't a string or long
	 */
	public Time getTimeValue()
	{
		if(value instanceof Long)
		{
			return Datetime.newInstance((Long)value).timeGmt();
		}

		if(value instanceof String)
		{
			return CMN_UTIL_Date.iso8601StringToDateTime((String)value).timeGmt();
		}

		throw new InvalidConversionException('Only Long and String values can be converted to a Time: ' + toStringPretty());
	}

	/**
	 * @description Returns the object found for the provided path
	 *
	 * @return The found item
	 */
	public Object getValue()
	{
		return value;
	}

	/**
	 * @description Thrown if item found is not an object
	 *
	 * @see CMN_UTIL_JsonPath.asMap
	 */
	public class NotAnObjectException extends Exception
	{
	}

	/**
	 * @description Thrown if item found is not an array
	 *
	 * @see CMN_UTIL_JsonPath.asList
	 */
	public class NotAnArrayException extends Exception
	{
	}

	/**
	 * @description Thrown if part of the path can't be resolved because there is no match on that key
	 *
	 * @see CMN_UTIL_JsonPath.get
	 */
	public class MissingKeyException extends Exception
	{
	}

	/**
	 * @description Thrown if the found item cannot be converted to the type requested
	 */
	public class InvalidConversionException extends Exception
	{
	}
}