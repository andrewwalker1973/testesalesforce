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
 * <p>Read record wrapper around CMN_SOQL_Query</p>
 * Provides methods to query SObjects generically wrappers CMN_DAL_Search for common search functions
 * on SObjects
 * SObjectSelector can be used statically (static methods for convenience or as its own instance)
 *
 * @see CMN_DAL_SObjectSelector_TEST
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date August 2021, June 2022
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class CMN_DAL_SObjectSelector
{
	private final static Set<String> NULL_SET_OF_STRINGS = null;

	/**
	 * @description This method is use initialise search parameters so that Developer can insert additional search parameters like `addOrderByField`
	 *
	 * @param objectName object against which to search
	 * @param searchField the field against which to filter
	 * @param searchValues the values to match
	 * @param selectedFields fields to query
	 *
	 * @return a populated search parameter object
	 */
	public static CMN_DAL_Search.SOQLSearchParameters initialiseParameters
			(String objectName, String searchField, Set<String> searchValues, Set<String> selectedFields)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(objectName, selectedFields);

		searchParameters.searchConditions.inX(searchField, CMN_UTIL_System.setToList(searchValues));

		return searchParameters;
	}

	/**
	 * @description This method is use to get the List of SObject
	 *
	 * @param objectName object against which to search
	 * @param searchField the field against which to filter
	 * @param searchValues the values to match
	 * @param selectedFields fields to query
	 *
	 * @return a populated search parameter object
	 */
	public static List<SObject> findByField(String objectName, String searchField, Set<String> searchValues, Set<String> selectedFields)
	{
		//No point in running query with empty search values; also a set condition is invalid if empty.
		if(searchValues.isEmpty())
		{
			return new List<SObject>();
		}

		CMN_DAL_Search.SOQLSearchParameters searchParameters = initialiseParameters(objectName, searchField, searchValues, selectedFields);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method is use to get the unique record of SObject
	 *
	 * @param objectName as input
	 * @param searchField as input
	 * @param searchValue as input
	 * @param selectedFields as input
	 * @param mustBeUnique as input
	 *
	 * @return searchParameters
	 */
	public static SObject findByField(String objectName, String searchField, String searchValue, Set<String> selectedFields, Boolean mustBeUnique)
	{
		List<SObject> foundObjects = findByField(objectName, searchField, new Set<String> {searchValue}, selectedFields);

		if(foundObjects.isEmpty())
		{
			return null;
		}
		else
				if(foundObjects.size() > 1)
				{
					if(mustBeUnique)
					{
						throw new SearchException('More than one ' + objectName + ' found when querying ' + searchField + ' with ' + searchValue);
					}
					else
					{
						return null;
					}
				}
				else
				{
					return foundObjects.iterator().next();
				}
	}

	/**
	 * @description Will retrieve an object based on field and values given
	 *
	 * @param objectType as input
	 * @param searchField as input
	 * @param searchValue as input
	 * @param selectedFields as input
	 * @param mustBeUnique as input
	 *
	 * @return sobject
	 */
	public static SObject findByField(SObjectType objectType, SObjectField searchField, String searchValue, Set<String> selectedFields, Boolean mustBeUnique)
	{
		return findByField(objectType.getDescribe().getLocalName(), searchField.getDescribe().getLocalName(), searchValue, selectedFields, mustBeUnique);
	}

	/**
	 * @description This is used to fin an object based on Id, please note providing a null will result in a null response
	 *
	 * @param objectName as input
	 * @param itemId as input
	 * @param requiredFields as input
	 *
	 * @return sobject
	 */
	public static SObject findById(String objectName, Id itemId, Set<String> requiredFields)
	{
		return findById(objectName, CMN_DAL_SObjectDomain.FIELD_ID, itemId, requiredFields);

	}

	/**
	 * @description Will retrieve an object based on an ID field, if the Id is null a null will be returned
	 *
	 * @param objectName Name of the object to query
	 * @param searchField Name of the field against which to search
	 * @param itemId The Id of the object
	 * @param requiredFields The fields to query
	 *
	 * @return Null or the unique object
	 */
	public static SObject findById(String objectName, String searchField, Id itemId, Set<String> requiredFields)
	{
		return String.isBlank(itemId) ? null : findByField(objectName, searchField, String.valueOf(itemId), requiredFields, true);
	}

	/**
	 * @description This method is use to get objects on an Id
	 *
	 * @param objectName as input
	 * @param searchField as input
	 * @param itemIds as input
	 * @param requiredFields as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> findById(String objectName, String searchField, Set<Id> itemIds, Set<String> requiredFields)
	{
		return findByField(objectName, searchField, CMN_UTIL_System.convertIdSetToStringSet(itemIds), requiredFields);
	}

	/**
	 * @description Will return the number of records based search parameters
	 *
	 * @param objectName The API name of the object to perform search against
	 * @param searchField The API name of the field against which to count the records
	 * @param itemIds The ids against which to filter
	 *
	 * @return Number of records found
	 */
	public static Integer countById(String objectName, String searchField, Set<Id> itemIds)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(objectName);
		searchParameters.searchConditions.inX(searchField, CMN_UTIL_System.setToList(itemIds));
		return CMN_DAL_Search.getObjectCount(searchParameters);
	}

	/**
	 * @description This method is use to get Ids
	 *
	 * @param objectName as input
	 * @param itemIds as input
	 * @param requiredFields as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> findById(String objectName, Set<Id> itemIds, Set<String> requiredFields)
	{
		return findById(objectName, CMN_DAL_SObjectDomain.FIELD_ID, itemIds, requiredFields);
	}

	/**
	 * @description This method is use to get Ids
	 *
	 * @param objectType as input
	 * @param itemId as input
	 * @param requiredFields as input
	 *
	 * @return sobject
	 */
	public static SObject findById(SObjectType objectType, Id itemId, Set<String> requiredFields)
	{
		return findById(objectType.getDescribe().getLocalName(), CMN_DAL_SObjectDomain.FIELD_ID, itemId, requiredFields);
	}

	/**
	 * @description This method is use to get Ids
	 *
	 * @param objectType as input
	 * @param itemIds as input
	 * @param requiredFields as input
	 *
	 * @return list of sobjects found by ids
	 */
	public static List<SObject> findById(SObjectType objectType, Set<Id> itemIds, Set<String> requiredFields)
	{
		return findById(objectType.getDescribe().getLocalName(), itemIds, requiredFields);
	}

	/**
	 * @description This method is use to get name
	 *
	 * @param objectName as input
	 * @param nameValue as input
	 * @param requiredFields as input
	 *
	 * @return sobject found by name
	 */
	public static SObject findByName(String objectName, String nameValue, Set<String> requiredFields)
	{
		return findByField(objectName, CMN_DAL_SObjectDomain.FIELD_NAME, nameValue, requiredFields, true);
	}

	/**
	 * @description This method is use to get name
	 *
	 * @param objectType as input
	 * @param nameValue as input
	 * @param requiredFields as input
	 *
	 * @return sobject found by name
	 */
	public static SObject findByName(SObjectType objectType, String nameValue, Set<String> requiredFields)
	{
		return findByName(objectType.getDescribe().getLocalName(), nameValue, requiredFields);
	}

	/**
	 * @description query by id only
	 *
	 * @param id as input
	 *
	 * @return sobject
	 */
	public static SObject query(String id)
	{
		return first(query(new Set<String> {id}, NULL_SET_OF_STRINGS));
	}

	/**
	 * @description query by id only
	 *
	 * @param id as input
	 * @param fields to return
	 *
	 * @return sobject
	 */
	public static SObject query(String id, List<String> fields)
	{
		return first(query(new Set<String> {id}, fields));
	}

	/**
	 * @description query by id only
	 *
	 * @param id as input
	 * @param fields to return
	 *
	 * @return sobject
	 */
	public static SObject query(String id, Set<String> fields)
	{
		return first(query(new Set<String> {id}, fields));
	}

	/**
	 * @description query by list of same type ids
	 *
	 * @param ids as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> query(List<String> ids)
	{
		return query(ids, NULL_SET_OF_STRINGS);
	}

	/**
	 * @description query by set of same type ids
	 *
	 * @param ids as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> query(Set<String> ids)
	{
		return query(ids, NULL_SET_OF_STRINGS);
	}

	/**
	 * @description query by ids and specify fields to return
	 *
	 * @param ids as input
	 * @param fields to return
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> query(List<String> ids, List<String> fields)
	{
		return query(CMN_UTIL_Set.listToSet(ids), CMN_UTIL_Set.listToSet(fields));
	}

	/**
	 * @description query by ids and specify fields to return
	 *
	 * @param ids as input
	 * @param fields to return
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> query(List<String> ids, Set<String> fields)
	{
		return query(CMN_UTIL_Set.listToSet(ids), fields);
	}

	/**
	 * @description query by ids and specify fields to return
	 *
	 * @param ids as input
	 * @param fields to return
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> query(Set<String> ids, List<String> fields)
	{
		return query(ids, CMN_UTIL_Set.listToSet(fields));
	}

	/**
	 * @description query by ids and specify fields to return
	 *
	 * @param ids as input
	 * @param fields to return
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> query(Set<String> ids, Set<String> fields)
	{
		if(ids == null || ids.isEmpty())
		{
			throw new IllegalArgumentException('ids argument must not be empty: ' + ids);
		}

		final Set<String> distinctKeyPrefixes = left(trim(ids), 3);

		if(distinctKeyPrefixes.size() > 1)
		{
			//ruh-roh, someone mixed types
			throw new IllegalArgumentException('ids argument invalid:  multiple SObject types detected: ' + distinctKeyPrefixes);
		}

		final CMN_SOQL_Builder soql =
				new CMN_SOQL_Builder()
						.fromX(CMN_UTIL_System.getObjectNameFromId(ids.iterator().next()))
						.whereX(new CMN_SOQL_Query.SetCondition('id').inX(CMN_UTIL_Set.setToList(ids)));

		if(fields == null || fields.size() <= 0)
		{
			soql.selectAll();
		}
		else
		{
			soql.selectX(fields);
		}
		return Database.query(soql.toSoql());
	}

	/**
	 * @description utility to left substring a collection of strings
	 *
	 * @param strings as input
	 * @param len as input to indicate length of left substring operation
	 *
	 * @return trimmed strings collection
	 */
	private static Set<String> left(Set<String> strings, Integer len)
	{
		Set<String> returnValue = null;
		if(strings != null || !strings.isEmpty())
		{
			returnValue = new Set<String>();
			for(String str : strings)
			{
				returnValue.add(CMN_UTIL_String.left(str, len));
			}
		}
		return returnValue;
	}

	/**
	 * @description utility to trim collection of strings
	 *
	 * @param strings as input
	 *
	 * @return trimmed strings collection
	 */
	private static Set<String> trim(Set<String> strings)
	{
		Set<String> returnValue = null;
		if(strings != null || !strings.isEmpty())
		{
			returnValue = new Set<String>();
			for(String str : strings)
			{
				returnValue.add(CMN_UTIL_String.trim(str));
			}
		}
		return returnValue;
	}

	/**
	 * @description utility to return first record in record list
	 *
	 * @param records as input
	 *
	 * @return first sobject
	 */
	public static SObject first(List<SObject> records)
	{
		SObject returnValue = null;

		if(records != null && !records.isEmpty())
		{
			returnValue = records.iterator().next();
		}

		return returnValue;
	}
}