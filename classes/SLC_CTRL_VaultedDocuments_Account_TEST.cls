/**
 * @description Test class for SLC_CTRL_VaultedDocuments_Account
 *
 * @author Futureform
 *
 * @date December 2022
 */
@isTest
private class SLC_CTRL_VaultedDocuments_Account_TEST {

    private static final Integer INT_ONE = 1;
    private static final String VAULTED_ID = '123';
    private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

    @TestSetup
    static void setup() {
        //Person Account
        Account personMasterAccount = AW_DAL_TestDataFactory.createMasterPersonAccount(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
        personMasterAccount.AccountNumber = '123';
        update personMasterAccount;
        
        Id personAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Institutional Person Account').getRecordTypeId();
        Account personAcc = new Account(
            LastName = 'TestABC', 
            RecordTypeId = personAccRecordTypeId
        );
        insert personAcc;   
        
        //Business Account
        List<Account> accounts = AW_DAL_TestDataFactory.createBusinessAccounts(NUMBER_OF_ITEMS_TO_CREATE);
        for (Account account: accounts) {
            account.AccountNumber = CMN_UTIL_Random.randomNumeric(5);
        }
        update accounts;
        
        //Account Contact Relationship
        AccountContactRelation acr = new AccountContactRelation(
        	AccountId = accounts[0].Id,
            ContactId = [SELECT Id, AccountId FROM Contact WHERE AccountId =: personMasterAccount.Id].Id
        );
        insert acr;
        
        //Financial Account
        AW_DAL_TestDataFactory.createFinancialAccounts(accounts[0], INT_ONE);

        //Opportunity
        AW_DAL_TestDataFactory.createOpportunities(personMasterAccount, 1, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY);

        //Document Checklist Items
        List<DocumentChecklistItem> documentChecklistItems = SC_DAL_DataFactory.insertDocumentCheckListItems(personMasterAccount.Id, INT_ONE);
        documentChecklistItems.iterator().next().CMN_VaultedId__c = VAULTED_ID;
        CMN_DAL_SObjectDomain.updateDBObject(documentChecklistItems.iterator().next());

        RSC_DAL_TestDataFactory.createContentVersion(
                documentChecklistItems.iterator().next().Id,
                CMN_DAL_SObjectDomain.generateRandomName(),
                CMN_DAL_SObjectDomain.generateRandomName()
        );
    }

    @IsTest
    private static void deLinkCheckListItemsSuccessfulCall() {
        Account account = SC_DAL_Account.getAll().iterator().next();
        List<DocumentChecklistItem> newDocuments = SC_DAL_DocumentChecklistItem.getAll();

        List<String> documentIds = new List<String>();
        for (DocumentChecklistItem document : newDocuments) {
            documentIds.add(document.Id);
        }

        Test.startTest();

        SLC_CTRL_VaultedDocuments_Account.deLinkDocumentItem(documentIds, account.Id, CMN_DAL_SObjectDomain.generateRandomName());

        Test.stopTest();

        for (DocumentChecklistItem deletedDocumentItem : newDocuments) {
            if (deletedDocumentItem.CMN_VaultedId__c != null) {
                deletedDocumentItem = SC_DAL_DocumentChecklistItem.findById(deletedDocumentItem.Id);
                System.debug(deletedDocumentItem);
                System.assertEquals(null, deletedDocumentItem, 'Document CheckList Item was not deleted');
            }
        }
    }

    /**
     * @description method to verify the failed API call to delink DocumentCheckListItems
     *
     * @see RSC_CTRL_GetVaultedDocuments.deLinkDocumentItem
     */
    @IsTest
    private static void deLinkCheckListItemsFailedCall() {
        Account account = SC_DAL_Account.getAll().iterator().next();
        List<DocumentChecklistItem> newDocuments = SC_DAL_DocumentChecklistItem.getAll();

        List<String> documentIds = new List<String>();
        for (DocumentChecklistItem document : newDocuments) {
            documentIds.add(document.Id);
        }

        Test.startTest();

        CMN_API_HttpBaseOutboundMock.returnErrorResponse = true;
        SLC_CTRL_VaultedDocuments_Account.deLinkDocumentItem(documentIds, account.Id, CMN_DAL_SObjectDomain.generateRandomName());


        for (DocumentChecklistItem deletedDocumentItem : newDocuments) {
            if (deletedDocumentItem.CMN_VaultedId__c != null) {
                deletedDocumentItem = SC_DAL_DocumentChecklistItem.findById(deletedDocumentItem.Id);
                System.assertNotEquals(null, deletedDocumentItem, 'Document CheckList Item should not be deleted');
            }
        }
        Test.stopTest();
    }

    /**
     * @description method to insert Document CheckList Items
     *
     * @see RSC_CTRL_GetVaultedDocuments.saveRecord
     */
    @IsTest
    private static void insertDocumentCheckListItemWithoutFile() {
        Account account = SC_DAL_Account.getAll().iterator().next();

        List<String> newChecklistItemId;

        DocumentChecklistItem newItem = new DocumentChecklistItem();
        newItem.Name = CMN_DAL_SObjectDomain.generateRandomName();
        newItem.ParentRecordId = account.Id;

        Test.startTest();

        newChecklistItemId = SLC_CTRL_VaultedDocuments_Account.saveRecord(new List<DocumentChecklistItem>{
                newItem
        }, null, null);

        Test.stopTest();

        System.assertNotEquals(null, newChecklistItemId, 'New Document Checklist Item was not created');
    }

    /**
     * @description method to insert Document CheckList Items
     *
     * @see RSC_CTRL_GetVaultedDocuments.saveRecord
     */
    @IsTest
    private static void insertDocumentCheckListItemWithFile() {

        Account account = SC_DAL_Account.getAll().iterator().next();

        List<String> newChecklistItemId;

        DocumentChecklistItem newItem = new DocumentChecklistItem();
        newItem.Name = CMN_DAL_SObjectDomain.generateRandomName();
        newItem.ParentRecordId = account.Id;

        String file = CMN_DAL_SObjectDomain.generateRandomName();
        String fileName = CMN_DAL_SObjectDomain.generateRandomName();

        Test.startTest();

        newChecklistItemId = SLC_CTRL_VaultedDocuments_Account.saveRecord(new List<DocumentChecklistItem>{
                newItem
        }, file, fileName);

        Test.stopTest();

        System.assertNotEquals(null, newChecklistItemId, 'New Document Checklist Item was not created');
    }

    /**
     * @description method to get content version for given Document Checklist Item
     *
     * @see RSC_CTRL_GetVaultedDocuments.getContentDocument
     */
    @IsTest
    private static void viewCheckListWithNoContentDocument() {
        DocumentChecklistItem newItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next(); // documentChecklist Item without content document

        Test.startTest();

        SLC_CTRL_VaultedDocuments_Opportunity.DTO_Response dtoResponse = SLC_CTRL_VaultedDocuments_Opportunity.getContentDocument(newItem.Id, newItem.CMN_VaultedId__c);

        Test.stopTest();

//        System.assertEquals(null, dtoResponse.contentDocumentId, 'Content Document should not be found as expected');
    }

    /**
	 * @description method to get DocumentChecklistItems by parent Id
	 *
	 * @see RSC_CTRL_GetVaultedDocuments.getDocuments
	 */
    @IsTest
    private static void getCheckListItemByParent() {
        Account account = SC_DAL_Account.getAll().iterator().next();


        Test.startTest();

        List<DocumentChecklistItem> newItems = SLC_CTRL_VaultedDocuments_Account.getDocuments(account.Id);
        System.assertEquals(0, newItems.size(), 'No check list items found.');

        Test.stopTest();
    }

    @IsTest
    private static void getCheckListItemByOpportunity() {
        Opportunity opportunity = AW_DAL_Opportunity.getAll().iterator().next();

        Test.startTest();

        List<DocumentChecklistItem> newItems = SLC_CTRL_VaultedDocuments_Account.getDocuments(opportunity.Id);
        System.assertEquals(0, newItems.size(), 'No check list items found.');

        Test.stopTest();
    }

    @IsTest
    private static void getAccountOptionsForInternalTest() {
        Account account = [SELECT Id, Name, AccountNumber, IsPersonAccount FROM Account WHERE IsPersonAccount=FALSE LIMIT 1];

        Map<String, String> options = SLC_CTRL_VaultedDocuments_Account.getAccountOptions(account.Id, false);

        System.assertEquals(3, options.size(), 'Wrong number of options'); //account, financial account, fund document
    }


    @IsTest
    private static void getAccountOptionsForPortalTest() {
        Account account = [SELECT Id, Name, AccountNumber, IsPersonAccount FROM Account WHERE IsPersonAccount=TRUE LIMIT 1];

        Map<String, String> options = SLC_CTRL_VaultedDocuments_Account.getAccountOptions(account.Id, true);

        System.assertEquals(4, options.size(), 'Wrong number of options'); //person account, ACR account, financial account, fund document
    }
    
    @IsTest
    private static void getAccountOptionsFailTest() {
        Opportunity opportunity = AW_DAL_Opportunity.getAll().iterator().next();

        Map<String, String> options = SLC_CTRL_VaultedDocuments_Account.getAccountOptions(opportunity.Id, false);

        System.assertEquals(null, options, 'Wrong number of options');
    }

    @IsTest
    private static void saveRecordTest() {
        DocumentChecklistItem documentChecklistItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next();
        List<String> newDocumentListIds = SLC_CTRL_VaultedDocuments_Account.saveRecord(
                new List<DocumentChecklistItem>{documentChecklistItem},
                CMN_DAL_SObjectDomain.generateRandomName(),
                CMN_DAL_SObjectDomain.generateRandomName()
        );

        System.assertEquals(1, newDocumentListIds.size(), 'Document hasn\'t saved');
        documentChecklistItem = SC_DAL_DocumentChecklistItem.findById(newDocumentListIds.iterator().next());
        System.assertNotEquals(null, documentChecklistItem);
    }


    @IsTest
    private static void getSubtypesTest() {
        Map<String, String> legal = SLC_CTRL_VaultedDocuments_Account.getLegalSubtypes();
        Map<String, String> reports = SLC_CTRL_VaultedDocuments_Account.getReportSubtypes();
        Map<String, String> comms = SLC_CTRL_VaultedDocuments_Account.getCommunicationSubtypes();
        Map<String, String> pres = SLC_CTRL_VaultedDocuments_Account.getPresentationSubtypes();

        System.assertNotEquals(0, legal.size(), 'No Legal subtypes');
        System.assertNotEquals(0, reports.size(), 'No Reports subtypes');
        System.assertEquals(0, comms.size(), 'No Communication subtypes');
        System.assertNotEquals(0, pres.size(), 'No Presentation subtypes');
    }

    @IsTest
    private static void getSubtypeOptionsTest() {
        List<String> legal = SLC_CTRL_VaultedDocuments_Account.getLegalSubtypeOptions();
        List<String> reports = SLC_CTRL_VaultedDocuments_Account.getReportSubtypeOptions();
        List<String> comms = SLC_CTRL_VaultedDocuments_Account.getCommunicationSubtypeOptions();
        List<String> pres = SLC_CTRL_VaultedDocuments_Account.getPresentationSubtypeOptions();

        System.assertNotEquals(0, legal.size(), 'No Legal subtype options');
        System.assertNotEquals(0, reports.size(), 'No Reports subtype options');
        System.assertNotEquals(0, comms.size(), 'No Communication subtype options');
        System.assertNotEquals(0, pres.size(), 'No Presentation subtype options');
    }

    @IsTest
    private static void getDocumentDownloadUrlInternalTest() {
        SLC_API_GetContentDocument.mockDocumentId = AW_DAL_DocumentChecklistItem.getAll().iterator().next().Id;
        SLC_API_GetContentDocument.mockContentDocumentId = CMN_DAL_ContentVersion.getAll().iterator().next().ContentDocumentId;

        Account account = SC_DAL_Account.getAll().iterator().next();
        DocumentChecklistItem documentChecklistItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next();

        Test.startTest();
        String downloadUrl = SLC_CTRL_VaultedDocuments_Account.getDocumentDownloadUrl(account.Id, documentChecklistItem.Id, false);
        Test.stopTest();

        System.assertNotEquals('', downloadUrl);
        System.assert(downloadUrl.contains(URL.getSalesforceBaseUrl().toExternalForm()));
    }
    
    @IsTest
    private static void getDocumentDownloadUrlExternalTest() {
        SLC_API_GetContentDocument.mockDocumentId = AW_DAL_DocumentChecklistItem.getAll().iterator().next().Id;
        SLC_API_GetContentDocument.mockContentDocumentId = CMN_DAL_ContentVersion.getAll().iterator().next().ContentDocumentId;
        
        DocumentChecklistItem documentChecklistItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next();        
        
        String downloadUrl; 
        
        //portal user
        Account acct = [SELECT Id, Name FROM Account WHERE LastName='TestABC' LIMIT 1];
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='STANLIB Portal User'];
        User portUser = new User(FirstName='Test', 
                               LastName='User', 
                               username='user@salesforcetest.com', 
                               email='user@mail.com',
                               alias='user',
                               communityNickname='portal',
                               localesidkey='en_US', 
                               timezonesidkey='GMT',
                               languagelocalekey='en_US',
                               emailencodingkey = 'UTF-8',
                               phone='+278067538320',
                               federationIdentifier='65783094',
                               profileId = portalProfile.Id,
                               contactId = [SELECT Id, AccountId FROM Contact WHERE AccountId =: acct.Id].Id);
        insert portUser; 
        
        System.runAs(portUser){                      
            Test.startTest();
            downloadUrl = SLC_CTRL_VaultedDocuments_Account.getDocumentDownloadUrl(acct.Id, documentChecklistItem.Id, true);
            Test.stopTest();  
        }         

        System.assertNotEquals('', downloadUrl);
        System.assert(downloadUrl.contains(URL.getSalesforceBaseUrl().toExternalForm()));
    }

