@isTest
private class CMN_FLOW_CreatePublicGroupsForShare_TEST {
    
    @IsTest
    private static void testCreateAccountGroups(){
        Id personAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Institutional Person Account').getRecordTypeId();
        Id busAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Institutional Account').getRecordTypeId();
        
        Account busAcc = new Account(
            Name = 'Test Parent Institutional Business Account',
            RecordTypeId = busAccRecordTypeId
        );
        
        test.startTest();
        insert busAcc;
        test.stopTest();
        
        String accGroupDevName = 'CMN_TestParentInstitutionalBu_AccountRead_'+busAcc.Id;
        
        List<Group> accGroup = [SELECT Id, Name FROM Group WHERE DeveloperName =: accGroupDevName];
        
        system.assertequals(1, accGroup.size(), 'Account Group not found');
    }
    
    @IsTest
    private static void testRemoveSpecialCharacters(){
        Id busAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Institutional Account').getRecordTypeId();
        
        Account busAcc = new Account(
            Name = 'Test Insto Acc +4%',
            RecordTypeId = busAccRecordTypeId
        );
        
        test.startTest();
        insert busAcc;
        test.stopTest();
                
        String searchString = '%' + busAcc.Id + '%';
        List<Group> accGroup = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName LIKE : searchString];
        
        Assert.isFalse(accGroup[0].DeveloperName.contains('+'), 'Group developer name contains special characters');
        Assert.isFalse(accGroup[0].DeveloperName.contains('%'), 'Group developer name contains special characters');   
    }

}