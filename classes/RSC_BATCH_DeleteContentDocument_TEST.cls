/**
 * @description Test class for RSC_BATCH_DeleteContentDocument
 *
 * @see RSC_BATCH_DeleteContentDocument @story ST-146054
 *
 * @author rajpal.singh@accenture.com jason.van.beukering@accenture.com
 *
 * @date September 2021, April 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class RSC_BATCH_DeleteContentDocument_TEST
{
	private static final Integer INT_MINUS_FIFTEEN = -15;
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description Create data required for the unit test and test the batch class
	 */
	@IsTest
	private static void contentVersion()
	{
		Case caseRecord = SC_DAL_DataFactory.createCase(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		DocumentChecklistItem checklistItem = RSC_DAL_TestDataFactory.insertDocumentCheckListItems(caseRecord.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		ContentVersion newContentVersion = AW_DAL_TestDataFactory.createContentVersions(checklistItem.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		newContentVersion.CMN_DeleteBy__c = System.now().addMinutes(INT_MINUS_FIFTEEN);

		update newContentVersion;

		Test.startTest();

		Database.executeBatch(new RSC_BATCH_DeleteContentDocument());

		Test.stopTest();

		ContentVersion version = SC_DAL_ContentVersion.findById(newContentVersion.Id);
		System.assertEquals(null, version, 'Content Version is not deleted as expected');
	}
}