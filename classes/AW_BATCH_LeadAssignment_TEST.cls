/**
 * @description Test class for AW_BATCH_LeadAssignment,AW_DAL_LeadAssignment
 * @ Func Area Lead Assignment
 *
 * @see AW_BATCH_LeadAssignment
 * @see AW_DAL_LeadAssignment
 *
 * @author vishakha.saini@accenture.com
 *
 * @date 2019, March 2023
 */
@IsTest(SeeAllData=false IsParallel=false)
private class AW_BATCH_LeadAssignment_TEST
{
	private static final Integer NUMBER_ACCOUNTS_TO_CREATE = 4;
	private static final Integer NUMBER_ADVISERS_ACCEPTING_LEADS = 1;
	private static final Integer NUMBER_ADVISERS_TO_RETRIEVE = 3;
	private static final Integer NUMBER_LEADS_TO_CREATE = 4;

	/**
	 * @description To setup the test data
	 */
	@TestSetup
	private static void insertTestData()
	{
		User runAsUser = AW_DAL_User.findActiveAdministrator();
		List<Account> newAccounts;

		System.runAs(runAsUser)
		{
			newAccounts = AW_DAL_TestDataFactory.createBusinessAccounts(NUMBER_ACCOUNTS_TO_CREATE);

			List<Lead> newLeads = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, NUMBER_LEADS_TO_CREATE, AW_DAL_Group.getDistributionQueue().Id);

			//Allocate Leads to Accounts
			newLeads[0].AW_LeadBranch__c = newAccounts[0].Id;
			newLeads[1].AW_LeadBranch__c = newAccounts[0].Id;
			newLeads[2].AW_LeadBranch__c = newAccounts[1].Id;
			newLeads[3].AW_LeadBranch__c = newAccounts[2].Id;

			update newLeads;
		}

		//retrieve advisers
		List<User> foundAdvisers = new List<User>();

		System.runAs(runAsUser)
		{
			foundAdvisers = AW_DAL_User.findRandomActiveAdvisers(NUMBER_ADVISERS_TO_RETRIEVE);

			//now loop through the advisers and ensure that only some are able to accept leads
			for(Integer i = 0; i < foundAdvisers.size(); i++)
			{
				User foundAdviser = foundAdvisers[i];

				//Make sure we only switch on  some to be allocated
				foundAdviser.AW_ReceiveLeads__c = (i <= NUMBER_ADVISERS_ACCEPTING_LEADS - 1);
				//Reset lead metrics
				foundAdviser.AW_LastLeadAllocationDate__c = null;
				foundAdviser.AW_NumberOfLeadAllocation__c = 0.0;
			}

			update foundAdvisers;
		}

		List<User> teamMembersAccount1 = new List<User>();

		//This adviser should receive all the leads on the relevant account
		teamMembersAccount1.add(foundAdvisers[0]);

		//Neither of these adviser should receive leads
		List<User> teamMembersAccount2 = new List<User>();
		teamMembersAccount2.add(foundAdvisers[2]);
		teamMembersAccount2.add(foundAdvisers[1]);

		System.runAs(runAsUser)
		{

			AW_DAL_TestDataFactory.createAccountTeamMembers(newAccounts[0], teamMembersAccount1, AW_DAL_AccountTeamMember.ROLE_ADVISER);

			//Add last adviser to account 2, these should not be receiving leads
			AW_DAL_TestDataFactory.createAccountTeamMembers(newAccounts[1], teamMembersAccount2, AW_DAL_AccountTeamMember.ROLE_ADVISER);
		}
	}

	/**
	 * @description This test checks that only the advisers who are able to accept leads will receive them during assignment process.
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void leadAssignmentAdviser()
	{
		//Retrieve all the team members we setup previously
		List<AccountTeamMember> accountTeamMembers = AW_DAL_AccountTeamMember.getAll();
		List<Account> accounts = CMN_DAL_Account.findAllWithoutTeamMembers();

		Test.startTest();

		Database.executeBatch(new AW_BATCH_LeadAssignment());

		Test.stopTest();

		Set<Id> allocationUserIds = CMN_UTIL_System.extractListIds(accountTeamMembers, AW_DAL_AccountTeamMember.FIELD_USER_ID);

		//Retrieve all the original users that were added into teams
		List<User> advisers = AW_DAL_User.findById(allocationUserIds);
		Assert.areEqual(NUMBER_ADVISERS_TO_RETRIEVE, advisers.size(), 'Incorrect Number of advisers');

		//Now loop through advisers, if the are meant to receive leads, they should have  2
		Decimal allocationCount = 0;
		for(User adviser : advisers)
		{
			if(adviser.AW_ReceiveLeads__c == true)
			{
				allocationCount = allocationCount + adviser.AW_NumberOfLeadAllocation__c;
			}
		}

		/*
		This check that leads which are allocated to a branch but where we were unable to find an adviser to assign the lead to
		Should have their owner set to the unallocated queue
		 */
		Assert.areEqual(2, allocationCount, 'Incorrect Number of Leads Allocated');

		List<Lead> leads = AW_DAL_Lead.findByBranchId(accounts);

		Assert.areEqual(1, leads.size(), 'Invalid Number of Leads Returned.');

		Assert.areEqual(AW_DAL_Group.getUnallocatedQueue().Id, leads[0].OwnerId, 'Lead has the Wrong Owner.');
	}
}