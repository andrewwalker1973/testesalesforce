/**
 * @description A selector class for retrieving data for templates that send communications to clients for outstanding documents (requirements)
 *
 * @see SC_DAL_OutstandingDocumentSelector_TEST @story ST-146934
 *
 * @author joson.van.beukering@accenture.com darrion.james.singh@accenture.com
 *
 * @date September 2021, May 2022
 */
public inherited sharing class SC_DAL_OutstandingDocumentSelector extends CMN_DAL_BaseTemplateSelector
{
	private static final String APPLICATION_PDF_STRING = 'application/pdf';
	private static final String ATTACHMENT_STRING = 'attachment';
	private static final String CONTENT_TYPE_STRING = 'contentType';
	private static final String EMAIL_TP = 'EMAIL_TP';
	private static final String FILENAME_STRING = 'fileName';
	@TestVisible
	private static final String FREE_TEXTS = 'OutstandingDocumentFreeText';
	@TestVisible
	private static final String FREE_TXT_FMT = 'FREE_TXT_FMT';
	private static final String FREE_TXT_FMT_PARAGRAPH = 'PARAGRAPH';
	@TestVisible
	private static final String FREE_TXT_TX = 'FREE_TXT_TX';
	private static final String MAIN_NAME = 'MAIN';
	private static final String OWNER_TITLE = 'OWNER_TITLE';
	private static final String RECIPIENT_INITS = 'RECIPIENT_INITS';
	private static final String RECIPIENT_ROLE = 'RECIPIENT_ROLE';
	private static final String RECIPIENT_SURNAME = 'RECIPIENT_SURNAME';
	private static final String RECIPIENT_TITLE = 'RECIPIENT_TITLE';
	@TestVisible
	private static final String SELECTOR_CLASS_NAME = SC_DAL_OutstandingDocumentSelector.class.getName();
	private static final String WORK_TP = 'WORK_TP';

	/**
	 * @description Contract section template object definition api name
	 */
	public static final String CONTRACTS_OBJECT_DEFINITION_API_NAME = 'OutstandingDocumentContracts';
	/**
	 * @description Indicator section template object definition api name
	 */
	public static final String INDICATORS_OBJECT_DEFINITION_API_NAME = 'OutstandingDocumentIndicators';
	/**
	 * @description Field name for contract number
	 */
	public static final String CONTRACT_NUMBER_TEMPLATE_OBJECT_FIELD_API_NAME = 'contractNumber';

	/**
	 * @description Will retrieve the required information for template and transform it into generic data sections
	 *
	 * @return A nested element structure
	 */
	protected override List<CMN_DTO_SendCommunicationRequest.DTO_Document> getTemplateData()
	{
		CMN_DTO_SendCommunicationRequest.DTO_Document singleDocument = super.getTemplateData().iterator().next();
		List<CMN_DTO_SendCommunicationRequest.DTO_Document> dtoDocuments = new List<CMN_DTO_SendCommunicationRequest.DTO_Document>();
		Case foundCase = SC_DAL_Case.findById(objectId);

		Set<String> statuses = new Set<String>
		{
				SC_DAL_DocumentChecklistItem.STATUS_NEW, SC_DAL_DocumentChecklistItem.STATUS_PENDING,
				SC_DAL_DocumentChecklistItem.STATUS_REJECTED
		};

		List<Object> objects = new List<String>(statuses);
		CMN_SOQL_Query.AndCondition andConditionDocuments = new CMN_SOQL_Query.AndCondition();
		andConditionDocuments.equalsX(SC_DAL_DocumentChecklistItem.FIELD_PARENT_ID, objectId);
		andConditionDocuments.inX(SC_DAL_DocumentChecklistItem.FIELD_STATUS, objects);
		List<DocumentChecklistItem> outstandingDocuments = (List<DocumentChecklistItem>)querySobjectRecords(SC_DAL_DocumentChecklistItem.OBJECT_NAME,
				andConditionDocuments);

		CMN_CommunicationTemplateObjectDef__c documentObjectDefinition = mapObjectNameToDefinition.get(SC_DAL_DocumentChecklistItem.OBJECT_NAME);
		CMN_CommunicationTemplateObjectDef__c caseObjectDefinition = mapObjectNameToDefinition.get(SC_DAL_Case.OBJECT_NAME);
		CMN_CommunicationTemplateObjectDef__c freeTextObjectDefinition = mapObjectNameToDefinition.get(FREE_TEXTS);
		CMN_CommunicationTemplateObjectDef__c indicatorObjectDefinition = mapObjectNameToDefinition.get(INDICATORS_OBJECT_DEFINITION_API_NAME);
		CMN_CommunicationTemplateObjectDef__c contractObjectDefinition = mapObjectNameToDefinition.get(CONTRACTS_OBJECT_DEFINITION_API_NAME);

		Map<String, String> indicators = new Map<String, String>
		{
				EMAIL_TP => getDataWrapper.emailType,
				WORK_TP => getDataWrapper.workType,
				RECIPIENT_ROLE => getDataWrapper.recipientRole
		};

		Map<String, String> freeTexts = new Map<String, String>
		{
				FREE_TXT_FMT => FREE_TXT_FMT_PARAGRAPH,
				FREE_TXT_TX => getDataWrapper.otherComments
		};

		Map<String, String> recipientFields = new Map<String, String>
		{
				RECIPIENT_TITLE => getSalutationLabel(getDataWrapper.recipientTitle),
				RECIPIENT_INITS => getDataWrapper.recipientInitials,
				RECIPIENT_SURNAME => getDataWrapper.recipientSurname
		};

		Map<String, String> ownerFields = new Map<String, String>
		{
				OWNER_TITLE => getSalutationLabel(foundCase.Account.Salutation)
		};

		List<Map<String, String>> attachments = new List<Map<String, String>>();
		Set<Id> attachmentIds = new Set<Id>();

		if(getDataWrapper.attachments != null)
		{
			for(CMN_DTO_CommunicationAttachment attachment : getDataWrapper.attachments)
			{
				attachments.add(new Map<String, String>
				{
						SC_DAL_DocumentChecklistItem.FIELD_NAME => attachment.definitionName,
						SC_DAL_DocumentChecklistItem.FIELD_REASON => attachment.reason
				});

				attachmentIds.add(attachment.attachmentId);
			}
		}

		List<SC_AssociatedContract__c> associatedContracts = SC_DAL_AssociatedContract.findByParent(objectId);
		Set<Id> associatedFinanceAccountIdSet = CMN_UTIL_System.extractListIds(associatedContracts, SC_DAL_AssociatedContract.FIELD_FINANCIAL_ACCOUNT);
		Set<Id> associatedInsurancePolicyIdSet = CMN_UTIL_System.extractListIds(associatedContracts, SC_DAL_AssociatedContract.FIELD_INSURANCE_POLICY);
		List<String> policyNumbers = CMN_UTIL_System.extractListValues(SC_DAL_InsurancePolicy.findById(associatedInsurancePolicyIdSet),
				CMN_DAL_SObjectDomain.FIELD_NAME);
		List<String> faNumbers = CMN_UTIL_System.extractListValues(SC_DAL_FinancialAccount.findById(associatedFinanceAccountIdSet),
				SC_DAL_FinancialAccount.FIELD_FINANCIAL_ACCOUNT_NUMBER);

		List<String> contractNumbers = new List<String>(policyNumbers);
		contractNumbers.addAll(faNumbers);

		List<Map<String, String>> contractMaps = new List<Map<String, String >>();
		for(String contractNumber : contractNumbers)
		{
			contractMaps.add(new Map<String, String>
			{
					CONTRACT_NUMBER_TEMPLATE_OBJECT_FIELD_API_NAME => contractNumber
			});
		}

		CMN_DTO_SendCommunicationRequest.DTO_Element mainElement = new CMN_DTO_SendCommunicationRequest.DTO_Element();
		mainElement.name = MAIN_NAME;
		List<CMN_DTO_SendCommunicationRequest.DTO_Element> mainSubElements = new List<CMN_DTO_SendCommunicationRequest.DTO_Element>();
		CMN_DTO_SendCommunicationRequest.DTO_Element fieldsElement = constructElement(caseObjectDefinition, SC_DAL_Case.OBJECT_NAME, new List<SObject> {foundCase});

		for(String recipientFieldKey : recipientFields.keySet())
		{
			fieldsElement.attributes.add(createAttribute(recipientFieldKey, recipientFields.get(recipientFieldKey)));
		}

		for(String ownerFieldKey : ownerFields.keySet())
		{
			fieldsElement.attributes.add(createAttribute(ownerFieldKey, ownerFields.get(ownerFieldKey)));
		}

		mainSubElements.add(fieldsElement);

		CMN_DTO_SendCommunicationRequest.DTO_Element docElement = constructElement(documentObjectDefinition, SC_DAL_DocumentChecklistItem.OBJECT_NAME,
				outstandingDocuments);
		CMN_DTO_SendCommunicationRequest.DTO_Element attachmentElement = constructElementFromAttachment(documentObjectDefinition,
				SC_DAL_DocumentChecklistItem.OBJECT_NAME, attachments);
		docElement.element.addAll(attachmentElement.element);
		mainSubElements.add(docElement);

		mainSubElements.add(constructElement(indicatorObjectDefinition, INDICATORS_OBJECT_DEFINITION_API_NAME, new List<Map<String, String>> {indicators}));
		mainSubElements.add(constructElement(freeTextObjectDefinition, FREE_TEXTS, new List<Map<String, String>> {freeTexts}));
		mainSubElements.add(constructElement(contractObjectDefinition, CONTRACTS_OBJECT_DEFINITION_API_NAME, contractMaps));

		mainElement.element = mainSubElements;
		mainElement.attributes = new List<CMN_DTO_SendCommunicationRequest.DTO_Attribute>();
		List<CMN_DTO_SendCommunicationRequest.DTO_Element> dtoElements = new List<CMN_DTO_SendCommunicationRequest.DTO_Element> {mainElement};
		singleDocument.element = dtoElements;
		dtoDocuments.add(singleDocument);

		List<CMN_CommunicationTemplateAttachment__c> foundAttachments = CMN_DAL_CommunicationTemplateAttachment.findByAttachmentId(attachmentIds);

		for(CMN_CommunicationTemplateAttachment__c foundAttachment : foundAttachments)
		{
			CMN_DTO_SendCommunicationRequest.DTO_Document formDocument = singleDocument.clone();
			formDocument.documentName = foundAttachment.SC_Definition__r.SC_Code__c;
			formDocument.passwordProtect = false;
			CMN_DTO_SendCommunicationRequest.DTO_Element element = new CMN_DTO_SendCommunicationRequest.DTO_Element();
			element.name = ATTACHMENT_STRING;

			CMN_DTO_SendCommunicationRequest.DTO_Attribute fileName = new CMN_DTO_SendCommunicationRequest.DTO_Attribute();
			fileName.name = FILENAME_STRING;
			fileName.value = foundAttachment.SC_Definition__r.Name;
			CMN_DTO_SendCommunicationRequest.DTO_Attribute contentType = new CMN_DTO_SendCommunicationRequest.DTO_Attribute();
			contentType.name = CONTENT_TYPE_STRING;
			contentType.value = APPLICATION_PDF_STRING;
			element.attributes = new List<CMN_DTO_SendCommunicationRequest.DTO_Attribute> {fileName, contentType};

			formDocument.element = new List<CMN_DTO_SendCommunicationRequest.DTO_Element> {element};
			dtoDocuments.add(formDocument);
		}

		return dtoDocuments;
	}

	/**
	 * @description Will query picklist metadata for the label of the Salutation picklist
	 *
	 * @param salutationValue API Name of the picklist item
	 *
	 * @return The label of the picklist item
	 */
	private String getSalutationLabel(String salutationValue)
	{
		Map<String, String> salutationValueToLabelMap = new Map<String, String>();
		List<PicklistEntry> entries = CMN_UTIL_System.getPicklistEntries(CMN_DAL_Account.OBJECT_NAME, Account.Salutation.getDescribe().getLocalName());
		for(PicklistEntry entry : entries)
		{
			salutationValueToLabelMap.put(entry.getValue(), entry.getLabel());
		}

		return salutationValueToLabelMap.get(salutationValue);
	}
}