/**
 * @description Public class to return the records of Opportunity
 *
 * @author Futureform
 *
 * @date December 2022
 */
public inherited sharing class SLC_DAL_Opportunity {
    public static final String OPPORTUNITY_ID = Opportunity.Id.getDescribe().getLocalName();
    private static final String ONBOARDING_RECORDTYPE = 'SLI_InstitutionalOnboarding';
    private static final String INSTO_CONSULTANT_PERMSET_GROUP = 'STANLIB_PortalInstitutionalConsultantGroup';
    private static final String ASSET_CONSULTANT_ROLE = 'Asset consultant';

    public static List<Opportunity> findByParentAccounts(Id accountId) {
        PermissionSetGroup instoConsultantPSG = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName =: INSTO_CONSULTANT_PERMSET_GROUP];
        
        //Check permission set group assignment
        List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetGroupId =: instoConsultantPSG.Id AND AssigneeId =: UserInfo.getUserId()];
        
        //If they are assigned this permission set, return only ACRs where Role = Asset Consultant
        if(psa.size() > 0){
            return [
                    SELECT Id
                    FROM Opportunity
                    WHERE IsClosed = FALSE 
                    AND RecordType.DeveloperName =: ONBOARDING_RECORDTYPE
                    AND AccountId IN (
                            SELECT AccountId
                            FROM AccountContactRelation
                            WHERE (Contact.AccountId = :accountId
                            OR AccountId = :accountId)
                        	AND Roles =: ASSET_CONSULTANT_ROLE
                    )
            ];            
        } else { //Else return all ACRs
            return [
                    SELECT Id
                    FROM Opportunity
                    WHERE IsClosed = FALSE 
                    AND RecordType.DeveloperName =: ONBOARDING_RECORDTYPE
                    AND AccountId IN (
                            SELECT AccountId
                        FROM AccountContactRelation
                        WHERE Contact.AccountId = :accountId
                        OR AccountId = :accountId
                )
        ];
    }
        
       

    }
    

}