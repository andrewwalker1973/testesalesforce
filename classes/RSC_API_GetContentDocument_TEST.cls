/**
 * @description Test class for RSC_API_GetContentDocument
 *
 * @see RSC_API_GetContentDocument @story ST-146054
 *
 * @author rajpal.singh@liberty.co.za jason.van.beukering@accenture.com
 *
 * @date August 2021, April 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private inherited sharing class RSC_API_GetContentDocument_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description Create data required for the unit test
	 */
	@TestSetup
	private static void setup()
	{
		Case caseRecord = SC_DAL_DataFactory.createCase(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		RSC_DAL_TestDataFactory.insertDocumentCheckListItems(caseRecord.Id, NUMBER_OF_ITEMS_TO_CREATE);
	}

	/**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void successfulCall()
	{
		DocumentChecklistItem checklistItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next();
		ContentVersion newContentVersion = AW_DAL_TestDataFactory.createContentVersions(checklistItem.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		newContentVersion = CMN_DAL_ContentVersion.findByFirstPublishLocationId(checklistItem.Id).iterator().next();
		RSC_API_GetContentDocument.mockContentDocumentId = newContentVersion.ContentDocumentId;

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
				(
						RSC_API_GetContentDocument.SERVICE_NAME, checklistItem.Id,
						RSC_API_GetContentDocument.PARAMETER_VAULTED_ID, checklistItem.CMN_VaultedId__c
				);

		RSC_API_GetContentDocument handler =
				(RSC_API_GetContentDocument)CMN_API_RestBaseOutboundTestHelper.successfulCall(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

		System.assertEquals(RSC_API_GetContentDocument.mockContentDocumentId, handler.contentDocumentId, 'Response should be a valid content document id');
	}

	/**
	 * @description Check that the service abort if the Id provided does not find a documentChecklistItem
	 *
	 * @see RSC_API_GetContentDocument.abortRequest
	 */
	@IsTest
	private static void abortedCallNoItemFound()
	{
		DocumentChecklistItem checklistItem = AW_DAL_DocumentChecklistItem.getAll().iterator().next();

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
				(
						RSC_API_GetContentDocument.SERVICE_NAME, checklistItem.Id
				);
		CMN_API_RestBaseOutboundTestHelper.abortedCall(new List<CMN_WebserviceCallQueue__c> {queueItem});

	}

	/**
	 * @description Check that the service abort if the vaultedId is blank
	 *
	 * @see RSC_API_GetContentDocument.abortRequest
	 */
	@IsTest
	private static void abortedCallForBlankParameter()
	{
		DocumentChecklistItem checklistItem = SC_DAL_DocumentChecklistItem.getAll().iterator().next();
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
				(
						RSC_API_GetContentDocument.SERVICE_NAME, checklistItem.Id,
						RSC_API_GetContentDocument.PARAMETER_VAULTED_ID, CMN_UTIL_String.EMPTY
				);
		CMN_API_RestBaseOutboundTestHelper.abortedCall(new List<CMN_WebserviceCallQueue__c> {queueItem});
	}
}