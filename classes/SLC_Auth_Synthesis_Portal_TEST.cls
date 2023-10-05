/**
 * @description Test class for SLC_Auth_Synthesis_Portal
 *
 * @author Futureform
 *
 * @date December 2022
 */
@isTest
private class SLC_Auth_Synthesis_Portal_TEST {
    @testSetup static void setup() {
        Id personAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Institutional Person Account').getRecordTypeId();
        Account personAcc = new Account(
            LastName = 'Test', 
            RecordTypeId = personAccRecordTypeId
        );
        insert personAcc;                  
    }
        
    @IsTest
    private static void testCreateUser() {
        Account acct = [SELECT Id, Name FROM Account WHERE LastName='Test' LIMIT 1];
        
        //Create portal user
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='STANLIB Portal User'];
        User portUser = new User(FirstName='testFirst', 
                               LastName='testLast', 
                               username='testuserlong@salesforce.com', 
                               email='testuser@example.org',
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
        
        Auth.UserData sampleData = new Auth.UserData(
            '65783094', 
            'testFirst', 
            'testLast',
            'testFirst testLast', 
            'testuser@example.org', 
            null, 
            'testuserlong@salesforce.com', 
            'en_US', 
            null,
            null, 
            new Map<String, String>{'language' => 'en_US'}
        );
        
        SLC_Auth_Synthesis_Portal handler = new SLC_Auth_Synthesis_Portal();
        
        User u = handler.createUser(portUser.Id, sampleData);
        System.assertEquals('testuserlong@salesforce.com', u.userName, 'Incorrect username');
        System.assertEquals('testuser@example.org', u.email, 'Incorrect email');
        System.assertEquals('testLast', u.lastName, 'Incorect last name');
        System.assertEquals('testFirst', u.firstName, 'Incorrect first name');
    }
    
    @IsTest
    private static void testCreateUserException() {
        Account acct = [SELECT Id, Name FROM Account WHERE LastName='Test' LIMIT 1];
        
        //Create portal user
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='STANLIB Portal User'];
        User portUser = new User(FirstName='testFirst', 
                               LastName='testLast', 
                               username='testuserlong@salesforce.com', 
                               email='testuser@example.org',
                               alias='user',
                               communityNickname='portal',
                               localesidkey='en_US', 
                               timezonesidkey='GMT',
                               languagelocalekey='en_US',
                               emailencodingkey = 'UTF-8',
                               phone='+278067538320',
                               profileId = portalProfile.Id,
                               contactId = [SELECT Id, AccountId FROM Contact WHERE AccountId =: acct.Id].Id);
        insert portUser;         
        
        Auth.UserData sampleData = new Auth.UserData(
            null, 
            'testFirst', 
            'testLast',
            'testFirst testLast', 
            'testuser@example.org', 
            null, 
            'testuserlong@salesforce.com', 
            'en_US', 
            null,
            null, 
            new Map<String, String>{'language' => 'en_US'}
        );
        
        SLC_Auth_Synthesis_Portal handler = new SLC_Auth_Synthesis_Portal();
        
        Boolean exceptionOccurred = false;
        try {
            User u = handler.createUser(portUser.Id, sampleData);
        } catch (Exception e){
            exceptionOccurred = true;
        }
        
        System.assertEquals(true, exceptionOccurred, 'Exception expected but did not occur');
        
    }

}