/**
 * @description Controller for retrieving all vaulted document for a record
 *
 * @see RSC_CTRL_GetVaultedDocuments_TEST @story ST-146010
 *
 * @author aakriti.a.goyal@accenture.com, jayanth.kumar.s@accenture.com
 *
 * @date July 2021, June 2023
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class RSC_CTRL_GetVaultedDocuments
{
	private static final String DE_LINK_ABORT_CASE_COMMENT = 'There were some errors on de-linking below documents:\n {0}';
	private static final String DE_LINK_SUCCESS_CASE_COMMENT = 'Following documents were successfully de-linked from the case:\n {0}';
	private static final String ERROR_COMMENT = 'Document Type: "{0}" , Document Name: "{1}" , Error: "{2}"';
	private static final String RECLASSIFY_SUCCESS_CASE_COMMENT = 'Following document was re-classified successfully from the case:';
	private static final String RECLASSIFY_SUCCESS_MESSAGE = 'Document reclassified  Successfully';
	private static final String SUCCESS_COMMENT = 'Document Type: "{0}" , Document Name: "{1}" , Date DeLinked: "{2}" , Reason: "{3}"';
	private static final String UPLOAD_SUCCESS_MESSAGE = 'Upload Successful';

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
	 * @description method used to delete DocumentCheckListItem based on Id
	 *
	 * @param documentIds The documentItem to be deleted
	 * @param deLinkReason Reason to de-link the documents
	 *
	 * @return A boolean variable to indicate if there was any error when de-linking the documents
	 */
	@AuraEnabled
	@SuppressWarnings('PMD.CognitiveComplexity')
	public static Boolean deLinkDocumentItem(List<String> documentIds, String deLinkReason)
	{
		Boolean isSuccess = true;

		List<CMN_WebserviceCallQueue__c> queueItems = new List<CMN_WebserviceCallQueue__c>();

		for(String documentId : documentIds)
		{
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
					(
							RSC_API_DelinkDocumentsFromCase.SERVICE_NAME, documentId, RSC_API_DelinkDocumentsFromCase.PARAMETER_REASON, deLinkReason
					);
			queueItems.add(queueItem);
		}

		List<CMN_API_HttpBase> handlers = CMN_FACTORY_WebserviceManager.execute(queueItems);

		List<String> errorMessages = new List<String>();
		Set<Id> deletedDocumentIds = new Set<Id>();
		Map<Id, String> documentIdToErrorMessage = new Map<Id, String>();

		// Extract the success & aborted responses
		for(CMN_API_HttpBase handler : handlers)
		{
			Id documentId = handler.getQueueItem().CMN_TriggeringObjectId__c;
			RSC_API_DelinkDocumentsFromCase deLinkedDocsHandler = (RSC_API_DelinkDocumentsFromCase)handler;
			if(!deLinkedDocsHandler.callResult.completed)
			{
				String error = CMN_UTIL_String.EMPTY;

				if(!deLinkedDocsHandler.callResult.errors.isEmpty())
				{
					error = String.join(deLinkedDocsHandler.callResult.errors, CMN_UTIL_String.LF);
				}
				else
				{
					error = RSC_DTO_ErrorResponse.errorMessage(deLinkedDocsHandler.callResult);
				}
				errorMessages.add(error);
				documentIdToErrorMessage.put(documentId, error);
			}
			else
			{
				deletedDocumentIds.add(documentId);
			}
		}

		List<CaseComment> caseComments = new List<CaseComment>();

		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork();
		unitOfWork.addSObjectTypes(new List<Schema.SObjectType>
		{
				CaseComment.SObjectType, DocumentChecklistItem.SObjectType
		});

		// Delete all documents those are successfully de-linked from the external system
		if(!deletedDocumentIds.isEmpty())
		{
			List<DocumentChecklistItem> documentChecklistItems = SC_DAL_DocumentChecklistItem.findById(deletedDocumentIds);

			if(!documentChecklistItems.isEmpty())
			{
				List<String> caseCommentSucceededDocuments = new List<String>();
				for(DocumentChecklistItem document : documentChecklistItems)
				{
					String successComment = String.format
							(
									SUCCESS_COMMENT,
									new List<Object>
									{
											document.DocumentType.MasterLabel, document.Name, System.now().format(), deLinkReason
									}
							);

					caseCommentSucceededDocuments.add(successComment);
				}

				CaseComment comment = new CaseComment();
				comment.CommentBody = String.format
						(
								DE_LINK_SUCCESS_CASE_COMMENT,
								new List<String> {String.join(caseCommentSucceededDocuments, CMN_UTIL_String.LF)}
						);
				comment.ParentId = documentChecklistItems.iterator().next().ParentRecordId;
				caseComments.add(comment);

				unitOfWork.registerDeleted(documentChecklistItems);
			}
		}

		if(!documentIdToErrorMessage.isEmpty())
		{
			List<DocumentChecklistItem> abortedDocumentChecklistItems = SC_DAL_DocumentChecklistItem.findById(documentIdToErrorMessage.keySet());
			if(!abortedDocumentChecklistItems.isEmpty())
			{
				List<String> caseCommentAbortedDocuments = new List<String>();
				for(DocumentChecklistItem document : abortedDocumentChecklistItems)
				{
					String successComment = String.format
							(
									ERROR_COMMENT,
									new List<Object>
									{
											document.DocumentType.MasterLabel, document.Name, documentIdToErrorMessage.get(document.Id)
									}
							);
					caseCommentAbortedDocuments.add(successComment);
				}

				CaseComment comment = new CaseComment();
				comment.CommentBody = String.format
						(
								DE_LINK_ABORT_CASE_COMMENT,
								new List<String> {String.join(caseCommentAbortedDocuments, CMN_UTIL_String.LF)}
						);
				comment.ParentId = abortedDocumentChecklistItems.iterator().next().ParentRecordId;
				caseComments.add(comment);
			}
		}

		unitOfWork.registerNew(caseComments);
		unitOfWork.commitWork();

		// Return the boolean variable as false if any request is aborted
		if(!errorMessages.isEmpty())
		{
			isSuccess = false;
		}

		return isSuccess;
	}

	/**
	 * @description method used to insert DocumentCheckListItem
	 *
	 * @param checklistItems The documentItems to be upserted
	 *
	 * @return DocumentChecklistItem Id
	 */
	@AuraEnabled
	@SuppressWarnings('PMD.ApexCRUDViolation')
	public static List<String> saveRecord(List<DocumentChecklistItem> checklistItems)
	{
		List<String> newDocumentListIds = new List<String>();
		List<DocumentChecklistItem> itemToUpsert = new List<DocumentChecklistItem>();

		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(DocumentChecklistItem.SObjectType, SC_DAL_DocumentChecklistItem.RT_CASE_DOCUMENT);

		for(DocumentChecklistItem newItem : checklistItems)
		{
			newItem.RecordTypeId = recordTypeId;
			itemToUpsert.add(newItem);
		}

		upsert itemToUpsert;

		for(DocumentChecklistItem items : itemToUpsert)
		{
			newDocumentListIds.add(items.Id);
		}

		return newDocumentListIds;
	}

	/**
	 * @description Will retrieve Document Type by its code
	 *
	 * @param documentCodes The list of codes of the record to be found
	 *
	 * @return List of Document Type records
	 */
	@AuraEnabled
	public static List<DocumentType> getDocumentTypeByCode(List<String> documentCodes)
	{
		return SC_DAL_DocumentType.findByDeveloperName(CMN_UTIL_Set.listToSet(documentCodes));
	}

	/**
	 * @description method used to get ContentVersion linked to given record
	 *
	 * @param recordId is the Id of Document to which ContentVersion is linked
	 * @param vaultedId is the vault Id of the document stored in external system
	 *
	 * @return returns id to content document for object retrieved or indicates an error with message
	 */
	@AuraEnabled
	public static DTO_Response getContentDocument(Id recordId, String vaultedId)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
				(
						RSC_API_GetContentDocument.SERVICE_NAME, recordId, RSC_API_GetContentDocument.PARAMETER_VAULTED_ID, vaultedId
				);

		RSC_API_GetContentDocument viewDocsHandler = (RSC_API_GetContentDocument)CMN_FACTORY_WebserviceManager.execute
				(
						new List<CMN_WebserviceCallQueue__c> {queueItem}
				).iterator().next();

		DTO_Response dtoResponse = new DTO_Response();

		if(!viewDocsHandler.callResult.completed)
		{
			dtoResponse.callMessage = String.join(viewDocsHandler.callResult.errors, CMN_UTIL_String.LF);
		}
		else if(String.isNotBlank(viewDocsHandler.contentDocumentId))
		{
			dtoResponse.contentDocumentId = viewDocsHandler.contentDocumentId;
		}

		dtoResponse.callSuccessful = viewDocsHandler.callResult.completed;

		return dtoResponse;
	}

	/**
	 * @description Will retrieve Document Type by its Id
	 *
	 * @param recordId The Id of the record to be found
	 *
	 * @return Single Document Type record
	 */
	@AuraEnabled(Cacheable=true)
	public static DocumentType getDocumentType(Id recordId)
	{
		return SC_DAL_DocumentType.findById(recordId);
	}

	/**
	 * @description Method used to retrieve all vaulted documents for the given record
	 *
	 * @param recordId The Id of the record from which vaulted documents has to be fetched
	 *
	 * @return A list of vaulted records or a indicates if a error was encountered
	 */
	@AuraEnabled
	public static DTO_Response getVaultedDocuments(Id recordId)
	{
		String serviceName = SC_API_FetchVaultedDocuments.SERVICE_NAME;

		if(CMN_UTIL_System.getSObjectTypeById(recordId) == Account.SObjectType)
		{
			Account foundAccount = AW_DAL_Account.findById(recordId);

			if(AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT.equals(foundAccount.RecordType.DeveloperName))
			{
				serviceName = SC_API_BusinessClientVaultedDocs.SERVICE_NAME;
			}
		}

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(serviceName, recordId);

		CMN_API_FetchVaultedDocuments handler = (CMN_API_FetchVaultedDocuments)CMN_FACTORY_WebserviceManager.execute
				(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

		DTO_Response dtoResponse = new DTO_Response();

		if(!handler.callResult.completed)
		{
			dtoResponse.callMessage = String.join(handler.callResult.errors, CMN_UTIL_String.LF);
		}

		dtoResponse.vaultedDocuments = handler.vaultedDocuments;
		dtoResponse.callSuccessful = handler.callResult.completed;

		return dtoResponse;
	}

	/**
	 * @description Method used to upload documents under the case record
	 *
	 * @param documentCheckList checkListItem record that has to be uploaded
	 *
	 * @return vaultedDocsHandler or will throw an exception if API callout fails
	 */
	@AuraEnabled
	public static DTO_Response uploadDocuments(List<String> documentCheckList)
	{
		String itemId = documentCheckList.iterator().next();

		List<CMN_WebserviceCallQueue__c> queueItemList = new List<CMN_WebserviceCallQueue__c>();
		List<String> errorMessages = new List<String>();

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(RSC_API_UploadDocumentToVault.SERVICE_NAME, itemId);
		queueItemList.add(queueItem);

		RSC_API_UploadDocumentToVault vaultedDocsHandler = (RSC_API_UploadDocumentToVault)CMN_FACTORY_WebserviceManager.execute(queueItemList).iterator().next();

		if(!vaultedDocsHandler.callResult.completed)
		{
			String error = RSC_DTO_ErrorResponse.errorMessage(vaultedDocsHandler.callResult);
			error = String.isNotBlank(error) ? error : String.join(vaultedDocsHandler.callResult.errors, CMN_UTIL_String.LF);
			errorMessages.add(error);
		}

		DTO_Response dtoResponse = new DTO_Response();
		dtoResponse.callSuccessful = errorMessages.size() > 0 ? false : true;
		dtoResponse.callMessage = dtoResponse.callSuccessful ? UPLOAD_SUCCESS_MESSAGE : errorMessages.iterator().next();

		return dtoResponse;
	}

	/**
	 * @description Method used to reclassify documents under the case record
	 *
	 * @param checklistId The Id of the document checklistItem record from which documents has to be reclassified
	 * @param documentTypeId The Id of the document type to be reclassified
	 *
	 * @return vaultedDocsHandler or will throw an exception if API callout fails
	 */
	@AuraEnabled
	public static DTO_Response reclassifyDocuments(String checklistId, Id documentTypeId)
	{
		List<CMN_WebserviceCallQueue__c> queueItemList = new List<CMN_WebserviceCallQueue__c>();

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
				(
						RSC_API_ReclassifyDocument.SERVICE_NAME,
						checklistId,
						RSC_API_ReclassifyDocument.PARAMETER_DOCUMENT_TYPE,
						documentTypeId
				);
		queueItemList.add(queueItem);

		RSC_API_ReclassifyDocument reclassifyDocsHandler = (RSC_API_ReclassifyDocument)CMN_FACTORY_WebserviceManager.execute(queueItemList).iterator().next();

		DTO_Response dtoResponse = new DTO_Response();
		dtoResponse.callSuccessful = reclassifyDocsHandler.callResult.completed;
		dtoResponse.callMessage = RECLASSIFY_SUCCESS_MESSAGE;

		// Extract the success & aborted responses
		if(!dtoResponse.callSuccessful)
		{
			//If aborted, error will store the aborted error message, else it will store the error message obtained on API callout failure
			dtoResponse.callMessage = String.isNotBlank(reclassifyDocsHandler.errorMessage) ?
					reclassifyDocsHandler.errorMessage : String.join(reclassifyDocsHandler.callResult.errors, CMN_UTIL_String.LF);
		}

		return dtoResponse;
	}

	/**
	 * @description Method used to post comments when documents are reclassified
	 *
	 * @param checklistId The Id of the document checklistItem record from which documents has to be reclassified
	 * @param documentTypeId The Id of the document type to be reclassified
	 */
	@AuraEnabled
	public static void postCaseComments(String checklistId, Id documentTypeId)
	{
		DocumentType newType = SC_DAL_DocumentType.findById(documentTypeId);
		CaseComment comment = new CaseComment();

		DocumentChecklistItem checkListItem = SC_DAL_DocumentChecklistItem.findById(new Set<Id> {checklistId}).iterator().next();
		if(checkListItem != null)
		{
			String successComment;
			if(checkListItem.DocumentType.Id != documentTypeId)
			{
				String oldDocumentType = newType != null ? newType.MasterLabel : CMN_UTIL_String.SPACE;
				successComment = ' Old Document Type: \'' + oldDocumentType + '\' , New Document Type: \'' + checkListItem.DocumentType.MasterLabel;
			}
			comment.CommentBody = RECLASSIFY_SUCCESS_CASE_COMMENT + CMN_UTIL_String.LF + successComment + CMN_UTIL_String.LF;
			comment.ParentId = checkListItem.ParentRecordId;
			CMN_DAL_SObjectDomain.insertDBObject(comment);
		}
	}

	/**
	 * @description This will delete the existing document checklist item record and insert a new record whenever Required checkbox field is updated
	 *
	 * @param documentChecklistId The Id of the documentChecklistItem
	 * @param newChecklistItem The documentChecklistItem to be inserted
	 *
	 * @return id of the new documentChecklistItem record
	 */
	@AuraEnabled
	public static String replaceDocumentChecklist(String documentChecklistId, DocumentChecklistItem newChecklistItem)
	{
		String newChecklistItemId;
		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(DocumentChecklistItem.SObjectType, SC_DAL_DocumentChecklistItem.RT_CASE_DOCUMENT);

		DocumentChecklistItem existingChecklistItem = SC_DAL_DocumentChecklistItem.findById(new Set<Id> {documentChecklistId}).iterator().next();

		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork();
		unitOfWork.addSObjectTypes(new List<Schema.SObjectType> {DocumentChecklistItem.SObjectType});

		unitOfWork.registerDeleted(existingChecklistItem);

		if(newChecklistItem != null)
		{
			newChecklistItem.RecordTypeId = recordTypeId;
			unitOfWork.registerNew(newChecklistItem);
		}

		unitOfWork.commitWork();
		newChecklistItemId = newChecklistItem.Id;

		return newChecklistItemId;
	}

	/**
	 * @description method used to delete Upload failed DocumentCheckListItem based on Id
	 *
	 * @param documentId The documentItem to be deleted
	 */
	@AuraEnabled
	public static void deleteNonVaultedDocuments(String documentId)
	{
		CMN_DAL_SObjectDomain.deleteDBObject(SC_DAL_DocumentChecklistItem.findById(documentId));
	}

	/**
	 * @description Provides the outcome of the API callout
	 */
	public class DTO_Response
	{
		/**
		 * @description stores the success or failure status of the API callout
		 */
		@AuraEnabled
		public Boolean callSuccessful;
		/**
		 * @description stores the message from the API callout
		 */
		@AuraEnabled
		public String callMessage;
		/**
		 * @description stores the contentDocumentId returned from the API callout
		 */
		@AuraEnabled
		public String contentDocumentId;
		/**
		 * @description stores the vaultedDocuments returned from the API callout
		 */
		@AuraEnabled
		public List<CMN_API_FetchVaultedDocuments.DTO_VaultedDocumentChecklistItem> vaultedDocuments;
	}
}