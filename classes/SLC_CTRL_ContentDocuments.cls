/**
 * @description Forms the download url for download of documents on Document Vault / Insto Onboarding
 *
 * @author Futureform
 *
 * @date December 2022
 */

public inherited sharing class SLC_CTRL_ContentDocuments {
    public static final String CLIENT_PORTAL_NAME = 'STANLIB Client Portal';

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
    public static String getDocumentDownloadUrl(Id recordId, String vaultedId, Boolean isExternal) {
        SLC_CTRL_VaultedDocuments_Opportunity.DTO_Response response = SLC_CTRL_VaultedDocuments_Opportunity.getContentDocument(recordId, vaultedId);

        if(response.callSuccessful){
            String fileDownloadUrl = URL.getSalesforceBaseUrl().toExternalForm();

            //First need to share the document with user so they can acccess the file upon download
            if(isExternal != null && isExternal){
				User u = [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId()];
                
                if(u.AccountId != null){
                    List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
                    contentDocumentLinks = [
                            SELECT Id
                            FROM ContentDocumentLink
                            WHERE LinkedEntityId =: u.AccountId AND ContentDocumentId = :response.contentDocumentId
                    ];                    
    
                    if (contentDocumentLinks.isEmpty()) {
                        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                                LinkedEntityId = u.AccountId,
                                ContentDocumentId = response.contentDocumentId,
                                ShareType = 'V',
                                Visibility = 'AllUsers'
                        );
                        insert contentDocumentLink;
                    }
                    
                    Boolean runningInSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                    if(runningInSandbox){
                        Site site = [SELECT Id, UrlPathPrefix FROM Site WHERE MasterLabel = :CLIENT_PORTAL_NAME LIMIT 1];
                        fileDownloadUrl += '/' + site.UrlPathPrefix.removeEnd('/s');
                    }
                }
            } else {
                User u = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
                
                List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
                contentDocumentLinks = [
                    SELECT Id
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId =: u.Id AND ContentDocumentId = :response.contentDocumentId
                ];  
                
                if(contentDocumentLinks.isEmpty()){
                    ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                        LinkedEntityId = u.Id,
                        ContentDocumentId = response.contentDocumentId,
                        ShareType = 'V',
                        Visibility = 'AllUsers'
                    );
                    insert contentDocumentLink;
                    }                
            }
            
            fileDownloadUrl += '/sfc/servlet.shepherd/document/download/';
            fileDownloadUrl += response.contentDocumentId;
            fileDownloadUrl += '?operationContext=S1';             
            
            system.debug(fileDownloadUrl);
            return fileDownloadUrl;
        } else {
            throw new AuraHandledException(String.isNotBlank(response.callMessage) ? response.callMessage : Label.RSC_NoFilesToDisplay);
        }
    }

}