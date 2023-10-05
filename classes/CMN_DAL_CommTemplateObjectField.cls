/**
 * @description Provides Query methods related to Communication Template Object Field object
 *
 * @author aakriti.a.goyal@accenture.com
 *
 * @date Sept 2021
 */
public inherited sharing class CMN_DAL_CommTemplateObjectField
{
	private static final String FIELD_OBJECT_DEFINITION = CMN_CommunicationTemplateObjectField__c.CMN_ObjectDefinition__c.getDescribe().getLocalName();
	private static final String FIELD_OBJECT_DEFINITION_NAME = 'CMN_ObjectDefinition__r.CMN_ApiName__c';
	public static final String OBJECT_NAME = CMN_CommunicationTemplateObjectField__c.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_CommunicationTemplateObjectField__c.Id.getDescribe().getLocalName(),
				CMN_CommunicationTemplateObjectField__c.CMN_Code__c.getDescribe().getLocalName(),
				CMN_CommunicationTemplateObjectField__c.Name.getDescribe().getLocalName(),
				FIELD_OBJECT_DEFINITION,
				FIELD_OBJECT_DEFINITION_NAME
		};
	}

	/**
	 * @description This method is use to retrieve the communication template object fields by the the object definitions
	 *
	 * @param objectDefinitionIds Set of object definition Ids
	 *
	 * @return List of items
	 */
	public static List<CMN_CommunicationTemplateObjectField__c> findByObjectDefinitions(Set<Id> objectDefinitionIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_OBJECT_DEFINITION, objectDefinitionIds, getDefaultFields());
	}
}