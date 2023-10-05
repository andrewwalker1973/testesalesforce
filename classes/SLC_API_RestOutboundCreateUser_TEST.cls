/**
 * @description Test class for SLC_API_RestOutboundCreateUser
 *
 * @author Futureform
 *
 * @date December 2022
 */
@isTest
private class SLC_API_RestOutboundCreateUser_TEST {    
    
    @testSetup static void setup() {
        Id personAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Institutional Person Account').getRecordTypeId();
        Account personAcc = new Account(
            LastName = 'Test', 
            RecordTypeId = personAccRecordTypeId
        );
        insert personAcc;                  
    }
    
	/**
	 * @description Test Method to validate the scenario wherein successful outbound API call is made to send new User to Mulesoft
	 */       
    @IsTest
    private static void testSuccessful(){
        Account acct = [SELECT Id, Name FROM Account WHERE LastName='Test' LIMIT 1];
        
        // Create users
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

        Profile admProfile = [SELECT Id FROM Profile WHERE Name='Liberty Administrator'];
        User admUser = new User(FirstName='Test', 
                               LastName='AdmUser', 
                               username='adm@salesforcetest.com', 
                               email='adm@mail.com',
                               alias='admi',
                               communityNickname='admin',
                               localesidkey='en_US', 
                               timezonesidkey='GMT',
                               languagelocalekey='en_US',
                               emailencodingkey = 'UTF-8',
                               profileId = admProfile.Id);
        insert admUser;
        
        System.runAs(admUser){          
            
            SLC_API_RestOutboundCreateUser.mockStatus = 'Success';
            SLC_API_RestOutboundCreateUser.mockError = '[]';
            SLC_API_RestOutboundCreateUser.mockPayload = 'identityNumber":"65783094","givenName":"Test","familyName":"User","email":"user@mail.com","phoneNumber":"+278067538320';
            
            CMN_API_RestBaseOutboundTestHelper.successfulCall(SLC_API_RestOutboundCreateUser.SERVICE_NAME, portUser.Id);          
        }       
        
    }
    
	/**
	 * @description Check that the service aborts if the Id provided does not find a User
	 *
	 * @see SLC_API_RestOutboundCreateUser.abortRequest
	 */
    @IsTest
    private static void abortedCallNoItemFound(){
        CMN_API_RestBaseOutboundTestHelper.abortedCall(SLC_API_RestOutboundCreateUser.SERVICE_NAME, '0052500000AMBzfAAX');		
	}

    
    
}