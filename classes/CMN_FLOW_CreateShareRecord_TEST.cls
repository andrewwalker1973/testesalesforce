@isTest
private class CMN_FLOW_CreateShareRecord_TEST {
    
    @testSetup static void setup() {
        // Create common test account
        Id busAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Institutional Account').getRecordTypeId();
        Account testAcc = new Account(
            Name = 'TestAccount',
            RecordTypeId = busAccRecordTypeId
        );
        insert testAcc; 
        
        //Create common test case
        Case testCase = new Case(
        	Subject = 'TestCase',
            AccountId = testAcc.Id
        );
        insert testCase;
        
        FinServ__FinancialAccount__c testFinAcc = new FinServ__FinancialAccount__c(
        	Name = 'TestFinAcc',
            FinServ__PrimaryOwner__c = testAcc.Id
        );
        insert testFinAcc;
        
        FinServ__FinancialAccountTransaction__c testFinAccTrans = new FinServ__FinancialAccountTransaction__c(
        	FinServ__Amount__c = 900000,
            FinServ__FinancialAccount__c = testFinAcc.Id,
            FinServ__TransactionId__c = '123',
            FinServ__TransactionDate__c = Date.today()
        );
        insert testFinAccTrans;        
    }
    
    @IsTest
    private static void testCreateShareAccount(){
		Account acct = [SELECT Id, Name FROM Account WHERE Name='TestAccount' LIMIT 1];
        
        //Fetch group that would have been created from account insert
		String accGroupDevName = 'CMN_'+acct.Name+'_AccountRead_'+acct.Id;        
        Group accountGroup = [SELECT Id, Name FROM Group WHERE DeveloperName =: accGroupDevName];
        
        //Create Share via Sharing Event platform event
        List<CMN_SharingEvent__e> eventToInsert = new List<CMN_SharingEvent__e>();
        CMN_SharingEvent__e accountShareEvent = new CMN_SharingEvent__e();
        accountShareEvent.CMN_IsCreate__c = true;
        accountShareEvent.CMN_ObjectName__c = 'Account';
        accountShareEvent.CMN_PublicGroupId__c = accountGroup.Id;
        accountShareEvent.CMN_Record_Id__c = acct.Id;   
        eventToInsert.add(accountShareEvent);
        
        test.startTest();
        CMN_FLOW_CreateShareRecord.createShare(eventToInsert);
        test.stopTest();
     
        List<AccountShare> accShare = [SELECT Id FROM AccountShare WHERE AccountId =: acct.Id AND RowCause = 'Manual'];
        
        system.assertEquals(1, accShare.size(), 'No AccountShare found');
    }
    
    @IsTest
    private static void testCreateShareCase(){
        Account acct = [SELECT Id, Name FROM Account WHERE Name='TestAccount' LIMIT 1];
        Case tstCase = [SELECT Id, Subject FROM Case WHERE Subject='TestCase' LIMIT 1];
        
        //Fetch group that would have been created from account insert
		String caseGroupDevName = 'CMN_'+acct.Name+'_CaseRead_'+acct.Id;        
        Group caseGroup = [SELECT Id, Name FROM Group WHERE DeveloperName =: caseGroupDevName];
        
        //Create Share via Sharing Event platform event
        List<CMN_SharingEvent__e> eventToInsert = new List<CMN_SharingEvent__e>();
        CMN_SharingEvent__e caseShareEvent = new CMN_SharingEvent__e();
        caseShareEvent.CMN_IsCreate__c = true;
        caseShareEvent.CMN_ObjectName__c = 'Case';
        caseShareEvent.CMN_PublicGroupId__c = caseGroup.Id;
        caseShareEvent.CMN_Record_Id__c = tstCase.Id;   
        eventToInsert.add(caseShareEvent);
        
        test.startTest();
        CMN_FLOW_CreateShareRecord.createShare(eventToInsert);
        test.stopTest();
     
        List<CaseShare> caseShare = [SELECT Id FROM CaseShare WHERE CaseId =: tstCase.Id AND RowCause = 'Manual'];
        
        system.assertEquals(1, caseShare.size(), 'No CaseShare found');
    }
    
    @IsTest
    private static void testCreateShareFinancialAccount(){
        Account acct = [SELECT Id, Name FROM Account WHERE Name='TestAccount' LIMIT 1];
        FinServ__FinancialAccount__c tstFA = [SELECT Id, Name FROM FinServ__FinancialAccount__c WHERE Name='TestFinAcc' LIMIT 1];
        
        //Fetch group that would have been created from account insert
		String accGroupDevName = 'CMN_'+acct.Name+'_AccountRead_'+acct.Id;        
        Group accGroup = [SELECT Id, Name FROM Group WHERE DeveloperName =: accGroupDevName];
        
        //Create Share via Sharing Event platform event
        List<CMN_SharingEvent__e> eventToInsert = new List<CMN_SharingEvent__e>();
        CMN_SharingEvent__e faShareEvent = new CMN_SharingEvent__e();
        faShareEvent.CMN_IsCreate__c = true;
        faShareEvent.CMN_ObjectName__c = 'FinServ__FinancialAccount__c';
        faShareEvent.CMN_PublicGroupId__c = accGroup.Id;
        faShareEvent.CMN_Record_Id__c = tstFA.Id;   
        eventToInsert.add(faShareEvent);
        
        test.startTest();
        CMN_FLOW_CreateShareRecord.createShare(eventToInsert);
        test.stopTest();
     
        List<FinServ__FinancialAccount__Share> faShare = [SELECT Id FROM FinServ__FinancialAccount__Share WHERE ParentId =: tstFA.Id AND RowCause = 'SLC_CodeShare__c'];
        
        system.assertEquals(1, faShare.size(), 'No FinancialAccount_Share found');
    }
    
    @IsTest
    private static void testCreateShareFinancialAccountTransaction(){
        Account acct = [SELECT Id, Name FROM Account WHERE Name='TestAccount' LIMIT 1];
        FinServ__FinancialAccountTransaction__c tstFAT = [SELECT Id, Name FROM FinServ__FinancialAccountTransaction__c WHERE FinServ__TransactionId__c='123' LIMIT 1];
        
        //Fetch group that would have been created from account insert
		String accGroupDevName = 'CMN_'+acct.Name+'_AccountRead_'+acct.Id;        
        Group accGroup = [SELECT Id, Name FROM Group WHERE DeveloperName =: accGroupDevName];

        //Create Share via Sharing Event platform event
        List<CMN_SharingEvent__e> eventToInsert = new List<CMN_SharingEvent__e>();
        CMN_SharingEvent__e fatShareEvent = new CMN_SharingEvent__e();
        fatShareEvent.CMN_IsCreate__c = true;
        fatShareEvent.CMN_ObjectName__c = 'FinServ__FinancialAccountTransaction__c';
        fatShareEvent.CMN_PublicGroupId__c = accGroup.Id;
        fatShareEvent.CMN_Record_Id__c = tstFAT.Id;   
        eventToInsert.add(fatShareEvent);
        
        test.startTest();
        CMN_FLOW_CreateShareRecord.createShare(eventToInsert);
        test.stopTest();
     
        List<FinServ__FinancialAccountTransaction__Share> fatShare = [SELECT Id FROM FinServ__FinancialAccountTransaction__Share WHERE ParentId =: tstFAT.Id AND RowCause = 'SLC_CodeShare__c'];
        
        system.assertEquals(1, fatShare.size(), 'No FinancialAccountTransaction_Share found');
    }

    
}