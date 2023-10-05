/**
 * @description Provides Query methods related to Account object
 *
 * @author aakriti.a.goyal@accenture.com jason.van.beukering@accenture.com
 *
 * @date September 2021, April 2022
 */
public inherited sharing class CMN_DAL_CommunicationTemplateAttachment
{
	private static final String FIELD_DEFINITION = CMN_CommunicationTemplateAttachment__c.SC_Definition__c.getDescribe().getLocalName();
	private static final String FIELD_TEMPLATE = CMN_CommunicationTemplateAttachment__c.SC_Template__c.getDescribe().getLocalName();
	private static final String OBJECT_NAME = CMN_CommunicationTemplateAttachment__c.SObjectType.getDescribe().getLocalName();
	/**
	 * @description Template Definition Unique Id
	 */
	public static final String FIELD_DEFINITION_CODE = 'SC_Definition__r.SC_Code__c';
	/**
	 * @description Template Definition Name
	 */
	public static final String FIELD_DEFINITION_NAME = 'SC_Definition__r.Name';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_CommunicationTemplateAttachment__c.Name.getDescribe().getLocalName(),
				CMN_CommunicationTemplateAttachment__c.SC_Definition__c.getDescribe().getLocalName(),
				CMN_CommunicationTemplateAttachment__c.SC_Template__c.getDescribe().getLocalName(),
				FIELD_DEFINITION,
				FIELD_DEFINITION_CODE,
				FIELD_DEFINITION_NAME
		};
	}

	/**
	 * @description This method is use to return the list of Communication Template Attachments with Template Id
	 *
	 * @param templateId Id of the Communication Template
	 *
	 * @return List of Communication Template Attachments
	 */
	public static List<CMN_CommunicationTemplateAttachment__c> findByTemplateId(String templateId)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_TEMPLATE, new Set<String> {templateId}, getDefaultFields());
	}

	/**
	 * @description This method is use to return the list of Communication Template Attachments with Template Id
	 *
	 * @param attachmentIds Id of the Communication Template
	 *
	 * @return List of Communication Template Attachments
	 */
	public static List<CMN_CommunicationTemplateAttachment__c> findByAttachmentId(Set<Id> attachmentIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, attachmentIds, getDefaultFields());
	}

	/**
	 * @description Will return all Communication Template Attachments created by unit tests
	 *
	 * @return A list of Communication Template Attachments
	 */
	@TestVisible
	private static List<CMN_CommunicationTemplateAttachment__c> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
}