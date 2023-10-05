/**
 * @description Test class for SLC_FLOW_CreatePortalUser
 *
 * @author Futureform
 *
 * @date December 2022
 */
@isTest
private class SLC_FLOW_CreatePortalUser_TEST {    
    @IsTest
    private static void testCreateUserPositive(){   
        
        SLC_FLOW_CreatePortalUser.ActionInput[] userInputsInsto = getActionInputs('Test Insto', 'Portal User', 'RSA ID', '9202204720082', 'testportalinst@testuser.com', '+27123456790', 'DFM', 'DFM Operations', 'Stanlib');
        SLC_FLOW_CreatePortalUser.ActionInput[] userInputsRetail = getActionInputs('Test Retail', 'Portal User', 'RSA ID', '9202204720083', 'testportalret@testuser.com', '+27123456791', 'Retail', 'Admin Assistant', 'Stanlib');
        
        test.startTest();
        SLC_FLOW_CreatePortalUser.ActionOutput[] userOuputInsto = SLC_FLOW_CreatePortalUser.createUser(userInputsInsto);
        SLC_FLOW_CreatePortalUser.ActionOutput[] userOuputRetail = SLC_FLOW_CreatePortalUser.createUser(userInputsRetail);
        test.stopTest();
        
        System.assertEquals(true, userOuputInsto[0].booleanOutput, 'Insto Person Account & User not created');
        System.assertEquals(true, userOuputRetail[0].booleanOutput, 'Retail Person Account & User not created');
    }
    
    @IsTest
    private static void testCreateUserNegative(){  
        // Create test person account
        Id personAccRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Retail Person Account').getRecordTypeId();
        Account testAcc = new Account(
            FirstName = 'Test',
            LastName = 'Retail Portal User',
            RecordTypeId = personAccRT,
            SLC_IDNumber__c = 'ABCDEF'
        );
        insert testAcc; 
        
        SLC_FLOW_CreatePortalUser.ActionInput[] userInputs = getActionInputs('Test', 'Portal User', 'RSA ID', 'ABCDEF', 'testportal@testuser.com', '+27123456790', 'DFM', 'DFM Operations', 'Stanlib');
       
        test.startTest();
        SLC_FLOW_CreatePortalUser.ActionOutput[] userOuput = SLC_FLOW_CreatePortalUser.createUser(userInputs);
        test.stopTest();
        
        // Check that a user and person account is not created since a matching email exists in the system
        System.assertEquals(false, userOuput[0].booleanOutput, 'Person Account & User created when insert should have not occurred');
    }
    
    @IsTest
    private static void testGetCustomMetadata(){
        //Retrieve mdt for default owners    
        SLC_SelfRegistrationSetting__mdt cmdt = [SELECT Id, SLI_ProspectAccountDefaultOwnerID__c, SLR_ProspectAccountDefaultOwnerID__c
                                                 FROM SLC_SelfRegistrationSetting__mdt WHERE DeveloperName = 'Stanlib_Self_Registration_Setting'];
        String retailOwner = cmdt.SLR_ProspectAccountDefaultOwnerID__c;
        String instoOwner = cmdt.SLI_ProspectAccountDefaultOwnerID__c;
        
        System.assert(cmdt != null , 'SLC_SelfRegistrationSetting__mdt does not exist');
        System.assert(retailOwner != null, 'No Owner for Retail');
        System.assert(instoOwner != null, 'No Owner for Institutional');
        
    }
    
    static SLC_FLOW_CreatePortalUser.ActionInput[] getActionInputs(String firstName, String lastName, String identificationType, String identificationNumber, String emailAddress, 
                                                                  String mobileNumber, String userType, String userRole, String companyName){
                                                                      
			SLC_FLOW_CreatePortalUser.ActionInput[] actionInputs = new SLC_FLOW_CreatePortalUser.ActionInput[]{};
            SLC_FLOW_CreatePortalUser.ActionInput input = new SLC_FLOW_CreatePortalUser.ActionInput();
                                                                      
            input.firstName = firstName;
            input.lastName = lastName;
            input.identificationType = identificationType;
            input.identificationNumber = identificationNumber;
            input.emailAddress = emailAddress;
            input.mobileNumber = mobileNumber;                                                                    
            input.userType = userType;
            input.userRole = userRole;
            input.companyName = companyName;
                                                                      
            actionInputs.add(input); 

        	return actionInputs;                                                                     
    }

}