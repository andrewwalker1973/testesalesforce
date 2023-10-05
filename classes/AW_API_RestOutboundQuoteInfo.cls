/**
 * @description Service class to make the API call, to get all the quotes associated with the Client.
 * If any of the quote is created after the opportunity was created in Salesforce and-
 * - Quote has a contract number, then update opportunity stage to "Case Submitted"
 * - Quote doesn't have a contract number, then update opportunity stage to "Quote Proposed"
 *
 * @see AW_TEST_API_RestOutboundQuoteInfo
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_API_RestOutboundQuoteInfo extends CMN_API_RestBaseOutboundMule
{
	private Account clientAccount;
	private List<Opportunity> clientOpportunities;

	private static final String FMT_DYNAMIC_URL = '/{0}/quotes';
	private static final String FMT_JSON_OUTER_ATTR_NAME = '"quotesList":';

	private static final String HTTP_HEADER_CONSULTANT_CODE = 'consultantCode';
	private static final String HTTP_HEADER_UACF_ID = 'uacfId';

	public static final String SERVICE_NAME = AW_API_RestOutboundQuoteInfo.class.getName();

	@TestVisible
	private static String responseType = CMN_UTIL_String.EMPTY;
	@TestVisible
	private static final String QUOTE_PROPOSED = 'QuoteProposed';
	@TestVisible
	private static final String CASE_SUBMITTED = 'CaseSubmitted';
	@TestVisible
	private static final String QUOTE_WITHOUT_CONTRACT = 'QuoteWithoutContract';
	@TestVisible
	private static final String RESPONSE_FOR_OPP_STAGE_VALIDATION = 'QuotesForOppStageValidation';
	@TestVisible
	private static final String RESPONSE_MULTIPLE_QUOTES = 'MultipleQuotes';

	//Global constants for exceptions
	@TestVisible
	private static final String EXC_CLIENT_ID_NOT_FOUND = 'Client not found, unable to process request';
	@TestVisible
	private static final String EXC_UACFID_NOT_FOUND = 'Adviser\'s UACF Id is not found, unable to process request';
	@TestVisible
	private static final String EXC_CONSULTANT_CODE_NOT_FOUND = 'Adviser\'s Consultant Code is not found, unable to process request';
	@TestVisible
	private static final String EXC_OPPORTUNITY_NOT_FOUND = 'API call was not made as there is no opportunity whose stage needs to be updated.';

	private static final String STR_QUOTE_NUMBER_FIELD_NAME = 'AW_Quote_Solution_Number__c';
	private static final String STR_QUOTED_SOLUTION_TF_EXTID_FIELD_NAME = 'AW_TF_External_Id__c';

	private static final String SOURCE_SYSTEM_NAME_BPO = CMN_UTIL_String.EMPTY;

	/**
	 * @description Override to set request and response DTO types and any other globals which may be used
	 */
	protected override void initialise()
	{
		super.initialise();

		baseResponseDTO = new DTO_Response();

	}

	/**
	 * @description Override to get Service name to be used when looking up custom settings for the service
	 *
	 * @return String Returns service name as string
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Override to use Get HTTP Method for API call
	 *
	 * @return String
	 */
	public override virtual String getVerb()
	{
		return HTTP_VERB_GET;
	}

	/**
	 * @description Override to return inner class having Mock response
	 *
	 * @return CMN_API_HttpBaseOutboundMock AW_API_RestOutboundQuoteInfoMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new AW_API_RestOutboundQuoteInfoMock();
	}

	/**
	 * @description Override to construct API endpoint
	 *
	 * @return String Complete API Endpoint
	 */
	protected override String getWebServiceEndPoint()
	{
		String staticUrl = super.getWebServiceEndPoint();

		//TODO: Can we make the webservice metadata setting format
		String dynamicUrl = String.format(FMT_DYNAMIC_URL, new List<String>
		{
				clientAccount.AW_IdentificationNumber__pc
		});

		return staticUrl + dynamicUrl;
	}

	/**
	 * @description Override to validate if all the information required to make API call is available
	 *
	 * @return Boolean Returns true if all the information is present, else will return false
	 */
	protected override Boolean abortRequest()
	{
		Boolean mustAbort = super.abortRequest();

		if(!mustAbort)
		{
			clientAccount = AW_DAL_Account.findById(queueItem.CMN_TriggeringObjectId__c);

			if(clientAccount == null)
			{
				mustAbort = true;
				callResult.errors.add(EXC_CLIENT_ID_NOT_FOUND);
			}
			else
			{
				if(String.isBlank(getUacfId()))
				{
					mustAbort = true;
					callResult.errors.add(EXC_UACFID_NOT_FOUND);
				}

				if(String.isBlank(getConsultantCode()))
				{
					mustAbort = true;
					callResult.errors.add(EXC_CONSULTANT_CODE_NOT_FOUND);
				}

				clientOpportunities = AW_DAL_Opportunity.findOpenByAccountId(clientAccount.Id);

				if(clientOpportunities.isEmpty())
				{
					mustAbort = true;
					callResult.errors.add(EXC_OPPORTUNITY_NOT_FOUND);
				}
			}
		}

		return mustAbort;
	}

	/**
	 * @description Override to set header values
	 */
	protected override void setHeaders()
	{
		super.setHeaders();

		request.setHeader(HTTP_HEADER_UACF_ID, getUacfId());
		request.setHeader(HTTP_HEADER_CONSULTANT_CODE, getConsultantCode());

	}

	/**
	 * @description Override to append parameters in endpoints URL
	 *
	 * @return 
	 */
	protected override String getQueryParameters()
	{
		String existingParams = super.getQueryParameters();
		String startDate = CMN_UTIL_Date.dateToIso8601String(System.today().addDays(-1));
		String endDate = CMN_UTIL_Date.dateToIso8601String(System.today());
		return String.isBlank(existingParams) ? 'startDate=' + startDate + '&endDate=' + endDate : existingParams + '&startDate=' + startDate + '&endDate=' + endDate;
	}

	/**
	 * @description Override to inject JSON outer class in API response
	 *
	 * @return String Response body
	 */
	protected override String getResponseBody()
	{
		String responseBody = super.getResponseBody();

		//We have to inject a JSON outer class because we are receiving an Array Response
		return '{' + FMT_JSON_OUTER_ATTR_NAME + responseBody + '}';
	}

	/**
	 * @description Override to set SObject types for DML operation
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType>
		{
				Opportunity.SObjectType, Quote.SObjectType, AW_Quoted_Solution__c.SObjectType
		});
	}

	/**
	 * @description Override to process API response and update opportunity status accordingly
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Response dtoQuotes = (DTO_Response)baseResponseDTO;
		processQuotesResponse(dtoQuotes.quotesList);
	}

	private String getUacfId()
	{
		return clientAccount.AW_Owner_UACFID__c;
	}

	private String getConsultantCode()
	{
		return clientAccount.Owner.AW_ConsultantCode__c;
	}

	/**
	 * @description Creates or updates Quotes and AW_Quoted_Solution__c based on the response from the callout.
	 * Updates Opportunities stages based on the Quotes assigned to them
	 *
	 * @param dtoQuotes 
	 *
	 * @author Paweł Czermiński
	 */
	private void processQuotesResponse(List<DTO_Quote> dtoQuotes)
	{
		Map<String, Quote> quoteNumberToQuote = new Map<String, Quote>();
		Map<String, AW_Quoted_Solution__c> extIdToQuotedSolution = new Map<String, AW_Quoted_Solution__c>();
		Map<String, List<AW_Quoted_Solution__c>> quoteNumberToQuotedSolutions = new Map<String, List<AW_Quoted_Solution__c>>();
		Map<String, Boolean> quoteNumberToHasContract = new Map<String, Boolean>();
		Map<Id, Opportunity> clientOppsByIds = new Map<Id, Opportunity>();
		String policyNumbersConcatenated ; //bug fix #102361

		for(Opportunity opp : clientOpportunities)
		{
			clientOppsByIds.put(opp.Id, opp);
		}

		for(DTO_Quote dtoQuote : dtoQuotes)
		{

			Set<String> contractsNumbers = new Set<String>();
			Boolean hasContract = false;
			for(DTO_Contract c : dtoQuote.contracts)
			{
				if(String.isNotBlank(c.contractNumber))
				{
					contractsNumbers.add(c.contractNumber);
					hasContract = true;
				}
			}
			String contractsNumbersConcatenated = String.join(new List<String>(contractsNumbers), ';');

			quoteNumberToHasContract.put(dtoQuote.quoteNumber, hasContract);

			Quote mQuote = populateQuote(dtoQuote, contractsNumbersConcatenated);
			quoteNumberToQuote.put(mQuote.AW_Quote_Solution_Number__c, mQuote);
			for(DTO_Contract c : dtoQuote.contracts)
			{
				for(DTO_Life liv : c.lives)
				{
					for(DTO_Benefit dtoQuotedSolution : liv.benefits)
					{
						AW_Quoted_Solution__c quotedSolution = populateQuotedSolution(dtoQuotedSolution, c, dtoQuote, liv);
						extIdToQuotedSolution.put(quotedSolution.AW_TF_External_Id__c, quotedSolution);
						if(!quoteNumberToQuotedSolutions.containsKey(mQuote.AW_Quote_Solution_Number__c))
						{
							quoteNumberToQuotedSolutions.put(mQuote.AW_Quote_Solution_Number__c, new List<AW_Quoted_Solution__c>());
						}
						quoteNumberToQuotedSolutions.get(mQuote.AW_Quote_Solution_Number__c).add(quotedSolution);
					}
				}
			}
		}

		List<Quote> existingQuotes = AW_DAL_Quote.findByQuoteNumber(quoteNumberToQuote.keySet());
		Map<String, SObject> existingQuotesByQuoteNumber
				= CMN_UTIL_System.convertListToSingleStringMap(existingQuotes, STR_QUOTE_NUMBER_FIELD_NAME);

		List<AW_Quoted_Solution__c> existingQuotedSolutions = AW_DAL_QuotedSolution.findByTfExternalId(extIdToQuotedSolution.keySet());
		Map<String, SObject> existingQuotedSolutionsByExternalId = CMN_UTIL_System.convertListToSingleStringMap(existingQuotedSolutions, STR_QUOTED_SOLUTION_TF_EXTID_FIELD_NAME);

		Set<String> quotedSolutionsExternalIds = new Set<String>();
		Map<Id, List<Quote>> oppIdToQuotes = new Map<Id, List<Quote>>();
		// if the Quote exists in Salesforce update it / if it doesn't exist create new Quote only if there is a matching Opportunity
		// if the AW_Quoted_Solution__c exists in Salesforce update it / if it doesn't exist create new AW_Quoted_Solution__c
		for(Quote mQuote : quoteNumberToQuote.values())
		{
			if(!existingQuotesByQuoteNumber.containsKey(mQuote.AW_Quote_Solution_Number__c))
			{ //new Quote
				Opportunity oppForQuote = identifyOpportunityForQuote(mQuote, clientOpportunities);
				if(oppForQuote != null)
				{
					mQuote.OpportunityId = oppForQuote.Id;
					registerNew(mQuote);
					if(!oppIdToQuotes.containsKey(mQuote.OpportunityId))
					{
						oppIdToQuotes.put(mQuote.OpportunityId, new List<Quote>());
					}
					oppIdToQuotes.get(mQuote.OpportunityId).add(mQuote);
					for(AW_Quoted_Solution__c quotedSolution : quoteNumberToQuotedSolutions.get(mQuote.AW_Quote_Solution_Number__c))
					{ //new Quote, so all the Quoted Solutions for it will be new
						if(!quotedSolutionsExternalIds.contains(quotedSolution.AW_TF_External_Id__c))
						{
							registerNew(quotedSolution, AW_Quoted_Solution__c.AW_Quote_Name__c, mQuote);
						}
						quotedSolutionsExternalIds.add(quotedSolution.AW_TF_External_Id__c);
					}
				}
			}
			else
			{ //existing Quote update
				Quote existingQuote = (Quote)existingQuotesByQuoteNumber.get(mQuote.AW_Quote_Solution_Number__c);
				mQuote.Id = existingQuote.Id;
				registerDirty(mQuote);
				if(clientOppsByIds.containsKey(existingQuote.OpportunityId))
				{
					if(!oppIdToQuotes.containsKey(existingQuote.OpportunityId))
					{
						oppIdToQuotes.put(existingQuote.OpportunityId, new List<Quote>());
					}
					oppIdToQuotes.get(existingQuote.OpportunityId).add(mQuote);
				}
				for(AW_Quoted_Solution__c quotedSolution : quoteNumberToQuotedSolutions.get(mQuote.AW_Quote_Solution_Number__c))
				{
					if(!existingQuotedSolutionsByExternalId.containsKey(quotedSolution.AW_TF_External_Id__c))
					{ // new Quoted Solution - need to specify Quote Id for it
						quotedSolution.AW_Quote_Name__c = existingQuotesByQuoteNumber.get(mQuote.AW_Quote_Solution_Number__c).Id;
						if(!quotedSolutionsExternalIds.contains(quotedSolution.AW_TF_External_Id__c))
						{
							registerNew(quotedSolution);
						}
						quotedSolutionsExternalIds.add(quotedSolution.AW_TF_External_Id__c);
					}
					else
					{ // existing Quoted Solution - already has the Quote reference populated, need to populate Id for update
						quotedSolution.Id = existingQuotedSolutionsByExternalId.get(quotedSolution.AW_TF_External_Id__c).Id;
						if(!quotedSolutionsExternalIds.contains(quotedSolution.AW_TF_External_Id__c))
						{
							registerDirty(quotedSolution);
						}
						quotedSolutionsExternalIds.add(quotedSolution.AW_TF_External_Id__c);
					}
				}
			}
		}

		// Update opportunities stages based on created/updated Quotes assigned to them
		// Stage can be only updated to higher stage, cannot be updated to the previous stages
		for(Id oppId : oppIdToQuotes.keySet())
		{
			Opportunity opp = clientOppsByIds.get(oppId);
			String oppStage = opp.StageName;
			for(Quote mQuote : oppIdToQuotes.get(oppId))
			{
				Boolean hasContract = quoteNumberToHasContract.get(mQuote.AW_Quote_Solution_Number__c);

				//added as part of the bug #102361 starts -- copy the contracts numbers in quotes to policy number in Opp.
				Set<String> policyNumbers = new Set<String>();
				if(String.isNotBlank(mQuote.AW_Contract_Numbers__c))
				{
					policyNumbers.add(mQuote.AW_Contract_Numbers__c);
				}
				policyNumbersConcatenated = String.join(new List<String>(policyNumbers), ';');
				//added as part of the bug #102361 ends

				if(hasContract)
				{
					if(oppStage != AW_DAL_Opportunity.OPPORTUNITY_STAGE_SOLUTION_ACCEPTED)
					{
						oppStage = AW_DAL_Opportunity.OPPORTUNITY_STAGE_SOLUTION_ACCEPTED;
						break;
					}
				}
				else
				{
					if(oppStage != AW_DAL_Opportunity.OPPORTUNITY_STAGE_QUOTE_PROPOSED
							&& oppStage != AW_DAL_Opportunity.OPPORTUNITY_STAGE_SOLUTION_ACCEPTED)
					{
						oppStage = AW_DAL_Opportunity.OPPORTUNITY_STAGE_QUOTE_PROPOSED;
					}
				}
			}

			if(oppStage != opp.StageName)
			{
				opp.StageName = oppStage;
				opp.AW_PolicyNumber__c = policyNumbersConcatenated;//bug fix #102361
				registerDirty(opp);
			}
		}
	}

	/**
	 * @description Identify Opportunity for the Quote to be created.
	 *
	 * @param mQuote 
	 * @param oppsForClient 
	 *
	 * @return Opportunity
	 *
	 * @author Paweł Czermiński
	 */
	private Opportunity identifyOpportunityForQuote(Quote mQuote, List<Opportunity> oppsForClient)
	{
		Opportunity chosenOpportunity = null;
		Integer rulePriority = null;

		for(Opportunity opp : oppsForClient)
		{
			if(mQuote.AW_Quote_DateTime__c > opp.CreatedDate)
			{ // only consider Opps created before Quote was created
				if(opp.AW_ProductInterest__c == mQuote.AW_Product_Category__c)
				{ // highest priority for Opp with Product Interest equals to Quote Product Category
					if(chosenOpportunity == null || rulePriority > 1
							|| (rulePriority == 1 && chosenOpportunity.LastModifiedDate < opp.LastModifiedDate))
					{
						chosenOpportunity = opp;
						rulePriority = 1;
					}
				}
				else if(opp.AW_ProductInterest__c == null)
				{ // second priority when Opp Product Interest is null
					if(chosenOpportunity == null || rulePriority > 2
							|| (rulePriority == 2 && chosenOpportunity.LastModifiedDate < opp.LastModifiedDate))
					{
						chosenOpportunity = opp;
						rulePriority = 2;
					}
				}
				else
				{ // if no other condtions are met choose most recent Opp created before Quote was created
					if(chosenOpportunity == null || rulePriority > 3
							|| (rulePriority == 3 && chosenOpportunity.LastModifiedDate < opp.LastModifiedDate))
					{
						chosenOpportunity = opp;
						rulePriority = 3;
					}
				}
			}
		}
		return chosenOpportunity;
	}

	/**
	 * @description Maps the response from the callout to AW_Quoted_Solution__c object
	 *
	 * @param benefit 
	 * @param mContract 
	 * @param mQuote 
	 * @param mLive 
	 *
	 * @return AW_Quoted_Solution__c
	 *
	 * @author Paweł Czermiński
	 */
	private AW_Quoted_Solution__c populateQuotedSolution(DTO_Benefit benefit, DTO_Contract mContract, DTO_Quote mQuote, DTO_Life mLive)
	{
		AW_Quoted_Solution__c newQuotedSolution = new AW_Quoted_Solution__c();

		newQuotedSolution.Name = mQuote.quoteNumber + ' ' + benefit.benefitTypeText;
		newQuotedSolution.AW_Contract_Number__c = mContract.contractNumber;
		newQuotedSolution.AW_Contract_Status__c = mContract.contractStatusCode;
		newQuotedSolution.AW_Life_Assured__c = mLive.initials + ' ' + mLive.surname;
		newQuotedSolution.AW_Benefit_Type__c = benefit.benefitTypeCode;
		newQuotedSolution.AW_Benefit_Category__c = benefit.benefitCategoryText;
		newQuotedSolution.AW_Single_Premium_Amount__c = benefit.singlePremiumAmount != null ? Decimal.valueOf(benefit.singlePremiumAmount) : null;
		newQuotedSolution.AW_Recurring_Premium_Amount__c = benefit.recurringPremiumAmount != null ? Decimal.valueOf(benefit.recurringPremiumAmount) : null;
		newQuotedSolution.AW_Recurring_Premium_Frequency__c = benefit.recurringPremiumFrequencyCode;
		newQuotedSolution.AW_Recurring_Premium_Escalation__c = benefit.recurringPremiumEscalationPercentage != null ? Decimal.valueOf(benefit.recurringPremiumEscalationPercentage) : null;
		newQuotedSolution.AW_Sum_Assured__c = benefit.summAssuredAmount != null ? Decimal.valueOf(benefit.summAssuredAmount) : null;
		newQuotedSolution.AW_Nett_Annuity_Amount__c = benefit.netAnnuityAmount != null ? Decimal.valueOf(benefit.netAnnuityAmount) : null;
		newQuotedSolution.AW_Annuity_Frequency__c = benefit.annuityFrequencyCode;
		newQuotedSolution.AW_Income_Escalation__c = benefit.incomeEscalationPercentage != null ? Decimal.valueOf(benefit.incomeEscalationPercentage) : null;
		newQuotedSolution.AW_Withdrawal_Amount__c = benefit.withdrawalAmount != null ? Decimal.valueOf(benefit.withdrawalAmount) : null;
		newQuotedSolution.AW_Withdrawal_Frequency__c = benefit.withdrawalFrequencyCode;
		newQuotedSolution.AW_Withdrawal_Increase__c = benefit.withdrawalIncreasePercentage != null ? Decimal.valueOf(benefit.withdrawalIncreasePercentage) : null;
		newQuotedSolution.AW_Source_System_Name__c = SOURCE_SYSTEM_NAME_BPO;
		newQuotedSolution.AW_TF_External_Id__c = mQuote.quoteNumber + mLive.initials + mLive.surname + mLive.dateOfBirth + benefit.benefitTypeCode;

		return newQuotedSolution;
	}

	/**
	 * @description Maps the response from the callout to Quote object.
	 *
	 * @param dtoQuote 
	 * @param contractsNumbers 
	 *
	 * @return Quote
	 *
	 * @author Paweł Czermiński
	 */
	private Quote populateQuote(DTO_Quote dtoQuote, String contractsNumbers)
	{
		Quote newQuote = new Quote();

		newQuote.Name = dtoQuote.quoteNumber;
		newQuote.AW_Quote_Solution_Number__c = dtoQuote.quoteNumber;
		newQuote.AW_Product_Type__c = dtoQuote.productTypeCode;
		newQuote.Status = dtoQuote.quoteStatusCode;
		newQuote.AW_Quote_Date__c = CMN_UTIL_Date.iso8601StringToDate(dtoQuote.quoteDate);
		newQuote.AW_Quote_DateTime__c = CMN_UTIL_Date.iso8601StringToDateTime(dtoQuote.quoteDate);
		newQuote.AW_Product_Category__c = dtoQuote.productCategory;
		newQuote.AW_Currency__c = dtoQuote.currencyText;
		newQuote.AW_Total_Investment_Amount__c = dtoQuote.totalInvestmentAmount != null ? Decimal.valueOf(dtoQuote.totalInvestmentAmount) : null;
		newQuote.AW_Total_Premium_Amount__c = dtoQuote.totalPremiumAmount != null ? Decimal.valueOf(dtoQuote.totalPremiumAmount) : null;
		newQuote.AW_Contract_Numbers__c = contractsNumbers;
		newQuote.AW_Source_System_Name__c = SOURCE_SYSTEM_NAME_BPO;

		return newQuote;
	}

	//TODO: Comment class
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public List<DTO_Quote> quotesList = new List<DTO_Quote>();

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_Response.class;
		}
	}

	//TODO: Comment class
	private class DTO_Quote
	{
		public String quoteNumber;
		public String quoteStatusCode;
		//public String quoteStatusText;
		public String quoteDate;
		public String productCategory;
		public String productTypeCode;
		//public String productTypeText;
		//public String sourceText;
		public String currencyText;
		public String totalInvestmentAmount;
		public String totalPremiumAmount;
		public List<DTO_Contract> contracts;
	}

	/**
	 * @description DTO to specify contracts structure
	 */
	public class DTO_Contract
	{
		public String contractNumber;
		public String contractStatusCode;
		//public String contractStatusText;
		//public String productCode;
		//public String productText;
		public List<DTO_Life> lives;
	}

	/**
	 * @description DTO to specify lives structure
	 */
	public class DTO_Life
	{
		//public String roleText;
		public String initials;
		public String surname;
		public String dateOfBirth;
		//public String genderText;
		public List<DTO_Benefit> benefits;
	}

	/**
	 * @description DTO to specify benefits structure
	 */
	public class DTO_Benefit
	{
		public String benefitTypeCode;
		public String benefitTypeText;
		public String benefitCategoryText;
		public String singlePremiumAmount;
		public String recurringPremiumAmount;
		public String recurringPremiumFrequencyCode;
		//public String recurringPremiumFrequencyText;
		public String recurringPremiumEscalationPercentage;
		public String summAssuredAmount;
		public String netAnnuityAmount;
		public String annuityFrequencyCode;
		//public String annuityFrequencyText;
		public String incomeEscalationPercentage;
		public String withdrawalAmount;
		public String withdrawalFrequencyCode;
		//public String withdrawalFrequencyText;
		public String withdrawalIncreasePercentage;
	}

	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	public class AW_API_RestOutboundQuoteInfoMock extends CMN_API_HttpBaseOutboundMock
	{

		private final String VALID_RESPONSE_QUOTE_PROPOSED = '[ { "quoteNumber": "49081032", "quoteStatusCode": "3", "quoteStatusText": "Calculated Error Free", "quoteDate": "2019-06-12T15:42:32.480", "productCategory": "Risk", "productTypeCode": "264", "productTypeText": "Lifestyle Protector", "sourceText": "Back to Back", "currencyText": "R", "totalInvestmentAmount": "0.00", "totalPremiumAmount": "2625.39", "contracts": [ { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "94", "benefitTypeText": "Life Cover", "benefitCategoryText": "LifeCover", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "2085.74", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "10000000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "100", "benefitTypeText": "Living Lifestyle Plus (to age 65)", "benefitCategoryText": "SevereIllness", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "195.78", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "1000000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "110", "benefitTypeText": "Capital Disability (OOD)", "benefitCategoryText": "PermanentDisability", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "53.00", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "1000000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "113", "benefitTypeText": "Future Protector", "benefitCategoryText": "None", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "35.00", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "1000000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "126", "benefitTypeText": "Living Lifestyle Plus Extended Cover (to 65)", "benefitCategoryText": "SevereIllness", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "2.95", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "1000000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "127", "benefitTypeText": "Living Lifestyle Plus Top-Up Cover (to 65)", "benefitCategoryText": "SevereIllness", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "137.74", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "1000000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "131", "benefitTypeText": "Premium Protector - Retrenchment", "benefitCategoryText": "None", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "100.18", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "3430.70", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" } ] }, { "roleText": "Spouse", "initials": null, "surname": "Test", "dateOfBirth": "1967-10-26T00:00:00", "genderText": "Female", "benefits": [ { "benefitTypeCode": "94", "benefitTypeText": "Life Cover", "benefitCategoryText": "LifeCover", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "471.00", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "1000000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "104", "benefitTypeText": "Living Lifestyle (to age 65)", "benefitCategoryText": "SevereIllness", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "77.40", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "100000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "109", "benefitTypeText": "Capital Disability (OD)", "benefitCategoryText": "PermanentDisability", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "276.00", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "1000000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "122", "benefitTypeText": "Living Lifestyle Extended Cover (to 65)", "benefitCategoryText": "SevereIllness", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "4.90", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "100000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "123", "benefitTypeText": "Living Lifestyle Top-Up Cover (to 65)", "benefitCategoryText": "SevereIllness", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "36.40", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "100000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "131", "benefitTypeText": "Premium Protector - Retrenchment", "benefitCategoryText": "None", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "100.18", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "3430.70", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49081022", "quoteStatusCode": "3", "quoteStatusText": "Calculated Error Free", "quoteDate": "2019-06-12T14:30:12", "productCategory": "Investment", "productTypeCode": "445", "productTypeText": "Agile Retirement Annuity", "sourceText": "Compulsory", "currencyText": "R", "totalInvestmentAmount": "519000.00", "totalPremiumAmount": "0.00", "contracts": [ { "contractNumber": "68567597", "contractStatusCode": "1", "contractStatusText": "Load/CC Outstanding", "productCode": "445", "productText": "Agile Retirement Annuity", "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "Agile Retirement Annuity", "benefitCategoryText": "None", "singlePremiumAmount": "519000.00", "recurringPremiumAmount": "897.00", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "20.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "20.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49081020", "quoteStatusCode": "3", "quoteStatusText": "Calculated Error Free", "quoteDate": "", "productCategory": "Investment", "productTypeCode": "436", "productTypeText": "GateWay Investment Plan", "sourceText": "Ordinary", "currencyText": "R", "totalInvestmentAmount": "435000.00", "totalPremiumAmount": "1356.00", "contracts": [ { "contractNumber": "68567572", "contractStatusCode": "1", "contractStatusText": "Load/CC Outstanding", "productCode": "436", "productText": "GateWay Investment Plan", "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "GateWay Investment Plan", "benefitCategoryText": "None", "singlePremiumAmount": "435000.00", "recurringPremiumAmount": "1356.00", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "100.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "100.00", "withdrawalAmount": "2450.00", "withdrawalFrequencyCode": "4", "withdrawalFrequencyText": "Quarterly", "withdrawalIncreasePercentage": "100.00" } ] } ] } ] }, { "quoteNumber": "49081008", "quoteStatusCode": "7", "quoteStatusText": "Incomplete Load", "quoteDate": "2019-06-12T12:15:48", "productCategory": "Investment", "productTypeCode": "432", "productTypeText": "Liberty Evolve Investment Plan", "sourceText": "Ordinary", "currencyText": "R", "totalInvestmentAmount": "0.00", "totalPremiumAmount": "0.00", "contracts": [ { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "New Investment Series", "benefitCategoryText": "None", "singlePremiumAmount": null, "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "0", "recurringPremiumFrequencyText": "(None)", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49081007", "quoteStatusCode": "7", "quoteStatusText": "Incomplete Load", "quoteDate": "2019-06-13T12:14:57", "productCategory": "Investment", "productTypeCode": "434", "productTypeText": "Liberty Evolve Pension/Provident Preserver", "sourceText": "Ordinary", "currencyText": "R", "totalInvestmentAmount": "0.00", "totalPremiumAmount": "0.00", "contracts": [ { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "New Investment Series", "benefitCategoryText": "None", "singlePremiumAmount": null, "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "0", "recurringPremiumFrequencyText": "(None)", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49081002", "quoteStatusCode": "3", "quoteStatusText": "Calculated Error Free", "quoteDate": "2019-06-12T12:09:25", "productCategory": "Investment", "productTypeCode": "252", "productTypeText": "Investment Plan with Income (300_CBIO)", "sourceText": "Ordinary", "currencyText": "R", "totalInvestmentAmount": "524000.00", "totalPremiumAmount": "524000.00", "contracts": [ { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "New Investment Series", "benefitCategoryText": "None", "singlePremiumAmount": "365783.89", "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "0", "recurringPremiumFrequencyText": "(None)", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": "0", "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "56", "benefitTypeText": "Immediate Annuity", "benefitCategoryText": "None", "singlePremiumAmount": "158216.11", "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "0", "recurringPremiumFrequencyText": "(None)", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "2578.00", "annuityFrequencyCode": "3", "annuityFrequencyText": "Monthly", "incomeEscalationPercentage": "5.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49080994", "quoteStatusCode": "3", "quoteStatusText": "Calculated Error Free", "quoteDate": "2019-06-12T11:31:21", "productCategory": "Investment", "productTypeCode": "432", "productTypeText": "Liberty Evolve Investment Plan", "sourceText": "Ordinary", "currencyText": "R", "totalInvestmentAmount": "297000.00", "totalPremiumAmount": "26799.00", "contracts": [ { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "New Investment Series", "benefitCategoryText": "None", "singlePremiumAmount": "278200.00", "recurringPremiumAmount": "18800.00", "recurringPremiumFrequencyCode": "2", "recurringPremiumFrequencyText": "Half-Annually", "recurringPremiumEscalationPercentage": "5.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "5.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "4", "withdrawalFrequencyText": "Quarterly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "71", "benefitTypeText": "GateWay Investment Plan", "benefitCategoryText": "None", "singlePremiumAmount": "18800.00", "recurringPremiumAmount": "1659.00", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "4.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "4.00", "withdrawalAmount": "3450.00", "withdrawalFrequencyCode": "4", "withdrawalFrequencyText": "Quarterly", "withdrawalIncreasePercentage": "5.00" } ] }, { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "New Investment Series", "benefitCategoryText": "None", "singlePremiumAmount": "200000.00", "recurringPremiumAmount": "3000.00", "recurringPremiumFrequencyCode": "2", "recurringPremiumFrequencyText": "Half-Annually", "recurringPremiumEscalationPercentage": "5.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "5.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "4", "withdrawalFrequencyText": "Quarterly", "withdrawalIncreasePercentage": "0.00" } ] }, { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "New Investment Series", "benefitCategoryText": "None", "singlePremiumAmount": "78200.00", "recurringPremiumAmount": "3340.00", "recurringPremiumFrequencyCode": "2", "recurringPremiumFrequencyText": "Half-Annually", "recurringPremiumEscalationPercentage": "5.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "5.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "4", "withdrawalFrequencyText": "Quarterly", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49080760", "quoteStatusCode": "7", "quoteStatusText": "Incomplete Load", "quoteDate": "2019-06-10T10:45:47", "productCategory": "Investment", "productTypeCode": "252", "productTypeText": "Investment Plan with Income (300_CBIO)", "sourceText": "Voluntary", "currencyText": "R", "totalInvestmentAmount": "632000.00", "totalPremiumAmount": "632000.00", "contracts": [ { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "New Investment Series", "benefitCategoryText": "None", "singlePremiumAmount": "632000.00", "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "0", "recurringPremiumFrequencyText": "(None)", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": "0", "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49080653", "quoteStatusCode": "7", "quoteStatusText": "Incomplete Load", "quoteDate": "2019-06-06T15:13:10", "productCategory": "Investment", "productTypeCode": "416", "productTypeText": "Investment Builder (2000_IB)", "sourceText": null, "currencyText": "R", "totalInvestmentAmount": "0.00", "totalPremiumAmount": "0.00", "contracts": [ { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "Investment Builder (2000_IB)", "benefitCategoryText": "None", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "0", "recurringPremiumFrequencyText": "(None)", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49080652", "quoteStatusCode": "3", "quoteStatusText": "Calculated Error Free", "quoteDate": "2019-06-06T15:08:19", "productCategory": "Investment", "productTypeCode": "416", "productTypeText": "Investment Builder (2000_IB)", "sourceText": null, "currencyText": "R", "totalInvestmentAmount": "456000.00", "totalPremiumAmount": "0.00", "contracts": [ { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "Investment Builder (2000_IB)", "benefitCategoryText": "None", "singlePremiumAmount": "456000.00", "recurringPremiumAmount": "5000.00", "recurringPremiumFrequencyCode": "2", "recurringPremiumFrequencyText": "Half-Annually", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] } ]'; //Copy example response

		private final String VALID_RESPONSE_CASE_SUBMITTED = '[ { "quoteNumber": "49080760", "quoteStatusCode": "7", "quoteStatusText": "Incomplete Load", "quoteDate": "2019-06-10T10:45:47", "productCategory": "Investment", "productTypeCode": "252", "productTypeText": "Investment Plan with Income (300_CBIO)", "sourceText": "Voluntary", "currencyText": "R", "totalInvestmentAmount": "632000.00", "totalPremiumAmount": "632000.00", "contracts": [ { "contractNumber": 68565705, "contractStatusCode": "16", "contractStatusText": "Upload Successful", "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "New Investment Series", "benefitCategoryText": "None", "singlePremiumAmount": "632000.00", "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "0", "recurringPremiumFrequencyText": "(None)", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": "0", "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49080652", "quoteStatusCode": "3", "quoteStatusText": "Calculated Error Free", "quoteDate": "2019-06-06T15:08:19", "productCategory": "Investment", "productTypeCode": "416", "productTypeText": "Investment Builder (2000_IB)", "sourceText": null, "currencyText": "R", "totalInvestmentAmount": "456000.00", "totalPremiumAmount": "0.00", "contracts": [ { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "Investment Builder (2000_IB)", "benefitCategoryText": "None", "singlePremiumAmount": "456000.00", "recurringPremiumAmount": "5000.00", "recurringPremiumFrequencyCode": "2", "recurringPremiumFrequencyText": "Half-Annually", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49080653", "quoteStatusCode": "7", "quoteStatusText": "Incomplete Load", "quoteDate": "2019-06-06T15:13:10", "productCategory": "Investment", "productTypeCode": "416", "productTypeText": "Investment Builder (2000_IB)", "sourceText": null, "currencyText": "R", "totalInvestmentAmount": "0.00", "totalPremiumAmount": "0.00", "contracts": [ { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "Investment Builder (2000_IB)", "benefitCategoryText": "None", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "0", "recurringPremiumFrequencyText": "(None)", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49080283", "quoteStatusCode": "7", "quoteStatusText": "Incomplete Load", "quoteDate": "2019-06-04T09:50:34", "productCategory": "Risk", "productTypeCode": "264", "productTypeText": "Lifestyle Protector", "sourceText": "Back to Back", "currencyText": "R", "totalInvestmentAmount": "0.00", "totalPremiumAmount": "0.00", "contracts": [ { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "147", "benefitTypeText": "Retrenchment Protector", "benefitCategoryText": "None", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "657000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49080059", "quoteStatusCode": "3", "quoteStatusText": "Calculated Error Free", "quoteDate": "2019-05-30T08:41:54", "productCategory": "Investment", "productTypeCode": "252", "productTypeText": "Investment Plan with Income (300_CBIO)", "sourceText": "Ordinary", "currencyText": "R", "totalInvestmentAmount": "456000.00", "totalPremiumAmount": "456000.00", "contracts": [ { "contractNumber": "68565670", "contractStatusCode": "1", "contractStatusText": "Load/CC Outstanding", "productCode": "252", "productText": "Investment Plan with Income (300_CBIO)", "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "New Investment Series", "benefitCategoryText": "None", "singlePremiumAmount": "283140.12", "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "0", "recurringPremiumFrequencyText": "(None)", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": "0", "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "56", "benefitTypeText": "Immediate Annuity", "benefitCategoryText": "None", "singlePremiumAmount": "172859.88", "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "0", "recurringPremiumFrequencyText": "(None)", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "2864.64", "annuityFrequencyCode": "3", "annuityFrequencyText": "Monthly", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49080061", "quoteStatusCode": "3", "quoteStatusText": "Calculated Error Free", "quoteDate": "2019-05-30T09:10:08", "productCategory": "Investment", "productTypeCode": "432", "productTypeText": "Liberty Evolve Investment Plan", "sourceText": "Ordinary", "currencyText": "R", "totalInvestmentAmount": "765000.00", "totalPremiumAmount": "765000.00", "contracts": [ { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "New Investment Series", "benefitCategoryText": "None", "singlePremiumAmount": "709000.00", "recurringPremiumAmount": "56000.00", "recurringPremiumFrequencyCode": "4", "recurringPremiumFrequencyText": "Quarterly", "recurringPremiumEscalationPercentage": "5.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "5.00", "withdrawalAmount": "5000.00", "withdrawalFrequencyCode": "2", "withdrawalFrequencyText": "Half-Annually", "withdrawalIncreasePercentage": "0.00" } ] } ] }, { "contractNumber": "68565705", "contractStatusCode": "1", "contractStatusText": "Load/CC Outstanding", "productCode": "436", "productText": "GateWay Investment Plan", "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "GateWay Investment Plan", "benefitCategoryText": "None", "singlePremiumAmount": "56000.00", "recurringPremiumAmount": "23000.00", "recurringPremiumFrequencyCode": "1", "recurringPremiumFrequencyText": "Annually", "recurringPremiumEscalationPercentage": "1.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "1.00", "withdrawalAmount": "5000.00", "withdrawalFrequencyCode": "2", "withdrawalFrequencyText": "Half-Annually", "withdrawalIncreasePercentage": "0.00" } ] } ] }, { "contractNumber": "68565688", "contractStatusCode": "1", "contractStatusText": "Load/CC Outstanding", "productCode": "432", "productText": "Liberty Evolve Investment Plan", "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "New Investment Series", "benefitCategoryText": "None", "singlePremiumAmount": "354500.00", "recurringPremiumAmount": "1500.00", "recurringPremiumFrequencyCode": "4", "recurringPremiumFrequencyText": "Quarterly", "recurringPremiumEscalationPercentage": "5.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "5.00", "withdrawalAmount": "5000.00", "withdrawalFrequencyCode": "2", "withdrawalFrequencyText": "Half-Annually", "withdrawalIncreasePercentage": "0.00" } ] } ] }, { "contractNumber": "68565695", "contractStatusCode": "1", "contractStatusText": "Load/CC Outstanding", "productCode": "432", "productText": "Liberty Evolve Investment Plan", "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "New Investment Series", "benefitCategoryText": "None", "singlePremiumAmount": "354500.00", "recurringPremiumAmount": "1500.00", "recurringPremiumFrequencyCode": "4", "recurringPremiumFrequencyText": "Quarterly", "recurringPremiumEscalationPercentage": "5.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "5.00", "withdrawalAmount": "5000.00", "withdrawalFrequencyCode": "2", "withdrawalFrequencyText": "Half-Annually", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49080045", "quoteStatusCode": "3", "quoteStatusText": "Calculated Error Free", "quoteDate": "2019-05-29T17:05:23.663", "productCategory": "Risk", "productTypeCode": "264", "productTypeText": "Lifestyle Protector", "sourceText": "Back to Back", "currencyText": "R", "totalInvestmentAmount": "0.00", "totalPremiumAmount": "1913.45", "contracts": [ { "contractNumber": "56353353800", "contractStatusCode": "1", "contractStatusText": "Load/CC Outstanding", "productCode": "264", "productText": "Lifestyle Protector", "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "94", "benefitTypeText": "Life Cover", "benefitCategoryText": "LifeCover", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "1876.65", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "8900000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "109", "benefitTypeText": "Capital Disability (OD)", "benefitCategoryText": "PermanentDisability", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "4.30", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "100000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "113", "benefitTypeText": "Future Protector", "benefitCategoryText": "None", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "17.50", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "500000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "132", "benefitTypeText": "Educator Benefit", "benefitCategoryText": "LifeCover", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "199.37", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" } ] } ] }, { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Spouse", "initials": null, "surname": "Second", "dateOfBirth": "1989-02-03T00:00:00", "genderText": "Female", "benefits": [ { "benefitTypeCode": "94", "benefitTypeText": "Life Cover", "benefitCategoryText": "LifeCover", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "3035.23", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "32890000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "109", "benefitTypeText": "Capital Disability (OD)", "benefitCategoryText": "PermanentDisability", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "7.00", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "200000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "113", "benefitTypeText": "Future Protector", "benefitCategoryText": "None", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "15.60", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "600000.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "132", "benefitTypeText": "Educator Benefit", "benefitCategoryText": "LifeCover", "singlePremiumAmount": "0.00", "recurringPremiumAmount": "100.36", "recurringPremiumFrequencyCode": "3", "recurringPremiumFrequencyText": "Monthly", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "3", "withdrawalFrequencyText": "Monthly", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49076341", "quoteStatusCode": "3", "quoteStatusText": "Calculated Error Free", "quoteDate": "2019-03-28T12:26:08", "productCategory": "Investment", "productTypeCode": "432", "productTypeText": "Liberty Evolve Investment Plan", "sourceText": "Ordinary", "currencyText": "R", "totalInvestmentAmount": "1234567.00", "totalPremiumAmount": "1234567.00", "contracts": [ { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "New Investment Series", "benefitCategoryText": "None", "singlePremiumAmount": "1234567.00", "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "0", "recurringPremiumFrequencyText": "(None)", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" } ] }, { "roleText": "Life Assured", "initials": "F", "surname": "Young", "dateOfBirth": "1998-07-07T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "71", "benefitTypeText": "New Investment Series", "benefitCategoryText": "None", "singlePremiumAmount": "1234567.00", "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "0", "recurringPremiumFrequencyText": "(None)", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": null, "annuityFrequencyText": "None", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] }, { "quoteNumber": "49076365", "quoteStatusCode": "3", "quoteStatusText": "Calculated Error Free", "quoteDate": "2019-03-28T14:56:16", "productCategory": "Investment", "productTypeCode": "186", "productTypeText": "Guaranteed Investment Plan (GCB_IO)", "sourceText": "Ordinary", "currencyText": "R", "totalInvestmentAmount": "444000.00", "totalPremiumAmount": "444000.00", "contracts": [ { "contractNumber": null, "contractStatusCode": null, "contractStatusText": null, "productCode": null, "productText": null, "lives": [ { "roleText": "Life Assured", "initials": "M", "surname": "MaleAPI", "dateOfBirth": "1990-08-08T00:00:00", "genderText": "Male", "benefits": [ { "benefitTypeCode": "59", "benefitTypeText": "Capital Bond", "benefitCategoryText": "None", "singlePremiumAmount": "327646.24", "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "0", "recurringPremiumFrequencyText": "(None)", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "0.00", "annuityFrequencyCode": "3", "annuityFrequencyText": "Monthly", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" }, { "benefitTypeCode": "56", "benefitTypeText": "Immediate Annuity", "benefitCategoryText": "None", "singlePremiumAmount": "116353.76", "recurringPremiumAmount": "0.00", "recurringPremiumFrequencyCode": "0", "recurringPremiumFrequencyText": "(None)", "recurringPremiumEscalationPercentage": "0.00", "summAssuredAmount": "0.00", "netAnnuityAmount": "1922.97", "annuityFrequencyCode": "3", "annuityFrequencyText": "Monthly", "incomeEscalationPercentage": "0.00", "withdrawalAmount": "0.00", "withdrawalFrequencyCode": "0", "withdrawalFrequencyText": "(None)", "withdrawalIncreasePercentage": "0.00" } ] } ] } ] } ]';

		private final String VALID_RESPONSE_QUOTE_WITHOUT_CONTRACT = '[{"quoteNumber":"49081032","quoteStatusCode":"3","quoteStatusText":"Calculated Error Free","quoteDate":"2021-06-12T15:42:32.480","productCategory":"Risk","productTypeCode":"264","productTypeText":"Lifestyle Protector","sourceText":"Back to Back","currencyText":"R","totalInvestmentAmount":"0.00","totalPremiumAmount":"2625.39","contracts":[{"contractNumber":null,"contractStatusCode":null,"contractStatusText":null,"productCode":null,"productText":null,"lives":[{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"94","benefitTypeText":"Life Cover","benefitCategoryText":"LifeCover","singlePremiumAmount":"0.00","recurringPremiumAmount":"2085.74","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"10000000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"}]}]}]}]';

		private final String VALID_RESPONSE_OPP_STAGE_VALIDATION = '[{"quoteNumber":"49081032","quoteStatusCode":"3","quoteStatusText":"Calculated Error Free","quoteDate":"2021-06-12T15:42:32.480","productCategory":"Risk","productTypeCode":"264","productTypeText":"Lifestyle Protector","sourceText":"Back to Back","currencyText":"R","totalInvestmentAmount":"0.00","totalPremiumAmount":"2625.39","contracts":[{"contractNumber":null,"contractStatusCode":null,"contractStatusText":null,"productCode":null,"productText":null,"lives":[{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"94","benefitTypeText":"Life Cover","benefitCategoryText":"LifeCover","singlePremiumAmount":"0.00","recurringPremiumAmount":"2085.74","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"10000000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"}]}]}]},{"quoteNumber":"49081033","quoteStatusCode":"3","quoteStatusText":"Calculated Error Free","quoteDate":"2021-06-12T15:42:32.480","productCategory":"Risk","productTypeCode":"264","productTypeText":"Lifestyle Protector","sourceText":"Back to Back","currencyText":"R","totalInvestmentAmount":"0.00","totalPremiumAmount":"2625.39","contracts":[{"contractNumber":"123","contractStatusCode":"16","contractStatusText":"Case Submitted","productCode":null,"productText":null,"lives":[{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"94","benefitTypeText":"Life Cover","benefitCategoryText":"LifeCover","singlePremiumAmount":"0.00","recurringPremiumAmount":"2085.74","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"10000000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"}]}]},{"contractNumber":"124","contractStatusCode":"16","contractStatusText":"Case Submitted","productCode":null,"productText":null,"lives":[{"roleText":"Life Assured","initials":"F","surname":"OtherAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"94","benefitTypeText":"Life Cover","benefitCategoryText":"LifeCover","singlePremiumAmount":"0.00","recurringPremiumAmount":"2085.74","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"10000000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"}]}]}]},{"quoteNumber":"49081034","quoteStatusCode":"3","quoteStatusText":"Calculated Error Free","quoteDate":"2021-06-12T15:42:32.480","productCategory":"Investment","productTypeCode":"264","productTypeText":"Lifestyle Protector","sourceText":"Back to Back","currencyText":"R","totalInvestmentAmount":"0.00","totalPremiumAmount":"2625.39","contracts":[{"contractNumber":null,"contractStatusCode":null,"contractStatusText":null,"productCode":null,"productText":null,"lives":[{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"94","benefitTypeText":"Life Cover","benefitCategoryText":"LifeCover","singlePremiumAmount":"0.00","recurringPremiumAmount":"2085.74","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"10000000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"}]}]}]}]';

		private final String VALID_RESPONSE_MULTIPLE_QUOTES = '[{"quoteNumber":"49081032","quoteStatusCode":"3","quoteStatusText":"Calculated Error Free","quoteDate":"2019-06-12T15:42:32.480","productCategory":"Risk","productTypeCode":"264","productTypeText":"Lifestyle Protector","sourceText":"Back to Back","currencyText":"R","totalInvestmentAmount":"0.00","totalPremiumAmount":"2625.39","contracts":[{"contractNumber":null,"contractStatusCode":null,"contractStatusText":null,"productCode":null,"productText":null,"lives":[{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"94","benefitTypeText":"Life Cover","benefitCategoryText":"LifeCover","singlePremiumAmount":"0.00","recurringPremiumAmount":"2085.74","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"10000000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"},{"benefitTypeCode":"100","benefitTypeText":"Living Lifestyle Plus (to age 65)","benefitCategoryText":"SevereIllness","singlePremiumAmount":"0.00","recurringPremiumAmount":"195.78","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"1000000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"},{"benefitTypeCode":"110","benefitTypeText":"Capital Disability (OOD)","benefitCategoryText":"PermanentDisability","singlePremiumAmount":"0.00","recurringPremiumAmount":"53.00","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"1000000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"},{"benefitTypeCode":"113","benefitTypeText":"Future Protector","benefitCategoryText":"None","singlePremiumAmount":"0.00","recurringPremiumAmount":"35.00","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"1000000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"},{"benefitTypeCode":"153","benefitTypeText":"The Maternity Pause Option","benefitCategoryText":"SevereIllness","singlePremiumAmount":"0.00","recurringPremiumAmount":"2.95","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"1000000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"},{"benefitTypeCode":"148","benefitTypeText":"Living Lifestyle Protector benefit","benefitCategoryText":"SevereIllness","singlePremiumAmount":"0.00","recurringPremiumAmount":"137.74","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"1000000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"},{"benefitTypeCode":"131","benefitTypeText":"Premium Protector - Retrenchment","benefitCategoryText":"None","singlePremiumAmount":"0.00","recurringPremiumAmount":"100.18","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"3430.70","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"}]},{"roleText":"Spouse","initials":null,"surname":"Test","dateOfBirth":"1967-10-26T00:00:00","genderText":"Female","benefits":[{"benefitTypeCode":"94","benefitTypeText":"Life Cover","benefitCategoryText":"LifeCover","singlePremiumAmount":"0.00","recurringPremiumAmount":"471.00","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"1000000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"},{"benefitTypeCode":"104","benefitTypeText":"Living Lifestyle (to age 65)","benefitCategoryText":"SevereIllness","singlePremiumAmount":"0.00","recurringPremiumAmount":"77.40","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"100000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"},{"benefitTypeCode":"109","benefitTypeText":"Capital Disability (OD)","benefitCategoryText":"PermanentDisability","singlePremiumAmount":"0.00","recurringPremiumAmount":"276.00","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"1000000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"},{"benefitTypeCode":"112","benefitTypeText":"Premium Protector - Disability","benefitCategoryText":"SevereIllness","singlePremiumAmount":"0.00","recurringPremiumAmount":"4.90","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"100000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"},{"benefitTypeCode":"174","benefitTypeText":"Wellness Bonus","benefitCategoryText":"SevereIllness","singlePremiumAmount":"0.00","recurringPremiumAmount":"36.40","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"100000.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"},{"benefitTypeCode":"131","benefitTypeText":"Premium Protector - Retrenchment","benefitCategoryText":"None","singlePremiumAmount":"0.00","recurringPremiumAmount":"100.18","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"3430.70","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"3","withdrawalFrequencyText":"Monthly","withdrawalIncreasePercentage":"0.00"}]}]}]},{"quoteNumber":"49081022","quoteStatusCode":"3","quoteStatusText":"Calculated Error Free","quoteDate":"2019-06-12T14:30:12","productCategory":"Investment","productTypeCode":"445","productTypeText":"Agile Retirement Annuity","sourceText":"Compulsory","currencyText":"R","totalInvestmentAmount":"519000.00","totalPremiumAmount":"0.00","contracts":[{"contractNumber":"68567597","contractStatusCode":"1","contractStatusText":"Load/CC Outstanding","productCode":"445","productText":"Agile Retirement Annuity","lives":[{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"160","benefitTypeText":"Absolute Impairment (Term)","benefitCategoryText":"None","singlePremiumAmount":"519000.00","recurringPremiumAmount":"897.00","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"20.00","summAssuredAmount":"0.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"20.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"0","withdrawalFrequencyText":"(None)","withdrawalIncreasePercentage":"0.00"}]}]}]},{"quoteNumber":"49081020","quoteStatusCode":"3","quoteStatusText":"Calculated Error Free","quoteDate":"","productCategory":"Investment","productTypeCode":"436","productTypeText":"GateWay Investment Plan","sourceText":"Ordinary","currencyText":"R","totalInvestmentAmount":"435000.00","totalPremiumAmount":"1356.00","contracts":[{"contractNumber":"68567572","contractStatusCode":"1","contractStatusText":"Load/CC Outstanding","productCode":"436","productText":"GateWay Investment Plan","lives":[{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"160","benefitTypeText":"Absolute Impairment (Term)","benefitCategoryText":"None","singlePremiumAmount":"435000.00","recurringPremiumAmount":"1356.00","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"100.00","summAssuredAmount":"0.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"100.00","withdrawalAmount":"2450.00","withdrawalFrequencyCode":"4","withdrawalFrequencyText":"Quarterly","withdrawalIncreasePercentage":"100.00"}]}]}]},{"quoteNumber":"49081008","quoteStatusCode":"7","quoteStatusText":"Incomplete Load","quoteDate":"2019-06-12T12:15:48","productCategory":"Investment","productTypeCode":"432","productTypeText":"Liberty Evolve Investment Plan","sourceText":"Ordinary","currencyText":"R","totalInvestmentAmount":"0.00","totalPremiumAmount":"0.00","contracts":[{"contractNumber":null,"contractStatusCode":null,"contractStatusText":null,"productCode":null,"productText":null,"lives":[{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"160","benefitTypeText":"Absolute Impairment (Term)","benefitCategoryText":"None","singlePremiumAmount":null,"recurringPremiumAmount":"0.00","recurringPremiumFrequencyCode":"0","recurringPremiumFrequencyText":"(None)","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"0.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"0","withdrawalFrequencyText":"(None)","withdrawalIncreasePercentage":"0.00"}]}]}]},{"quoteNumber":"49081007","quoteStatusCode":"7","quoteStatusText":"Incomplete Load","quoteDate":"2019-06-13T12:14:57","productCategory":"Investment","productTypeCode":"434","productTypeText":"Liberty Evolve Pension/Provident Preserver","sourceText":"Ordinary","currencyText":"R","totalInvestmentAmount":"0.00","totalPremiumAmount":"0.00","contracts":[{"contractNumber":null,"contractStatusCode":null,"contractStatusText":null,"productCode":null,"productText":null,"lives":[{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"160","benefitTypeText":"Absolute Impairment (Term)","benefitCategoryText":"None","singlePremiumAmount":null,"recurringPremiumAmount":"0.00","recurringPremiumFrequencyCode":"0","recurringPremiumFrequencyText":"(None)","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"0.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"0","withdrawalFrequencyText":"(None)","withdrawalIncreasePercentage":"0.00"}]}]}]},{"quoteNumber":"49081002","quoteStatusCode":"3","quoteStatusText":"Calculated Error Free","quoteDate":"2019-06-12T12:09:25","productCategory":"Investment","productTypeCode":"252","productTypeText":"Investment Plan with Income (300_CBIO)","sourceText":"Ordinary","currencyText":"R","totalInvestmentAmount":"524000.00","totalPremiumAmount":"524000.00","contracts":[{"contractNumber":null,"contractStatusCode":null,"contractStatusText":null,"productCode":null,"productText":null,"lives":[{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"160","benefitTypeText":"Absolute Impairment (Term)","benefitCategoryText":"None","singlePremiumAmount":"365783.89","recurringPremiumAmount":"0.00","recurringPremiumFrequencyCode":"0","recurringPremiumFrequencyText":"(None)","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"0.00","netAnnuityAmount":"0.00","annuityFrequencyCode":"0","annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"0","withdrawalFrequencyText":"(None)","withdrawalIncreasePercentage":"0.00"},{"benefitTypeCode":"156","benefitTypeText":"Capital Disability (Term) (OOD)","benefitCategoryText":"None","singlePremiumAmount":"158216.11","recurringPremiumAmount":"0.00","recurringPremiumFrequencyCode":"0","recurringPremiumFrequencyText":"(None)","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"0.00","netAnnuityAmount":"2578.00","annuityFrequencyCode":"3","annuityFrequencyText":"Monthly","incomeEscalationPercentage":"5.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"0","withdrawalFrequencyText":"(None)","withdrawalIncreasePercentage":"0.00"}]}]}]},{"quoteNumber":"49080994","quoteStatusCode":"3","quoteStatusText":"Calculated Error Free","quoteDate":"2019-06-12T11:31:21","productCategory":"Investment","productTypeCode":"432","productTypeText":"Liberty Evolve Investment Plan","sourceText":"Ordinary","currencyText":"R","totalInvestmentAmount":"297000.00","totalPremiumAmount":"26799.00","contracts":[{"contractNumber":null,"contractStatusCode":null,"contractStatusText":null,"productCode":null,"productText":null,"lives":[{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"174","benefitTypeText":"Wellness Bonus","benefitCategoryText":"None","singlePremiumAmount":"278200.00","recurringPremiumAmount":"18800.00","recurringPremiumFrequencyCode":"2","recurringPremiumFrequencyText":"Half-Annually","recurringPremiumEscalationPercentage":"5.00","summAssuredAmount":"0.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"5.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"4","withdrawalFrequencyText":"Quarterly","withdrawalIncreasePercentage":"0.00"},{"benefitTypeCode":"175","benefitTypeText":"Income Protector benefit","benefitCategoryText":"None","singlePremiumAmount":"18800.00","recurringPremiumAmount":"1659.00","recurringPremiumFrequencyCode":"3","recurringPremiumFrequencyText":"Monthly","recurringPremiumEscalationPercentage":"4.00","summAssuredAmount":"0.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"4.00","withdrawalAmount":"3450.00","withdrawalFrequencyCode":"4","withdrawalFrequencyText":"Quarterly","withdrawalIncreasePercentage":"5.00"}]},{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"176","benefitTypeText":"Bonus Cover benefit","benefitCategoryText":"None","singlePremiumAmount":"200000.00","recurringPremiumAmount":"3000.00","recurringPremiumFrequencyCode":"2","recurringPremiumFrequencyText":"Half-Annually","recurringPremiumEscalationPercentage":"5.00","summAssuredAmount":"0.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"5.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"4","withdrawalFrequencyText":"Quarterly","withdrawalIncreasePercentage":"0.00"}]},{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"166","benefitTypeText":"MediCator","benefitCategoryText":"None","singlePremiumAmount":"78200.00","recurringPremiumAmount":"3340.00","recurringPremiumFrequencyCode":"2","recurringPremiumFrequencyText":"Half-Annually","recurringPremiumEscalationPercentage":"5.00","summAssuredAmount":"0.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"5.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"4","withdrawalFrequencyText":"Quarterly","withdrawalIncreasePercentage":"0.00"}]}]}]},{"quoteNumber":"49080760","quoteStatusCode":"7","quoteStatusText":"Incomplete Load","quoteDate":"2019-06-10T10:45:47","productCategory":"Investment","productTypeCode":"252","productTypeText":"Investment Plan with Income (300_CBIO)","sourceText":"Voluntary","currencyText":"R","totalInvestmentAmount":"632000.00","totalPremiumAmount":"632000.00","contracts":[{"contractNumber":null,"contractStatusCode":null,"contractStatusText":null,"productCode":null,"productText":null,"lives":[{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"162","benefitTypeText":"Living Lifestyle (Term)","benefitCategoryText":"None","singlePremiumAmount":"632000.00","recurringPremiumAmount":"0.00","recurringPremiumFrequencyCode":"0","recurringPremiumFrequencyText":"(None)","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"0.00","netAnnuityAmount":"0.00","annuityFrequencyCode":"0","annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"0","withdrawalFrequencyText":"(None)","withdrawalIncreasePercentage":"0.00"}]}]}]},{"quoteNumber":"49080653","quoteStatusCode":"7","quoteStatusText":"Incomplete Load","quoteDate":"2019-06-06T15:13:10","productCategory":"Investment","productTypeCode":"416","productTypeText":"Investment Builder (2000_IB)","sourceText":null,"currencyText":"R","totalInvestmentAmount":"0.00","totalPremiumAmount":"0.00","contracts":[{"contractNumber":null,"contractStatusCode":null,"contractStatusText":null,"productCode":null,"productText":null,"lives":[{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"176","benefitTypeText":"Bonus Cover benefit","benefitCategoryText":"None","singlePremiumAmount":"0.00","recurringPremiumAmount":"0.00","recurringPremiumFrequencyCode":"0","recurringPremiumFrequencyText":"(None)","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"0.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"0","withdrawalFrequencyText":"(None)","withdrawalIncreasePercentage":"0.00"}]}]}]},{"quoteNumber":"49080652","quoteStatusCode":"3","quoteStatusText":"Calculated Error Free","quoteDate":"2019-06-06T15:08:19","productCategory":"Investment","productTypeCode":"416","productTypeText":"Investment Builder (2000_IB)","sourceText":null,"currencyText":"R","totalInvestmentAmount":"456000.00","totalPremiumAmount":"0.00","contracts":[{"contractNumber":null,"contractStatusCode":null,"contractStatusText":null,"productCode":null,"productText":null,"lives":[{"roleText":"Life Assured","initials":"M","surname":"MaleAPI","dateOfBirth":"1990-08-08T00:00:00","genderText":"Male","benefits":[{"benefitTypeCode":"174","benefitTypeText":"Wellness Bonus","benefitCategoryText":"None","singlePremiumAmount":"456000.00","recurringPremiumAmount":"5000.00","recurringPremiumFrequencyCode":"2","recurringPremiumFrequencyText":"Half-Annually","recurringPremiumEscalationPercentage":"0.00","summAssuredAmount":"0.00","netAnnuityAmount":"0.00","annuityFrequencyCode":null,"annuityFrequencyText":"None","incomeEscalationPercentage":"0.00","withdrawalAmount":"0.00","withdrawalFrequencyCode":"0","withdrawalFrequencyText":"(None)","withdrawalIncreasePercentage":"0.00"}]}]}]}]';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);

			if(responseType == QUOTE_PROPOSED)
			{
				response.setBody(VALID_RESPONSE_QUOTE_PROPOSED);
			}
			else if(responseType == CASE_SUBMITTED)
			{
				response.setBody(VALID_RESPONSE_CASE_SUBMITTED);
			}
			else if(responseType == QUOTE_WITHOUT_CONTRACT)
			{
				response.setBody(VALID_RESPONSE_QUOTE_WITHOUT_CONTRACT);
			}
			else if(responseType == RESPONSE_FOR_OPP_STAGE_VALIDATION)
			{
				response.setBody(VALID_RESPONSE_OPP_STAGE_VALIDATION);
			}
			else if(responseType == RESPONSE_MULTIPLE_QUOTES)
			{
				response.setBody(VALID_RESPONSE_MULTIPLE_QUOTES);
			}
		}
	}

}