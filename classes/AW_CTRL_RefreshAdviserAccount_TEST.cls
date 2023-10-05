/**
 * @description Test class for AW_CTRL_RefreshAdviserAccount
 *
 * @see AW_CTRL_RefreshAdviserAccount
 *
 * @author jason.van.beukering@accenture.com, pavan.t@lntinfotech.com
 *
 * @date July 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=false)
private class AW_CTRL_RefreshAdviserAccount_TEST
{
	private static final String ERROR_ACCOUNT_WITH_NO_POLICIES = 'client does not have associated policies';
	private static final String ERROR_CHILD_ACCOUNT_UPDATE = 'adviser account in not updated as expected';
	private static final String ERROR_NO_FIELDSET_MEMBERS_RETURNED = 'No fieldset members returned';
	private static final String EXPECTED_ACCOUNT_WITH_NO_POLICIES = 'expected client does not have associated policies';

	/**
	 * @description Create data required for unit tests
	 */
	@TestSetup
	private static void setup()
	{
		AW_DAL_TestDataFactory.createMasterPersonAccount();
	}
	/**
	 * @description Check account has the policies
	 *
	 * @see AW_CTRL_RefreshAdviserAccount.checkForAccountPolicies
	 */
	@IsTest
	private static void checkForAccountPoliciesPositiveTest()
	{
		System.runAs(AW_DAL_User.findRandomActiveAdviser())
		{
			Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
			AW_DAL_TestDataFactory.createInsurancePolicies(newAccount, 1);

			Test.startTest();

			Boolean accountHasPolicies = AW_CTRL_RefreshAdviserAccount.checkForAccountPolicies(newAccount.Id);

			Test.stopTest();

			Assert.isTrue(accountHasPolicies, ERROR_ACCOUNT_WITH_NO_POLICIES);
		}
	}
	/**
	 * @description Check account has the policies
	 *
	 * @see AW_CTRL_RefreshAdviserAccount.checkForAccountPolicies
	 */
	@IsTest
	private static void checkForAccountPoliciesNegativeTest()
	{
		System.runAs(AW_DAL_User.findRandomActiveAdviser())
		{
			Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

			Test.startTest();

			Boolean accountHasPolicies = AW_CTRL_RefreshAdviserAccount.checkForAccountPolicies(newAccount.Id);

			Test.stopTest();

			Assert.isFalse(accountHasPolicies, EXPECTED_ACCOUNT_WITH_NO_POLICIES);
		}
	}

	/**
	 * @description to test if the required fieldSet information is retrieved and child is updated with selected fields from parent
	 *
	 * @see AW_CTRL_RefreshAdviserAccount.getFieldDetailsForRecord
	 * @see AW_CTRL_RefreshAdviserAccount.updateChildAccount
	 */
	@IsTest
	private static void checkForFieldSetDTOResponse()
	{
		Account masterAccount = SC_DAL_Account.findAccountByRecordTypeName(AW_DAL_Account.RT_PERSON_MASTER_ACCOUNT).iterator().next();

		System.runAs(AW_DAL_User.findRandomActiveAdviser())
		{
			Account childAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
			Map<Id, Map<String, List<CMN_CTRL_FieldSet.DTO_FieldSetMember>>> dtoFieldSetMembers;
			dtoFieldSetMembers = AW_CTRL_RefreshAdviserAccount.getFieldDetailsForRecord(new List<Id> {childAccount.Id, masterAccount.Id});
			Assert.isFalse(dtoFieldSetMembers.isEmpty(), ERROR_NO_FIELDSET_MEMBERS_RETURNED);

			List<CMN_CTRL_FieldSet.DTO_FieldSetMember> fieldSetMembers = new List<CMN_CTRL_FieldSet.DTO_FieldSetMember>();
			List<String> selectedFields = new List<String>();

			//verifying AW_CTRL_RefreshAdviserAccount.updateChildAccount method using 2 field sets
			fieldSetMembers.addAll(dtoFieldSetMembers.get(masterAccount.Id).get(AW_DAL_Account.FIELDSET_EMPLOYMENT_INFO));
			fieldSetMembers.addAll(dtoFieldSetMembers.get(masterAccount.Id).get(AW_DAL_Account.FIELDSET_DEMOGRAPHIC_INFO));

			for(CMN_CTRL_FieldSet.DTO_FieldSetMember fieldItem : fieldSetMembers)
			{
				selectedFields.add(fieldItem.fieldAPIName);
			}
			Assert.isFalse(selectedFields.isEmpty(), ERROR_NO_FIELDSET_MEMBERS_RETURNED);

			Test.startTest();

			AW_CTRL_RefreshAdviserAccount.updateChildAccount(selectedFields, masterAccount.Id, childAccount.Id);

			Test.stopTest();

			childAccount = AW_DAL_Account.findById(childAccount.Id);

			Assert.areEqual(childAccount.AW_IdentificationNumber__pc, masterAccount.AW_IdentificationNumber__pc, ERROR_CHILD_ACCOUNT_UPDATE);
			Assert.areEqual(childAccount.AW_TaxNumber__pc, masterAccount.AW_TaxNumber__pc, ERROR_CHILD_ACCOUNT_UPDATE);
			Assert.areNotEqual(childAccount.RecordTypeId, masterAccount.RecordTypeId, ERROR_CHILD_ACCOUNT_UPDATE);
		}
	}
}