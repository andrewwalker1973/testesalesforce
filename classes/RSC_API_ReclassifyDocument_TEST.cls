/**
 * @description Test class for RSC_API_ReclassifyDocument
 *
 * @see RSC_API_ReclassifyDocument @story ST-146099
 *
 * @author m.sudhakar.rokde@accenture.com jason.van.beukering@accenture.com
 *
 * @date September 2021, April 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class RSC_API_ReclassifyDocument_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	private static DocumentChecklistItem createData(User aUser)
	{
		DocumentChecklistItem checklistItem;

		System.runAs(aUser)
		{
			Case caseRecord = SC_DAL_DataFactory.createCase(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
			checklistItem = RSC_DAL_TestDataFactory.insertDocumentCheckListItems(caseRecord.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		}

		return checklistItem;
	}

	/**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void successfulCall()
	{
		User foundUser = SC_DAL_User.findRandomActiveAgent();
		DocumentChecklistItem checklistItem = createData(foundUser);

		System.runAs(foundUser)
		{
			Id documentTypeId = SC_DAL_DocumentType.findRandomActive().Id;

			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
					(
							RSC_API_ReclassifyDocument.SERVICE_NAME,
							checklistItem.Id,
							RSC_API_ReclassifyDocument.PARAMETER_DOCUMENT_TYPE,
							documentTypeId
					);

			CMN_API_RestBaseOutboundTestHelper.successfulCall(new List<CMN_WebserviceCallQueue__c> {queueItem});
		}
	}

	/**
	 * @description Check that the service abort if the Id provided does not find a documentChecklistItem
	 *
	 * @see RSC_API_ReclassifyDocument.abortRequest
	 */
	@IsTest
	private static void abortDueToNoItemFound()
	{
		System.runAs(SC_DAL_User.findRandomActiveAgent())
		{
			CMN_API_RestBaseOutboundTestHelper.abortedCall
					(RSC_API_ReclassifyDocument.SERVICE_NAME, UserInfo.getUserId(), RSC_API_ReclassifyDocument.PARAMETER_DOCUMENT_TYPE);
		}
	}

	/**
	 * @description Checks that the service aborts if an invalid document document type Id is provided
	 *
	 * @see RSC_API_ReclassifyDocument.abortRequest
	 */
	@IsTest
	private static void abortDueToInvalidDocumentTypeId()
	{
		User foundUser = SC_DAL_User.findRandomActiveAgent();
		DocumentChecklistItem checklistItem = createData(foundUser);

		System.runAs(foundUser)
		{
			CMN_API_RestBaseOutboundTestHelper.abortedCall
					(RSC_API_ReclassifyDocument.SERVICE_NAME, checklistItem.Id, RSC_API_ReclassifyDocument.PARAMETER_DOCUMENT_TYPE);
		}

	}

	/**
	 * @description Check that the service abort if the Id provided does not find a vaulted documentChecklistItem
	 *
	 * @see RSC_API_ReclassifyDocument.abortRequest
	 */
	@IsTest
	private static void abortedDueDocumentNotVaulted()
	{
		User foundUser = SC_DAL_User.findRandomActiveAgent();
		DocumentChecklistItem checklistItem = createData(foundUser);

		checklistItem.AW_Vaulted__c = false;
		CMN_DAL_SObjectDomain.updateDBObject(checklistItem);

		System.runAs(foundUser)
		{
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
					(
							RSC_API_ReclassifyDocument.SERVICE_NAME,
							checklistItem.Id,
							RSC_API_ReclassifyDocument.PARAMETER_DOCUMENT_TYPE,
							checklistItem.DocumentTypeId
					);

			CMN_API_RestBaseOutboundTestHelper.abortedCall(new List<CMN_WebserviceCallQueue__c> {queueItem});
		}
	}
	/**
	 * @description Check that the service abort if the Id provided does not find a user with UACFID
	 *
	 * @see RSC_API_ReclassifyDocument.abortRequest
	 */
	@IsTest
	private static void abortedDueNoUacfid()
	{
		User foundUser = SC_DAL_User.findRandomActiveAgent();
		DocumentChecklistItem checklistItem = createData(foundUser);

		foundUser.AW_UACFID__c = CMN_UTIL_String.EMPTY;
		CMN_DAL_SObjectDomain.updateDBObject(foundUser);

		System.runAs(foundUser)
		{
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
					(
							RSC_API_ReclassifyDocument.SERVICE_NAME,
							checklistItem.Id,
							RSC_API_ReclassifyDocument.PARAMETER_DOCUMENT_TYPE,
							checklistItem.DocumentTypeId
					);

			CMN_API_RestBaseOutboundTestHelper.abortedCall(new List<CMN_WebserviceCallQueue__c> {queueItem});
		}
	}

	/**
	 * @description Check that the service abort if the Workflow case number on the parent case is null
	 *
	 * @see RSC_API_ReclassifyDocument.abortRequest
	 */
	@IsTest
	private static void abortedNoWorkflowCaseNumberOnCase()
	{
		User foundUser = SC_DAL_User.findRandomActiveAgent();
		DocumentChecklistItem checklistItem = createData(foundUser);

		Case caseRecord = SC_DAL_Case.findById(checklistItem.ParentRecordId);
		caseRecord.RSC_WorkflowCaseNumber__c = null;
		CMN_DAL_SObjectDomain.updateDBObject(caseRecord);

		System.runAs(foundUser)
		{
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
					(
							RSC_API_ReclassifyDocument.SERVICE_NAME,
							checklistItem.Id,
							RSC_API_ReclassifyDocument.PARAMETER_DOCUMENT_TYPE,
							checklistItem.DocumentTypeId
					);

			CMN_API_RestBaseOutboundTestHelper.abortedCall(new List<CMN_WebserviceCallQueue__c> {queueItem});
		}
	}

	/**
	 * @description Emulates a failed call and checks that error message is not blank
	 */
	@IsTest
	private static void failedCall()
	{
		User foundUser = SC_DAL_User.findRandomActiveAgent();
		DocumentChecklistItem checklistItem = createData(foundUser);

		System.runAs(foundUser)
		{
			Id documentTypeId = SC_DAL_DocumentType.findRandomActive().Id;

			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
					(
							RSC_API_ReclassifyDocument.SERVICE_NAME,
							checklistItem.Id,
							RSC_API_ReclassifyDocument.PARAMETER_DOCUMENT_TYPE,
							documentTypeId
					);

			Test.startTest();

			CMN_API_HttpBaseOutboundMock.returnErrorResponse = true;

			RSC_API_ReclassifyDocument handler =
					(RSC_API_ReclassifyDocument)CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

			Test.stopTest();

			System.assertEquals(true, handler.callResult.failed, 'Status invalid. Response Call Result JSON: ' + JSON.serialize(handler.callResult));
			System.assertEquals(true, String.isNotBlank(handler.errorMessage), 'Error Message not set correctly');
		}
	}

}