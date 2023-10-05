/**
 * @description A post copy sandbox worker that will enable user based on settings
 *
 * @see CMN_SPC_Workers_TEST
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date August 2021, August 2022
 */
public inherited sharing class CMN_SPC_EnableUsers extends CMN_SPC_BaseWorker
{
	@TestVisible
	private static final String ERROR_NO_USERS_FOUND = 'No User Names or Profiles found to enable';

	/**
	 * @description Exception used by Post Copy Worker Factory when attempting to execute workers
	 */
	public class EnableUserException extends Exception
	{
	}

	/**
	 * @description Method update the users email and profiles from CMN_DAL_UsersToEnable list
	 */
	protected override void internalRun()
	{
		enableUsers(findUsersToEnable());
	}

	/**
	 * @description Will read the Custom setting and determine if there are any users that need to be enabled
	 *
	 * @return A list of users to enable
	 */
	private List<User> findUsersToEnable()
	{
		//get all the users or profiles that are listed in the custom setting
		List<CMN_SPC_UsersToEnable__c> usersToEnableSettings = CMN_DAL_UsersToEnable.getAll();

		if(usersToEnableSettings.isEmpty())
		{
			throw new EnableUserException(ERROR_NO_USERS_FOUND);
		}

		Set<String> userNames = CMN_UTIL_System.extractSetValues
				(
						usersToEnableSettings,
						CMN_SPC_UsersToEnable__c.CMN_SPC_EnableUsername__c.getDescribe().getLocalName()
				);
		Set<String> profileNames = CMN_UTIL_System.extractSetValues
				(
						usersToEnableSettings,
						CMN_SPC_UsersToEnable__c.CMN_SPC_EnableProfileName__c.getDescribe().getLocalName()
				);

		//Removing null values because when querying users with a profile name of null it returns automated process users
		userNames.remove(null);
		profileNames.remove(null);

		List<User> usersToEnable = new List<User>();

		if(!userNames.isEmpty())
		{
			Set<String> additionalUserNames = new Set<String>();

			//If this has been setup, make sure we append the Sandbox name assuming it isn't there already
			//This will most likely always be the case when cloning a sandbox or copying production
			for(String userName : userNames)
			{
				if(String.isNotBlank(userName) && !userName.endsWith(context.sandboxName()))
				{
					additionalUserNames.add(userName + CMN_UTIL_String.DOT + context.sandboxName());
				}
			}

			userNames.addAll(additionalUserNames);

			usersToEnable.addAll(CMN_DAL_User.findByUsername(userNames));
		}

		if(!profileNames.isEmpty())
		{
			usersToEnable.addAll(CMN_DAL_User.findByProfileName(profileNames));
		}

		return usersToEnable;
	}

	/**
	 * @description Will enable all the users in the list provided
	 *
	 * @param usersToEnable A list of users to enable
	 */
	private static void enableUsers(List<User> usersToEnable)
	{
		if(!usersToEnable.isEmpty())
		{
			List<User> userEmailsToUpdate = new List<User>();

			for(User userToEnable : usersToEnable)
			{
				//Prevent update of the running user
				if(userToEnable.Email.contains(CMN_DAL_User.INVALID_EMAIL_SUFFIX) && userToEnable.Id <> UserInfo.getUserId())
				{
					userToEnable.Email = userToEnable.Email.remove(CMN_DAL_User.INVALID_EMAIL_SUFFIX);
					userEmailsToUpdate.add(userToEnable);
				}
			}

			List<User> usersToActivate = new List<User>();

			for(User userToEnable : usersToEnable)
			{
				if(!userToEnable.IsActive)
				{
					userToEnable.IsActive = true;
					usersToActivate.add(userToEnable);
				}
			}

			//we may have duplicates, make sure we remove then
			Set<User> uniqueObjects = new Set<User>(userEmailsToUpdate);
			CMN_DAL_SObjectDomain.updateDBObjects(new List<User>(uniqueObjects));

			uniqueObjects = new Set<User>(usersToActivate);
			//NB: There maybe a scenario where there aren't enough user licenses available
			CMN_DAL_SObjectDomain.updateDBObjects(new List<User>(uniqueObjects));
		}
	}
}