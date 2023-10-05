/**
 * @description This class is the apex test class for the class AW_CTR_ContractServicingQuote
 *
 * @see AW_CTRL_ContractServicingQuote
 *
 * @author kiran.kumaryelisetti@lntinfotech.com jason.van.beukering@accenture.com
 *
 * @date 2021-09-03, April 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_CTRL_ContractServicingQuote_TEST
{
	private static final String QUOTE_NUMBER = CMN_DAL_SObjectDomain.generateRandomNumber();
	/**
	 * @description This setup test method prepares the data for the test methods
	 */
	@TestSetup
	private static void setup()
	{
		List<Account> accList = AW_DAL_TestDataFactory.createClientAccount();
		Account setupAcc = accList.iterator().next();
		setupAcc.FinServ__Status__c = AW_DAL_Account.STATUS_ACTIVE;
		update setupAcc;
		List<Opportunity> oppList = AW_DAL_TestDataFactory.createDefaultOpportunities(setupAcc, 1);
		Opportunity setupOpp = oppList.iterator().next();
		List<FinServ__FinancialAccount__c> listAccounts = AW_DAL_TestDataFactory.createFinancialAccounts(setupAcc, 1);
		FinServ__FinancialAccount__c financialAccount = listAccounts.iterator().next();
		financialAccount.FinServ__Status__c = AW_DAL_FinancialAccount.STATUS_IN_FORCE;
		financialAccount.Name = CMN_UTIL_Random.randomNumeric(5);
		update financialAccount;

		List<InsurancePolicy> insuranceList = AW_DAL_TestDataFactory.createInsurancePolicies(setupAcc, 1);
		InsurancePolicy setupInsurance = insuranceList.iterator().next();
		setupInsurance.Status = AW_DAL_InsurancePolicy.STATUS_IN_FORCE;
		update setupInsurance;
		Quote qte = AW_DAL_TestDataFactory.createQuoteWithQuoteNumber(setupOpp.Id, QUOTE_NUMBER, false);
		qte.AW_Contract_Numbers__c = setupInsurance.Name;
		insert qte;
		qte.AW_Contract_Numbers__c = financialAccount.Name;
		update qte;
	}

	/**
	 * @description This test method tests fetchFinancialAccountsTest method behaviour
	 *
	 * @see AW_CTRL_ContractServicingQuote.fetchAccountId
	 * @see AW_CTRL_ContractServicingQuote.getServicingContractWrapper
	 */
	@IsTest
	private static void fetchFinancialAccounts()
	{
		Opportunity foundOpportunity = AW_DAL_Opportunity.getAll().iterator().next();
		Test.startTest();
		Id accountId = AW_CTRL_ContractServicingQuote.fetchAccountId(foundOpportunity.Id);
		System.assertEquals(accountId, foundOpportunity.AccountId, 'After test, opportunity having account should be found');
		AW_CTRL_ContractServicingQuote.DTO_ServicingQuoteList dtoServiceQuotes =
				AW_CTRL_ContractServicingQuote.getServicingContractWrapper(foundOpportunity.AccountId);
		System.assertNotEquals(dtoServiceQuotes, null, 'After test, Insurance Policy/financial account record should be found');
		Test.stopTest();
	}

	/**
	 * @description This test method tests getLabels method behaviour
	 *
	 * @see AW_CTRL_ContractServicingQuote.getLabels
	 */
	@IsTest
	private static void getLabels()
	{
		Test.startTest();
		Map<String, String> accountLabels = AW_CTRL_ContractServicingQuote.getLabels();
		Test.stopTest();
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType leadSchema = schemaMap.get('Quote');
		Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
		String accountNameLabel = fieldMap.get('name').getDescribe().getLabel();
		System.assertEquals(accountNameLabel, accountLabels.get('name'), 'The getLabels method does not get the right label for the Name field on Account');
	}
}