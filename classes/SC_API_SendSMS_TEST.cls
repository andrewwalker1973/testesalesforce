/**
 * @description Test class for CMN_API_SendSMS
 *
 * @see SC_API_SendSMS @story ST-297814
 *
 * @author uttpal.chandra@accenture.com jason.van.beukering@accenture.com
 *
 * @date December 2022
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class SC_API_SendSMS_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description Create data required for the unit test
	 */
	@TestSetup
	private static void setup()
	{
		Account accountRecord = AW_DAL_TestDataFactory.createMasterPersonAccount(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		SC_CaseExtension__c newExtension = SC_DAL_DataFactory.newCaseExtensions(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		newExtension.RSC_ClientCellNumber__c = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		insert newExtension;

		Case newCase = SC_DAL_DataFactory.newCase();
		newCase.SC_CaseExtension__c = newExtension.Id;
		newCase.AccountId = accountRecord.Id;
		insert newCase;
	}

	/**
	 * @description Emulates a successful call and confirms that Sms API was called successfully
	 */
	@IsTest
	private static void successfulCallWithCase()
	{

		CMN_API_RestBaseOutboundTestHelper.successfulCall
				(
						SC_API_SendSMS.SERVICE_NAME,
						SC_DAL_Case.getAll().iterator().next().Id,
						new Map<String, String>
						{
								SC_API_SendSMS.PARAMETER_EMAIL_TEMPLATE_NAME => CMN_DAL_EmailTemplate.TEST_EMAIL_TEMPLATE
						}
				);
	}

	/**
	 * @description Emulates a successful call and confirms that Sms API was called successfully
	 */
	@IsTest
	private static void successfulCallWithMobileParameter()
	{

		CMN_API_RestBaseOutboundTestHelper.successfulCall
				(
						SC_API_SendSMS.SERVICE_NAME,
						SC_DAL_Account.getAll().iterator().next().Id,
						new Map<String, String>
						{
								SC_API_SendSMS.PARAMETER_EMAIL_TEMPLATE_NAME => CMN_DAL_EmailTemplate.TEST_EMAIL_TEMPLATE,
								SC_API_SendSMS.PARAMETER_RECIPIENT_MOBILE_NUMBER => CMN_DAL_SObjectDomain.generateRandomNumber()
						}
				);
	}

	/**
	 * @description heck that the service aborts if the case Id provided doesn't exist (or returns no row)
	 */
	@IsTest
	private static void abortedCallCaseNotFound()
	{

		CMN_API_RestBaseOutboundTestHelper.abortedCall
				(
						SC_API_SendSMS.SERVICE_NAME,
						CMN_UTIL_Random.randomSObjectId(Case.SObjectType),
						new Map<String, String>
						{
								SC_API_SendSMS.PARAMETER_EMAIL_TEMPLATE_NAME => CMN_DAL_EmailTemplate.TEST_EMAIL_TEMPLATE
						}
				);
	}

	/**
	 * @description Check that the service aborts if no recipient parameter was provided
	 *
	 * @see SC_API_SendSMS.abortRequest
	 */
	@IsTest
	private static void abortedCallNoNumber()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall
				(
						SC_API_SendSMS.SERVICE_NAME,
						UserInfo.getUserId(),
						new Map<String, String>
						{
								SC_API_SendSMS.PARAMETER_EMAIL_TEMPLATE_NAME => CMN_DAL_EmailTemplate.TEST_EMAIL_TEMPLATE
						}
				);
	}

	/**
	 * @description Check that the service aborts if no template parameter was provided
	 *
	 * @see SC_API_SendSMS.abortRequest
	 */
	@IsTest
	private static void abortedCallNoTemplateParameter()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall
				(
						SC_API_SendSMS.SERVICE_NAME,
						SC_DAL_Case.getAll().iterator().next().Id
				);
	}

	/**
	 * @description Check that the service aborts if the template provided doesn't exist
	 *
	 * @see SC_API_SendSMS.abortRequest
	 */
	@IsTest
	private static void abortedCallTemplateNotFound()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall
				(
						SC_API_SendSMS.SERVICE_NAME,
						SC_DAL_Case.getAll().iterator().next().Id,
						new Map<String, String>
						{
								SC_API_SendSMS.PARAMETER_EMAIL_TEMPLATE_NAME => CMN_DAL_SObjectDomain.generateRandomName()
						}
				);
	}
}