/**
 * @description The Base object for communication template selector class, this class must overridden by child classes
 * The class is responsible for querying the relevant information required for a template
 * Once retrieved it should provide the information transformed according the object and field mapping to a common structure
 *
 * @see CMN_DAL_BaseTemplateSelector_TEST @story ST-146934
 *
 * @author aakriti.a.goyal@accenture.com darrion.james.singh@accenture.com
 *
 * @date September 2021, July 2022
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public abstract inherited sharing class CMN_DAL_BaseTemplateSelector
{
	/**
	 * @description Papyrus-requested Date format
	 */
	private static final String DATE_FORMATTER = 'yyyyMMdd';
	/**
	 * @description Communication Settings to populate DTO_Document
	 */
	private static CMN_CommunicationSetting__mdt setting;
	/**
	 * @description Error message for when the class provided isn't a descendant of CMN_DAL_BaseTemplateSelector
	 */
	private static final String ERROR_INVALID_TYPE = 'Invalid Class Type for Name: {0}, a child class for CMN_DAL_BaseTemplateSelector is expected';
	/**
	 * @description Error message for when the className provided isn't associated to a class type either because the type isn't public or no class exists
	 */
	private static final String ERROR_NO_CLASS = 'No Accessible Class exists for Name: {0}';
	/**
	 * @description Error message when a template cannot be found with the given Id
	 */
	private static final String ERROR_NO_TEMPLATE_FOUND = 'No template found for the Id given';
	/**
	 * @description Error message when class is called without providing a template id
	 */
	private static final String ERROR_TEMPLATE_ID_BLANK = 'No Template Id provided.';
	/**
	 * @description Error message to be logged
	 */
	private static final String MISSING_FIELD_VALUE_MESSAGE = 'No value was fetched for the given field : {0}';
	/**
	 * @description Error message to be logged
	 */
	private static final String MISSING_FIELD_CODE_MESSAGE = 'No code was fetched for the given field : {0}';
	/**
	 * @description The communication Template provided to the selector
	 */
	protected CMN_CommunicationTemplate__c template;
	/**
	 * @description The optional Object Id provided to the selector
	 */
	protected Id objectId;
	/**
	 * @description The optional List of Parameter Ids provided to the selector
	 */
	protected List<Id> parameterIds;
	/**
	 * @description The map of SObject name to Sobject Definition
	 */
	protected Map<String, CMN_CommunicationTemplateObjectDef__c> mapObjectNameToDefinition = new Map<String, CMN_CommunicationTemplateObjectDef__c>();
	/**
	 * @description The map of SObject Definition and all of the fields to be queried in selector classes
	 */
	protected Map<CMN_CommunicationTemplateObjectDef__c, List<CMN_CommunicationTemplateObjectField__c>> mapObjectDefinitionToFields =
			new Map<CMN_CommunicationTemplateObjectDef__c, List<CMN_CommunicationTemplateObjectField__c>>();

	/**
	 * @description DTO containing data passed from a Flow Action
	 */

	public class CMN_DTO_CommunicationData
	{
		/**
		 * @description Email Type code
		 */
		public String emailType;
		/**
		 * @description Service Type code
		 */
		public String workType;
		/**
		 * @description Indicates if the recipient is Client/FA/Third Party
		 */
		public String recipientRole;
		/**
		 * @description Title of the recipient
		 */
		public String recipientTitle;
		/**
		 * @description Initials of the recipient
		 */
		public String recipientInitials;
		/**
		 * @description Surname of the recipient
		 */
		public String recipientSurname;
		/**
		 * @description The Communication Template Id that must be used (Mandatory)
		 */
		public Id templateId;
		/**
		 * @description The Id of an object that set context for all queries (Optional, if not required)
		 */
		public Id objectId;
		/**
		 * @description List of parameter Ids to be handled by the selector
		 */
		public List<Id> parameterIds;
		/**
		 * @description Comments added by the agent during the Send Email flow
		 */
		public String otherComments;
		/**
		 * @description Attachments selected by the agent during the Send Email flow
		 */
		public List<CMN_DTO_CommunicationAttachment> attachments;
		/**
		 * @description Indicates whether the flow action requested password protection for this communication
		 */
		public Boolean passwordProtect;
	}

	/**
	 * @description Instance containing the data passed in from the flow action
	 */
	public CMN_DTO_CommunicationData getDataWrapper;

	/**
	 * @description
	 * @param className The selector class name for retrieving template data
	 * @param dtoCommunicationData A wrapper class containing the data to populate the selector class
	 *
	 * @return A DTO contain the data correctly mapped to template sections and fields
	 */
	public static List<CMN_DTO_SendCommunicationRequest.DTO_Document> getData(String className, CMN_DTO_CommunicationData dtoCommunicationData)
	{
		return getInstance(className).execute(dtoCommunicationData);
	}

	/**
	 * @description Will return an instance of CMN_DAL_BaseTemplateSelector descendant based on the class name
	 *
	 * @param selectorName The class name to use when creating the object
	 *
	 * @return A newly created object, method will check that the className is valid otherwise exception will be thrown
	 */
	private static CMN_DAL_BaseTemplateSelector getInstance(String selectorName)
	{
		Type selectorType = Type.forName(selectorName);

		if(selectorType == null)
		{
			throw new TypeException(String.format(ERROR_NO_CLASS, new List<String> {selectorName}));
		}
		else
		{
			Object selector = selectorType.newInstance();

			if(selector instanceof CMN_DAL_BaseTemplateSelector)
			{
				return (CMN_DAL_BaseTemplateSelector)selector;
			}
			else
			{
				throw new TypeException(String.format(ERROR_INVALID_TYPE, new List<String> {selectorName}));
			}
		}
	}

	/**
	 * @description Will retrieve all the data required for the template, and transform it into a generic format
	 *
	 * @param dtoCommunicationData A wrapper class containing the data to populate the selector class
	 *
	 * @return A DTO contain the data correctly mapped to template sections and fields
	 */
	private List<CMN_DTO_SendCommunicationRequest.DTO_Document> execute(CMN_DTO_CommunicationData dtoCommunicationData)
	{
		this.getDataWrapper = dtoCommunicationData;
		this.objectId = dtoCommunicationData.objectId;
		this.parameterIds = dtoCommunicationData.parameterIds != null ? dtoCommunicationData.parameterIds : new List<Id>();
		setting = CMN_DAL_CommunicationSetting.getInstance();
		getMappingData(dtoCommunicationData.templateId);

		return getTemplateData();
	}

	/**
	 * @description Method will query all template related data and put into maps and relevant lists for use by descendant classes
	 * Method was made virtual in the "slim" event additional processing required in child classes
	 *
	 * @param templateId The Id of the template for which to get mapping information
	 */
	protected virtual void getMappingData(Id templateId)
	{
		if(String.isBlank(templateId))
		{
			throw new IllegalArgumentException(ERROR_TEMPLATE_ID_BLANK);
		}

		template = CMN_DAL_CommunicationTemplate.findById(templateId);

		if(template == null)
		{
			throw new IllegalArgumentException(ERROR_NO_TEMPLATE_FOUND);
		}

		// Query the Communication Template Object Map records to get the Object definitions
		List<CMN_CommunicationTemplateObjectMap__c> templateObjectMaps = CMN_DAL_CommTemplateObjectMap.findByCommunicationTemplate(templateId);
		Set<Id> objectDefinitionIds = CMN_UTIL_System.extractListIds(templateObjectMaps, CMN_DAL_CommTemplateObjectMap.FIELD_OBJECT_DEFINITION);

		// Query the Communication Template Object Definition records to get the Object names to be queried & create a map
		List<CMN_CommunicationTemplateObjectDef__c> templateObjectDefinitions = CMN_DAL_CommTemplateObjectDefinition.findByIds(objectDefinitionIds);

		Map<Id, CMN_CommunicationTemplateObjectDef__c> objectIdToDefinition = new Map<Id, CMN_CommunicationTemplateObjectDef__c>();
		for(CMN_CommunicationTemplateObjectDef__c objectDefinition : templateObjectDefinitions)
		{
			objectIdToDefinition.put(objectDefinition.Id, objectDefinition);
			mapObjectNameToDefinition.put(objectDefinition.CMN_ApiName__c, objectDefinition);
		}

		// Query the Communication Template Object Field records to get the field names all of the object definitions
		List<CMN_CommunicationTemplateObjectField__c> objectFields = CMN_DAL_CommTemplateObjectField.findByObjectDefinitions(objectIdToDefinition.keySet());

		// Create a map of SObject name & a list of the Field names to be queried
		createMapOfSobjectAndFields(objectIdToDefinition, objectFields);
	}

	/**
	 * @description Method used to create a map of object & the field names to be queried
	 *
	 * @param objectIdToDefinition Map of Sobject Id & the Object Definition record
	 * @param objectFields List of the communication template object field
	 */
	protected void createMapOfSobjectAndFields
			(
					Map<Id, CMN_CommunicationTemplateObjectDef__c> objectIdToDefinition,
					List<CMN_CommunicationTemplateObjectField__c> objectFields
			)
	{
		for(CMN_CommunicationTemplateObjectField__c field : objectFields)
		{
			CMN_CommunicationTemplateObjectDef__c objectDefinition = objectIdToDefinition.get(field.CMN_ObjectDefinition__c);
			List<CMN_CommunicationTemplateObjectField__c> fieldAPINames = mapObjectDefinitionToFields.get(objectDefinition);

			if(fieldAPINames == null)
			{
				fieldAPINames = new List<CMN_CommunicationTemplateObjectField__c>();
				mapObjectDefinitionToFields.put(objectDefinition, fieldAPINames);
			}
			fieldAPINames.add(field);
		}
	}

	/**
	 * @description Generic method used to query Sobject records with the specific fields & the provided condition
	 *
	 * @param objectName name of the object to be queried
	 * @param condition filter criteria to be applied on the query
	 *
	 * @return A List of the SObject records
	 */
	protected List<SObject> querySobjectRecords(String objectName, CMN_SOQL_Query.AndCondition condition)
	{
		CMN_CommunicationTemplateObjectDef__c objectDefinition = mapObjectNameToDefinition.get(objectName);

		// Create a set of all the field names to be used in the query
		Set<String> allFields = new Set<String>();
		if(mapObjectDefinitionToFields.get(objectDefinition) != null && !mapObjectDefinitionToFields.get(objectDefinition).isEmpty())
		{
			for(CMN_CommunicationTemplateObjectField__c field : mapObjectDefinitionToFields.get(objectDefinition))
			{
				allFields.add(field.Name);
			}
		}

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(allFields)
						.fromX(objectName)
						.whereX(condition);

		return Database.query(builder.toSoql());
	}

	/**
	 * @description Generic method used to construct the structure of the element
	 *
	 * @param objectDef the object definition SObject
	 * @param objectName name of the object
	 * @param sobjectRecords list of sobject records
	 *
	 * @return An element DTO
	 */
	protected CMN_DTO_SendCommunicationRequest.DTO_Element constructElement(CMN_CommunicationTemplateObjectDef__c objectDef,
			String objectName, List<SObject> sobjectRecords)
	{
		CMN_DTO_SendCommunicationRequest.DTO_Element dtoElement = new CMN_DTO_SendCommunicationRequest.DTO_Element();
		dtoElement.element = new List<CMN_DTO_SendCommunicationRequest.DTO_Element>();
		dtoElement.attributes = new List<CMN_DTO_SendCommunicationRequest.DTO_Attribute>();

		if(objectDef == null)
		{
			return dtoElement;
		}

		if(sobjectRecords.isEmpty())
		{
			dtoElement.name = objectDef.CMN_GroupingName__c;
		}
		else if(sobjectRecords.size() == 1)
		{
			dtoElement = createElement(objectDef.CMN_GroupingName__c, objectName, sobjectRecords.iterator().next());
		}
		else
		{
			dtoElement.name = objectDef.CMN_GroupingName__c;
			List<CMN_DTO_SendCommunicationRequest.DTO_Element> dtoChildElements = new List<CMN_DTO_SendCommunicationRequest.DTO_Element>();
			for(SObject so : sobjectRecords)
			{
				CMN_DTO_SendCommunicationRequest.DTO_Element element = new CMN_DTO_SendCommunicationRequest.DTO_Element();
				element = createElement(objectDef.CMN_Code__c, objectName, so);
				dtoChildElements.add(element);
			}
			dtoElement.element = dtoChildElements;
		}

		return dtoElement;
	}

	/**
	 * @description Constructs and populations DTO_Element from a Template object definition and a list of field data maps
	 *
	 * @param objectDef Template object definition
	 * @param objectName SObject API Name
	 * @param fieldsMaps List of field data maps
	 *
	 * @return SC_DTO_SendCommunicationRequest.DTO_Element
	 */
	protected CMN_DTO_SendCommunicationRequest.DTO_Element constructElement(CMN_CommunicationTemplateObjectDef__c objectDef, String objectName,
			List<Map<String, String>> fieldsMaps)
	{
		CMN_DTO_SendCommunicationRequest.DTO_Element dtoElement = new CMN_DTO_SendCommunicationRequest.DTO_Element();
		dtoElement.element = new List<CMN_DTO_SendCommunicationRequest.DTO_Element>();
		dtoElement.attributes = new List<CMN_DTO_SendCommunicationRequest.DTO_Attribute>();

		if(objectDef == null)
		{
			return dtoElement;
		}

		if(fieldsMaps.isEmpty())
		{
			dtoElement.name = objectDef.CMN_GroupingName__c;
		}
		else if(String.isBlank(objectDef.CMN_Code__c))
		{
			dtoElement = createElement(objectDef.CMN_GroupingName__c, objectName, fieldsMaps.iterator().next());
		}
		else
		{
			populateElementFromMaps(dtoElement, objectDef, fieldsMaps, objectName);
		}

		return dtoElement;
	}

	private void populateElementFromMaps(CMN_DTO_SendCommunicationRequest.DTO_Element dtoElement, CMN_CommunicationTemplateObjectDef__c objectDef,
			List<Map<String, String>> fieldsMaps, String objectName)
	{
		dtoElement.name = objectDef.CMN_GroupingName__c;
		List<CMN_DTO_SendCommunicationRequest.DTO_Element> dtoChildElements = new List<CMN_DTO_SendCommunicationRequest.DTO_Element>();
		for(Map<String, String> so : fieldsMaps)
		{
			CMN_DTO_SendCommunicationRequest.DTO_Element element = new CMN_DTO_SendCommunicationRequest.DTO_Element();
			element = createElement(objectDef.CMN_Code__c, objectName, so);
			dtoChildElements.add(element);
		}
		dtoElement.element = dtoChildElements;
		dtoElement.attributes = new List<CMN_DTO_SendCommunicationRequest.DTO_Attribute>();
	}

	/**
	 * @description
	 * @param objectDef Template object definition
	 * @param objectName SObject API Name
	 * @param fieldsMaps List of attachment field maps
	 *
	 * @return SC_DTO_SendCommunicationRequest.DTO_Element
	 */
	protected CMN_DTO_SendCommunicationRequest.DTO_Element constructElementFromAttachment(CMN_CommunicationTemplateObjectDef__c objectDef,
			String objectName, List<Map<String, String>> fieldsMaps)
	{
		CMN_DTO_SendCommunicationRequest.DTO_Element dtoElement = new CMN_DTO_SendCommunicationRequest.DTO_Element();
		dtoElement.element = new List<CMN_DTO_SendCommunicationRequest.DTO_Element>();
		dtoElement.attributes = new List<CMN_DTO_SendCommunicationRequest.DTO_Attribute>();

		if(objectDef == null)
		{
			return dtoElement;
		}

		if(fieldsMaps.isEmpty())
		{
			dtoElement.name = objectDef.CMN_GroupingName__c;
		}
		else
		{
			populateElementFromMaps(dtoElement, objectDef, fieldsMaps, objectName);
		}

		return dtoElement;
	}

	/**
	 * @description Generic method used to create element
	 *
	 * @param elementName name of the attribute
	 * @param sobjectName value of the attribute
	 * @param record sobject record
	 *
	 * @return An element
	 */
	protected CMN_DTO_SendCommunicationRequest.DTO_Element createElement(String elementName, String sobjectName, SObject record)
	{
		CMN_DTO_SendCommunicationRequest.DTO_Element dtoElement = new CMN_DTO_SendCommunicationRequest.DTO_Element();
		dtoElement.name = elementName;
		dtoElement.element = new List<CMN_DTO_SendCommunicationRequest.DTO_Element>();
		dtoElement.attributes = new List<CMN_DTO_SendCommunicationRequest.DTO_Attribute>();

		CMN_CommunicationTemplateObjectDef__c objectDefinition = mapObjectNameToDefinition.get(sobjectName);
		List<CMN_CommunicationTemplateObjectField__c> templateFields = mapObjectDefinitionToFields.get(objectDefinition);

		if(templateFields != null)
		{
			for(CMN_CommunicationTemplateObjectField__c field : templateFields)
			{
				setAttribute(dtoElement, field, CMN_UTIL_System.getFieldValue(record, field.Name));
			}
		}

		return dtoElement;
	}

	/**
	 * @description Creates DTO_Element structure when SObject list is not available
	 *
	 * @param elementName Element Name
	 * @param sobjectName SObject API name for element population
	 * @param record Map containing field-value pairs for element population
	 *
	 * @return SC_DTO_SendCommunicationRequest.DTO_Element
	 */
	protected CMN_DTO_SendCommunicationRequest.DTO_Element createElement(String elementName, String sobjectName, Map<String, String> record)
	{
		CMN_DTO_SendCommunicationRequest.DTO_Element dtoElement = new CMN_DTO_SendCommunicationRequest.DTO_Element();
		dtoElement.name = elementName;
		dtoElement.element = new List<CMN_DTO_SendCommunicationRequest.DTO_Element>();
		dtoElement.attributes = new List<CMN_DTO_SendCommunicationRequest.DTO_Attribute>();

		CMN_CommunicationTemplateObjectDef__c objectDefinition = mapObjectNameToDefinition.get(sobjectName);
		if(mapObjectDefinitionToFields.get(objectDefinition) != null && !mapObjectDefinitionToFields.get(objectDefinition).isEmpty())
		{
			for(CMN_CommunicationTemplateObjectField__c field : mapObjectDefinitionToFields.get(objectDefinition))
			{
				setAttribute(dtoElement, field, record.get(field.Name));
			}
		}

		return dtoElement;
	}

	/**
	 * @description Consolidates code for setting (adding) an attribute to the provided element
	 *
	 * @param dtoElement Element Name
	 * @param field Template field
	 * @param attributeValue The value of the attribute
	 */
	private void setAttribute(CMN_DTO_SendCommunicationRequest.DTO_Element dtoElement, CMN_CommunicationTemplateObjectField__c field, Object attributeValue)
	{
		if(attributeValue == null)
		{
			String message = String.format(MISSING_FIELD_VALUE_MESSAGE, new List<String> {field.Name});
			CMN_UTIL_Logger.error(message, 'CMN_DAL_BaseTemplateSelector.setAttribute');
		}
		else if(field.CMN_Code__c == null)
		{
			String message = String.format(MISSING_FIELD_CODE_MESSAGE, new List<String> {field.Name});
			CMN_UTIL_Logger.error(message, 'CMN_DAL_BaseTemplateSelector.setAttribute');
		}
		else
		{
			dtoElement.attributes.add(createAttribute(field.CMN_Code__c, attributeValue));
		}
	}

	/**
	 * @description Generic method used to create attribute
	 *
	 * @param attributeName name of the attribute
	 * @param attributeValue value of the attribute
	 *
	 * @return An attribute
	 */
	protected CMN_DTO_SendCommunicationRequest.DTO_Attribute createAttribute(String attributeName, Object attributeValue)
	{
		CMN_DTO_SendCommunicationRequest.DTO_Attribute attribute = new CMN_DTO_SendCommunicationRequest.DTO_Attribute();
		attribute.name = attributeName;

		if(attributeValue instanceof Boolean)
		{
			attribute.value = attributeValue.toString();
		}
		// CMN_UTIL_System.getFieldValue always returns a Date as a DateTime string, with the time as midnight. Thus, attributeValue will never be 'instanceof Date'
		else if(attributeValue instanceof Datetime)
		{
			attribute.value = ((Datetime)attributeValue).format(DATE_FORMATTER);
		}
		else
		{
			attribute.value = String.valueOf(attributeValue);
		}

		return attribute;
	}

	/**
	 * @description Method must be implemented in child classes; it will query data and transform it into relevant structure
	 *
	 * @return A generic structure containing the document data for the template
	 */
	protected virtual List<CMN_DTO_SendCommunicationRequest.DTO_Document> getTemplateData()
	{
		List<CMN_DTO_SendCommunicationRequest.DTO_Document> dtoDocuments = new List<CMN_DTO_SendCommunicationRequest.DTO_Document>();
		CMN_DTO_SendCommunicationRequest.DTO_Document document = new CMN_DTO_SendCommunicationRequest.DTO_Document();
		document.documentName = template.CMN_DocumentName__c;
		document.mimeType = setting?.CMN_MimeType__c;
		document.action = setting?.CMN_Action__c;
		document.passwordProtect = CMN_UTIL_Boolean.isTrue(this.getDataWrapper.passwordProtect);
		dtoDocuments.add(document);
		return dtoDocuments;
	}

	/**
	 * @description Derived Base Template Selector that is used to return the List of DTO elements for Communication API
	 */
	@TestVisible
	private class CMN_TEST_BaseTemplate extends CMN_DAL_BaseTemplateSelector
	{
		private List<CMN_DTO_SendCommunicationRequest.DTO_Document> elements = new List<CMN_DTO_SendCommunicationRequest.DTO_Document>();

		public override List<CMN_DTO_SendCommunicationRequest.DTO_Document> getTemplateData()
		{
			return elements;
		}

		public override void getMappingData(Id templateId)
		{
			super.getMappingData(templateId);
		}

		/**
		 * @description
		 * @param objectName SObject API name
		 * @param condition SOQL query condition to filter the query on
		 *
		 * @return List<SObject>
		 */
		public List<SObject> queryRecords(String objectName, CMN_SOQL_Query.AndCondition condition)
		{
			List<SObject> sObjects = querySobjectRecords(objectName, condition);
			return sObjects;
		}

		/**
		 * @description
		 * @param elementName DTO Element name
		 * @param objectName SObject API name for the list of SObject records
		 * @param sobjectRecords List of SObject records to populate the DTO_Element
		 *
		 * @return DTO_Element
		 */
		public CMN_DTO_SendCommunicationRequest.DTO_Element createElements(String elementName, String objectName, List<SObject> sobjectRecords)
		{
			CMN_CommunicationTemplateObjectDef__c objectDef = new CMN_CommunicationTemplateObjectDef__c();
			objectDef.CMN_GroupingName__c = elementName;
			CMN_DTO_SendCommunicationRequest.DTO_Element element = constructElement(objectDef, objectName, sobjectRecords);
			return element;
		}
	}
}