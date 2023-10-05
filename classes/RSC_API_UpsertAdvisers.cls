/**
 * @description API handler to support Financial Adviser synchronisation
 *
 * @see RSC_API_UpsertAdvisers_TEST @146274
 * @see RSC_URL_AdviserSync
 *
 * @author m.sudhakar.rokde@accenture.com jason.van.beukering@accenture.com darrion.james.singh@accenture.com jayanth.kumar.s@accenture.com
 *
 * @date March 2022
 */
public inherited sharing class RSC_API_UpsertAdvisers extends CMN_API_RestBaseInbound
{
    private Account activePracticeAccount;
    private Id adviserRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Contact.SObjectType, SC_DAL_Contact.RT_ADVISER);
    private Map <String, SC_ConsultantCodes__c> consultantCodeToConsultantRecord = new Map <String, SC_ConsultantCodes__c>();
    @TestVisible
	private static final String ERROR_NO_ACTIVE_ACCOUNT_FOUND = 'Unable to process request as there is no Active Adviser Account present.';

    /**
     * @description The class name of the webservice
     */
    public static final String SERVICE_NAME = RSC_API_UpsertAdvisers.class.getName();

    /**
     * @description Initialise variable Object variables
     */
    protected override void initialise()
    {
        super.initialise();

        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
    }

    /**
     * @description register all the object types we want to update
     */
    protected override void setUnitOfWorksObjectTypes()
    {
        super.setUnitOfWorksObjectTypes();

        addSObjectTypes(new List<Schema.SObjectType> {Contact.SObjectType, SC_ConsultantCodes__c.SObjectType});
    }

    /**
     * @description Will check that the information received is valid and query any related data
     */

    protected override void processRequest()
    {
        super.processRequest();

		activePracticeAccount = SC_DAL_Account.findPracticeAccountByName(SC_DAL_AdviserAccountsMapping.findActivePracticeAccountName());

        if(activePracticeAccount == null)
        {
            throw new SearchException(ERROR_NO_ACTIVE_ACCOUNT_FOUND);
        }
    }
    /**
     * @description Will register accounts and contacts that need to be Upsert based on request received
     */
    protected override void registerDatabaseChanges()
    {
        super.registerDatabaseChanges();

        DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

        Set<String> partyIds = new Set<String>();

		for(DTO_Adviser dtoAdviser : dtoRequest.advisers)
		{
			partyIds.add(dtoAdviser.partyId);
        }

        CMN_UTIL_SObjectIndex partyIdToContactMap = new CMN_UTIL_SObjectIndex(SC_DAL_Contact.FIELD_PARTY_ID).putAll(SC_DAL_Contact.findByPartyId(partyIds));

        for(SObject conRecord : partyIdToContactMap.values())
        {
            Contact contactRecord = (Contact)conRecord;
            for(SC_ConsultantCodes__c consultantRecord : contactRecord.ConsultantCodes__r)
            {
				consultantCodeToConsultantRecord.put(consultantRecord.Name, consultantRecord);
            }
        }

        //Since we may receive multiple consultant codes for a contact in a single batch,
        //We should ensure the party record is only processed once
        Map <String, Contact> processedPartyIdsToContact = new Map<String, Contact>();

		for(DTO_Adviser dtoAdviser : dtoRequest.advisers)
		{
			Contact foundContact = (Contact)partyIdToContactMap.get(dtoAdviser.partyId);

			//If the party id has been processed do not process the adviser record
			Contact processedContact = processedPartyIdsToContact.get(dtoAdviser.partyId);
			// If the contact is already processed we are sending the same contact information to the Consultant Code
			foundContact = processedContact != null ? processedContact : saveContact(dtoAdviser, foundContact);
			processedPartyIdsToContact.put(dtoAdviser.partyId, foundContact);

			saveConsultantCode(dtoAdviser, consultantCodeToConsultantRecord.get(dtoAdviser.consultantCode), foundContact);
        }
    }

    /**
     * @description This method is used to populate account details on the requested cases
     *
	 * @param adviser The case received with the request
     * @param foundContact The case existing contact record for the provided consultantCode  *
     *
     * @return contact record created/updated
     */
	private Contact saveContact(DTO_Adviser adviser, Contact foundContact)
	{
		Contact upsertContact;

		if(String.isNotBlank(adviser.partyId))
		{
			Boolean hasIdentityNumber = String.isNotBlank(adviser.idNumber);

            upsertContact = new Contact();

            upsertContact.Id = foundContact?.Id;
            upsertContact.AccountId = activePracticeAccount.Id;
			upsertContact.AW_IdentificationNumber__c = hasIdentityNumber ? adviser.idNumber : adviser.passportNumber;

			String identityType = String.isNotBlank(adviser.passportNumber) ? AW_DAL_Account.PICK_PASSPORT_TYPE : upsertContact.AW_IdentificationType__c;
			upsertContact.AW_IdentificationType__c = hasIdentityNumber ? AW_DAL_Account.PICK_SA_ID_TYPE : identityType;
			upsertContact.Birthdate = hasIdentityNumber ? AW_UTIL_IdentityNumber.extractDateOfBirthFromIdentityNumber(adviser.idNumber) : upsertContact.Birthdate;
			upsertContact.CMN_AQCCode__c = adviser.aqcCode;
			upsertContact.CMN_SRSPartyID__c = adviser.partyId;
			String gender = hasIdentityNumber ? AW_UTIL_IdentityNumber.getGenderFromIdentityNumber(adviser.idNumber) : upsertContact.FinServ__Gender__c;
			upsertContact.FinServ__Gender__c = gender;
			upsertContact.FirstName = adviser.firstName;
			upsertContact.LastName = adviser.lastName;
            upsertContact.RecordTypeId = adviserRecordTypeId;

            registerChange(upsertContact);
        }

        return upsertContact;
    }
    /**
     * @description This method is used to populate consultant Code details
     *
	 * @param dtoAdviser The adviser details received with the request
     * @param foundConsultantCodeRecord The consultant code Record found based on consultant code
     * @param foundContact The contact record received in the request
     *
     * @return upsertConsultantCode created/updated
     */
	private SC_ConsultantCodes__c saveConsultantCode(DTO_Adviser dtoAdviser, SC_ConsultantCodes__c foundConsultantCodeRecord, Contact foundContact)
	{
		SC_ConsultantCodes__c upsertConsultantCode = new SC_ConsultantCodes__c();
		upsertConsultantCode.Id = foundConsultantCodeRecord?.Id;
		upsertConsultantCode.Name = dtoAdviser.consultantCode;
		upsertConsultantCode.SC_AgreementNumber__c = dtoAdviser.agreementNumber;
		upsertConsultantCode.SC_AgreementStatus__c = SC_DAL_ConsultantCodes.ACTIVE_AGREEMENT_STATUS.equals(dtoAdviser.agreementStatus);
		upsertConsultantCode.SC_Brokerage__c = dtoAdviser.brokerageName;
		upsertConsultantCode.SC_SRSBelongsToID__c = dtoAdviser.belongsToId;
        registerChange(upsertConsultantCode);
        registerRelationship(upsertConsultantCode, SC_ConsultantCodes__c.SC_ContactId__c, foundContact);

        return upsertConsultantCode;
    }

    /**
     * @description The DTO representing the request being sent
     */
    @TestVisible
    private class DTO_Request extends CMN_DTO_JsonBase
    {
		public List<DTO_Adviser> advisers;

        /**
         * @description The Type of the DTO used when deserializing the class
         *
         * @return Class of the DTO
         */
        protected override Type getObjectType()
        {
            return DTO_Request.class;
        }

        /**
         * @description Will deserialize the string and return an instance of the class specified in "getObjectType"
         *
         * @param dtoString A JSON string
         *
         * @return Deserialized DTO
         *
         * @see CMN_DTO_JsonBase.getObjectType
         */
        public override CMN_DTO_Base deserialize(String dtoString)
        {
			String modifiedRequest = '{ "advisers" : ' + dtoString + '}';
            return super.deserialize(modifiedRequest);
        }

        /**
         * @description Suppresses null values when serializing Apex objects
         *
         * @return JSON string
         */
        public override String serialize()
        {
			return JSON.serializePretty(advisers, true);
        }
    }

    /**
     * @description DTO representing a successful response
     */
    private class DTO_Response extends CMN_DTO_JsonBase
    {
        public String message = 'Data Uploaded Successfully to Salesforce';
    }

    /**
	 * @description DTO to specify Adviser structure
	 */
	@TestVisible
	private class DTO_Adviser
    {
        public String agreementNumber;
        public String agreementStatus;
        public String aqcCode;
        public String belongsToId;
        public String brokerageName;
        public String consultantCode;
        public String firstName;
        public String idNumber;
        public String lastName;
        public String partyId;
        public String passportNumber;
    }
}