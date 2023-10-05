/**
 * @description Test class for AW_API_RestOutboundQuoteInfo
 *
 * @see AW_TEST_API_RestOutboundQuoteInfo
 *
 * @author vishakha.saini@accenture.com
 *
 * @date 2019, February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_API_RestOutboundQuoteInfo
{
	private static final Integer NUM_OPPORTUNITIES_TO_CREATE = 2;

	@TestSetup
	private static void insertTestData()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		System.runAs(adviser)
		{
			Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
			AW_DAL_TestDataFactory.createDefaultOpportunities(newAccount, NUM_OPPORTUNITIES_TO_CREATE);
		}
	}

	/**
	 * @description Method use to setup the webservice call queue
	 *
	 * @return List of Web Service Call Queue records
	 */
	public static List<CMN_WebserviceCallQueue__c> setup()
	{
		Account newAccount = AW_DAL_Account.getAll().iterator().next();
		List<CMN_WebserviceCallQueue__c> queueItems = setupQueueItems(newAccount);
		return queueItems;
	}

	private static List<CMN_WebserviceCallQueue__c> setupQueueItems(Account newAccount)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RestOutboundQuoteInfo.SERVICE_NAME, newAccount.Id);
		return new List<CMN_WebserviceCallQueue__c> {queueItem};
	}

	/**
	 * @description Check to see if exception is thrown
	 */
	@IsTest
	private static void checkExistingAccountForRequest()
	{
		AW_API_RestOutboundQuoteInfo.responseType = AW_API_RestOutboundQuoteInfo.RESPONSE_MULTIPLE_QUOTES;
		List<CMN_WebserviceCallQueue__c> queueItems = setup();
		queueItems.iterator().next().CMN_TriggeringObjectId__c = UserInfo.getUserId();

		checkException(queueItems, AW_API_RestOutboundQuoteInfo.EXC_CLIENT_ID_NOT_FOUND);
	}

	@IsTest
	private static void checkExistingOpportunityForRequest()
	{
		AW_API_RestOutboundQuoteInfo.responseType = AW_API_RestOutboundQuoteInfo.RESPONSE_MULTIPLE_QUOTES;
		List<CMN_WebserviceCallQueue__c> queueItems = setup();

		Account newAccount = AW_DAL_Account.getAll()[0];
		List<Opportunity> clientOpportunities = AW_DAL_Opportunity.findOpenByAccountId(newAccount.Id);
		delete clientOpportunities;

		checkException(queueItems, AW_API_RestOutboundQuoteInfo.EXC_OPPORTUNITY_NOT_FOUND);
	}

	@IsTest
	private static void checkAdviserIdForRequest()
	{
		AW_API_RestOutboundQuoteInfo.responseType = AW_API_RestOutboundQuoteInfo.RESPONSE_MULTIPLE_QUOTES;
		List<CMN_WebserviceCallQueue__c> queueItems = setup();

		List<Account> accountsCreated = AW_DAL_Account.getAll();
		User adviser = AW_DAL_User.findAdviserById(accountsCreated[0].OwnerId);
		adviser.AW_UACFID__c = CMN_UTIL_String.EMPTY;

		System.runAs(AW_DAL_User.findActiveAdministrator())
		{
			update adviser;
		}

		checkException(queueItems, AW_API_RestOutboundQuoteInfo.EXC_UACFID_NOT_FOUND);
	}

	@IsTest
	private static void checkAdviserCodeForRequest()
	{
		AW_API_RestOutboundQuoteInfo.responseType = AW_API_RestOutboundQuoteInfo.RESPONSE_MULTIPLE_QUOTES;
		List<CMN_WebserviceCallQueue__c> queueItems = setup();

		List<Account> accountsCreated = AW_DAL_Account.getAll();
		User adviser = AW_DAL_User.findAdviserById(accountsCreated.iterator().next().OwnerId);
		adviser.AW_ConsultantCode__c = CMN_UTIL_String.EMPTY;

		System.runAs(AW_DAL_User.findActiveAdministrator())
		{
			update adviser;
		}

		checkException(queueItems, AW_API_RestOutboundQuoteInfo.EXC_CONSULTANT_CODE_NOT_FOUND);
	}

	/**
	 * @description Method to test processing of the Quotes and Quoted Solutions after successful callout.
	 * Checks if the correct Opportunity will be assigned to the Quote received in the response.
	 * Checks if the Quote and Quoted Solution existing in Salesforce will be updated.
	 * Checks if Quote and Quoted Solution which doesn't exist in Salesforce will be inserted.
	 *
	 * @author Pawel Czermiński
	 */
	@IsTest
	private static void withProductInterests()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();
		Id opportunityId = null;
		Id riskOpportunityId = null;
		Id investmentOpportunityId = null;
		Id oppWithoutProductId = null;
		Account mAccount = null;
		System.runAs(adviser)
		{
			Account newAccount = AW_DAL_TestDataFactory.createClientAccount()[0];
			mAccount = newAccount;
			List<Opportunity> opportunitiesToInsert = AW_DAL_TestDataFactory.newOpportunities(newAccount, adviser, 4, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY);
			opportunitiesToInsert[0].CreatedDate = Date.newInstance(2000, 1, 1);
			opportunitiesToInsert[0].AW_ProductInterest__c = AW_DAL_Opportunity.OPPORTUNITY_PRODUCT_INTEREST_RISK;
			opportunitiesToInsert[1].CreatedDate = Date.newInstance(2000, 1, 1);
			opportunitiesToInsert[1].AW_ProductInterest__c = AW_DAL_Opportunity.OPPORTUNITY_PRODUCT_INTEREST_INVESTMENT;
			opportunitiesToInsert[2].CreatedDate = Date.newInstance(2000, 1, 1);
			opportunitiesToInsert[2].AW_ProductInterest__c = null;
			insert opportunitiesToInsert;
			opportunityId = opportunitiesToInsert[0].Id;
			riskOpportunityId = opportunitiesToInsert[0].Id;
			investmentOpportunityId = opportunitiesToInsert[1].Id;
			oppWithoutProductId = opportunitiesToInsert[2].Id;
		}
		Quote mQuote = AW_DAL_TestDataFactory.createQuoteWithQuoteNumber(opportunityId, '49081032', true);
		AW_Quoted_Solution__c quotedSolution = AW_DAL_TestDataFactory.createQuoteSolution(mQuote.Id, null, false);

		//Quote number + Initials + Surname + Date of birth + Benefit code - External Id for Quoted Solution created based on mocked response
		quotedSolution.AW_TF_External_Id__c = '49081032MMaleAPI1990-08-08T00:00:00100';

		insert quotedSolution;
		AW_API_RestOutboundQuoteInfo.responseType = AW_API_RestOutboundQuoteInfo.RESPONSE_MULTIPLE_QUOTES;
		List<CMN_WebserviceCallQueue__c> queueItems = setupQueueItems(mAccount);
		CMN_API_RestBaseOutboundTestHelper.successfulCall(queueItems);

		System.assertEquals('3', AW_DAL_Quote.findById(mQuote.Id).Status);
		System.assertEquals(13, AW_DAL_QuotedSolution.findByQuoteName(mQuote.Id).size());

		//TODO: Priority 1 - use DAL class
		Quote quoteWithInvestmentProduct =
		[
				SELECT Status,
						OpportunityId,
				(
						SELECT Id
						FROM Quoted_Solutions__r
				)
				FROM Quote
				WHERE AW_Quote_Solution_Number__c = '49081022'
		];
		System.assertEquals(1, quoteWithInvestmentProduct.Quoted_Solutions__r.size());
		System.assertEquals(investmentOpportunityId, quoteWithInvestmentProduct.OpportunityId);
		System.assertEquals('3', [
				SELECT AW_Recurring_Premium_Frequency__c
				FROM AW_Quoted_Solution__c
				WHERE Id = :quotedSolution.Id
		].AW_Recurring_Premium_Frequency__c);
	}

	private static void checkException(List<CMN_WebserviceCallQueue__c> queueItems, String excMessage)
	{
		Test.startTest();

		List<CMN_API_HttpBase> responses = CMN_FACTORY_WebserviceManager.execute(queueItems);

		Test.stopTest();

		for(CMN_API_HttpBase response : responses)
		{
			System.assertNotEquals(true, response.callResult.errors.isEmpty(), 'No errors thrown');
			System.assert(response.callResult.errors.contains(excMessage));
			System.assertEquals(true, response.callResult.aborted, 'Expected Request to have aborted.');
		}
	}

	/**
	 * @description Method to test processing of the Quotes and Quoted Solutions after successful
	 * callout when there is one Opp without Product Interest existing in Salesforce.
	 * Checks if the Opp will be properly assigned to received Quote.
	 *
	 * @author Paweł Czermiński
	 */
	@IsTest
	private static void withoutProductInterests()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();
		Id oppWithoutProductId = null;
		Account mAccount = null;
		System.runAs(adviser)
		{
			Account newAccount = AW_DAL_TestDataFactory.createClientAccount()[0];
			mAccount = newAccount;
			List<Opportunity> opportunitiesToInsert = AW_DAL_TestDataFactory.newOpportunities(newAccount, adviser, 1, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY);
			opportunitiesToInsert[0].CreatedDate = Date.newInstance(2000, 1, 1);
			opportunitiesToInsert[0].AW_ProductInterest__c = null;
			insert opportunitiesToInsert;
			oppWithoutProductId = opportunitiesToInsert[0].Id;
		}

		AW_API_RestOutboundQuoteInfo.responseType = AW_API_RestOutboundQuoteInfo.RESPONSE_MULTIPLE_QUOTES;
		List<CMN_WebserviceCallQueue__c> queueItems = setupQueueItems(mAccount);
		CMN_API_RestBaseOutboundTestHelper.successfulCall(queueItems);

		Quote quoteWithInvestmentProduct =
		[
				//TODO: Priority 1 - use DAL class
				SELECT Status,
						OpportunityId,
						Opportunity.AW_ProductInterest__c,
				(
						SELECT Id
						FROM Quoted_Solutions__r
				)
				FROM Quote
				WHERE AW_Quote_Solution_Number__c = '49081022'
		];
		System.assertEquals(oppWithoutProductId, quoteWithInvestmentProduct.OpportunityId);
	}

	/**
	 * @description Method to test processing of the Quotes and Quoted Solutions after successful callout and Opportunity Stage update.
	 * Checks if the Opp will be properly assigned to received Quote.
	 *
	 * @author Paweł Czermiński
	 */
	@IsTest
	private static void stageUpdateWithMultipleQuotes()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();
		Id opportunityId = null;
		Id riskOpportunityId = null;
		Id investmentOpportunityId = null;
		Account mAccount = null;
		System.runAs(adviser)
		{
			Account newAccount = AW_DAL_TestDataFactory.createClientAccount()[0];
			mAccount = newAccount;
			List<Opportunity> opportunitiesToInsert = AW_DAL_TestDataFactory.newOpportunities(newAccount, adviser, 4, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY);
			opportunitiesToInsert[0].CreatedDate = Date.newInstance(2000, 1, 1);
			opportunitiesToInsert[0].AW_ProductInterest__c = AW_DAL_Opportunity.OPPORTUNITY_PRODUCT_INTEREST_RISK;
			opportunitiesToInsert[1].CreatedDate = Date.newInstance(2000, 1, 1);
			opportunitiesToInsert[1].AW_ProductInterest__c = AW_DAL_Opportunity.OPPORTUNITY_PRODUCT_INTEREST_INVESTMENT;
			insert opportunitiesToInsert;
			opportunityId = opportunitiesToInsert[0].Id;
			riskOpportunityId = opportunitiesToInsert[0].Id;
			investmentOpportunityId = opportunitiesToInsert[1].Id;
		}

		AW_API_RestOutboundQuoteInfo.responseType = AW_API_RestOutboundQuoteInfo.RESPONSE_FOR_OPP_STAGE_VALIDATION;
		List<CMN_WebserviceCallQueue__c> queueItems = setupQueueItems(mAccount);
		CMN_API_RestBaseOutboundTestHelper.successfulCall(queueItems);

		List<Quote> quotes =
		[
				//TODO: Priority 1 - use DAL class
				SELECT
						AW_Quote_Solution_Number__c,
						Status,
						OpportunityId,
						Opportunity.AW_ProductInterest__c,
						Opportunity.StageName,
						AW_Contract_Numbers__c,
				(
						SELECT Id
						FROM Quoted_Solutions__r
				)
				FROM Quote
		];

		System.assertEquals(3, quotes.size());

		Quote riskQuoteWithoutContracts;
		Quote riskQuoteWithContracts;
		Quote investmentQuote;

		for(Quote mQuote : quotes)
		{
			if(mQuote.AW_Quote_Solution_Number__c == '49081032')
			{
				riskQuoteWithoutContracts = mQuote;
			}
			else if(mQuote.AW_Quote_Solution_Number__c == '49081033')
			{
				riskQuoteWithContracts = mQuote;
			}
			else if(mQuote.AW_Quote_Solution_Number__c == '49081034')
			{
				investmentQuote = mQuote;
			}
		}

		System.assertEquals(riskOpportunityId, riskQuoteWithContracts.OpportunityId);
		System.assertEquals(riskOpportunityId, riskQuoteWithoutContracts.OpportunityId);
		System.assertEquals(investmentOpportunityId, investmentQuote.OpportunityId);

		System.assertEquals(null, riskQuoteWithoutContracts.AW_Contract_Numbers__c);
		System.assertEquals('123;124', riskQuoteWithContracts.AW_Contract_Numbers__c);

		System.assertEquals(AW_DAL_Opportunity.OPPORTUNITY_STAGE_SOLUTION_ACCEPTED, riskQuoteWithContracts.Opportunity.StageName);
		System.assertEquals(AW_DAL_Opportunity.OPPORTUNITY_STAGE_QUOTE_PROPOSED, investmentQuote.Opportunity.StageName);
	}
}