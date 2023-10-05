/**
 * @description Test class for RSC_CTRL_CaseExtensionDetails
 *
 * @see RSC_CTRL_CaseExtensionDetails @story US-316918
 *
 * @author vikrant.goswami@accenture.com
 *
 * @date July 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class RSC_CTRL_CaseExtensionDetails_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description Create data required for unit tests
	 */
	@TestSetup
	private static void setup()
	{
		AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		SC_DAL_DataFactory.insertCaseExtensions(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		SC_ServiceType__c newServiceType = SC_DAL_DataFactory.createServiceTypesWithAssignableValue(NUMBER_OF_ITEMS_TO_CREATE, true).iterator().next();
		newServiceType.RSC_CaseExtensionFieldSet__c = SC_DAL_CaseExtension.FIELDSET_UNPAID_DEBIT_ORDER;
		update newServiceType;
	}

	@IsTest
	private static void getCaseExtensionDetails()
	{
		Account foundAccount = SC_DAL_Account.getAll().iterator().next();
		SC_ServiceType__c foundServiceType = SC_DAL_ServiceType.getAll().iterator().next();
		SC_CaseExtension__c foundCaseExtension = SC_DAL_CaseExtension.getAll().iterator().next();
		User foundAgent = SC_DAL_User.findRandomActiveAgent();
		Case newCase = SC_DAL_DataFactory.newCase(foundAccount.Id);
		newCase.RSC_ServiceType__c = foundServiceType.Id;
		newCase.SC_CaseExtension__c = foundCaseExtension.Id;
		newCase.OwnerId = foundAgent.Id;
		insert newCase;

		RSC_CTRL_CaseExtensionDetails.DTO_CaseExtensionDetails dtoCaseExtensionDetails;

		Test.startTest();
		System.runAs(foundAgent)
		{
			dtoCaseExtensionDetails = RSC_CTRL_CaseExtensionDetails.getCaseExtensionDetails(newCase.Id);
		}
		Test.stopTest();

		System.assertEquals(foundCaseExtension.Id, dtoCaseExtensionDetails.caseExtensionId, 'Related case extension not found.');
		System.assertEquals(foundServiceType.RSC_CaseExtensionFieldSet__c,
				dtoCaseExtensionDetails.fieldSetNames.iterator().next(), 'Expected fieldset name not found.');
	}
}