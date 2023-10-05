/**
 * @description Test class for AW_TH_Opportunity
 *
 * @see AW_TH_Opportunity
 *
 * @author prashant.k.jain@accenture.com
 *
 * @date 2019, May 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_TH_Opportunity
{
	private static final Integer INT_ONE = 1;
	private static final Integer INT_THREE = 3;
	private static final Integer INT_TWO = 2;
	private static final Integer INT_ZERO = 0;
	private static final Integer NUM_ACCOUNTS_TO_CREATE = 1;
	private static final String ERROR_ITEM_NOT_LINKED = 'Item was not linked to master account';
	private static final String ERROR_OWNER_NOT_SAME = 'Owner is not same as Account Owner';

	/**
	 * @description Tests that the performance numbers for opportunities are calculated correctly on initial insert
	 */
	@IsTest
	private static void performanceNumbersOnInsert()
	{
		User newAdviser = AW_DAL_User.findRandomActiveAdviser();
		Account newAccount;

		System.runAs(newAdviser)
		{
			AW_DAL_TestDataFactory.createFeatureSwitch();
			newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		}

		Test.startTest();

		System.runAs(newAdviser)
		{
			AW_DAL_TestDataFactory.createOpportunities(newAccount, newAdviser, INT_THREE, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY);
		}

		Test.stopTest();

		String compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(newAdviser);
		AW_AdviserPerformance__c updatedPerformance = AW_DAL_AdviserPerformance.findByCompositeId(compositeKey);

		System.assertEquals(INT_THREE, updatedPerformance.AW_NumberOfNewOpportunities__c, 'Number of New Opportunities Incorrect');
		System.assertEquals(INT_ZERO, updatedPerformance.AW_NumberOfOpportunitiesWon__c, 'Number of Won Opportunities Incorrect');
		System.assertEquals(INT_THREE, updatedPerformance.AW_NumberOfOpportunitiesOpen__c, 'Number of Open Opportunities Incorrect');

	}

	/**
	 * @description Tests that the performance numbers for opportunities are calculated correctly after an additional opportunity is added
	 */
	@IsTest
	private static void performanceNumbersOnInsertWithExisting()
	{
		User newAdviser = AW_DAL_User.findRandomActiveAdviser();
		Account newAccount;

		System.runAs(newAdviser)
		{
			AW_DAL_TestDataFactory.createFeatureSwitch();
			newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
			AW_DAL_TestDataFactory.createOpportunities(newAccount, newAdviser, INT_ONE, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY);
		}

		String compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(newAdviser);

		AW_AdviserPerformance__c existingPerformance = AW_DAL_AdviserPerformance.findByCompositeId(compositeKey);
		System.assertNotEquals(null, existingPerformance, 'No existing performance returned');

		Test.startTest();

		System.runAs(newAdviser)
		{
			AW_DAL_TestDataFactory.createOpportunities(newAccount, newAdviser, INT_TWO, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY);
		}

		Test.stopTest();

		AW_AdviserPerformance__c updatedPerformance = AW_DAL_AdviserPerformance.findByCompositeId(compositeKey);

		System.assertEquals(INT_THREE, updatedPerformance.AW_NumberOfNewOpportunities__c, 'Invalid number of new Opportunities');
		System.assertEquals(INT_THREE, updatedPerformance.AW_NumberOfOpportunitiesOpen__c, 'Invalid number of open Opportunities');
	}

	/**
	 * @description Tests that the performance numbers for opportunities that are updated to other statuses
	 */
	@IsTest
	private static void performanceNumbersWithOtherStatusUpdated()
	{
		User newAdviser = AW_DAL_User.findRandomActiveAdviser();

		Opportunity newOpportunity;

		System.runAs(newAdviser)
		{
			AW_DAL_TestDataFactory.createFeatureSwitch();
			Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
			newOpportunity = AW_DAL_TestDataFactory.createOpportunities(newAccount, newAdviser, INT_ONE, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY).iterator().next();
			newOpportunity.StageName = AW_DAL_Opportunity.OPPORTUNITY_STAGE_PERFORM_FNA;
			update newOpportunity;
		}

		String compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(newAdviser);
		AW_AdviserPerformance__c existingPerformance = AW_DAL_AdviserPerformance.findByCompositeId(compositeKey);
		System.assertNotEquals(null, existingPerformance, 'No existing performance returned');

		Test.startTest();

		System.runAs(newAdviser)
		{
			newOpportunity.StageName = AW_DAL_Opportunity.OPPORTUNITY_STAGE_QUOTE_PROPOSED;
			update newOpportunity;
		}

		Test.stopTest();

		AW_AdviserPerformance__c updatedPerformance = AW_DAL_AdviserPerformance.findByCompositeId(compositeKey);

		System.assertEquals(existingPerformance.AW_NumberOfNewOpportunities__c, updatedPerformance.AW_NumberOfNewOpportunities__c, 'Expected no change in number');
		System.assertEquals(existingPerformance.AW_NumberOfOpportunitiesWon__c, updatedPerformance.AW_NumberOfOpportunitiesWon__c, 'Expected no change in number');
		System.assertEquals(existingPerformance.AW_NumberOfOpportunitiesOpen__c, updatedPerformance.AW_NumberOfOpportunitiesOpen__c, 'Expected no change in number');
	}

	/**
	 * @description Tests that the performance numbers for opportunities when an opportunity owner changes
	 */
	@IsTest
	private static void performanceNumbersOnOwnerChange()
	{
		List<User> advisers = AW_DAL_User.findRandomActiveAdvisers(INT_TWO);
		User oldAdviser = advisers.get(INT_ZERO);
		User newAdviser = advisers.get(INT_ONE);

		System.runAs(oldAdviser)
		{
			AW_DAL_TestDataFactory.createFeatureSwitch();
			Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
			AW_DAL_TestDataFactory.createOpportunities(newAccount, oldAdviser, INT_ONE, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY);
		}

		//Check to see that after insert of the opportunity we have found a performance record for the adviser
		String oldAdviserKey = AW_DAL_AdviserPerformance.generateCompositeKey(oldAdviser);
		AW_AdviserPerformance__c oldPerformance = AW_DAL_AdviserPerformance.findByCompositeId(oldAdviserKey);
		System.assertNotEquals(null, oldPerformance, 'Performances not found');

		//Check to see if a performance record exists for the new adviser found, there should be now
		String newAdviserKey = AW_DAL_AdviserPerformance.generateCompositeKey(newAdviser);
		AW_AdviserPerformance__c newPerformance = AW_DAL_AdviserPerformance.findByCompositeId(newAdviserKey);
		System.assertEquals(null, newPerformance, 'No Performance should be found');

		Opportunity foundOpportunity = AW_DAL_Opportunity.getAll().iterator().next();

		Test.startTest();

		System.runAs(oldAdviser)
		{
			foundOpportunity.OwnerId = newAdviser.Id;
			update foundOpportunity;
		}

		Test.stopTest();

		oldPerformance = AW_DAL_AdviserPerformance.findByCompositeId(oldAdviserKey);
		newPerformance = AW_DAL_AdviserPerformance.findByCompositeId(newAdviserKey);

		//Check to see that numbers adjusted correctly
		System.assertEquals
				(
						oldPerformance.AW_NumberOfNewOpportunities__c + INT_ONE,
						newPerformance.AW_NumberOfNewOpportunities__c,
						'Invalid Number of New Opportunities'
				);
		System.assertEquals(oldPerformance.AW_NumberOfOpportunitiesWon__c, newPerformance.AW_NumberOfOpportunitiesWon__c, 'Invalid Number of Opportunities');
		System.assertEquals
				(
						oldPerformance.AW_NumberOfOpportunitiesOpen__c + INT_ONE,
						newPerformance.AW_NumberOfOpportunitiesOpen__c,
						'Invalid Number of Open Opportunities'
				);
	}

	/**
	 * @description Will create an opportunity running as the given adviser user
	 *
	 * @param adviser User to run as
	 *
	 * @return Newly created item
	 */
	private static Opportunity createOpportunity(User adviser)
	{
		Opportunity newOpportunity;

		System.runAs(adviser)
		{
			AW_DAL_TestDataFactory.createFeatureSwitch();
			Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
			newOpportunity = AW_DAL_TestDataFactory.createOpportunities(newAccount, adviser, INT_ONE, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY).iterator().next();
		}

		return newOpportunity;
	}

	/**
	 * @description Tests that the performance numbers for opportunities when an opportunity stage is changed to won
	 */
	@IsTest
	private static void performanceNumbersOnWon()
	{
		User newAdviser = AW_DAL_User.findRandomActiveAdviser();

		Opportunity newOpportunity = createOpportunity(newAdviser);

		String compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(newAdviser);
		AW_AdviserPerformance__c existingPerformance = AW_DAL_AdviserPerformance.findByCompositeId(compositeKey);

		Test.startTest();

		System.runAs(newAdviser)
		{
			newOpportunity.StageName = AW_DAL_Opportunity.OPPORTUNITY_STAGE_CLOSED_WON;
			update newOpportunity;
		}

		Test.stopTest();

		AW_AdviserPerformance__c updatedPerformance = AW_DAL_AdviserPerformance.findByCompositeId(compositeKey);

		System.assertEquals
				(
						existingPerformance.AW_NumberOfNewOpportunities__c,
						updatedPerformance.AW_NumberOfNewOpportunities__c,
						'Invalid Number of New Opportunities'
				);
		System.assertEquals
				(
						existingPerformance.AW_NumberOfOpportunitiesWon__c + INT_ONE,
						updatedPerformance.AW_NumberOfOpportunitiesWon__c,
						'Invalid Number of Won Opportunities'
				);
		System.assertEquals
				(
						existingPerformance.AW_NumberOfOpportunitiesOpen__c - INT_ONE,
						updatedPerformance.AW_NumberOfOpportunitiesOpen__c,
						'Invalid Number of Open Opportunities'
				);
	}

	/**
	 * @description Tests that the performance numbers for opportunities when an opportunity is created with stage set to won
	 */
	@IsTest
	private static void performanceNumbersCreatedWon()
	{
		User newAdviser = AW_DAL_User.findRandomActiveAdviser();
		Account newAccount;

		System.runAs(newAdviser)
		{
			AW_DAL_TestDataFactory.createFeatureSwitch();
			newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		}

		Test.startTest();

		System.runAs(newAdviser)
		{
			Opportunity newOpportunity =
					AW_DAL_TestDataFactory.newOpportunities(newAccount, newAdviser, INT_ONE, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY).iterator().next();
			newOpportunity.StageName = AW_DAL_Opportunity.OPPORTUNITY_STAGE_CLOSED_WON;
			insert newOpportunity;
		}

		Test.stopTest();

		String compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(newAdviser);
		AW_AdviserPerformance__c foundPerformance = AW_DAL_AdviserPerformance.findByCompositeId(compositeKey);

		System.assertNotEquals(null, foundPerformance, 'No performance record found.');
		System.assertEquals(INT_ONE, foundPerformance.AW_NumberOfOpportunitiesWon__c, 'Invalid Number of Opportunities Won');
	}

	/**
	 * @description Tests that the performance numbers for opportunities when an opportunity is deleted
	 */
	@IsTest
	private static void performanceNumbersOnDelete()
	{
		User newAdviser = AW_DAL_User.findRandomActiveAdviser();

		Opportunity newOpportunity = createOpportunity(newAdviser);

		String compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(newAdviser);
		AW_AdviserPerformance__c existingPerformance = AW_DAL_AdviserPerformance.findByCompositeId(compositeKey);

		Test.startTest();

		System.runAs(newAdviser)
		{
			delete newOpportunity;
		}

		Test.stopTest();

		AW_AdviserPerformance__c updatedPerformance = AW_DAL_AdviserPerformance.findByCompositeId(compositeKey);

		System.assertEquals
				(
						existingPerformance.AW_NumberOfNewOpportunities__c - INT_ONE,
						updatedPerformance.AW_NumberOfNewOpportunities__c,
						'Number of new Opportunities not updated correctly'
				);
		System.assertEquals
				(
						existingPerformance.AW_NumberOfOpportunitiesOpen__c - INT_ONE,
						updatedPerformance.AW_NumberOfOpportunitiesOpen__c,
						'Number of open Opportunities not updated correctly'
				);
	}

	/**
	 * @description Tests that the performance numbers for opportunities when an opportunity is undeleted
	 */
	@IsTest
	private static void performanceNumbersOnUndelete()
	{
		User newAdviser = AW_DAL_User.findRandomActiveAdviser();
		Opportunity newOpportunity;

		System.runAs(newAdviser)
		{
			AW_DAL_TestDataFactory.createFeatureSwitch();
			Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
			newOpportunity = AW_DAL_TestDataFactory.createOpportunities(newAccount, newAdviser, INT_ONE, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY).iterator().next();
			delete newOpportunity;
		}

		String compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(newAdviser);
		AW_AdviserPerformance__c existingPerformance = AW_DAL_AdviserPerformance.findByCompositeId(compositeKey);

		Test.startTest();

		System.runAs(newAdviser)
		{
			undelete newOpportunity;
		}

		Test.stopTest();

		AW_AdviserPerformance__c updatedPerformance = AW_DAL_AdviserPerformance.findByCompositeId(compositeKey);

		System.assertEquals
				(
						existingPerformance.AW_NumberOfNewOpportunities__c + INT_ONE,
						updatedPerformance.AW_NumberOfNewOpportunities__c,
						'Number of new Opportunities not updated correctly'
				);
		System.assertEquals
				(
						existingPerformance.AW_NumberOfOpportunitiesOpen__c + INT_ONE,
						updatedPerformance.AW_NumberOfOpportunitiesOpen__c,
						'Number of open Opportunities not updated correctly'
				);
	}

	/**
	 * @description Tests that the performance numbers for opportunities when an opportunity status is updated from won to lost
	 */
	@IsTest
	private static void performanceNumbersToLost()
	{
		User newAdviser = AW_DAL_User.findRandomActiveAdviser();

		Opportunity newOpportunity;

		System.runAs(newAdviser)
		{
			AW_DAL_TestDataFactory.createFeatureSwitch();
			Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
			newOpportunity = AW_DAL_TestDataFactory.createOpportunities(newAccount, newAdviser, INT_ONE, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY).iterator().next();
			newOpportunity.StageName = AW_DAL_Opportunity.OPPORTUNITY_STAGE_CLOSED_WON;
			update newOpportunity;
		}

		String compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(newAdviser);
		AW_AdviserPerformance__c existingPerformance = AW_DAL_AdviserPerformance.findByCompositeId(compositeKey);

		Test.startTest();

		System.runAs(newAdviser)
		{
			newOpportunity.StageName = AW_DAL_Opportunity.OPPORTUNITY_STAGE_CLOSED_LOST;
			update newOpportunity;
		}

		Test.stopTest();

		AW_AdviserPerformance__c updatedPerformance = AW_DAL_AdviserPerformance.findByCompositeId(compositeKey);

		System.assertEquals
				(
						existingPerformance.AW_NumberOfNewOpportunities__c,
						updatedPerformance.AW_NumberOfNewOpportunities__c,
						'Number of new Opportunities not correct'
				);
		System.assertEquals
				(
						existingPerformance.AW_NumberOfOpportunitiesWon__c - INT_ONE,
						updatedPerformance.AW_NumberOfOpportunitiesWon__c,
						'Number of Opportunities not correct'
				);
		System.assertEquals
				(
						existingPerformance.AW_NumberOfOpportunitiesOpen__c,
						updatedPerformance.AW_NumberOfOpportunitiesOpen__c - INT_ONE,
						'Number of open Opportunities not correct'
				);
	}

	/**
	 * @description Test method to test whether a Opportunity is related to MasterAccount on Insert
	 */
	@IsTest
	private static void linkToMaster()
	{
		Account childAccount = AW_DAL_TestDataFactory.createPersonChildAccountWithMaster();

		Test.startTest();

		Opportunity newOpportunity =
				AW_DAL_TestDataFactory.createOpportunities(childAccount, NUM_ACCOUNTS_TO_CREATE, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY).iterator().next();

		Test.stopTest();

		newOpportunity = AW_DAL_Opportunity.findById(newOpportunity.Id);

		System.assertNotEquals(null, newOpportunity.AW_MasterAccount__c, ERROR_ITEM_NOT_LINKED);
	}

	/**
	 * @description Test method to test whether an Opportunity created by Personal Assistant is linked to Account Owner
	 */
	@IsTest
	private static void changeOwner()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		Account childAccount;

		System.runAs(adviser)
		{
			childAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		}

		User personalAssistant = AW_DAL_User.findActivePersonalAssistant();

		Opportunity newOpportunity;

		System.runAs(personalAssistant)
		{
			Test.startTest();

			newOpportunity = AW_DAL_TestDataFactory.createOpportunities(childAccount, INT_ONE, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY).iterator().next();

			Test.stopTest();
		}

		childAccount = AW_DAL_Account.findById(childAccount.Id);
		newOpportunity = AW_DAL_Opportunity.findById(newOpportunity.Id);
		System.assertEquals(newOpportunity.OwnerId, childAccount.OwnerId, ERROR_OWNER_NOT_SAME);
	}
}