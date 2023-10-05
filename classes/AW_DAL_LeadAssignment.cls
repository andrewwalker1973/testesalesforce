/**
 * @description Public class to return the user based on the leads assigned.
 *
 * @see AW_BATCH_LeadAssignment
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_DAL_LeadAssignment
{
	/**
	 * @description Method to get the list of User which not have assigned leads
	 *
	 * @param unAssignedLeads
	 *
	 * @return List<User>
	 */
	public static List<User> assignAdviser(List<Lead> unAssignedLeads)
	{
		Map<Id, List<User>> advisersPerBranch = prepareData(unAssignedLeads);
		List<User> usersToUpdate = matchLeadWithAdviser(unAssignedLeads, advisersPerBranch);
		return usersToUpdate;
	}

	/**
	 * @description Will combine all the objects in all the maps list into a single object list
	 *
	 * @param unAssignedLeads
	 *
	 * @return
	 */
	public static Map<Id, List<User>> prepareData(List<Lead> unAssignedLeads)
	{
		Set<Id> branchIds = CMN_UTIL_System.extractListIds(unAssignedLeads, AW_DAL_Lead.FIELD_LEAD_BRANCH, true);
		List<AccountTeamMember> accountTeamMembers;
		Set<Id> adviserIds;
		List<User> availableAdvisers;
		Map<Id, User> advisersAvailableForLeadAssignment;
		Map<Id, List<User>> advisersPerBranch;

		//NB: For the users to be in the right order for allocation we sort by allocation date, without this allocation will be done incorrectly
		if(branchIds?.size() > 0)
		{
			accountTeamMembers = AW_DAL_AccountTeamMember.findAdvisersSortedByAllocationDate(branchIds);
		}
		if(accountTeamMembers?.size() > 0)
		{
			adviserIds = CMN_UTIL_System.extractListIds(accountTeamMembers, AW_DAL_AccountTeamMember.FIELD_USER_ID);
		}
		//only retrieve users that are available for lead assignment
		if(adviserIds?.size() > 0)
		{
			availableAdvisers = AW_DAL_User.findAdvisersAvailableForLeadAssignment(adviserIds);
		}
		if(availableAdvisers?.size() > 0)
		{
			advisersAvailableForLeadAssignment = new Map<Id, User>(availableAdvisers);
		}
		if(advisersAvailableForLeadAssignment?.size() > 0)
		{
			advisersPerBranch = AW_DAL_Adviser.createAdvisersPerBranch(accountTeamMembers, advisersAvailableForLeadAssignment);
		}
		return advisersPerBranch;
	}

	/**
	 * @description This method is use to get the list of adviser which can match with leads
	 *
	 * @param unAssignedLeads To get the list of unAssigned Leads
	 * @param advisersPerBranch Map to store the branch of the lead adviser
	 *
	 * @return
	 */
	private static List<User> matchLeadWithAdviser(List<Lead> unAssignedLeads, Map<Id, List<User>> advisersPerBranch)
	{
		List<Lead> leadsToUpdate = new List<Lead>();
		Map<Id, User> advisersToUpdate = new Map<Id, User>();

		Group unallocatedQueue = AW_DAL_Group.getUnallocatedQueue();

		for(Lead unassignedLead : unAssignedLeads)
		{
			List<User> branchAdvisers = new List<User>();

			branchAdvisers = advisersPerBranch.get(unassignedLead.AW_LeadBranch__c);

			if(branchAdvisers != null)
			{
				//Allocate lead to first adviser
				User adviserToUpdate = branchAdvisers[0];

				//Check to see if we have previously updated this adviser, if so make sure we use previous record
				User previouslyUpdatedAdviser = advisersToUpdate.get(adviserToUpdate.Id);

				if(previouslyUpdatedAdviser != null)
				{
					adviserToUpdate = previouslyUpdatedAdviser;
				}
				else
				//Keep a unique list of advisers being updated
				{
					advisersToUpdate.put(adviserToUpdate.Id, adviserToUpdate);
				}

				unassignedLead.OwnerId = adviserToUpdate.Id;

				adviserToUpdate.AW_NumberOfLeadAllocation__c = adviserToUpdate.AW_NumberOfLeadAllocation__c == null ? 1 : adviserToUpdate.AW_NumberOfLeadAllocation__c + 1;
				adviserToUpdate.AW_LastLeadAllocationDate__c = System.now();

				leadsToUpdate.add(unassignedLead);

				//Remove the first user to list and add it back to the end of the list
				branchAdvisers.remove(0);

				//Now add adviser to end of the list
				branchAdvisers.add(adviserToUpdate);
			}
			else
			{
				unassignedLead.OwnerId = unallocatedQueue.Id; // if no adviser put to unallocated queue
				leadsToUpdate.add(unassignedLead);
			}

		}
		CMN_DAL_SObjectDomain.updateDBObjects(leadsToUpdate);

		return advisersToUpdate.values();
	}
}