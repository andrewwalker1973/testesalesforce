/**
 * @description Test class for AW_API_RestOutboundPostClientURL
 *
 * @see AW_API_RestOutboundGetAtWorkURL @story ST-2375
 *
 * @author vishakha.saini@accenture.com, jason.van.beukering@accenture.com
 *
 * @date November 2021, March 2023
 */
@IsTest(SeeAllData=false IsParallel=false)
private class AW_API_RestOutboundGetAtWorkURL_TEST
{

	/**
	 * @description Will create required test data
	 */
	@TestSetup
	private static void setup()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		System.runAs(adviser)
		{
			AW_DAL_TestDataFactory.createClientAccount();
		}
	}

	/**
	 * @description Method to create webservice queue records
	 *
	 * @param foundAccount The account on which to base the service request on
	 *
	 * @return Returns list of webservice queue records
	 */
	private static List<CMN_WebserviceCallQueue__c> getRequestList(Account foundAccount)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RestOutboundGetAtWorkURL.SERVICE_NAME, foundAccount.Id);
		queueItem.CMN_SourceID__c = AW_DAL_User.generateRandomAtWorkUserId();

		return new List<CMN_WebserviceCallQueue__c> {queueItem};
	}

	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void abortNoSourceId()
	{
		Account foundAccount = AW_DAL_Account.getAll().iterator().next();
		List<CMN_WebserviceCallQueue__c> queueItems = getRequestList(foundAccount);
		queueItems.iterator().next().CMN_SourceID__c = CMN_UTIL_String.EMPTY;

		CMN_API_RestBaseOutboundTestHelper.abortedCall(queueItems, AW_API_RestOutboundGetAtWorkURL.ERROR_USERNAME_BLANK);
	}

	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	private static void abortAccountNotFound()
	{
		Account foundAccount = AW_DAL_Account.getAll().iterator().next();
		List<CMN_WebserviceCallQueue__c> queueItems = getRequestList(foundAccount);
		delete foundAccount;

		CMN_API_RestBaseOutboundTestHelper.abortedCall(queueItems, AW_API_RestOutboundGetAtWorkURL.ERROR_ACCOUNT_NOT_FOUND);
	}

	@IsTest
	private static void abortNoUacfId()
	{
		Account foundAccount = AW_DAL_Account.getAll().iterator().next();
		List<CMN_WebserviceCallQueue__c> queueItems = getRequestList(foundAccount);
		User adviser = foundAccount.Owner;
		adviser.AW_UACFID__c = CMN_UTIL_String.EMPTY;

		System.runAs(AW_DAL_User.findActiveAdministrator())
		{
			update adviser;
		}

		System.runAs(adviser)
		{
			CMN_API_RestBaseOutboundTestHelper.abortedCall(queueItems, AW_API_RestOutboundGetAtWorkURL.ERROR_UACFID_NOT_FOUND);
		}
	}

	@IsTest
	private static void abortNoConsultantCode()
	{
		Account foundAccount = AW_DAL_Account.getAll().iterator().next();
		List<CMN_WebserviceCallQueue__c> queueItems = getRequestList(foundAccount);
		User adviser = foundAccount.Owner;
		adviser.AW_ConsultantCode__c = CMN_UTIL_String.EMPTY;

		System.runAs(AW_DAL_User.findActiveAdministrator())
		{
			update adviser;
		}

		CMN_API_RestBaseOutboundTestHelper.abortedCall(queueItems, AW_API_RestOutboundGetAtWorkURL.ERROR_CONSULTANT_CODE_NOT_FOUND);
	}

	/**
	 * @description Test Method to validate the scenario wherein successful outbound API call is made to get atWork URL
	 */
	@IsTest
	private static void successful()
	{
		Account foundAccount = AW_DAL_Account.getAll().iterator().next();
		List<CMN_WebserviceCallQueue__c> queueItems = getRequestList(foundAccount);
		User adviser = foundAccount.Owner;
		List<CMN_API_HttpBase> responses;

		System.runAs(adviser)
		{
			responses = CMN_API_RestBaseOutboundTestHelper.successfulCall(queueItems);
		}

		for(CMN_API_HttpBase response : responses)
		{
			AW_API_RestOutboundGetAtWorkURL urlHandler = (AW_API_RestOutboundGetAtWorkURL)response;
			Assert.isTrue(urlHandler.success, 'Successful response not received.');
			Assert.isTrue(String.isNotBlank(urlHandler.secureUrl), 'Url should not be blank.');
		}
	}

	/**
	 * @description Test Method to validate the scenario wherein calls is successful (i.e. HTTP 200 response), but payload indicates an error occurred
	 */
	@IsTest
	private static void successfulWithError()
	{
		Account foundAccount = AW_DAL_Account.getAll().iterator().next();
		List<CMN_WebserviceCallQueue__c> queueItems = getRequestList(foundAccount);
		User adviser = foundAccount.Owner;
		List<CMN_API_HttpBase> responses;

		System.runAs(adviser)
		{
			AW_API_RestOutboundGetAtWorkURL.returnErrorInResponse = true;
			responses = CMN_API_RestBaseOutboundTestHelper.successfulCall(queueItems);
		}

		for(CMN_API_HttpBase response : responses)
		{
			AW_API_RestOutboundGetAtWorkURL urlHandler = (AW_API_RestOutboundGetAtWorkURL)response;
			Assert.isFalse(urlHandler.success, 'Response should not be successful.');
			Assert.isTrue(String.isNotBlank(urlHandler.message), 'Message should not be blank.');
		}
	}
}