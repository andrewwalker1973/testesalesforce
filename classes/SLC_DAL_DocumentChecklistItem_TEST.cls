/**
 * @description Test class for SLC_DAL_DocumentChecklistItem
 *
 * @author Futureform
 *
 * @date December 2022
 */
@IsTest
private class SLC_DAL_DocumentChecklistItem_TEST {
    private static final Integer NUMBER_OF_DOCUMENTS = 5;
    
    @TestSetup
    static void setup() {
        PermissionSetGroup psg  = [SELECT Id, DeveloperName, Status FROM PermissionSetGroup WHERE DeveloperName = 'STANLIB_PortalInstitutionalConsultantGroup'];
        if(psg.Status != 'Updated'){
            Test.calculatePermissionSetGroup(psg.Id);
        }
        
        Account personMasterAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
        DocumentType documentType = [
                SELECT Id, Description
                FROM DocumentType
                LIMIT 1
        ];

        List<DocumentChecklistItem> checklistItems = SC_DAL_DataFactory.newDocumentCheckListItems(personMasterAccount.Id, NUMBER_OF_DOCUMENTS);

        for(DocumentChecklistItem checklistItem: checklistItems){
            checklistItem.DocumentTypeId = documentType.Id;
        }

        insert checklistItems;
        
        Id personAccRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Institutional Person Account').getRecordTypeId();
        Account testAcc = new Account(
            FirstName = 'Test',
            LastName = 'Insto Portal User',
            RecordTypeId = personAccRT,
            SLC_IDNumber__c = 'ABCDEF'
        );
        insert testAcc;
    }

    @IsTest
    static void testFindByParentAndDocType() {
        Account account = AW_DAL_Account.getAll().iterator().next();
        DocumentType documentType = [
                SELECT
                        Id, Description
                FROM DocumentType
                LIMIT 1
        ];
        List<DocumentChecklistItem> documentChecklistItems =
                SLC_DAL_DocumentChecklistItem.findByParentAndDocType(account.Id, new List<String>{
                        documentType.Description
                });

        System.assertEquals(NUMBER_OF_DOCUMENTS, documentChecklistItems.size(), 'Wrong number of documents');
    }
    
    @IsTest
    private static void getCheckListItemByParentInstoConsultant() {
        Account acct = [SELECT Id, SLC_IDNumber__c FROM Account WHERE SLC_IDNumber__c = 'ABCDEF' LIMIT 1];
        
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
        
        //assign permission set
        PermissionSetGroup portalPs = [SELECT Id, DeveloperName, Status FROM PermissionSetGroup WHERE DeveloperName = 'STANLIB_PortalInstitutionalConsultantGroup'];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            PermissionSetGroupId = portalPs.Id, 
            AssigneeId = portUser.Id
        );
        insert psa;  
        
        System.runAs(portUser){   
            test.startTest();
            List<Opportunity> oppList = SLC_DAL_Opportunity.findByParentAccounts(acct.Id);
            test.stopTest();
            
            Assert.isTrue(oppList.size() == 0, 'Opportunities found when should not have found');
        }      
    }

}