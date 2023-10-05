/**
 * @description Public class to return the records of Quote
 *
 * @author vishakha.saini@accenture.com nihal.desai@accenture.com pavan.thammali@liberty.co.za
 *
 * @date 2020, May 2022 , Nov 2022
 */
public inherited sharing class AW_DAL_Quote
{
	private static final String FIELD_ACCOUNT_ID = Quote.AccountId.getDescribe().getLocalName();
	private static final String FIELD_CONTRACT_NUMBER = Quote.AW_Contract_Numbers__c.getDescribe().getLocalName();
	private static final String FIELD_NAME = Quote.Name.getDescribe().getLocalName();
	private static final String FIELD_OPPORTUNITY_ID = Quote.OpportunityId.getDescribe().getLocalName();
	private static final String FIELD_OPPORTUNITY_PRODUCT_INTEREST = 'Opportunity.AW_ProductInterest__c';
	private static final String FIELD_OPPORTUNITY_STAGE_NAME = 'Opportunity.StageName';
	private static final String FIELD_PLANNED_SOLUTION = Quote.AW_Planned_Solution__c.getDescribe().getLocalName();
	private static final String FIELD_SOLUTION_NUMBER = Quote.AW_Quote_Solution_Number__c.getDescribe().getLocalName();
	private static final String FIELD_STATUS = Quote.Status.getDescribe().getLocalName();
	private static final String OBJECT_NAME = Quote.SObjectType.getDescribe().getLocalName();
	/**
	 * @description Picklist Value for Product Type field
	 */
	@TestVisible
	private static final String PRODUCT_TYPE_LIFE_ANNUITY = 'Life Annuity';
	/**  
	 * @description Field name for Quote Product Type
	 */
	public static final String FIELD_PRODUCT_TYPE = Quote.AW_Product_Type__c.getDescribe().getLocalName();
	
	/**
	 * @description Record Type for new business quotes for adviser workbench
	 */
	public static final String RT_NEW_BUSINESS_QUOTE = 'AW_NewBusiness';
	/**
	 * @description Record Type for servicing quotes for adviser workbench
	 */
	public static final String RT_SERVICING_QUOTE = 'AW_ServicingQuote';
	/**
	 * @description Constant string representing Investment Product Category
	 */
	public static final String PRODUCT_CATEGORY_INVESTMENT = 'Investment';
	/**
	 * @description Constant string representing Risk Product Category
	 */
	public static final String PRODUCT_CATEGORY_RISK = 'Risk';
	/**
	 * @description Constant string representing Protection Product Sub Category
	 */
	public static final String PRODUCT_SUB_CATEGORY_PROTECTION = 'Protection';
	/**
	 * @description Constant string epresenting Risk Product Sub Category
	 */
	public static final String PRODUCT_SUB_CATEGORY_INVESTMENT = 'Investment';
	/**
	 * @description Constant string representing Retirement Annuity Product sub Category
	 */
	public static final String PRODUCT_SUB_CATEGORY_RETIREMENT_ANNUITY = 'Retirement Annuity';


	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_ACCOUNT_ID,
				FIELD_CONTRACT_NUMBER,
				FIELD_NAME,
				FIELD_OPPORTUNITY_PRODUCT_INTEREST,
				FIELD_OPPORTUNITY_STAGE_NAME,
				FIELD_SOLUTION_NUMBER,
				Quote.AW_Planned_Solution__c.getDescribe().getLocalName(),
				Quote.AW_Product_Category__c.getDescribe().getLocalName(),
				Quote.Id.getDescribe().getLocalName(),
				Quote.Name.getDescribe().getLocalName(),
				Quote.OpportunityId.getDescribe().getLocalName(),
				Quote.Status.getDescribe().getLocalName(),
				new CMN_SOQL_Query.Field(FIELD_PRODUCT_TYPE).toLabelX().toSoql()
		};
	}

	/**
	 * @description Retrieves the quotes with the given Quote Numbers.
	 *
	 * @param quoteNumbers a list of numbers
	 *
	 * @return a list of quotes
	 */
	public static List<Quote> findByQuoteNumber(Set<String> quoteNumbers)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_SOLUTION_NUMBER, quoteNumbers, getDefaultFields());

	}

	/**
	 * @description Retrieves the quotes having the given ids.
	 *
	 * @param quoteIds a list of ids
	 *
	 * @return a list of items
	 */
	public static List<Quote> findById(Set<Id> quoteIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, quoteIds, getDefaultFields());
	}

	/**
	 * @description Gets a Quote based on Id
	 *
	 * @param quoteId Id of the account
	 *
	 * @return Null or Item
	 */
	public static Quote findById(Id quoteId)
	{
		return (Quote)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, quoteId, getDefaultFields());
	}

	/**
	 * @description Retrieves the quotes with the given Quote Solution Number.
	 *
	 * @param quoteSolutionNumber The solution number of the quote
	 *
	 * @return Null or item
	 */
	public static Quote findByQuoteSolutionNumber(String quoteSolutionNumber)
	{
		return (Quote)CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_SOLUTION_NUMBER, quoteSolutionNumber, getDefaultFields(), true);
	}

	/**
	 * @description Retrieves the quotes with the given Planned Solution Id.
	 *
	 * @param plannedSolutionIds A list of solution Ids
	 *
	 * @return list of found items
	 */
	public static List<Quote> findByPlannedSolutionId(Set<Id> plannedSolutionIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_PLANNED_SOLUTION, plannedSolutionIds, getDefaultFields());
	}

	/**
	 * @description Retrieves the quotes with the given Account Id.
	 *
	 * @param accountId A list of account Id
	 *
	 * @return list of found items
	 */
	public static List<Quote> findByAccountId(Id accountId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_ACCOUNT_ID, new Set<Id> {accountId}, getDefaultFields());
	}

	/**
	 * @description retrieves all Quotes in the system
	 *
	 * @return A list of Quotes
	 */
	@TestVisible
	private static List<Quote> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
		
	/**
	 * @description Method to get the quote with inner select on quoted solution
	 *
	 * @param quoteSolutionNumber The solution number of the quote
	 *
	 * @return Null or the item found
	 */
	@TestVisible
	private static Quote selectQuoteWithChildSelect(String quoteSolutionNumber)
	{
		CMN_DAL_Search.SOQLSearchParameters outerParams = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME,
				new Set<String> {FIELD_STATUS, FIELD_OPPORTUNITY_ID, FIELD_NAME});

		outerParams.searchConditions.equalsX(FIELD_SOLUTION_NUMBER, quoteSolutionNumber);

		CMN_DAL_Search.SOQLSearchParameters childParams = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME,
				new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID}, 'Quoted_Solutions__r');

		outerParams.childSearchParameters.addAll(new Set <CMN_DAL_Search.SOQLSearchParameters> {childParams});

		List<Quote> foundQuotes = CMN_DAL_Search.getObjects(outerParams);

		return foundQuotes.isEmpty() ? null : foundQuotes.iterator().next();
	}
}