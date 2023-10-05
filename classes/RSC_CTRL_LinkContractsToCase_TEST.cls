/**
 * @description Test class related to the RSC_CTRL_LinkContractsToCase
 *
 * @see RSC_CTRL_LinkContractsToCase @story ST-168884
 *
 * @author jayanth.kumar.s@accenture.com meghana.g.n@accenture.com
 *
 * @date August 2021, March 2022, May 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class RSC_CTRL_LinkContractsToCase_TEST
{
	private static final Integer INT_ONE = 1;
	private static final Integer INT_TWO = 2;
	private static final Integer INT_ZERO = 0;

	/**
	 * @description Create data required for unit tests
	 */
	@TestSetup
	private static void setup()
	{
		Account childAccountWithMaster = AW_DAL_TestDataFactory.createPersonChildAccountWithMaster();
		Case newCase = RSC_DAL_TestDataFactory.newCase(INT_ONE, childAccountWithMaster.AW_ParentAccount__c).iterator().next();
		insert newCase;

		InsurancePolicy newPolicy = AW_DAL_TestDataFactory.createInsurancePolicies(childAccountWithMaster, INT_ONE).iterator().next();

		FinServ__FinancialAccount__c newFinancialAccount = AW_DAL_TestDataFactory.createFinancialAccounts(
				childAccountWithMaster, INT_ONE).iterator().next();

		SC_DAL_DataFactory.insertAssociatedContracts(newCase.Id, INT_ONE, newFinancialAccount.Id, null).iterator().next();
		SC_DAL_DataFactory.insertAssociatedContracts(newCase.Id, INT_ONE, null, newPolicy.Id).iterator().next();
	}

	/**
	 * @description to get contracts linked to a Account
	 *
	 * @see RSC_CTRL_LinkContractsToCase.getContractsFromAccount
	 */
	@IsTest
	private static void getContractsFromAccount()
	{
		Case newCase = SC_DAL_Case.getAll().iterator().next();
		Account newAccount = SC_DAL_Account.getAll().iterator().next();

		Test.startTest();

		RSC_CTRL_LinkContractsToCase.DTO_AssociatedContracts contracts = RSC_CTRL_LinkContractsToCase.getContractsFromAccount(newCase.Id, newAccount.Id);

		Test.stopTest();

		System.assertEquals(INT_TWO, contracts.dtoContracts.size(), 'Expected contracts not found in the Account');
	}

	/**
	 * @description to get contracts linked to a Account
	 *
	 * @see RSC_CTRL_LinkContractsToCase.getContractsFromAccount
	 */
	@IsTest
	private static void getContractsFromAccountClientId()
	{
		Case newCase = SC_DAL_Case.getAll().iterator().next();
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

		Test.startTest();

		RSC_CTRL_LinkContractsToCase.DTO_AssociatedContracts contracts = RSC_CTRL_LinkContractsToCase.getContractsFromAccount(newCase.Id, newAccount.Id);

		Test.stopTest();

		System.assertEquals(INT_ZERO, contracts.dtoContracts.size(), 'Contracts found in the Account');
	}

	/**
	 * @description to get contracts linked to a case's parent Account
	 *
	 * @see RSC_CTRL_LinkContractsToCase.getContractsFromAccount
	 */
	@IsTest
	private static void getContractsFromAccountNoClientId()
	{
		Case newCase = SC_DAL_Case.getAll().iterator().next();
		Test.startTest();
		RSC_CTRL_LinkContractsToCase.DTO_AssociatedContracts contracts = RSC_CTRL_LinkContractsToCase.getContractsFromAccount(newCase.Id, null);
		Test.stopTest();
		System.assertEquals(INT_TWO, contracts.dtoContracts.size(), 'Expected contracts not found in the Account');
	}

	/**
	 * @description to get contracts linked to a Account
	 *
	 * @see RSC_CTRL_LinkContractsToCase.getContractsFromAccount
	 */
	@IsTest
	private static void getContractsFromAccountWithoutCase()
	{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

		Test.startTest();

		RSC_CTRL_LinkContractsToCase.DTO_AssociatedContracts contracts = RSC_CTRL_LinkContractsToCase.getContractsFromAccount(null, newAccount.Id);

		Test.stopTest();

		System.assertEquals(INT_ZERO, contracts.dtoContracts.size(), 'Expected contracts not found in the Account');
	}

	/**
	 * @description to get contracts linked to a case
	 *
	 * @see RSC_CTRL_LinkContractsToCase.getContractFromCase
	 */
	@IsTest
	private static void getContractFromCase()
	{
		Case newCase = SC_DAL_Case.getAll().iterator().next();

		Test.startTest();

		List<SC_AssociatedContract__c> associatedContracts = RSC_CTRL_LinkContractsToCase.getContractFromCase(newCase.Id);

		Test.stopTest();

		System.assertEquals(INT_TWO, associatedContracts.size(), 'Expected contracts not found in the Account');
	}

	/**
	 * @description to update contracts linked to a case
	 *
	 * @see RSC_CTRL_LinkContractsToCase.updateContracts
	 */
	@IsTest
	private static void updateContracts()
	{
		Case newCase = SC_DAL_Case.getAll().iterator().next();
		Account newAccount = SC_DAL_Account.getAll().iterator().next();
		InsurancePolicy newPolicy = AW_DAL_TestDataFactory.createInsurancePolicies(newAccount, INT_ONE).iterator().next();

		FinServ__FinancialAccount__c newFinancialAccount = AW_DAL_TestDataFactory.createFinancialAccounts(
				newAccount, INT_ONE).iterator().next();

		List<Id> policyAccounts = new List<Id>();
		policyAccounts.add(newPolicy.Id);
		policyAccounts.add(newFinancialAccount.Id);

		Test.startTest();

		RSC_CTRL_LinkContractsToCase.updateContracts(newCase.Id, policyAccounts);

		Test.stopTest();

		System.assertEquals(INT_TWO, SC_DAL_AssociatedContract.findByParent(newCase.Id).size(), 'Contracts not updated as expected');
	}

	/**
	 * @description to update contracts linked to a case
	 *
	 * @see RSC_CTRL_LinkContractsToCase.updateContracts
	 */
	@IsTest
	private static void updateContractsDelete()
	{
		Case newCase = SC_DAL_Case.getAll().iterator().next();
		List<Id> policyAccounts = new List<Id>();
		Test.startTest();

		RSC_CTRL_LinkContractsToCase.updateContracts(newCase.Id, policyAccounts);

		Test.stopTest();

		System.assertEquals(INT_ZERO, SC_DAL_AssociatedContract.findByParent(newCase.Id).size(), 'Contracts not deleted as expected');
	}
}