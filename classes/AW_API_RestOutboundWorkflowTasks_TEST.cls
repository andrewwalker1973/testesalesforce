/**
 * @description Test class for AW_API_RestOutboundWorkflowTasks
 *
 * @see AW_API_RestOutboundWorkflowTasks @story ST-2338
 *
 * @author vishakha.saini@accenture.com, jason.van.beukering@accenture.com
 *
 * @date 2019, March 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
private class AW_API_RestOutboundWorkflowTasks_TEST
{
	private static Account newAccount;
	private static User adviser;
	private static final String ZERO_STRING = '0';

	/**
	 * @description Method to create webservice queue records
	 *
	 * @return Returns list of webservice queue records
	 */
	private static List<CMN_WebserviceCallQueue__c> setup()
	{
		adviser = AW_DAL_User.findRandomActiveAdviser();

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RestOutboundWorkflowTasks.SERVICE_NAME, adviser.Id);
		queueItem.CMN_PartnerCode__c = adviser.AW_ConsultantCode__c;

		return new List<CMN_WebserviceCallQueue__c> {queueItem};
	}

	/**
	 * @description Test Method to validate the scenario wherein Partner code is not present
	 */
	@IsTest
	private static void abortedNoCode()
	{
		List<CMN_WebserviceCallQueue__c> queueItems = setup();
		queueItems.iterator().next().CMN_PartnerCode__c = CMN_UTIL_String.EMPTY;

		CMN_API_RestBaseOutboundTestHelper.abortedCall(queueItems, AW_API_RestOutboundWorkflowTasks.ERROR_CONSULTANT_CODE_NOT_FOUND);
	}

	@IsTest
	private static void abortedNoAdviser()
	{
		List<CMN_WebserviceCallQueue__c> queueItems = setup();
		queueItems.iterator().next().CMN_PartnerCode__c = AW_DAL_User.generateRandomConsultantCode();
		CMN_API_RestBaseOutboundTestHelper.abortedCall(queueItems, AW_API_RestOutboundWorkflowTasks.ERROR_ADVISER_NOT_FOUND);
	}

	/**
	 * @description Test Method to validate the scenario wherein workflow task exist on an account;
	 */
	@SuppressWarnings('PMD.CognitiveComplexity,PMD.CyclomaticComplexity')
	@IsTest
	private static void checkUpsertOrDelete()
	{
		List<CMN_WebserviceCallQueue__c> queueItems = setup();

		AW_Outstanding_Requirement__c newTaskForUpdate;

		//Create a new client account that will be matched by webservice class
		System.runAs(adviser)
		{
			newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
			newAccount.OwnerId = adviser.Id;
			//Insert a new workflow task, we will use this to ensure that we update and not insert a new workflow task if we match on external id
			newTaskForUpdate = AW_DAL_TestDataFactory.createWorkflowTask(newAccount);
		}

		//Make sure that constants embedded in the mock response are updated with the newly created workflow tasks
		//This will ensure that we match existing workflow task
		AW_API_RestOutboundWorkflowTasks.mockIdentificationNumber = newTaskForUpdate.AW_IdentityNumber__c;
		AW_API_RestOutboundWorkflowTasks.mockUpdateIsn = newTaskForUpdate.AW_UpdateISN__c;

		//We are setting the Processing Status to blank to test setting the status to processing
		AW_API_RestOutboundWorkflowTasks.mockProcessingStatus = CMN_UTIL_String.EMPTY;

		//Parse the mock response and determine the expected number of Workflow tasks so we can compare them against what's expected
		List<AW_API_RestOutboundWorkflowTasks.DTO_WorkflowTask> dtoTasks = getMockResponseTasks();

		// Retrieve the contract numbers from the mock response
		Set<String> contractNumbers = new Set<String>();
		for(AW_API_RestOutboundWorkflowTasks.DTO_WorkflowTask dtoTask : dtoTasks)
		{
			String contractNumberFormatted = CMN_UTIL_String.stripStart(dtoTask.ContractNumber, ZERO_STRING);
			contractNumbers.add(contractNumberFormatted);
		}
		List<String> contractNumbersList = new List<String>(contractNumbers);

		// Create quoted solutions for every contract number, together with related quotes and related opportunities
		List<Opportunity> opportunities = AW_DAL_TestDataFactory.createDefaultOpportunities(newAccount, contractNumbers.size());

		List<Quote> quotesToInsert = new List<Quote>();
		for(Opportunity opportunity : opportunities)
		{
			Quote quote = AW_DAL_TestDataFactory.createQuoteWithQuoteNumber(opportunity.Id, String.valueOf(opportunities.indexOf(opportunity)), false);
			quotesToInsert.add(quote);
		}
		insert quotesToInsert;

		List<AW_Quoted_Solution__c> quotedSolutionsToInsert = new List<AW_Quoted_Solution__c>();
		for(Quote quote : quotesToInsert)
		{
			AW_Quoted_Solution__c quotedSolution = AW_DAL_TestDataFactory.createQuoteSolution(quote.Id, contractNumbersList.get(quotesToInsert.indexOf(quote)), false);
			quotedSolutionsToInsert.add(quotedSolution);
		}
		insert quotedSolutionsToInsert;

		//Create a new workflow task, this one  will NOT exist in the Mock Response and therefore should be deleted
		AW_Outstanding_Requirement__c newTaskForDelete = AW_DAL_TestDataFactory.createWorkflowTask(newAccount);

		//Ensure that a mock call is made with the status code set to 200
		CMN_API_RestBaseOutboundTestHelper.successfulCall(queueItems);

		//Query the database to retrieve all the workflow tasks that exist for the current adviser
		List<AW_Outstanding_Requirement__c> foundTasks = AW_DAL_OutstandingRequirement.findByOwnerId(adviser.Id);

		Boolean itemDeleted = true;

		//Make sure that the item we created which isn't in the MockResponse is deleted.
		for(AW_Outstanding_Requirement__c foundTask : foundTasks)
		{
			if(foundTask.Id == newTaskForDelete.Id)
			{
				itemDeleted = false;
				break;
			}
		}

		Assert.isTrue(itemDeleted, 'Workflow task not deleted as expected.');

		//Compare the number of workflow tasks we expect vs the number that exist within Salesforce
		Assert.areEqual(dtoTasks.size(), foundTasks.size(), 'Invalid number of workflow tasks');

		// map the found outstanding requirements (workflow tasks) by their contract number
		Map<String, List<AW_Outstanding_Requirement__c>> tasksListByContractNumber = new Map<String, List<AW_Outstanding_Requirement__c>>();
		for(AW_Outstanding_Requirement__c foundTask : foundTasks)
		{
			List<AW_Outstanding_Requirement__c> tasksList = tasksListByContractNumber.get(foundTask.AW_ContractNumber__c);
			if(tasksList == null)
			{
				tasksList = new List<AW_Outstanding_Requirement__c>();
			}
			tasksList.add(foundTask);
			tasksListByContractNumber.put(foundTask.AW_ContractNumber__c, tasksList);
		}

		List<AW_Quoted_Solution__c> quotedSolutions = AW_DAL_QuotedSolution.findByContractNumber(contractNumbers);

		// map the quoted solutions and the related quote id by the contract number
		Map<String, List<AW_Quoted_Solution__c>> quotedSolutionsByContractNumber = new Map<String, List<AW_Quoted_Solution__c>>();
		Map<String, Id> quoteIdByContractNumber = new Map<String, Id>();
		for(AW_Quoted_Solution__c quotedSolution : quotedSolutions)
		{
			List<AW_Quoted_Solution__c> listOfQuotedSolution = quotedSolutionsByContractNumber.get(quotedSolution.AW_Contract_Number__c);
			if(listOfQuotedSolution == null)
			{
				listOfQuotedSolution = new List<AW_Quoted_Solution__c>();
			}
			listOfQuotedSolution.add(quotedSolution);
			quotedSolutionsByContractNumber.put(quotedSolution.AW_Contract_Number__c, listOfQuotedSolution);
			quoteIdByContractNumber.put(quotedSolution.AW_Contract_Number__c, quotedSolution.AW_Quote_Name__c);
		}

		Set<Id> quotesIds = new Set<Id>(quoteIdByContractNumber.values());

		Map<Id, Quote> quotesByIds = new Map<Id, Quote>(AW_DAL_Quote.findById(quotesIds));

		Set<Id> opportunityIds = new Set<Id>();

		// check each found outstanding requirement is linked to the right opportunity
		for(String contractNumber : contractNumbers)
		{
			Id quoteId = quoteIdByContractNumber.get(contractNumber);
			Quote quote = quotesByIds.get(quoteId);

			List<AW_Outstanding_Requirement__c> tasksList = tasksListByContractNumber.get(contractNumber);

			for(AW_Outstanding_Requirement__c task : tasksList)
			{
				Assert.areEqual(quote.OpportunityId, task.AW_Opportunity__c, 'Outstanding Requirement (Id = ' + task.Id +
						') is not linked to the correct Opportunity (Id = ' + quote.OpportunityId + ').');
			}

			opportunityIds.add(quote.OpportunityId);
		}

		// check each related opportunity had its stage updated from the initial stage
		List<Opportunity> updatedOpportunities = AW_DAL_Opportunity.findById(opportunityIds);
		for(Opportunity updatedOpportunity : updatedOpportunities)
		{
			Assert.areNotEqual(AW_DAL_Opportunity.OPPORTUNITY_STAGE_QUALIFIED, updatedOpportunity.StageName, 'The stage of this opportunity (Id = '
					+ updatedOpportunity.Id + ' was not updated as expected.');
		}
	}

	/**
	 * @description Method to list of mock response from API
	 *
	 * @return the dtoResponse for mocking
	 */
	private static List<AW_API_RestOutboundWorkflowTasks.DTO_WorkflowTask> getMockResponseTasks()
	{
		AW_API_RestOutboundWorkflowTasks.AW_API_RestOutboundWorkflowTasksMock mockResponse =
				new AW_API_RestOutboundWorkflowTasks.AW_API_RestOutboundWorkflowTasksMock();

		String response = mockResponse.validResponse;
		String res = '{' + AW_API_RestOutboundWorkflowTasks.FMT_JSON_OUTER_ATTR_NAME + response + '}';

		AW_API_RestOutboundWorkflowTasks.DTO_Response dtoResponse =
				(AW_API_RestOutboundWorkflowTasks.DTO_Response)JSON.deserialize(res, AW_API_RestOutboundWorkflowTasks.DTO_Response.class);

		return dtoResponse.workflowTasks;
	}

}