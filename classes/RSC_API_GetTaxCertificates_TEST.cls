/**
 * @description Test class for RSC_API_GetTaxCertificates
 *
 * @see RSC_API_GetTaxCertificates @story ST-147578
 *
 * @author jayanth.kumar.s@accenture.com darrion.james.singh@accenture.com, vishakha.saini@accenture.com jason.van.beukering@accenture.com
 *
 * @date September 2021, April 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class RSC_API_GetTaxCertificates_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;
	private static final String ERROR_NO_TAX_RETRIEVED = 'Tax certificates not retrieved for the given personId';

	/**
	 * @description Create data required for the unit test
	 */
	@TestSetup
	private static void setup()
	{
		AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
	}

	/**
	 * @description Emulates a successful call when the required parameter personId is passed.
	 * Inserts a contract to be enriched, Name is given as one of the policy numbers in the mock response
	 *
	 * @see RSC_API_GetTaxCertificates.getEndpointMock
	 */
	@IsTest
	private static void successfulCall()
	{
		Account foundAccount = SC_DAL_Account.getAll().iterator().next();
		InsurancePolicy newPolicy = RSC_DAL_TestDataFactory.createInsurancePolicies(NUMBER_OF_ITEMS_TO_CREATE, foundAccount.Id).iterator().next();
		FinServ__FinancialAccount__c newFinancialAccount = AW_DAL_TestDataFactory.createFinancialAccounts(foundAccount, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
				(
						RSC_API_GetTaxCertificates.SERVICE_NAME, null,
						RSC_API_GetTaxCertificates.PARAMETER_PERSON_ID, foundAccount.AW_IdentificationNumber__pc
				);

		CMN_DAL_Logger.ignoreTestMode = true;

		RSC_API_GetTaxCertificates.testPolicyNumber1 = newPolicy.Name;
		RSC_API_GetTaxCertificates.testPolicyNumber2 = newFinancialAccount.FinServ__FinancialAccountNumber__c;

		RSC_API_GetTaxCertificates handler =
				(RSC_API_GetTaxCertificates)CMN_API_RestBaseOutboundTestHelper.successfulCall(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

		System.assertNotEquals(true, handler.transformedResponse.contracts.isEmpty(), ERROR_NO_TAX_RETRIEVED);
		Boolean contractWasEnriched = false;

		for(RSC_API_GetTaxCertificates.DTO_Contract dtoContract : handler.transformedResponse.contracts)
		{
			// Find the enriched contract in the list of contract responses
			if(String.isNotBlank(dtoContract.status))
			{
				contractWasEnriched = true;
				break;
			}
		}

		System.assert(contractWasEnriched, 'No enriched contract was found');
	}

	/**
	 * @description Emulates a successful call when the required parameter personId is passed.
	 * Inserts a contract to be enriched, Name is given as one of the policy numbers in the mock response
	 *
	 * @see RSC_API_GetTaxCertificates.getEndpointMock
	 */
	@IsTest
	private static void successfulCallTable()
	{
		Account foundAccount = SC_DAL_Account.getAll().iterator().next();

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
				(
						RSC_API_GetTaxCertificates.SERVICE_NAME, null,
						RSC_API_GetTaxCertificates.PARAMETER_PERSON_ID, foundAccount.AW_IdentificationNumber__pc
				);

		CMN_DAL_Logger.ignoreTestMode = true;

		RSC_API_GetTaxCertificates handler = (RSC_API_GetTaxCertificates)CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer
				(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

		System.assertNotEquals(true, handler.transformedResponse.contracts.isEmpty(), ERROR_NO_TAX_RETRIEVED);
	}

	/**
	 * @description Emulates a successful call when the required parameter personId is passed.
	 */
	@IsTest
	private static void successfulCallNoEnrichment()
	{
		Account foundAccount = SC_DAL_Account.getAll().iterator().next();

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
				(
						RSC_API_GetTaxCertificates.SERVICE_NAME, null,
						RSC_API_GetTaxCertificates.PARAMETER_PERSON_ID, foundAccount.AW_IdentificationNumber__pc
				);

		CMN_DAL_Logger.ignoreTestMode = true;

		RSC_API_GetTaxCertificates handler =
				(RSC_API_GetTaxCertificates)CMN_API_RestBaseOutboundTestHelper.successfulCall(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

		System.assertNotEquals(true, handler.transformedResponse.contracts.isEmpty(), ERROR_NO_TAX_RETRIEVED);
		System.assertEquals(true, String.isBlank(handler.transformedResponse.contracts.iterator().next().status), 'Policy should not be enriched');

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(RSC_API_GetTaxCertificates.LOG_CLASS_METHOD);
		System.assertNotEquals(null, appLog, 'No Log was written');
	}

	/**
	 * @description Check that the service abort if the personId is blank
	 *
	 * @see RSC_API_GetTaxCertificates.abortRequest
	 */
	@IsTest
	private static void abortIdentificationNumberBlank()
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
				(
						RSC_API_GetTaxCertificates.SERVICE_NAME, null,
						RSC_API_GetTaxCertificates.PARAMETER_PERSON_ID, CMN_UTIL_String.EMPTY
				);

		CMN_API_RestBaseOutboundTestHelper.abortedCall(new List<CMN_WebserviceCallQueue__c> {queueItem});
	}
}