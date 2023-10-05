/**
 * @description Public class to return the records of Users
 *
 * @author prashant.k.jain@accenture.com jason.van.beukering@accenture.com
 *
 * @date 2019; February 2022, June 2022
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class AW_DAL_User
{
	private static final Integer LENGTH_AT_WORK_USERID = 5;
	private static final Integer LENGTH_CONSULTANT_CODE = 13;
	private static final Integer LENGTH_UACF_ID = 7;
	private static final String FIELD_IS_RECEIVE_LEADS = User.AW_ReceiveLeads__c.getDescribe().getLocalName();
	private static final String FIELD_LEAD_ALLOCATION_DATE = User.AW_LastLeadAllocationDate__c.getDescribe().getLocalName();
	private static final String FIELD_PROFILE_NAME = 'Profile.Name';

	/**
	 * @description Name of the Consultant Code field
	 */
	public static final String FIELD_CONSULTANT_CODE = User.AW_ConsultantCode__c.getDescribe().getLocalName();
	/**
	 * @description Name of the Federation Identifier field
	 */
	public static final String FIELD_FEDERATION_IDENTIFIER = User.FederationIdentifier.getDescribe().getLocalName();
	/**
	 * @description Name of the Is Active field
	 */
	public static final String FIELD_IS_ACTIVE = User.IsActive.getDescribe().getLocalName();
	/**
	 * @description Name of the UACF Id field
	 */
	public static final String FIELD_UACF_ID = User.AW_UACFID__c.getDescribe().getLocalName();
	/**
	 * @description Name of the User object
	 */
	public static final String OBJECT_NAME = CMN_DAL_User.OBJECT_NAME;

	/**
	 * @description Will return the common fields used by all queries
	 *
	 * @return List of fields
	 */
	private static Set<String> getDefaultFields()
	{
		Set<String> defaultFields = new Set<String>
		{
				FIELD_CONSULTANT_CODE,
				FIELD_IS_RECEIVE_LEADS,
				FIELD_LEAD_ALLOCATION_DATE,
				FIELD_PROFILE_NAME,
				FIELD_UACF_ID,
				User.AW_AtWorkUsername__c.getDescribe().getLocalName(),
				User.AW_Branch__c.getDescribe().getLocalName(),
				User.AW_LastPerformanceAPIRunDate__c.getDescribe().getLocalName(),
				User.AW_NumberOfLeadAllocation__c.getDescribe().getLocalName(),
				User.AW_Region__c.getDescribe().getLocalName(),
				User.AW_Unit__c.getDescribe().getLocalName(),
				User.AW_Opt_in_out__c.getDescribe().getLocalName()
		};

		defaultFields.addAll(CMN_DAL_User.getDefaultFields());

		return defaultFields;
	}

	/**
	 * @description This method is use to get the list of User
	 *
	 * @param userIds Set of User Ids
	 *
	 * @return List of User
	 */
	public static List<User> findById(Set<Id> userIds)
	{
		return CMN_DAL_SObjectSelector.findById(User.SObjectType, userIds, getDefaultFields());
	}

	/**
	 * @description This method is use to get the User
	 *
	 * @param userId The Id of the user
	 *
	 * @return Null or Item
	 */
	public static User findById(Id userId)
	{
		return (User)CMN_DAL_SObjectSelector.findById(User.SObjectType, userId, getDefaultFields());
	}

	/**
	 * @description This method is use to get the list of User with accounts
	 *
	 * @param accountIds Set of Account Ids
	 *
	 * @return List of User
	 */
	public static List<User> findByAccountId(Set<Id> accountIds)
	{
		return CMN_DAL_SObjectSelector.findById(CMN_DAL_User.OBJECT_NAME, CMN_DAL_User.FIELD_ACCOUNT_ID, accountIds, getDefaultFields());
	}

	/**
	 * @description This method is use to get the User with accounts
	 *
	 * @param accountId Id of Account
	 *
	 * @return community user
	 */
	public static User findByAccountId(Id accountId)
	{
		List<User> communityUsers = findByAccountId(new Set<Id> {accountId});
		return communityUsers.isEmpty() ? null : communityUsers[0];
	}

	/**
	 * @description This method is use to get the record of current User
	 *
	 * @return List of User
	 */
	public static User getCurrentUser()
	{
		return (User)findById(UserInfo.getUserId());
	}

	/**
	 * @description This method is use to get the list of adviser available for lead assignment
	 *
	 * @param userIds A list of user ids
	 *
	 * @return list of found items sorted by allocation date
	 */
	public static List<User> findAdvisersAvailableForLeadAssignment(Set<Id> userIds)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_User.OBJECT_NAME, getDefaultFields());

		searchParameters.searchConditions.inX(CMN_DAL_SObjectDomain.FIELD_ID, CMN_UTIL_System.setToList(userIds));
		searchParameters.searchConditions.equalsX(FIELD_PROFILE_NAME, AW_DAL_Profile.PROFILE_ADVISER);
		searchParameters.searchConditions.equalsX(FIELD_IS_ACTIVE, true);
		searchParameters.searchConditions.equalsX(FIELD_IS_RECEIVE_LEADS, true);
		searchParameters.addOrderByField(FIELD_LEAD_ALLOCATION_DATE);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Will generate a query the most recently created active user for a particular user; user must have a role
	 *
	 * @param profileName The profile of the user
	 *
	 * @return Query string
	 */
	private static CMN_DAL_Search.SOQLSearchParameters generateFindActiveUserParameters(String profileName)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_User.OBJECT_NAME, getDefaultFields());

		searchParameters.searchConditions.equalsX(FIELD_PROFILE_NAME, profileName);
		searchParameters.searchConditions.equalsX(FIELD_IS_ACTIVE, true);
		searchParameters.searchConditions.notEquals(CMN_DAL_User.FIELD_USER_ROLE, null);
		searchParameters.addOrderByField(CMN_DAL_SObjectDomain.FIELD_CREATED_DATE, true);

		return searchParameters;
	}

	/**
	 * @description Will retrieve the most recently created active user for a particular user; user must have a role
	 *
	 * @param profileName The profile of the user
	 *
	 * @return Either Null or a User
	 */
	@TestVisible
	private static User findActiveUser(String profileName)
	{
		List<User> activeUsers = CMN_DAL_Search.getObjects(generateFindActiveUserParameters(profileName));
		System.assertNotEquals(true, activeUsers.isEmpty(), 'No Active User found for Profile: ' + profileName);

		return activeUsers.iterator().next();
	}

	@TestVisible
	private static User findActiveAdministrator()
	{
		return findActiveUser(AW_DAL_Profile.PROFILE_LIBERTY_ADMIN);
	}

	/**
	 * @description This method is use to get an active PA
	 *
	 * @return Active Personal Assistant user record
	 */
	@TestVisible
	private static User findActivePersonalAssistant()
	{
		return findActiveUser(AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT);
	}

	/**
	 * @description This method is use to get the active user who has the Liberty Support Profile
	 *
	 * @return List of Users
	 */
	@TestVisible
	private static User findActiveLibertySupportUser()
	{
		return findActiveUser(AW_DAL_Profile.PROFILE_LIBERTY_SUPPORT);
	}

	/**
	 * @description This method is used to get one random adviser
	 *
	 * @return Random active adviser
	 */
	@TestVisible
	private static User findRandomActiveAdviser()
	{
		return findRandomActiveAdvisers(1).iterator().next();
	}

	/**
	 * @description This method is used to get random advisers
	 *
	 * @param numberOfAdvisersToFind Number of advisers to find
	 *
	 * @return List of random active adviser
	 */
	@TestVisible
	private static List<User> findRandomActiveAdvisers(Integer numberOfAdvisersToFind)
	{
		System.assert(numberOfAdvisersToFind > 0, 'Incorrect number of Active Advisers requested: ' + numberOfAdvisersToFind);

		CMN_DAL_Search.SOQLSearchParameters searchParameters = generateFindActiveUserParameters(AW_DAL_Profile.PROFILE_ADVISER);

		searchParameters.searchConditions.notEquals(FIELD_UACF_ID, null);
		searchParameters.searchConditions.notEquals(FIELD_CONSULTANT_CODE, null);
		searchParameters.searchConditions.notEquals(FIELD_FEDERATION_IDENTIFIER, null);

		List<User> advisers = CMN_DAL_Search.getRandomItems(searchParameters, numberOfAdvisersToFind);

		System.assertNotEquals(null, advisers, 'No Active Advisers found');
		System.assertEquals(numberOfAdvisersToFind, advisers.size(), 'Correct number of Active Advisers not found');

		return advisers;
	}

	/**
	 * @description This method is use to get the List of adviser
	 *
	 * @param userIds Set of User Ids
	 *
	 * @return List of User
	 */
	@TestVisible
	private static List<User> findAdviserById(Set<Id> userIds)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_User.OBJECT_NAME, getDefaultFields());

		searchParameters.searchConditions.inX(CMN_DAL_SObjectDomain.FIELD_ID, CMN_UTIL_System.setToList(userIds));
		searchParameters.searchConditions.equalsX(FIELD_PROFILE_NAME, AW_DAL_Profile.PROFILE_ADVISER);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method is use to get the adviser
	 *
	 * @param userId Id of User
	 *
	 * @return List of User
	 */
	@TestVisible
	private static User findAdviserById(Id userId)
	{
		List<User> foundUsers = findAdviserById(new Set<Id> {userId});
		return foundUsers.isEmpty() ? null : foundUsers.iterator().next();
	}

	/**
	 * @description This method is use to get the adviser with account
	 *
	 * @param accountId Id of Account
	 *
	 * @return List of User
	 */
	public static User findAdviserByAccountId(Id accountId)
	{
		User adviserUser;

		Account adviserAccount = AW_DAL_Account.findById(accountId);

		if(adviserAccount != null)
		{
			adviserUser = AW_DAL_User.findAdviserById(adviserAccount.OwnerId);
		}

		return adviserUser;
	}

	/**
	 * @description This method is use to generate UACF Id
	 *
	 * @return string
	 */
	public static String generateRandomUACFId()
	{
		return CMN_UTIL_String.generateRandomString(LENGTH_UACF_ID);
	}

	/**
	 * @description This method is use to generate consultant code
	 *
	 * @return string
	 */
	public static String generateRandomConsultantCode()
	{
		return CMN_UTIL_String.generateRandomString(LENGTH_CONSULTANT_CODE);
	}

	/**
	 * @description This method is use to generate length
	 *
	 * @return string
	 */
	@TestVisible
	private static String generateRandomAtWorkUserId()
	{
		return CMN_UTIL_String.generateRandomString(LENGTH_AT_WORK_USERID);
	}

	/**
	 * @description This method is use to get the user with profile
	 *
	 * @param profileName Name of profile to create
	 *
	 * @return User
	 */
	public static User newUser(String profileName)
	{
		User newUser = new User();

		newUser.ProfileId = CMN_DAL_Profile.findByName(profileName).Id;

		newUser.Username = CMN_DAL_SObjectDomain.generateRandomEmail();
		newUser.Email = newUser.Username.toLowerCase();
		newUser.LastName = CMN_DAL_SObjectDomain.generateRandomName();
		newUser.FirstName = CMN_DAL_SObjectDomain.generateRandomName();
		newUser.Alias = CMN_UTIL_String.generateRandomString(LENGTH_UACF_ID);
		newUser.CommunityNickname = CMN_DAL_SObjectDomain.generateRandomName();

		newUser.AW_UACFID__c = AW_DAL_User.generateRandomUACFId();
		newUser.AW_ConsultantCode__c = AW_DAL_User.generateRandomConsultantCode();
		newUser.FederationIdentifier = CMN_DAL_SObjectDomain.generateRandomEmail();

		User currentUser = AW_DAL_User.getCurrentUser();

		newUser.TimeZoneSidKey = currentUser.TimeZoneSidKey;
		newUser.LocaleSidKey = currentUser.LocaleSidKey;
		newUser.EmailEncodingKey = currentUser.EmailEncodingKey;
		newUser.LanguageLocaleKey = currentUser.LanguageLocaleKey;

		newUser.MobilePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();

		newUser.IsActive = true;
		newUser.AW_ReceiveLeads__c = true;

		return newUser;
	}

	/**
	 * @description This method is use to get the community user from account
	 *
	 * @param communityUserAccount get the community user
	 *
	 * @return User
	 */
	public static User newCommunityUser(Account communityUserAccount)
	{
		User newUser = newUser(AW_DAL_Profile.PROFILE_CLIENT);

		newUser.ContactId = communityUserAccount.PersonContactId;

		return newUser;
	}

	/**
	 * @description This method is use to get the List of user with consultantCodes
	 *
	 * @param consultantCodes Consultant codes to use
	 *
	 * @return List of Users
	 */
	public static List<User> findByConsultantCode(Set<String> consultantCodes)
	{
		return CMN_DAL_SObjectSelector.findByField(CMN_DAL_User.OBJECT_NAME, FIELD_CONSULTANT_CODE, consultantCodes, getDefaultFields());
	}

	/**
	 * @description This method is use to the user with account
	 *
	 * @param accountId Id of Account
	 *
	 * @return List<User>
	 */
	@TestVisible
	private static User findCommunityUser(Id accountId)
	{
		List<User> communityUsers = CMN_DAL_User.findByAccountId(new Set<Id> {accountId});
		System.assertNotEquals(true, communityUsers.isEmpty(), 'No Community Users Retrieved');
		return communityUsers.iterator().next();
	}

	/**
	 * @description This method is use to get a community user based on user name
	 *
	 * @param communityUserName the user's name
	 *
	 * @return null or found user
	 */
	public static User findCommunityUserOwner(String communityUserName)
	{
		User communityUser = findCommunityUseByUserName(communityUserName);
		return communityUser == null ? communityUser : AW_DAL_User.findAdviserByAccountId(communityUser.AccountId);
	}

	/**
	 * @description This method is use to get the list of User with specific user name
	 *
	 * @param communityUserName Name of the user
	 *
	 * @return List of items
	 */
	public static User findCommunityUseByUserName(String communityUserName)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(
				CMN_DAL_User.OBJECT_NAME,
				CMN_DAL_User.FIELD_USER_NAME,
				new Set<String> {communityUserName},
				getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(CMN_DAL_User.FIELD_ACCOUNT_ID, CMN_SOQL_Query.Operator.NOT_EQUALS, null));

		searchParameters.searchConditions.add(andCondition);

		List<User> foundUsers = CMN_DAL_Search.getObjects(searchParameters);

		return foundUsers.isEmpty() ? null : foundUsers.iterator().next();
	}

	/**
	 * @description This method is use to get the users with UACF Ids
	 *
	 * @param uacfIds A list of Ids
	 *
	 * @return List of Users
	 */
	public static List<User> findByUACFIds(Set<String> uacfIds)
	{
		Set<String> trimmedUacfIds = CMN_UTIL_System.trimSet(uacfIds);

		if(trimmedUacfIds.isEmpty())
		{
			return new List<User>();
		}

		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_UACF_ID, trimmedUacfIds, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_IS_ACTIVE, CMN_SOQL_Query.Operator.EQUALS, true));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(CMN_DAL_User.FIELD_USER_TYPE, CMN_SOQL_Query.Operator.EQUALS, CMN_DAL_User.PICK_USER_TYPE_STANDARD));
		searchParameters.searchConditions.add(andCondition);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method is use to get the active users with profile name
	 *
	 * @param profileName Name of profile to search by
	 *
	 * @return List of Users
	 */
	public static List<User> findActiveByProfileName(String profileName)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_PROFILE_NAME, new Set<String> {profileName}, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_IS_ACTIVE, CMN_SOQL_Query.Operator.EQUALS, true));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(CMN_DAL_User.FIELD_USER_ROLE, CMN_SOQL_Query.Operator.NOT_EQUALS, null));
		searchParameters.searchConditions.add(andCondition);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Method to fetch an Active Personal Assistant and update it's role to be above the provided adviser
	 *
	 * @param adviserId Id of the Adviser
	 *
	 * @return Active Personal Assistant user with Role above Adviser
	 *
	 * @author prashant.k.jain@accenture.com
	 */
	@TestVisible
	private static User findActivePersonalAssistantByAdviser(Id adviserId)
	{
		User adviser = AW_DAL_User.findById(adviserId);
		UserRole adviserRole = AW_DAL_Role.findById(adviser.UserRoleId);

		//This will make sure that the Adviser does not have a top level role and does has a parent.
		System.assert(String.isNotBlank(adviserRole.ParentRoleId), 'Parent Role not found for Adviser Id: ' + adviserId); 

		//This update ensures PA is above Adviser in role hierarchy
		User personalAssistant = AW_DAL_User.findActivePersonalAssistant();
		personalAssistant.UserRoleId = adviserRole.ParentRoleId;

		//Make sure that Personal Assistant's UACF Id and Consultant Code is not blank	
		personalAssistant.AW_UACFID__c = String.isBlank(personalAssistant.AW_UACFID__c) ? AW_DAL_User.generateRandomUACFId() : personalAssistant.AW_UACFID__c;	
		personalAssistant.AW_ConsultantCode__c =	
				String.isBlank(personalAssistant.AW_ConsultantCode__c) ? AW_DAL_User.generateRandomConsultantCode() : personalAssistant.AW_ConsultantCode__c;

		update personalAssistant; //NOPMD

		return personalAssistant;
	}
}