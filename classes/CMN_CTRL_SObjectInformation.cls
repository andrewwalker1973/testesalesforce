/**
 * @description Returns information about the an SObject for the purpose of displaying the correct form element in cmnLwcCreateForm
 *
 * @see CMN_CTRL_SObjectInformation_TEST
 *
 * @author darrion.james.singh@accenture.com
 *
 * @date January 2022
 */
public inherited sharing class CMN_CTRL_SObjectInformation
{
	/**
	 * @description Returns map of SObject field information for the purpose of form element display
	 *
	 * @param objectName SObject API name
	 *
	 * @return Map of field API name to CMN_DTO_FieldInformation
	 */
	@AuraEnabled(Cacheable=true)
	public static Map<String, CMN_DTO_FieldInformation> getSObjectFieldInformation(String objectName)
	{
		Map<String, CMN_DTO_FieldInformation> fieldNameToInfoMap = new Map<String, CMN_DTO_FieldInformation>();
		Map<String, SObjectField> objectTypeMap = CMN_UTIL_SObjectDescribe.getDescribe(objectName).getFieldsMap();
		for(SObjectField field : objectTypeMap.values())
		{
			String name = field.getDescribe().getLocalName();
			String label = field.getDescribe().getLabel();
			String fieldType = field.getDescribe().getType().name();
			String lookupObjectApiName = fieldType == DisplayType.REFERENCE.name() ?
					field.getDescribe().getReferenceTo().iterator().next().getDescribe().getName() : null;

			CMN_DTO_FieldInformation infoMap = new CMN_DTO_FieldInformation();
			infoMap.fieldLabel = label;
			infoMap.fieldType = fieldType;
			infoMap.lookupObjectApiName = lookupObjectApiName;

			fieldNameToInfoMap.put(name, infoMap);
		}
		return fieldNameToInfoMap;
	}

	/**
	 * @description Returns a list of record types and information by SObject API name
	 *
	 * @param objectName SObject API name
	 *
	 * @return List of CMN_DTO_RecordTypeInformation containing record type information
	 */
	@AuraEnabled(Cacheable=true)
	public static List<CMN_DTO_RecordTypeInformation> getRecordTypes(String objectName)
	{
		List<CMN_DTO_RecordTypeInformation> results = new List<CMN_DTO_RecordTypeInformation>();
		List<Schema.RecordTypeInfo> recordTypeInfos = CMN_UTIL_SObjectDescribe.getDescribe(objectName)
				.getDescribe().getRecordTypeInfos();

		for(Schema.RecordTypeInfo info : recordTypeInfos)
		{
			CMN_DTO_RecordTypeInformation dtoRecordTypeInfo = new CMN_DTO_RecordTypeInformation();

			dtoRecordTypeInfo.name = info.getDeveloperName();
			dtoRecordTypeInfo.label = info.getName();
			dtoRecordTypeInfo.available = info.isAvailable();
			dtoRecordTypeInfo.active = info.isActive();
			dtoRecordTypeInfo.master = info.isMaster();
			dtoRecordTypeInfo.recordTypeId = info.getRecordTypeId();

			results.add(dtoRecordTypeInfo);
		}

		return results;
	}

	/**
	 * @description DTO for Record Type information for an SObject
	 */
	public class CMN_DTO_RecordTypeInformation
	{
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String label;
		@AuraEnabled
		public Boolean available;
		@AuraEnabled
		public Boolean active;
		@AuraEnabled
		public Boolean master;
		@AuraEnabled
		public Id recordTypeId;
	}

	/**
	 * @description DTO for Field information for an SObject field
	 */
	public class CMN_DTO_FieldInformation
	{
		@AuraEnabled
		public String fieldLabel;
		@AuraEnabled
		public String fieldType;
		@AuraEnabled
		public String lookupObjectApiName;
	}
}