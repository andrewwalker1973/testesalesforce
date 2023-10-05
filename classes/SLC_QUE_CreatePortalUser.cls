/**
 * @description Class enqueued by SLC_FLOW_CreatePortalUser that creates User to corresponding Person Account and assigns them to portal permission set
 *
 * @author Futureform
 *
 * @date January 2023
 */
public class SLC_QUE_CreatePortalUser implements Queueable {
    
    public Account portUser;
    
    public SLC_QUE_CreatePortalUser(Account portalPerson){
        portUser = portalPerson;

    }
    
    public void execute(QueueableContext qc){
        Integer retryCount = 0;
        String userAlias;
        if(portUser.FirstName.length() >= 2  && portUser.LastName.length() >= 2){
            userAlias = portUser.FirstName.substring(0,2) + portUser.LastName.substring(0,2);
        } else {
            userAlias = 'portUser';
        }
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='STANLIB Portal User'];
        User portalUser = new User(FirstName = portUser.FirstName, 
                                   LastName = portUser.LastName, 
                                   Username = portUser.PersonEmail, 
                                   Email = portUser.PersonEmail, 
                                   FederationIdentifier = portUser.SLC_IDNumber__c,
                                   Phone = portUser.Phone,
                                   ProfileId = portalProfile.Id,
                                   ContactId = [SELECT Id, AccountId FROM Contact WHERE AccountId =: portUser.Id].Id,
                                   Alias = userAlias,
                                   LocaleSidKey='en_ZA', 
                                   TimeZoneSidKey='Africa/Johannesburg',
                                   LanguageLocaleKey='en_US',
                                   EmailEncodingKey = 'UTF-8'
                                  );
        
        try {
            insert portalUser;
            
            //assign permission set
            PermissionSetGroup portalPs = [SELECT Id, DeveloperName, Status FROM PermissionSetGroup WHERE DeveloperName = 'STANLIB_PortalProspectGroup'];
            if(portalPs.Status == 'Updated'){
                PermissionSetAssignment psa = new PermissionSetAssignment(
                    PermissionSetGroupId = portalPs.Id, 
                    AssigneeId = portalUser.Id
                );
            	insert psa;
        	}
        } catch(DmlException ex) {
            //retry user insertion three times
            while(retryCount <= 2){
                System.enqueueJob(new SLC_QUE_CreatePortalUser(portUser));
                retryCount += 1;
            }
            System.debug(ex.getMessage());
        }
        
    }    

}