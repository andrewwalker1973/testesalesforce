/**
 * @description Test class for RSC_API_UploadDocumentToVault
 *
 * @see RSC_API_UploadDocumentToVault @story 146092
 *
 * @author aakriti.a.goyal@accenture.com rajpal.singh@accenture.com
 *
 * @date August 2021, July 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private inherited sharing class RSC_API_UploadDocumentToVault_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description Create data required for the unit test
	 *
	 * @param aUser the user with which data should be created
	 *
	 * @return a newly inserted item
	 */
	private static DocumentChecklistItem createData(User aUser)
	{
		Account personMasterAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();

		Account newAccount = new Account();
		newAccount.Id = personMasterAccount.Id;
		newAccount.OwnerId = aUser.Id;
		update newAccount;

		DocumentChecklistItem checklistItem;
		SC_ServiceType__c newServiceType = SC_DAL_DataFactory.createServiceTypesWithAssignableValue(NUMBER_OF_ITEMS_TO_CREATE, true).iterator().next();
		System.runAs(aUser)
		{
			Case caseRecord = SC_DAL_DataFactory.newCase(personMasterAccount.Id);
			caseRecord.RSC_ServiceType__c = newServiceType.Id;
			insert caseRecord;

			checklistItem =  SC_DAL_DataFactory.newDocumentCheckListItems(caseRecord.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
			checklistItem.OwnerId = aUser.Id;
			insert checklistItem;
		}

		return checklistItem;
	}
	/**
	 * @description Emulates a successful call and confirms DocumentChecklistITem vaulted fields were correctly set
	 */
	@IsTest
	private static void successfulCall()
	{
		User foundUser = SC_DAL_User.findRandomActiveAgent();
		DocumentChecklistItem checklistItem = createData(foundUser);

		System.runAs(foundUser)
		{
			RSC_DAL_TestDataFactory.createNewContentVersion(NUMBER_OF_ITEMS_TO_CREATE, checklistItem.Id);
			CMN_API_RestBaseOutboundTestHelper.successfulCall(RSC_API_UploadDocumentToVault.SERVICE_NAME, checklistItem.Id);
			System.assertEquals(true, checklistItem.AW_Vaulted__c, 'Vaulted check-box is not checked');
		}
	}

	/**
	 * @description Check that the service abort if the Case is not linked to the documentChecklistItem
	 *
	 * @see RSC_API_UploadDocumentToVault.abortRequest
	 */
	@IsTest
	private static void abortedCallForWrongParentId()
	{
		Account newAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		DocumentChecklistItem checklistItem = SC_DAL_DataFactory.insertDocumentCheckListItems(newAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		RSC_DAL_TestDataFactory.createNewContentVersion(NUMBER_OF_ITEMS_TO_CREATE, checklistItem.Id);

		CMN_API_RestBaseOutboundTestHelper.abortedCall(RSC_API_UploadDocumentToVault.SERVICE_NAME, checklistItem.Id);
	}

	/**
	 * @description Check that the service abort if the ContentVersion is not linked to the documentChecklistItem
	 *
	 * @see RSC_API_UploadDocumentToVault.abortRequest
	 */
	@IsTest
	private static void abortedCallForNoContentVersion()
	{
		Account newAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		DocumentChecklistItem checklistItem = SC_DAL_DataFactory.insertDocumentCheckListItems(newAccount.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		CMN_API_RestBaseOutboundTestHelper.abortedCall(RSC_API_UploadDocumentToVault.SERVICE_NAME, checklistItem.Id);
	}

	/**
	 * @description Check that the service abort if the Id provided does not find a documentChecklistItem
	 *
	 * @see RSC_API_UploadDocumentToVault.abortRequest
	 */
	@IsTest
	private static void abortedCallNoItemFound()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(RSC_API_UploadDocumentToVault.SERVICE_NAME, UserInfo.getUserId());
	}

	/**
	 * @description Check that the service abort if the User uploading the file does not have a UACFID
	 *
	 * @see RSC_API_UploadDocumentToVault.abortRequest
	 */
	@IsTest
	private static void abortedCallForBlankUACFID()
	{
		User foundUser = SC_DAL_User.findRandomActiveAgent();
		DocumentChecklistItem checklistItem = createData(foundUser);

		foundUser.AW_UACFID__c = CMN_UTIL_String.EMPTY;
		CMN_DAL_SObjectDomain.updateDBObject(foundUser);

		System.runAs(foundUser)
		{
			RSC_DAL_TestDataFactory.createNewContentVersion(NUMBER_OF_ITEMS_TO_CREATE, checklistItem.Id);
			CMN_API_RestBaseOutboundTestHelper.abortedCall(RSC_API_UploadDocumentToVault.SERVICE_NAME, checklistItem.Id);
		}
	}

	/**
	 * @description Emulates a successful call and confirms DocumentChecklistITem vaulted fields were correctly set
	 */
	@IsTest
	private static void successfulCallCaseOnBusinessAccount()
	{
		Account businessMasterAccount =
				RSC_DAL_TestDataFactory.createBusinessAccounts(AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		SC_ServiceType__c newServiceType = SC_DAL_DataFactory.createServiceTypesWithAssignableValue(NUMBER_OF_ITEMS_TO_CREATE, true).iterator().next();

		User foundUser = SC_DAL_User.findRandomActiveAgent();
		businessMasterAccount.OwnerId = foundUser.Id;
		update businessMasterAccount;

		DocumentChecklistItem checklistItem;

		System.runAs(foundUser)
		{
			Case caseRecord = SC_DAL_DataFactory.newCase(businessMasterAccount.Id);
			caseRecord.RSC_ServiceType__c = newServiceType.Id;
			insert caseRecord;

			checklistItem =  SC_DAL_DataFactory.newDocumentCheckListItems(caseRecord.Id, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
			checklistItem.OwnerId = foundUser.Id;
			insert checklistItem;

			RSC_DAL_TestDataFactory.createNewContentVersion(NUMBER_OF_ITEMS_TO_CREATE, checklistItem.Id);
			CMN_API_RestBaseOutboundTestHelper.successfulCall(RSC_API_UploadDocumentToVault.SERVICE_NAME, checklistItem.Id);

			System.assertEquals(true, checklistItem.AW_Vaulted__c, 'Vaulted check-box is not checked');
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
			RSC_DAL_TestDataFactory.createNewContentVersion(NUMBER_OF_ITEMS_TO_CREATE, checklistItem.Id);
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
					(
							RSC_API_UploadDocumentToVault.SERVICE_NAME,
							checklistItem.Id
					);

			Test.startTest();

			CMN_API_HttpBaseOutboundMock.returnErrorResponse = true;

			RSC_API_UploadDocumentToVault handler =
					(RSC_API_UploadDocumentToVault)CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

			Test.stopTest();

			System.assertEquals(true, handler.callResult.failed, 'Status invalid. Response Call Result JSON: ' + JSON.serialize(handler.callResult));
		}
	}
}