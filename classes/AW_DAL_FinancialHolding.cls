/**
 * @description Public class to return the record of Financial Holding
 *
 * @author jayanth.kumar.s@accenture.com jason.van.beukering@accenture.com
 *
 * @date 2019, January 2023
 */
public inherited sharing class AW_DAL_FinancialHolding
{
	private static final String FIELD_CURRENT_VALUE = FinServ__FinancialHolding__c.AW_CurrentValue__c.getDescribe().getLocalName();
	//TODO: Remove to SL DAL Class
	private static final String FIELD_FINANCIAL_ACCOUNT_ENTITY_NUMBER = 'FinServ__FinancialAccount__r.SLSC_EntityNumber__c';
	private static final String FIELD_FINANCIAL_ACCOUNT_PARENT_ACCOUNT_ID = 'FinServ__FinancialAccount__r.FinServ__PrimaryOwner__c';
	private static final String OBJECT_NAME = FinServ__FinancialHolding__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();

	/**
	 * @description stores the fieldAPIName of Product Code
	 */
	public static final String FIELD_PRODUCT_CODE = FinServ__FinancialHolding__c.AW_Product_Code__c.getDescribe().getLocalName();
	/**
	 * @description stores the aliased name of Current Value Field
	 */
	public static final String FIELD_SUM_CURRENT_VALUE = CMN_UTIL_String.lowerCase('Sum') + '_' + FIELD_CURRENT_VALUE;
	/**
	 * @description The record type is being used when creating financial holding records
	 */
	public static final String RT_LIBERTY_FINANCIAL_HOLDING = 'CMN_LibertyFinancialHolding';
	/**
	 * @description Liberty Financial Holding record type id that should be used
	 */
	public static final Id RT_LIBERTY_FINANCIAL_HOLDING_ID =
			CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(FinServ__FinancialHolding__c.SObjectType, AW_DAL_FinancialHolding.RT_LIBERTY_FINANCIAL_HOLDING);

	/**
	 * @description Method to set the fields using in financial holding
	 *
	 * @return A set of the standard fields used by queries when returning financial holdings
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_CURRENT_VALUE,
				FIELD_FINANCIAL_ACCOUNT_ENTITY_NUMBER,
				FinServ__FinancialHolding__c.AW_AUMSourceExternalId__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.AW_NetContribution__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.AW_Product_Code__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.AW_SellingPrice__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.AW_SharePercentage__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.AW_ValueAsAt__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__AssetCategoryName__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__AssetCategory__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__AssetClass__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__FinancialAccount__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__GainLoss__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__Household__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__LastUpdated__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__MarketValue__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__PercentChange__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__Price__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__PrimaryOwner__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__PurchasePrice__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__Securities__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__Shares__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__SourceSystemId__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.FinServ__Symbol__c.getDescribe().getLocalName(),
				FinServ__FinancialHolding__c.Name.getDescribe().getLocalName(),
				//TODO: Remove to SL DAL Class
				FinServ__FinancialHolding__c.SLSC_FundAccNumber__c.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Gets an Financial Holding based on Id
	 *
	 * @param finHoldingId Id of the financial holding
	 *
	 * @return Null or Item
	 */
	public static FinServ__FinancialHolding__c findById(Id finHoldingId)
	{
		return (FinServ__FinancialHolding__c) CMN_DAL_SObjectSelector.findById(OBJECT_NAME, finHoldingId, getDefaultFields());
	}

	/**
	 * @description This method is use to get the Financial Holding Names along with the grouped Current Values
	 *
	 * @param accountId Master Account Id
	 *
	 * @return list of found items
	 */
	public static List<AggregateResult> sumCurrentValuePerHoldingName(Id accountId)
	{
		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.notEquals(FIELD_PRODUCT_CODE, null);
		andCondition.equalsX(FIELD_FINANCIAL_ACCOUNT_PARENT_ACCOUNT_ID, accountId);

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectSumX(FIELD_CURRENT_VALUE)
						.fromX(OBJECT_NAME)
						.whereX(andCondition)
						.groupByX(FIELD_PRODUCT_CODE)
						.limitX(CMN_DAL_SObjectDomain.MAXIMUM_BATCH_SIZE);

		return Database.query(builder.toSoql());
	}
}