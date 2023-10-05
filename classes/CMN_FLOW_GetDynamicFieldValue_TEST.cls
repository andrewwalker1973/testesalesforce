@isTest
private class CMN_FLOW_GetDynamicFieldValue_TEST {

    @isTest
    static void getDynamicSObjectFieldValueTest() {

        Account dummyAcc = new Account(
            Name = 'DummyAccount', 
            AnnualRevenue = 100.0, 
            NumberOfEmployees = 5, 
            CMN_CreatePublicGroups__c = FALSE,
            SLI_LastUpdatedContract__c = Date.today()
        );
        insert dummyAcc;
        
        dummyAcc = [SELECT Id, Name, AnnualRevenue, NumberOfEmployees, CMN_CreatePublicGroups__c, SLI_LastUpdatedContract__c, CreatedDate FROM Account WHERE Id =: dummyAcc.Id];

        CMN_FLOW_GetDynamicFieldValue.ActionInput[] actionInputString = getFlowActionInputs(
            dummyAcc, 
            'Account',
            'Name'
        );
        
        CMN_FLOW_GetDynamicFieldValue.ActionInput[] actionInputCurrency = getFlowActionInputs(
            dummyAcc, 
            'Account',
            'AnnualRevenue'
        );
        
        CMN_FLOW_GetDynamicFieldValue.ActionInput[] actionInputInteger = getFlowActionInputs(
            dummyAcc, 
            'Account',
            'NumberOfEmployees'
        );
        
        CMN_FLOW_GetDynamicFieldValue.ActionInput[] actionInputDate = getFlowActionInputs(
            dummyAcc, 
            'Account',
            'SLI_LastUpdatedContract__c '
        );
        
        CMN_FLOW_GetDynamicFieldValue.ActionInput[] actionInputDateTime = getFlowActionInputs(
            dummyAcc, 
            'Account',
            'CreatedDate'
        );
        
        CMN_FLOW_GetDynamicFieldValue.ActionInput[] actionInputBoolean = getFlowActionInputs(
            dummyAcc, 
            'Account',
            'CMN_CreatePublicGroups__c'
        );

        test.startTest();
        CMN_FLOW_GetDynamicFieldValue.ActionOutput[] outputString = CMN_FLOW_GetDynamicFieldValue.getDynamicSObjectFieldValue(actionInputString);
        CMN_FLOW_GetDynamicFieldValue.ActionOutput[] outputCurrency = CMN_FLOW_GetDynamicFieldValue.getDynamicSObjectFieldValue(actionInputCurrency);
        CMN_FLOW_GetDynamicFieldValue.ActionOutput[] outputInteger = CMN_FLOW_GetDynamicFieldValue.getDynamicSObjectFieldValue(actionInputInteger);
        CMN_FLOW_GetDynamicFieldValue.ActionOutput[] outputDate = CMN_FLOW_GetDynamicFieldValue.getDynamicSObjectFieldValue(actionInputDate);
        CMN_FLOW_GetDynamicFieldValue.ActionOutput[] outputDateTime = CMN_FLOW_GetDynamicFieldValue.getDynamicSObjectFieldValue(actionInputDateTime);
        CMN_FLOW_GetDynamicFieldValue.ActionOutput[] outputBoolean = CMN_FLOW_GetDynamicFieldValue.getDynamicSObjectFieldValue(actionInputBoolean);
        test.stopTest();
       
        System.assertEquals(dummyAcc.Name, outputString[0].stringOutput,'Unexpected string output.');
        System.assertEquals(dummyAcc.AnnualRevenue, outputCurrency[0].currencyOutput,'Unexpected currency output.');
        System.assertEquals(dummyAcc.NumberOfEmployees, outputInteger[0].numberOutput,'Unexpected integer output.');
        System.assertEquals(dummyAcc.SLI_LastUpdatedContract__c , outputDate[0].dateOutput,'Unexpected date output.');
        System.assertEquals(dummyAcc.CreatedDate, outputDateTime[0].datetimeOutput,'Unexpected datetime output.');
        System.assertEquals(dummyAcc.CMN_CreatePublicGroups__c, outputBoolean[0].booleanOutput,'Unexpected boolean output.');
    }

    @isTest
    static void exceptionTest() {

        CMN_FLOW_GetDynamicFieldValue.ActionInput[] actionInputs = getFlowActionInputs(
            new Account(),
            'Account', 
            'InvalidName'
        );

        Test.startTest();

        try {
            CMN_FLOW_GetDynamicFieldValue.getDynamicSObjectFieldValue(actionInputs);
        } catch (CMN_FLOW_GetDynamicFieldValue.CustomException ex) {
            System.assert(
                ex.getMessage().contains('Invalid Field'), 
                'Exception message is expected to contain \'Invalid Field\' phrase.'
            );
        }

        Test.stopTest();
    }

    static CMN_FLOW_GetDynamicFieldValue.ActionInput[] getFlowActionInputs(SObject record, String objectApiName, String fieldApiName){
        CMN_FLOW_GetDynamicFieldValue.ActionInput[] actionInputs = new CMN_FLOW_GetDynamicFieldValue.ActionInput[]{};
            CMN_FLOW_GetDynamicFieldValue.ActionInput input = new CMN_FLOW_GetDynamicFieldValue.ActionInput();
            input.record = record;
            input.objectApiName = objectApiName;
            input.fieldApiName = fieldApiName;

            actionInputs.add(input); 

        	return actionInputs;
    }
}