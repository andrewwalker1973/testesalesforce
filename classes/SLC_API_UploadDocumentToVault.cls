/**
 * @description Service class to make the API call to notify Mulesoft to retrieve a document and upload it to the vault
 *
 * @author Futureform
 *
 * @date December 2022
 */
public inherited sharing class SLC_API_UploadDocumentToVault extends CMN_API_RestBaseOutboundMule {
    private String personId;
    private static final String ERROR_INCORRECT_OBJECT_TYPE = 'Item was not processed as it is linked to an Object other than an Account or Opportunity';
    private static final String ERROR_ITEM_NOT_FOUND = 'Unable to process request as no Check List Item was found.';
    private static final String ERROR_NO_CONTENT_VERSION = 'Unable to process request as the Check List Item has no document associated with it.';
    private static final String ERROR_NO_UACF_ID = 'Unable to process the request as the current user does not have an UACF Id.';
    private static final String ERROR_NO_OPP_ACCNUMBER = 'Unable to process the request as the Account linked to this Opportunity has no AccountNumber.';
    private static final String ERROR_UNEXPECTED = 'An unexpected error occurred.';
    private static final String RESPONSE_ERROR = '{"error":{"errorCode":400,"errorDateTime":"2021-08-20T09:49:53","errorMessage":"User name not found",' +
            '"errorDescription":"This user is not associated with UACF Id"}}';
    private static final String NO_UACF_ID = 'UACF0';

    /**
     * @description API class name from the service
     */
    public static final String SERVICE_NAME = SLC_API_UploadDocumentToVault.class.getName();

    private static final Set<SObjectType> ALLOWED_OBJECT_TYPES = new Set<SObjectType>{
            Account.SObjectType,
            Opportunity.SObjectType,
            FinServ__FinancialAccount__c.SObjectType,
            Lead.SObjectType
    };

    /**
     * @description Override to set request and response DTO types and any other globals which may be used
     */
    protected override void initialise() {
        super.initialise();

        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
    }

    /**
     * @description Override to get Service name to be used when looking up custom settings for the service
     *
     * @return String Returns service name as string
     */
    protected override String getServiceName() {
        return SERVICE_NAME;
    }

    /**
     * @description Main process loop which controls the processing of outbound request and ensure result of call is logged
     *
     * @param queueItem The queueItem which will ultimately saved to record activity of webservice object
     */

    public override void process(CMN_WebserviceCallQueue__c queueItem) {
        super.process(queueItem);

        //We must make sure that the document is always deleted irrespective of the API call being successful or not
        if (((DTO_Request) baseRequestDTO).foundVersion != null) {
            registerDeleted(new ContentDocument(Id = ((DTO_Request) baseRequestDTO).foundVersion.ContentDocument.Id));
        }
    }

    /**
     * @description Override to validate if all the information required to make API call is available
     *
     * @return Boolean Returns true if all the information is present, else will return false
     */
    @SuppressWarnings('PMD.CognitiveComplexity')
    protected override Boolean abortRequest() {
        system.debug('abort request upload');
        
        Boolean mustAbort = super.abortRequest();

        Id triggeringObjectId = CMN_UTIL_String.validateId(queueItem.CMN_TriggeringObjectId__c);
        SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(triggeringObjectId);

        // Override allowed object Types
        if (ALLOWED_OBJECT_TYPES.contains(objectType)) {
            mustAbort = false;
            callResult.errors.remove(callResult.errors.size() - 1);
        }

        if (!mustAbort) {
            User userFound = AW_DAL_User.findById(UserInfo.getUserId());

            personId = userFound.AW_UACFID__c;

            if (String.isBlank(personId)) {
                personId = NO_UACF_ID;
            }

            DTO_Request dtoRequest = (DTO_Request) baseRequestDTO;

            dtoRequest.foundCheckListItem = SC_DAL_DocumentChecklistItem.findById(queueItem.CMN_TriggeringObjectId__c);

            if (dtoRequest.foundCheckListItem == null) {
                mustAbort = true;
                callResult.errors.add(ERROR_ITEM_NOT_FOUND);
            } else {
                objectType = CMN_UTIL_System.getSObjectTypeById(dtoRequest.foundCheckListItem.ParentRecordId);

                if (objectType != Account.SObjectType
                        && objectType != Opportunity.SObjectType
                        && objectType != FinServ__FinancialAccount__c.SObjectType) {
                    mustAbort = true;
                    callResult.errors.add(ERROR_INCORRECT_OBJECT_TYPE);
                }

                List<ContentVersion> foundVersions = CMN_DAL_ContentVersion.findByFirstPublishLocationId(dtoRequest.foundCheckListItem.Id);

                if (foundVersions.isEmpty()) {
                    mustAbort = true;
                    callResult.errors.add(ERROR_NO_CONTENT_VERSION);
                } else {
                    dtoRequest.foundVersion = foundVersions.iterator().next();
                }
            }
        }

        return mustAbort;
    }

    /**
     * @description Inner class to define structure of request body and populate the same for API call
     */
    public class DTO_Request extends CMN_DTO_JsonBase {
        private Boolean attachToCase;
        private String documentTypeText;
        private String caseNumber;
        private String documentTypeCode;
        private String emailAddress;
        private String documentType;
        private String fileName;
        private String name;
        private String surname;
        private String identityNumber;
        private List<DTO_Attribute> attributes;
        private String versionId;
        private String sourceId;
        private String documentContent;
        private DateTime documentDate;
        private transient ContentVersion foundVersion;
        private transient DocumentChecklistItem foundCheckListItem;

        public override void populate(Id triggeringObjectId) {
            super.populate(triggeringObjectId);

            DocumentChecklistItem checklistItem = AW_DAL_DocumentChecklistItem.findById(triggeringObjectId);

            fileName = foundVersion.Title;
            sourceId = UserInfo.getUserId();
            documentTypeCode = checklistItem.DocumentType.Description;
            documentType = checklistItem.DocumentType.DeveloperName;
            documentTypeText = checklistItem.DocumentType.MasterLabel;
            versionId = foundVersion.ContentDocument.LatestPublishedVersionId;
            documentDate = checklistItem.AW_DateVaulted__c;
            //documentContent = EncodingUtil.base64Encode(foundVersion.VersionData);  
            documentContent = '';          
            
            String todaysDateStr;            
            if(documentDate != null){
                DateTime todaysDate = documentDate;
                todaysDateStr = todaysDate.format('yyyy-MM-dd');                
            } else {
                DateTime todaysDate = System.today();
                todaysDateStr = todaysDate.format('yyyy-MM-dd');    
            }

            if (checklistItem.ParentRecordId.getSobjectType() == Account.getSObjectType()) {
                Account account = SLC_DAL_Account.findById(checklistItem.ParentRecordId);

                if (account.IsPersonAccount) {
                    attributes = new List<DTO_Attribute>{
                            new DTO_Attribute('identityNumber', account.SLC_IDNumber__c),
                            new DTO_Attribute('documentDate', todaysDateStr)    
                    };
                } else {
                    attributes = new List<DTO_Attribute>{
                            new DTO_Attribute('accountNumber', account.AccountNumber),
                            new DTO_Attribute('documentDate', todaysDateStr) 
                    };
                }
            } else if (checklistItem.ParentRecordId.getSobjectType() == Opportunity.getSObjectType()) {
                Opportunity opp = AW_DAL_Opportunity.findById(checklistItem.ParentRecordId);
                String accNumber = [SELECT Id, AccountNumber FROM Account WHERE Id =: opp.AccountId].AccountNumber;
                attributes = new List<DTO_Attribute>{
                        new DTO_Attribute('accountNumber', accNumber),
                        new DTO_Attribute('documentDate', todaysDateStr) 
                };
            } else if (checklistItem.ParentRecordId.getSobjectType() == FinServ__FinancialAccount__c.getSObjectType()) {
                FinServ__FinancialAccount__c financialAccount = AW_DAL_FinancialAccount.findById(checklistItem.ParentRecordId);
                attributes = new List<DTO_Attribute>{
                        new DTO_Attribute('financialAccountNumber', financialAccount.FinServ__FinancialAccountNumber__c),
                        new DTO_Attribute('documentDate', todaysDateStr) 
                };
            }
        }
    }

    public class DTO_Attribute extends CMN_DTO_JsonBase {
        public String itemName;
        public String itemValue;

        public DTO_Attribute(String itemName, String itemValue) {
            this.itemName = itemName;
            this.itemValue = itemValue;
        }
    }

    /**
     * @description Override to set SObject types for DML operation
     */
    protected override void setUnitOfWorksObjectTypes() {
        super.setUnitOfWorksObjectTypes();

        addSObjectTypes(new List<Schema.SObjectType>{
                DocumentChecklistItem.SObjectType, ContentVersion.SObjectType, ContentDocument.SObjectType
        });
    }

    /**
     * @description Will save updates
     */
    protected override void registerDatabaseChanges() {
        super.registerDatabaseChanges();

        DTO_Response dtoResponse = (DTO_Response) baseResponseDTO;
        DTO_Request dtoRequest = (DTO_Request) baseRequestDTO;

        dtoRequest.foundCheckListItem.AW_Vaulted__c = true;
        dtoRequest.foundCheckListItem.AW_DateVaulted__c = System.now();
        dtoRequest.foundCheckListItem.SC_UploadedWithCase__c = true;
        dtoRequest.foundCheckListItem.CMN_VaultedId__c = dtoResponse.documentId;
        
        registerChange(dtoRequest.foundCheckListItem);
    }

    /**
     * @description Inner class to define structure of response body
     */
    private class DTO_Response extends CMN_DTO_JsonBase {
        private String documentId;

        /**
         * @description The Type of the DTO used when deserializing the class
         *
         * @return Class of the DTO
         */
        protected override Type getObjectType() {
            return DTO_Response.class;
        }
    }

    /**
     * @description Used to parse an error response
     */
    private class DTO_ErrorResponse {
        private DTO_Error error;
    }

    /**
     * @description Detail of error received
     */
    @SuppressWarnings('ApexUnusedDeclaration')
    private class DTO_Error {
        private Integer errorCode;
        private String errorMessage;

    }

    /**
     * @description If API encounters an error, this method will provide a user friendly error message
     */
    public String errorMessage {
        get {
            String message;

            if (callResult.failed) {
                System.debug(callResult);
                DTO_ErrorResponse dtoErrorResponse = (DTO_ErrorResponse) JSON.deserialize(callResult.responseBody, DTO_ErrorResponse.class);
                message = dtoErrorResponse.error?.errorMessage;
                if (String.isBlank(message)) {
                    message = ERROR_UNEXPECTED;
                }
            }

            return message;
        }
    }

    /**
     * @description Override to construct API endpoint
     *
     * @return String Complete API Endpoint
     */
    protected override String getWebServiceEndPoint() {
        return String.format
                (
                        super.getWebServiceEndPoint(),
                        new List<String>{
                                EncodingUtil.urlEncode(personId, UTF8_ENCODING_SCHEME)
                        }
                );
    }

    /**
     * @description Override to return mock response for test class
     *
     * @return CMN_API_HttpBaseOutboundMock ARSC_API_UploadDocumentToVaultMock is extension class and contains Mock response
     */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
        return new RSC_API_UploadDocumentToVaultMock();
    }

    private class RSC_API_UploadDocumentToVaultMock extends CMN_API_HttpBaseOutboundMock {
        private final String validResponse = '{"message": "Document uploaded successfully.","documentId": "123456"}';

        protected override void setResponse(HttpRequest request, HttpResponse response) {
            super.setResponse(request, response);
            response.setBody(validResponse);
        }

        /**
         * @description Will set response in the event on exception
         *
         * @param response The response object on which to set the relevant body
         */
        protected override void setErrorResponse(HttpResponse response) {
            super.setErrorResponse(response);
            response.setBody(RESPONSE_ERROR);
        }
    }
}