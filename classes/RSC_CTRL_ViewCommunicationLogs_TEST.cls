/**
 * @description Test class related to the RSC_CTRL_ViewCommunicationLogsOnAccount
 *
 * @see RSC_CTRL_ViewCommunicationLogs
 *
 * @author jayanth.kumar.s@accenture.com prashant.k.jain@accenture.com
 *
 * @date February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class RSC_CTRL_ViewCommunicationLogs_TEST
{
	private static final Integer INT_ONE = 1;
	private static final Integer INT_TWO = 2;
	private static final String NO_CASES_FOUND = 'No Cases found as expected';
	private static final String NO_COMMUNICATION_LOGS_FOUND = 'No Communication Logs found as expected';

	/**
	 * @description Create data required for unit tests
	 */
	@TestSetup
	private static void setup()
	{
		Account personMasterAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		List<Case> newCases = RSC_DAL_TestDataFactory.newCase(INT_TWO, personMasterAccount.Id);
		insert newCases;

		List<CMN_CommunicationLog__c> newLogs = new List<CMN_CommunicationLog__c>();

		for(Case newCase : newCases)
		{
			CMN_CommunicationLog__c newLog = RSC_DAL_TestDataFactory.newCommunicationLog(INT_ONE, newCase.Id).iterator().next();
			newLogs.add(newLog);
		}

		insert newLogs;
	}

	/**
	 * @description method to get Cases by account Id
	 *
	 * @see RSC_CTRL_ViewCommunicationLogs.getCases
	 */
	@IsTest
	private static void getCaseByAccount()
	{

		/*
			As we can’t use Apex to create a criteria-based sharing rule,and we can’t test criteria-based sharing using Apex.
			If the Agent is not set as the owner of the Account then the records will not be shared with Agent,
			hence the approach is to not to run the test as specific user or set the user as
			the owner of the record
		*/

		Account foundAccount = SC_DAL_Account.getAll().iterator().next();

		Test.startTest();

			List<Case> newCases = RSC_CTRL_ViewCommunicationLogs.getCases(foundAccount.Id);

		Test.stopTest();

		System.assertEquals(false, newCases.isEmpty(), NO_CASES_FOUND);
		System.assertEquals(INT_TWO, newCases.size(), NO_CASES_FOUND);
	}

	/**
	 * @description method to get Cases by account Id
	 *
	 * @see RSC_CTRL_ViewCommunicationLogs.getCases
	 */
	@IsTest
	private static void getCommunicationLogsByCase()
	{
		User foundAgent = SC_DAL_User.findRandomActiveAgent();
		List<Case> foundCases = SC_DAL_Case.getAll();

		List<Id> foundCaseIds = new List<Id> (CMN_UTIL_System.extractListIds(foundCases));

		Test.startTest();

		System.runAs(foundAgent)
		{
			List<CMN_CommunicationLog__c> newLogs = RSC_CTRL_ViewCommunicationLogs.getCommunicationLogs(foundCaseIds);
			System.assertEquals(false, newLogs.isEmpty(), NO_COMMUNICATION_LOGS_FOUND);
			System.assertEquals(INT_TWO, newLogs.size(), NO_COMMUNICATION_LOGS_FOUND);
		}

		Test.stopTest();
	}
}