/**
 * @description Test class for AW_API_GetSigningHubOAuthToken
 *
 * @see AW_API_GetSigningHubOAuthToken @story ST-166458
 *
 * @author prashant.k.jain@accenture.com
 *
 * @date July 2021, February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_API_GetSigningHubOAuthToken_TEST
{

	private static final Integer NUM_ITEMS_TO_CREATE = 1;

	/**
	 * @description Emulates a successful call and confirms Authentication details are retrieved
	 */
	@IsTest

	private static void successfulCallWithEnvelope()
	{
		AW_Envelope__c envelope;
		User adviser = AW_DAL_User.findRandomActiveAdviser();
		System.runAs(adviser)
		{
			List<Account> personAccounts = AW_DAL_TestDataFactory.createClientAccount();
			Account newPersonAccount = personAccounts.iterator().next();
			envelope = AW_DAL_TestDataFactory.insertEnvelopeWithActiveAccount(newPersonAccount.Id);
			DocumentChecklistItem documentChecklistItem = AW_DAL_TestDataFactory.insertDocumentCheckListItem(envelope.Id);
			AW_DAL_TestDataFactory.createContentVersions(documentChecklistItem.Id, NUM_ITEMS_TO_CREATE);
		}

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_GetSigningHubOAuthToken.SERVICE_NAME, envelope.Id);
		AW_API_GetSigningHubOAuthToken handler = (AW_API_GetSigningHubOAuthToken)
				CMN_API_RestBaseOutboundTestHelper.successfulCall(new List<CMN_WebserviceCallQueue__c>{queueItem}).iterator().next();
		System.assert(String.isNotBlank(handler.accessToken), 'Access Token not generated');
	}

	/**
	 * @description Emulates a unsuccessful call and confirms Authentication details are not retrieved
	 */
	@IsTest
	private static void abortedCallWithoutEnvelope()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_GetSigningHubOAuthToken.SERVICE_NAME, adviser.Id);
		CMN_API_RestBaseOutboundTestHelper.abortedCall(new List<CMN_WebserviceCallQueue__c>
		{
				queueItem
		}).iterator().next();
	}
}