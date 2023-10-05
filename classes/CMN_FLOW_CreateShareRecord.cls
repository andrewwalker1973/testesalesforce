/**
 * @description Used to create share records from Sharing Event platform event
 *
 * @author Futureform
 *
 * @date 2022
 */
public without sharing class CMN_FLOW_CreateShareRecord {
    /**
     * @description Creates Share records when Sharing Event platform event is fired
     *
     * @return void
     */
    @InvocableMethod(label='Create Share Record' description='Creates sharing record')
    public static void createShare(List<CMN_SharingEvent__e> sharingEventRecord) {
        List<CaseShare> caseSharesInsert = new List<CaseShare>();
        List<AccountShare> accountSharesInsert = new List<AccountShare>();
        List<FinServ__FinancialAccount__Share> financialAccountSharesInsert = new List<FinServ__FinancialAccount__Share>();
        List<FinServ__FinancialAccountTransaction__Share> financialAccountTransactionSharesInsert = new List<FinServ__FinancialAccountTransaction__Share>();
        
        for(CMN_SharingEvent__e shareEvent : sharingEventRecord){
                                   
            if(shareEvent.CMN_IsCreate__c){
                if(shareEvent.CMN_ObjectName__c == 'Case'){
                    CaseShare shareRecord = new CaseShare();
                    shareRecord.CaseId = shareEvent.CMN_Record_Id__c;
                    shareRecord.UserOrGroupId = shareEvent.CMN_PublicGroupId__c;
                    shareRecord.CaseAccessLevel = 'Read';
                        
                    caseSharesInsert.add(shareRecord);                
                }       
                if(shareEvent.CMN_ObjectName__c == 'Account'){
                    AccountShare shareRecord = new AccountShare();
                    shareRecord.AccountId = shareEvent.CMN_Record_Id__c;
                    shareRecord.UserOrGroupId = shareEvent.CMN_PublicGroupId__c;
                    shareRecord.AccountAccessLevel = 'Read';
                    shareRecord.OpportunityAccessLevel = 'None';
                    shareRecord.CaseAccessLevel = 'None';
                        
                    accountSharesInsert.add(shareRecord);                       
                }
                if(shareEvent.CMN_ObjectName__c == 'FinServ__FinancialAccount__c'){
                    FinServ__FinancialAccount__Share shareRecord = new FinServ__FinancialAccount__Share();
                    shareRecord.ParentId = shareEvent.CMN_Record_Id__c;
                    shareRecord.UserOrGroupId = shareEvent.CMN_PublicGroupId__c;
                    shareRecord.AccessLevel = 'Read';
                    shareRecord.RowCause = Schema.FinServ__FinancialAccount__Share.RowCause.SLC_CodeShare__c;
                        
                    financialAccountSharesInsert.add(shareRecord);                           
                }
                if(shareEvent.CMN_ObjectName__c == 'FinServ__FinancialAccountTransaction__c'){
                    FinServ__FinancialAccountTransaction__Share shareRecord = new FinServ__FinancialAccountTransaction__Share();
                    shareRecord.ParentId = shareEvent.CMN_Record_Id__c;
                    shareRecord.UserOrGroupId = shareEvent.CMN_PublicGroupId__c;
                    shareRecord.AccessLevel = 'Read';
                    shareRecord.RowCause = Schema.FinServ__FinancialAccountTransaction__Share.RowCause.SLC_CodeShare__c;
                        
                    financialAccountTransactionSharesInsert.add(shareRecord);                      
                }
            }  
        }
        
        if(caseSharesInsert.size() > 0){
            insert caseSharesInsert;
        }
        if(accountSharesInsert.size() > 0){
            insert accountSharesInsert;
        }
        if(financialAccountSharesInsert.size() > 0){
            insert financialAccountSharesInsert;
        }
        if(financialAccountTransactionSharesInsert.size() > 0){
            insert financialAccountTransactionSharesInsert;
        }
    }

}