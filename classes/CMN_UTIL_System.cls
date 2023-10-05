/**
 * @description General Utility Class which will contain common routines that can be reused within the system
 *
 * @see CMN_UTIL_System_TEST
 *
 * @author darrion.james.singh@accenture.com jason.van.beukering@accenture.com
 *
 * @date May 2021, June 2023
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity,PMD.ExcessiveClassLength,PMD.ExcessivePublicCount')
public inherited sharing class CMN_UTIL_System
{
	private static Set<String> ignoredSelectFields;
	private static String apiEnabledSessionId;
	private static final String XM_ASSERT_VALUE = 'Value mismatch on {0}, for {1}. Expected {2}, got {3}. {4}';
	private static final String ERROR_NULL_POINTER_TYPE = 'NullPointerException - Input object is null';
	private static final Map<String, Map<String, Schema.SObjectField>> OBJECT_FIELD_BY_REFERENCE_MAP = new Map<String, Map<String, Schema.SObjectField> >();
	@TestVisible
	private static final Integer DEFAULT_NESTED_LEVELS = 1;
	private static final Integer DEFAULT_START_LEVEL = 0;
	@TestVisible
	private static final Integer MAX_NESTED_LEVELS = 5;
	private static final Map<String, Map<String, Schema.SObjectField>> OBJECT_FIELD_BY_NAME_MAP = new Map<String, Map<String, Schema.SObjectField> >();
	private static final Map<String, Schema.DescribeSObjectResult> OBJECT_DESCRIBE_MAP = new Map<String, DescribeSObjectResult>();
	/**
	 * @description Relationship suffix
	 */
	public static final String RELATIONSHIP_SUFFIX = '__r';
	/**
	 * @description Custom suffix
	 */
	public static final String CUSTOM_FIELD_SUFFIX = '__c';
	private static final String ID_FIELD_SUFFIX = 'Id';
	private static final String DATE_TYPE = 'Date';
	/**
	 * @description Share Object suffix for Custom object
	 */
	public static final String CUSTOM_OBJECT_SHARE_SUFFIX = '__Share';

	/**
	 * @description Class using for Exceptions
	 */
	public class AssertionException extends Exception
	{
	}

	/**
	 * @description Class using for Exceptions
	 */
	public virtual class JlException extends Exception
	{
	}

	/**
	 * @description Class using to throw Exceptions
	 */
	public static void justThrow()
	{
		throw new JlException();
	}

	/**
	 * @description Class using to throw Exceptions
	 *
	 * @param message as input
	 */
	public static void justThrow(String message)
	{
		throw new JlException(message);
	}

	/**
	 * @description Class using to throw Exceptions
	 *
	 * @param subject as input
	 * @param fieldName as input
	 * @param expected as input
	 * @param got as input
	 * @param message as input
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static void throwFieldValueAssertionException(String subject, String fieldName, Object expected, Object got, String message)
	{
		throw new AssertionException(String.format(XM_ASSERT_VALUE, new List<String>
		{
				subject, fieldName, String.valueOf(expected), String.valueOf(got), message
		}));
	}

	/**
	 * @description Will combine all the objects in all the maps list into a single object list
	 *
	 * @param idMap A map where the value is a list of objects and the key is an Id
	 *
	 * @return list of items
	 */
	public static List<SObject> extractListFromMap(Map<Id, List<SObject>> idMap)
	{
		List<SObject> objectList = new List<SObject>();

		if((idMap != null) && (idMap.values() != null) && !idMap.values().isEmpty())
		{
			for(List<SObject> valuesList : idMap.values())
			{
				objectList.addAll(valuesList);
			}
		}

		return objectList;
	}

	/**
	 * @description Will combine all the objects in all the maps list into a single object list
	 *
	 * @param stringMap A map where the value is a list of objects and the key is a string
	 *
	 * @return list of items
	 */
	public static List<SObject> extractListFromMap(Map<String, List<SObject>> stringMap)
	{
		List<SObject> objectList = new List<SObject>();

		if((stringMap != null) && (stringMap.values() != null) && !stringMap.values().isEmpty())
		{
			for(List<SObject> valuesList : stringMap.values())
			{
				objectList.addAll(valuesList);
			}
		}

		return objectList;
	}

	/**
	 * @description Will check the the match
	 *
	 * @param obj as input
	 * @param filter as input
	 *
	 * @return result
	 */
	public static Boolean matches(SObject obj, Map<String, Object> filter)
	{
		Boolean bMatches;

		for(String name : filter.keySet())
		{
			Object fieldVal = obj.get(name);
			Object filterVal = filter.get(name);

			// Special case: we assume a match when [Boolean] false == null.
			// Extend these special cases, as needed (e.g. String null = ''). Also, we may want to specify a "strict match" at some stage.
			bMatches = filterVal instanceof Boolean && ((Boolean)filterVal == false) ? fieldVal == false || fieldVal == null : fieldVal == filterVal;

			if(!bMatches)
			{
				return false;
			}
		}

		return true;
	}

	/**
	 * @description Will check and find the object
	 *
	 * @param objects as input
	 * @param fieldName as input
	 * @param value as input
	 *
	 * @return result
	 */
	public static List<SObject> findWhere(List<SObject> objects, String fieldName, Object value)
	{
		return findWhere(objects, new Map<String, Object>
		{
				fieldName => value
		});
	}

	/**
	 * @description Will check and find the object
	 *
	 * @param objects as input
	 * @param filter as input
	 *
	 * @return result
	 */
	public static List<SObject> findWhere(List<SObject> objects, Map<String, Object> filter)
	{
		List<SObject> result = new List<SObject>();

		for(SObject obj : objects)
		{
			if(matches(obj, filter))
			{
				result.add(obj);
			}
		}

		return result;
	}

	/**
	 * @description Will check and find the record in the object
	 *
	 * @param objects as input
	 * @param fieldName as input
	 * @param values as input
	 *
	 * @return result
	 */
	public static List<SObject> findWhereIn(List<SObject> objects, String fieldName, List<Object> values)
	{
		Set<Object> valueSet = new Set<Object>(values);
		Object fieldVal;
		List<SObject> result = new List<SObject>();

		for(SObject obj : objects)
		{
			fieldVal = obj.get(fieldName);

			if(valueSet.contains(fieldVal))
			{
				result.add(obj);
			}
		}

		return result;
	}

	/**
	 * @description Will check the object which not found
	 *
	 * @param objects as input
	 * @param fieldName as input
	 * @param value as input
	 *
	 * @return omitWhere
	 */
	public static List<SObject> omitWhere(List<SObject> objects, String fieldName, Object value)
	{
		return omitWhere(objects, new Map<String, Object>
		{
				fieldName => value
		});
	}

	/**
	 * @description This method is use to find the list of Sobject
	 *
	 * @param objects as input
	 * @param filter as input
	 *
	 * @return result
	 */
	public static List<SObject> omitWhere(List<SObject> objects, Map<String, Object> filter)
	{
		List<SObject> result;

		if(objects != null)
		{
			result = new List<SObject>();

			for(SObject obj : objects)
			{
				if(!matches(obj, filter))
				{
					result.add(obj);
				}
			}
		}

		return result;
	}

	/**
	 * @description This method is use to get the set Id of of Sobject
	 *
	 * @param masterList as input
	 * @param toBeOmitted as input
	 *
	 * @return result
	 */
	public static Set<Id> omit(Set<Id> masterList, Set<Id> toBeOmitted)
	{
		Set<Id> result;

		if(masterList != null)
		{
			result = masterList.clone();
			result.removeAll(toBeOmitted);
		}

		return result;
	}

	/**
	 * @description This method is use to concat
	 *
	 * @param set1 as input
	 * @param set2 as input
	 *
	 * @return result
	 */
	public static Set<Id> concat(Set<Id> set1, Set<Id> set2)
	{
		Set<Id> result = new Set<Id>(set1);

		result.addAll(set2);
		return result;
	}

	/**
	 * @description This method is use to check the items exclude from list
	 *
	 * @param sourceItems as input
	 * @param excludeItems as input
	 *
	 * @return resultList
	 */
	public static List<SObject> excludeItemsFromList(List<SObject> sourceItems, List<SObject> excludeItems)
	{
		List<SObject> resultList = new List<SObject>();

		if(sourceItems != null)
		{
			Set<SObject> objectSet = new Set<SObject>(sourceItems);
			objectSet.removeAll(excludeItems);
			resultList.addAll(objectSet);
		}

		return resultList;
	}

	/**
	 * @description This method is use to check the object field
	 *
	 * @param so as input
	 * @param fieldName as input
	 *
	 * @return exceptions
	 */
	public static Boolean hasSObjectField(SObject so, String fieldName)
	{
		try
		{
			so.get(fieldName);
			return true;
		}
		catch(Exception ex)
		{
			return false;
		}
	}

	/**
	 * @description This method is use to get the list of Object based on Ids
	 *
	 * @param objects as input
	 * @param fieldName as input
	 * @param removeNulls as input
	 *
	 * @return Ids
	 */
	public static Set<Id> extractListIds(List<SObject> objects, String fieldName, Boolean removeNulls)
	{
		Set<Id> idSet = new Set<Id>();

		Id itemId;

		if(objects != null)
		{
			for(SObject item : objects)
			{
				itemId = (Id)item.get(fieldName);
				if(!removeNulls || (itemId != null))
				{
					idSet.add(itemId);
				}
			}
		}

		return idSet;
	}

	/**
	 * @description This method is use to get the list of Object with field name
	 *
	 * @param objects as input
	 * @param fieldName as input
	 *
	 * @return extractListIds
	 */
	public static Set<Id> extractListIds(List<SObject> objects, String fieldName)
	{
		return extractListIds(objects, fieldName, false);
	}

	/**
	 * @description This method is use to get the list of Object
	 *
	 * @param objects as input
	 *
	 * @return extractListIds
	 */
	public static Set<Id> extractListIds(List<SObject> objects)
	{
		return extractListIds(objects, false);
	}

	/**
	 * @description This method is use to get the list of Object filter by Null value.
	 *
	 * @param objects as input
	 * @param removeNulls as input
	 *
	 * @return result
	 */
	public static Set<Id> extractListIds(List<SObject> objects, Boolean removeNulls)
	{
		Set<Id> result = new Set<Id>();

		if(objects != null)
		{
			for(SObject item : objects)
			{
				if(!removeNulls || item.Id != null)
				{
					result.add(item.Id);
				}
			}
		}

		return result;
	}

	/**
	 * @description Will extract all the values for a particular field from a list of objects
	 *
	 * @param objects The object from which to extract the field value
	 * @param fieldName The API name of the field to process, this can be a multipart field name
	 *
	 * @return A list of values (note this will include blank values)
	 *
	 * @see String.isBlank
	 * @see CMN_UTIL_System.getFieldValue
	 * @see CMN_UTIL_System_TEST.extractSetValues
	 */
	public static List<String> extractListValues(List<SObject> objects, String fieldName)
	{
		return extractListValues(objects, fieldName, false);
	}

	/**
	 * @description Will extract all the values for a particular field from a list of objects
	 *
	 * @param objects The object from which to extract the field value
	 * @param fieldName The API name of the field to process, this can be a multipart field name
	 * @param ignoreBlankValues If the item is blank then it will not be return
	 *
	 * @return A list of values
	 *
	 * @see String.isBlank
	 * @see CMN_UTIL_System.getFieldValue
	 * @see CMN_UTIL_System_TEST.extractListValues
	 */
	public static List<String> extractListValues(List<SObject> objects, String fieldName, Boolean ignoreBlankValues)
	{
		List<String> listResult = new List<String>();

		if(objects != null)
		{
			for(SObject item : objects)
			{
				String fieldValue = String.valueOf(getFieldValue(item, fieldName));

				if(!ignoreBlankValues || String.isNotBlank(fieldValue))
				{
					listResult.add(fieldValue);
				}
			}
		}

		return listResult;
	}

	/**
	 * @description Will extract a unique set of values for a particular field from a list of objects
	 *
	 * @param objects The object from which to extract the field value
	 * @param fieldName The API name of the field to process, this can be a multipart field name
	 *
	 * @return A list of values (note this will include blank values)
	 *
	 * @see String.isBlank
	 * @see CMN_UTIL_System.getFieldValue
	 * @see CMN_UTIL_System_TEST.extractSetValues
	 */
	public static Set<String> extractSetValues(List<SObject> objects, String fieldName)
	{
		return extractSetValues(objects, fieldName, false);
	}

	/**
	 * @description Will extract all the values for a particular field from a list of objects
	 *
	 * @param objects The object from which to extract the field value
	 * @param fieldName The API name of the field to process, this can be a multipart field name
	 * @param ignoreBlankValues If the item is blank then it will not be return
	 *
	 * @return A list of values
	 *
	 * @see String.isBlank
	 * @see CMN_UTIL_System.getFieldValue
	 * @see CMN_UTIL_System_TEST.extractSetValues
	 */
	public static Set<String> extractSetValues(List<SObject> objects, String fieldName, Boolean ignoreBlankValues)
	{
		Set<String> setResult = new Set<String>();

		if(objects != null)
		{
			for(SObject item : objects)
			{
				String fieldValue = String.valueOf(getFieldValue(item, fieldName));

				if(!ignoreBlankValues || String.isNotBlank(fieldValue))
				{
					setResult.add(fieldValue);
				}
			}
		}

		return setResult;
	}

	/**
	 * @description This method is use to check trim the set
	 *
	 * @param idList as input
	 *
	 * @return result
	 */
	public static Set<Id> trimSet(Set<Id> idList)
	{
		Set<Id> result = new Set<Id>();

		for(Id item : idList)
		{
			if(String.isNotBlank(item))
			{
				result.add(item);
			}
		}

		return result;
	}

	/**
	 * @description This method is use to check trim the set
	 *
	 * @param stringSet as input
	 *
	 * @return result
	 */
	public static Set<String> trimSet(Set<String> stringSet)
	{
		Set<String> result = new Set<String>();

		for(String item : stringSet)
		{
			if(String.isNotBlank(item))
			{
				result.add(item);
			}
		}

		return result;
	}

	/**
	 * @description Method will remove any strings containing only whitespace or null
	 *
	 * @param strings A list of strings
	 *
	 * @return A new list containing non-blank strings
	 */
	public static List<String> trimList(List<String> strings)
	{
		List<String> result = new List<String>();

		for(String item : strings)
		{
			if(String.isNotBlank(item))
			{
				result.add(item);
			}
		}

		return result;
	}

	/**
	 * @description This method is use to get the list of string converted from list
	 *
	 * @param delimitedString as input
	 * @param delimiter as input
	 *
	 * @return stringsList
	 */
	public static List<String> convertStringToList(String delimitedString, String delimiter)
	{
		List<String> stringsList = new List<String>();

		if(String.isNotBlank(delimitedString))
		{
			stringsList = CMN_UTIL_String.splitByWholeSeparator(delimitedString, delimiter);
		}

		return stringsList;
	}

	/**
	 * @description This method is use to get the list of string converted from set
	 *
	 * @param delimitedString as input
	 * @param delimiter as input
	 *
	 * @return stringsSet
	 */
	public static Set<String> convertStringToSet(String delimitedString, String delimiter)
	{
		Set<String> stringsSet = new Set<String>();

		stringsSet.addAll(convertStringToList(delimitedString, delimiter));

		return stringsSet;
	}

	/**
	 * @description Will iterate through a list of SObjects and produce map of <keyFieldName, Set<objectFieldName>
	 *
	 * @param objectList List of SObjects
	 * @param keyFieldName The field to extract from the SObjects provided and forms the key of the map
	 * @param valueSetFieldName The field to extract from the SObjects and combined in the value set
	 *
	 * @return A populated map
	 */
	public static Map<Id, Set<Id>> convertListToMapSet(List<SObject> objectList, String keyFieldName, String valueSetFieldName)
	{
		Map<Id, Set<Id>> objectMap = new Map<Id, Set<Id>>();

		if(objectList != null)
		{
			for(SObject listItem : objectList)
			{
				Id keyValue = (Id)listItem.get(keyFieldName);

				Set<Id> valueSet = objectMap.get(keyValue);

				if(valueSet == null)
				{
					valueSet = new Set<Id>();
					objectMap.put(keyValue, valueSet);
				}

				valueSet.add((Id)listItem.get(valueSetFieldName));
			}
		}

		return objectMap;
	}

	/**
	 * @description Will convert object list into a map <keyFieldName List<SObject>
	 *
	 * @param objectList List of items to map
	 * @param keyFieldName The apiName of the object field to use as a key, this must be an Id field
	 *
	 * @return The map based on the key field
	 */
	public static Map<Id, List<SObject>> convertListToMap(List<SObject> objectList, String keyFieldName)
	{
		Map<Id, List<SObject>> objectMap = new Map<Id, List<SObject> >();

		if(objectList != null)
		{
			for(SObject listItem : objectList)
			{
				Id key = (Id)listItem.get(keyFieldName);

				List<SObject> listInMap = objectMap.get(key);

				if(listInMap == null)
				{
					listInMap = new List<SObject>();
					objectMap.put(key, listInMap);
				}

				listInMap.add(listItem);
			}
		}

		return objectMap;
	}

	/**
	 * @description Will convert object list into a map of <keyFieldName SObject>
	 *
	 * @param objectList List of items to map
	 * @param keyFieldName The apiName of the object field to use as a key, this must be an Id field
	 *
	 * @return The map based on the key field
	 */
	public static Map<Id, SObject> convertListToSingleMap(List<SObject> objectList, String keyFieldName)
	{
		Map<Id, SObject> objectMap = new Map<Id, SObject>();

		if(objectList != null)
		{
			for(SObject listItem : objectList)
			{
				objectMap.put((Id)listItem.get(keyFieldName), listItem);
			}
		}

		return objectMap;
	}

	/**
	 * @description This method is use to get the List map converted from string map
	 *
	 * @param objectList as input
	 * @param objectFieldName as input
	 *
	 * @return objectMap
	 */
	public static Map<String, List<SObject> > convertListToStringMap(List<SObject> objectList, String objectFieldName)
	{
		Map<String, List<SObject> > objectMap = new Map<String, List<SObject> >();

		if(objectList != null)
		{
			for(SObject item : objectList)
			{
				String idFromField = String.valueOf(item.get(objectFieldName));

				List<SObject> listInMap = objectMap.get(idFromField);

				if(listInMap == null)
				{
					listInMap = new List<SObject>();
					objectMap.put(idFromField, listInMap);
				}

				listInMap.add(item);
			}
		}

		return objectMap;
	}

	/**
	 * @description This method is use to generate a String map of objects based on the values in the field provided
	 *
	 * @param objectList The list of items to process
	 * @param keyFieldName The apiName of the object field to use as a key, this can be a multipart field name
	 *
	 * @return The map based on the key field
	 */
	public static Map<String, SObject> convertListToSingleStringMap(List<SObject> objectList, String keyFieldName)
	{
		return convertListToSingleStringMap(objectList, keyFieldName, false);
	}

	/**
	 * @description This method is use to generate a String map of objects based on the values in the field provided
	 *
	 * @param objectList The list of items to process
	 * @param keyFieldName The apiName of the object field to use as a key, this can be a multipart field name
	 * @param setKeyToUpperCase If true, the key value for the map will be set to upper case
	 *
	 * @return The map based on the key field
	 */
	public static Map<String, SObject> convertListToSingleStringMap(List<SObject> objectList, String keyFieldName, Boolean setKeyToUpperCase)
	{
		Map<String, SObject> objectMap = new Map<String, SObject>();

		if(objectList != null)
		{
			for(SObject listItem : objectList)
			{
				String idFromField = String.valueOf(getFieldValue(listItem, keyFieldName));
				objectMap.put(setKeyToUpperCase ? CMN_UTIL_String.upperCase(idFromField) : idFromField, listItem);
			}
		}

		return objectMap;
	}

	/**
	 * @description This method is use to create the map of uppercase key and sobject record from list of sObject
	 * key is identified based on objectFieldName
	 *
	 * @param objectList as input
	 * @param objectFieldName as input
	 *
	 * @return objectMap
	 */
	public static Map<String, SObject> convertListToSingleUpperStringMap(List<SObject> objectList, String objectFieldName)
	{
		Map<String, SObject> objectMap = new Map<String, SObject>();

		if(objectList != null && !objectList.isEmpty())
		{
			for(SObject item : objectList)
			{
				String idFromField = String.valueOf(item.get(objectFieldName));
				objectMap.put(CMN_UTIL_String.upperCase(idFromField), item);
			}
		}

		return objectMap;
	}

	/**
	 * @description This method is use to get the component key
	 *
	 * @param obj as input
	 * @param objectFieldNames as input
	 *
	 * @return result
	 */
	public static String getCompoundKey(SObject obj, List<String> objectFieldNames)
	{
		String result = CMN_UTIL_String.EMPTY;

		for(String field : objectFieldNames)
		{
			result += String.valueOf(obj.get(field));
		}

		return result;
	}

	/**
	 * @description This method is use to get the single Map of SObject converted from single map
	 *
	 * @param objectList as input
	 * @param objectFieldNames as input
	 *
	 * @return objectMap
	 */
	public static Map<String, SObject> convertListToSingleMap(List<SObject> objectList, List<String> objectFieldNames)
	{
		Map<String, SObject> objectMap = new Map<String, SObject>();

		if(objectList != null)
		{
			for(SObject item : objectList)
			{
				objectMap.put(getCompoundKey(item, objectFieldNames), item);
			}
		}

		return objectMap;
	}

	/**
	 * @description This method is use to get the List of Ids
	 *
	 * @param aSet as input
	 *
	 * @return set
	 */
	public static List<Id> setToList(Set<Id> aSet)
	{
		return aSet != null ? new List<Id>(aSet) : null;
	}

	/**
	 * @description This method is use to get the List of string
	 *
	 * @param aSet as input
	 *
	 * @return returnValue
	 */
	public static List<String> setToList(Set<String> aSet)
	{
		List<String> returnValue = null;

		if(aSet != null)
		{
			returnValue = new List<String>(aSet);
		}
		return returnValue;
	}

	/**
	 * @description Will convert a set of type Id to a set of type String
	 *
	 * @param ids Set of items to convert
	 *
	 * @return Converted set
	 */
	public static Set<String> convertIdSetToStringSet(Set<Id> ids)
	{
		Set<String> stringSet = new Set<String>();

		for(Id itemId : ids)
		{
			if(String.isNotBlank(itemId))
			{
				stringSet.add(String.valueOf(itemId));
			}
		}

		return stringSet;
	}

	/**
	 * @description Will return the object type for an a given Id
	 *
	 * @param objectId The Id of the SObject
	 *
	 * @return A type or null
	 */
	public static SObjectType getSObjectTypeById(Id objectId)
	{
		Id validatedId = CMN_UTIL_String.validateId(objectId);
		return validatedId == null ? null : validatedId.getSobjectType();
	}

	/**
	 * @description Returns the API name of an object based on it's ID
	 *
	 * @param objectId An Id of an SObject
	 *
	 * @return The API name or null
	 */
	public static String getObjectNameFromId(Id objectId)
	{
		SObjectType objectType = getSObjectTypeById(objectId);
		return objectType == null ? null : objectType.getDescribe().getLocalName();
	}

	/**
	 * @description This method is use to get the the object type based on it's name
	 *
	 * @param objectApiName The API name of the object
	 *
	 * @return An SObjectType or null
	 */
	public static SObjectType getSObjectTypeByName(String objectApiName)
	{
		return CMN_UTIL_SObjectDescribe.getGlobalDescribe().get(objectApiName);
	}

	/**
	 * @description This method is use to get a list of picklist entries
	 *
	 * @param objectName The object api name for which the entries should be retrieved
	 * @param fieldName The API name of a pick field
	 *
	 * @return List of found items
	 */
	public static List<PicklistEntry> getPicklistEntries(String objectName, String fieldName)
	{
		SObjectType token = getSObjectTypeByName(objectName);

		return getPicklistEntries(token, fieldName);
	}

	/**
	 * @description This method is use to get a list of picklist entries
	 *
	 * @param objectType The object for which the entries should be retrieved
	 * @param fieldName The API name of a pick field
	 *
	 * @return List of found items
	 */
	public static List<PicklistEntry> getPicklistEntries(SObjectType objectType, String fieldName)
	{
		DescribeSObjectResult describe = objectType.getDescribe();
		Map<String, SObjectField> fieldMap = describe.fields.getMap();
		return fieldMap.get(fieldName).getDescribe().getPicklistValues();
	}

	/**
	 * @description This will retrieve a map of Picklist label and apiName for a given object field
	 *
	 * @param objectType The object for which picklist field should be retrieved
	 * @param fieldName The API name of the object's field
	 *
	 * @return A map of picklist values
	 */
	public static Map<String, String> getPicklistEntriesMap(SObjectType objectType, String fieldName)
	{
		return getPicklistEntriesMap(objectType, fieldName, true);
	}

	/**
	 * @description This will retrieve a map of found picklist entries, the key of the map is by the last parameter
	 *
	 * @param objectType The object for which picklist field should be retrieved
	 * @param fieldName The API name of the object's field
	 * @param useLabelAsKey If true the key will be the picklist label, else it will be the api name (i.e value)
	 *
	 * @return A map of the found items
	 */
	public static Map<String, String> getPicklistEntriesMap(SObjectType objectType, String fieldName, Boolean useLabelAsKey)
	{
		List<PicklistEntry> foundEntries = getPicklistEntries(objectType, fieldName);

		Map<String, String> entriesMap = new Map<String, String>();

		for(PicklistEntry foundEntry : foundEntries)
		{
			String mapKey = useLabelAsKey ? foundEntry.getLabel() : foundEntry.getValue();
			String mapValue = useLabelAsKey ? foundEntry.getValue() : foundEntry.getLabel();

			entriesMap.put(mapKey, mapValue);
		}

		return entriesMap;
	}

	/**
	 * @description This method is use to get the value of a picklist item found by label
	 *
	 * @param objectType Object Type
	 * @param fieldName API name of the  of the Field
	 * @param pickLabel The label to match
	 *
	 * @return The value found by matching the label
	 */
	public static String getPicklistValue(SObjectType objectType, String fieldName, String pickLabel)
	{
		List<PicklistEntry> foundEntries = getPicklistEntries(objectType, fieldName);

		String foundValue;

		for(PicklistEntry foundEntry : foundEntries)
		{
			if(pickLabel.equals(foundEntry.label))
			{
				foundValue = foundEntry.value;
				break;
			}
		}

		return foundValue;
	}

	/**
	 * @description Returns a list of values for the relevant field for the passed in SObject name
	 *
	 * @param objectName API name of the Object
	 * @param fieldName API name of the Field
	 *
	 * @return list of pick values for a particular pick field
	 */
	public static List<String> getPicklistValues(String objectName, String fieldName)
	{
		List<PicklistEntry> foundEntries = getPicklistEntries(getSObjectTypeByName(objectName), fieldName);

		List<String> pickValues = new List<String>();

		for(PicklistEntry foundEntry : foundEntries)
		{
			pickValues.add(foundEntry.value);
		}

		return pickValues;
	}

	/**
	 * @description method is use return the date from dateTime
	 *
	 * @param inDate as input
	 *
	 * @return result
	 */
	public static Date dateTimeToDate(Datetime inDate)
	{
		return Date.newInstance(inDate.year(), inDate.month(), inDate.day());
	}

	/**
	 * @description Using this method to test helper methods
	 *
	 * @param items as input
	 * @param message as input
	 */
	public static void assertEmptyList(List<SObject> items, String message)
	{
		assertSizeEquals(items, 0, message);
	}

	/**
	 * @description Using this method to test helper methods
	 *
	 * @param items as input
	 * @param size as input
	 * @param message as input
	 */
	public static void assertSizeEquals(List<SObject> items, Integer size, String message)
	{
		if(items.size() != size)
		{
			String msg = String.format('Assertion error: List is size {0}, and should be {1}. {2}', new List<String>
			{
					String.valueOf(items.size()),
					String.valueOf(size), message != null ? ', for: ' + message : ''
			});
			throw new AssertionException(msg);
		}
	}

	/**
	 * @description Using this method to test helper methods
	 *
	 * @param set1 as input
	 * @param set2 as input
	 * @param message as input
	 */
	public static void assertIDSetEquals(Set<Id> set1, Set<Id> set2, String message)
	{
		if(set1.size() != set2.size())
		{
			String msg = String.format('Assertion error: Lists of mismatching size {0} and {1}. {2}', new List<String>
			{
					String.valueOf(set1.size()),
					String.valueOf(set2.size()), message != null ? ', for: ' + message : ''
			});
			throw new AssertionException(msg);
		}

		for(Id s : set1)
		{
			if(!set2.contains(s))
			{
				String msg = String.format('Assertion error: List content mismatch - Element {0} not found. {1}', new List<String>
				{
						s, message != null ? ', for: ' + message : ''
				});
				throw new AssertionException(msg);
			}
		}
	}

	/**
	 * @description Using this method to test helper methods
	 *
	 * @param dateSet1 as input
	 * @param dateSet2 as input
	 * @param message as input
	 */
	public static void assertDateSetEquals(Set<Date> dateSet1, Set<Date> dateSet2, String message)
	{
		if(dateSet1.size() != dateSet2.size())
		{
			String msg = String.format('Assertion error: Lists of mismatching size {0} and {1}. {2}', new List<String>
			{
					String.valueOf(dateSet1.size()),
					String.valueOf(dateSet2.size()), message != null ? ', for: ' + message : ''
			});
			throw new AssertionException(msg);
		}

		for(Date s : dateSet1)
		{
			if(!dateSet2.contains(s))
			{
				String msg = String.format('Assertion error: List content mismatch - Element {0} not found. {1}', new List<String>
				{
						s.format(),
						message != null ? ', for: ' + message : ''
				});
				throw new AssertionException(msg);
			}
		}
	}

	/**
	 * @description Using this method to test helper methods
	 *
	 * @param obj as input
	 * @param fieldNames as input
	 * @param values as input
	 * @param message as input
	 */
	public static void assertObjectValues(SObject obj, List<String> fieldNames, List<Object> values, String message)
	{
		String objName = obj.getSObjectType().getDescribe().getLocalName();

		for(Integer i = 0; i < Math.min(fieldNames.size(), values.size()); i++)
		{
			if(obj.get(fieldNames[i]) != values[i])
			{
				throwFieldValueAssertionException(objName, fieldNames[i], values[i], obj.get(fieldNames[i]), message);
			}
		}
	}

	/**
	 * @description Remove all matching items from a list
	 *
	 * @param sourceItems The list containing the original source items
	 * @param deleteItems The set of items we want to remove
	 *
	 * @return A list containing the remaining items after removing matching deleteItems
	 */
	public static List<String> removeItems(List<String> sourceItems, Set<String> deleteItems)
	{
		List<String> result = new List<String>(sourceItems);

		if(sourceItems.isEmpty() || deleteItems.isEmpty())
		{
			return result;
		}

		//Loop backwards through the list so that the index remains valid
		for(Integer i = result.size() - 1; i >= 0; i--)
		{
			if(deleteItems.contains(result[i]))
			{
				result.remove(i);
			}
		}

		return result;
	}

	/**
	 * @description Get the map of SObjects Field Names
	 *
	 * @param objectName The name of the object to retrieve fields for
	 *
	 * @return A Map of SObject Fields, with the key being the FieldName
	 */
	public static Map<String, SObjectField> getObjectFieldMap(String objectName)
	{
		Map<String, SObjectField> fieldMap = OBJECT_FIELD_BY_NAME_MAP.get(objectName);

		if(fieldMap == null)
		{
			DescribeSObjectResult describeSObjectResult = getObjectResult(objectName);
			fieldMap = describeSObjectResult != null ? describeSObjectResult.fields.getMap() : new Map<String, SObjectField>();
			OBJECT_FIELD_BY_NAME_MAP.put(objectName, fieldMap);
		}

		return fieldMap;
	}

	/**
	 * @description Get the map of SObjects Fields by Reference
	 *
	 * @param objectName The name of the object to retrieve fields map for
	 *
	 * @return A Map of SObject Fields, with the key being the RelationShipName of the field, fields without reference will be excluded
	 */
	public static Map<String, SObjectField> getObjectFieldReferenceMap(String objectName)
	{
		Map<String, SObjectField> referenceFieldMap = OBJECT_FIELD_BY_REFERENCE_MAP.get(objectName);

		if(referenceFieldMap == null)
		{
			getObjectFieldMap(objectName);

			DescribeSObjectResult describe = getObjectResult(objectName);

			if(describe != null)
			{
				referenceFieldMap = new Map<String, SObjectField>();

				for(SObjectField objectField : describe.fields.getMap().values())
				{
					DescribeFieldResult fieldDescribe = objectField.getDescribe();

					if(fieldDescribe.getType() == DisplayType.REFERENCE)
					{
						referenceFieldMap.put(fieldDescribe.getRelationshipName(), objectField);
					}
				}
			}

			OBJECT_FIELD_BY_REFERENCE_MAP.put(objectName, referenceFieldMap);
		}

		return referenceFieldMap;
	}

	/**
	 * @description Will return an SObject describe based on the object Api Name provided
	 *
	 * @param objectApiName The Api name of the object whose describe should be retrieved
	 *
	 * @return The describe for the object
	 *
	 * @throws InvalidParameterValueException If the objectApi name is invalid
	 */
	@TestVisible
	private static DescribeSObjectResult getObjectResult(String objectApiName)
	{
		DescribeSObjectResult describeResult = OBJECT_DESCRIBE_MAP.get(objectApiName);

		if(describeResult == null)
		{
			List<DescribeSObjectResult> describeSObjectResults = Schema.describeSObjects(new List<String> {objectApiName}, SObjectDescribeOptions.FULL);

			if(!describeSObjectResults.isEmpty())
			{
				describeResult = describeSObjectResults.iterator().next();
				OBJECT_DESCRIBE_MAP.put(objectApiName, describeResult);
			}
		}

		return describeResult;
	}

	/**
	 * @description Method to check the Object
	 *
	 * @param objectName as input
	 *
	 * @return result
	 */
	public static Boolean objectQueryable(String objectName)
	{
		Schema.DescribeSObjectResult describeSObjectResult = getObjectResult(objectName);

		//If the name given doesn't exist, then return empty results
		return describeSObjectResult == null ? false : describeSObjectResult.isQueryable();
	}

	/**
	 * @description This method will walk the object tree and return all fields for all objects related by look, it will only walk one level in the tree
	 *
	 * @param objectName The name of the starting object
	 *
	 * @return A list of fields using multipart dot notation; such as for given Contact, you would get Account.Name
	 */
	public static Set<String> getNestableFieldNames(String objectName)
	{
		return getNestableFieldNames(objectName, DEFAULT_NESTED_LEVELS);
	}

	/**
	 * @description This method will walk the object tree and return all fields for all objects related by look
	 *
	 * @param objectName The name of the starting object
	 * @param levels e number of Levels up the tree to go, maximum allowed for number is 5
	 *
	 * @return A list of fields using multipart dot notation; such as for given Contact, you would get Account.Name
	 */
	public static Set<String> getNestableFieldNames(String objectName, Integer levels)
	{
		return getNestableFieldNames(CMN_UTIL_String.EMPTY, objectName, Math.min(MAX_NESTED_LEVELS, levels), DEFAULT_START_LEVEL);
	}

	/**
	 * @description his method will walk the object tree and return all fields for all objects related by look
	 *
	 * @param objectPrefix The prefix that should applied to field name for related object
	 * @param objectName The name of the starting object
	 * @param levels The number of Levels up the tree to go
	 * @param currentLevel The level we're currently att
	 *
	 * @return A list of fields using multipart dot notation; such as for given Contact, you would get Account.Name
	 */
	@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
	private static Set<String> getNestableFieldNames(String objectPrefix, String objectName, Integer levels, Integer currentLevel)
	{
		Set<String> currentLevelFieldNames = new Set<String>();

		//Only process to a particular level
		if(currentLevel > levels)
		{
			return currentLevelFieldNames;
		}

		currentLevel++;

		Map<String, SObjectField> fieldMap = getObjectFieldMap(objectName);

		if(fieldMap != null)
		{
			for(SObjectField objectField : fieldMap.values())
			{
				DescribeFieldResult fieldDescribe = objectField.getDescribe();

				if(!getIgnoredSelectFields().contains(fieldDescribe.getLocalName()))
				{
					String fieldName = fieldDescribe.getLocalName();

					if(String.isNotBlank(objectPrefix))
					{
						fieldName = objectPrefix + CMN_UTIL_String.DOT + fieldName;
					}

					currentLevelFieldNames.add(fieldName);

					//Make sure we add related object lookup fields into query
					//Ignore any references to objects that could be of multiple types, like owner (which could be a queue or user)
					if(fieldDescribe.getType() == DisplayType.REFERENCE && !fieldDescribe.namePointing)
					{
						for(SObjectType objType : fieldDescribe.getReferenceTo())
						{
							String relationshipPrefixName = fieldDescribe.getRelationshipName();

							//Some ID fields cannot be used to follow as a join in a query
							if(String.isNotBlank(relationshipPrefixName))
							{

								if(currentLevel > DEFAULT_NESTED_LEVELS)
								{
									relationshipPrefixName = objectPrefix + CMN_UTIL_String.DOT + relationshipPrefixName;
								}

								String referenceObjectName = objType.getDescribe().getLocalName();

								currentLevelFieldNames.addAll(getNestableFieldNames(relationshipPrefixName, referenceObjectName, levels, currentLevel));
							}
						}
					}
				}
			}
		}

		return currentLevelFieldNames;
	}

	/**
	 * @description This method is use to get the all field name of Object based on record type
	 *
	 * @param objectName as input
	 * @param includeRecordType as input
	 *
	 * @return fieldNames
	 */
	@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
	public static Set<String> getAllFieldNames(String objectName, Boolean includeRecordType)
	{
		Set<String> fieldNames = new Set<String>();

		Map<String, SObjectField> fieldMap = getObjectFieldMap(objectName);

		if(fieldMap != null)
		{
			for(SObjectField field : fieldMap.values())
			{
				DescribeFieldResult describe = field.getDescribe();

				if(!getIgnoredSelectFields().contains(describe.getLocalName()))
				{
					fieldNames.add(describe.getLocalName());

					//If we have Record Types then make sure we inject fields for recordtype name
					if(!describe.namePointing && !describe.getReferenceTo().isEmpty() && includeRecordType)
					{
						SObjectType objType = describe.getReferenceTo()[0];
						String relatedObjName = objType.getDescribe().getLocalName();

						if(CMN_DAL_RecordType.OBJECT_NAME.equalsIgnoreCase(relatedObjName))
						{
							Set<String> relatedFieldNames = getAllFieldNames(relatedObjName, false);

							for(String relatedFieldName : relatedFieldNames)
							{
								fieldNames.add(describe.getRelationshipName() + CMN_UTIL_String.DOT + relatedFieldName);
							}
						}
					}
				}
			}
		}

		return fieldNames;
	}

	/**
	 * @description This method is use to get the all field name of Object based on type
	 *
	 * @param objectType as input
	 *
	 * @return Set<String>
	 */
	public static Set<String> getAllFieldNames(SObjectType objectType)
	{
		return getAllFieldNames(objectType.getDescribe().getLocalName());
	}

	/**
	 * @description This method is use to get the all field name of Object based on type
	 *
	 * @param objectName as input
	 *
	 * @return Set<String>
	 */
	public static Set<String> getAllFieldNames(String objectName)
	{
		return getAllFieldNames(objectName, true);
	}

	/**
	 * @description Will split a list up into smaller lists based on the split size
	 *
	 * @param sObjects A list of objects
	 * @param splitSize The size at which the objects in the input list should be split
	 *
	 * @return A list of split object list, each list will not be larger then the split size
	 */
	public static List<List<SObject>> splitSObjects(List<SObject> sObjects, Integer splitSize)
	{
		List<List<SObject>> objectSplits = new List<List<SObject>>();

		if(sObjects.size() > splitSize)
		{
			List<SObject> splitObjects;

			for(Integer i = 0; i < Math.ceil(Decimal.valueOf(sObjects.size()).divide(Math.max(splitSize, 1), 1)); i++)
			{
				splitObjects = new List<SObject>();

				for(Integer j = (i * splitSize); (j < (i * splitSize) + splitSize) && j < sObjects.size(); j++)
				{
					splitObjects.add(sObjects.get(j));
				}

				objectSplits.add(splitObjects);
			}
		}
		else
		{
			objectSplits.add(sObjects);
		}

		return objectSplits;
	}

	/**
	 * @description Will split a list up into smaller lists based on the split size
	 *
	 * @param objects A list of objects
	 * @param splitSize The size at which the objects in the input list should be split
	 *
	 * @return A list of split object list, each list will not be larger then the split size
	 */
	public static List<List<Object>> splitObjects(List<Object> objects, Integer splitSize)
	{
		List<List<Object>> objectSplits = new List<List<Object>>();

		if(objects.size() > splitSize)
		{
			List<Object> splitObjects;

			for(Integer i = 0; i < Math.ceil(Decimal.valueOf(objects.size()).divide(Math.max(splitSize, 1), 1)); i++)
			{
				splitObjects = new List<Object>();

				for(Integer j = (i * splitSize); (j < (i * splitSize) + splitSize) && j < objects.size(); j++)
				{
					splitObjects.add(objects.get(j));
				}

				objectSplits.add(splitObjects);
			}
		}
		else
		{
			objectSplits.add(objects);
		}

		return objectSplits;
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
		Integer index = getRandomIndex(objects);
		return index == null ? null : objects.get(index);

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
	 * @description Will check to see if the given field api name exists for the given object
	 *
	 * @param objectName The object API name on which the field must exist for example Opportunity
	 * @param fieldName The Field API name for example "Account.RecordType.DeveloperName"
	 *
	 * @return indicates that both the object and related field exist
	 */
	public static Boolean isValidObjectFieldName(String objectName, String fieldName)
	{
		if(String.isBlank(fieldName))
		{
			return false;
		}

		SObjectType objectType = getSObjectTypeByName(objectName);

		if(objectType == null)
		{
			return false;
		}

		Boolean isValid;

		List<String> fieldNameParts = convertStringToList(fieldName, CMN_UTIL_String.DOT);

		Boolean isMultipartReference = fieldNameParts.size() > 1;

		String objectNameToUse = objectName;

		for(Integer i = 0; i < fieldNameParts.size(); i++)
		{
			String fieldPart = fieldNameParts[i];

			Map<String, Schema.SObjectField> fieldMap = getObjectFieldMap(objectNameToUse);

			String fieldNameToUse = fieldPart;

			//Change the name for field except for the last field in the list
			if(isMultipartReference && i < fieldNameParts.size() - 1 && String.isNotBlank(fieldPart))
			{
				if(fieldPart.endsWith(RELATIONSHIP_SUFFIX))
				{
					fieldNameToUse = fieldNameToUse.replace(RELATIONSHIP_SUFFIX, CUSTOM_FIELD_SUFFIX);
				}
				else
				{
					fieldNameToUse = fieldNameToUse + ID_FIELD_SUFFIX;
				}
			}

			SObjectField objectField = fieldMap.get(fieldNameToUse.toLowerCase());

			isValid = String.isBlank(fieldNameToUse) || fieldMap == null ? false : objectField != null;

			if(!isValid)
			{
				break;
			}

			DescribeFieldResult describe = objectField.getDescribe();

			objectNameToUse = !describe.namePointing && !describe.getReferenceTo().isEmpty() ? describe.getReferenceTo()[0].getDescribe().getLocalName() : fieldPart;
		}

		return isValid;
	}

	/**
	 * @description Will retrieve the value for an SObject generically
	 *
	 * @param anObject The SObject data, can include references to related object
	 * @param fieldName A single field name or field names using DOT notation; such as Case.Contact.Name, we assume last value is a field name
	 *
	 * @return The value of the field
	 */
	public static Object getFieldValue(SObject anObject, String fieldName)
	{
		Object fieldValue = null;

		if(anObject != null)
		{
			List<String> fieldNameParts = CMN_UTIL_System.convertStringToList(fieldName, CMN_UTIL_String.DOT);

			Boolean isMultipartReference = fieldNameParts.size() > 1;

			SObject objectToUse = anObject;

			for(Integer i = 0; i < fieldNameParts.size(); i++)
			{
				if(objectToUse != null) //WHILST the field name may be field, the object references is null...
				{
					String fieldPart = fieldNameParts[i];

					//If we are not at the end of the field parts, then we are retrieving an SObject
					if(isMultipartReference && i < fieldNameParts.size() - 1)
					{
						objectToUse = objectToUse.getSObject(fieldPart);
					}
					//If we get here then we are retrieving a field value
					else
					{
						fieldValue = objectToUse.get(fieldPart);
					}
				}
			}
		}

		return fieldValue;
	}

	/**
	 * @description Class that represents the SObject and SObject field from walking an SObject returned from a query
	 * with a text field name (path); for example (from case) Contact.Account.Name;
	 * This should return with SObject = Account SObjectField = Name;
	 * The passed in object will be Case in this instance
	 */
	public class ObjectFieldInformation
	{
		/**
		 * @description SObject name
		 */
		public SObject objectReference;
		/**
		 * @description SObjectField name
		 */
		public SObjectField objectField;
	}

	/**
	 * @description Retrieves and SObject and SObjectField from an SObject based on a field name
	 *
	 * @param anObject Root Object; for example Case
	 * @param fieldName Multipart field name; for example Contact.Account.Name
	 *
	 * @return Object contain an SObject and SObjectField reference in example above that would be Account and Name
	 */
	public static ObjectFieldInformation getObjectAndFieldInformation(SObject anObject, String fieldName)
	{
		ObjectFieldInformation result = new ObjectFieldInformation();

		List<String> fieldNameParts = CMN_UTIL_System.convertStringToList(fieldName, CMN_UTIL_String.DOT);

		Boolean isMultipartReference = fieldNameParts.size() > 1;

		result.objectReference = anObject;
		String fieldPart;

		for(Integer i = 0; i < fieldNameParts.size(); i++)
		{
			if(result.objectReference != null) //WHILST the field name may be field, the object references is null...
			{
				fieldPart = fieldNameParts[i];

				//If we are not at the end of the field parts, then we are retrieving an SObject
				if(isMultipartReference && i < fieldNameParts.size() - 1)
				{
					result.objectReference = result.objectReference.getSObject(fieldPart);
				}
			}
		}

		if(result.objectReference != null)
		{
			result.objectField = result.objectReference.getSObjectType().getDescribe().fields.getMap().get(fieldPart);
		}

		return result;
	}

	/**
	 * @description converts id 15 to 1d 18
	 *
	 * @param the15charID as input
	 *
	 * @return converted to 18 id
	 */
	public static String to18(String the15charID)
	{
		final String base = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456';
		the15charID = CMN_UTIL_String.trim(the15charID);

		if(CMN_UTIL_String.length(the15charID) != 15)
		{
			return the15charID;
		}

		String result = '';
		List<String> chars = null;

		for(Integer i = 0; i < 3; i++)
		{
			chars = CMN_UTIL_String.toCharArray(CMN_UTIL_String.reverse(the15charID.substring(i * 5, i * 5 + 5)));
			String binary = '';
			for(String ch : chars)
			{
				binary += CMN_UTIL_Character.isUpperCase(ch) ? '1' : '0';
			}
			result += CMN_UTIL_String.charAt(base, CMN_UTIL_Number.parseInt(binary, 2));
		}

		return the15charID + result;
	}

	/**
	 * @description Method to get the type of a single element
	 *
	 * @param objects The list of objects to evaluate
	 *
	 * @return returns Type of given list single element
	 */
	public static Type getListItemType(List<Object> objects)
	{
		return getType(objects, 'List<', '>');
	}

	/**
	 * @description Running type of object passed in parameter.
	 *
	 * @param o The object to evaluate
	 *
	 * @return This method returns null if type is not accessible - when class is private
	 * or when it's part of anonymous script. In that case, getRunningTypeName() should be used instead.
	 */
	public static Type getType(Object o)
	{
		return getType(o, 'Invalid conversion from runtime type ', ' to Date');
	}

	/**
	 * @description Overloaded method to get the type from the Type name
	 *
	 * @param anObject The object to evaluate
	 * @param open The opening tag as response from the getType
	 * @param close The closing tag as response from the getType
	 *
	 * @return Running type of object passed in parameter.
	 */
	public static Type getType(Object anObject, String open, String close)
	{
		return Type.forName(getTypeName(anObject, open, close));
	}

	/**
	 * @description This method serves to retrieve the type name of the running object node
	 *
	 * @param o The object to evaluate
	 *
	 * @return Name of running type of object passed in parameter.
	 */
	public static String getTypeName(Object o)
	{
		return getTypeName(o, 'Invalid conversion from runtime type ', ' to Date');
	}

	/**
	 * @description Method to determine the running type of any node, this method uses assignment to the date type
	 * to attempt to convert the input object and subsequently extracts the type from potential error responses
	 * when performing the type conversion.
	 *
	 * @param anObject The object used in the type conversion
	 * @param open the opening tag of the type conversion
	 * @param close the closing tag of the type conversion
	 *
	 * @return A string containing the name of the class
	 */
	@SuppressWarnings('ApexUnusedDeclaration, PMD.UnusedLocalVariable')
	public static String getTypeName(Object anObject, String open, String close)
	{
		if(anObject == null)
		{
			CMN_UTIL_Logger.error(ERROR_NULL_POINTER_TYPE, 'CMN_UTIL_System/getTypeName');
			throw new NullPointerException();
		}

		try
		{
			//This line is expected to throw an error if the type isn't a date and then will use the error to find actual type
			Date aDate = (Date)anObject;
			return DATE_TYPE;
		}
		catch(Exception ex)
		{
			return ex.getMessage().substringBetween(open, close);
		}
	}
	/**
	 * @description Method to shuffle a list of SObjects
	 *
	 * @param objectList List of SObjects to be shuffled
	 */
	public static void shuffleList(List<Object> objectList)
	{
		Integer currentIndex = objectList.size();
		Integer randomIndex;
		Object temporaryValue;

		while(currentIndex != 0)
		{
			randomIndex = CMN_UTIL_Random.nextInteger(--currentIndex);

			//Swap values on positions currentIndex & randomIndex
			temporaryValue = objectList[currentIndex];
			objectList[currentIndex] = objectList[randomIndex];
			objectList[randomIndex] = temporaryValue;
		}
	}

	/**
	 * @description Will render a VF page to retrieve an API Enabled Session Id for current user
	 * To improve performance, session will be cached
	 *
	 * @return API enabled Session Id
	 */
	public static String getApiEnabledSessionId()
	{
		if(String.isBlank(apiEnabledSessionId))
		{
			//NB: GetContent cannot be called in a unit test as it results in the following error "Methods defined as TestMethod do not support getContent call"
			final String dummyPageContent = '<html>\n' +
					'<body>[[00D8K0000008hUd!AR8AQJBGJaOvuaNi0B1HuNalTfDFbcO55h2z8IvtggvX.K_gRm46YZLzQBwYA1r7lecFsZAP84RagxA0NEyF6qJZVfS9VfuA]]\n' +
					'</body>\n' +
					'</html>';

			String pageContent = Test.isRunningTest() ? dummyPageContent : Page.CMN_UTIL_GetApiEnabledSessionId.getContent().toString();
			apiEnabledSessionId = CMN_UTIL_String.substringBetween(pageContent, '[[', ']]');
		}

		return apiEnabledSessionId;
	}

	private static Set<String> getIgnoredSelectFields()
	{
		if(ignoredSelectFields == null)
		{
			ignoredSelectFields = new Set<String>
			{
					'AboutMe',
					'AnnualRevenue',
					'AssetId',
					'BannerPhotoUrl',
					'BusinessHoursId',
					'BusinessProcessId',
					'CallCenterId',
					'CampaignId',
					'CommunityId',
					'ContractId',
					'ConvertedAccountId',
					'ConvertedContactId',
					'CreatedById',
					'ConvertedDate',
					'ConvertedOpportunityId',
					'CreatorFullPhotoUrl',
					'CreatorSmallPhotoUrl',
					'DefaultCurrencyIsoCode',
					'DefaultGroupNotificationFrequency',
					'DelegatedApproverId',
					'DigestFrequency',
					'DoNotCall',
					'EmailBouncedDate',
					'EmailBouncedReason',
					'EmailEncodingKey',
					'EmailPreferencesAutoBcc',
					'EmailPreferencesAutoBccStayInTouch',
					'EmailPreferencesStayInTouchReminder',
					'EntitlementId',
					'Extension',
					'FederationIdentifier',
					'FeedItemId',
					'ForecastEnabled',
					'FullPhotoUrl',
					'GenderIdentity',
					'HasOptedOutOfEmail',
					'HasOptedOutOfFax',
					'IsCustomerPortal',
					'IsDeleted',
					'IsEmailBounced',
					'IsExtIndicatorVisible',
					'IsPartner',
					'IsPortalEnabled',
					'IsPrmSuperUser',
					'IsProfilePhotoActive',
					'Jigsaw',
					'JigsawCompanyId',
					'JigsawContactId',
					'LanguageLocaleKey',
					'LastActivityDate',
					'LastCURequestDate',
					'LastCUUpdateDate',
					'LastLoginDate',
					'LastModifiedById',
					'LastModifiedDate',
					'LastPasswordChangeDate',
					'LastReferencedDate',
					'LastTransferDate',
					'LastViewedDate',
					'LocaleSidKey',
					'LocaleSidKey',
					'MasterRecordId',
					'MediumBannerPhotoUrl',
					'MediumPhotoUrl',
					'NamespacePrefix',
					'NumberOfEmployees',
					'OfflinePdaTrialExpirationDate',
					'OfflineTrialExpirationDate',
					'OutOfOfficeMessage',
					'PartnerAccountId',
					'PermissionsAccessCMC',
					'PermissionsActivateContract',
					'PermissionsActivateOrder',
					'PermissionsAllowUniversalSearch',
					'PermissionsAllowViewKnowledge',
					'PermissionsApiEnabled',
					'PermissionsApiUserOnly',
					'PermissionsAssignPermissionSets',
					'PermissionsAssignTopics',
					'PermissionsAssignUserToSkill',
					'PermissionsAuthorApex',
					'PermissionsBulkApiHardDelete',
					'PermissionsBulkMacrosAllowed',
					'PermissionsBypassEmailApproval',
					'PermissionsCampaignInfluence2',
					'PermissionsCanApproveFeedPost',
					'PermissionsCanInsertFeedSystemFields',
					'PermissionsCanUseNewDashboardBuilder',
					'PermissionsChatterComposeUiCodesnippet',
					'PermissionsChatterEditOwnPost',
					'PermissionsChatterEditOwnRecordPost',
					'PermissionsChatterFileLink',
					'PermissionsChatterForSharePoint',
					'PermissionsChatterInternalUser',
					'PermissionsChatterInviteExternalUsers',
					'PermissionsChatterOwnGroups',
					'PermissionsConfigCustomRecs',
					'PermissionsConnectOrgToEnvironmentHub',
					'PermissionsContentAdministrator',
					'PermissionsContentHubUser',
					'PermissionsConvertLeads',
					'PermissionsCreateAuditFields',
					'PermissionsCreateCustomizeFilters',
					'PermissionsCreateMultiforce',
					'PermissionsCreateTopics',
					'PermissionsCreateWorkBadgeDefinition',
					'PermissionsCreateWorkspaces',
					'PermissionsCustomMobileAppsAccess',
					'PermissionsCustomizeApplication',
					'PermissionsDataExport',
					'PermissionsDelegatedPortalUserAdmin',
					'PermissionsDelegatedTwoFactor',
					'PermissionsDeleteActivatedContract',
					'PermissionsDeleteTopics',
					'PermissionsEditActivatedOrders',
					'PermissionsEditBrandTemplates',
					'PermissionsEditCaseComments',
					'PermissionsEditEvent',
					'PermissionsEditHtmlTemplates',
					'PermissionsEditKnowledge',
					'PermissionsEditOppLineItemUnitPrice',
					'PermissionsEditPublicDocuments',
					'PermissionsEditPublicTemplates',
					'PermissionsEditReadonlyFields',
					'PermissionsEditReports',
					'PermissionsEditTask',
					'PermissionsEditTopics',
					'PermissionsEmailAdministration',
					'PermissionsEmailMass',
					'PermissionsEmailSingle',
					'PermissionsEmailTemplateManagement',
					'PermissionsEnableNotifications',
					'PermissionsExportReport',
					'PermissionsFlowUFLRequired',
					'PermissionsForceTwoFactor',
					'PermissionsGovernNetworks',
					'PermissionsIdentityConnect',
					'PermissionsIdentityEnabled',
					'PermissionsImportCustomObjects',
					'PermissionsImportLeads',
					'PermissionsImportPersonal',
					'PermissionsInboundMigrationToolsUser',
					'PermissionsInstallMultiforce',
					'PermissionsLightningExperienceUser',
					'PermissionsManageAnalyticSnapshots',
					'PermissionsManageAuthProviders',
					'PermissionsManageBusinessHourHolidays',
					'PermissionsManageCallCenters',
					'PermissionsManageCases',
					'PermissionsManageCategories',
					'PermissionsManageChatterMessages',
					'PermissionsManageContentPermissions',
					'PermissionsManageContentProperties',
					'PermissionsManageContentTypes',
					'PermissionsManageCssUsers',
					'PermissionsManageCustomPermissions',
					'PermissionsManageCustomReportTypes',
					'PermissionsManageDashboards',
					'PermissionsManageDataCategories',
					'PermissionsManageDataIntegrations',
					'PermissionsManageEmailClientConfig',
					'PermissionsManageEncryptionKeys',
					'PermissionsManageEntitlements',
					'PermissionsManageExchangeConfig',
					'PermissionsManageInteraction',
					'PermissionsManageInternalUsers',
					'PermissionsManageIpAddresses',
					'PermissionsManageKnowledge',
					'PermissionsManageKnowledgeImportExport',
					'PermissionsManageLeads',
					'PermissionsManageLoginAccessPolicies',
					'PermissionsManageMobile',
					'PermissionsManageNetworks',
					'PermissionsManagePartners',
					'PermissionsManagePasswordPolicies',
					'PermissionsManageProfilesPermissionsets',
					'PermissionsManageRemoteAccess',
					'PermissionsManageRoles',
					'PermissionsManageSearchPromotionRules',
					'PermissionsManageSharing',
					'PermissionsManageSolutions',
					'PermissionsManageSynonyms',
					'PermissionsManageTwoFactor',
					'PermissionsManageUnlistedGroups',
					'PermissionsManageUsers',
					'PermissionsMassInlineEdit',
					'PermissionsMergeTopics',
					'PermissionsModerateChatter',
					'PermissionsModerateNetworkFeeds',
					'PermissionsModerateNetworkFiles',
					'PermissionsModerateNetworkMessages',
					'PermissionsModerateNetworkUsers',
					'PermissionsModifyAllData',
					'PermissionsNewReportBuilder',
					'PermissionsOutboundMigrationToolsUser',
					'PermissionsPasswordNeverExpires',
					'PermissionsPortalSuperUser',
					'PermissionsPublishMultiforce',
					'PermissionsResetPasswords',
					'PermissionsRunFlow',
					'PermissionsRunReports',
					'PermissionsSalesConsole',
					'PermissionsScheduleJob',
					'PermissionsScheduleReports',
					'PermissionsSelectFilesFromSalesforce',
					'PermissionsSendAnnouncementEmails',
					'PermissionsSendExternalEmailAvailable',
					'PermissionsSendSitRequests',
					'PermissionsShareInternalArticles',
					'PermissionsShowCompanyNameAsUserBadge',
					'PermissionsSolutionImport',
					'PermissionsSubmitMacrosAllowed',
					'PermissionsTransferAnyCase',
					'PermissionsTransferAnyEntity',
					'PermissionsTransferAnyLead',
					'PermissionsTwoFactorApi',
					'PermissionsUpdateWithInactiveOwner',
					'PermissionsUseTeamReassignWizards',
					'PermissionsViewAllData',
					'PermissionsViewAllUsers',
					'PermissionsViewCaseInteraction',
					'PermissionsViewContent',
					'PermissionsViewDataCategories',
					'PermissionsViewEncryptedData',
					'PermissionsViewEventLogFiles',
					'PermissionsViewGlobalHeader',
					'PermissionsViewHelpLink',
					'PermissionsViewMyTeamsDashboards',
					'PermissionsViewSetup',
					'PersonAssistantName',
					'PersonAssistantPhone',
					'PersonDoNotCall',
					'PersonEmailBouncedDate',
					'PersonEmailBouncedReason',
					'PersonHasOptedOutOfEmail',
					'PersonHasOptedOutOfFax',
					'PersonLastCURequestDate',
					'PersonLastCUUpdateDate',
					'PhotoUrl',
					'PortalAccountOwnerId',
					'PortalRole',
					'ProductId',
					'Pronouns',
					'QuestionId',
					'Rating',
					'ReceivesAdminInfoEmails',
					'ReceivesInfoEmails',
					'SenderEmail',
					'SenderName',
					'Sic',
					'SicDesc',
					'Signature',
					'SmallBannerPhotoUrl',
					'SmallPhotoUrl',
					'SobjectType',
					'StayInTouchNote',
					'StayInTouchSignature',
					'StayInTouchSubject',
					'SyncedQuoteId',
					'SystemModstamp',
					'TickerSymbol',
					'TimeZoneSidKey',
					'UserLicenseId',
					'UserPermissionsCallCenterAutoLogin',
					'UserPermissionsChatterAnswersUser',
					'UserPermissionsInteractionUser',
					'UserPermissionsKnowledgeUser',
					'UserPermissionsLiveAgentUser',
					'UserPermissionsMarketingUser',
					'UserPermissionsMobileUser',
					'UserPermissionsOfflineUser',
					'UserPermissionsSFContentUser',
					'UserPermissionsSupportUser',
					'UserPreferencesActivityRemindersPopup',
					'UserPreferencesApexPagesDeveloperMode',
					'UserPreferencesCacheDiagnostics',
					'UserPreferencesContentEmailAsAndWhen',
					'UserPreferencesContentNoEmail',
					'UserPreferencesCreateLEXAppsWTShown',
					'UserPreferencesDisCommentAfterLikeEmail',
					'UserPreferencesDisMentionsCommentEmail',
					'UserPreferencesDisProfPostCommentEmail',
					'UserPreferencesDisableAllFeedsEmail',
					'UserPreferencesDisableBookmarkEmail',
					'UserPreferencesDisableChangeCommentEmail',
					'UserPreferencesDisableEndorsementEmail',
					'UserPreferencesDisableFileShareNotification',
					'UserPreferencesDisableFileShareNotificationsForApi',
					'UserPreferencesDisableFollowersEmail',
					'UserPreferencesDisableLaterCommentEmail',
					'UserPreferencesDisableLikeEmail',
					'UserPreferencesDisableMentionsPostEmail',
					'UserPreferencesDisableMessageEmail',
					'UserPreferencesDisableProfilePostEmail',
					'UserPreferencesDisableSharePostEmail',
					'UserPreferencesEnableAutoSubForFeeds',
					'UserPreferencesEventRemindersCheckboxDefault',
					'UserPreferencesGlobalNavBarWTShown',
					'UserPreferencesGlobalNavGridMenuWTShown',
					'UserPreferencesHideBiggerPhotoCallout',
					'UserPreferencesHideCSNDesktopTask',
					'UserPreferencesHideCSNGetChatterMobileTask',
					'UserPreferencesHideChatterOnboardingSplash',
					'UserPreferencesHideEndUserOnboardingAssistantModal',
					'UserPreferencesHideLightningMigrationModal',
					'UserPreferencesHideS1BrowserUI',
					'UserPreferencesHideSecondChatterOnboarding',
					'UserPreferencesHideSecondChatterOnboardingSplash',
					'UserPreferencesHideSfxWelcomeMat',
					'UserPreferencesLightningExperiencePreferred',
					'UserPreferencesPathAssistantCollapsed',
					'UserPreferencesPreviewLightning',
					'UserPreferencesReminderSoundOff',
					'UserPreferencesShowCityToExternalUsers',
					'UserPreferencesShowCityToGuestUsers',
					'UserPreferencesShowCountryToExternalUsers',
					'UserPreferencesShowCountryToGuestUsers',
					'UserPreferencesShowEmailToExternalUsers',
					'UserPreferencesShowEmailToGuestUsers',
					'UserPreferencesShowFaxToExternalUsers',
					'UserPreferencesShowFaxToGuestUsers',
					'UserPreferencesShowManagerToExternalUsers',
					'UserPreferencesShowManagerToGuestUsers',
					'UserPreferencesShowMobilePhoneToExternalUser',
					'UserPreferencesShowMobilePhoneToExternalUsers',
					'UserPreferencesShowMobilePhoneToGuestUsers',
					'UserPreferencesShowPostalCodeToExternalUser',
					'UserPreferencesShowPostalCodeToExternalUsers',
					'UserPreferencesShowPostalCodeToGuestUsers',
					'UserPreferencesShowProfilePicToGuestUsers',
					'UserPreferencesShowStateToExternalUsers',
					'UserPreferencesShowStateToGuestUsers',
					'UserPreferencesShowStreetAddressToExternal',
					'UserPreferencesShowStreetAddressToExternalUsers',
					'UserPreferencesShowStreetAddressToGuestUsers',
					'UserPreferencesShowTitleToExternalUsers',
					'UserPreferencesShowTitleToGuestUsers',
					'UserPreferencesShowWorkPhoneToExternalUser',
					'UserPreferencesShowWorkPhoneToExternalUsers',
					'UserPreferencesShowWorkPhoneToGuestUsers',
					'UserPreferencesSortFeedByComment',
					'UserPreferencesTaskRemindersCheckboxDefault',
					'UserType',
					CMN_DAL_SObjectDomain.FIELD_ID
			};
		}
		return ignoredSelectFields;
	}
}