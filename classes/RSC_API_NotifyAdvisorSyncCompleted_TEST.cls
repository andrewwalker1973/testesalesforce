/**
 * @description Will test the inbound service class RSC_API_NotifyAdvisorSyncCompleted
 *
 * @see RSC_API_NotifyAdvisorSyncCompleted @226578
 * @see RSC_URL_NotifyAdvisorSyncCompleted
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date December 2021, February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class RSC_API_NotifyAdvisorSyncCompleted_TEST
{
	private static final Integer INT_ONE = 1;
	private static final Integer INT_TWO = 2;
	private static final String CONSULTANTS_SHOULD_BE_UPDATED = 'Consultants should be updated';
	private static final String CONSULTANTS_SHOULD_NOT_UPDATED = 'Consultants should not be updated';

	/**
	 * @description Create data required for the unit test
	 */
	@TestSetup
	private static void setup()
	{
		RSC_DAL_TestDataFactory.createPracticeContacts(SC_DAL_Contact.RT_ADVISER, INT_ONE, null).iterator().next();
	}

	/**
	 * @description Will check if contacts not modified today are de-activated
	 */
	@IsTest
	private static void checkForConsultantsNotModifiedToday()
	{
		Id newContactId = SC_DAL_Contact.getAll().iterator().next().Id;

		List<SC_ConsultantCodes__c> newActiveConsultantCodes = RSC_DAL_TestDataFactory.newConsultantCodeRecords(
				newContactId, INT_TWO, true
		);

		List<SC_ConsultantCodes__c> newConsultantsToInsert = new List<SC_ConsultantCodes__c>();
		for(SC_ConsultantCodes__c newConsultant : newActiveConsultantCodes)
		{
			newConsultant.CreatedDate = System.today() - 1;
			newConsultant.LastModifiedDate = System.today() - 1;
			newConsultantsToInsert.add(newConsultant);
		}

		insert newConsultantsToInsert;

		RSC_API_NotifyAdvisorSyncCompleted.DTO_Request dtoRequest = populateDtoRequestData();
		setupRestContextAndExecuteService(dtoRequest);

		Set<Id> consultantIds = CMN_UTIL_System.extractListIds(newConsultantsToInsert);

		newConsultantsToInsert = SC_DAL_ConsultantCodes.findById(consultantIds);

		for(SC_ConsultantCodes__c newConsultant : newConsultantsToInsert)
		{
			System.assertEquals(false, newConsultant.SC_AgreementStatus__c, CONSULTANTS_SHOULD_BE_UPDATED);
		}

	}

	/**
	 * @description Will check if new contacts created are not terminated
	 */
	@IsTest
	private static void checkForNewConsultants()
	{
		List<SC_ConsultantCodes__c> newConsultantCodeRecords = RSC_DAL_TestDataFactory.insertConsultantCode(
				SC_DAL_Contact.getAll().iterator().next().Id, INT_TWO, true
		);
		RSC_API_NotifyAdvisorSyncCompleted.DTO_Request dtoRequest = populateDtoRequestData();
		setupRestContextAndExecuteService(dtoRequest);

		for(SC_ConsultantCodes__c newConsultant : newConsultantCodeRecords)
		{
			System.assertEquals(true, newConsultant.SC_AgreementStatus__c, CONSULTANTS_SHOULD_NOT_UPDATED);
		}
	}

	/**
	 * @description Will setup the RestContext & execute the service
	 *
	 * @param dtoRequest The DTO that represents the JSON sent in a request
	 */
	private static void setupRestContextAndExecuteService(RSC_API_NotifyAdvisorSyncCompleted.DTO_Request dtoRequest)
	{
		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		RSC_URL_NotifyAdvisorSyncCompleted.notifyAdvisorSyncCompleted();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(RSC_API_NotifyAdvisorSyncCompleted.SERVICE_NAME);
	}

	/**
	 * @description Will populate the dtoRequest data
	 *
	 * @return the DTO_Request
	 */
	private static RSC_API_NotifyAdvisorSyncCompleted.DTO_Request populateDtoRequestData()
	{
		RSC_API_NotifyAdvisorSyncCompleted.DTO_Request dtoRequest = new RSC_API_NotifyAdvisorSyncCompleted.DTO_Request();
		dtoRequest.notifyMessage = RSC_API_NotifyAdvisorSyncCompleted.SYNC_FINISHED;
		return dtoRequest;
	}
}