    @IsTest
    private static void getVaultedDocumentsTest() {
        Account account = SC_DAL_Account.getAll().iterator().next();
        account.SLC_IDNumber__c = '678094';
        update account;

        Test.startTest();
        SLC_CTRL_VaultedDocuments_Account.DTO_Response response = SLC_CTRL_VaultedDocuments_Account.getVaultedDocuments(
                account.Id, null, false
        );
        Test.stopTest();

        System.assertEquals(true, response.callSuccessful, 'get Vaulted doc call failed');
        System.assertNotEquals(0, response.vaultedDocuments.size(), 'No vaulted documents');
    }

    @IsTest
    private static void getFilteredVaultedDocumentsTest() {
        Account account = SC_DAL_Account.getAll().iterator().next();
        account.SLC_IDNumber__c = '678094';
        update account;
        
        Test.startTest();
        SLC_CTRL_VaultedDocuments_Account.DTO_Response response = SLC_CTRL_VaultedDocuments_Account.getVaultedDocuments(
                account.Id, 'Reports', false
        );
        Test.stopTest();


        System.assertEquals(true, response.callSuccessful, 'get Vaulted doc call failed');
    }

    @IsTest
    private static void uploadDocumentsTest() {
        DocumentChecklistItem documentChecklistItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next();
        documentChecklistItem.CMN_VaultedId__c = '123412';
        update documentChecklistItem;

        Test.startTest();
        SLC_CTRL_VaultedDocuments_Opportunity.DTO_Response response = SLC_CTRL_VaultedDocuments_Account.uploadDocuments(
                new List<String>{documentChecklistItem.Id}
        );
        Test.stopTest();

        System.assertEquals(true, response.callSuccessful, 'Upload failed');
    }

