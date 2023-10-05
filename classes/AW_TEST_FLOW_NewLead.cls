/**
 * @description Test class for AW_FLOW_NewLead
 * @story ST-1900 ,ST-1276
 * @Func area Customer Community , Chatbot
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_FLOW_NewLead
{
	private static final Integer NUMBER_LEADS_TO_CREATE = 3;

	//Global variables to store assertion error messages
	private static final String ERROR_COMMUNITY_ACC_NOT_CREATED = 'Community  Account not created.';
	private static final String ERROR_COMMUNITY_USER_NOT_FOUND = 'No Community Users Retrieved';
	private static final String ERROR_INVALID_NUM_LEADS = 'Invalid number of Leads.';
	private static final String ERROR_INCORRECT_LEAD_OWNER = 'Incorrect Owner set on lead';
	private static final String ERROR_LEAD_OWNER_COMMUNITY_USER = 'Community User should not own Lead';

	/**
	 * @description Setup method to create test data
	 */
	@TestSetup
	private static void insertTestData()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		//Ensure that we create community account and user and community account owned by an adviser
		System.runAs(adviser)
		{
			AW_DAL_TestDataFactory.createCommunityUser();
		}
	}

	/**
	 * @description Method to test the scenario wherein lead is successfully created in Salesforce and owner set on provided UserName.
	 */
	@IsTest
	private static void createLeadAndSetOwnerWithUserName()
	{
		List<Account> newAccounts = AW_DAL_Account.getAll();

		System.assertEquals(1, newAccounts.size(), ERROR_COMMUNITY_ACC_NOT_CREATED);

		Account newAccount = newAccounts[0];

		List<User> communityUsers = CMN_DAL_User.findByAccountId(new Set<Id> {newAccount.Id});
		System.assertNotEquals(true, communityUsers.isEmpty(), ERROR_COMMUNITY_USER_NOT_FOUND);

		User communityUser = communityUsers[0];

		List<AW_FLOW_NewLead.DTO_Lead> dtoLeads = AW_DAL_TestDataFactory.createReferralLeadsDTO(NUMBER_LEADS_TO_CREATE, communityUser.Username);

		Test.startTest();

		AW_FLOW_NewLead.newItems(dtoLeads);

		Test.stopTest();

		List<Lead> newLeads = CMN_DAL_Lead.getAll();

		System.assertEquals(NUMBER_LEADS_TO_CREATE, newLeads.size(), ERROR_INVALID_NUM_LEADS);
		System.assertNotEquals(newLeads[0].OwnerId, communityUser.Id, ERROR_LEAD_OWNER_COMMUNITY_USER);
		System.assertEquals(newAccount.OwnerId, newLeads[0].OwnerId, ERROR_INCORRECT_LEAD_OWNER);
	}

	/**
	 * @description Method to test the scenario wherein lead is successfully created in Salesforce and if run as community user
	 */
	@IsTest
	private static void createLeadAndSetOwnerFromCommunity()
	{
		Account newAccount = AW_DAL_Account.getAll()[0];
		User communityUser = CMN_DAL_User.findByAccountId(new Set<Id> {newAccount.Id})[0];

		List<AW_FLOW_NewLead.DTO_Lead> dtoLeads = AW_DAL_TestDataFactory.createReferralLeadsDTO(NUMBER_LEADS_TO_CREATE, CMN_UTIL_String.EMPTY);

		System.runAs(communityUser)
		{
			Test.startTest();

			AW_FLOW_NewLead.newItems(dtoLeads);

			Test.stopTest();
		}

		List<Lead> newLeads = CMN_DAL_Lead.getAll();

		System.assertEquals(NUMBER_LEADS_TO_CREATE, newLeads.size(), ERROR_INVALID_NUM_LEADS);
		System.assertNotEquals(newLeads[0].OwnerId, communityUser.Id, ERROR_LEAD_OWNER_COMMUNITY_USER);
		System.assertEquals(newAccount.OwnerId, newLeads[0].OwnerId, ERROR_INCORRECT_LEAD_OWNER);
	}

}