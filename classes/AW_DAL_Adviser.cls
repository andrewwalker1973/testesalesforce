/**
 * @description Class used to createAdvisersPerBranch
 *
 * @see AW_BATCH_AccountReallocation
 * @see AW_DAL_LeadAssignment
 *
 * @author Ashwini Gulbhile
 *
 * @date October 2020
 */
public inherited sharing class AW_DAL_Adviser
{
	/**
	 * @description This method is used to return Map of Advisers within the same branch.
	 *
	 * @param accountTeamMembers to store list of account team members
	 * @param advisersAvailableForLeadAssignment To store map of advisers available for account reallocation
	 *
	 * @return map contains list users
	 *
	 * @author kiran.kumaryelisetti@lntinfotech.com
	 */
	public static Map<Id, List<User>> createAdvisersPerBranch(List<AccountTeamMember> accountTeamMembers, Map<Id, User> advisersAvailableForLeadAssignment)
	{
		Map<Id, List<User>> advisersPerBranch = new Map<Id, List<User>>();
		List<User> branchAdvisers;

		for(AccountTeamMember teamMember : accountTeamMembers)
		{
			//Get the details of the adviser
			User adviser = advisersAvailableForLeadAssignment.get(teamMember.UserId);

			//Adviser may not exist in the map as they  are marked as not being available for receiving leads.
			if(adviser != null)
			{
				branchAdvisers = advisersPerBranch.get(teamMember.AccountId);

				if(branchAdvisers == null)
				{
					branchAdvisers = new List<User>();
					advisersPerBranch.put(teamMember.AccountId, branchAdvisers);
				}

				branchAdvisers.add(adviser);
			}
		}

		return advisersPerBranch;
	}

	/**
	 * @description Method to get Advisers by Branch
	 *
	 * @param accountIds Set of Account Ids
	 *
	 * @return advisersByBranch Advisers by Branch map
	 *
	 * @author kiran.kumaryelisetti@lntinfotech.com
	 */
	public static Map<Id, List<User>> getAdvisersByBranchId(Set<Id> accountIds)
	{
		List<AccountTeamMember> accountTeamMembers;
		Map<Id, User> advisersAvailableForLeadAssignment;
		Set<Id> adviserIds;
		Map<Id, List<User>> advisersByAccountId;

		accountTeamMembers = AW_DAL_AccountTeamMember.findAdvisersSortedByAllocationDate(accountIds);

		if(accountTeamMembers?.size() > 0)
		{
			adviserIds = CMN_UTIL_System.extractListIds(accountTeamMembers, AW_DAL_AccountTeamMember.FIELD_USER_ID);
		}
		if(adviserIds?.size() > 0)
		{
			//only retrieve users that are available for lead assignment
			advisersAvailableForLeadAssignment = new Map<Id, User>(AW_DAL_User.findAdvisersAvailableForLeadAssignment(adviserIds));
		}
		if(advisersAvailableForLeadAssignment?.size() > 0)
		{
			advisersByAccountId = createAdvisersPerBranch(accountTeamMembers, advisersAvailableForLeadAssignment);
		}

		return advisersByAccountId;
	}
}