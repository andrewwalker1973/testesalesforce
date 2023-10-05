/**
 * @description This class is the apex test class for the class AW_FNA_TOOL_Land_Page_Controller
 *
 * @see AW_FNA_TOOL_Land_Page_Controller
 *
 * @author thirugnana.sambandam@lntinfotech.com vishakha.saini@accenture.com
 *
 * @date November 2020, February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_FNA_TOOL_Land_Page_Controller
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description This test method tests the happy flow for the method getAccountId and checks
	 * 				that the method behaves correctly.
	 *
	 * @see AW_FNA_TOOL_Land_Page_Controller.getAccountId
	 */
	@IsTest
	private static void getAccountId()
	{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		AW_FNA__c newFNA = AW_DAL_TestDataFactory.createFNA(newAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		Test.startTest();

		Id accountId = AW_FNA_TOOL_Land_Page_Controller.getAccountId(newFNA.AW_FNAID__c);

		Test.stopTest();

		System.assertEquals(accountId, newAccount.Id, 'Incorrect Account Id retrieved');
	}
}