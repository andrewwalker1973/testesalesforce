/**
 * @description Controller for retrieving all vaulted document for a record
 *
 * @author Futureform
 *
 * @date October 2022
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class SLC_CTRL_VaultedDocuments_Account {
    /**
	 * @description Will retrieve all Accounts and Financial Account records related to recordId
	 *
	 * @param recordId The Id of the record to which the Documents are linked
	 * @param isExternal The mark the that is portal user
	 *
	 * @return A map of the record name and its corresponding index field
	 */

	@AuraEnabled(Cacheable=true)
	public static Map<String, String> getAccountOptions(Id recordId, Boolean isExternal) {
        isExternal = isExternal != null && isExternal;
		Map<String, String> options = new Map<String, String>();

		if (recordId.getSobjectType() != Account.getSObjectType()) {
			return null;
		}

		Account account = SLC_DAL_Account.findById(recordId);
		options.put(account.Id, account.Name + ' - ' + (account.IsPersonAccount ? account.SLC_IDNumber__c : account.AccountNumber));
        
        //Add the portal User's related Accounts
        if(isExternal){
            List<Account> relatedAccs = SLC_DAL_Account.findACRAccounts(recordId);            
            for(Account acc : relatedAccs){
                options.put(acc.Id, acc.Name + ' - ' + (acc.IsPersonAccount ? acc.SLC_IDNumber__c : acc.AccountNumber));
            }
        }

		List<FinServ__FinancialAccount__c> financialAccounts = SLC_DAL_Account.findChildFinancialAccounts(recordId, isExternal);

		for (FinServ__FinancialAccount__c financialAccount: financialAccounts) {
			options.put(financialAccount.Id, financialAccount.Name + ' - ' + financialAccount.FinServ__FinancialAccountNumber__c);
		}
        
		options.put(account.SLC_IDNumber__c, 'Fund Documents');
		return options;
	}

	/**
	 * @description Will retrieve all Document Checklist Items related to the recordId in Opp Insto Onboarding
	 *
	 * @param recordId The Id of the record to which the DocumentChecklistItems are linked
	 *
	 * @return A list of the DocumentChecklistItem records
	 */
	@AuraEnabled
	public static List<DocumentChecklistItem> getDocuments(Id recordId){
        return SLC_CTRL_VaultedDocuments_Opportunity.getDocuments(recordId);
	}

	/**
	 * @description method used to de-link Document from recordId in Horizon
	 *
	 * @param documentIds The documents to be un-linked to recordId
	 * @param recordId The Id or record that document is linked to
	 * @param deLinkReason Reason to un-link the documents
	 *
	 * @return A boolean variable to indicate if there was any error when de-linking the documents
	 */
	@AuraEnabled
	@SuppressWarnings('PMD.CognitiveComplexity')
	public static String deLinkDocumentItem(List<String> documentIds, String recordId, String deLinkReason){
		List<CMN_WebserviceCallQueue__c> queueItems = new List<CMN_WebserviceCallQueue__c>();

		for(String documentId : documentIds){
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
					(
							SLC_API_DelinkDocumentsFromAccount.SERVICE_NAME, recordId,
							new Map<String, String>{
									SLC_API_DelinkDocumentsFromAccount.PARAMETER_REASON => deLinkReason,
									SLC_API_DelinkDocumentsFromAccount.PARAMETER_DOCUMENT_ID => documentId
							}
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
			SLC_API_DelinkDocumentsFromAccount deLinkedDocsHandler = (SLC_API_DelinkDocumentsFromAccount)handler;
			Id documentId;
			try {
				Map<String, String> requestBody = (Map<String, String>) JSON.deserialize(deLinkedDocsHandler.callResult.requestBody, Map<String, String>.class);
				documentId = requestBody.get(SLC_API_DelinkDocumentsFromAccount.PARAMETER_DOCUMENT_ID);
			} catch (Exception e) {
				System.debug(e);
			}
			if(!deLinkedDocsHandler.callResult.completed)
			{
				String error = CMN_UTIL_String.EMPTY;

				if(!deLinkedDocsHandler.callResult.errors.isEmpty())
				{
					error = String.join(deLinkedDocsHandler.callResult.errors, CMN_UTIL_String.LF);
				}
				else
				{
					error = deLinkedDocsHandler.errorMessage;
				}
				errorMessages.add(error);
				documentIdToErrorMessage.put(documentId, error);
			}
			else
			{
				deletedDocumentIds.add(documentId);
			}
		}
        
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork();
		unitOfWork.addSObjectTypes(new List<Schema.SObjectType>
		{
				DocumentChecklistItem.SObjectType
		});

		// Delete all documents those are successfully de-linked from the external system
		if(!deletedDocumentIds.isEmpty())
		{
			List<DocumentChecklistItem> documentChecklistItems = SC_DAL_DocumentChecklistItem.findById(deletedDocumentIds);

			if(!documentChecklistItems.isEmpty())
			{
				unitOfWork.registerDeleted(documentChecklistItems);
			}
		}

		unitOfWork.commitWork();

		return errorMessages.isEmpty() ? 'Success' : String.join(errorMessages,'.\n');
	}

	/**
	 * @description method used to insert DocumentCheckListItem into Salesforce for Document Vault
	 *
	 * @param checklistItems The DocumentChecklistItems to be upserted
	 * @param file The content of the file that needs to be attached with the Document Checklist Item
	 * @param fileName The name of the file that needs to be attached with the Document Checklist Item
	 *
	 * @return list of inserted DocumentChecklistItem Id
	 */
	@AuraEnabled
	@SuppressWarnings('PMD.ApexCRUDViolation')
	public static List<String> saveRecord(List<DocumentChecklistItem> checklistItems, String file, String fileName){        
		List<String> newDocumentListIds = new List<String>();
		List<DocumentChecklistItem> itemToUpsert = new List<DocumentChecklistItem>();

		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(DocumentChecklistItem.SObjectType, SC_DAL_DocumentChecklistItem.RT_CASE_DOCUMENT);

		for(DocumentChecklistItem newItem : checklistItems){
			newItem.RecordTypeId = recordTypeId;
			itemToUpsert.add(newItem);
		}
		upsert itemToUpsert;

        for(DocumentChecklistItem items : itemToUpsert){
			newDocumentListIds.add(items.Id);
		}

		//Content Version creation happens only for the Upload action i.e. when a file is attached. Only 1 document checklist item is processed at a time.
		if(!Test.isRunningTest() && String.isNotBlank(file) && String.isNotBlank(fileName) && !newDocumentListIds.isEmpty()){
			for(String newItemId : newDocumentListIds){
				createContentVersion(newItemId, file, fileName);
			}
		}

		return newDocumentListIds;
	}

	/**
	 * @description Will create a ContentVersion record; used when there is a file is attached during Upload action
	 *
	 * @param documentCheckListId the parentId to be linked with contentVersion
	 * @param file the file to be attached with contentVersion
	 * @param fileName name of the file to be attached with contentVersion
	 *
	 * @return Boolean true if ContentVersion record is created else false
	 */
	@AuraEnabled
	public static Boolean createContentVersion(String documentCheckListId, String file, String fileName){
		return String.isNotBlank(RSC_DAL_TestDataFactory.createContentVersion(documentCheckListId, file, fileName).Id);
	}

	/**
	 * @description Will retrieve Document Type by its code
	 *
	 * @param documentCodes The list of codes of the record to be found
	 *
	 * @return List of Document Type records
	 */
	@AuraEnabled
	public static List<DocumentType> getDocumentTypeByCode(List<String> documentCodes){
		return SLC_DAL_DocumentType.findByDeveloperName(CMN_UTIL_Set.listToSet(documentCodes));
	}

	/**
	 * @description Fetches all SLC_Document_Type_Mapping__mdt records where Onboarding Accessibility is not null
	 *
	 * @return Map of 4-digit Document Code to corresponding SLC_Document_Type_Mapping__mdt record
	 */    
    @AuraEnabled(Cacheable=true)
    public static Map<String, SLC_Document_Type_Mapping__mdt> getOnboardingDocumentTypes(){
        return SLC_CTRL_VaultedDocuments_Opportunity.getOnboardingDocumentTypes();
    }

	/**
	 * @description Fetches all SLC_Document_Type_Mapping__mdt records where Legal_Sub_Type__c != NULL
	 * 
	 * @return Map of 4-digit Document Code to corresponding Legal Subtype value
	 */ 
	@AuraEnabled(Cacheable=true)
	public static Map<String, String> getLegalSubtypes(){
   	    Map<String, String> codeToType = new Map<String, String>();
        
		List<SLC_Document_Type_Mapping__mdt> legalCodes = [
				SELECT Id, Document_Code__c, Legal_Sub_Type__c
				FROM SLC_Document_Type_Mapping__mdt
				WHERE Legal_Sub_Type__c != NULL
		];

		for(SLC_Document_Type_Mapping__mdt legalCode: legalCodes) {
			codeToType.put(legalCode.Document_Code__c, legalCode.Legal_Sub_Type__c);
		}

		return codeToType;
	}
    
	/**
	 * @description Fetches values in Legal_Sub_Type__c picklist on SLC_Document_Type_Mapping__mdt object
	 * 
	 * @return List of picklist values
	 */     
	@AuraEnabled(Cacheable=true)
	public static List<String> getLegalSubtypeOptions(){
		List<String> pickListValues = new List<String>();
		Schema.DescribeFieldResult pickList = SLC_Document_Type_Mapping__mdt.Legal_Sub_Type__c.getDescribe();

		for( Schema.PicklistEntry pickVal : pickList.getPicklistValues()){
			pickListValues.add(pickVal.getValue());
		}

		return pickListValues;
	}
    
	/**
	 * @description Fetches all SLC_Document_Type_Mapping__mdt records where Report_Sub_Type__c != NULL
	 * 
	 * @return Map of 4-digit Document Code to corresponding Report Subtype value
	 */     
	@AuraEnabled(Cacheable=true)
	public static Map<String, String> getReportSubtypes(){
		Map<String, String> codeToType = new Map<String, String>();

		List<SLC_Document_Type_Mapping__mdt> reportCodes = [
				SELECT Id, Document_Code__c, Report_Sub_Type__c
				FROM SLC_Document_Type_Mapping__mdt
				WHERE Report_Sub_Type__c != NULL
		];

		for (SLC_Document_Type_Mapping__mdt reportCode: reportCodes) {
			codeToType.put(reportCode.Document_Code__c, reportCode.Report_Sub_Type__c);
		}

		return codeToType;
	}

	/**
	 * @description Fetches values in Report_Sub_Type__c picklist on SLC_Document_Type_Mapping__mdt object
	 * 
	 * @return List of picklist values
	 */   
	@AuraEnabled(Cacheable=true)
	public static List<String> getReportSubtypeOptions(){
		List<String> pickListValues = new List<String>();
		Schema.DescribeFieldResult pickList = SLC_Document_Type_Mapping__mdt.Report_Sub_Type__c.getDescribe();

		for( Schema.PicklistEntry pickVal : pickList.getPicklistValues()){
			pickListValues.add(pickVal.getValue());
		}

		return pickListValues;
	}
    
	/**
	 * @description Fetches all SLC_Document_Type_Mapping__mdt records where Communication_Sub_Type__c != NULL
	 * 
	 * @return Map of 4-digit Document Code to corresponding Communication Subtype value
	 */     
	@AuraEnabled(Cacheable=true)
	public static Map<String, String> getCommunicationSubtypes(){
		Map<String, String> codeToType = new Map<String, String>();
        
		List<SLC_Document_Type_Mapping__mdt> commCodes = [
				SELECT Id, Document_Code__c, Communication_Sub_Type__c
				FROM SLC_Document_Type_Mapping__mdt
				WHERE Communication_Sub_Type__c != NULL
		];

		for (SLC_Document_Type_Mapping__mdt commCode: commCodes) {
			codeToType.put(commCode.Document_Code__c, commCode.Communication_Sub_Type__c);
		}

		return codeToType;
	}

	/**
	 * @description Fetches values in Communication_Sub_Type__c picklist on SLC_Document_Type_Mapping__mdt object
	 * 
	 * @return List of picklist values
	 */
	@AuraEnabled(Cacheable=true)
	public static List<String> getCommunicationSubtypeOptions(){
		List<String> pickListValues = new List<String>();
		Schema.DescribeFieldResult pickList = SLC_Document_Type_Mapping__mdt.Communication_Sub_Type__c.getDescribe();

		for( Schema.PicklistEntry pickVal : pickList.getPicklistValues()){
			pickListValues.add(pickVal.getValue());
		}

		return pickListValues;
	}
    
	@AuraEnabled(Cacheable=true)
	public static Map<String, String> getPresentationSubtypes()
	{
		List<SLC_Document_Type_Mapping__mdt> onboardingCodes = [
				SELECT
						Id, Document_Code__c, Presentation_Sub_Type__c
				FROM SLC_Document_Type_Mapping__mdt
				WHERE Presentation_Sub_Type__c != NULL
		];

		Map<String, String> codeToType = new Map<String, String>();

		for (SLC_Document_Type_Mapping__mdt onboardingCode: onboardingCodes) {
			codeToType.put(onboardingCode.Document_Code__c, onboardingCode.Presentation_Sub_Type__c);
		}

		return codeToType;
	}

	/**
	 * @description Fetches all SLC_Document_Type_Mapping__mdt records where Presentation_Sub_Type__c != NULL
	 * 
	 * @return Map of 4-digit Document Code to corresponding Presentation Subtype value
	 */    
	@AuraEnabled(Cacheable=true)
	public static List<String> getPresentationSubtypeOptions(){
		List<String> pickListValues = new List<String>();
		Schema.DescribeFieldResult pickList = SLC_Document_Type_Mapping__mdt.Presentation_Sub_Type__c.getDescribe();

		for( Schema.PicklistEntry pickVal : pickList.getPicklistValues()){
			pickListValues.add(pickVal.getValue());
		}

		return pickListValues;
	}

	/**
	 * @description method used to form download URL upon 'Download' action
	 *
	 * @param recordId is the Id of Document to which ContentVersion is linked
	 * @param vaultedId is the vault Id of the document stored in external system
	 * @param isExternal is the mark that the document is being retrieved for a portal user
	 *
	 * @return Returns download url
	 */
	@AuraEnabled
	public static String getDocumentDownloadUrl(Id recordId, String vaultedId, Boolean isExternal){
		return SLC_CTRL_VaultedDocuments_Opportunity.getDocumentDownloadUrl(recordId, vaultedId, isExternal);
	}

	/**
	 * @description Method used to retrieve all vaulted documents for the given record
	 *
	 * @param recordId The Id of the record from which vaulted documents has to be fetched for Document Vault
	 * @param tabTypes The name of tab for which documents has to be fetched
	 * @param isFundDoc The mark for fetching documents by uniqueInternalCode
	 *
	 * @return A list of vaulted records or a indicates if a error was encountered
	 */
	@AuraEnabled
	public static DTO_Response getVaultedDocuments(Id recordId, String tabTypes, Boolean isFundDoc){
		isFundDoc = isFundDoc != null && isFundDoc;
		String serviceName = SLC_API_FetchVaultedDocuments.SERVICE_NAME; 

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
				serviceName,
				recordId,
				SLC_API_FetchVaultedDocuments.IS_FUND_DOC_PARAMETER,
				String.valueOf(isFundDoc));

		SLC_API_FetchVaultedDocuments handler = (SLC_API_FetchVaultedDocuments)CMN_FACTORY_WebserviceManager.execute
				(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

		DTO_Response dtoResponse = new DTO_Response(); 
		if(!handler.callResult.completed){
			dtoResponse.callMessage = String.join(handler.callResult.errors, CMN_UTIL_String.LF);
		}

		dtoResponse.vaultedDocuments = String.isBlank(tabTypes) || handler.vaultedDocuments == null
				? handler.vaultedDocuments
				: filterVaultedDocs(handler.vaultedDocuments, tabTypes); 
		dtoResponse.callSuccessful = handler.callResult.completed;

		return dtoResponse;
	}

	/**
	 * @description Method used to filter documents per tab chosen
	 *
	 * @param vaultedDocs The vaulted documents returned by SLC_API_FetchVaultedDocuments
	 * @param tabTypes The name of tab for which documents has to be fetched
	 *
	 * @return A list of vaulted documents specific to given tab type
	 */
    private static List<SLC_API_FetchVaultedDocuments.DTO_VaultedDocumentChecklistItem> filterVaultedDocs(List<SLC_API_FetchVaultedDocuments.DTO_VaultedDocumentChecklistItem> vaultedDocs, String tabTypes){
        List<SLC_Document_Type_Mapping__mdt> documentTypeMappings = getDocumentTypeMapping(tabTypes.split(','));
        Set<String> codes = new Set<String>();

        for (SLC_Document_Type_Mapping__mdt mapping: documentTypeMappings) {
            codes.add(mapping.Document_Code__c);
        }

        List<SLC_API_FetchVaultedDocuments.DTO_VaultedDocumentChecklistItem> filteredVaultedDocs = new List<SLC_API_FetchVaultedDocuments.DTO_VaultedDocumentChecklistItem>();
        for (SLC_API_FetchVaultedDocuments.DTO_VaultedDocumentChecklistItem doc : vaultedDocs) {
            if (codes.contains(doc.documentTypeCode)) {
                filteredVaultedDocs.add(doc);
            }
        }

        return filteredVaultedDocs;
    }

	/**
	 * @description Method used to extract SLC_Document_Type_Mapping__mdt records that fall into given tab type
	 *
	 * @param tabTypes The name of tab for which records have to be fetched
	 *
	 * @return A list SLC_Document_Type_Mapping__mdt records where document type falls into tabTypes
	 */
    @AuraEnabled(Cacheable=true)
    public static List<SLC_Document_Type_Mapping__mdt> getDocumentTypeMapping(List<String> tabTypes){
        return [SELECT Id, MasterLabel, Document_Code__c, Type__c FROM SLC_Document_Type_Mapping__mdt WHERE Type__c IN :tabTypes];
    }

    /**
     * @description Method used to upload documents under the record
     *
     * @param documentCheckList checkListItem record that has to be uploaded
     *
     * @return vaultedDocsHandler or will throw an exception if API callout fails
     */
	@AuraEnabled
	public static SLC_CTRL_VaultedDocuments_Opportunity.DTO_Response uploadDocuments(List<String> documentCheckList){
		return SLC_CTRL_VaultedDocuments_Opportunity.uploadDocuments(documentCheckList);
	}

	/**
	 * @description Will retrieve Document Type by its MasterLabel
	 *
	 * @param masterLabels The list of names of the record to be found
	 *
	 * @return List of Document Type records
	 */
	@AuraEnabled
	public static List<DocumentType> getDocumentTypeByName(List<String> masterLabels){
		return SLC_DAL_DocumentType.findByName(CMN_UTIL_Set.listToSet(masterLabels));
	}

	/**
	 * @description Will retrieve Document Types by the child Document Checklist Items
	 *
	 * @param documentIds The list of document ids of the records to be found
	 *
	 * @return List of Document Type records
	 */
	@AuraEnabled
	public static List<DocumentType> getDocumentTypeByIds(List<String> documentIds){
        List<DocumentChecklistItem> checkItems = [SELECT Id, Name, DocumentType.MasterLabel, DocumentType.Id, DocumentType.DeveloperName
                                                  FROM DocumentChecklistItem WHERE CMN_VaultedId__c IN : documentIds];

        List<String> docTypeIds = new List<String>();
        if(checkItems.size() > 0){
            for(DocumentChecklistItem checklst : checkItems){
                docTypeIds.add(checklst.DocumentType.Id);
            }
        }

        return SLC_DAL_DocumentType.findByIds(CMN_UTIL_Set.listToSet(docTypeIds));
	}

	/**
	 * @description Will retrieve logged in portal user's details
	 *
	 * @param userId is logged in user's id
	 *
	 * @return user details
	 */
	@AuraEnabled
    public static User getPortalUserDetails(String userId){
        User portalUser = [SELECT Id, FirstName, LastName, AccountId, ContactId FROM User
                          WHERE Id =: userId];

		return portalUser;
    }

	/**
	 * @description Will convert inputted Document Date into Date/Time
	 *
	 * @param docDate is inputted Document Date 
	 *
	 * @return Date/Time
	 */
	@AuraEnabled
    public static DateTime getDocumentDateTime(Date docDate){        
		DateTime docDateTime = docDate;
		return docDateTime;
    }
    
	/**
	 * @description Provides the outcome of the API callout
	 */
	public class DTO_Response {
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
		public List<SLC_API_FetchVaultedDocuments.DTO_VaultedDocumentChecklistItem> vaultedDocuments;
	}
}