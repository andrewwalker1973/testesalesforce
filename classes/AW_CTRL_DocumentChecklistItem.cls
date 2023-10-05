/**
 * @description Controller used to view and update DocumentChecklistItem's
 *
 * @see AW_CTRL_DocumentChecklistItem_TEST
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing class AW_CTRL_DocumentChecklistItem
{
	/**
	 * @description Will retrieve document checklist item by parent Record
	 *
	 * @param parentRecordId The id of the parent record
	 *
	 * @return A list of items
	 */
	@AuraEnabled(Cacheable=true)
	public static List<DocumentChecklistItem> getDocumentListByParent(Id parentRecordId)
	{
		return AW_DAL_DocumentChecklistItem.findByParent(parentRecordId);
	}

	/**
	 * @description Will delete a document check list item based on Id
	 *
	 * @param documentItemId The Item to delete!
	 */
	@AuraEnabled
	public static void deleteDocumentListItem(Id documentItemId)
	{
		CMN_DAL_SObjectDomain.deleteDBObject(new DocumentChecklistItem(Id = documentItemId));
	}

	/**
	 * @description Used to insert or update a DocumentChecklistItem from a LWC component
	 *
	 * @param request DocumentChecklistItem information which need to be inserted/updated
	 *
	 * @return Returns the Id of the inserted/updated DocumentChecklistItem
	 */
	@AuraEnabled
	public static Id saveDocumentListItem(String request)
	{
		//TODO: Can we not use a formal type as method parameter rather than a string
		DTO_DocumentChecklistItem dtoDocumentChecklistItem = (DTO_DocumentChecklistItem)JSON.deserialize(request, DTO_DocumentChecklistItem.class);

		DocumentChecklistItem newDocumentChecklistItem = new DocumentChecklistItem();

		newDocumentChecklistItem.Id = dtoDocumentChecklistItem.documentChecklistItemId;
		newDocumentChecklistItem.Name = dtoDocumentChecklistItem.documentChecklistItemName;
		newDocumentChecklistItem.ParentRecordId = dtoDocumentChecklistItem.documentChecklistItemParentId;
		//TODO: commented out code below as it won't work to either update or insert an object, the recordtype must be queried, make sure unit test also provides recordtype name
		//newDocumentChecklistItem.RecordType.Name = dtoDocumentChecklistItem.documentChecklistItemRecordType;

		upsert newDocumentChecklistItem;

		return newDocumentChecklistItem.Id;
	}

	/**
	 * @description Wrapper class is use to store the document checklist item fields
	 */
	public class DTO_DocumentChecklistItem
	{
		@AuraEnabled
		public String documentChecklistItemId;
		@AuraEnabled
		public String documentChecklistItemName;
		@AuraEnabled
		public String documentChecklistItemParentId;
		@AuraEnabled
		public String documentChecklistItemRecordType;
	}
}