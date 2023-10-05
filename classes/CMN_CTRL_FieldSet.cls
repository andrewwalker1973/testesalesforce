/**
 * @description Common Controller used to get fields from Field set based on the Sobject
 *
 * @see CMN_CTRL_FieldSet_TEST
 *
 * @author jason.van.beukering@accenture.com, pavan.t@lntinfotech.com
 *
 * @date June 2022, July 2023
 */
@SuppressWarnings('PMD.CognitiveComplexity')
public inherited sharing class CMN_CTRL_FieldSet
{
	/**
	 * @description Use the method to get 1 or more fieldSets for a record of a particular SObjectType.
	 * eg: When you require 2 fieldSets for an account record, and 1 fieldSet for a case record in a single call
	 * Do not use when you want 1 fieldSet for multiple records of the same SObjectType
	 *
	 * @param recordIdToFieldSetListMap Map of record Id and List of fieldSets
	 *
	 * @return Map of FieldSetAPIName with List of DTO_FieldSetMembers
	 */
	@AuraEnabled(Cacheable=true)
	public static Map<Id, Map<String, List<DTO_FieldSetMember>>> getFieldSetsForRecord(Map<Id, List<String>> recordIdToFieldSetListMap)
	{
		Map<Id, Set<FieldSet>> objectIdToFieldsSetMap = new Map<Id, Set<FieldSet>>();
		Map<String, Set<Id>> objectNameToIdMap = new Map<String, Set<Id>>();
		Map<String, Set<String>> objectNameToFieldsMap = new Map<String, Set<String>>();

		initialiseMaps(recordIdToFieldSetListMap, objectNameToIdMap, objectNameToFieldsMap, objectIdToFieldsSetMap);

		List<SObject> foundObjects = findObjectsById(objectNameToIdMap, objectNameToFieldsMap);

		Map<Id, Map<String, List<DTO_FieldSetMember>>> objectIdToDtoMemberMap = new Map<Id, Map<String, List<DTO_FieldSetMember>>>();

		for(SObject foundObject : foundObjects)
		{
			Set<FieldSet> foundFieldSets = objectIdToFieldsSetMap.get(foundObject.Id);

			//This situation occurs when valid object Id is passed for an object with field sets, but request is passed with invalid field set name
			if(foundFieldSets == null)
			{
				continue;
			}

			Map<String, List<DTO_FieldSetMember>> dtoMemberByFieldSetMap = objectIdToDtoMemberMap.get(foundObject.Id);

			if(dtoMemberByFieldSetMap == null)
			{
				dtoMemberByFieldSetMap = new Map<String, List<DTO_FieldSetMember>>();
				objectIdToDtoMemberMap.put(foundObject.Id, dtoMemberByFieldSetMap);
			}

			for(FieldSet foundFieldSet : foundFieldSets)
			{
				List<DTO_FieldSetMember> dtoFieldSetMembers = dtoMemberByFieldSetMap.get(foundFieldSet.name);

				if(dtoFieldSetMembers == null)
				{
					dtoFieldSetMembers = new List<DTO_FieldSetMember>();
					dtoMemberByFieldSetMap.put(foundFieldSet.name, dtoFieldSetMembers);
				}

				addDtoFieldSetMembers(foundFieldSet, foundObject, dtoFieldSetMembers);
			}
		}

		return objectIdToDtoMemberMap;
	}

	/**
	 * @description Will setup the maps required to get the required information from object Ids and field sets provided
	 *
	 * @param recordIdToFieldSetListMap Original request with object Ids and required field set names
	 * @param objectNameToIdMap A map of object API name to the Ids request
	 * @param objectNameToFieldsMap A map of object API name to  required fields (API name)
	 * @param objectIdToFieldsSetMap A map of original Object Ids by found FieldSets (will be used to populate final response)
	 */
	@SuppressWarnings('PMD.CognitiveComplexity')
	private static void initialiseMaps
			(
					Map<Id, List<String>> recordIdToFieldSetListMap,
					Map<String, Set<Id>> objectNameToIdMap,
					Map<String, Set<String>> objectNameToFieldsMap,
					Map<Id, Set<FieldSet>> objectIdToFieldsSetMap
			)
	{
		for(Id recordId : recordIdToFieldSetListMap.keySet())
		{
			List<String> fieldsetNames = recordIdToFieldSetListMap.get(recordId);

			if(fieldsetNames == null || fieldsetNames.isEmpty())
			{
				continue;
			}

			String objectName = CMN_UTIL_System.getObjectNameFromId(recordId);

			Map<String, FieldSet> fieldSetMap = CMN_UTIL_SObjectDescribe.getDescribe(objectName).getFieldSetsMap();

			if(fieldSetMap == null || fieldSetMap.isEmpty())
			{
				continue;
			}

			Set<Id> recordIds = objectNameToIdMap.get(objectName);

			if(recordIds == null)
			{
				recordIds = new Set<Id>();
				objectNameToIdMap.put(objectName, recordIds);
			}

			recordIds.add(recordId);

			for(String fieldSetName : fieldsetNames)
			{
				FieldSet foundFieldset = fieldSetMap.get(fieldSetName);

				if(foundFieldset == null)
				{
					continue;
				}

				Set<String> fieldSetFieldNames = getFieldNamesFromFieldSetMember(foundFieldset.fields);

				Set<String> fieldNames = objectNameToFieldsMap.get(objectName);

				if(fieldNames == null)
				{
					fieldNames = new Set<String>();
					objectNameToFieldsMap.put(objectName, fieldNames);
				}

				fieldNames.addAll(fieldSetFieldNames);

				Set<FieldSet> fieldSets = objectIdToFieldsSetMap.get(recordId);

				if(fieldSets == null)
				{
					fieldSets = new Set<FieldSet>();
					objectIdToFieldsSetMap.put(recordId, fieldSets);
				}

				fieldSets.add(foundFieldset);
			}
		}
	}

	/**
	 * @description Will retrieve all objects that have fields per original request
	 *
	 * @param objectNameToIdMap A unique list of object names and requested records
	 * @param objectNameToFieldsMap The fields per object to query
	 *
	 * @return A list of found items
	 */
	private static List<SObject> findObjectsById(Map<String, Set<Id>> objectNameToIdMap, Map<String, Set<String>> objectNameToFieldsMap)
	{
		List<SObject> foundObjects = new List<SObject>();

		for(String objectName : objectNameToIdMap.keySet())
		{
			CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(objectName, objectNameToFieldsMap.get(objectName));
			searchParameters.searchConditions.inX(CMN_DAL_SObjectDomain.FIELD_ID, CMN_UTIL_System.setToList(objectNameToIdMap.get(objectName)));
			searchParameters.enforceSharing = false;
			foundObjects.addAll(CMN_DAL_Search.getObjects(searchParameters));
		}
		return foundObjects;
	}

	/**
	 * @description Will add to the DTO FieldSet Member list using the record and Field Set provided
	 *
	 * @param foundFieldSet A fieldset for the given object
	 * @param foundObject An object record
	 * @param dtoFieldSetMembers List to which to add the DTO List
	 */
	private static void addDtoFieldSetMembers(FieldSet foundFieldSet, SObject foundObject, List<DTO_FieldSetMember> dtoFieldSetMembers)
	{
		for(FieldSetMember member : foundFieldSet.getFields())
		{
			DTO_FieldSetMember dtoFieldSetMember = new DTO_FieldSetMember();

			dtoFieldSetMember.fieldAPIName = member.fieldPath;
			dtoFieldSetMember.fieldLabel = member.label;
			dtoFieldSetMember.fieldSetAPIName = foundFieldSet.name;
			dtoFieldSetMember.fieldSetName = foundFieldSet.label;
			dtoFieldSetMember.fieldType = member.type.name();
			dtoFieldSetMember.fieldValue = CMN_UTIL_System.getFieldValue(foundObject, member.fieldPath);
			dtoFieldSetMember.isRequired = member.dbRequired || member.required;
			dtoFieldSetMember.objectName = foundFieldSet.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).name;

			if(dtoFieldSetMember.fieldValue != null)
			{
				switch on member.type
				{
					when REFERENCE
					{
						DescribeFieldResult fieldDescribe = member.SObjectField.getDescribe();
						dtoFieldSetMember.fieldDisplayValue
								= CMN_UTIL_System.getFieldValue(foundObject, fieldDescribe.relationshipName + CMN_UTIL_String.DOT + CMN_DAL_SObjectDomain.FIELD_NAME);
					}
					when PICKLIST
					{
						DescribeFieldResult fieldDescribe = member.SObjectField.getDescribe();
						Map<String, String> picklistMap =
								CMN_UTIL_System.getPicklistEntriesMap(fieldDescribe.SObjectType, dtoFieldSetMember.fieldAPIName, false);
						dtoFieldSetMember.fieldDisplayValue = picklistMap.get(String.valueOf(dtoFieldSetMember.fieldValue));
					}
					when else
					{
						dtoFieldSetMember.fieldDisplayValue = String.valueOf(dtoFieldSetMember.fieldValue);
					}
				}
			}

			dtoFieldSetMembers.add(dtoFieldSetMember);
		}
	}

	/**
	 * @description Use the method to get 1 or more fieldSets for a specific SObjectName.
	 *
	 * @param objectNameToFieldSetListMap Map of record Id and List of fieldSets
	 *
	 * @return Map of ObjectName to Map of FieldSetAPIName with List of DTO_FieldSetMembers
	 */
	@AuraEnabled(Cacheable=true)
	public static Map<String, Map<String, List<DTO_FieldSetMember>>> getFieldSetsForObject(Map<String, List<String>> objectNameToFieldSetListMap)
	{
		Map<String, Map<String, List<DTO_FieldSetMember>>> objectNameToFieldSetMap = new Map<String, Map<String, List<DTO_FieldSetMember>>>();

		for(String objectName : objectNameToFieldSetListMap.keySet())
		{
			Map<String, List<DTO_FieldSetMember>> memberByFieldSetMap = objectNameToFieldSetMap.get(objectName);

			if(memberByFieldSetMap == null)
			{
				memberByFieldSetMap = new Map<String, List<DTO_FieldSetMember>>();
				objectNameToFieldSetMap.put(objectName, memberByFieldSetMap);
			}

			Map<String, FieldSet> fieldSetByNameMap = CMN_UTIL_SObjectDescribe.getDescribe(objectName).getFieldSetsMap();

			List<String> fieldSetNames = objectNameToFieldSetListMap.get(objectName);

			for(String fieldSetName : fieldSetNames)
			{
				FieldSet foundFieldSet = fieldSetByNameMap.get(fieldSetName);

				if(foundFieldSet == null)
				{
					continue;
				}

				List<DTO_FieldSetMember> dtoFieldSetMembers = memberByFieldSetMap.get(fieldSetName);

				if(dtoFieldSetMembers == null)
				{
					dtoFieldSetMembers = new List<DTO_FieldSetMember>();
					memberByFieldSetMap.put(fieldSetName, dtoFieldSetMembers);
				}

				addDtoFieldSetMembers(foundFieldSet, null, dtoFieldSetMembers);
			}
		}

		return objectNameToFieldSetMap;
	}

	/**
	 * @description This method is used to get the field names from fieldSetMember
	 *
	 * @param members A List of fieldSetMembers
	 *
	 * @return Set of name
	 */
	@TestVisible
	private static Set<String> getFieldNamesFromFieldSetMember(List<FieldSetMember> members)
	{
		Set<String> fieldNames = new Set<String>();

		for(FieldSetMember member : members)
		{
			fieldNames.add(member.fieldPath);
			if(member.type == DisplayType.REFERENCE)
			{
				fieldNames.add(member.SObjectField.getDescribe().relationshipName + CMN_UTIL_String.DOT + CMN_DAL_SObjectDomain.FIELD_NAME);
			}
		}

		return fieldNames;
	}

	/**
	 * @description This method is used to get the map of custom metadata developer name to custom metadata record which has the fieldSets information
	 *
	 * @param developerName The developerName of custom metadata
	 *
	 * @return Map of DeveloperName to the CustomMetadata record
	 */
	@AuraEnabled(Cacheable=true)
	public static CMN_LightningWebComponentsFieldSet__mdt findByDeveloperName(String developerName)
	{
		return CMN_DAL_LightningWebComponentsFieldSets.findByDeveloperName(developerName);
	}

	/**
	 * @description Retrieves the SObject API name from record Id
	 *
	 * @param recordId Record Id to obtain information about
	 *
	 * @return SObject API Name
	 */
	@AuraEnabled(Cacheable=true)
	public static String getObjectNameFromRecordId(Id recordId)
	{
		return CMN_UTIL_System.getObjectNameFromId(recordId);
	}

	/**
	 * @description This wrapper class is used to store the field information
	 */
	public class DTO_FieldSetMember
	{
		/**
		 * @description stores the Label for the fields in the fieldSet
		 */
		@AuraEnabled
		public String fieldLabel {get; set;}
		/**
		 * @description stores the APIName for the fields in the fieldSet
		 */
		@AuraEnabled
		public String fieldAPIName {get; set;}
		/**
		 * @description The display value for the field, will be set when the field is storing the Id of a related object
		 */
		@AuraEnabled
		public Object fieldDisplayValue {get; set;}
		/**
		 * @description stores the value for the field in the fieldSet from the relevant SObject
		 */
		@AuraEnabled
		public Object fieldValue {get; set;}
		/**
		 * @description stores the APIName of the fieldSet
		 */
		@AuraEnabled
		public String fieldSetAPIName {get; set;}
		/**
		 * @description stores the Type of the field in the fieldset
		 */
		@AuraEnabled
		public String fieldType {get; set;}
		/**
		 * @description stores the Label of the fieldSet
		 */
		@AuraEnabled
		public String fieldSetName {get; set;}
		/**
		 * @description Required marker for the field
		 */
		@AuraEnabled
		public Boolean isRequired {get; set;}
		/**
		 * @description Object api name
		 */
		@AuraEnabled
		public String objectName {get; set;}
		/**
		 * @description Check to see if the object has a value set for the field
		 */
		@AuraEnabled
		public Boolean valueIsSet
		{
			get
			{
				return fieldValue != null;
			}
		}
	}
}