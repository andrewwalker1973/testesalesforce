/**
 * @description This class is use to match user record when logging using Synthesis SSO
 *
 * @author Futureform
 *
 * @date 2022
 */
global class SLC_Auth_Synthesis_Portal implements Auth.RegistrationHandler  {
    private static final String ERROR_NO_FEDERATION_IDENTIFIER_RECEIVED = 'No Email Or UserName Attribute received.';

    class SynthesisException extends Exception {
    }

    global User createUser(Id portalId, Auth.UserData data){
        
        if (String.isBlank(data.identifier )) {
          throw new SynthesisException(ERROR_NO_FEDERATION_IDENTIFIER_RECEIVED);
        }

        User foundUser;

        if (String.isNotBlank(data.identifier )) {
          foundUser = CMN_DAL_User.findUserByFederationId(data.identifier);
        }

        system.debug(data);
        system.debug(foundUser);
        
        return foundUser;
    
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        
    }
}