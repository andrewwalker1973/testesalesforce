/**
 * @description Test class related to the AW_CTRL_DocumentChecklistItem
 *
 * @see AW_CTRL_DocumentChecklistItem
 *
 * @author Accenture
 *
 * @date May 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_CTRL_DocumentChecklistItem_TEST
{
	/**
	 * @description Create data required for unit tests
	 *
	 * @return
	 */
	private static DocumentChecklistItem createTestData()
	{
		AW_Envelope__c newEnvelope = AW_DAL_TestDataFactory.insertEnvelope();
		return AW_DAL_TestDataFactory.insertDocumentCheckListItem(newEnvelope.Id);
	}

	/**
	 * @description Will check that the querying check list items by parent id works
	 *
	 * @see AW_CTRL_DocumentChecklistItem.getDocumentListByParent
	 */
	@IsTest
	private static void getDocumentListByParent()
	{
		DocumentChecklistItem newItem = createTestData();

		Test.startTest();

		List<DocumentChecklistItem> foundItems = AW_CTRL_DocumentChecklistItem.getDocumentListByParent(newItem.ParentRecordId);

		Test.stopTest();

		System.assertEquals(false, foundItems.isEmpty(), 'No check list items were found.');
	}

	/**
	 * @description Will check that deleting if a check list item works
	 *
	 * @see AW_CTRL_DocumentChecklistItem.deleteDocumentListItem
	 */
	@IsTest
	private static void deleteDocumentListItem()
	{
		DocumentChecklistItem newItem = createTestData();

		Test.startTest();

		AW_CTRL_DocumentChecklistItem.deleteDocumentListItem(newItem.Id);

		Test.stopTest();

		newItem = AW_DAL_DocumentChecklistItem.findById(newItem.Id);
		System.assertEquals(null, newItem, 'Item was not deleted as expected.');
	}

	/**
	 * @description Will check if the documentChecklistItem is being inserted
	 *
	 * @see AW_CTRL_DocumentChecklistItem.saveDocumentListItem
	 */
	@IsTest
	private static void insertDocumentListItem()
	{
		AW_Envelope__c newEnvelope = AW_DAL_TestDataFactory.insertEnvelope();

		AW_CTRL_DocumentChecklistItem.DTO_DocumentChecklistItem dtoDocumentChecklistItem = new AW_CTRL_DocumentChecklistItem.DTO_DocumentChecklistItem();

		dtoDocumentChecklistItem.documentChecklistItemName = CMN_DAL_SObjectDomain.generateRandomName();
		dtoDocumentChecklistItem.documentChecklistItemParentId = newEnvelope.Id;
		dtoDocumentChecklistItem.documentChecklistItemId = null;

		Id documentChecklistItemId;

		Test.startTest();

		documentChecklistItemId = AW_CTRL_DocumentChecklistItem.saveDocumentListItem(JSON.serialize(dtoDocumentChecklistItem));

		Test.stopTest();

		System.assertNotEquals(null, documentChecklistItemId, 'New DocumentChecklistItem was not created as expected');
	}

	/**
	 * @description Will check if the documentChecklistItem is being updated
	 *
	 * @see AW_CTRL_DocumentChecklistItem.saveDocumentListItem
	 */
	@IsTest
	private static void updateDocumentListItem()
	{
		AW_CTRL_DocumentChecklistItem.DTO_DocumentChecklistItem dtoDocumentChecklistItem = new AW_CTRL_DocumentChecklistItem.DTO_DocumentChecklistItem();

		DocumentChecklistItem newItem = createTestData();

		String documentChecklistItemName = CMN_DAL_SObjectDomain.generateRandomName();

		dtoDocumentChecklistItem.documentChecklistItemName = documentChecklistItemName;
		dtoDocumentChecklistItem.documentChecklistItemParentId = newItem.ParentRecordId;
		dtoDocumentChecklistItem.documentChecklistItemId = newItem.Id;

		Test.startTest();

		AW_CTRL_DocumentChecklistItem.saveDocumentListItem(JSON.serialize(dtoDocumentChecklistItem));

		Test.stopTest();

		newItem = AW_DAL_DocumentChecklistItem.findById(newItem.Id);

		System.assertEquals(newItem.Name, documentChecklistItemName, 'DocumentChecklistItem was not updated as expected.');
	}

}