/**
 * @description Public class to return the records of DocumentChecklistItems
 *
 * @see AW_CTRL_DocumentChecklistItem_TEST
 *
 * @author Accenture
 *
 * @date 2021
 */
public inherited sharing class AW_DAL_DocumentChecklistItem
{
	private static final String FIELD_DOCUMENT_TYPE_LABEL = 'DocumentChecklistItem.DocumentType.MasterLabel';
	private static final String FIELD_DOCUMENT_TYPE_DESCRIPTION = 'DocumentChecklistItem.DocumentType.Description';
	private static final String FIELD_DOCUMENT_TYPE_NAME = 'DocumentType.DeveloperName';
	private static final String FIELD_PARENT_RECORD_ID = DocumentChecklistItem.ParentRecordId.getDescribe().getLocalName();
	private static final String FIELD_WHO_NAME = 'Who.Name';
	private static final String OBJECT_NAME = DocumentChecklistItem.SObjectType.getDescribe().getLocalName();
	public static final String RT_ENVELOPE = 'AW_EnvelopeSigningRequest';
	public static final String RT_OUTSTANDING_REQUIREMENT = 'AW_VaultDocument';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				DocumentChecklistItem.AW_DateVaulted__c.getDescribe().getLocalName(),
				DocumentChecklistItem.AW_Vaulted__c.getDescribe().getLocalName(),
				DocumentChecklistItem.DocumentTypeId.getDescribe().getLocalName(),
				DocumentChecklistItem.Name.getDescribe().getLocalName(),
				DocumentChecklistItem.OwnerId.getDescribe().getLocalName(),
				DocumentChecklistItem.Status.getDescribe().getLocalName(),
				DocumentChecklistItem.WhoId.getDescribe().getLocalName(),
				FIELD_DOCUMENT_TYPE_LABEL,
				FIELD_DOCUMENT_TYPE_NAME,
				FIELD_DOCUMENT_TYPE_DESCRIPTION,
				FIELD_PARENT_RECORD_ID,
				FIELD_WHO_NAME
		};
	}

	/**
	 * @description This method is use to get a DocumentCheckListItem with the particular Id
	 *
	 * @param recordId The record of the DocumentCheckListItem
	 *
	 * @return A single DocumentChecklistItem
	 */
	public static DocumentChecklistItem findById(Id recordId)
	{
		return (DocumentChecklistItem)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, recordId, getDefaultFields());
	}

	/**
	 * @description This method is use to get the List of DocumentCheckListItems with the particular ParenRecordId
	 *
	 * @param parentRecordId The record to which this item is associated
	 *
	 * @return A list of items
	 */
	public static List<DocumentChecklistItem> findByParent(Id parentRecordId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_PARENT_RECORD_ID, new Set<Id> {parentRecordId}, getDefaultFields());
	}

	/**
	 * @description Will return all DocumentChecklistItem in the system
	 *
	 * @return A list of envelopes
	 */
	@TestVisible
	private static List<DocumentChecklistItem> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
}