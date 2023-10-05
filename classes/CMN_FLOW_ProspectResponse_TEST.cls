/**
 * @description Test class for CMN_FLOW_ProspectResponse
 *
 * @see CMN_FLOW_ProspectResponse
 *
 * @author vishakha.saini@accenture.com safwan.h.mohammed@accenture.com
 *
 * @date February 2022, June 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_FLOW_ProspectResponse_TEST
{
	@IsTest
	private static void checkProspectResponse()
	{
		Id accountFailureTriggerId;
		Id accountSuccessTriggerId;
		List<Account> newAccounts;
		List<CMN_WebserviceCallQueue__c> queueItems = new List<CMN_WebserviceCallQueue__c>();
		Set<Id> accountIds = new Set<Id>();
		final String completedStatus = 'Completed';
		final String failedStatus = 'Failed';
		final String globalKeyValue = CMN_DAL_SObjectDomain.generateRandomNumber();
		final String validResponseBody =
				'{ "Message": "Persons Added successfully", "stateId": "8AAC3638-845C-44E0-A7C5-64111B2D2D7A", "globalKey": "' + globalKeyValue + '" }';

		newAccounts = AW_DAL_TestDataFactory.createClientAccount(2);

		accountSuccessTriggerId = newAccounts.get(0).Id;
		accountFailureTriggerId = newAccounts.get(1).Id;

		// Success
		CMN_WebserviceCallQueue__c successQueueItem = new CMN_WebserviceCallQueue__c();
		successQueueItem.CMN_TriggeringObjectId__c = accountSuccessTriggerId;
		successQueueItem.CMN_Status__c = completedStatus;
		successQueueItem.CMN_Response__c = validResponseBody;
		queueItems.add(successQueueItem);

		// Failed
		CMN_WebserviceCallQueue__c failedQueueItem = new CMN_WebserviceCallQueue__c();
		failedQueueItem.CMN_TriggeringObjectId__c = accountFailureTriggerId;
		failedQueueItem.CMN_Status__c = failedStatus;
		failedQueueItem.CMN_Response__c = '{"error":{"errorMessage":"Prospect sync did not execute as expected."}}';
		queueItems.add(failedQueueItem);

		Test.startTest();
		CMN_FLOW_ProspectResponse.updateProspect(queueItems);
		Test.stopTest();

		accountIds.add(accountSuccessTriggerId);
		accountIds.add(accountFailureTriggerId);
		Map<Id, Account> accountByIds = new Map<Id, Account>(AW_DAL_Account.findById(accountIds)); // Re-query accounts to get updated values
		Account successAccount = accountByIds.get(accountSuccessTriggerId);
		Account failedAccount = accountByIds.get(accountFailureTriggerId);

		System.assertEquals(false, successAccount.AW_Synch_Error__c, 'Sync Error flag not set correctly on success Account');
		System.assertNotEquals(null, successAccount.AW_Last_Synch_Date__c, 'Last Sync Date not set correctly on success Account');
		System.assertEquals(globalKeyValue, successAccount.AW_SKF_Id__c, 'SKF Id not set correctly on success Account');

		System.assertEquals(true, failedAccount.AW_Synch_Error__c, 'Sync Error flag not set correctly on failed Account');
		System.assertNotEquals(null, failedAccount.AW_SyncErrorMessage__c, 'Sync Error message did not load as expected');
	}
}