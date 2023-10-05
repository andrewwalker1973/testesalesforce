/**
 * @description Public class to return the records of Users
 *
 * @author mthobisi.ndlovu@accenture.com, uttpal.chandra@accenture.com
 *
 * @date July 2021, March 2023
 */
public inherited sharing class SC_DAL_User
{
	private static final String FIELD_IS_ACTIVE = User.IsActive.getDescribe().getLocalName();
	private static final String FIELD_PROFILE_NAME = 'Profile.Name';
	private static final String FIELD_UACF_ID = User.AW_UACFID__c.getDescribe().getLocalName();
	private static final String FIELD_USER_ROLE = User.UserRoleId.getDescribe().getLocalName();
	private static final String OBJECT_NAME = User.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method use to get the set of fields of SObject
	 *
	 * @return A list of commonly queried User fields
	 */
	private static Set<String> getDefaultFields()
	{
		Set<String> defaultFields = new Set<String>
		{
				FIELD_UACF_ID
		};

		defaultFields.addAll(CMN_DAL_User.getDefaultFields());

		return defaultFields;
	}

	/**
	 * @description This method is use to get the list of User
	 *
	 * @param userIds set of User Id's
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
	 * @param userId The user Id
	 *
	 * @return found item or null
	 */
	public static User findById(Id userId)
	{
		return (User)CMN_DAL_SObjectSelector.findById(User.SObjectType, userId, getDefaultFields());
	}

	/**
	 * @description Will retrieve an random Users with given profile that's active, and retrieves requested fields
	 *
	 * @return random item or null
	 */
	public static User findRandomActiveAgent()
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());

		searchParameters.searchConditions.equalsX(FIELD_PROFILE_NAME, SC_DAL_Profile.PROFILE_SERVICE_AGENT);
		searchParameters.searchConditions.equalsX(FIELD_IS_ACTIVE, true);
		searchParameters.searchConditions.notEquals(FIELD_UACF_ID, null);
		searchParameters.searchConditions.notEquals(FIELD_USER_ROLE, null);

		return (User)CMN_DAL_Search.getRandomItem(searchParameters);
	}

	/**
	 * @description This method is used to generate a Map of UACF ID to existing agent records
	 *
	 * @param uacfIds A set of UACF Ids
	 *
	 * @return Agent User Map - mapped by UACF Id  to User record
	 */
	public static Map<String, User> getAgentMapByUacfId(Set<String> uacfIds)
	{
		List<User> agents = AW_DAL_User.findByUACFIds(uacfIds);
		Map<String, User> uacfIdToAgent = new Map<String, User>();
		for(User agent : agents)
		{
			uacfIdToAgent.put(agent.AW_UACFID__c, agent);
		}
		return uacfIdToAgent;
	}

	/**
	 * @description Will retrieve an Active Knowledge Administrator
	 *
	 * @return Active Retail Knowledge Administrator User or null
	 */
	public static User findActiveKnowledgeAdministrator()
	{
		return CMN_DAL_User.findRandomActiveByProfileName(SC_DAL_Profile.PROFILE_RETAIL_KNOWLEDGE_ADMINISTRATOR, getDefaultFields());
	}
}