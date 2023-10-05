/**
 * @description Provides Query methods related to User object.
 *
 * @see CMN_DAL_User_TEST
 * @see User
 *
 * @author latika.kharbanda@accenture.com, jason.van.beukering@accenture.com
 *
 * @date 2019, June 2023
 */
public inherited sharing class CMN_DAL_User
{
	@TestVisible
	private static final String FIELD_SET_PERSONAL_INFO = 'PersonalInfo_EPIM';
	private static final String SITE_USER_TYPE = 'Guest';
	/**
	 * @description The reference to use to get the profiles name
	 */
	public static final String FIELD_PROFILE_NAME = 'Profile.Name';
	/**
	 * @description Stores the Account Id
	 */
	public static final String FIELD_ACCOUNT_ID = User.AccountId.getDescribe().getLocalName();
	/**
	 * @description Api name for the IsActive field
	 */
	public static final String FIELD_IS_ACTIVE = User.IsActive.getDescribe().getLocalName();
	/**
	 * @description Api name for the Username field
	 */
	public static final String FIELD_USER_NAME = User.Username.getDescribe().getLocalName();
	/**
	 * @description Api name for the Role field
	 */
	public static final String FIELD_USER_ROLE = User.UserRoleId.getDescribe().getLocalName();
	/**
	 * @description Stores the User Type
	 */
	public static final String FIELD_USER_TYPE = User.UserType.getDescribe().getLocalName();
	/**
	 * @description Prefix to use when composing an example email
	 */
	public static final String INVALID_EMAIL_SUFFIX = '.invalid';
	/**
	 * @description The API name of the object
	 */
	public static final String OBJECT_NAME = User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
	/**
	 * @description Stores the Standard User Type
	 */
	public static final String PICK_USER_TYPE_STANDARD = 'Standard';

	/**
	 * @description Method use to get the set of fields of SObject
	 *
	 * @return A list of commonly queried User fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_ACCOUNT_ID,
				FIELD_PROFILE_NAME,
				FIELD_USER_NAME,
				FIELD_USER_ROLE,
				User.AboutMe.getDescribe().getLocalName(),
				User.Address.getDescribe().getLocalName(),
				User.Alias.getDescribe().getLocalName(),
				User.BadgeText.getDescribe().getLocalName(),
				User.BannerPhotoUrl.getDescribe().getLocalName(),
				User.CallCenterId.getDescribe().getLocalName(),
				User.City.getDescribe().getLocalName(),
				User.CommunityNickname.getDescribe().getLocalName(),
				User.CompanyName.getDescribe().getLocalName(),
				User.ContactId.getDescribe().getLocalName(),
				User.Country.getDescribe().getLocalName(),
				User.CreatedById.getDescribe().getLocalName(),
				User.CreatedDate.getDescribe().getLocalName(),
				User.DefaultGroupNotificationFrequency.getDescribe().getLocalName(),
				User.DelegatedApproverId.getDescribe().getLocalName(),
				User.Department.getDescribe().getLocalName(),
				User.DigestFrequency.getDescribe().getLocalName(),
				User.Division.getDescribe().getLocalName(),
				User.Email.getDescribe().getLocalName(),
				User.EmailEncodingKey.getDescribe().getLocalName(),
				User.EmailPreferencesAutoBcc.getDescribe().getLocalName(),
				User.EmailPreferencesAutoBccStayInTouch.getDescribe().getLocalName(),
				User.EmailPreferencesStayInTouchReminder.getDescribe().getLocalName(),
				User.EmployeeNumber.getDescribe().getLocalName(),
				User.Extension.getDescribe().getLocalName(),
				User.Fax.getDescribe().getLocalName(),
				User.FederationIdentifier.getDescribe().getLocalName(),
				User.FinServ__ReferrerScore__c.getDescribe().getLocalName(),
				User.FirstName.getDescribe().getLocalName(),
				User.ForecastEnabled.getDescribe().getLocalName(),
				User.FullPhotoUrl.getDescribe().getLocalName(),
				User.GeocodeAccuracy.getDescribe().getLocalName(),
				User.IndividualId.getDescribe().getLocalName(),
				User.IsActive.getDescribe().getLocalName(),
				User.IsExtIndicatorVisible.getDescribe().getLocalName(),
				User.IsPortalEnabled.getDescribe().getLocalName(),
				User.IsProfilePhotoActive.getDescribe().getLocalName(),
				User.LanguageLocaleKey.getDescribe().getLocalName(),
				User.LastLoginDate.getDescribe().getLocalName(),
				User.LastModifiedById.getDescribe().getLocalName(),
				User.LastModifiedDate.getDescribe().getLocalName(),
				User.LastName.getDescribe().getLocalName(),
				User.LastReferencedDate.getDescribe().getLocalName(),
				User.LastViewedDate.getDescribe().getLocalName(),
				User.Latitude.getDescribe().getLocalName(),
				User.LocaleSidKey.getDescribe().getLocalName(),
				User.Longitude.getDescribe().getLocalName(),
				User.ManagerId.getDescribe().getLocalName(),
				User.MediumBannerPhotoUrl.getDescribe().getLocalName(),
				User.MediumPhotoUrl.getDescribe().getLocalName(),
				User.MiddleName.getDescribe().getLocalName(),
				User.MobilePhone.getDescribe().getLocalName(),
				User.Name.getDescribe().getLocalName(),
				User.OfflinePdaTrialExpirationDate.getDescribe().getLocalName(),
				User.OfflineTrialExpirationDate.getDescribe().getLocalName(),
				User.OutOfOfficeMessage.getDescribe().getLocalName(),
				User.Phone.getDescribe().getLocalName(),
				User.PortalRole.getDescribe().getLocalName(),
				User.PostalCode.getDescribe().getLocalName(),
				User.ProfileId.getDescribe().getLocalName(),
				User.ReceivesAdminInfoEmails.getDescribe().getLocalName(),
				User.ReceivesInfoEmails.getDescribe().getLocalName(),
				User.SenderEmail.getDescribe().getLocalName(),
				User.SenderName.getDescribe().getLocalName(),
				User.Signature.getDescribe().getLocalName(),
				User.SmallBannerPhotoUrl.getDescribe().getLocalName(),
				User.SmallPhotoUrl.getDescribe().getLocalName(),
				User.State.getDescribe().getLocalName(),
				User.StayInTouchNote.getDescribe().getLocalName(),
				User.StayInTouchSignature.getDescribe().getLocalName(),
				User.StayInTouchSubject.getDescribe().getLocalName(),
				User.Street.getDescribe().getLocalName(),
				User.SystemModstamp.getDescribe().getLocalName(),
				User.TimeZoneSidKey.getDescribe().getLocalName(),
				User.Title.getDescribe().getLocalName(),
				User.UserType.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Method to return a list of users by Id
	 *
	 * @param userIds The userIds to be used when filtering the user list
	 *
	 * @return List of Users
	 */
	public static List<User> findById(Set<Id> userIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, userIds, getDefaultFields());
	}

	/**
	 * @description Method to return User based on Id
	 *
	 * @param userId The Id to be used when finding the user
	 *
	 * @return Single User
	 */
	public static User findByUserId(Id userId)
	{
		List<User> foundUsers = findById(new Set<Id> {userId});
		return foundUsers.isEmpty() ? null : foundUsers.iterator().next();
	}

	/**
	 * @description Will get the details for the currently logged in user
	 *
	 * @return A fully populated User object
	 */
	public static User getCurrentUser()
	{
		return CMN_DAL_User.findByUserId(UserInfo.getUserId());
	}

	/**
	 * @description Will generate the search parameters for retrieving active users
	 *
	 * @param selectFields The fields to return for the user object
	 *
	 * @return Initialised search parameters
	 */
	private static CMN_DAL_Search.SOQLSearchParameters initialiseParametersForActiveUsers(Set<String> selectFields)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_User.OBJECT_NAME, selectFields);

		searchParameters.searchConditions.equalsX(FIELD_IS_ACTIVE, true);

		return searchParameters;
	}

	/**
	 * @description Will a list of users that are active, will use a default set of fields to retrieve
	 *
	 * @param profileName The profile name that user should have
	 * @param selectFields The fields to return for the user object
	 * @param randomResults Will return a random active user for the given profile if set to true
	 *
	 * @return User object
	 */
	public static List<User> findActiveByProfileName(String profileName, Set<String> selectFields, Boolean randomResults)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = initialiseParametersForActiveUsers(selectFields);

		searchParameters.searchConditions.equalsX(FIELD_PROFILE_NAME, profileName);
		searchParameters.randomResults = randomResults;

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Will retrieve an random user that's active, will use a default set of fields to retrieve
	 *
	 * @param profileName The profile name that user should have
	 *
	 * @return User object
	 */
	public static User findRandomActiveByProfileName(String profileName)
	{
		return findRandomActiveByProfileName(profileName, getDefaultFields());
	}

	/**
	 * @description Will retrieve an random user that's active, will retrieve fields requested
	 *
	 * @param profileName The profile name that user should have
	 * @param selectFields The fields to return for the user object
	 *
	 * @return User object
	 */
	public static User findRandomActiveByProfileName(String profileName, Set<String> selectFields)
	{
		List<User> users = findActiveByProfileName(profileName, selectFields, true);
		return users.isEmpty() ? null : users.iterator().next();
	}

	/**
	 * @description This method is use to get the List of users by username
	 *
	 * @param userNames The usernames to search against
	 *
	 * @return List of User
	 */
	public static List<User> findByUsername(Set<String> userNames)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_USER_NAME, userNames, getDefaultFields());
	}

	/**
	 * @description This method is use to get the List of users by profile name
	 *
	 * @param profileNames A list of profile names
	 *
	 * @return Found users for the given profiles
	 */
	public static List<User> findByProfileName(Set<String> profileNames)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_PROFILE_NAME, profileNames, getDefaultFields());
	}

	/**
	 * @description Checks if current user is admin
	 *
	 * @return Boolean is admin or not
	 */
	public static Boolean isCurrentUserSystemAdmin()
	{
		Profile foundProfile = CMN_DAL_Profile.findByName(CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN);
		return foundProfile.Id == UserInfo.getProfileId();
	}

	/**
	 * @description Method to return the user federation Id
	 *
	 * @param federationId as input
	 *
	 * @return user if found
	 */
	public static User findUserByFederationId(String federationId)
	{
		return findByField(User.FederationIdentifier, federationId, false);
	}

	/**
	 * @description Method to return the list of user of account
	 *
	 * @param accountIds Set of Account Ids
	 *
	 * @return Found Users
	 */
	public static List<User> findByAccountId(Set<Id> accountIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_ACCOUNT_ID, accountIds, getDefaultFields());
	}

	/**
	 * @description Method to return the user
	 *
	 * @param userField as input
	 * @param fieldValue as input
	 * @param mustBeUnique as input
	 *
	 * @return User if found
	 */
	private static User findByField(SObjectField userField, String fieldValue, Boolean mustBeUnique)
	{
		return (User)CMN_DAL_SObjectSelector.findByField(User.SObjectType, userField, fieldValue, getDefaultFields(), mustBeUnique);
	}

	/**
	 * @description Will retrieve the specified number of users
	 *
	 * @param numberOfUsers The number of users to be queried
	 *
	 * @return List of Users
	 */
	public static List<User> findActiveUsers(Integer numberOfUsers)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = initialiseParametersForActiveUsers(getDefaultFields());
		searchParameters.pageSize = numberOfUsers;
		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Determines if the current running user is a Site Guest User
	 *
	 * @return True if user is a site user
	 */
	public static Boolean isCurrentUserGuest()
	{
		return SITE_USER_TYPE.equals(UserInfo.getUserType());
	}
}