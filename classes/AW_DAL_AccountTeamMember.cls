/**
 * @description Public class to return the name of Member from Account
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_DAL_AccountTeamMember
{
	private static final String FIELD_ACCOUNT_ID = AccountTeamMember.AccountId.getDescribe().getLocalName();
	private static final String FIELD_LAST_ALLOCATION_DATE = 'User.AW_LastLeadAllocationDate__c';
	private static final String FIELD_ROLE = AccountTeamMember.TeamMemberRole.getDescribe().getLocalName();
	private static final String OBJECT_NAME = AccountTeamMember.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_USER_ID = AccountTeamMember.UserId.getDescribe().getLocalName();
	public static final String ROLE_ADVISER = 'AW_Adviser';

	/**
	 * @description Method to define the fields to retrieve Account Team Members
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				AccountTeamMember.AccountAccessLevel.getDescribe().getLocalName(),
				AccountTeamMember.CaseAccessLevel.getDescribe().getLocalName(),
				AccountTeamMember.ContactAccessLevel.getDescribe().getLocalName(),
				AccountTeamMember.Id.getDescribe().getLocalName(),
				AccountTeamMember.OpportunityAccessLevel.getDescribe().getLocalName(),
				AccountTeamMember.PhotoUrl.getDescribe().getLocalName(),
				AccountTeamMember.Title.getDescribe().getLocalName(),
				AccountTeamMember.UserId.getDescribe().getLocalName(),
				FIELD_ACCOUNT_ID,
				FIELD_LAST_ALLOCATION_DATE,
				FIELD_ROLE,
				FIELD_USER_ID
		};
	}

	/**
	 * @description This method is use to get the list of Account team member based on account Id
	 *
	 * @param accountIds list of account ids
	 *
	 * @return List of Items
	 */
	public static List<AccountTeamMember> findAdvisersSortedByAllocationDate(Set<Id> accountIds)
	{
		Set<String> accountIdStrings = new Set<String>();

		for(Id accountId : accountIds)
		{
			accountIdStrings.add(String.valueOf(accountId));
		}

		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_ACCOUNT_ID, accountIdStrings, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_ROLE, CMN_SOQL_Query.Operator.EQUALS, ROLE_ADVISER));

		searchParameters.addSearchCondition(andCondition);

		searchParameters.addOrderByField(FIELD_LAST_ALLOCATION_DATE);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method is use to get the list of All Account team member
	 *
	 * @return List of AccountTeamMember
	 */
	@TestVisible
	private static List<AccountTeamMember> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description This method is use to get the list of Account team member of adviser
	 *
	 * @param userId team member user
	 *
	 * @return Null or Item
	 */
	public static AccountTeamMember findByAdviserRoleAndUserId(Id userId)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_ACCOUNT_ID, new Set<String> {String.valueOf(userId)}, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_ROLE, CMN_SOQL_Query.Operator.EQUALS, ROLE_ADVISER));

		searchParameters.addSearchCondition(andCondition);

		List<AccountTeamMember> members = CMN_DAL_Search.getObjects(searchParameters);

		return members.isEmpty() ? null : members.iterator().next();
	}
}