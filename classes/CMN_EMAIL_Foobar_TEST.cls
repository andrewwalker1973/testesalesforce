/**
 * @description Test the behaviour of Inbound Email Handler
 *
 * @see CMN_EMAIL_Foobar
 *
 * @author Accenture
 *
 * @date 2020
 */
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_EMAIL_Foobar_TEST
{
	/**
	 * @description Tests successful processing of an Inbound Email
	 */
	@IsTest
	private static void successful()
	{
		Messaging.InboundEnvelope newEnvelope = CMN_DAL_DataFactory.newInboundEnvelope();
		Messaging.InboundEmail newEmail = CMN_DAL_DataFactory.newInboundEmail();

		Test.startTest();

		Messaging.InboundEmailResult result = new CMN_EMAIL_Foobar().handleInboundEmail(newEmail, newEnvelope);

		Test.stopTest();

		System.assertNotEquals(null, result, 'Result incorrectly set');
		System.assertEquals(true, result.success, 'Processing should have passed');

		List<CMN_Foobar__c> cmnFoobars = CMN_DAL_Foobar.getAll();
		System.assertEquals(1, cmnFoobars.size(), 'Invalid number of Objects inserted');

		List<ContentVersion> savedAttachments = CMN_DAL_ContentVersion.findByFirstPublishLocationId(cmnFoobars.iterator().next().Id);
		System.assertEquals(CMN_DAL_DataFactory.NUMBER_HEADERS_AND_ATTACHMENTS_TO_CREATE * 2, savedAttachments.size(), 'Invalid number of attachments saved');
	}

	/**
	 * @description Tests failed processing of an Inbound Email
	 */
	@IsTest
	private static void failed()
	{
		Test.startTest();

		/* passing nulls will result in null pointer exception */
		Messaging.InboundEmailResult result = new CMN_EMAIL_Foobar().handleInboundEmail(null, null);

		Test.stopTest();

		System.assertNotEquals(null, result, 'Result incorrectly set');
		System.assertEquals(false, result.success, 'Processing should have failed');
	}
}