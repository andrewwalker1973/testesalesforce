/**
 * @description Class that stores the common methods for Document Vault and Insto Client Onboarding
 *
 * @author Futureform
 *
 * @date March 2023
 */
public without sharing class SLC_CTRL_VaultedDocuments_Opportunity {    
	private static final String UPLOAD_SUCCESS_MESSAGE = 'Upload Successful';
    
	/**
	 * @description Will retrieve all Document Checklist Items related to the recordId in Opp Insto Onboarding
	 *
	 * @param recordId The Id of the record to which the DocumentChecklistItems are linked
	 *
	 * @return A list of the DocumentChecklistItem records
	 */
	@AuraEnabled
	public static List<DocumentChecklistItem> getDocuments(Id recordId){
        //If external
		if(recordId.getSobjectType() == Account.getSObjectType()){
			return SLC_DAL_DocumentChecklistItem.getExternalOnboardingDocs(recordId); 
        //If internal
		} else if(recordId.getSobjectType() == Opportunity.getSObjectType()){
			return SLC_DAL_DocumentChecklistItem.findByParentAndDocType(
					recordId, (List<String>) CMN_UTIL_Set.setToList(getOnboardingDocumentTypes().keySet())
			);
		}

		return null;
	}

	/**
	 * @description Fetches all SLC_Document_Type_Mapping__mdt records where Onboarding Accessibility is not null
	 *
	 * @return Map of 4-digit Document Code to corresponding SLC_Document_Type_Mapping__mdt record
	 */     
    @AuraEnabled(Cacheable=true)
    public static Map<String, SLC_Document_Type_Mapping__mdt> getOnboardingDocumentTypes(){
        Map<String, SLC_Document_Type_Mapping__mdt> codeToType = new Map<String, SLC_Document_Type_Mapping__mdt>();
        
		List<SLC_Document_Type_Mapping__mdt> onboardingCodes = [
                SELECT Id, Document_Code__c, Onboarding_Accessibility__c, Internal_Only__c
                FROM SLC_Document_Type_Mapping__mdt
                WHERE Onboarding_Accessibility__c != NULL
        ];

		for(SLC_Document_Type_Mapping__mdt onboardingCode: onboardingCodes){
			codeToType.put(onboardingCode.Document_Code__c, onboardingCode);
		}

		return codeToType;
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
		return SLC_CTRL_ContentDocuments.getDocumentDownloadUrl(recordId, vaultedId, isExternal);
	}

	/**
	 * @description method used to get ContentVersion linked to given record
	 *
	 * @param recordId is the Id of Document to which ContentVersion is linked
	 * @param vaultedId is the vault Id of the document stored in external system
	 *
	 * @return returns dtoResponse for object retrieved or indicates an error with message
	 */
	@AuraEnabled
	public static SLC_CTRL_VaultedDocuments_Opportunity.DTO_Response getContentDocument(Id recordId, String vaultedId){
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
				(
						SLC_API_GetContentDocument.SERVICE_NAME,
						recordId,
						new Map<String, String> {
								SLC_API_GetContentDocument.PARAMETER_VAULTED_ID => vaultedId,
								SLC_API_GetContentDocument.LINKED_OBJECT_ID => recordId
						}

				);

		SLC_API_GetContentDocument viewDocsHandler = (SLC_API_GetContentDocument)CMN_FACTORY_WebserviceManager.execute
				(
						new List<CMN_WebserviceCallQueue__c> {queueItem}
				).iterator().next();

		DTO_Response dtoResponse = new DTO_Response();

		if(!viewDocsHandler.callResult.completed){
			dtoResponse.callMessage = String.join(viewDocsHandler.callResult.errors, CMN_UTIL_String.LF);
		} else if(String.isNotBlank(viewDocsHandler.contentDocumentId)){
			dtoResponse.contentDocumentId = viewDocsHandler.contentDocumentId;
		}

		dtoResponse.callSuccessful = viewDocsHandler.callResult.completed;

		return dtoResponse;
	}
    
    /**
     * @description Method used to upload documents under the record
     *
     * @param documentCheckList checkListItem record that has to be uploaded
     *
     * @return vaultedDocsHandler or will throw an exception if API callout fails
     */
	@AuraEnabled
	public static DTO_Response uploadDocuments(List<String> documentCheckList){
		String itemId = documentCheckList.iterator().next();

		List<CMN_WebserviceCallQueue__c> queueItemList = new List<CMN_WebserviceCallQueue__c>();
		List<String> errorMessages = new List<String>();

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(SLC_API_UploadDocumentToVault.SERVICE_NAME, itemId);
		queueItemList.add(queueItem);

		SLC_API_UploadDocumentToVault vaultedDocsHandler = (SLC_API_UploadDocumentToVault)CMN_FACTORY_WebserviceManager.execute(queueItemList).iterator().next();

		if(!vaultedDocsHandler.callResult.completed){
			//If aborted, error will store the aborted error message, else it will store the error message obtained on API callout failure
			String error = String.isNotBlank(vaultedDocsHandler.errorMessage) 
                ? vaultedDocsHandler.errorMessage 
                : String.join(vaultedDocsHandler.callResult.errors, CMN_UTIL_String.LF);
			errorMessages.add(error);
		}

		DTO_Response dtoResponse = new DTO_Response(); 
		dtoResponse.callSuccessful = errorMessages.size() > 0 ? false : true;
		dtoResponse.callMessage = dtoResponse.callSuccessful ? UPLOAD_SUCCESS_MESSAGE : errorMessages.iterator().next();

		return dtoResponse;
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