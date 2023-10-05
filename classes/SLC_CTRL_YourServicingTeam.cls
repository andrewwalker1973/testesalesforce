/**
 * @description Controller for the Your Servicing Team LWC
 *
 * @author Futureform
 *
 * @date October 2022
 */
public without sharing class SLC_CTRL_YourServicingTeam {
    
    @AuraEnabled
    public static Account getAccountDetails(String userAccountId){
        Account personAccount = [SELECT Id, Name, SLR_Channel__c, SLR_MannedUnmanned__c,AW_ParentAccount__c, OwnerId,
                                 Owner.FirstName, Owner.LastName, Owner.FullPhotoUrl, Owner.Email, Owner.Phone, Owner.Title,
                                 AW_ParentAccount__r.SLI_ClientClassification__c, AW_ParentAccount__r.SLI_AlternateOwner__c,
                                 AW_ParentAccount__r.SLI_AlternateOwner__r.FirstName, AW_ParentAccount__r.SLI_AlternateOwner__r.LastName,
                                 AW_ParentAccount__r.SLI_AlternateOwner__r.FullPhotoUrl, AW_ParentAccount__r.SLI_AlternateOwner__r.Email,
                                 AW_ParentAccount__r.SLI_AlternateOwner__r.Phone, AW_ParentAccount__r.SLI_AlternateOwner__r.Title
                                 FROM Account WHERE Id =: userAccountId];        
        return personAccount;
    }
    
    @AuraEnabled
    public static List<User> getUnmannedContacts(){   
        List<SLC_Unmanned_Contact__mdt> members = [SELECT Id, Member_User_Id__c FROM SLC_Unmanned_Contact__mdt];
        
        List<String> userIds = new List<String>();        
        for(SLC_Unmanned_Contact__mdt membs : members){
            userIds.add(membs.Member_User_Id__c);
        }
        
        List<User> unmannedUsers = [SELECT Id, FirstName, LastName, Name, FullPhotoUrl, Email, Title, Phone FROM User
                                	WHERE Id IN : userIds ORDER BY FirstName];
		        
        return unmannedUsers;        
    }   
         
    @AuraEnabled
    public static List<User> getClientExpTeam(String teamName){   
        List<SLC_Client_Experience_Teams__mdt> teammembers = [SELECT Id, Client_Classification__c, Member_User_Id__c 
                                                  FROM SLC_Client_Experience_Teams__mdt  
                                                  WHERE Client_Classification__c =: teamName];
        
        List<String> userIds = new List<String>();        
        for(SLC_Client_Experience_Teams__mdt membs : teammembers){
            userIds.add(membs.Member_User_Id__c);
        }
        
        List<User> teamUsers = [SELECT Id, FirstName, LastName, Name, FullPhotoUrl, Email, Title, Phone FROM User
                                WHERE Id IN : userIds ORDER BY FirstName];
		        
        return teamUsers;        
    }   
    
    @AuraEnabled
    public static List<User> getEscalationTeam(String teamName){   
        List<SLC_Escalation_Teams__mdt> teammembers = [SELECT Id, Client_Classification__c, Member_User_Id__c 
                                                    FROM SLC_Escalation_Teams__mdt
                                                    WHERE Client_Classification__c =: teamName];
        
        List<String> userIds = new List<String>();        
        for(SLC_Escalation_Teams__mdt membs : teammembers){
            userIds.add(membs.Member_User_Id__c);
        }
        
        List<User> teamUsers = [SELECT Id, FirstName, LastName, Name, FullPhotoUrl, Email, Title, Phone FROM User
                                WHERE Id IN : userIds ORDER BY FirstName];      
		        
        return teamUsers;        
    }   

}