/**
 * @description This class is the apex controller for Lightning Component hosting the Canvas named
 * 			AW_CTRL_BPOCanvasContainer
 * 			Set as With Sharing to ensure no unauthorized user can execute the class
 *
 * @see AW_CTRL_BPOCanvasContainer_TEST @story ST-155482
 *
 * @author vishakha.saini@accenture.com pavan.thammali@liberty.co.za
 *
 * @date November 2020, November 2022
 */
public inherited sharing class AW_CTRL_BPOCanvasContainer
{
	private static final String FINANCIAL_ACCOUNT = 'Financial Account';
	private static final String INSURANCE_POLICY = 'Insurance Policy';
	/**
	 * @description This aura enabled method create a quote, save the external id of the quote and link the
	 * 				quote to the right solution and the right opportunity.
	 *
	 * @param quoteNumberInExternalSystem (String): The quote number from the external system which needs to be saved as
	 * 				the quote external id.
	 * @param productType : The product type sent by BPO.
	 * @param solutionId (String): The Salesforce id of the quote to update.
	 */
	@AuraEnabled
	@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity, PMD.ApexCRUDViolation')
	public static void createQuoteWithExternalId(String quoteNumberInExternalSystem, String productType, String solutionId)
	{
		if(solutionId == null || solutionId == '' || quoteNumberInExternalSystem == null || quoteNumberInExternalSystem == '')
		{
			return;
		}
		else
		{
			AW_Planned_Solution__c sol = AW_DAL_PlannedSolution.findById(solutionId);
			Opportunity opportunity = AW_DAL_Opportunity.findById(sol.AW_Opportunity_Name__c);

			Quote isQuoteInSalesforceRecord = AW_DAL_Quote.findByQuoteSolutionNumber(quoteNumberInExternalSystem);
			List<Quote> quoteRecords = new List<Quote>();
			if(isQuoteInSalesforceRecord != null)
			{
				quoteRecords.add(isQuoteInSalesforceRecord);
			}
			Integer isQuoteInSalesforce = quoteRecords.size();

			if(isQuoteInSalesforce == 0)
			{
				//TODO: Centralise quote creation code to a factory class
				Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Quote.SObjectType, AW_DAL_Quote.RT_NEW_BUSINESS_QUOTE);
				Quote quoteToCreate = new Quote
						(
								RecordTypeId = recordTypeId,
								OpportunityId = sol.AW_Opportunity_Name__c,
								AW_Planned_Solution__c = sol.Id,
								Name = quoteNumberInExternalSystem,
								AW_Quote_Solution_Number__c = quoteNumberInExternalSystem,
								AW_Product_Category__c = sol.AW_Financial_Goal__r.AW_Goal_Type__c
						);
				upsert quoteToCreate;

				if(opportunity.StageName != AW_DAL_Opportunity.OPPORTUNITY_STAGE_QUOTE_PROPOSED)
				{
					opportunity.StageName = AW_DAL_Opportunity.OPPORTUNITY_STAGE_QUOTE_PROPOSED;
					update opportunity;
				}
			}

			if(productType == null || productType == '' || quoteNumberInExternalSystem == null || quoteNumberInExternalSystem == '')
			{
				return;
			}
			else
			{
				Quote quoteToUpdate = AW_DAL_Quote.findByQuoteSolutionNumber(quoteNumberInExternalSystem);

				if(quoteToUpdate != null)
				{
					quoteToUpdate.AW_Product_Type__c = productType;
					update quoteToUpdate;

					if(opportunity.StageName != AW_DAL_Opportunity.OPPORTUNITY_STAGE_QUOTE_PROPOSED)
					{
						opportunity.StageName = AW_DAL_Opportunity.OPPORTUNITY_STAGE_QUOTE_PROPOSED;
						update opportunity;
					}
				}
				else
				{
					return;
				}
			}
		}
	}

	/**
	 * @description This aura enabled method create a quote, save the external id of the quote, put the record type and
	 * link the quote to the right opportunity.
	 *
	 * @param quoteNumberInExternalSystem (String): The quote number from the external system which needs to be saved as
	 * 				the quote external id.
	 * @param quotePDFName : The link of the quote PDF
	 * @param opportunityId : The opportunity record id to link the quote to it.
	 * @param contractNumber (String): The Contract Number on the quote to update.
	 * @param changeType (String): JSON String Array of change type
	 * @param lifeAssured (String): JSON String Array of lifeAssured
	 * @param financialEntity financialEntityType
	 * @param productCategory quote product category
	 */
	@AuraEnabled
	@SuppressWarnings('PMD.ApexCRUDViolation,PMD.AvoidDeeplyNestedIfStmts,PMD.CognitiveComplexity,PMD.CyclomaticComplexity,PMD.ExcessiveParameterList')
	public static void createQuoteWithExternalIdForContract
			(
					String quoteNumberInExternalSystem,
					String quotePDFName,
					String opportunityId,
					String contractNumber,
					String changeType,
					String lifeAssured,
					String financialEntity,
					String productCategory,
                    String financialEntityName
			)
	{
		Quote quoteRecord;

		List<String> changeTypes = (List<String>)JSON.deserialize(changeType, List<String>.class);
		List<LifeAssured> lifeAssureds = (List<LifeAssured>)JSON.deserialize(lifeAssured, List<LifeAssured>.class);

		if(String.isNotBlank(contractNumber) && String.isNotBlank(quoteNumberInExternalSystem))
		{
			quoteRecord = AW_DAL_Quote.findByQuoteSolutionNumber(quoteNumberInExternalSystem);

			if(quoteRecord == null)
			{
				//When on policy level (no life assured returned) one change selected then Quote Name. = Change type'
				//When on policy level (no life assured returned) and multiple changes then Quote name = 'Various changes'
				String quoteName = changeTypes.size() == 1 ? changeTypes.get(0) : 'Various changes';

				if(lifeAssureds.size() > 0)
				{
					if(lifeAssureds.size() == 1)
					{
						//When one Life Assured  level and once change selected then Quote Name. = 'Change type : Life Assured name'
						//When one Life Assured  level and multiple changes  then Quote Name  = 'Various changes :  Like Assured name'
						List<String> changeTypesList = lifeAssureds.get(0).ChangeTypes;
						quoteName = changeTypesList.size() == 1 ? changeTypesList.get(0) + ' : ' + lifeAssureds.get(0).LifeAssuredName : 'Various changes' + ' : ' +
								lifeAssureds.get(0).LifeAssuredName;
					}
					else
					{
						//When more than one  Life Assured  level  then  Quote Name = 'Various changes'
						quoteName = 'Various changes';
					}
				}

				Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Quote.SObjectType, AW_DAL_Quote.RT_SERVICING_QUOTE);
				Quote quoteToCreate = new Quote
						(
								RecordTypeId = recordTypeId,
								OpportunityId = opportunityId,
								Name = financialEntityName,
								AW_QuoteFileName__c = quotePDFName,
								AW_Contract_Numbers__c = contractNumber,
								AW_Quote_Solution_Number__c = quoteNumberInExternalSystem,
								AW_Quote_Date__c = System.today()
						);
				if(financialEntity == FINANCIAL_ACCOUNT)
				{
					quoteToCreate.AW_Product_Category__c = AW_DAL_Quote.PRODUCT_CATEGORY_INVESTMENT;
					quoteToCreate.AW_ProductSubCategory__c =
							(productCategory == AW_DAL_FinancialAccount.PRODUCT_CATEGORY_INVESTMENT) ?
									AW_DAL_Quote.PRODUCT_SUB_CATEGORY_INVESTMENT :
									((productCategory == AW_DAL_FinancialAccount.PRODUCT_CATEGORY_RETIREMENT) ?
											AW_DAL_Quote.PRODUCT_SUB_CATEGORY_RETIREMENT_ANNUITY : null);
				}
				else if(financialEntity == INSURANCE_POLICY)
				{
					quoteToCreate.AW_Product_Category__c = AW_DAL_Quote.PRODUCT_CATEGORY_RISK;
					quoteToCreate.AW_ProductSubCategory__c = AW_DAL_Quote.PRODUCT_SUB_CATEGORY_PROTECTION;
				}
				insert quoteToCreate;

				Opportunity opportunity = AW_DAL_Opportunity.findById(opportunityId);
				if(opportunity.StageName != AW_DAL_Opportunity.OPPORTUNITY_STAGE_QUOTE_PROPOSED)
				{
					opportunity.StageName = AW_DAL_Opportunity.OPPORTUNITY_STAGE_QUOTE_PROPOSED;
					update opportunity;
				}
			}
		}
	}
	/**
	 * @description This wrapper class is used to deserialize the response from BPO canvas.
	 */
	@SuppressWarnings('PMD.FieldNamingConventions')
	@TestVisible
	private class LifeAssured
	{
		public String LifeAssuredName;
		public List<String> ChangeTypes;
	}
}