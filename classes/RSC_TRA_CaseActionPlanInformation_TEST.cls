/**
 * @description Test class for RSC_TRA_CaseActionPlanInformation
 *
 * @see RSC_TRA_CaseActionPlanInformation @story ST-146010
 *
 * @author jayanth.kumar.s@accenture.com prashant.k.jain@accenture.com jason.van.beukering@accenture.com
 *
 * @date 2021, April 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class RSC_TRA_CaseActionPlanInformation_TEST
{
	private static final Integer INT_FOUR = 4;
	private static final Integer INT_ONE = 1;
	private static final Integer INT_TWO = 2;
	private static final Integer INT_ZERO = 0;
	private static final String NO_EXPECTED_ITEM_ERROR_MSG = 'Items not created as expected';
	private static final String NO_ITEM_ERROR_MSG = 'Items should not be created';

	/**
	 * @description Create data required for unit tests
	 */
	@TestSetup
	private static void setup()
	{
		AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();

		ActionPlanTemplate newTemplate = RSC_DAL_TestDataFactory.insertActionPlanTemplates(INT_ONE, true, false).iterator().next();
		SC_ServiceType__c newServiceType = SC_DAL_DataFactory.createServiceTypes(INT_ONE).iterator().next();
		newServiceType.RSC_ActionPlanTemplate__c = newTemplate.Id;
		update newServiceType;
	}

	/**
	 * @description method to test whether DocumentChecklistItem on ActionPlanTemplate are inserted
	 */
	@IsTest
	private static void insertCaseWithServiceTypeHavingTemplate()
	{
		Account account = AW_DAL_Account.getAll().iterator().next();

		SC_ServiceType__c newType = SC_DAL_ServiceType.getAll().iterator().next();

		List<Case> newCases = RSC_DAL_TestDataFactory.newCase(INT_TWO, account.Id);

		for(Case newCase : newCases)
		{
			newCase.RSC_ServiceType__c = newType.Id;
			newCase.SC_RequesterType__c = SC_DAL_Case.REQUESTER_TYPE_CUSTOMER;
		}

		Test.startTest();

		insert newCases;

		Test.stopTest();

		List<DocumentChecklistItem> newItem = SC_DAL_DocumentChecklistItem.findByParent(newCases.iterator().next().Id);

		System.assertNotEquals(null, newItem, NO_EXPECTED_ITEM_ERROR_MSG);
		System.assertEquals(INT_TWO, newItem.size(), NO_EXPECTED_ITEM_ERROR_MSG);
	}

	/**
	 * @description method to test whether DocumentChecklistItem is created when case has no serviceType
	 */
	@IsTest
	private static void insertCaseWithoutServiceType()
	{
		Account account = AW_DAL_Account.getAll().iterator().next();

		Case newCase = RSC_DAL_TestDataFactory.newCase(INT_ONE, account.Id).iterator().next();

		Test.startTest();

		insert newCase;

		Test.stopTest();

		List<DocumentChecklistItem> newItem = SC_DAL_DocumentChecklistItem.findByParent(newCase.Id);

		System.assertEquals(INT_ZERO, newItem.size(), NO_ITEM_ERROR_MSG);
	}

	/**
	 * @description method to test whether DocumentChecklistItems are created when serviceType has no ActionPlan Template
	 */
	@IsTest
	private static void insertCaseWithServiceTypeHavingNoTemplate()
	{
		Account account = AW_DAL_Account.getAll().iterator().next();
		SC_ServiceType__c typeWithNoTemplate = SC_DAL_DataFactory.createServiceTypes(INT_ONE).iterator().next();
		Case newCase = RSC_DAL_TestDataFactory.newCase(INT_ONE, account.Id).iterator().next();
		newCase.RSC_ServiceType__c = typeWithNoTemplate.Id;

		Test.startTest();

		insert newCase;

		Test.stopTest();

		List<DocumentChecklistItem> newItem = SC_DAL_DocumentChecklistItem.findByParent(newCase.Id);

		System.assertEquals(INT_ZERO, newItem.size(), NO_ITEM_ERROR_MSG);
	}

	/**
	 * @description method to test whether DocumentChecklistItems are created when template has no items in it
	 */
	@IsTest
	private static void insertCaseWithServiceTypeHavingNoItemsInTemplate()
	{
		Account account = AW_DAL_Account.getAll().iterator().next();
		ActionPlanTemplate newTemplateWithNoItem = RSC_DAL_TestDataFactory.insertActionPlanTemplates(INT_ONE, false, false).iterator().next();

		SC_ServiceType__c typeWithNoItemInTemplate = SC_DAL_DataFactory.createServiceTypes(INT_ONE).iterator().next();
		typeWithNoItemInTemplate.RSC_ActionPlanTemplate__c = newTemplateWithNoItem.Id;

		Case newCase = RSC_DAL_TestDataFactory.newCase(INT_ONE, account.Id).iterator().next();
		newCase.RSC_ServiceType__c = typeWithNoItemInTemplate.Id;

		Test.startTest();

		insert newCase;

		Test.stopTest();

		List<DocumentChecklistItem> newItem = SC_DAL_DocumentChecklistItem.findByParent(newCase.Id);

		System.assertEquals(INT_ZERO, newItem.size(), NO_ITEM_ERROR_MSG);
	}

	/**
	 * @description method to test whether DocumentChecklistItem on ActionPlanTemplate are
	 * inserted when a case is update with new service type associated with action plan template
	 */
	@IsTest
	private static void updateCaseWithNewServiceType()
	{
		Account account = AW_DAL_Account.getAll().iterator().next();
		Case newCase = RSC_DAL_TestDataFactory.newCase(INT_ONE, account.Id).iterator().next();
		insert newCase;
		RSC_DAL_TestDataFactory.insertDocumentCheckListItems(newCase.Id, INT_TWO);

		ActionPlanTemplate newTemplate = RSC_DAL_TestDataFactory.insertActionPlanTemplates(INT_ONE, true, true).iterator().next();
		SC_ServiceType__c newType = SC_DAL_DataFactory.createServiceTypes(INT_ONE).iterator().next();
		newType.RSC_ActionPlanTemplate__c = newTemplate.Id;
		update newType;

		newCase.RSC_ServiceType__c = newType.Id;

		Test.startTest();

		update newCase;

		Test.stopTest();

		List<DocumentChecklistItem> foundCheckListItems = SC_DAL_DocumentChecklistItem.findByParent(newCase.Id);

		System.assertNotEquals(null, foundCheckListItems, NO_EXPECTED_ITEM_ERROR_MSG);
		System.assertEquals(INT_FOUR, foundCheckListItems.size(), NO_EXPECTED_ITEM_ERROR_MSG);
	}
}