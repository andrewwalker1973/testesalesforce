/**
 * @description Test class for the controller of the Your Servicing Team LWC
 *
 * @see SLC_CTRL_YourServicingTeam
 *
 * @author Futureform
 *
 * @date October 2022
 */
@isTest
private class SLC_CTRL_YourServicingTeam_TEST {
    
    @IsTest
    private static void testGetAccountDetails(){
        Id personAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Institutional Person Account').getRecordTypeId();
        Id busAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Institutional Account').getRecordTypeId();
        
        Account busAcc = new Account(
        	Name = 'Test Parent Acc 123',
            RecordTypeId = busAccRecordTypeId,
            SLI_KnowYourCustomerCategory__c = 'RSA Company'
        );
        insert busAcc;
        
        Account personAcc = new Account(
            LastName = 'Test', 
            RecordTypeId = personAccRecordTypeId, 
            SLR_MannedUnmanned__c = 'Manned',
            AW_ParentAccount__c = busAcc.Id
        );
        insert personAcc;
        
        test.startTest();
        Account personAccount = SLC_CTRL_YourServicingTeam.getAccountDetails(personAcc.Id);
        test.stopTest();
        
        System.assertEquals(busAcc.Id, personAccount.AW_ParentAccount__c, 'Correct Account details not returned');
             
    }
    
    @IsTest
    private static void testGetUnmannedContacts(){
        List<User> unmannedList = SLC_CTRL_YourServicingTeam.getUnmannedContacts();
        
        if(unmannedList.size() > 0){
            List<SLC_Unmanned_Contact__mdt> members = [SELECT Id, Member_User_Id__c FROM SLC_Unmanned_Contact__mdt WHERE Member_User_Id__c =: unmannedList[0].Id];
            
            System.assertEquals(1, members.size(), 'No records in SLC_Unmanned_Contact__mdt');
        }   
                   
    }
    
    @IsTest
    private static void testGetClientExpTeam(){
        List<User> servicingList = SLC_CTRL_YourServicingTeam.getClientExpTeam('Institutional');
        
        if(servicingList.size() > 0){
            List<SLC_Client_Experience_Teams__mdt> members = [SELECT Id, Member_User_Id__c FROM SLC_Client_Experience_Teams__mdt WHERE Member_User_Id__c =: servicingList[0].Id AND Client_Classification__c = 'Institutional'];
            
            System.assertEquals(1, members.size(), 'No Institutional team in SLC_Client_Experience_Teams__mdt');            
        }
    }
    
    
    @IsTest
    private static void testGetEscalationTeam(){
        List<User> escalationList = SLC_CTRL_YourServicingTeam.getEscalationTeam('Institutional');
        
        if(escalationList.size() > 0){
            List<SLC_Escalation_Teams__mdt> members = [SELECT Id, Member_User_Id__c FROM SLC_Escalation_Teams__mdt WHERE Member_User_Id__c =: escalationList[0].Id AND Client_Classification__c = 'Institutional'];
            
            system.assertEquals(1, members.size(), 'No Institutional team in SLC_Escalation_Teams__mdt');            
        }        
    }

}