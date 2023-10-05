/**
 * @description Test class related to the RSC_CTRL_GetCommunicationAttachment
 *
 * @see RSC_CTRL_GetCommunicationAttachment @story ST-146941
 *
 * @author darrion.james.singh@accenture.com, meghana.g.n@accenture.com
 *
 * @date July 2021, May 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class RSC_CTRL_GetCommunicationAttachment_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description method to get Communication Attachments by template Id
	 *
	 * @see RSC_CTRL_GetCommunicationAttachment.getAttachmentsByTemplateId
	 */
	@IsTest
	private static void getAttachmentsByTemplateId()
	{
		CMN_CommunicationTemplate__c template = CMN_DAL_DataFactory.createCommunicationTemplate
				(
						NUMBER_OF_ITEMS_TO_CREATE,
						SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME
				).iterator().next();

		CMN_DAL_DataFactory.createCommunicationTemplateAttachments(template.Id, NUMBER_OF_ITEMS_TO_CREATE);

		Test.startTest();

		List<CMN_DTO_CommunicationAttachment> attachments = RSC_CTRL_GetCommunicationAttachment.getAttachmentsByTemplateId(template.Id);

		Test.stopTest();

		System.assertEquals(false, attachments.isEmpty(), 'No communication template attachment found.');
	}
}