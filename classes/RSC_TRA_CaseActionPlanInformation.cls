/**
 * @description Trigger Action to ensure Action Plan for a Case Service Type is processed and check list items are created
 *
 * @see RSC_TRG_Case @story ST-146010
 * @see RSC_TRA_CaseActionPlanInformation_TEST
 *
 * @author jayanth.kumar.s@accenture.com jason.van.beukering@accenture.com
 *
 * @date December 2021
 */
public inherited sharing class RSC_TRA_CaseActionPlanInformation extends CMN_TRA_BaseObject implements CMN_TRA_Interfaces.CMN_INT_AfterInsert, CMN_TRA_Interfaces.CMN_INT_AfterUpdate
{
	private List<Case> casesToBeProcessed = new List<Case>();
	private Map<Id, DocumentChecklistItem> templateItemToCheckListItemMap = new Map<Id, DocumentChecklistItem>();
	private Map<Id, Set<Id>> caseToDocumentTypeIdMap = new Map<Id, Set<Id>>();
	private Map<Id, Set<Id>> templateToItemIdMap = new Map<Id, Set<Id>>();

	/**
	 * @description Context method will be called after insertion of Object.
	 *
	 * @param newCases To store the list of Case
	 */
	public void afterInsert(List<Case> newCases)
	{
		upsertDocumentsOnCase(newCases, null);
	}

	/**
	 * @description Context method will be called after updating the Object.
	 *
	 * @param newCases To store the new value for the list of Case
	 * @param oldCases To store the old value for the list of Case
	 */
	public void afterUpdate(List<Case> newCases, List<Case> oldCases)
	{
		upsertDocumentsOnCase(newCases, oldCases);
	}

	/**
	 * @description Context method will be called after insertion of Object.
	 *
	 * @param newCases A list of updated or inserted Cases
	 * @param oldCases A list of Cases the old values for cases
	 */
	private void upsertDocumentsOnCase(List<Case> newCases, List<Case> oldCases)
	{
		Id retailCaseRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Case.SObjectType, SC_DAL_Case.RT_RETAIL);

		Set<Id> caseIdsToProcess = new Set<Id>();
		Set<Id> templateIds = new Set<Id>();

		for(Case newCase : newCases)
		{
			//Only process if they are of the correct record type and they have a service type associated to them
			if(
					newCase.RecordTypeId == retailCaseRecordTypeId &&
							String.isNotBlank(newCase.RSC_ServiceType__c) &
							String.isNotBlank(newCase.RSC_ServiceTypeActionPlanTemplateId__c))
			{
				if(Trigger.isInsert || (!newCase.RSC_ServiceType__c.equals(((Case)Trigger.oldMap.get(newCase.Id)).RSC_ServiceType__c)))
				{
					caseIdsToProcess.add(newCase.Id);
					casesToBeProcessed.add(newCase);
					templateIds.add(newCase.RSC_ServiceTypeActionPlanTemplateId__c);
				}
			}
		}

		if(!casesToBeProcessed.isEmpty())
		{
			getActionPlanTemplateDetails(templateIds);

			//If none of the action plan templates have any items, then don't continue processing
			if(!templateItemToCheckListItemMap.isEmpty())
			{
				populateCaseCheckListItemMap(caseIdsToProcess);
				insertCheckListItems();
			}
		}
	}

	/**
	 * @description This method is used to get Map of Case Id and Document check list type map
	 *
	 * @param caseIds A list of Case Ids to process
	 */
	private void populateCaseCheckListItemMap(Set<Id> caseIds)
	{
		List<DocumentChecklistItem> existingCheckListItems = SC_DAL_DocumentChecklistItem.findByParent(caseIds);

		for(DocumentChecklistItem checklistItem : existingCheckListItems)
		{
			Set<Id> newItems = caseToDocumentTypeIdMap.get(checklistItem.ParentRecordId);

			if(newItems == null)
			{
				newItems = new Set<Id>();
				caseToDocumentTypeIdMap.put(checklistItem.ParentRecordId, newItems);
			}

			newItems.add(checklistItem.DocumentTypeId);
		}
	}

	/**
	 * @description Method to retrieve the Action Plan Template Item details
	 *
	 * @param templateIds List of Ids to query against
	 */
	private void getActionPlanTemplateDetails(Set<Id> templateIds)
	{
		List<ActionPlanTemplateItem> foundTemplateItems = SC_DAL_ActionPlanTemplateItem.findByTemplateId(templateIds);

		if(!foundTemplateItems.isEmpty())
		{
			List<ActionPlanTemplateItemValue> foundTemplateItemValues = SC_DAL_ActionPlanTemplateItemValue.findByTemplateId(templateIds);

			if(!foundTemplateItemValues.isEmpty())
			{
				populateTemplateToItemMap(foundTemplateItems);
				populateTemplateItemToCheckListItemMap(foundTemplateItemValues);
			}
		}
	}

	/**
	 * @description Insert check list items for the template for each of the cases, only insert items that don't already exist
	 */
	private void insertCheckListItems()
	{
		List<DocumentChecklistItem> checkListItemsToInsert = new List<DocumentChecklistItem>();

		Id checkListItemRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(DocumentChecklistItem.SObjectType, SC_DAL_DocumentChecklistItem.RT_CASE_DOCUMENT);
		DocumentType authorizationType = SC_DAL_DocumentType.findByDeveloperName(new Set<String> {SC_DAL_DocumentType.LETTER_OF_AUTHORITY_CODE}).iterator().next();

		for(Case caseToBeProcessed : casesToBeProcessed)
		{
			Set<Id> templateItemIds = templateToItemIdMap.get(caseToBeProcessed.RSC_ServiceTypeActionPlanTemplateId__c);

			if(templateItemIds != null)
			{
				Set<Id> existingDocumentTypeIds = caseToDocumentTypeIdMap.get(caseToBeProcessed.Id);

				for(DocumentChecklistItem missingChecklistItem : findMissingCheckListItems(templateItemIds, existingDocumentTypeIds))
				{
					DocumentChecklistItem checklistItemToInsert = missingChecklistItem.clone(false, true);

					checklistItemToInsert.ParentRecordId = caseToBeProcessed.Id;
					checklistItemToInsert.RecordTypeId = checkListItemRecordTypeId;

					if(SC_DAL_Case.REQUESTER_TYPE_CUSTOMER.equals(caseToBeProcessed.SC_RequesterType__c) && checklistItemToInsert.DocumentTypeId == authorizationType.Id)
					{
						checklistItemToInsert.IsRequired = false;
					}
					else
					{
						checklistItemToInsert.IsRequired = true;
					}

					checkListItemsToInsert.add(checklistItemToInsert);
				}
			}
		}

		CMN_DAL_SObjectDomain.insertDBObjects(checkListItemsToInsert);
	}

	/**
	 * @description method used to get the ActionPlanTemplateItem map associated with ActionPlan Template
	 *
	 * @param templateItems List of Action plan templates associated with service type
	 */
	private void populateTemplateToItemMap(List<ActionPlanTemplateItem> templateItems)
	{
		for(ActionPlanTemplateItem templateItem : templateItems)
		{
			Set<Id> templateItemIds = templateToItemIdMap.get(templateItem.ActionPlanTemplateVersion.ActionPlanTemplate.Id);

			if(templateItemIds == null)
			{
				templateItemIds = new Set<Id>();
				templateToItemIdMap.put(templateItem.ActionPlanTemplateVersion.ActionPlanTemplate.Id, templateItemIds);
			}

			templateItemIds.add(templateItem.Id);
		}
	}

	/**
	 * @description method used to get the DocumentChecklistItems associated with ActionPlan Template
	 *
	 * @param foundTemplateItemValues List of action plan template item associated with action plan templates
	 */
	private void populateTemplateItemToCheckListItemMap(List<ActionPlanTemplateItemValue> foundTemplateItemValues)
	{
		for(ActionPlanTemplateItemValue foundTemplateItemValue : foundTemplateItemValues)
		{
			DocumentChecklistItem checklistItem = templateItemToCheckListItemMap.get(foundTemplateItemValue.ActionPlanTemplateItemId);

			if(checklistItem == null)
			{
				checklistItem = new DocumentChecklistItem();
				templateItemToCheckListItemMap.put(foundTemplateItemValue.ActionPlanTemplateItemId, checklistItem);
			}

			if(SC_DAL_Case.ENTITY_DOCUMENT_NAME.equals(foundTemplateItemValue.ItemEntityFieldName))
			{
				checklistItem.Name = foundTemplateItemValue.ValueLiteral;
			}
			else
			{
				checklistItem.DocumentTypeId = foundTemplateItemValue.ValueLiteral;
			}
		}
	}

	/**
	 * @description This method is used to check if the mandatory documents are already part of the existing documents on case
	 *
	 * @param templateItemIds The list of template Item ids
	 * @param existingDocumentTypeIds The list of documents already existing on case
	 *
	 * @return The final List of Items to be inserted after comparing the mandatory items and existing items
	 */
	private List<DocumentChecklistItem> findMissingCheckListItems(Set<Id> templateItemIds, Set<Id> existingDocumentTypeIds)
	{
		List<DocumentChecklistItem> missingCheckListItems = new List<DocumentChecklistItem>();

		for(Id checkListItemId : templateItemIds)
		{
			DocumentChecklistItem checkListItem = templateItemToCheckListItemMap.get(checkListItemId);

			if(checkListItem != null && (existingDocumentTypeIds == null || !existingDocumentTypeIds.contains(checkListItem.DocumentTypeId)))
			{
				missingCheckListItems.add(checkListItem);
			}
		}

		return missingCheckListItems;
	}
}