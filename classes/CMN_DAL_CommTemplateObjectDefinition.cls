/**
 * @description Provides Query methods related to Communication Template Object Definition object
 *
 * @author aakriti.a.goyal@accenture.com, darrion.james.singh@accenture.com
 *
 * @date Sept 2021, May 2021
 */
public inherited sharing class CMN_DAL_CommTemplateObjectDefinition
{
	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_CommunicationTemplateObjectDef__c.CMN_ApiName__c.getDescribe().getLocalName(),
				CMN_CommunicationTemplateObjectDef__c.CMN_Code__c.getDescribe().getLocalName(),
				CMN_CommunicationTemplateObjectDef__c.CMN_GroupingName__c.getDescribe().getLocalName(),
				CMN_CommunicationTemplateObjectDef__c.Id.getDescribe().getLocalName()
		};
	}

	/**
	 * @description This method is use to retrieve the template objects by the object definition Ids
	 *
	 * @param definitionIds Object Definition Ids
	 *
	 * @return List of items
	 */
	public static List<CMN_CommunicationTemplateObjectDef__c> findByIds(Set<Id> definitionIds)
	{
		return CMN_DAL_SObjectSelector.findById(CMN_CommunicationTemplateObjectDef__c.SObjectType, definitionIds, getDefaultFields());
	}

	/**
	 * @description Will return all the CMN_CommunicationTemplateObjectDef__c in the system
	 *
	 * @return A list of CMN_CommunicationTemplateObjectDef__c
	 */
	@TestVisible
	private static List<CMN_CommunicationTemplateObjectDef__c> getAll()
	{
		return CMN_DAL_Search.getAll(CMN_CommunicationTemplateObjectDef__c.SObjectType, getDefaultFields());
	}
}