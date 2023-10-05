/**
 * @description Test class related to the RSC_CTRL_GetVaultedDocuments
 *
 * @see RSC_CTRL_GetVaultedDocuments
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date May 2022, June 2023
 */
//As criteria based sharing rules cannot be accommodated in test class , not running as an agent.

@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=false)
private class RSC_CTRL_GetVaultedDocuments_TEST
{
	private static final Integer CASE_COMMENT_SIZE = 1;
	private static final Integer INT_ONE = 1;
	private static final Integer INT_THREE = 3;
	private static final Integer INT_TWO = 2;
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description Create data required for unit tests
	 */
	@TestSetup
	private static void setup()
	{
		Account personMasterAccount = AW_DAL_TestDataFactory.createMasterPersonAccount(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		Case newCase = SC_DAL_DataFactory.createCase(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		newCase.AccountId = personMasterAccount.Id;
		update newCase;
		AW_DAL_TestDataFactory.createClientAccount(AW_UTIL_IdentityNumber.generateRandomIdentityNumber(), NUMBER_OF_ITEMS_TO_CREATE);
		List<DocumentChecklistItem> documentChecklistItems = SC_DAL_DataFactory.insertDocumentCheckListItems(newCase.Id, INT_THREE);

		documentChecklistItems.iterator().next().CMN_VaultedId__c = CMN_UTIL_String.EMPTY;
		CMN_DAL_SObjectDomain.updateDBObject(documentChecklistItems.iterator().next());
	}

	/**
	 * @description method to get DocumentChecklistItems by parent Id
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.getDocuments
	 */
	@IsTest
	private static void getCheckListItemByParent()
	{
		List<DocumentChecklistItem> newItem = AW_DAL_DocumentChecklistItem.getAll();

		Test.startTest();

		for(DocumentChecklistItem newDocumentItem : newItem)
		{
			List<DocumentChecklistItem> newItems = RSC_CTRL_GetVaultedDocuments.getDocuments(newDocumentItem.ParentRecordId);
			System.assertEquals(false, newItems.isEmpty(), 'No check list items found.');
		}

		Test.stopTest();
	}

	/**
	 * @description method to verify if DocumentCheckListItems were de-linked successfully
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.deLinkDocumentItem
	 */
	@IsTest
	private static void deLinkCheckListItemsSuccessfulCall()
	{
		List<DocumentChecklistItem> newDocuments = SC_DAL_DocumentChecklistItem.getAll();

		List<String> documentIds = new List<String>();
		for(DocumentChecklistItem document : newDocuments)
		{
			documentIds.add(document.Id);
		}

		Test.startTest();

		RSC_CTRL_GetVaultedDocuments.deLinkDocumentItem(documentIds, CMN_DAL_SObjectDomain.generateRandomName());

		Test.stopTest();

		for(DocumentChecklistItem deletedDocumentItem : newDocuments)
		{
			if(deletedDocumentItem.CMN_VaultedId__c != null)
			{
				deletedDocumentItem = SC_DAL_DocumentChecklistItem.findById(deletedDocumentItem.Id);
				System.assertEquals(null, deletedDocumentItem, 'Document CheckList Item was not deleted');
			}
		}

		List<CaseComment> comments = RSC_DAL_CaseComment.getAll();
		System.assertEquals(INT_TWO, comments.size(), 'Case Comments were not created successfully');
	}

	/**
	 * @description method to verify the failed API call to de-link DocumentCheckListItems
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.deLinkDocumentItem
	 */
	@IsTest
	private static void deLinkCheckListItemsFailedCall()
	{
		List<DocumentChecklistItem> newDocuments = SC_DAL_DocumentChecklistItem.getAll();

		List<String> documentIds = new List<String>();
		for(DocumentChecklistItem document : newDocuments)
		{
			documentIds.add(document.Id);
		}

		Test.startTest();

		CMN_API_HttpBaseOutboundMock.returnErrorResponse = true;
		RSC_CTRL_GetVaultedDocuments.deLinkDocumentItem(documentIds, CMN_DAL_SObjectDomain.generateRandomName());

		Test.stopTest();

		for(DocumentChecklistItem deletedDocumentItem : newDocuments)
		{
			if(deletedDocumentItem.CMN_VaultedId__c != null)
			{
				deletedDocumentItem = SC_DAL_DocumentChecklistItem.findById(deletedDocumentItem.Id);
				System.assertNotEquals(null, deletedDocumentItem, 'Document CheckList Item should not be deleted');
			}
		}

		List<CaseComment> comments = RSC_DAL_CaseComment.getAll();
		System.assertEquals(INT_ONE, comments.size(), 'Case Comments were not created successfully');
	}

	/**
	 * @description method to insert Document CheckList Items
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.saveRecord
	 */
	@IsTest
	private static void insertDocumentCheckListItem()
	{
		Case newCase = SC_DAL_Case.getAll().iterator().next();

		List<String> newChecklistItemId;

		DocumentChecklistItem newItem = new DocumentChecklistItem();
		newItem.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newItem.ParentRecordId = newCase.Id;

		Test.startTest();

		newChecklistItemId = RSC_CTRL_GetVaultedDocuments.saveRecord(new List<DocumentChecklistItem> {newItem});

		Test.stopTest();

		System.assertNotEquals(null, newChecklistItemId, 'New Document Checklist Item was not created');
	}

	/**
	 * @description method to get content version for given Document Checklist Item
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.getContentDocument
	 */
	@IsTest
	private static void getContentDocumentForCheckListItem()
	{
		Case newCase = SC_DAL_Case.getAll().iterator().next();
		DocumentChecklistItem newItem = SC_DAL_DataFactory.insertDocumentCheckListItems(newCase.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		ContentVersion newVersion = RSC_DAL_TestDataFactory.createNewContentVersion(NUMBER_OF_ITEMS_TO_CREATE, newItem.Id).iterator().next();
		newVersion = CMN_DAL_ContentVersion.findByFirstPublishLocationId(newItem.Id).iterator().next();

		RSC_API_GetContentDocument.mockContentDocumentId = newVersion.ContentDocumentId;

		Test.startTest();

		RSC_CTRL_GetVaultedDocuments.DTO_Response dtoResponse = RSC_CTRL_GetVaultedDocuments.getContentDocument(newItem.Id, newItem.CMN_VaultedId__c);

		Test.stopTest();

		System.assertNotEquals(null, dtoResponse.contentDocumentId, 'Content Version is not linked to Document CheckList Item');
	}

	/**
	 * @description method to get content version for given Document Checklist Item
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.getContentDocument
	 */
	@IsTest
	private static void viewCheckListWithNoContentDocument()
	{
		DocumentChecklistItem newItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next(); // documentChecklist Item without content document

		Test.startTest();

		RSC_CTRL_GetVaultedDocuments.DTO_Response dtoResponse = RSC_CTRL_GetVaultedDocuments.getContentDocument(newItem.Id, newItem.CMN_VaultedId__c);

		Test.stopTest();

		System.assertEquals(null, dtoResponse.contentDocumentId, 'Content Document should not be found as expected');
	}

	/**
	 * @description method to get DocumentType by code
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.getDocumentTypeByCode
	 */
	@IsTest
	private static void getDocumentsByCode()
	{
		List<String> newCodes = new List<String>();
		newCodes.add(CMN_DAL_SObjectDomain.generateRandomName());
		newCodes.add(CMN_DAL_SObjectDomain.generateRandomName());

		Test.startTest();

		List<DocumentType> newTypes = RSC_CTRL_GetVaultedDocuments.getDocumentTypeByCode(newCodes);

		Test.stopTest();

		System.assert(newTypes.isEmpty(), 'List should be empty as expected');
	}

	/**
	 * @description method to get DocumentType by recordId
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.getDocumentType
	 */
	@IsTest
	private static void getDocumentsById()
	{
		DocumentType newType = SC_DAL_DocumentType.findRandomActive();

		Test.startTest();

		DocumentType documentType = RSC_CTRL_GetVaultedDocuments.getDocumentType(newType.Id);

		Test.stopTest();

		System.assertEquals(newType.Id, documentType.Id, 'No Document Type found');
	}

	/**
	 * @description method to check that the controller will return document checklist item for a given Individual Account Id
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.getVaultedDocuments
	 */
	@IsTest
	private static void getChecklistItemFromIndividualClient()
	{
		Account newAccount = SC_DAL_Account.getAll().iterator().next();

		Test.startTest();

		RSC_CTRL_GetVaultedDocuments.DTO_Response dtoResponse = RSC_CTRL_GetVaultedDocuments.getVaultedDocuments(newAccount.Id);

		Test.stopTest();

		System.assertEquals(false, dtoResponse.vaultedDocuments.isEmpty(), 'No checklist items found for given parent record');
	}

	/**
	 * @description method to check that the controller will return document checklist item for a given Business Account Id
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.getVaultedDocuments
	 */
	@IsTest
	private static void getChecklistItemFromBusinessClient()
	{
		Account newBusinessAccount = AW_DAL_TestDataFactory.createBusinessChildAccountWithMaster();

		Test.startTest();

		RSC_CTRL_GetVaultedDocuments.DTO_Response dtoResponse = RSC_CTRL_GetVaultedDocuments.getVaultedDocuments(newBusinessAccount.AW_ParentAccount__c);

		Test.stopTest();

		System.assertEquals(false, dtoResponse.vaultedDocuments.isEmpty(), 'No checklist items found for given parent record');
	}

	/**
	 * @description Will check that the controller will return document list for a given parent Id
	 */
	@IsTest
	private static void getChecklistItemFromInvalidClient()
	{
		Test.startTest();

		RSC_CTRL_GetVaultedDocuments.DTO_Response dtoResponse = RSC_CTRL_GetVaultedDocuments.getVaultedDocuments(UserInfo.getUserId());

		Test.stopTest();

		System.assertEquals(false, dtoResponse.callSuccessful, 'Callout not failed as expected');

	}

	/**
	 * @description method to check that the controller will return document checklist item for a given parent Id
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.uploadDocuments
	 */
	@IsTest
	private static void uploadDocumentsToCase()
	{
		Case newCase = SC_DAL_Case.getAll().iterator().next();
		DocumentChecklistItem newItem = SC_DAL_DataFactory.insertDocumentCheckListItems(newCase.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		RSC_DAL_TestDataFactory.createNewContentVersion(NUMBER_OF_ITEMS_TO_CREATE, newItem.Id).iterator().next();
		Test.startTest();

		RSC_CTRL_GetVaultedDocuments.DTO_Response dtoResponse;

		dtoResponse = RSC_CTRL_GetVaultedDocuments.uploadDocuments(new List<String> {newItem.Id});

		Test.stopTest();

		System.assertNotEquals(null, dtoResponse, 'API is not returning the response as expected');
	}

	/**
	 * @description method to check that the controller will return document checklist item for a given parent Id
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.uploadDocuments
	 */
	@IsTest
	private static void uploadDocumentsToCaseErrorCall()
	{
		Test.startTest();

		RSC_CTRL_GetVaultedDocuments.DTO_Response dtoResponse;

		dtoResponse = RSC_CTRL_GetVaultedDocuments.uploadDocuments(new List<String> {UserInfo.getUserId()});

		Test.stopTest();

		System.assertEquals(false, dtoResponse.callSuccessful, 'API is not returning the response as expected');
	}

	/**
	 * @description method to check that the controller will return document checklist item
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.reclassifyDocuments
	 */
	@IsTest
	private static void reclassifyDocumentsSuccessCall()
	{
		List<DocumentChecklistItem> newItem = SC_DAL_DocumentChecklistItem.getAll();
		String documentId;
		for(DocumentChecklistItem documentChecklist : newItem)
		{
			if(documentChecklist.CMN_VaultedId__c != null)
			{
				documentId = documentChecklist.Id;
				break;
			}
		}

		DocumentType newType = SC_DAL_DocumentType.findRandomActive();

		Test.startTest();

		RSC_CTRL_GetVaultedDocuments.DTO_Response dtoResponse = RSC_CTRL_GetVaultedDocuments.reclassifyDocuments(documentId, newType.Id);

		Test.stopTest();

		System.assertNotEquals(null, dtoResponse, 'API is not returning the response as expected');

	}

	/**
	 * @description method to check that the controller will return when API call  returns error
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.reclassifyDocuments
	 */
	@IsTest
	private static void reclassifyDocumentsErrorCall()
	{
		DocumentType newType = SC_DAL_DocumentType.findRandomActive();
		String currentUser = UserInfo.getUserId();

		Test.startTest();

		RSC_CTRL_GetVaultedDocuments.DTO_Response dtoResponse;

		dtoResponse = RSC_CTRL_GetVaultedDocuments.reclassifyDocuments(currentUser, newType.Id);

		Test.stopTest();

		System.assertNotEquals(null, dtoResponse, 'API is not returning the response as expected');
		System.assertEquals(false, dtoResponse.callSuccessful, 'DTO response was  returned successfully.');
	}

	/**
	 * @description method to check if CTRL has posted case comments
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.postCaseComments
	 */
	@IsTest
	private static void getPostedCaseComments()
	{
		DocumentChecklistItem newItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next();
		newItem.CMN_VaultedId__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		update newItem;
		Id documentId = SC_DAL_DocumentType.findRandomActive().Id;

		Test.startTest();

		RSC_CTRL_GetVaultedDocuments.postCaseComments(newItem.Id, documentId);

		Test.stopTest();

		List<CaseComment> comments = RSC_DAL_CaseComment.getAll();
		System.assertEquals(CASE_COMMENT_SIZE, comments.size(), 'Case Comments were not created successfully');
	}

	/**
	 * @description method to Delete the document by DocumentId
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.deleteNonVaultedDocuments
	 */
	@IsTest
	private static void deleteDocumentsById()
	{
		DocumentChecklistItem itemToDelete = SC_DAL_DocumentChecklistItem.getAll().iterator().next();

		Test.startTest();

		RSC_CTRL_GetVaultedDocuments.deleteNonVaultedDocuments(itemToDelete.Id);

		Test.stopTest();

		itemToDelete = SC_DAL_DocumentChecklistItem.findById(itemToDelete.Id);

		System.assertEquals(null, itemToDelete, 'Item Not Deleted as expected');
	}

	/**
	 * @description method to delete the existing documentCheckListItem record and replace it with a new record
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.replaceDocumentChecklist
	 */
	@IsTest
	private static void replaceDocumentCheckListItemOnEdit()
	{
		DocumentChecklistItem currentDocumentChecklistItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next();

		DocumentChecklistItem newItemToBeCreated = new DocumentChecklistItem();
		newItemToBeCreated.Name = currentDocumentChecklistItem.Name;
		newItemToBeCreated.ParentRecordId = currentDocumentChecklistItem.ParentRecordId;
		newItemToBeCreated.Status = currentDocumentChecklistItem.Status;
		newItemToBeCreated.IsRequired = false;
		newItemToBeCreated.DocumentTypeId = currentDocumentChecklistItem.DocumentTypeId;

		Test.startTest();

		String documentCheckListItemId = RSC_CTRL_GetVaultedDocuments.replaceDocumentChecklist(currentDocumentChecklistItem.Id, newItemToBeCreated);

		Test.stopTest();

		System.assertEquals(documentCheckListItemId, newItemToBeCreated.Id, 'Record not replaced');
		System.assertEquals(false, newItemToBeCreated.IsRequired, 'Required field not updated');
	}
}