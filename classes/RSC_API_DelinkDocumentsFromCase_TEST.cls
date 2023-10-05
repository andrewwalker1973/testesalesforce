/**
 * @description Test class for RSC_API_DelinkDocumentsFromCase
 *
 * @see RSC_API_DelinkDocumentsFromCase @story ST-146083
 *
 * @author jason.van.beukering@accenture.com meghana.g.n@accenture.com
 *
 * @date August 2021, May 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class RSC_API_DelinkDocumentsFromCase_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description Create data required for the unit test
	 */
	@TestSetup
	private static void setup()
	{
		Case caseRecord = SC_DAL_DataFactory.createCase(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		SC_DAL_DataFactory.insertDocumentCheckListItems(caseRecord.Id, NUMBER_OF_ITEMS_TO_CREATE);
	}

	/**
	 * @description Emulates a successful call and confirms DocumentChecklistITem is de-linked successfully
	 */
	@IsTest
	private static void successfulCall()
	{
		DocumentChecklistItem checklistItem = AW_DAL_DocumentChecklistItem.getAll().iterator().next();
		CMN_API_RestBaseOutboundTestHelper.successfulCall
				(RSC_API_DelinkDocumentsFromCase.SERVICE_NAME, checklistItem.Id, RSC_API_DelinkDocumentsFromCase.PARAMETER_REASON);

	}

	/**
	 * @description Check that the service abort if the Id provided does not find a documentChecklistItem
	 *
	 * @see RSC_API_DelinkDocumentsFromCase.abortRequest
	 */
	@IsTest
	private static void abortedCallNoItemFound()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall
				(RSC_API_DelinkDocumentsFromCase.SERVICE_NAME, UserInfo.getUserId(), RSC_API_DelinkDocumentsFromCase.PARAMETER_REASON);
	}

	/**
	 * @description Check that the service abort if the documentChecklistItem is not vaulted
	 *
	 * @see RSC_API_DelinkDocumentsFromCase.abortRequest
	 */
	@IsTest
	private static void abortedCallDocumentNotVaulted()
	{
		DocumentChecklistItem checklistItem = AW_DAL_DocumentChecklistItem.getAll().iterator().next();
		checklistItem.CMN_VaultedId__c = CMN_UTIL_String.EMPTY;
		CMN_DAL_SObjectDomain.updateDBObject(checklistItem);

		CMN_API_RestBaseOutboundTestHelper.abortedCall
				(RSC_API_DelinkDocumentsFromCase.SERVICE_NAME, checklistItem.Id, RSC_API_DelinkDocumentsFromCase.PARAMETER_REASON);
	}

	/**
	 * @description Check that the service abort if the de-link reason is not provided
	 *
	 * @see RSC_API_DelinkDocumentsFromCase.abortRequest
	 */
	@IsTest
	private static void abortedCallReasonNotProvided()
	{
		DocumentChecklistItem checklistItem = AW_DAL_DocumentChecklistItem.getAll().iterator().next();
		CMN_API_RestBaseOutboundTestHelper.abortedCall(RSC_API_DelinkDocumentsFromCase.SERVICE_NAME, checklistItem.Id);
	}

	/**
	 * @description Check that the service abort if the de-link reason is blank
	 *
	 * @see RSC_API_DelinkDocumentsFromCase.abortRequest
	 */
	@IsTest
	private static void abortedCallForBlankReason()
	{
		DocumentChecklistItem checklistItem = AW_DAL_DocumentChecklistItem.getAll().iterator().next();
		Map<String, String> parameterMap = new Map<String, String>();
		parameterMap.put(RSC_API_DelinkDocumentsFromCase.PARAMETER_REASON, CMN_UTIL_String.EMPTY);
		CMN_API_RestBaseOutboundTestHelper.abortedCall(RSC_API_DelinkDocumentsFromCase.SERVICE_NAME, checklistItem.Id, parameterMap);
	}
	/**
	 * @description Emulates a failed call and checks that error message is not blank
	 */
	@IsTest
	private static void failedCall()
	{
		DocumentChecklistItem checklistItem = AW_DAL_DocumentChecklistItem.getAll().iterator().next();
		Map<String, String> parameterMap = new Map<String, String>();
		parameterMap.put(RSC_API_DelinkDocumentsFromCase.PARAMETER_REASON, CMN_UTIL_String.generateRandomString(NUMBER_OF_ITEMS_TO_CREATE));

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
				RSC_API_DelinkDocumentsFromCase.SERVICE_NAME,
				checklistItem.Id,
				parameterMap);

		Test.startTest();

		CMN_API_HttpBaseOutboundMock.returnErrorResponse = true;
		RSC_API_DelinkDocumentsFromCase handler = (RSC_API_DelinkDocumentsFromCase)CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c>
		{
				queueItem
		}).iterator().next();

		Test.stopTest();
		System.assertEquals(true, handler.callResult.failed, 'Status invalid. Response Call Result JSON: ' + JSON.serialize(handler.callResult));
	}
}