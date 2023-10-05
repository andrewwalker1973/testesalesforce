/**
 * @description Public class to return the records of DocumentChecklistItems
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date 2021
 */
public inherited sharing class SC_DAL_DocumentChecklistItem
{
	private static final String FIELD_DOCUMENT_TYPE_LABEL = 'DocumentChecklistItem.DocumentType.MasterLabel';
	private static final String FIELD_DOCUMENT_TYPE_NAME = 'DocumentType.DeveloperName';
	public static final String DOCUMENT_CODE = 'DocumentCode_';
	public static final String FIELD_DOCUMENT_TYPE_ID = DocumentChecklistItem.DocumentTypeId.getDescribe().getLocalName();
	public static final String FIELD_NAME = CMN_DAL_SObjectDomain.FIELD_NAME;
	public static final String FIELD_PARENT_ID = DocumentChecklistItem.ParentRecordId.getDescribe().getLocalName();
	public static final String FIELD_REASON = DocumentChecklistItem.CMN_Reason__c.getDescribe().getLocalName();
	public static final String FIELD_STATUS = DocumentChecklistItem.Status.getDescribe().getLocalName();
	public static final String FIELD_UPLOADED_WITH_CASE = DocumentChecklistItem.SC_UploadedWithCase__c.getDescribe().getLocalName();
	public static final String FIELD_VAULTED = DocumentChecklistItem.AW_Vaulted__c.getDescribe().getLocalName();
	public static final String FIELD_VAULT_ID = DocumentChecklistItem.CMN_VaultedId__c.getDescribe().getLocalName();
	public static final String OBJECT_NAME = DocumentChecklistItem.SObjectType.getDescribe().getLocalName();
	public static final String RT_CASE_DOCUMENT = 'SC_CaseDocument';
	public static final String STATUS_NEW = 'New';
	public static final String STATUS_PENDING = 'Pending';
	public static final String STATUS_REJECTED = 'Rejected';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				DocumentChecklistItem.AW_DateVaulted__c.getDescribe().getLocalName(),
				DocumentChecklistItem.Id.getDescribe().getLocalName(),
				DocumentChecklistItem.IsRequired.getDescribe().getLocalName(),
				DocumentChecklistItem.RecordTypeId.getDescribe().getLocalName(),
				DocumentChecklistItem.Status.getDescribe().getLocalName(),
				DocumentChecklistItem.WhoId.getDescribe().getLocalName(),
				FIELD_DOCUMENT_TYPE_ID,
				FIELD_DOCUMENT_TYPE_LABEL,
				FIELD_DOCUMENT_TYPE_NAME,
				FIELD_NAME,
				FIELD_PARENT_ID,
				FIELD_REASON,
				FIELD_UPLOADED_WITH_CASE,
				FIELD_VAULTED,
				FIELD_VAULT_ID
		};
	}

	/**
	 * @description This method is use to get the List of DocumentCheckListItems with Vault Ids
	 *
	 * @param vaultIds Set of Vault ids of documents
	 *
	 * @return A list of items
	 */
	public static List<DocumentChecklistItem> findByVaultIds(Set<String> vaultIds)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_VAULT_ID, vaultIds, getDefaultFields());
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
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_PARENT_ID, new Set<Id> {parentRecordId}, getDefaultFields());
	}

	/**
	 * @description This method is use to get DocumentCheckListItems by Id
	 *
	 * @param recordIds The record ids of the DocumentCheckListItems
	 *
	 * @return A list of DocumentChecklistItem
	 */
	public static List<DocumentChecklistItem> findById(Set<Id> recordIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, recordIds, getDefaultFields());
	}

	/**
	 * @description This method is use to get a DocumentCheckListItem by Id
	 *
	 * @param recordId The record id of the DocumentCheckListItem
	 *
	 * @return An item
	 */
	public static DocumentChecklistItem findById(Id recordId)
	{
		return (DocumentChecklistItem)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, recordId, getDefaultFields());
	}

	/**
	 * @description Will return all DocumentChecklistItem in the system
	 *
	 * @return A list of DocumentChecklistItems
	 */
	@TestVisible
	private static List<DocumentChecklistItem> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description Will return all outstanding documents related to a case
	 *
	 * @param parentIds Set of parent record Ids
	 *
	 * @return A list of found items
	 */
	public static List<DocumentChecklistItem> getOutstandingDocuments(Set<Id> parentIds)
	{
		Set<String> statuses = new Set<String> {STATUS_NEW, STATUS_PENDING, STATUS_REJECTED};

		List<Object> parentRecordIds = new List<Id>(parentIds);
		List<Object> statusNames = new List<String>(statuses);

		CMN_SOQL_Query.AndCondition andConditionDocuments = new CMN_SOQL_Query.AndCondition();
		andConditionDocuments.add(new CMN_SOQL_Query.SetCondition(SC_DAL_DocumentChecklistItem.FIELD_PARENT_ID, CMN_SOQL_Query.Operator.INX, parentRecordIds));
		andConditionDocuments.add(new CMN_SOQL_Query.SetCondition(SC_DAL_DocumentChecklistItem.FIELD_STATUS, CMN_SOQL_Query.Operator.INX, statusNames));

		CMN_SOQL_Builder fieldBuilder =
				new CMN_SOQL_Builder()
						.selectX(getDefaultFields())
						.fromX(SC_DAL_DocumentChecklistItem.OBJECT_NAME)
						.whereX(andConditionDocuments);

		return Database.query(fieldBuilder.toSoql());
	}

	/**
	 * @description This method is use to get the List of Vaulted DocumentCheckListItems with the particular ParenRecordId
	 *
	 * @param parentRecordId The record to which this item is associated
	 *
	 * @return A list of items
	 */
	public static List<DocumentChecklistItem> findVaultedDocumentByParent(Id parentRecordId)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_PARENT_ID, new Set<String> {parentRecordId}, getDefaultFields());
		searchParameters.searchConditions.add(CMN_SOQL_Query.equalsX(FIELD_VAULTED, true));

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method is use to get the List of DocumentCheckListItems with the particular ParenRecordId
	 *
	 * @param parentRecordId The recordId to which this item is associated
	 *
	 * @return A list of items
	 */
	public static List<DocumentChecklistItem> findByParent(Set<Id> parentRecordId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_PARENT_ID, parentRecordId, getDefaultFields());
	}
}