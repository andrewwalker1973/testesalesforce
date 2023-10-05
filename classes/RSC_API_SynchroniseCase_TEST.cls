/**
 * @description Test class for RSC_API_SynchroniseCase
 *
 * @see RSC_API_SynchroniseCase @story ST-145998
 *
 * @author jason.van.beukering@accenture.com, jayanth.kumar.s@accenture.com
 *
 * @date September 2022, July 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=false)
private class RSC_API_SynchroniseCase_TEST
{
	private static final Integer INT_TWO = 2;
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description Create data required for the unit test
	 */
	@TestSetup
	private static void setup()
	{
		Account account = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
		AW_DAL_TestDataFactory.createFinancialAccounts(account, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		AW_DAL_TestDataFactory.createInsurancePolicies(account, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
		SC_DAL_DataFactory.createServiceTypesWithAssignableValue(NUMBER_OF_ITEMS_TO_CREATE, true).iterator().next();
	}

	/**
	 * @description Method to insert or update the case
	 *
	 * @param isInsert flag to check if its insert or update operation
	 * @param status Status of the Case to be updated
	 * @param subStatus Sub-Status of the Case to be updated
	 * @param financialPolicy FinancialPolicy to be linked with case
	 * @param insurancePolicy InsurancePolicy to be linked with case
	 * @param isAssignedToAgent Boolean to check if the Case is assigned to Agent or not
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	private static void triggerApiOnCaseInsertOrUpdate
			(Boolean isInsert, String status, String subStatus, Id financialPolicy, Id insurancePolicy, Boolean isAssignedToAgent)
	{
		User agent = SC_DAL_User.findRandomActiveAgent();
		Account account = SC_DAL_Account.getAll().iterator().next();
		Case newCase = new Case();
		SC_ServiceType__c newServiceType = SC_DAL_ServiceType.getAll().iterator().next();

		//As criteria based sharing rules cannot be accommodated in test class , not running as an agent.
		Case caseRecord = SC_DAL_DataFactory.newCase(account.Id);
		caseRecord.RSC_ServiceType__c = newServiceType.Id;
		insert caseRecord;

		SC_DAL_DataFactory.insertDocumentCheckListItems(caseRecord.Id, NUMBER_OF_ITEMS_TO_CREATE);
		SC_DAL_DataFactory.insertAssociatedContracts(caseRecord.Id, NUMBER_OF_ITEMS_TO_CREATE, null, null);

		if(isInsert)
		{
			newCase = RSC_DAL_TestDataFactory.newCase(NUMBER_OF_ITEMS_TO_CREATE, account.Id).iterator().next();
			newCase.RSC_ServiceType__c = newServiceType.Id;
			newCase.RSC_Department__c = SC_DAL_ServiceType.getAll().iterator().next().SC_Department__c;
			newCase.SC_RequesterEmail__c = CMN_DAL_SObjectDomain.generateRandomEmail();
			if(isAssignedToAgent)
			{
				newCase.SC_AssignedTo__c = agent.Id;
			}
			insert newCase;
		}
		else
		{
			newCase = SC_DAL_Case.getAll().iterator().next();
			newCase.Subject = CMN_DAL_SObjectDomain.generateRandomName();
			newCase.RSC_WorkflowCaseNumber__c = null;
			newCase.RSC_ServiceType__c = newServiceType.Id;
			newCase.RSC_Department__c = newServiceType.SC_Department__c;
			newCase.Status = status;
			newCase.SC_SubStatus__c = subStatus;
			newCase.SC_RequesterEmail__c = CMN_DAL_SObjectDomain.generateRandomEmail();

			update newCase;

			if(financialPolicy != null)
			{
				SC_DAL_DataFactory.insertAssociatedContracts(newCase.Id, NUMBER_OF_ITEMS_TO_CREATE, financialPolicy, null);
			}
			else if(insurancePolicy != null)
			{
				SC_DAL_DataFactory.insertAssociatedContracts(newCase.Id, NUMBER_OF_ITEMS_TO_CREATE, null, insurancePolicy);
			}
		}

		/*
			running the query out, as this query would be successful when included in system.runAs, if the case is owned by agent
			but if the case is owned by integration user then the case wouldn't be found and it leads to "Attempt to dereference null
			object error", hence executing the query outside the system.runAs and then again the API is executed as an Agent
		*/

		newCase = SC_DAL_Case.findById(newCase.Id);
		RSC_API_SynchroniseCase.mockCaseNumber = String.valueOf(newCase.CaseNumber);
		RSC_API_SynchroniseCase.mockTeam = CMN_DAL_SObjectDomain.generateRandomName();
		RSC_API_SynchroniseCase.mockExternalCaseNumber = String.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber());

		System.runAs(agent)
		{
			CMN_API_RestBaseOutboundTestHelper.successfulCall(RSC_API_SynchroniseCase.SERVICE_NAME, newCase.Id);
		}

		newCase = SC_DAL_Case.findById(newCase.Id);

		Assert.areEqual(Integer.valueOf(RSC_API_SynchroniseCase.mockExternalCaseNumber), newCase.RSC_WorkflowCaseNumber__c, 'WorkFlowCase number is not updated');
	}

	/**
	 * @description Create Case as required agent
	 *
	 * @param agentUser Agent responsible for creating the contracts
	 *
	 * @return Case created by agent
	 */
	private static Case createCaseAsAgent(User agentUser)
	{
		Case newCase = new Case();
		System.runAs(agentUser)
		{
			SC_ServiceType__c newServiceType = SC_DAL_ServiceType.getAll().iterator().next();

			newCase = SC_DAL_DataFactory.newCase();
			newCase.RSC_ServiceType__c = newServiceType.Id;
			newCase.SC_RequesterEmail__c = CMN_DAL_SObjectDomain.generateRandomEmail();

			insert newCase;
		}

		return newCase;
	}

	/**
	 * @description Create data required for the unit test
	 *
	 * @param agentUser Agent responsible for creating the contracts
	 * @param policyId policy to with the contract has to be linked
	 *
	 * @return AssociatedContracts created by agent
	 */
	private static List<SC_AssociatedContract__c> createAssociatedContracts(User agentUser, Id policyId)
	{
		List<SC_AssociatedContract__c> newContracts;
		Case newCase = createCaseAsAgent(agentUser);
		System.runAs(agentUser)
		{
			newContracts = SC_DAL_DataFactory.insertAssociatedContracts(newCase.Id, INT_TWO, null, policyId);
		}

		return newContracts;
	}

	/**
	 * @description Test Method to validate the scenario wherein successful outbound API call is made to send new Case to Mulesoft
	 */
	@IsTest
	private static void successfulCallOnInsert()
	{
		triggerApiOnCaseInsertOrUpdate(true, null, null, null, null, false);
	}

	/**
	 * @description Test Method to validate the scenario wherein successful outbound API call is made to send updated Case to Mulesoft
	 */
	@IsTest
	private static void successfulCallOnInProgressStatus()
	{
		triggerApiOnCaseInsertOrUpdate(false, SC_DAL_Case.STATUS_IN_PROGRESS, null, null, null, false);
	}

	/**
	 * @description Test Method to validate the scenario wherein successful outbound API call is made to send updated Case to Mulesoft
	 */
	@IsTest
	private static void successfulCallOnHoldStatus()
	{
		triggerApiOnCaseInsertOrUpdate(false, SC_DAL_Case.STATUS_IN_PROGRESS, SC_DAL_Case.SUB_STATUS_ON_HOLD, null, null, false);
	}

	/**
	 * @description Test Method to validate the scenario wherein successful outbound API call is made to send completed Case to Mulesoft
	 */
	@IsTest
	private static void successfulCallOnCompletedStatus()
	{
		FinServ__FinancialAccount__c financialAccount = AW_DAL_FinancialAccount.getAll().iterator().next();
		triggerApiOnCaseInsertOrUpdate(false, SC_DAL_Case.STATUS_CLOSED, null, financialAccount.Id, null, false);
	}

	/**
	 * @description Test Method to validate the scenario wherein successful outbound API call is made to send Terminated Case to Mulesoft
	 */
	@IsTest
	private static void successfulCallOnTerminatedStatus()
	{
		InsurancePolicy insurancePolicy = AW_DAL_InsurancePolicy.getAll().iterator().next();
		triggerApiOnCaseInsertOrUpdate(false, SC_DAL_Case.STATUS_CLOSED, SC_DAL_Case.SUB_STATUS_TERMINATED, null, insurancePolicy.Id, false);
	}

	/**
	 * @description Test Method to check if the  successful outbound API call is made to send new non serviceable Case to Mulesoft with agent information
	 */
	@IsTest
	private static void successfulCallWhenNonServiceableCaseIsWithAgent()
	{
		triggerApiOnCaseInsertOrUpdate(true, null, null, null, null, true);
	}

	/**
	 * @description Test Method to check if the  successful outbound API call is made to send new non serviceable Case to Mulesoft with no agent information
	 */
	@IsTest
	private static void successfulCallWhenNonServiceableCaseIsNotWithAgent()
	{
		triggerApiOnCaseInsertOrUpdate(true, null, null, null, null, false);
	}

	/**
	 * @description Test Method to validate the scenario wherein successful outbound API call is made to send updated Case to Mulesoft
	 */
	@IsTest
	private static void successfulCallOnContractsDelete()
	{
		InsurancePolicy insurancePolicy = AW_DAL_InsurancePolicy.getAll().iterator().next();
		User foundUser = SC_DAL_User.findRandomActiveAgent();
		List<SC_AssociatedContract__c> newContracts = createAssociatedContracts(foundUser, insurancePolicy.Id);
		System.runAs(foundUser)
		{
			SC_AssociatedContract__c newContract = SC_DAL_AssociatedContract.getAll().iterator().next();
			Id caseId = newContract.SC_Case__c;
			String caseNumber = newContract.SC_Case__r.CaseNumber;
			delete newContracts;

			RSC_API_SynchroniseCase.mockCaseNumber = String.valueOf(caseNumber);
			RSC_API_SynchroniseCase.mockTeam = CMN_DAL_SObjectDomain.generateRandomName();
			RSC_API_SynchroniseCase.mockExternalCaseNumber = String.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber());

			CMN_API_RestBaseOutboundTestHelper.successfulCall(RSC_API_SynchroniseCase.SERVICE_NAME, caseId);

			Case newCase = SC_DAL_Case.findById(caseId);

			Assert.areEqual(Integer.valueOf(RSC_API_SynchroniseCase.mockExternalCaseNumber), newCase.RSC_WorkflowCaseNumber__c, 'WorkFlowCase number is not updated');
		}
	}

	/**
	 * @description Method to insert or update the CaseComments
	 *
	 * @param isInsert flag to check if its insert or update operation
	 */
	private static void triggerApiOnCommentsUpsert(Boolean isInsert)
	{
		User foundAgent = SC_DAL_User.findRandomActiveAgent();
		Case newCase = createCaseAsAgent(foundAgent);
		if(!isInsert)
		{
			RSC_DAL_TestDataFactory.insertCaseComments(NUMBER_OF_ITEMS_TO_CREATE, newCase.Id).iterator().next();
		}
		CMN_CaseComment__c newCaseComment = new CMN_CaseComment__c();

		System.runAs(foundAgent)
		{
			if(isInsert)
			{
				newCaseComment = RSC_DAL_TestDataFactory.insertCaseComments(NUMBER_OF_ITEMS_TO_CREATE, newCase.Id).iterator().next();
			}
			else
			{
				newCaseComment = CMN_DAL_CaseComments.getAll().iterator().next();
				newCaseComment.CMN_Comment__c = CMN_DAL_SObjectDomain.generateRandomDescription();
				update newCaseComment;
			}

			RSC_API_SynchroniseCase.mockCaseNumber = String.valueOf(newCaseComment.CMN_Case__r.CaseNumber);
			RSC_API_SynchroniseCase.mockTeam = CMN_DAL_SObjectDomain.generateRandomName();
			RSC_API_SynchroniseCase.mockExternalCaseNumber = String.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber());
			RSC_API_SynchroniseCase.mockSourceCommentId = newCaseComment.Id;
			RSC_API_SynchroniseCase.mockTargetCommentId = CMN_DAL_SObjectDomain.generateRandomNumber();

			CMN_API_RestBaseOutboundTestHelper.successfulCall(RSC_API_SynchroniseCase.SERVICE_NAME, newCase.Id);

			Case foundCase = SC_DAL_Case.findById(newCase.Id);

			Assert.areEqual(Integer.valueOf(RSC_API_SynchroniseCase.mockExternalCaseNumber), foundCase.RSC_WorkflowCaseNumber__c, 'WorkFlowCase number is not updated');
		}
	}

	/**
	 * @description Test Method to validate the scenario wherein successful outbound API call is made when CaseComments are inserted in salesforce
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	private static void successfulCallOnCommentsInsert()
	{
		triggerApiOnCommentsUpsert(true);
	}

	/**
	 * @description Test Method to validate the scenario wherein successful outbound API call is made when CaseComments are updated in salesforce
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	private static void successfulCallOnCommentsUpdate()
	{
		triggerApiOnCommentsUpsert(false);
	}

	/**
	 * @description Check that the service abort if the Id provided does not find a case
	 *
	 * @see RSC_API_SynchroniseCase.abortRequest
	 */
	@IsTest
	private static void abortedCallNoItemFound()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(RSC_API_SynchroniseCase.SERVICE_NAME, UserInfo.getUserId());
	}
}