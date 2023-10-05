/**
 * @description Test class related to the RSC_CTRL_CloneCaseWithFieldSet
 *
 * @see RSC_CTRL_CloneCaseWithFieldSet @story ST-141793, ST-348797
 *
 * @author  jason.van.beukering@accenture.com,vijay.jayswal@accenture.com
 *
 * @date September 2022, January 2023, March 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=false)
private class RSC_CTRL_CloneCaseWithFieldSet_TEST
{
	private static final Integer INT_TWO = 2;
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;
	private static final String ERROR_NO_MEMBERS_RETURNED = 'No fieldset members returned.';
	private static final String NON_ASSIGNABLE_QUEUE = 'Cases Not Available For Assignment';

	/**
	 * @description Create data required for unit tests
	 */
	@TestSetup
	private static void setup()
	{
		Account personMasterAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		Case newCase = SC_DAL_DataFactory.createCase(NUMBER_OF_ITEMS_TO_CREATE, personMasterAccount.Id).iterator().next();
		SC_DAL_DataFactory.insertDocumentCheckListItems(newCase.Id, INT_TWO);

		InsurancePolicy newPolicy = SC_DAL_DataFactory.createInsurancePolicies(NUMBER_OF_ITEMS_TO_CREATE, personMasterAccount.Id).iterator().next();
		newPolicy.AW_MasterAccount__c = personMasterAccount.Id;

		FinServ__FinancialAccount__c newFinancialAccount =
				AW_DAL_TestDataFactory.createFinancialAccounts(personMasterAccount, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		newFinancialAccount.AW_MasterAccount__c = personMasterAccount.Id;

		CMN_DAL_SObjectDomain.updateDBObjects(new List<SObject>
		{
				newPolicy, newFinancialAccount
		});
		SC_DAL_DataFactory.insertAssociatedContracts(newCase.Id, NUMBER_OF_ITEMS_TO_CREATE, newFinancialAccount.Id, null);
		SC_DAL_DataFactory.insertAssociatedContracts(newCase.Id, NUMBER_OF_ITEMS_TO_CREATE, null, newPolicy.Id);
	}

	/**
	 * @description Will check if all of the fields are retrieved from the field set for a new case
	 *
	 * @see RSC_CTRL_CloneCaseWithFieldSet.getFieldSetMember
	 */
	@IsTest
	private static void getFieldSetMember()
	{
		Test.startTest();

		List<CMN_CTRL_FieldSet.DTO_FieldSetMember> dtoFieldSetMembers = RSC_CTRL_CloneCaseWithFieldSet.getFieldSetMember(null);

		Test.stopTest();

		assertMembersNotEmpty(dtoFieldSetMembers);
	}

	private static void assertMembersNotEmpty(List<CMN_CTRL_FieldSet.DTO_FieldSetMember> fields)
	{
		Assert.isFalse(fields.isEmpty(), ERROR_NO_MEMBERS_RETURNED);
	}

	/**
	 * @description Will check if all of the fields are retrieved from the field set for a new case when caseId is not null
	 *
	 * @see RSC_CTRL_CloneCaseWithFieldSet.getFieldSetMember
	 */
	@IsTest
	private static void getFieldSetMemberForCase()
	{
		Case newCase = SC_DAL_Case.getAll().iterator().next();
		Test.startTest();

		List<CMN_CTRL_FieldSet.DTO_FieldSetMember> dtoFieldSetMembers = RSC_CTRL_CloneCaseWithFieldSet.getFieldSetMember(newCase.Id);

		Test.stopTest();

		assertMembersNotEmpty(dtoFieldSetMembers);
	}

	/**
	 * @description to check cloning a case with parent case
	 *
	 * @see RSC_CTRL_CloneCaseWithFieldSet.cloneRecord
	 */
	@IsTest
	private static void cloneRecord()
	{
		SC_ServiceType__c newServiceType = SC_DAL_DataFactory.createServiceTypes(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		Id actionPlanTemplateId = RSC_DAL_TestDataFactory.insertActionPlanTemplates(NUMBER_OF_ITEMS_TO_CREATE, true, false).iterator().next().Id;
		newServiceType.RSC_ActionPlanTemplate__c = actionPlanTemplateId;
		update newServiceType;
		System.assertEquals(actionPlanTemplateId, newServiceType.RSC_ActionPlanTemplate__c);

		Account foundAccount = AW_DAL_Account.getAll().iterator().next();
		Case existingCase = RSC_DAL_TestDataFactory.newCase(NUMBER_OF_ITEMS_TO_CREATE, foundAccount.Id).iterator().next();
		existingCase.RSC_IsRelated__c = true;
		existingCase.RSC_ServiceType__c = newServiceType.Id;
		existingCase.RSC_Department__c = newServiceType.SC_Department__c;
		existingCase.SC_RequesterPhone__c = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		existingCase.SC_RequesterEmail__c = CMN_DAL_SObjectDomain.generateRandomEmail();
		existingCase.Status = SC_DAL_Case.STATUS_IN_PROGRESS;
		insert existingCase;

		InsurancePolicy foundPolicy = SC_DAL_InsurancePolicy.getAll().iterator().next();
		FinServ__FinancialAccount__c foundFinancialAccount = SC_DAL_FinancialAccount.getAll().iterator().next();
		List<DocumentChecklistItem> checklistItems = SC_DAL_DocumentChecklistItem.findByParent(existingCase.Id);
		System.assertNotEquals(0, checklistItems.size(), 'Checklist items not found.');

		checklistItems.add(checklistItems.iterator().next().clone(false));
		checklistItems.addAll(SC_DAL_DataFactory.insertDocumentCheckListItems(existingCase.Id, INT_TWO));

		Id newCaseId;

		/*As criteria based sharing rules cannot be accommodated in test class & can not make the agent as the owner of the document checklist item records,
		 ignoring the test to run as an agent.*/
		Test.startTest();
			newCaseId = RSC_CTRL_CloneCaseWithFieldSet.cloneRecord(existingCase, new List<Id> {foundPolicy.Id, foundFinancialAccount.Id}, checklistItems, true);
		Test.stopTest();

		System.assertNotEquals(null, newCaseId, 'Case not cloned');

		Case foundCase = SC_DAL_Case.findById(newCaseId);
		System.assertEquals(foundCase.RSC_ServiceType__c, newServiceType.Id, 'Case not cloned with expected serviceType');
		System.assertEquals(foundCase.RSC_IsRelated__c, true, 'Case not cloned with expected relation');
		System.assertEquals(foundCase.Status, SC_DAL_Case.STATUS_IN_PROGRESS, 'Case not cloned with expected status');
		System.assertEquals(foundCase.AccountId, foundAccount.Id, 'Case not cloned with expected Account');
		System.assertEquals(foundCase.RSC_Department__c, newServiceType.SC_Department__c, 'Case not cloned with expected Department');

		List<SC_AssociatedContract__c> contracts = SC_DAL_AssociatedContract.findByParent(newCaseId);
		System.assertEquals(INT_TWO, contracts.size(), 'Policies were not processed successfully.');
	}

	/**
	 * @description to check cloning a case with parent case
	 *
	 * @see RSC_CTRL_CloneCaseWithFieldSet.cloneRecord
	 */
	@IsTest
	private static void cloneRecordDocumentsException()
	{
		SC_ServiceType__c newServiceType = SC_DAL_DataFactory.createServiceTypes(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		Account foundAccount = AW_DAL_Account.getAll().iterator().next();

		Case existingCase = RSC_DAL_TestDataFactory.newCase(NUMBER_OF_ITEMS_TO_CREATE, foundAccount.Id).iterator().next();
		existingCase.RSC_IsRelated__c = true;
		existingCase.RSC_ServiceType__c = newServiceType.Id;
		existingCase.RSC_Department__c = newServiceType.SC_Department__c;
		existingCase.SC_RequesterPhone__c = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		existingCase.SC_RequesterEmail__c = CMN_DAL_SObjectDomain.generateRandomEmail();
		existingCase.Status = SC_DAL_Case.STATUS_IN_PROGRESS;

		insert existingCase;

		List<DocumentChecklistItem> checklistItems = new List<DocumentChecklistItem> {null};

		User foundAgent = SC_DAL_User.findRandomActiveAgent();

		Test.startTest();

		System.runAs(foundAgent)
		{
			try
			{
				RSC_CTRL_CloneCaseWithFieldSet.cloneRecord(existingCase, new List<Id>(), checklistItems, true);
				System.assert(false, 'Exception NOT thrown as expected');
			}
			catch(Exception e)
			{
				System.assert(true, 'Exception thrown as expected');
			}
		}
		Test.stopTest();
	}

	/**
	 * @description to check cloning a case with parent case
	 *
	 * @see RSC_CTRL_CloneCaseWithFieldSet.cloneRecord
	 */
	@IsTest
	private static void createRecord()
	{
		SC_ServiceType__c newServiceType = SC_DAL_DataFactory.createServiceTypes(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		Account foundAccount = AW_DAL_Account.getAll().iterator().next();

		Case existingCase = RSC_DAL_TestDataFactory.newCase(NUMBER_OF_ITEMS_TO_CREATE, foundAccount.Id).iterator().next();
		existingCase.RSC_IsRelated__c = true;
		existingCase.RSC_ServiceType__c = newServiceType.Id;
		existingCase.RSC_Department__c = newServiceType.SC_Department__c;
		existingCase.SC_RequesterPhone__c = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		existingCase.SC_RequesterEmail__c = CMN_DAL_SObjectDomain.generateRandomEmail();
		existingCase.Status = SC_DAL_Case.STATUS_IN_PROGRESS;
		existingCase.SC_AssignedTo__c = null;

		InsurancePolicy foundPolicy = SC_DAL_InsurancePolicy.getAll().iterator().next();
		FinServ__FinancialAccount__c foundFinancialAccount = SC_DAL_FinancialAccount.getAll().iterator().next();

		User foundAgent = SC_DAL_User.findRandomActiveAgent();

		Test.startTest();

		String newCaseId;

		System.runAs(foundAgent)
		{
			newCaseId = RSC_CTRL_CloneCaseWithFieldSet.createCase(existingCase, new List<Id> {foundPolicy.Id, foundFinancialAccount.Id});
		}

		Test.stopTest();

		System.assertNotEquals(null, newCaseId, 'Case not created');

		Case foundCase = SC_DAL_Case.findById(newCaseId);

		System.assertEquals(foundCase.RSC_ServiceType__c, newServiceType.Id, 'Case not cloned with expected serviceType');
		System.assertEquals(foundCase.RSC_IsRelated__c, true, 'Case not cloned with expected relation');
		System.assertEquals(foundCase.Status, SC_DAL_Case.STATUS_IN_PROGRESS, 'Case not cloned with expected status');
		System.assertEquals(foundCase.AccountId, foundAccount.Id, 'Case not cloned with expected Account');
		System.assertEquals(foundCase.RSC_Department__c, newServiceType.SC_Department__c, 'Case not cloned with expected Department');

		List<SC_AssociatedContract__c> contracts = SC_DAL_AssociatedContract.findByParent(newCaseId);
		System.assertEquals(INT_TWO, contracts.size(), 'Policies were not processed successfully.');
	}

	/**
	 * @description method to get DocumentChecklistItems by parent Id
	 *
	 * @see RSC_CTRL_CloneCaseWithFieldSet.getDocuments
	 */
	@IsTest
	private static void getCheckListItemByParent()
	{
		List<DocumentChecklistItem> newItem = AW_DAL_DocumentChecklistItem.getAll();

		Test.startTest();

		for(DocumentChecklistItem newDocumentItem : newItem)
		{
			List<DocumentChecklistItem> newItems = RSC_CTRL_CloneCaseWithFieldSet.getDocuments(newDocumentItem.ParentRecordId);
			System.assertEquals(false, newItems.isEmpty(), 'No check list items found.');
		}

		Test.stopTest();
	}

	/**
	 * @description to check the case owner when Assigned To Me checkbox is true or false when creating / cloning a case
	 *
	 * @param isCreate Boolean to check if its create case / clone case scenario
	 * @param isServiceable Boolean to check if the Case is serviceable in salesforce 
	 *
	 * @see RSC_CTRL_CloneCaseWithFieldSet.createCase
	 */
	private static void checkOwnerForCase(Boolean isCreate, Boolean isServiceable)
	{
		SC_ServiceType__c newServiceType = isServiceable ? SC_DAL_DataFactory.createServiceTypesWithAssignableValue(NUMBER_OF_ITEMS_TO_CREATE, true).iterator().next()
				: SC_DAL_DataFactory.createServiceTypes(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();

		User foundAgent = SC_DAL_User.findRandomActiveAgent();

		Account foundAccount = AW_DAL_Account.getAll().iterator().next();
		Case caseRecord = RSC_DAL_TestDataFactory.newCase(NUMBER_OF_ITEMS_TO_CREATE, foundAccount.Id).iterator().next();
		caseRecord.RSC_ServiceType__c = newServiceType.Id;
		caseRecord.RSC_Department__c = newServiceType.SC_Department__c;
		caseRecord.SC_RequesterPhone__c = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		caseRecord.SC_RequesterEmail__c = CMN_DAL_SObjectDomain.generateRandomEmail();
		caseRecord.Status = isServiceable ? SC_DAL_Case.STATUS_IN_PROGRESS : SC_DAL_Case.STATUS_NEW;
		caseRecord.SC_AssignedTo__c = isServiceable ? foundAgent.Id : null;

		String newCaseId;

		if(isCreate)
		{
			RSC_CTRL_CloneCaseWithFieldSet.getAssignableCaseQueueId(newServiceType.Id);
			newCaseId = RSC_CTRL_CloneCaseWithFieldSet.createCase(caseRecord, null);
		}
		else
		{
			newCaseId = RSC_CTRL_CloneCaseWithFieldSet.cloneRecord(caseRecord, null, null, false);
		}

		Case foundCase = SC_DAL_Case.findById(newCaseId);

		if(isServiceable)
		{
			System.assertEquals(UserInfo.getUserId(), foundCase.OwnerId, 'Case owner mismatch');
		}
		else
		{
			Group foundGroup = AW_DAL_Group.findById(foundCase.OwnerId);
			System.assertNotEquals(UserInfo.getUserId(), foundCase.OwnerId, 'Case owner mismatch');
			System.assertEquals(NON_ASSIGNABLE_QUEUE, foundGroup.Name, 'Case owner mismatch');
		}

	}

	/**
	 * @description to check the case owner when creating a serviceable case
	 */
	@IsTest
	private static void checkOwnerForNewServiceableCase()
	{
		checkOwnerForCase(true, true);
	}

	/**
	 * @description to check the case owner when creating a non serviceable case
	 *
	 * @see RSC_CTRL_CloneCaseWithFieldSet.createCase
	 */
	@IsTest
	private static void checkOwnerForNewNonServiceableCase()
	{
		checkOwnerForCase(true, false);
	}

	/**
	 * @description to check the case owner when cloning a serviceable case
	 */
	@IsTest
	private static void checkOwnerForCloneServiceableCase()
	{
		checkOwnerForCase(false, true);
	}

	/**
	 * @description to check the case owner when cloning a non serviceable case
	 */
	@IsTest
	private static void checkOwnerForCloneNonServiceableCase()
	{
		checkOwnerForCase(false, false);
	}

	/**
	 * @description Will check is service type record available with the field set name to get list field set.
	 *
	 * @see RSC_CTRL_CloneCaseWithFieldSet.getServiceTypeRecord
	 */
	@IsTest
	private static void getServiceTypeRecord()
	{

		SC_ServiceType__c serviceType =SC_DAL_DataFactory.createServiceTypes(NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		Test.startTest();
		SC_ServiceType__c getServiceType =RSC_CTRL_CloneCaseWithFieldSet.getServiceTypeRecord(serviceType.Id);
		Test.stopTest();
		Assert.isFalse(getServiceType.SC_Assignable__c, 'no service type record is assignable .');


	}
	/**
	 * @description Will check if all of the fields are retrieved from the field set for a new case
	 *
	 * @see RSC_CTRL_CloneCaseWithFieldSet.getFieldSetMember
	 */
	@IsTest
	private static void getAdditionalSectionFieldSet()
	{
		Map<String,List<String>> mapOfFieldSetObject = new Map<String,List<String>>();
		List<String> fieldSetNames = new List<String>();
		fieldSetNames.add(SC_DAL_CaseExtension.FIELDSET_POLICY_OWNER_DETAILS);
		mapOfFieldSetObject.put(SC_DAL_CaseExtension.OBJECT_NAME,fieldSetNames);
		Test.startTest();

		List<CMN_CTRL_FieldSet.DTO_FieldSetMember> dtoFieldSetMembers = RSC_CTRL_CloneCaseWithFieldSet.getAdditionalSectionFieldSet(mapOfFieldSetObject);

		Test.stopTest();

		assertMembersNotEmpty(dtoFieldSetMembers);
	}
}