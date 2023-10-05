/**
 * @description Used for Manual Sharing flows for Institutional sharing
 *
 * @author Futureform
 *
 * @date 2022
 */
public class CMN_FLOW_CreatePublicGroupsForShare {
    /**
     * @description Creates public groups for AccountShare when new Insto business account created and updates the business account
     * with the group ids
     *
     * @return void
     */
    @InvocableMethod(label='Create Public Groups' description='Creates public groups for sharing records')
    public static void createAccountGroups(List<String> actIds) { 
        List<Account> accIds = [SELECT Id, Name, RecordTypeId FROM Account WHERE Id IN : actIds];
        List<Account> acctsToUpdate = new List<Account>();
        List<Group> accGroupsToInsert = new List<Group>();
        List<Group> caseGroupsToInsert = new List<Group>();
        
        Map<String, String> accGroupMap = new Map<String, String>();
        Map<String, String> caseGroupMap = new Map<String, String>();
        
        for(Account acct : accIds){            
            String accountName = acct.Name;            
            if(accountName.length() >= 28){
                accountName = acct.Name.substring(0,28);
            }
            String accountNameNoGaps = accountName.replaceAll('[^a-zA-Z0-9\\s+]', '');
            accountNameNoGaps = accountNameNoGaps.replaceAll( '\\s+', '');
            if(accountNameNoGaps.contains('+')){
                accountNameNoGaps = accountNameNoGaps.replaceAll('\\+', '');
            }
    
            //Create Account and Case Read Groups
            Group accountGroup = new Group(
                Name = accountName+' AccountRead',
                DeveloperName = 'CMN_'+accountNameNoGaps+'_AccountRead_'+acct.Id,
                doesIncludeBosses = false
            );     
            Group caseGroup = new Group(
                Name = accountName+' CaseRead',
                DeveloperName = 'CMN_'+accountNameNoGaps+'_CaseRead_'+acct.Id,
                doesIncludeBosses = false
            );
            
            accGroupsToInsert.add(accountGroup);
            caseGroupsToInsert.add(caseGroup); 
        }
        
        insert accGroupsToInsert;
        insert caseGroupsToInsert;
        
        List<Group> accGroups = [SELECT Id, DeveloperName FROM Group WHERE Id IN : accGroupsToInsert];
        for(Group accGroup : accGroups){
            accGroupMap.put(accGroup.DeveloperName.right(18), accGroup.Id);
        }        
        
        List<Group> caseGroups = [SELECT Id, DeveloperName FROM Group WHERE Id IN : caseGroupsToInsert];
        for(Group caseGroup : caseGroups){
            caseGroupMap.put(caseGroup.DeveloperName.right(18), caseGroup.Id);
        }        
        
        for(Account acct : accIds){
            //Update Account record
            acct.CMN_CreatePublicGroups__c = false;
            acct.CMN_PublicGroupAccountRead__c = accGroupMap.get(acct.Id);
            acct.CMN_PublicGroupCaseRead__c = caseGroupMap.get(acct.Id);
            
            acctsToUpdate.add(acct);
        }
        
        update acctsToUpdate;

    }

}