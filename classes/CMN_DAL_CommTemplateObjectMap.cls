/**
 * @description Provides Query methods related to Communication Template Object Map object
 *
 * @author aakriti.a.goyal@accenture.com
 *
 * @date Sept 2021
 */
public inherited sharing class CMN_DAL_CommTemplateObjectMap
{
	private static final String FIELD_COMMUNICATION_TEMPLATE = CMN_CommunicationTemplateObjectMap__c.CMN_CommunicationTemplate__c.getDescribe().getLocalName();
	private static final String OBJECT_NAME = CMN_CommunicationTemplateObjectMap__c.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_OBJECT_DEFINITION = CMN_CommunicationTemplateObjectMap__c.CMN_ObjectDefinition__c.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_CommunicationTemplateObjectMap__c.CMN_ObjectDefinition__c.getDescribe().getLocalName(),
				CMN_CommunicationTemplateObjectMap__c.Id.getDescribe().getLocalName(),
				CMN_CommunicationTemplateObjectMap__c.Name.getDescribe().getLocalName(),
				FIELD_COMMUNICATION_TEMPLATE
		};
	}

	/**
	 * @description This method is use to retrieve the template object Maps by the the communication template
	 *
	 * @param templateId Id of the Communication Template
	 *
	 * @return List of items
	 */
	public static List<CMN_CommunicationTemplateObjectMap__c> findByCommunicationTemplate(String templateId)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_COMMUNICATION_TEMPLATE, new Set<String> {templateId}, getDefaultFields());
	}
}