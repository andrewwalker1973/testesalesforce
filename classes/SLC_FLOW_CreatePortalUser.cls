/**
 * @description Class invoked by flow that creates portal Person Account record and enqueues queuable class to create corresponding User
 *
 * @author Futureform
 *
 * @date January 2023
 */
public without sharing class SLC_FLOW_CreatePortalUser {
    
    @InvocableMethod(label='Create Portal User' description='Creates portal user and person account if no duplication record found')
    public static ActionOutput[] createUser(ActionInput[] inputs) {
        Id retailRt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Retail Person Account').getRecordTypeId();
        Id instoRt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Stanlib Institutional Person Account').getRecordTypeId();
        ActionOutput[] outputs = new ActionOutput[]{};
        List<Account> accountToInsert = new List<Account>();
            
        //Retrieve mdt for default owners    
        SLC_SelfRegistrationSetting__mdt cmdt = [SELECT Id, SLI_ProspectAccountDefaultOwnerID__c, SLR_ProspectAccountDefaultOwnerID__c
                                                 FROM SLC_SelfRegistrationSetting__mdt WHERE DeveloperName = 'Stanlib_Self_Registration_Setting'];
        String retailOwner = cmdt.SLR_ProspectAccountDefaultOwnerID__c;
        String instoOwner = cmdt.SLI_ProspectAccountDefaultOwnerID__c;
            
        ActionInput input = inputs[0];
        ActionOutput output = new ActionOutput();
        String idNumber = input.identificationNumber;
            
        List<Account> persAcc = [SELECT Id, SLC_IDNumber__c FROM Account 
                                     WHERE (RecordTypeId =: retailRt OR RecordTypeId =: instoRt)
                                     AND (SLC_IDNumber__c =: idNumber)]; 
            
            if(persAcc.size() > 0){
                output.booleanOutput = false;                
            } else {
				Id personAccRT;
                Boolean prospectStatus;
                String clientStatus;
                String mannedStatus;
                Boolean emailOptOut;
                String ownerId;
                
                if(input.userType == 'Retail'){
                    personAccRT = retailRt;
                    prospectStatus = true;
                    clientStatus = 'Inactive';
                    mannedStatus = 'Unmanned';
                    emailOptOut = true;
                    ownerId = retailOwner;
                } else {
                    personAccRT = instoRt;
                    prospectStatus = true;
                    emailOptOut = false;
                    ownerId = instoOwner;
                }
                
                Account personAccount = new Account(
                    FirstName = input.firstName,
                    LastName = input.lastName,
                    RecordTypeId = personAccRT,
                    SLC_IDNumber__c = input.identificationNumber,
                    Type = input.userRole,
                    OwnerId = ownerId,
                PersonEmail = input.emailAddress,
                AW_Company__c = input.companyName,
                Phone = input.mobileNumber,
                    SLC_Prospect__c = prospectStatus,
                    SLC_Client_Status__c = clientStatus,
                    SLR_MannedUnmanned__c = mannedStatus,
                    PersonHasOptedOutOfEmail = emailOptOut    
                );    
            accountToInsert.add(personAccount);
            output.booleanOutput = true; 
        }            

        if(accountToInsert.size() > 0){
            insert accountToInsert;   
            System.enqueueJob(new SLC_QUE_CreatePortalUser(accountToInsert[0]));            
        }
        
        outputs.add(output); 
        return outputs;        
    }
    
    public class ActionInput { 
        @InvocableVariable(label='First Name' required=true)
        public String firstName;

        @InvocableVariable(label='Last Name' required=true)
        public String lastName;

        @InvocableVariable(label='Identification Type' required=true)
        public String identificationType;
        
        @InvocableVariable(label='Identification Number' required=true)
        public String identificationNumber;
        
        @InvocableVariable(label='Email Address' required=true)
        public String emailAddress;
        
        @InvocableVariable(label='Mobile Number' required=true)
        public String mobileNumber;
        
        @InvocableVariable(label='User Type' required=true)
        public String userType;
        
        @InvocableVariable(label='Role' required=true)
        public String userRole;
        
        @InvocableVariable(label='Company Name' required=true)
        public String companyName;
    }
    
    public class ActionOutput {
        @InvocableVariable(label='Successful record creation')
        public Boolean booleanOutput;
     }

}