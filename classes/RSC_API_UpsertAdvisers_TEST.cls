/**
 * @description Will test the inbound service class RSC_API_UpsertAdvisors
 *
 * @see RSC_API_UpsertAdvisers @146274
 * @see RSC_URL_AdviserSync
 *
 * @author m.sudhakar.rokde@accenture.com jason.van.beukering@accenture.com
 *
 * @date February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class RSC_API_UpsertAdvisers_TEST
{
	private static final Integer NUMBER_OF_ADVISERS_TO_PROCESS = 3;
    private static final Integer NUMBER_OF_RECORDS_TO_CREATE = 1;
    private static final String CONTACTS_NOT_LINKED = ' No Contacts were linked to the account  ';
    private static final String NO_CONSULTANT_RECORD = 'No Consultant records found as expected';
    private static final String PARTY_ID = CMN_DAL_SObjectDomain.generateRandomName();

    /**
     * @description Will check that a Account and Contact are inserted successfully
     */
    @IsTest
    private static void checkForPracticeAccount()
    {
        RSC_API_UpsertAdvisers.DTO_Request dtoRequest = populateDtoRequestData();

        Account practiceAccount = RSC_DAL_TestDataFactory.newPracticeAccounts(SC_DAL_Account.RT_PRACTICE, NUMBER_OF_RECORDS_TO_CREATE).iterator().next();
        practiceAccount.Name = SC_DAL_Account.ACTIVE_ADVISER_ACCOUNT;
        insert practiceAccount;

        setupRestContextAndExecuteService(dtoRequest);

        List<Contact> contactRecords = SC_DAL_Contact.getAll();

        System.assertEquals(practiceAccount.Id, contactRecords.iterator().next().AccountId, CONTACTS_NOT_LINKED);
    }
    /**
     * @description Will check that a Account and Contact are inserted successfully
     */
    @IsTest
    private static void checkForExistingPracticeContact()
    {
        RSC_API_UpsertAdvisers.DTO_Request dtoRequest = populateDtoRequestData();

        Account practiceAccount = RSC_DAL_TestDataFactory.newPracticeAccounts(SC_DAL_Account.RT_PRACTICE, NUMBER_OF_RECORDS_TO_CREATE).iterator().next();
        practiceAccount.Name = SC_DAL_Account.ACTIVE_ADVISER_ACCOUNT;
        insert practiceAccount;

        Contact existingContact = RSC_DAL_TestDataFactory.createPracticeContacts(SC_DAL_Contact.RT_ADVISER, NUMBER_OF_RECORDS_TO_CREATE, null).iterator().next();
        existingContact.CMN_SRSPartyID__c = PARTY_ID;
        update existingContact;

		for(RSC_API_UpsertAdvisers.DTO_Adviser adviser : dtoRequest.advisers)
		{
			adviser.partyId = existingContact.CMN_SRSPartyID__c;
        }
        setupRestContextAndExecuteService(dtoRequest);

        List<Contact> contactRecords = SC_DAL_Contact.getAll();

        System.assertEquals(practiceAccount.Id, contactRecords.iterator().next().AccountId, CONTACTS_NOT_LINKED);
    }

    /**
     * @description Will check that a existing contact is linked to existing account successfully
     */
    @IsTest
    private static void linkConsultantWithContact()
    {
        RSC_API_UpsertAdvisers.DTO_Request dtoRequest = populateDtoRequestData();

        Account practiceAccount = RSC_DAL_TestDataFactory.newPracticeAccounts(SC_DAL_Account.RT_PRACTICE, NUMBER_OF_RECORDS_TO_CREATE).iterator().next();
        practiceAccount.Name = SC_DAL_Account.ACTIVE_ADVISER_ACCOUNT;
        insert practiceAccount;

        Contact existingContact = RSC_DAL_TestDataFactory.createPracticeContacts(SC_DAL_Contact.RT_ADVISER, NUMBER_OF_RECORDS_TO_CREATE, null).iterator().next();
        existingContact.CMN_SRSPartyID__c = PARTY_ID;
        update existingContact;

		for(RSC_API_UpsertAdvisers.DTO_Adviser adviser : dtoRequest.advisers)
		{
			adviser.partyId = existingContact.CMN_SRSPartyID__c;
        }

        List<SC_ConsultantCodes__c> existingConsultantRecord =
                RSC_DAL_TestDataFactory.insertConsultantCode(existingContact.Id, NUMBER_OF_RECORDS_TO_CREATE, true);

        System.assertNotEquals(null, existingConsultantRecord.size(), NO_CONSULTANT_RECORD);

        setupRestContextAndExecuteService(dtoRequest);
    }

    /**
     * @description Check that the service abort if active account is not found
     *
	 * @see RSC_API_UpsertAdvisers.processRequest
     */
    @IsTest
    private static void abortedCallForNoActiveAccount()
    {
        RSC_API_UpsertAdvisers.DTO_Request dtoRequest = populateDtoRequestData();

        CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

        Test.startTest();

        RSC_URL_AdviserSync.adviserSync();

        Test.stopTest();

        CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(RSC_API_UpsertAdvisers.SERVICE_NAME, RSC_API_UpsertAdvisers.ERROR_NO_ACTIVE_ACCOUNT_FOUND);
    }

    /**
     * @description Will setup the RestContext & execute the service
     *
     * @param dtoRequest The DTO that represents the JSON sent in a request
     */
    private static void setupRestContextAndExecuteService(RSC_API_UpsertAdvisers.DTO_Request dtoRequest)
    {
        CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

        Test.startTest();

        RSC_URL_AdviserSync.adviserSync();

        Test.stopTest();

        CMN_DAL_WebserviceCallQueue.checkServiceCompleted(RSC_API_UpsertAdvisers.SERVICE_NAME);
    }

    /**
     * @description Will populate the dtoRequest data
     *
     * @return the DTO_Request
     */
    private static RSC_API_UpsertAdvisers.DTO_Request populateDtoRequestData()
    {
        RSC_API_UpsertAdvisers.DTO_Request dtoRequest = new RSC_API_UpsertAdvisers.DTO_Request();
		List<RSC_API_UpsertAdvisers.DTO_Adviser> dtoAdvisers = new List<RSC_API_UpsertAdvisers.DTO_Adviser>();

		for(Integer i = 0; i < NUMBER_OF_ADVISERS_TO_PROCESS; i++)
		{
			RSC_API_UpsertAdvisers.DTO_Adviser dtoAdviser = new RSC_API_UpsertAdvisers.DTO_Adviser();

			dtoAdviser.agreementNumber = CMN_DAL_SObjectDomain.generateRandomName();
			dtoAdviser.agreementStatus = CMN_DAL_SObjectDomain.generateRandomName();
			dtoAdviser.aqcCode = CMN_DAL_SObjectDomain.generateRandomName();
			dtoAdviser.belongsToId = CMN_DAL_SObjectDomain.generateRandomName();
			dtoAdviser.brokerageName = CMN_DAL_SObjectDomain.generateRandomName();
			dtoAdviser.consultantCode = CMN_DAL_SObjectDomain.generateRandomName();
			dtoAdviser.firstName = CMN_DAL_SObjectDomain.generateRandomName();
			dtoAdviser.idNumber = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
			dtoAdviser.lastName = CMN_DAL_SObjectDomain.generateRandomName();
			dtoAdviser.partyId = CMN_DAL_SObjectDomain.generateRandomName();
			dtoAdviser.passportNumber = CMN_DAL_SObjectDomain.generateRandomNumber();

			dtoAdvisers.add(dtoAdviser);
		}

		dtoRequest.advisers = dtoAdvisers;
        return dtoRequest;
    }
}