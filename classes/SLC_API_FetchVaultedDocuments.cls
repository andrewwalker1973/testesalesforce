/**
 * @description Service class to make the API call to notify Mulesoft to fetch a document
 *
 * @author Futureform
 *
 * @date December 2022
 */
public with sharing class SLC_API_FetchVaultedDocuments extends CMN_API_RestBaseOutboundMule {

    private String identificationNumber;
    private static final String HEADER_ADVISOR_CONSULTANT_CODE = 'advisorConsultantCode';
    private static final String HEADER_AGENT_UACF_ID = 'agentUacfId';
    private static final String NO_IDENTIFICATION_NUMBER = 'Unable to process request as the object did not have an AccountNumber / SLC_IDNumber__c / FinServ__FinancialAccountNumber__c.';

    public static final String IS_FUND_DOC_PARAMETER = 'isFund';

    private static final String NAME_VALUE_SEPARATOR = '=';
    private static final String PARAM_SEPARATOR = '&';

    /**
     * @description Contains list of Objects whose Id can be processed
     */
    private static final Set<SObjectType> ALLOWED_OBJECT_TYPES = new Set<SObjectType>{
            Account.SObjectType,
            Opportunity.SObjectType,
            FinServ__FinancialAccount__c.SObjectType,
            Lead.SObjectType
    };

    /**
	 * @description Service name to be used when looking up custom settings
	 */
    public static final String SERVICE_NAME = SLC_API_FetchVaultedDocuments.class.getName();


    /**
     * @description Public property exposing the documents successfully retrieved
     */
    public List<DTO_VaultedDocumentChecklistItem> vaultedDocuments
    {
        get
        {
            DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;
            return dtoResponse.responses;
        }
    }

    protected virtual override void initialise()
    {
        super.initialise();
        baseResponseDTO = new DTO_Response();
    }

    protected override Boolean hasArrayResponse()
    {
        return true;
    }

    /**
     * @description Override to use Get HTTP Method for API call
     *
     * @return String
     */

    public override virtual String getVerb()
    {
        return HTTP_VERB_GET;
    }

    /**
     * @description Override to set header values
     */
    protected override void setHeaders()
    {
        super.setHeaders();

        User currentUser = AW_DAL_User.getCurrentUser();

        String consultantCode = currentUser.AW_ConsultantCode__c;
        String universalId = currentUser.AW_UACFID__c;

        if(String.isNotBlank(consultantCode) && String.isNotBlank(universalId))
        {
            request.setHeader(HEADER_ADVISOR_CONSULTANT_CODE, consultantCode);
            request.setHeader(HEADER_AGENT_UACF_ID, universalId);
        }

    }

    /**
     * @description Override to construct API endpoint
     *
     * @return String Complete API Endpoint
     */
    protected override String getWebServiceEndPoint()
    {
        return String.format
                (
                        super.getWebServiceEndPoint(),
                        new List<String>
                        {
                                EncodingUtil.urlEncode(identificationNumber, UTF8_ENCODING_SCHEME)
                        }
                );
    }

    @SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
    protected virtual override Boolean abortRequest()
    {
        Boolean mustAbort = super.abortRequest();

        if(!mustAbort)
        {
            Id triggeringObjectId = CMN_UTIL_String.validateId(queueItem.CMN_TriggeringObjectId__c);
            SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(triggeringObjectId);

            if(!ALLOWED_OBJECT_TYPES.contains(objectType))
            {
                mustAbort = true;
                callResult.errors.add('The Object Type "' + objectType.getDescribe().getLocalName() + '" is unsupported');
            }
            else
            {
                Id accountId = triggeringObjectId;

                if(objectType == Opportunity.SObjectType)
                {
                    Opportunity foundOpportunity = AW_DAL_Opportunity.findById(triggeringObjectId);
                    accountId = foundOpportunity?.AccountId;
                }
                else if(objectType == FinServ__FinancialAccount__c.SObjectType)
                {
                    FinServ__FinancialAccount__c financialAccount = AW_DAL_FinancialAccount.findById(triggeringObjectId);
                    accountId = financialAccount?.FinServ__PrimaryOwner__c;
                }

                Account foundAccount = SLC_DAL_Account.findById(accountId);
                if(foundAccount != null)
                {
                    identificationNumber = foundAccount.IsPersonAccount ? foundAccount.SLC_IDNumber__c : foundAccount.AccountNumber;
                }


                if(String.isBlank(identificationNumber))
                {
                    mustAbort = true;
                    callResult.errors.add(NO_IDENTIFICATION_NUMBER);
                }
            }
        }
        return mustAbort;
    }

    protected override String getQueryParameters()
    {
        DTO_QueryParams queryParams = new DTO_QueryParams();
        queryParams.populate(
                queueItem.CMN_TriggeringObjectId__c,
                Boolean.valueOf(requestParameters.getFirst(IS_FUND_DOC_PARAMETER))
        );
        return queryParams.build();
    }

    /**
     * @description Inner class to define structure of QueryParams
     */
    private class DTO_QueryParams
    {

        private String accountNumber;
        private String identityNumber;
        private String entityId;
        private String uniqueInternalCode;
        private String financialAccountNumber;
        private String documentTypeCode;
        private Boolean extractDocumentTypes;
        private String sourceSystem;

        public void populate(Id triggeringObjectId, Boolean isFundDoc) {
            if (triggeringObjectId.getSobjectType() == Account.getSObjectType()) {
                Account account = SLC_DAL_Account.findById(triggeringObjectId);

                if (account.IsPersonAccount) {
                    this.identityNumber = account.SLC_IDNumber__c;
                } else if (isFundDoc) {
                    this.uniqueInternalCode = account.SLC_IDNumber__c;
                } else {
                    this.accountNumber = account.AccountNumber;
                }
            } else if (triggeringObjectId.getSobjectType() == FinServ__FinancialAccount__c.getSObjectType()) {
                FinServ__FinancialAccount__c financialAccount = AW_DAL_FinancialAccount.findById(triggeringObjectId);
                this.financialAccountNumber = financialAccount.FinServ__FinancialAccountNumber__c;
            }
        }

        public String build() {
            Map<String, String> mappedParams = (Map<String, String>) JSON.deserialize(JSON.serialize(this), Map<String, String>.class);
            List<String> paramsStr = new List<String>();
            for (String key : mappedParams.keySet()) {
                String value = mappedParams.get(key);
                if (value != null) {
                    paramsStr.add(key + NAME_VALUE_SEPARATOR + value);
                }
            }
            return String.join(paramsStr, PARAM_SEPARATOR);
        }
    }


    /**
     * @description Inner class to define structure of response body
     */
    private class DTO_Response extends CMN_DTO_JsonBase
    {
        private List <DTO_VaultedDocumentChecklistItem> responses;

        /**
         * @description The Type of the DTO used when deserializing the class
         *
         * @return Class of the DTO
         */
        protected override Type getObjectType()
        {
            return DTO_Response.class;
        }
    }

    /**
     * @description Class representing a vaulted document
     */
    @SuppressWarnings('ApexUnusedDeclaration')
    public class DTO_VaultedDocumentChecklistItem
    {
        /**
         * @description Where the vaulted document is stored, e.g. 'Horizon'
         */
        @AuraEnabled
        public String source;
        /**
         * @description Vaulted Id - external Id from Horizon
         */
        @AuraEnabled
        public String documentId;
        /**
         * @description Document Type - used to store document name
         */
        @AuraEnabled
        public String documentType;
        /**
         * @description Document Type Code - used to store document code
         */
        @AuraEnabled
        public String documentTypeCode;
        /**
         * @description Vaulted Date - saved as AW_VaultedDate
         */
        @AuraEnabled
        public String entryDate;
        /**
         * @description Document Date - today's date
         */
        @AuraEnabled
        public String documentDate;
        /**
         * @description Source Id - used to store who is sending request
         */
        @AuraEnabled
        public String sourceId;
        /**
         * @description Indicates that the document read-only. Added as part of Service Console
         */
        @AuraEnabled
        public Boolean readOnly;
    }

    /**
     * @description Override to return mock response for test class
     *
     * @return CMN_API_HttpBaseOutboundMock CMN_API_FetchVaultedDocumentsMock is extension class and contains Mock response
     */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
    {
        return new CMN_API_FetchVaultedDocumentsMock();
    }

    /**
     * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
     */
    private class CMN_API_FetchVaultedDocumentsMock extends CMN_API_HttpBaseOutboundMock
    {
        private final String validResponse = '[{"source": "Horizon", "documentId": "911642606", "documentType": "Cancel Cession",' +
                '"entryDate": "01/03/2021 12:26:41", "sourceId": "1234", "readOnly": true},{"source": "Horizon", "documentId": "911642707",' +
                ' "documentType": "Id Declaration", "entryDate": "02/03/2021 12:27:41", "sourceId": "2211", "readOnly": false}]';

        protected override void setResponse(HttpRequest request, HttpResponse response)
        {
            super.setResponse(request, response);
            response.setBody(validResponse);
        }
    }
}