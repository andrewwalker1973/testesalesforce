/**
 * @description Test class for SLC_FLOW_DeleteUserFromGroupACR
 *
 * @author Futureform
 *
 * @date December 2022
 */
@isTest
private class SLC_FLOW_DeleteUserFromGroupACR_TEST {

    @testSetup static void setup() {
        // Create common test account
        Id busAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Institutional Account').getRecordTypeId();
        Account testAcc = new Account(
            Name = 'TestAccount',
            RecordTypeId = busAccRecordTypeId
        );
        insert testAcc;    
        
    }
    
    @IsTest
    private static void testDeleteUserFromGroups(){
        Account acct = [SELECT Id, Name FROM Account WHERE Name='TestAccount' LIMIT 1];
        
        // Create common test user
        Profile admProfile = [SELECT Id FROM Profile WHERE Name='Liberty Administrator'];
        User admuser = new User(FirstName='Test', 
                               LastName='AdmUser', 
                               username='adm@salesforcetest.com', 
                               email='adm@mail.com',
                               alias='admi',
                               communityNickname='po',
                               localesidkey='en_US', 
                               timezonesidkey='GMT',
                               languagelocalekey='en_US',
                               emailencodingkey = 'UTF-8',
                               profileId = admProfile.Id);
        insert admuser; 
        
        // Fetch group that would have been created from account insert
        String accGroupDevName = 'CMN_'+acct.Name+'_AccountRead_'+acct.Id;        
        Group accountGroup = [SELECT Id, Name FROM Group WHERE DeveloperName =: accGroupDevName];
        
        // Create group member
        GroupMember groupmem = new GroupMember(
            GroupId = accountGroup.Id,
            UserOrGroupId = admuser.Id  
        );
        insert groupmem;
        
        List<List<GroupMember>> gmListList = new List<List<GroupMember>>();
        List<GroupMember> gmList = new List<GroupMember>();
        gmList.add(groupmem);
        gmListList.add(gmList);
        
        test.startTest();
        SLC_FLOW_DeleteUserFromGroupACR.deleteUserFromGroups(gmListList);
        test.stopTest();
        
        
        List<GroupMember> gm = [SELECT Id FROM GroupMember WHERE Id =: groupmem.Id];
        
        system.assertEquals(0, gm.size(), 'Group Member not deleted');
    }

}