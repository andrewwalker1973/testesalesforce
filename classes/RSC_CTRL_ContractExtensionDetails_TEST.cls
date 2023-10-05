/**
 * @description Test class for RSC_CTRL_ContractExtensionDetails
 *
 * @see RSC_CTRL_ContractExtensionDetails
 *
 * @author vikrant.goswami@accenture.com  @story 320305
 *
 * @date July 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class RSC_CTRL_ContractExtensionDetails_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	@TestSetup
	private static void setup()
	{
		AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		SC_ServiceType__c newServiceType = SC_DAL_DataFactory.createServiceTypesWithAssignableValue(NUMBER_OF_ITEMS_TO_CREATE, true).iterator().next();
		newServiceType.RSC_AssociatedContractExtensionFieldSet__c = SC_DAL_AssociatedContractExtension.FIELDSET_UNPAID_DEBIT_ORDER;
		SC_DAL_DataFactory.insertAssociatedContractExtensions(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		update newServiceType;
	}

	@IsTest
	private static void getContractExtensionDetails()
	{
		Account foundAccount = SC_DAL_Account.getAll().iterator().next();
		SC_ServiceType__c foundServiceType = SC_DAL_ServiceType.getAll().iterator().next();
		SC_AssociatedContractExtension__c foundContractExtension = SC_DAL_AssociatedContractExtension.getAll().iterator().next();
		User foundAgent = SC_DAL_User.findRandomActiveAgent();
		Case newCase = SC_DAL_DataFactory.newCase(foundAccount.Id);
		newCase.RSC_ServiceType__c = foundServiceType.Id;
		newCase.OwnerId = foundAgent.Id;
		insert newCase;
		SC_AssociatedContract__c newAssociatedContract = SC_DAL_DataFactory.insertAssociatedContracts(newCase.Id, NUMBER_OF_ITEMS_TO_CREATE, null,
				SC_DAL_DataFactory.createInsurancePolicies(NUMBER_OF_ITEMS_TO_CREATE, foundAccount.Id).iterator().next().Id).iterator().next();
		newAssociatedContract.SC_AssociatedContractExtension__c = foundContractExtension.Id;
		update newAssociatedContract;

		RSC_CTRL_ContractExtensionDetails.DTO_ContractExtensionDetails dtoContractExtensionDetails;

		Test.startTest();
		System.runAs(foundAgent)
		{
			dtoContractExtensionDetails = RSC_CTRL_ContractExtensionDetails.getContractExtensionDetails(newAssociatedContract.Id);
		}
		Test.stopTest();

		System.assertEquals(foundContractExtension.Id, dtoContractExtensionDetails.contractExtensionId, 'Related contract extension not found.');
		System.assertEquals(foundServiceType.RSC_AssociatedContractExtensionFieldSet__c, dtoContractExtensionDetails.fieldSetNames.iterator().next(),
				'Expected fieldset name not found.');

	}
}