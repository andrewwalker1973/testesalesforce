/**
 * @description Service class to make the API call to notify Mulesoft when a User is updated in Salesforce
 *
 * @author Futureform
 *
 * @date December 2022
 */
public inherited sharing class SLC_API_RestOutboundUpdateUser extends CMN_API_RestBaseOutboundMule
{
    private String uniqueId;
    private static final String ERROR_ITEM_NOT_FOUND = 'Unable to process request as no User was found.';
    /**
     * @description stores the name of the service which can be referenced in test class
     */
    public static final String SERVICE_NAME = SLC_API_RestOutboundUpdateUser.class.getName();

    @TestVisible
    private static String mockStatus;
    @TestVisible
    private static String mockError;
    @TestVisible
    private static String mockPayload;
   
    /**
     * @description Override to set request and response DTO types and any other globals which may be used
     */
    protected override void initialise()
    {
        super.initialise();

        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
    }
    
	/**
	 * @description Override to use Delete HTTP Method for API call
	 *
	 * @return String
	 */
	public override virtual String getVerb()
	{
		return CMN_API_HttpBase.HTTP_VERB_PATCH;
	}

    /**
     * @description Override to get Service name to be used when looking up custom settings for the service
     *
     * @return String Returns service name as string
     */
    protected override String getServiceName()
    {
        return SERVICE_NAME;
    }

    /**
     * @description Check if the JSON Response is in the form of an array without key; Parsing this using a Salesforce DTO
     * class is not possible so it needs to be manually added to the response
     *
     * @return Boolean - An indicator to show if the response is an array and is withing a key node.
     */
    protected override Boolean hasArrayResponse()
    {
        return true;
    }


    /**
     * @description Override to validate if all the information required to make API call is available
     *
     * @return Boolean Returns true if all the information is present, else will return false
     */
    @SuppressWarnings('PMD.CognitiveComplexity')
    protected override Boolean abortRequest()
    {
        Boolean mustAbort = super.abortRequest();
        
        if(!mustAbort){
            DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;            

            dtoRequest.userToSend = SC_DAL_User.findById(queueItem.CMN_TriggeringObjectId__c);
            uniqueId = dtoRequest.userToSend.FederationIdentifier;
                        
            if(dtoRequest.userToSend == null)
            {
                mustAbort = true;
                callResult.errors.add(ERROR_ITEM_NOT_FOUND);
            }
        }        
        
        return mustAbort;
    }

    /**
     * @description register all the object types we want to update
     */
    protected override void setUnitOfWorksObjectTypes()
    {
        super.setUnitOfWorksObjectTypes();

        addSObjectTypes(new List<Schema.SObjectType> {User.SObjectType});
    }

    /**
     * @description Inner class to define structure of request body and populate the same for API call
     */
    @SuppressWarnings('PMD.CognitiveComplexity')
    public class DTO_Request extends CMN_DTO_JsonBase
    {
        private transient User userToSend;
        /**
         * @description stores the User information to be sent from salesforce to horizon
         */
        public List<SLC_DTO_User> dtoUsers;

        /**
         * @description Override to populate request body
         *
         * @param triggeringObjectId User Id for which API call is initiated
         */
        @SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
        public override void populate(Id triggeringObjectId)
        {
            super.populate(triggeringObjectId);

            dtoUsers = new List<SLC_DTO_User>();

            SLC_DTO_User dtoUser = new SLC_DTO_User();
            dtoUser.givenName = userToSend.FirstName;
            dtoUser.familyName = userToSend.LastName;
            dtoUser.identityNumber = userToSend.FederationIdentifier;
            dtoUser.email = userToSend.Email;
            dtoUser.phoneNumber = userToSend.Phone;

            dtoUsers.add(dtoUser);
        }

        /**
         * @description Suppresses null values when serializing Apex objects
         *
         * @return JSON string
         */
        public override String serialize()
        {
            return JSON.serializePretty(dtoUsers[0], true);
        }
    }
    
	/**
	 * @description Takes all the work that has been registered with the UnitOfWork and commits it to the database
	 */
	public override void commitWork()
	{
		/* Including this to make sure the sharing is bypassed after making the controller as without sharing*/
		super.commitWork(false);
	}

    /**
     * @description Will save updates to the User if any updates exists 
     */
    protected override void registerDatabaseChanges()
    {
        super.registerDatabaseChanges();

        DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;
        DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

        //Since we only send one case at a time we expect one response in the array
        DTO_User dtoUser = dtoResponse.responses;
        
        registerDirty(dtoRequest.userToSend);
    }

    /**
     * @description Inner class to define structure of response body
     */
    private class DTO_Response extends CMN_DTO_JsonBase
    {
        public DTO_User responses;

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

    @TestVisible   
    private class DTO_User
    {        
        public String status;
        public List<DTO_Errors> errors;
        public DTO_Payload payload;    
    }
    
	/**
	 * @description DTO_Errors to specify error structure
	 */      
        public class DTO_Errors {
            public String errorCode;
            public String errorDateTime;
            public String errorMessage;
            public String errorDescription;
        }
    
	/**
	 * @description DTO_Payload to specify payload structure
	 */    
        public class DTO_Payload {
            public String identityNumber;
            public String givenName;
            public String familyName;
            public String email;
            public String phoneNumber;
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
                                EncodingUtil.urlEncode(uniqueId, UTF8_ENCODING_SCHEME)
                        }
                );
    }

    /**
     * @description Override to return inner class having Mock response
     *
     * @return CMN_API_HttpBaseOutboundMock SLC_API_RestOutboundCreateUpdateUserMock is extension class and contains Mock response
     */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
    {
        return new SLC_API_RestOutboundCreateUpdateUserMock();
    }

    /**
     * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
     */
    private class SLC_API_RestOutboundCreateUpdateUserMock extends CMN_API_HttpBaseOutboundMock
    {        
        private final String validResponse = '{"status":"'+mockStatus+'","errors":'+mockError+',"payload":{"'+mockPayload+'"}}';
        
        protected override void setResponse(HttpRequest request, HttpResponse response)
        {
            super.setResponse(request, response);
            response.setBody(validResponse);
        }
    }
}