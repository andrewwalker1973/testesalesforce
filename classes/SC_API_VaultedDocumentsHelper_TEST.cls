/**
 * @description Util class for SC_API_FetchVaultedDocuments_TEST and SC_API_BusinessClientVaultedDocs_TEST
 *
 * @see SC_API_FetchVaultedDocuments and SC_API_BusinessClientVaultedDocs @story ST-118605,ST-178029, ST-284351
 *
 * @author meghana.g.n@accenture.com
 *
 * @date May 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
public inherited sharing class SC_API_VaultedDocumentsHelper_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;

	/**
	 * @description Will call API with the provided triggering object Id and then check that call was successful
	 *
	 * @param triggeringObjectId Parent object for which to get vaulted documents
	 * @param serviceName Name of the service API
	 */
	public static void runSuccessfulTest(Id triggeringObjectId, String serviceName)
	{
		if(serviceName == SC_API_FetchVaultedDocuments.SERVICE_NAME)
		{
			SC_API_FetchVaultedDocuments handler = (SC_API_FetchVaultedDocuments)CMN_API_RestBaseOutboundTestHelper.successfulCall
					(SC_API_FetchVaultedDocuments.SERVICE_NAME, triggeringObjectId);
			System.assertNotEquals(handler.vaultedDocuments, null, 'Response should not be null');
		}
		else if(serviceName == SC_API_BusinessClientVaultedDocs.SERVICE_NAME)
		{
			SC_API_BusinessClientVaultedDocs handler = (SC_API_BusinessClientVaultedDocs)CMN_API_RestBaseOutboundTestHelper.successfulCall
					(SC_API_BusinessClientVaultedDocs.SERVICE_NAME, triggeringObjectId);
			System.assertNotEquals(handler.vaultedDocuments, null, 'Response should not be null');
		}
	}

	/**
	 * @description Emulates a successful call and confirms Vaulted docs were correctly set for a lead
	 *
	 * @param serviceName Name of the service API
	 * @param accountRecord Account Record created
	 */
	public static void vaultedDocumentsForLead(String serviceName, Account accountRecord)
	{
		//The owner will be the adviser
		User runningUser = SC_DAL_User.findById(accountRecord.OwnerId);
		System.runAs(runningUser)
		{
			Lead newLead = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, NUMBER_OF_ITEMS_TO_CREATE, runningUser.Id).iterator().next();
			runSuccessfulTest(newLead.Id, serviceName);
		}
	}

	/**
	 * @description Emulates a successful call and confirms Vaulted docs were correctly set for an account
	 *
	 * @param serviceName Name of the service API
	 * @param masterAccount Name of the account record type
	 */
	public static void validateVaultedDocuments(String serviceName, Account masterAccount)
	{
		User agent = SC_DAL_User.findRandomActiveAgent();

		/*
			Setting the agent as the owner of the MasterAccount as we can’t use Apex to create a
			criteria-based sharing rule,and we can’t test criteria-based sharing using Apex.
			If the Agent is not set as the owner then the records will not be shared with Agent,
			hence the approach is to not to run the test as specific user or set the user as
			the owner of the record
		*/

		//Updating with new instance to avoid the smoker__c validation
		Account foundAccount = new Account();
		foundAccount.Id = masterAccount.Id;
		foundAccount.OwnerId = agent.Id;
		update foundAccount;

		System.runAs(agent)
		{
			runSuccessfulTest(foundAccount.Id, serviceName);
		}
	}

	/**
	 * @description Emulates a successful call and confirms Vaulted docs were correctly set for an opportunity
	 *
	 * @param serviceName Name of the service API
	 * @param accountRecord Account Record created
	 */
	public static void validateVaultedDocumentsForOpportunity(String serviceName, Account accountRecord)
	{
		//The owner will be the adviser
		User runningUser = SC_DAL_User.findById(accountRecord.OwnerId);
		System.runAs(runningUser)
		{
			Opportunity newOpportunity = AW_DAL_TestDataFactory.createDefaultOpportunities(accountRecord, NUMBER_OF_ITEMS_TO_CREATE).iterator().next();
			runSuccessfulTest(newOpportunity.Id, serviceName);
		}
	}

	/**
	 * @description Emulates a successful call and confirms Vaulted docs were correctly set for an outstanding requirement
	 *
	 * @param serviceName Name of the service API
	 * @param accountRecord Account Record created
	 */
	public static void validateVaultedDocumentsForOutstandingRequirement(String serviceName, Account accountRecord)
	{
		//The owner will be the adviser
		User runningUser = SC_DAL_User.findById(accountRecord.OwnerId);
		System.runAs(runningUser)
		{
			AW_Outstanding_Requirement__c newOutstandingRequirement = AW_DAL_TestDataFactory.createWorkflowTask(accountRecord);
			runSuccessfulTest(newOutstandingRequirement.Id, serviceName);
		}
	}

	/**
	 * @description Check that the service abort if the account is not found
	 *
	 * @param serviceName Name of the service API
	 *
	 * @see CMN_API_FetchVaultedDocuments.abortRequest
	 */
	public static void abortedAccountNotFound(String serviceName)
	{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		delete newAccount;
		runAbortedTest(newAccount.Id, serviceName);
	}

	/**
	 * @description Will call API with the provided triggering object Id and then check that call was aborted as now item was found
	 *
	 * @param triggeringObjectId Parent object for which to get vaulted documents
	 * @param serviceName Name of the service API
	 *
	 * @see CMN_API_FetchVaultedDocuments.abortRequest
	 */
	public static void runAbortedTest(Id triggeringObjectId, String serviceName)
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(serviceName, triggeringObjectId);
	}
}