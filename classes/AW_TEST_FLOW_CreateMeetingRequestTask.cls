/**
 * @description Test class for AW_FLOW_CreateMeetingRequestTask
 *
 * @see AW_FLOW_CreateMeetingRequestTask @story ST-1900 ,ST-1276
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_FLOW_CreateMeetingRequestTask
{
	private static final Integer NUMBER_REQUEST_RECORD_TO_CREATE = 3;

	//Global variables to store assertion error messages
	private static final String ERROR_COMMUNITY_ACC_NOT_CREATED = 'Community  Account not created.';
	private static final String ERROR_COMMUNITY_USER_NOT_FOUND = 'No Community Users Retrieved';
	private static final String ERROR_INVALID_NUM_TASKS = 'Invalid number of tasks created';
	private static final String ERROR_INCORRECT_TASK_OWNER = 'Task is not owned by Adviser';

	/**
	 * @description : Setup method to create test data
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
	 * @description : Method to test the scenario wherein task is created in Salesforce from community
	 */
	@IsTest
	private static void createAppointmentRequest()
	{
		List<Account> newAccounts = AW_DAL_Account.getAll();

		System.assertEquals(1, newAccounts.size(), ERROR_COMMUNITY_ACC_NOT_CREATED);

		Account newAccount = newAccounts[0];

		List<User> communityUsers = CMN_DAL_User.findByAccountId(new Set<Id> {newAccount.Id});
		System.assertNotEquals(true, communityUsers.isEmpty(), ERROR_COMMUNITY_USER_NOT_FOUND);

		User communityUser = communityUsers[0];

		List<AW_FLOW_CreateMeetingRequestTask.DTO_Task> dtoTasks = AW_DAL_TestDataFactory.createAppointmentTasksDTO(NUMBER_REQUEST_RECORD_TO_CREATE, communityUser.Username);

		List<Task> newTasks;

		Test.startTest();

		newTasks = AW_FLOW_CreateMeetingRequestTask.createTask(dtoTasks);

		Test.stopTest();

		System.assertEquals(dtoTasks.size(), newTasks.size(), ERROR_INVALID_NUM_TASKS);

		User adviserUser = AW_DAL_User.findById(new Set<Id> {newAccount.OwnerId})[0];

		System.assertEquals(adviserUser.Id, newTasks[0].OwnerId, ERROR_INCORRECT_TASK_OWNER);
	}
}