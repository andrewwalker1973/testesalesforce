/**
 * @description Test class for AW_TH_FNA
 *
 * @see AW_TH_FNA
 *
 * @author Deloitte, vishakha.saini@accenture.com
 *
 * @date 2020, February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_TH_FNA
{
	private static final Integer INT_ONE = 1;
	private static final Integer INT_TWO = 2;
	private static final Integer INT_ZERO = 0;
	private static final String ERROR_ITEM_NOT_LINKED = 'Item was not linked to master account';
	private static final String ERROR_OWNER_NOT_SAME = 'Owner is not same as Account Owner';
	private static final String IDENTITY_NUMBER_NO_OPPORTUNITY = '2401015800087';

	/**
	 * @description Create required test data
	 */
	@TestSetup
	private static void setup()
	{
		AW_DAL_TestDataFactory.createClientAccount(IDENTITY_NUMBER_NO_OPPORTUNITY).iterator().next();
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		AW_DAL_TestDataFactory.createDefaultOpportunities(newAccount, INT_TWO);
	}

	/**
	 * @description This method will test the scenario when FNA is inserted/updated and
	 * 					there is no Opportunity related to the FNAs Account
	 */
	@IsTest
	private static void noOpportunity()
	{
		Account foundAccount = AW_DAL_Account.findByIdentityNumber(IDENTITY_NUMBER_NO_OPPORTUNITY);

		Test.startTest();

		AW_FNA__c newFna = AW_DAL_TestDataFactory.createFNA(foundAccount.Id, INT_ONE).iterator().next();

		Test.stopTest();

		newFna = AW_DAL_FNA.findById(newFna.Id);

		System.assertEquals(newFna.AW_Opportunity__r.StageName, AW_DAL_Opportunity.OPPORTUNITY_STAGE_PERFORM_FNA, 'Invalid Opportunity Stage');

		List<Opportunity> foundOpportunities = AW_DAL_Opportunity.findOpenByAccountId(foundAccount.Id);
		System.assertEquals(INT_ONE, foundOpportunities.size(), 'Opportunities not linked correctly');
	}

	/**
	 * @description This method will test the scenario when FNA is inserted/updated and
	 * 					there is a single "Perform FNA" Opportunity related to that FNAs Account
	 */
	@IsTest
	private static void singleFnaOpportunity()
	{
		Account foundAccount = AW_DAL_Account.findAccountWithDifferentIdentificationNumber(IDENTITY_NUMBER_NO_OPPORTUNITY);

		List<Opportunity> foundOpportunities = AW_DAL_Opportunity.getAll();

		for(Opportunity foundOpportunity : foundOpportunities)
		{
			foundOpportunity.StageName = AW_DAL_Opportunity.OPPORTUNITY_STAGE_PERFORM_FNA;
		}

		update foundOpportunities;

		Test.startTest();

		AW_FNA__c newFna = AW_DAL_TestDataFactory.createFNA(foundAccount.Id, INT_ONE).iterator().next();

		Test.stopTest();

		newFna = AW_DAL_FNA.findById(newFna.Id);

		System.assertEquals(AW_DAL_Opportunity.OPPORTUNITY_STAGE_PERFORM_FNA, newFna.AW_Opportunity__r.StageName, 'Invalid Opportunity Stage');

		foundOpportunities = AW_DAL_Opportunity.findOpenByAccountId(foundAccount.Id);
		System.assertEquals(INT_TWO, foundOpportunities.size(), 'Opportunities not linked correctly');
	}

	/**
	 * @description This method will test the scenario when FNA is inserted/updated and
	 * 					there is a single "Qualify" Opportunity related to that FNAs Account
	 */
	@IsTest
	private static void singleQualifiedOpportunity()
	{
		Account foundAccount = AW_DAL_Account.findAccountWithDifferentIdentificationNumber(IDENTITY_NUMBER_NO_OPPORTUNITY);

		Test.startTest();

		AW_FNA__c newFna = AW_DAL_TestDataFactory.createFNA(foundAccount.Id, INT_ONE).iterator().next();

		Test.stopTest();

		newFna = AW_DAL_FNA.findById(newFna.Id);

		System.assertEquals(AW_DAL_Opportunity.OPPORTUNITY_STAGE_PERFORM_FNA, newFna.AW_Opportunity__r.StageName, 'Invalid Opportunity Stage');

		List<Opportunity> foundOpportunities = AW_DAL_Opportunity.findOpenByAccountId(foundAccount.Id);
		System.assertEquals(INT_TWO, foundOpportunities.size(), 'Opportunities not linked correctly');
	}

	/**
	 * @description This method will test the scenario when FNA is inserted/updated and
	 * 					there are multiple Opportunities in higher stages related to that FNAs Account
	 */
	@IsTest
	private static void higherStageOpportunity()
	{
		Account foundAccount = AW_DAL_Account.findAccountWithDifferentIdentificationNumber(IDENTITY_NUMBER_NO_OPPORTUNITY);

		List<Opportunity> foundOpportunities = AW_DAL_Opportunity.getAll();

		for(Opportunity foundOpportunity : foundOpportunities)
		{
			foundOpportunity.StageName = AW_DAL_Opportunity.OPPORTUNITY_STAGE_BUSINESS_ACCEPTED;
		}

		update foundOpportunities;

		Test.startTest();

		AW_FNA__c newFna = AW_DAL_TestDataFactory.createFNA(foundAccount.Id, INT_ONE).iterator().next();

		Test.stopTest();

		newFna = AW_DAL_FNA.findById(newFna.Id);

		System.assertNotEquals(AW_DAL_Opportunity.OPPORTUNITY_STAGE_PERFORM_FNA, newFna.AW_Opportunity__r.StageName, 'Invalid Opportunity Stage');

		foundOpportunities = AW_DAL_Opportunity.findByAccountIdAndPerformFnaStage(foundAccount.Id);
		System.assertEquals(INT_ZERO, foundOpportunities.size());
	}

	/**
	 * @description Test method to test whether a FNA is related to MasterAccount on Insert
	 */
	@IsTest
	private static void linkToMaster()
	{
		Account childAccount = AW_DAL_TestDataFactory.createPersonChildAccountWithMaster();

		Test.startTest();

		AW_FNA__c newFNA = AW_DAL_TestDataFactory.createFNA(childAccount.Id, INT_ONE).iterator().next();

		Test.stopTest();

		newFNA = AW_DAL_FNA.findByAccountIds(new Set<Id> {childAccount.Id}).iterator().next();
		System.assertNotEquals(null, newFNA.AW_MasterAccount__c, ERROR_ITEM_NOT_LINKED);
	}

	/**
	 * @description Test method to test whether a FNA is related to MasterAccount on Insert
	 */
	@IsTest
	private static void updateFNAWithAccountOwner()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		Account childAccount;

		System.runAs(adviser)
		{
			childAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		}

		User personalAssistant = AW_DAL_User.findActivePersonalAssistant();

		AW_FNA__c newFNA;

		System.runAs(personalAssistant)
		{
			Test.startTest();

			newFNA = AW_DAL_TestDataFactory.createFNA(childAccount.Id, INT_ONE).iterator().next();

			Test.stopTest();
		}

		childAccount = AW_DAL_Account.findById(childAccount.Id);
		newFNA = AW_DAL_FNA.findByAccountIds(new Set<Id> {childAccount.Id}).iterator().next();
		System.assertEquals(newFNA.OwnerId, childAccount.OwnerId, ERROR_OWNER_NOT_SAME);
	}
}