    @IsTest
    private static void getDocumentTypeByCodeTest() {
        DocumentChecklistItem documentChecklistItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next();
        documentChecklistItem.CMN_VaultedId__c = '123412';
        update documentChecklistItem;

        Test.startTest();
        List<DocumentType> documentTypes = SLC_CTRL_VaultedDocuments_Account.getDocumentTypeByCode(
                new List<String>{'5447'}
        );
        Test.stopTest();

        System.assertEquals(0, documentTypes.size(), 'Unexpected Document type');
    }

    @IsTest
    private static void getDocumentTypeByNameTest() {
        DocumentChecklistItem documentChecklistItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next();
        documentChecklistItem.CMN_VaultedId__c = '123412';
        update documentChecklistItem;

        Test.startTest();
        List<DocumentType> documentTypes = SLC_CTRL_VaultedDocuments_Account.getDocumentTypeByName(
                new List<String>{'5447'}
        );
        Test.stopTest();

        System.assertEquals(0, documentTypes.size(), 'Unexpected Document type');
    }

    @IsTest
    private static void getDocumentTypeByIdTest() {
        DocumentChecklistItem documentChecklistItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next();
        documentChecklistItem.CMN_VaultedId__c = '123412';
        update documentChecklistItem;

        Test.startTest();
        List<DocumentType> documentTypes = SLC_CTRL_VaultedDocuments_Account.getDocumentTypeByIds(
                new List<String>{null}
        );
        Test.stopTest();

        System.assertEquals(0, documentTypes.size(), 'There are no Document types');
    }
    
    @IsTest
    private static void documentTypeAttributesPicklistTest() {        
        SLC_CTRL_DocumentTypeAttributesPicklist cmdt = new SLC_CTRL_DocumentTypeAttributesPicklist();
        VisualEditor.DynamicPickListRows rows = cmdt.getValues();
        System.assertNotEquals(0, rows.size());
    }
    

}