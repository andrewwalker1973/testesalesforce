/**
 * @description Test class for InsurancePolicy classes
 *
 * @see AW_TH_InsurancePolicy
 *
 * @author jason.van.beukering@accenture.com jayanth.kumar.s@accenture.com
 *
 * @date 2019, February 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=false)
private class AW_TEST_TH_InsurancePolicy
{
	private static final Integer NUMBER_OF_GOALS_TO_CREATE = 1;
	private static final Integer NUMBER_OF_GOALS_TO_CREATE_BULK = 2;
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 1;
	private static final Integer NUMBER_OF_POLICIES_TO_CREATE = 5;
	private static final String ERROR_ITEM_NOT_LINKED = 'Item was not linked to master account';
	private static final String ERROR_OWNER_NOT_SAME = 'Owner is not same as Account Owner';

	@TestSetup
	private static void insertTestData()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		//Ensure that we create community account and user and community account owned by an adviser
		System.runAs(adviser)
		{
			AW_DAL_TestDataFactory.createClientAccount();
		}
	}

	/**
	 * @description method to get the list of Account
	 *
	 * @return newAccounts
	 */
	private static Account findCreatedAccount()
	{
		List<Account> newAccounts = AW_DAL_Account.getAll();

		Assert.isFalse(newAccounts.isEmpty(), 'Account not created.');

		return newAccounts.iterator().next();
	}

	/**
	 * @description Calculate the total of all policies so we can compare it to the value on the Goal
	 */

	@IsTest
	private static void checkRollupCalculationOnInsert()
	{
		Account createdAccount = findCreatedAccount();

		Test.startTest();

		FinServ__FinancialGoal__c newFinancialGoal = AW_DAL_TestDataFactory.createFinancialGoals(createdAccount, NUMBER_OF_GOALS_TO_CREATE).iterator().next();
		List<InsurancePolicy> newInsurancePolicies = AW_DAL_TestDataFactory.createInsurancePolicies(createdAccount, newFinancialGoal, NUMBER_OF_POLICIES_TO_CREATE);

		Test.stopTest();

		//Calculate the total of all policies so we can compare it to the value on the Goal
		Decimal totalValueOfPolicies = 0;
		for(InsurancePolicy newInsurancePolicy : newInsurancePolicies)
		{
			totalValueOfPolicies = totalValueOfPolicies + newInsurancePolicy.AW_CurrentValue__c;
		}

		newFinancialGoal = AW_DAL_FinancialGoal.findByPrimaryOwner(createdAccount.Id).iterator().next();

		Assert.areEqual(totalValueOfPolicies, newFinancialGoal.AW_TotalInsuranceAmount__c, 'AW_TotalInsuranceAmount__c Amount not calculated correctly');
	}

	/**
	 * @description Calculate the total of all policies so we can compare it to the value on the Goal
	 */
	@IsTest
	private static void checkRollupCalculationOnAmountUpdate()
	{
		Account createdAccount = findCreatedAccount();

		FinServ__FinancialGoal__c newFinancialGoal = AW_DAL_TestDataFactory.createFinancialGoals(createdAccount, NUMBER_OF_GOALS_TO_CREATE).iterator().next();
		List<InsurancePolicy> newInsurancePolicies = AW_DAL_TestDataFactory.createInsurancePolicies(createdAccount, newFinancialGoal, NUMBER_OF_POLICIES_TO_CREATE);

		for(InsurancePolicy newInsurancePolicy : newInsurancePolicies)
		{
			newInsurancePolicy.AW_CurrentValue__c = Decimal.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger());
		}

		Test.startTest();

		update newInsurancePolicies;

		Test.stopTest();

		//Calculate the total of all policies so we can compare it to the value on the Goal
		Decimal totalValueOfPolicies = 0;
		for(InsurancePolicy newInsurancePolicy : newInsurancePolicies)
		{
			totalValueOfPolicies = totalValueOfPolicies + newInsurancePolicy.AW_CurrentValue__c;
		}

		newFinancialGoal = AW_DAL_FinancialGoal.findByPrimaryOwner(createdAccount.Id).iterator().next();

		Assert.areEqual(totalValueOfPolicies, newFinancialGoal.AW_TotalInsuranceAmount__c, 'AW_TotalInsuranceAmount__c Updated Amount not calculated correctly');
	}

	/**
	 * @description Method check  to see what happens with  the  financial goal lookup on an  insurance  policy is altered.
	 */

	@IsTest
	private static void checkRollupCalculationOnGoalIDUpdate()
	{
		Account createdAccount = findCreatedAccount();

		List<FinServ__FinancialGoal__c> newFinancialGoals = AW_DAL_TestDataFactory.createFinancialGoals(createdAccount, NUMBER_OF_GOALS_TO_CREATE_BULK);
		FinServ__FinancialGoal__c newFinancialGoal = newFinancialGoals[0];
		FinServ__FinancialGoal__c newFinancialGoalToUpdateTo = newFinancialGoals[1];

		List<InsurancePolicy> newInsurancePolicies = AW_DAL_TestDataFactory.createInsurancePolicies(createdAccount, newFinancialGoal, NUMBER_OF_POLICIES_TO_CREATE);

		for(InsurancePolicy newInsurancePolicy : newInsurancePolicies)
		{
			newInsurancePolicy.AW_FinancialGoal__c = newFinancialGoalToUpdateTo.Id;
		}

		Test.startTest();

		update newInsurancePolicies;

		Test.stopTest();

		//Calculate the total of all policies so we can compare it to the value on the Goal
		Decimal totalValueOfPolicies = 0;
		for(InsurancePolicy newInsurancePolicy : newInsurancePolicies)
		{
			totalValueOfPolicies = totalValueOfPolicies + newInsurancePolicy.AW_CurrentValue__c;
		}

		newFinancialGoalToUpdateTo = AW_DAL_FinancialGoal.findById(newFinancialGoalToUpdateTo.Id);

		Assert.areEqual
				(
						totalValueOfPolicies,
						newFinancialGoalToUpdateTo.AW_TotalInsuranceAmount__c,
						'AW_TotalInsuranceAmount__c Updated Amount not calculated correctly'
				);
	}

	/**
	 * @description Calculate the total of all policies so we can compare it to the value on the Goal.
	 */

	@IsTest
	private static void deleteAPolicy()
	{
		Account createdAccount = findCreatedAccount();

		FinServ__FinancialGoal__c newFinancialGoal = AW_DAL_TestDataFactory.createFinancialGoals(createdAccount, NUMBER_OF_GOALS_TO_CREATE).iterator().next();
		List<InsurancePolicy> newInsurancePolicies = AW_DAL_TestDataFactory.createInsurancePolicies(createdAccount, newFinancialGoal, NUMBER_OF_POLICIES_TO_CREATE);

		Test.startTest();

		delete newInsurancePolicies.iterator().next();

		newInsurancePolicies.remove(0);

		Test.stopTest();

		//Calculate the total of all policies so we can compare it to the value on the Goal
		Decimal totalValueOfPolicies = 0;
		for(InsurancePolicy newInsurancePolicy : newInsurancePolicies)
		{
			totalValueOfPolicies = totalValueOfPolicies + newInsurancePolicy.AW_CurrentValue__c;
		}

		newFinancialGoal = AW_DAL_FinancialGoal.findByPrimaryOwner(createdAccount.Id).iterator().next();

		Assert.areEqual
				(
						totalValueOfPolicies,
						newFinancialGoal.AW_TotalInsuranceAmount__c,
						'AW_TotalInsuranceAmount__c Amount not calculated correctly after delete'
				);
	}

	@IsTest
	private static void deleteAllPolicies()
	{
		Account createdAccount = findCreatedAccount();

		FinServ__FinancialGoal__c newFinancialGoal = AW_DAL_TestDataFactory.createFinancialGoals(createdAccount, NUMBER_OF_GOALS_TO_CREATE).iterator().next();
		List<InsurancePolicy> newInsurancePolicies = AW_DAL_TestDataFactory.createInsurancePolicies(createdAccount, newFinancialGoal, NUMBER_OF_POLICIES_TO_CREATE);

		Test.startTest();

		delete newInsurancePolicies;

		Test.stopTest();

		newFinancialGoal = AW_DAL_FinancialGoal.findByPrimaryOwner(createdAccount.Id).iterator().next();

		Assert.isNull(newFinancialGoal.AW_TotalInsuranceAmount__c, 'AW_TotalInsuranceAmount__c Amount not set to null as expected.');
	}

	@IsTest
	private static void undeleteAllPolicies()
	{
		Account createdAccount = findCreatedAccount();

		FinServ__FinancialGoal__c newFinancialGoal = AW_DAL_TestDataFactory.createFinancialGoals(createdAccount, NUMBER_OF_GOALS_TO_CREATE).iterator().next();
		List<InsurancePolicy> newInsurancePolicies = AW_DAL_TestDataFactory.createInsurancePolicies(createdAccount, newFinancialGoal, NUMBER_OF_POLICIES_TO_CREATE);

		Test.startTest();

		delete newInsurancePolicies;
		undelete newInsurancePolicies;

		Test.stopTest();

		Decimal totalValueOfPolicies = 0;
		for(InsurancePolicy newInsurancePolicy : newInsurancePolicies)
		{
			totalValueOfPolicies = totalValueOfPolicies + newInsurancePolicy.AW_CurrentValue__c;
		}

		newFinancialGoal = AW_DAL_FinancialGoal.findByPrimaryOwner(createdAccount.Id).iterator().next();
		Assert.areEqual
				(
						totalValueOfPolicies,
						newFinancialGoal.AW_TotalInsuranceAmount__c,
						'AW_TotalInsuranceAmount__c Amount not calculated correctly after undelete'
				);
	}

	/**
	 * @description Test method to test whether a Insurance Policy is related to a Business Master Account on Insert
	 */
	@IsTest
	private static void insertPoliciesWithBusinessMaster()
	{
		Account childAccount = AW_DAL_TestDataFactory.createBusinessChildAccountWithMaster();

		List<FinServ__FinancialGoal__c> financialGoals = AW_DAL_TestDataFactory.createGoals(childAccount.Id, NUMBER_OF_GOALS_TO_CREATE);

		Test.startTest();

		InsurancePolicy newPolicy =
				AW_DAL_TestDataFactory.createInsurancePolicies(childAccount, financialGoals.iterator().next(), NUMBER_OF_POLICIES_TO_CREATE).iterator().next();

		Test.stopTest();

		newPolicy = AW_DAL_InsurancePolicy.findById(newPolicy.Id);

		Assert.isNotNull(newPolicy.AW_MasterAccount__c, ERROR_ITEM_NOT_LINKED);
		Assert.areEqual
				(AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT, newPolicy.CMN_MasterAccountRecordTypeName__c, 'Record Type name not set as expected');
	}

	/**
	 * @description Test method to test whether a InsurancePolicy is assigned to ParentAccount Owner on Insert
	 */
	@IsTest
	private static void updateInsurancePolicyWithAccountOwner()
	{
		Account childAccount = AW_DAL_Account.getAll().iterator().next();

		childAccount = AW_DAL_Account.findById(childAccount.Id);
		List<FinServ__FinancialGoal__c> financialGoals = AW_DAL_TestDataFactory.createGoals(childAccount.Id, NUMBER_OF_ITEMS_TO_CREATE);
		User personalAssistant;

		System.runAs(AW_DAL_User.findActiveAdministrator())
		{
			personalAssistant = AW_DAL_User.findActivePersonalAssistantByAdviser(childAccount.OwnerId);
		}

		InsurancePolicy newPolicy;

		System.runAs(personalAssistant)
		{
			Test.startTest();

			newPolicy = AW_DAL_TestDataFactory.createInsurancePolicies(childAccount, financialGoals.iterator().next(), NUMBER_OF_POLICIES_TO_CREATE).iterator().next();

			Test.stopTest();
		}

		childAccount = AW_DAL_Account.findById(childAccount.Id);
		newPolicy = AW_DAL_InsurancePolicy.findById(newPolicy.Id);
		Assert.areEqual(newPolicy.OwnerId, childAccount.OwnerId, ERROR_OWNER_NOT_SAME);
	}

	/**
	 * @description Test method to test whether a Master Person Account RecordType name is set on InsurancePolicy
	 */
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs,PMD.ApexUnitTestClassShouldHaveAsserts')
	@IsTest
	private static void setMasterPersonAccountRecordTypeName()
	{
		linkToMasterAccount(true);
	}

	/**
	 * @description Test method to test whether a Master Business Account RecordType name is set on InsurancePolicy
	 */
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs,PMD.ApexUnitTestClassShouldHaveAsserts')
	@IsTest
	private static void setMasterBusinessAccountRecordTypeName()
	{
		linkToMasterAccount(false);
	}

	/**
	 * @description common method to check if the master account record type name is populated on InsurancePolicy
	 *
	 * @param isMasterIndividual flag to indicate to link InsurancePolicy to Master Person or Master Individual Account
	 */
	private static void linkToMasterAccount(Boolean isMasterIndividual)
	{
		String recordTypeName = isMasterIndividual ? AW_DAL_Account.RT_PERSON_MASTER_ACCOUNT : AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT;

		Test.startTest();

		InsurancePolicy newPolicy = SC_DAL_DataFactory.linkInsurancePolicyToMasterAccount(isMasterIndividual);

		Test.stopTest();

		newPolicy = AW_DAL_InsurancePolicy.findById(newPolicy.Id);
		Assert.areEqual
				(recordTypeName, newPolicy.CMN_MasterAccountRecordTypeName__c, 'Record Type name not set as expected');
	}
}