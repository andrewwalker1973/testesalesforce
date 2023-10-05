/**
 * @description Test class for CMN_TRA_CommunicationLog
 *
 * @see CMN_TRA_CommunicationLog @story ST-322854
 *
 * @author aakriti.a.goyal@accenture.com
 *
 * @date July 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_TRA_CommunicationLog_TEST
{
	private static final Integer INT_ONE = 1;
	private static final Integer INT_TWO = 2;

	/**
	 * @description Create data required for unit tests
	 */
	@TestSetup
	private static void setup()
	{
		Account account = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();

		SC_ServiceType__c newServiceType = SC_DAL_DataFactory.createServiceTypesWithAssignableValue(INT_ONE, true).iterator().next();
		List<Case> newCases = RSC_DAL_TestDataFactory.newCase(INT_TWO, account.Id);
		for(Case newCase : newCases)
		{
			newCase.RSC_ServiceType__c = newServiceType.Id;
		}

		insert newCases;

		CMN_CommunicationTemplateMap__mdt foundTemplateMap =
				CMN_DAL_CommunicationTemplateMap.findByName(CMN_DAL_CommunicationTemplateMap.TEMPLATE_OUTSTANDING_REQUIREMENTS);

		// Insert Communication Template Record
		CMN_CommunicationTemplate__c newTemplate = CMN_DAL_DataFactory.newCommunicationTemplate
				(
						SC_DAL_OutstandingDocumentSelector.SELECTOR_CLASS_NAME,
						SC_API_SendCommunication.SERVICE_NAME
				);

		newTemplate.CMN_Code__c = foundTemplateMap.CMN_TemplateCode__c;
		insert newTemplate;

		// Insert communication Log Records
		List<CMN_CommunicationLog__c> newLogs = new List<CMN_CommunicationLog__c>();
		for(Case newCase : newCases)
		{
			CMN_CommunicationLog__c newLog = RSC_DAL_TestDataFactory.newCommunicationLog(INT_ONE, newCase.Id).iterator().next();
			newLog.CMN_CommunicationTemplate__c = newTemplate.Id;
			newLog.CMN_SendReminder__c = true;
			newLogs.add(newLog);
		}
		insert newLogs;

	}

	/**
	 * @description method to test whether send reminder flag was set as false on existing communication log records
	 * if new communication logs are created to send reminders.
	 */
	@IsTest
	private static void insertCommunicationLogToSendReminder()
	{
		Set<Id> existingLogIds = createCommunicationLogs(true);
		List<CMN_CommunicationLog__c> updatedLogs = CMN_DAL_CommunicationLog.getAll();

		for(CMN_CommunicationLog__c updatedLog : updatedLogs)
		{
			System.assertEquals(!existingLogIds.contains(updatedLog.Id), updatedLog.CMN_SendReminder__c, 'Send Reminder flag was not updated properly');
		}
	}

	/**
	 * @description method to test the send reminder flag should not be set as false on existing communication log records
	 * if new communication logs are not created to send reminders.
	 */
	@IsTest
	private static void insertCommunicationLogForNoReminder()
	{
		Set<Id> existingLogIds = createCommunicationLogs(false);
		List<CMN_CommunicationLog__c> updatedLogs = CMN_DAL_CommunicationLog.getAll();

		for(CMN_CommunicationLog__c updatedLog : updatedLogs)
		{
			System.assertEquals(existingLogIds.contains(updatedLog.Id), updatedLog.CMN_SendReminder__c, 'Send Reminder flag should not be updated on existing logs');
		}
	}

	/**
	 * @description method to insert the communication log records for various scenarios
	 *
	 * @param sendReminder Boolean variable to indicate if reminder to be sent or not
	 *
	 * @return list of existing log ids
	 */
	private static Set<Id> createCommunicationLogs(Boolean sendReminder)
	{
		List<Case> foundCases = SC_DAL_Case.getAll();
		CMN_CommunicationTemplate__c foundTemplate = CMN_DAL_CommunicationTemplate.getAll().iterator().next();
		Set<Id> existingLogIds = CMN_UTIL_System.extractListIds(CMN_DAL_CommunicationLog.getAll());

		List<CMN_CommunicationLog__c> newLogs = new List<CMN_CommunicationLog__c>();
		for(Case existingCase : foundCases)
		{
			CMN_CommunicationLog__c newLog = RSC_DAL_TestDataFactory.newCommunicationLog(INT_ONE, existingCase.Id).iterator().next();
			newLog.CMN_CommunicationTemplate__c = foundTemplate.Id;
			newLog.CMN_SendReminder__c = sendReminder;
			newLogs.add(newLog);
		}

		Test.startTest();

		insert newLogs;

		Test.stopTest();

		return existingLogIds;
	}
}