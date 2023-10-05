/**
 * @description This class is use to match user record when logging using SSO or Azure B2C
 *
 * @author Accenture
 *
 * @date 2019
 */
global class AW_AUTH_AzureB2C implements Auth.RegistrationHandler
{
	private static final String ERROR_NO_FEDERATION_IDENTIFIER_RECEIVED = 'No Email Or UserName Attribute received.';

	class AzureB2CException extends Exception
	{
	}

	/**
	 * @description Returns a User object using the specified portal ID and user information from the third party, such as the username and email address.
	 * The User object corresponds to the third party’s user information and may be a new user that
	 * hasn’t been inserted in the database or may represent an existing user record in the database.
	 *
	 * @param portalId The portalID value may be null or an empty key if there is no portal configured with this provider.
	 * @param data
	 *
	 * @return
	 */
	global User createUser(Id portalId, Auth.UserData data)
	{
		if(String.isBlank(data.email) && String.isBlank(data.username))
		{
			throw new AzureB2CException(ERROR_NO_FEDERATION_IDENTIFIER_RECEIVED);
		}

		User foundUser;

		if(String.isNotBlank(data.email))
		{
			foundUser = CMN_DAL_User.findUserByFederationId(data.email);
		}

		if(foundUser == null && String.isNotBlank(data.username))
		{
			foundUser = CMN_DAL_User.findUserByFederationId(data.username);
		}

		return foundUser;
	}

	/**
	 * @description Updates the specified user’s information. This method is called if the user has logged in before with the authorization provider and then logs in again.
	 *
	 * @param userId
	 * @param portalId
	 * @param data
	 */
	global void updateUser(Id userId, Id portalId, Auth.UserData data)
	{
	}
}