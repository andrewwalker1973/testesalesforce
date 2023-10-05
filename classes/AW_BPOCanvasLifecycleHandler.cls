/**
 * @description This class is the BPO Canvas lifecycle handler
 *
 * @see AW_BPOCanvasLifecycleHandler_TEST
 *
 * @author kiran.kumaryelisetti@lntinfotech.com pavan.t@lntinfotech.com
 *
 * @date November 2020, July 2023
 */
public inherited sharing class AW_BPOCanvasLifecycleHandler implements Canvas.CanvasLifecycleHandler
{
	/**
	 * @description This method is used to exclude some context from the signed request. This is not used here.
	 *
	 * @return Void
	 */
	public Set<Canvas.ContextTypeEnum> excludeContextTypes()
	{
		Set<Canvas.ContextTypeEnum> excluded = new Set<Canvas.ContextTypeEnum>();

		// Code goes here to add items to excluded list
		// that should be excluded from Context data

		return excluded;
	}

	/**
	 * @description This method is used to add custom parameter into the signed request.
	 *
	 * @param renderContext pass the renderContext
	 */
	@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity,PMD.NcssMethodCount')
	public void onRender(Canvas.RenderContext renderContext)
	{
		// Get the Environment context from the RenderContext
		Canvas.EnvironmentContext env = renderContext.getEnvironmentContext();

		// Get current custom params
		Map<String, Object> currentParams = (Map<String, Object>)JSON.deserializeUntyped(env.getParametersAsJSON());

		String plannedSolutionId = (String)currentParams.get('plannedSolutionId');
		String quoteSolutionNumber = (String)currentParams.get('quoteSolutionNumber');
		Boolean isRiskGoalSync = false;
		String shortFallOrSurplusAmount;

		if(String.isNotBlank(plannedSolutionId) && plannedSolutionId != 'null')
		{
			AW_Planned_Solution__c solution = AW_DAL_PlannedSolution.findById(plannedSolutionId);

			String parameter = String.isBlank(solution.AW_Opportunity_Name__r.Account.AW_ClientId__c) ? '0' : solution.AW_Opportunity_Name__r.Account.AW_ClientId__c;
			currentParams.put('clientId', parameter);
			currentParams.put('clientFirstName', solution.AW_Opportunity_Name__r.Account.FirstName);
			currentParams.put('clientLastName', solution.AW_Opportunity_Name__r.Account.LastName);
			currentParams.put('clientRetirementAge', solution.AW_Opportunity_Name__r.Account.Retirement_Age__pc);
			currentParams.put('clientDOB', solution.AW_Opportunity_Name__r.Account.PersonBirthdate);
			currentParams.put('clientIdPassportNumber', solution.AW_Opportunity_Name__r.Account.AW_IdentificationNumber__pc);

			parameter = AW_DAL_Account.PICK_PASSPORT_TYPE.equalsIgnoreCase(solution.AW_Opportunity_Name__r.Account.AW_IdentificationType__pc) ? '1' : '0';
			currentParams.put('clientIdIndicator', parameter);

			currentParams.put('clientPassportCountryOfIssue', solution.AW_Opportunity_Name__r.Account.AW_PassportCountryOfIssue__pr.AW_CountryCode__c);
			currentParams.put('clientTitle', solution.AW_Opportunity_Name__r.Account.Salutation);
			currentParams.put('clientGender', solution.AW_Opportunity_Name__r.Account.FinServ__Gender__pc);

			//Adding Planned solution information
			currentParams.put('solutionName', solution.Name);
			currentParams.put('solutionGUID', solution.AW_SourceSystemId__c);
			currentParams.put('solutionTerm', solution.AW_Term_Months__c);
			currentParams.put('solutionCPI', solution.AW_CPI__c);
			currentParams.put('solutionLumpsumAmount', solution.AW_Lumpsum_Amount__c);
			currentParams.put('solutionGrowthStrategy', solution.AW_Growth_Strategy__c);
			currentParams.put('solutionPremiumAmount', solution.AW_Premium_Amount__c);
			currentParams.put('solutionPremiumFrequency', solution.AW_PremiumFrequency__c);
			currentParams.put('solutionRecommendedMultiStrat', solution.AW_RecommendedMultiStratPortfolio__c);

			//Adding Risk Goal Sync information
			if(solution.AW_Financial_Goal__r.AW_Goal_Type__c == AW_DAL_FinancialGoal.PICK_RISK_GOAL_TYPE)
			{
				isRiskGoalSync = true;
				shortFallOrSurplusAmount = getShortFallOrSurplusAmountParam(solution.AW_Opportunity_Name__r.AccountId);
			}
			currentParams.put('isRiskGoalSync', isRiskGoalSync);
			currentParams.put('shortFallorSurpLusAmount', shortFallOrSurplusAmount);
			//Bug-104874
			if(solution.AW_Opportunity_Name__r.Account.AW_Country_Of_Birth__c != null)
			{
				AW_Country__c country = AW_DAL_Country.findById(solution.AW_Opportunity_Name__r.Account.AW_Country_Of_Birth__c);
				currentParams.put('countryOfBirth', String.valueOf(country.AW_CountryCode__c.intValue()));
			}

			currentParams.put('sfUUID', solution.AW_Opportunity_Name__r.Account.AW_SKF_Id__c);

			//Bug-224128
			Id accountOwnerId = String.isNotBlank(solution?.AW_Opportunity_Name__r?.Account?.Id) ? solution.AW_Opportunity_Name__r.Account.Id : null;
			//Adding User information
			Account currentUser = AW_DAL_Account.findById(accountOwnerId);

			currentParams.put('userConsultantCode', currentUser.Owner.AW_ConsultantCode__c);
			currentParams.put('userUACFId', currentUser.AW_Owner_UACFID__c);
			currentParams.put('sourceSystem', 'Salesforce');
		}

		//Adding Quote id if a quote has been chosen

		if(quoteSolutionNumber == null || quoteSolutionNumber == 'null' || quoteSolutionNumber == '' || quoteSolutionNumber == 'Undefined')
		{
			currentParams.put('quoteSolutionNumber', '0');
		}
		else
		{
			currentParams.put('quoteSolutionNumber', quoteSolutionNumber);
			Quote q = AW_DAL_Quote.findByQuoteSolutionNumber(quoteSolutionNumber);

			String productType = CMN_UTIL_String.EMPTY;
			if(q.AW_Product_Type__c != null)
			{
				productType = isRiskGoalSync ? q.AW_Product_Type__c :
						CMN_UTIL_System.getPicklistValue(Quote.SObjectType, AW_DAL_Quote.FIELD_PRODUCT_TYPE, q.AW_Product_Type__c);
			}
			currentParams.put('quoteProductType', productType);
		}

		//setting the new currentParams into the environment variable of the signed request.
		env.setParametersAsJSON(JSON.serialize(currentParams));
	}
	/**
	 * @description This method will return the comma seperated shortfall/surplus amounts string for risk goal types
	 *
	 * @param accountId The id of the account record to fetch associated risk goals
	 *
	 * @return Returns the parameter
	 */
	private static String getShortFallOrSurplusAmountParam(Id accountId)
	{
		List<FinServ__FinancialGoal__c> financialGoals = AW_DAL_FinancialGoal.findByAccountIdAndGoalType(accountId, AW_DAL_FinancialGoal.PICK_RISK_GOAL_TYPE);
		String shortFallOrSurplusAmount = '';
		if(!financialGoals.isEmpty())
		{
			for(FinServ__FinancialGoal__c fGoal : financialGoals)
			{
				String finalAmount = fGoal.AW_Shortfall__c < 0 ? String.valueOf(fGoal.AW_Shortfall__c) : '0';
				shortFallOrSurplusAmount = shortFallOrSurplusAmount + (fGoal.Name).deleteWhitespace() + ':' + finalAmount + ',';
			}
		}
		return shortFallOrSurplusAmount.removeEnd(',');

	}
}