/**
 * @description Test class for SLC_API_UploadDocumentToVault
 *
 * @author Futureform
 *
 * @date October 2022
 */
@IsTest
private class SLC_API_UploadDocumentToVault_TEST {
    private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

    /**
     * @description Create data required for the unit test
     *
     * @param aUser the user with which data should be created
     *
     * @return a newly inserted item
     */
    private static DocumentChecklistItem createData(User aUser)
    {
        Account personMasterAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();

        Account newAccount = new Account();
        newAccount.Id = personMasterAccount.Id;
        newAccount.OwnerId = aUser.Id;
        update newAccount;
        
        DocumentChecklistItem checklistItem;
        SC_ServiceType__c newServiceType = SC_DAL_DataFactory.createServiceTypesWithAssignableValue(NUMBER_OF_ITEMS_TO_CREATE, true).iterator().next();
        System.runAs(aUser)
        {
            Case caseRecord = SC_DAL_DataFactory.newCase(personMasterAccount.Id);
            caseRecord.RSC_ServiceType__c = newServiceType.Id;
            insert caseRecord;

            checklistItem =  SC_DAL_DataFactory.newDocumentCheckListItems(personMasterAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
            checklistItem.OwnerId = aUser.Id;
            insert checklistItem;
        }

        return checklistItem;
    }

    /**
     * @description Check successfull Call
     *
     * @see SLC_API_UploadDocumentToVault.populate
     */
    @IsTest
    private static void successfulCall1()
    {
        Account newAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
        DocumentChecklistItem checklistItem = SC_DAL_DataFactory.insertDocumentCheckListItems(newAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
        RSC_DAL_TestDataFactory.createNewContentVersion(NUMBER_OF_ITEMS_TO_CREATE, checklistItem.Id);

        CMN_API_RestBaseOutboundTestHelper.successfulCall(SLC_API_UploadDocumentToVault.SERVICE_NAME, checklistItem.Id);
    }
    
    /**
     * @description Check successfull Call
     *
     * @see SLC_API_UploadDocumentToVault.populate
     */
    @IsTest
    private static void successfulCall2()
    {
        Account newAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
        DocumentChecklistItem checklistItem = SC_DAL_DataFactory.insertDocumentCheckListItems(newAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
        checklistItem.AW_DateVaulted__c = null;
        update checklistItem;
        RSC_DAL_TestDataFactory.createNewContentVersion(NUMBER_OF_ITEMS_TO_CREATE, checklistItem.Id);

        CMN_API_RestBaseOutboundTestHelper.successfulCall(SLC_API_UploadDocumentToVault.SERVICE_NAME, checklistItem.Id);
    }
    
    /**
     * @description Check successfull Call
     *
     * @see SLC_API_UploadDocumentToVault.populate
     */
    @IsTest
    private static void successfulCall3()
    {
        Id busAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Institutional Account').getRecordTypeId();        
        Account busAcc = new Account(
        	Name = 'TestBusAcc123',
            RecordTypeId = busAccRecordTypeId,
            SLI_KnowYourCustomerCategory__c = 'RSA Company',
            AccountNumber='4474'
        );
        insert busAcc;
        
        DocumentChecklistItem checklistItem = SC_DAL_DataFactory.insertDocumentCheckListItems(busAcc.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

        RSC_DAL_TestDataFactory.createNewContentVersion(NUMBER_OF_ITEMS_TO_CREATE, checklistItem.Id);

        CMN_API_RestBaseOutboundTestHelper.successfulCall(SLC_API_UploadDocumentToVault.SERVICE_NAME, checklistItem.Id);
    }

    /**
     * @description Check that the service abort if the ContentVersion is not linked to the documentChecklistItem
     *
     * @see SLC_API_UploadDocumentToVault.abortRequest
     */
    @IsTest
    private static void abortedCallForNoContentVersion()
    {
        Account newAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
        DocumentChecklistItem checklistItem = SC_DAL_DataFactory.insertDocumentCheckListItems(newAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

        CMN_API_RestBaseOutboundTestHelper.abortedCall(SLC_API_UploadDocumentToVault.SERVICE_NAME, checklistItem.Id);
    }

    /**
     * @description Check that the service abort if the Id provided does not find a documentChecklistItem
     *
     * @see SLC_API_UploadDocumentToVault.abortRequest
     */
    @IsTest
    private static void abortedCallNoItemFound()
    {
        CMN_API_RestBaseOutboundTestHelper.abortedCall(SLC_API_UploadDocumentToVault.SERVICE_NAME, UserInfo.getUserId());
    }

   /**
     * @description Emulates a failed call and checks that error message is not blank
     */
    @IsTest
    private static void failedCall()
    {
        User foundUser = AW_DAL_TestDataFactory.createTestUser(SC_DAL_Profile.PROFILE_SERVICE_AGENT, true);
        DocumentChecklistItem checklistItem = createData(foundUser);

        System.runAs(foundUser)
        {
            RSC_DAL_TestDataFactory.createNewContentVersion(NUMBER_OF_ITEMS_TO_CREATE, checklistItem.Id);
            CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
                    (
                            SLC_API_UploadDocumentToVault.SERVICE_NAME,
                            checklistItem.Id
                    );

            Test.startTest();

            CMN_API_HttpBaseOutboundMock.returnErrorResponse = true;

            SLC_API_UploadDocumentToVault handler =
                    (SLC_API_UploadDocumentToVault)CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

            Test.stopTest();

            System.assertEquals(true, handler.callResult.failed, 'Status invalid. Response Call Result JSON: ' + JSON.serialize(handler.callResult));
        }
    }
}