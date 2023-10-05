/**
 * @description Class to test the send email functionality in CMN_FLOW_SendEmail
 *
 * @see CMN_FLOW_SendEmail.sendEmail
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date March 2021, January 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_FLOW_SendEmail_TEST
{
	/**
	 * @description Create required data for the unit test
	 */
	@TestSetup
	private static void setup()
	{
		CMN_DAL_SObjectDomain.insertDBObjects
				(
						new List<SObject>
						{
								CMN_DAL_DataFactory.newContact(),
								CMN_DAL_DataFactory.newFoobar(),
								CMN_DAL_DataFactory.newContentVersion()
						}
				);
	}

	/**
	 * @description Contains the base code required to run each test with variants in parameter list
	 *
	 * @param toAddress The address to send email to
	 * @param whatId The Id to which email should be related
	 *
	 * @return A list of email send responses
	 */
	private static List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> runTest(String toAddress, Id whatId)
	{

		CMN_FLOW_SendEmail.DTO_SendEmailRequest dtoEmail = new CMN_FLOW_SendEmail.DTO_SendEmailRequest();

		dtoEmail.toAddress = toAddress;
		dtoEmail.whatId = whatId;
		dtoEmail.orgWideEmailAddress = CMN_DAL_OrgWideEmailAddress.getRandomItem()?.Address;
		dtoEmail.templateUniqueName = CMN_DAL_EmailTemplate.TEST_EMAIL_TEMPLATE;
		dtoEmail.fileIds = new List<Id>();
		dtoEmail.fileIds.add(CMN_DAL_ContentVersion.getAll().iterator().next().Id);

		Test.startTest();

		List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> dtoResponses = CMN_FLOW_SendEmail.sendEmail(new List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> {dtoEmail});

		Test.stopTest();

		System.assertNotEquals(true, dtoResponses.isEmpty(), 'No responses received');

		return dtoResponses;
	}

	/**
	 * @description Check to see an email would have successfully been sent using contactId in the toAddress field
	 */
	@IsTest
	private static void successfulUsingContactId()
	{
		Contact newContact = CMN_DAL_Contact.getAll().iterator().next();
		CMN_Foobar__c newFoobar = CMN_DAL_Foobar.getAll().iterator().next();

		List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> dtoResponses = runTest(newContact.Id, newFoobar.Id);

		//Some orgs don't allow external emails to be sent, so don't fail tests if this is the case
		Boolean externalEmailsAllowed = CMN_EMAIL_Sender.getEmailDeliverabilityAccessLevel() == CMN_EMAIL_Sender.DeliverabilityAccessLevel.ALL_EMAIL;
		System.assert(dtoResponses.iterator().next().success || !externalEmailsAllowed, JSON.serializePretty(dtoResponses));
	}

	/**
	 * @description Check to see an email would have successfully been sent using an email in the toAddress field
	 */
	@IsTest
	private static void successfulUsingEmailAddress()
	{
		Contact newContact = CMN_DAL_Contact.getAll().iterator().next();
		CMN_Foobar__c newFoobar = CMN_DAL_Foobar.getAll().iterator().next();

		List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> dtoResponses = runTest(newContact.Email, newFoobar.Id);

		//Some orgs don't allow external emails to be sent, so don't fail tests if this is the case
		Boolean externalEmailsAllowed = CMN_EMAIL_Sender.getEmailDeliverabilityAccessLevel() == CMN_EMAIL_Sender.DeliverabilityAccessLevel.ALL_EMAIL;
		System.assert(dtoResponses.iterator().next().success || !externalEmailsAllowed, JSON.serializePretty(dtoResponses));
	}

	/**
	 * @description Will Test that an error is reported for putting invalid Id into targetObjectId
	 */
	@IsTest
	private static void failedInvalidTargetObjectId()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_Foobar.getAll().iterator().next();

		List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> dtoResponses = runTest(newFoobar.Id, newFoobar.Id);

		System.assertEquals(false, dtoResponses.iterator().next().success, JSON.serializePretty(dtoResponses));
	}
}