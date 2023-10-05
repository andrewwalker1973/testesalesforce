/**
 * @description Selector class for Communication Template
 *
 * @see CMN_CommunicationTemplate__c
 *
 * @author nihal.desai@accenture.com aakriti.a.goyal@accenture.com
 *
 * @date August 2021, July 2022
 */
public inherited sharing class CMN_DAL_CommunicationTemplate
{
	private static final String OBJECT_NAME = CMN_CommunicationTemplate__c.SObjectType.getDescribe().getLocalName();

	/**
	 * @description stores the label to map Date of Birth to the passport types
	 */
	public static final String BIRTH_DATE_TYPE = 'Date of Birth';
	/**
	 * @description stores the label to map Company Registration Number to the passport types
	 */
	public static final String COMPANY_REGISTRATION_NUMBER_TYPE = 'Company Registration Number';
	/**
	 * @description stores the label to map SA Id Number to the passport types
	 */
	public static final String IDENTIFICATION_NUMBER_TYPE = 'South African ID Number';
	/**
	 * @description stores the label to map Passport Number to the passport types
	 */
	public static final String PASSPORT_NUMBER_TYPE = 'Passport Number';
	/**
	 * @description stores the label to map Trust Registration Number to the passport types
	 */
	public static final String TRUST_REGISTRATION_NUMBER = 'Trust Registration Number';

	/**
	 * @description Map of field api name & password type to be sent with communication API
	 */
	public static final Map<String, String> PASSWORD_TYPES = new Map<String, String>
	{
			BIRTH_DATE_TYPE => 'DOB',
			COMPANY_REGISTRATION_NUMBER_TYPE => 'CO_REG',
			IDENTIFICATION_NUMBER_TYPE => 'SA_ID',
			PASSPORT_NUMBER_TYPE => 'PASSPORT',
			TRUST_REGISTRATION_NUMBER => 'TRST_REG'
	};

	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of Communication Template fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_CommunicationTemplate__c.CMN_APIName__c.getDescribe().getLocalName(),
				CMN_CommunicationTemplate__c.CMN_Code__c.getDescribe().getLocalName(),
				CMN_CommunicationTemplate__c.CMN_CommunicationsLabel__c.getDescribe().getLocalName(),
				CMN_CommunicationTemplate__c.CMN_DocumentName__c.getDescribe().getLocalName(),
				CMN_CommunicationTemplate__c.CMN_SelectorClassName__c.getDescribe().getLocalName(),
				CMN_CommunicationTemplate__c.Name.getDescribe().getLocalName(),
				CMN_CommunicationTemplate__c.OwnerId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will retrieve all communication templates
	 *
	 * @return A list of Communication Templates
	 */
	@TestVisible
	private static List<CMN_CommunicationTemplate__c> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description Will retrieve a template by its Id
	 *
	 * @param templateId The id on which to query
	 *
	 * @return Either null or the template
	 */
	public static CMN_CommunicationTemplate__c findById(Id templateId)
	{
		return (CMN_CommunicationTemplate__c)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, templateId, getDefaultFields());
	}

	/**
	 * @description Will retrieve a template by the set of Ids
	 *
	 * @param templateIds The set of ids on which to query
	 *
	 * @return List of items
	 */
	public static List<CMN_CommunicationTemplate__c> findByIds(Set<Id> templateIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, templateIds, getDefaultFields());
	}

	/**
	 * @description Will retrieve a template by its Selector name
	 *
	 * @param name The CMN_SelectorClassName__c class name
	 *
	 * @return Either null or the template
	 */
	public static CMN_CommunicationTemplate__c findBySelectorClassName(String name)
	{
		return (CMN_CommunicationTemplate__c)CMN_DAL_SObjectSelector.findByField(CMN_CommunicationTemplate__c.SObjectType,
				CMN_CommunicationTemplate__c.CMN_SelectorClassName__c, name, getDefaultFields(), true);
	}

	/**
	 * @description Will retrieve a template by its code
	 *
	 * @param templateCode The code for the template
	 *
	 * @return Either null or the template
	 */
	public static CMN_CommunicationTemplate__c findByTemplateCode(String templateCode)
	{
		return (CMN_CommunicationTemplate__c)CMN_DAL_SObjectSelector.findByField(CMN_CommunicationTemplate__c.SObjectType,
				CMN_CommunicationTemplate__c.CMN_Code__c, templateCode, getDefaultFields(), true);
	}
}