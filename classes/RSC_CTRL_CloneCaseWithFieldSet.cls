/**
 * @description Controller used to Clone Case using fields from Field set
 *
 * @see RSC_CTRL_CloneCaseWithFieldSet_TEST @story ST-141793, ST-267789, ST-348797, ST-399878
 *
 * @author vijay.jayswal@accenture.com, aditya.kumar.nanda@accenture.com
 *
 * @date September 2022, April 2023
 */
public inherited sharing class RSC_CTRL_CloneCaseWithFieldSet
{
	private static final String FIELD_ACCOUNT_LABEL_ID = Case.AccountId.getDescribe().getLabel();
	private static final String FIELD_CLIENT_ID = 'Client';

	/**
	 * @description This method is used to get the fields from FieldSet
	 *
	 * @param caseId The parent case Id
	 *
	 * @return Wrapper list of fields record
	 */
	@AuraEnabled
	public static List<CMN_CTRL_FieldSet.DTO_FieldSetMember> getFieldSetMember(Id caseId)
	{
		Case newCase = SC_DAL_Case.findById(caseId);
		List<CMN_CTRL_FieldSet.DTO_FieldSetMember> fieldSetMembers = getEmptyFieldSetMembers();

		if(newCase != null)
		{
			for(CMN_CTRL_FieldSet.DTO_FieldSetMember fieldSetMember : fieldSetMembers)
			{
				fieldSetMember.fieldValue = String.valueOf(newCase.get(fieldSetMember.fieldAPIName));
			}
		}

		return fieldSetMembers;
	}

	/**
	 * @description Returns a list of fieldset dto objects that have api names and label populate, but no value.
	 *
	 * @return List of CMN_CTRL_FieldSet.DTO_FieldSetMember
	 */
	@AuraEnabled(Cacheable=true)
	@SuppressWarnings('PMD.CognitiveComplexity')
	public static List<CMN_CTRL_FieldSet.DTO_FieldSetMember> getEmptyFieldSetMembers()
	{
		List<CMN_CTRL_FieldSet.DTO_FieldSetMember> dtoFieldSetMembers = new List<CMN_CTRL_FieldSet.DTO_FieldSetMember>();

		Set<String> mandatoryFields = new Set<String>();

		mandatoryFields.add(SC_DAL_Case.FIELD_ORIGIN);
		mandatoryFields.add(SC_DAL_Case.FIELD_ACCOUNT_ID);
		mandatoryFields.add(SC_DAL_Case.FIELD_REQUESTER_TYPE);
		mandatoryFields.add(SC_DAL_Case.FIELD_REQUESTER_NAME);
		mandatoryFields.add(SC_DAL_Case.FIELD_REQUESTER_EMAIL);
		mandatoryFields.add(SC_DAL_Case.FIELD_REQUESTER_MOBILE);
		mandatoryFields.add(SC_DAL_Case.FIELD_REQUESTER_PHONE);

		FieldSet fieldsToUse;

		Set<String> fieldSetNames = new Set<String> ();
		fieldSetNames.add(SC_DAL_Case.FIELD_SET_CLONE_CASE);
		fieldSetNames.add(SC_DAL_Case.FIELD_SET_REQUESTER_FIELDS);

		CMN_UTIL_SObjectDescribe objectDescribe = CMN_UTIL_SObjectDescribe.getDescribe(Case.SObjectType);
		Map<String, FieldSet> fieldSetMap = objectDescribe.getFieldSetsMap();
		Set<String> requiredFields = new Set<String>();

		for(String fieldSetName : fieldSetNames)
		{
			fieldsToUse = fieldSetMap.get(fieldSetName);
			if(fieldsToUse != null)
			{
				for(FieldSetMember member : fieldsToUse.getFields())
				{
					CMN_CTRL_FieldSet.DTO_FieldSetMember dtoFieldSetMember = new CMN_CTRL_FieldSet.DTO_FieldSetMember();
					requiredFields.add(member.getFieldPath());

					String fieldPath = member.getFieldPath();
					SObjectField fieldToMap = objectDescribe.getField(fieldPath);

					if(fieldToMap != null)
					{
						dtoFieldSetMember.fieldLabel = member.getLabel() == FIELD_ACCOUNT_LABEL_ID ? FIELD_CLIENT_ID : member.getLabel();
						dtoFieldSetMember.fieldSetAPIName = fieldsToUse.getName();
						dtoFieldSetMember.fieldAPIName = member.getFieldPath();
						dtoFieldSetMember.fieldValue = CMN_UTIL_String.EMPTY;

						if(mandatoryFields.contains(dtoFieldSetMember.fieldAPIName))
						{
							dtoFieldSetMember.isRequired = true;
						}

						dtoFieldSetMembers.add(dtoFieldSetMember);
					}

				}
			}
		}

		return dtoFieldSetMembers;
	}

	/**
	 * @description Method used to bypass the sharing rule as the agents do not have access to create the case records.
	 */
	private without sharing class BypassSharingProxy
	{
		private void commitWork(CMN_DAL_SObjectUnitOfWork unitOfWork)
		{
			unitOfWork.commitWork();
		}
	}

	/**
	 * @description Will retrieve all vaulted documents for the given record
	 *
	 * @param recordId The Id of the record to which the Documents are linked
	 *
	 * @return A list of documents from DocumentChecklistItem
	 */
	@AuraEnabled(Cacheable=true)
	public static List<DocumentChecklistItem> getDocuments(Id recordId)
	{
		return SC_DAL_DocumentChecklistItem.findByParent(recordId);
	}

	/**
	 * @description method is used to get assignable queue Id if selected service type of case is assignable
	 *
	 * @param serviceTypeId The Id of the selected service type on case
	 *
	 * @return assignable queue Id
	 */
	@AuraEnabled(Cacheable=true)
	public static Id getAssignableCaseQueueId(Id serviceTypeId)
	{
		Id queueId;
		SC_ServiceType__c serviceType = SC_DAL_ServiceType.findById(serviceTypeId);
		if(serviceType?.SC_Assignable__c == true)
		{
			queueId = SC_DAL_Group.getAssignableCasesQueue()?.Id;
		}

		return queueId;
	}

	/**
	 * @description Creates case and links associated policies. Will not commit to DB if any operation fails.
	 *
	 * @param newCase New case object
	 * @param selectedPolicyIds List of policy Ids (contracts) to link
	 *
	 * @return New Case Id
	 */
	@AuraEnabled
	public static Id createCase(Case newCase, List<Id> selectedPolicyIds)
	{
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(new List<SObjectType>
		{
				Case.SObjectType, SC_AssociatedContract__c.SObjectType
		});

		unitOfWork.registerNew(newCase);

		for(SC_AssociatedContract__c associatedContract : RSC_DAL_TestDataFactory.createNewContracts(selectedPolicyIds))
		{
			unitOfWork.registerNew(associatedContract, SC_AssociatedContract__c.SC_Case__c, newCase);
		}

		new BypassSharingProxy().commitWork(unitOfWork);

		return newCase.Id;
	}

	/**
	 * @description This method is used to clone the case record. Will not commit to DB if any operation fails.
	 *
	 * @param existingCase Case to clone
	 * @param selectedPolicyIds List of contracts to link
	 * @param checklistItems List of document checklist items to be created
	 * @param isRelatedToParentCase Places original case on hold
	 *
	 * @return Wrapper list of fields record
	 */
	@AuraEnabled
	public static String cloneRecord(Case existingCase, List<Id> selectedPolicyIds, List<DocumentChecklistItem> checklistItems, Boolean isRelatedToParentCase)
	{
		Savepoint savepoint = Database.setSavepoint();
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(new List<SObjectType>
		{
				Case.SObjectType, SC_AssociatedContract__c.SObjectType, DocumentChecklistItem.SObjectType
		});
		Case existingCaseClone = existingCase.clone(false, true);

		unitOfWork.registerNew(existingCaseClone);

		if(CMN_UTIL_Boolean.isTrue(isRelatedToParentCase))
		{
			unitOfWork.registerDirty(new Case(Id = existingCase.Id, SC_SubStatus__c = SC_DAL_Case.SUB_STATUS_ON_HOLD));
		}

		for(SC_AssociatedContract__c associatedContract : RSC_DAL_TestDataFactory.createNewContracts(selectedPolicyIds))
		{
			unitOfWork.registerNew(associatedContract, SC_AssociatedContract__c.SC_Case__c, existingCaseClone);
		}

		new BypassSharingProxy().commitWork(unitOfWork);
		unitOfWork.clear();
		try
		{
			for(DocumentChecklistItem checklistItem : getDocumentsForUpsert(existingCaseClone.Id, checklistItems))
			{
				unitOfWork.registerChange(checklistItem);
			}

			new BypassSharingProxy().commitWork(unitOfWork);
		}
		catch(Exception e)
		{
			Database.rollback(savepoint);
			throw e;
		}

		return existingCaseClone.Id;
	}

	/**
	 * @description Populates DocumentChecklistItem objects with relevant values and updates existing document objects with
	 * latest information that is sent from the UI
	 *
	 * @param cloneCaseId Id of the new cloned case
	 * @param selectedParentChecklistItems List of DocumentChecklistItem objects that were selected from the UI
	 *
	 * @return List of DocumentChecklistItem objects
	 */
	private static List<DocumentChecklistItem> getDocumentsForUpsert(Id cloneCaseId, List<DocumentChecklistItem> selectedParentChecklistItems)
	{
		List<DocumentChecklistItem> newCloneCaseChecklistItems = new List<DocumentChecklistItem>();
		List<DocumentChecklistItem> documentTypeExistingOnParentChecklistItems = new List<DocumentChecklistItem>();
		List<DocumentChecklistItem> checklistItems = new List<DocumentChecklistItem>();
		selectedParentChecklistItems = selectedParentChecklistItems == null ? new List<DocumentChecklistItem>() : selectedParentChecklistItems;

		if(!selectedParentChecklistItems.isEmpty())
		{
			List<DocumentChecklistItem> existingCloneCaseChecklistItems = SC_DAL_DocumentChecklistItem.findByParent(cloneCaseId);
			List<Id> existingCloneCaseDocumentTypeIds =
					new List<Id>(CMN_UTIL_System.extractListIds(existingCloneCaseChecklistItems, SC_DAL_DocumentChecklistItem.FIELD_DOCUMENT_TYPE_ID));

			for(DocumentChecklistItem parentChecklistItem : selectedParentChecklistItems)
			{
				if(existingCloneCaseDocumentTypeIds.contains(parentChecklistItem.DocumentTypeId))
				{
					documentTypeExistingOnParentChecklistItems.add(parentChecklistItem);
				}
				else
				{
					newCloneCaseChecklistItems.add(parentChecklistItem);
				}
			}

			Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(DocumentChecklistItem.SObjectType, SC_DAL_DocumentChecklistItem.RT_CASE_DOCUMENT);
			for(DocumentChecklistItem newCloneCaseChecklistItem : newCloneCaseChecklistItems)
			{
				newCloneCaseChecklistItem.ParentRecordId = cloneCaseId;
				newCloneCaseChecklistItem.RecordTypeId = recordTypeId;
			}

			for(DocumentChecklistItem documentTypeExistingOnParentChecklistItem : documentTypeExistingOnParentChecklistItems)
			{
				DocumentChecklistItem existingCloneCaseChecklistItem = (DocumentChecklistItem)CMN_UTIL_System.findWhere(
						existingCloneCaseChecklistItems, SC_DAL_DocumentChecklistItem.FIELD_DOCUMENT_TYPE_ID,
						documentTypeExistingOnParentChecklistItem.DocumentTypeId).iterator().next();
				existingCloneCaseChecklistItem.AW_DateVaulted__c = documentTypeExistingOnParentChecklistItem.AW_DateVaulted__c;
				existingCloneCaseChecklistItem.CMN_VaultedId__c = documentTypeExistingOnParentChecklistItem.CMN_VaultedId__c;
				existingCloneCaseChecklistItem.SC_UploadedWithCase__c = documentTypeExistingOnParentChecklistItem.SC_UploadedWithCase__c;
				existingCloneCaseChecklistItem.AW_Vaulted__c = documentTypeExistingOnParentChecklistItem.AW_Vaulted__c;
				checklistItems.add(existingCloneCaseChecklistItem);
			}
		}

		checklistItems.addAll(newCloneCaseChecklistItems);
		return checklistItems;
	}
	/**
	 * @description Returns a list of fieldset dto objects that have api names and label populate, but no value.
	 *
	 * @param mapOfObjectsFieldsSet object name and list of field set name.
	 *
	 * @return List of CMN_CTRL_FieldSet.DTO_FieldSetMember
	 */
	@AuraEnabled(Cacheable=true)
	public static List<CMN_CTRL_FieldSet.DTO_FieldSetMember> getAdditionalSectionFieldSet(Map<String, List<String>> mapOfObjectsFieldsSet)
	{
		List<CMN_CTRL_FieldSet.DTO_FieldSetMember> dtoFieldSetMembers = new List<CMN_CTRL_FieldSet.DTO_FieldSetMember>();
		for(String objectName : mapOfObjectsFieldsSet.keySet())
		{
			populateMembersDto(objectName, mapOfObjectsFieldsSet, dtoFieldSetMembers);
		}
		return dtoFieldSetMembers;
	}

	/**
	 * @description Will populate the provide dto with fieldset members
	 *
	 * @param objectName The object name for which to retrieve fieldset members
	 * @param mapOfObjectsFieldsSet A map containing the a list of field sets per object name
	 * @param dtoFieldSetMembers The list of populate
	 */
	private static void populateMembersDto(String objectName, Map<String, List<String>> mapOfObjectsFieldsSet, List<CMN_CTRL_FieldSet.DTO_FieldSetMember> dtoFieldSetMembers)
	{
		CMN_UTIL_SObjectDescribe objectDescribe = CMN_UTIL_SObjectDescribe.getDescribe(objectName);
		Map<String, FieldSet> fieldSetMap = objectDescribe.getFieldSetsMap();
		for(String fieldSetName : mapOfObjectsFieldsSet.get(objectName))
		{
			FieldSet fieldsToUse = fieldSetMap.get(fieldSetName);
			if(fieldsToUse != null)
			{
				for(FieldSetMember member : fieldsToUse.getFields())
				{
					populateFieldSetMemberDto(member, objectDescribe, fieldsToUse, objectName, dtoFieldSetMembers);
				}
			}
		}
	}

	/**
	 * @description Will populate a field set member Dto and add it into the list
	 *
	 * @param member Fieldset Member
	 * @param objectDescribe The current describe for the object containing fieldset fields
	 * @param currentFieldset Fieldset from which to read the members
	 * @param objectName The current object name
	 * @param dtoFieldSetMembers The list to populate
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	private static void populateFieldSetMemberDto
			(FieldSetMember member, CMN_UTIL_SObjectDescribe objectDescribe, FieldSet currentFieldset, String objectName, List<CMN_CTRL_FieldSet.DTO_FieldSetMember> dtoFieldSetMembers)
	{
		CMN_CTRL_FieldSet.DTO_FieldSetMember dtoFieldSetMember = new CMN_CTRL_FieldSet.DTO_FieldSetMember();
		String fieldPath = member.getFieldPath();
		SObjectField fieldToMap = objectDescribe.getField(fieldPath);
		if(fieldToMap != null)
		{
			dtoFieldSetMember.fieldAPIName = member.getFieldPath();
			dtoFieldSetMember.fieldLabel = member.getLabel();
			dtoFieldSetMember.isRequired = member.required;
			dtoFieldSetMember.fieldSetAPIName = currentFieldset.getName();
			dtoFieldSetMember.fieldValue = CMN_UTIL_String.EMPTY;
			dtoFieldSetMember.objectName = objectName;
			dtoFieldSetMembers.add(dtoFieldSetMember);
		}
	}

	/**
	 * @description query the service type record based on service type id.
	 *
	 * @param serviceTypeId id of service type object.
	 *
	 * @return service type record
	 */
	@AuraEnabled(Cacheable=true)
	public static SC_ServiceType__c getServiceTypeRecord(Id serviceTypeId)
	{
		return SC_DAL_ServiceType.findById(serviceTypeId);
	}

}