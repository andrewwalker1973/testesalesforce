/**
 * @description Test class for Lead
 *
 * @see AW_TH_Lead
 *
 * @author prashant.k.jain@accenture.com
 *
 * @date 2019, May 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_TH_Lead
{
	private static User adviser;
	private static final Integer INT_ONE = 1;
	private static final Integer INT_THREE = 3;
	private static final Integer INT_TWO = 2;
	private static final Integer INT_ZERO = 0;

	/**
	 * @description Method is use to set up the test data.
	 */
	@TestSetup
	private static void setUpData()
	{
		AW_DAL_TestDataFactory.createFeatureSwitch();

		User adviser = AW_DAL_User.findRandomActiveAdviser();

		//Ensure that we create community account and user and community account owned by an adviser
		System.runAs(adviser)
		{
			AW_DAL_TestDataFactory.createCommunityUser();
		}
	}

	/**
	 * @description This method is use to get the adviser of Accounts
	 *
	 * @return Adviser user record
	 */
	private static User findAdviser()
	{
		List<Account> newAccounts = AW_DAL_Account.getAll();

		System.assertEquals(1, newAccounts.size(), 'Community  Account not created.');

		return AW_DAL_User.findById(newAccounts[0].OwnerId);
	}

	/**
	 * @description Test method to test the lead while creation (Scenario 1)
	 */
	@IsTest
	private static void validateNewLeadCreationWithoutExistingLead()
	{
		adviser = findAdviser();

		String compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(adviser);

		List<Lead> existingLeads = AW_DAL_Lead.findByOwnerId(new List<User> {adviser});
		List<AW_AdviserPerformance__c> existingPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});
		System.assertEquals(INT_ZERO, existingLeads.size());
		System.assertEquals(INT_ZERO, existingPerformances.size());

		Test.startTest();

		AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, INT_THREE, adviser.Id);

		Test.stopTest();

		List<Lead> updatedLeads = AW_DAL_Lead.findByOwnerId(new List<User> {adviser});
		List<AW_AdviserPerformance__c> updatedPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});

		System.assertEquals(INT_THREE, updatedLeads.size());
		System.assertEquals(INT_ONE, updatedPerformances.size());
		System.assertEquals(INT_THREE, updatedPerformances[0].AW_NumberOfNewLeads__c);
		System.assertEquals(INT_ZERO, updatedPerformances[0].AW_NumberOfLeadConverted__c);
		System.assertEquals(INT_THREE, updatedPerformances[0].AW_NumberOfOpenLeads__c);

	}

	/**
	 * @description Test method to test the lead while creation (Scenario w)
	 */
	@IsTest
	private static void validateNewLeadCreationWithExistingLead()
	{
		adviser = findAdviser();

		String compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(adviser);

		List<Lead> existingLeads = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, INT_ONE, adviser.Id);
		List<AW_AdviserPerformance__c> existingPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});

		System.assertEquals(INT_ONE, existingLeads.size());
		System.assertEquals(INT_ONE, existingPerformances.size());

		Test.startTest();

		AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, INT_THREE, adviser.Id);

		Test.stopTest();

		List<Lead> updatedLeads = AW_DAL_Lead.findByOwnerId(new List<User> {adviser});
		List<AW_AdviserPerformance__c> updatedPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});

		System.assertEquals(existingLeads.size() + INT_THREE, updatedLeads.size());
		System.assertEquals(existingPerformances.size(), updatedPerformances.size());
		System.assertEquals(existingPerformances[0].AW_NumberOfNewLeads__c + INT_THREE, updatedPerformances[0].AW_NumberOfNewLeads__c);
		System.assertEquals(existingPerformances[0].AW_NumberOfLeadConverted__c, updatedPerformances[0].AW_NumberOfLeadConverted__c);
		System.assertEquals(existingPerformances[0].AW_NumberOfOpenLeads__c + INT_THREE, updatedPerformances[0].AW_NumberOfOpenLeads__c);
	}

	/**
	 * @description Test method to test the update lead status
	 */
	@IsTest
	private static void validateLeadStatusUpdate()
	{
		adviser = findAdviser();

		List<Lead> leads = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, INT_THREE, adviser.Id);

		// Updating status to Prospect in case lead is created with some other status
		for(Lead existingLead : leads)
		{
			if(existingLead.Status != AW_DAL_Lead.STATUS_NEW)
			{
				existingLead.Status = AW_DAL_Lead.STATUS_NEW;

			}
		}

		update leads;
		// Asserting exiting data
		List<Lead> existingLeads = AW_DAL_Lead.findByOwnerId(new List<User> {adviser});
		List<Lead> existingContactedLeads = CMN_UTIL_System.findWhere(existingLeads, CMN_DAL_Lead.FIELD_STATUS, AW_DAL_Lead.STATUS_INITIATE_1ST_CONTACT);
		System.assertEquals(true, existingContactedLeads.isEmpty());

		String compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(adviser);
		List<AW_AdviserPerformance__c> existingPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});

		Test.startTest();
		for(Lead existingLead : leads)
		{
			existingLead.Status = AW_DAL_Lead.STATUS_INITIATE_1ST_CONTACT;
		}

		update leads;
		Test.stopTest();

		List<Lead> updatedLeads = AW_DAL_Lead.findByOwnerId(new List<User> {adviser});
		List<AW_AdviserPerformance__c> updatedPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});

		System.assertEquals(AW_DAL_Lead.STATUS_INITIATE_1ST_CONTACT, updatedLeads[0].Status);
		System.assertEquals(existingPerformances.size(), updatedPerformances.size());
		System.assertEquals(existingPerformances[0].AW_NumberOfNewLeads__c, updatedPerformances[0].AW_NumberOfNewLeads__c);
		System.assertEquals(existingPerformances[0].AW_NumberOfLeadConverted__c, updatedPerformances[0].AW_NumberOfLeadConverted__c);
		System.assertEquals(existingPerformances[0].AW_NumberOfOpenLeads__c, updatedPerformances[0].AW_NumberOfOpenLeads__c);
	}

	/**
	 * @description Test method to test the update lead status to converted
	 */
	@IsTest
	private static void validateConvertedLeadStatusUpdate()
	{
		adviser = findAdviser();

		List<Lead> leads = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, INT_THREE, adviser.Id);

		// Updating status to Prospect in case lead is created with some other status
		for(Lead existingLead : leads)
		{
			existingLead.Status = AW_DAL_Lead.STATUS_CONVERTED;
		}

		update leads;
		// Asserting exiting data
		List<Lead> existingLeads = AW_DAL_Lead.findByOwnerId(new List<User> {adviser});
		List<Lead> existingContactedLeads = CMN_UTIL_System.findWhere(existingLeads, CMN_DAL_Lead.FIELD_STATUS, AW_DAL_Lead.STATUS_INITIATE_1ST_CONTACT);
		System.assertEquals(true, existingContactedLeads.isEmpty());

		String compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(adviser);
		List<AW_AdviserPerformance__c> existingPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});

		Test.startTest();
		for(Lead existingLead : leads)
		{
			existingLead.Status = AW_DAL_Lead.STATUS_INITIATE_1ST_CONTACT;
		}

		update leads;
		Test.stopTest();

		List<Lead> updatedLeads = AW_DAL_Lead.findByOwnerId(new List<User> {adviser});
		List<AW_AdviserPerformance__c> updatedPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});

		System.assertEquals(AW_DAL_Lead.STATUS_INITIATE_1ST_CONTACT, updatedLeads[0].Status);
		System.assertEquals(existingPerformances.size(), updatedPerformances.size());
		System.assertEquals(existingPerformances[0].AW_NumberOfNewLeads__c, updatedPerformances[0].AW_NumberOfNewLeads__c);
		System.assertEquals(existingPerformances[0].AW_NumberOfLeadConverted__c, updatedPerformances[0].AW_NumberOfLeadConverted__c);
		System.assertEquals(existingPerformances[0].AW_NumberOfOpenLeads__c, updatedPerformances[0].AW_NumberOfOpenLeads__c);
	}

	@IsTest
	private static void validateLeadOwnerChange()
	{
		List<AW_AdviserPerformance__c> oldAdviserPerfBeforeUpdate;
		List<AW_AdviserPerformance__c> oldAdviserPerfAfterUpdate;
		List<AW_AdviserPerformance__c> newPerformances;

		adviser = findAdviser();

		AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, INT_THREE, adviser.Id);

		List<Lead> existingLeads = AW_DAL_Lead.findByOwnerId(new List<User> {adviser});
		String oldAdviserCompositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(adviser);
		oldAdviserPerfBeforeUpdate = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {oldAdviserCompositeKey});
		System.assertEquals(INT_ONE, oldAdviserPerfBeforeUpdate.size());

		User newAdviser = selectNewAdviser();
		String newAdviserCompositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(newAdviser);
		newPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {newAdviserCompositeKey});
		System.assertEquals(INT_ZERO, newPerformances.size());

		Test.startTest();
		for(Lead existingLead : existingLeads)
		{
			existingLead.OwnerId = newAdviser.Id;
		}
		update existingLeads;

		Test.stopTest();

		oldAdviserPerfAfterUpdate = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {oldAdviserCompositeKey});
		newPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {newAdviserCompositeKey});

		System.assertEquals(newAdviser.Id, existingLeads[0].OwnerId);
		System.assertEquals(INT_ONE, newPerformances.size());
		System.assertEquals(oldAdviserPerfBeforeUpdate[0].AW_NumberOfNewLeads__c - INT_THREE, oldAdviserPerfAfterUpdate[0].AW_NumberOfNewLeads__c);
		System.assertEquals(oldAdviserPerfBeforeUpdate[0].AW_NumberOfLeadConverted__c, oldAdviserPerfAfterUpdate[0].AW_NumberOfLeadConverted__c);
		System.assertEquals(oldAdviserPerfBeforeUpdate[0].AW_NumberOfOpenLeads__c - INT_THREE, oldAdviserPerfAfterUpdate[0].AW_NumberOfOpenLeads__c);
		System.assertEquals(INT_THREE, newPerformances[0].AW_NumberOfNewLeads__c);
		System.assertEquals(INT_ZERO, newPerformances[0].AW_NumberOfLeadConverted__c);
		System.assertEquals(INT_THREE, newPerformances[0].AW_NumberOfOpenLeads__c);
	}

	@IsTest
	private static void validateLeadDeletion()
	{
		adviser = findAdviser();

		String compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(adviser);

		List<Lead> existingLeads = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, INT_THREE, adviser.Id);
		List<AW_AdviserPerformance__c> existingPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});
		System.assertEquals(INT_THREE, existingLeads.size());
		System.assertEquals(INT_ONE, existingPerformances.size());

		Test.startTest();
		delete existingLeads;
		Test.stopTest();

		List<Lead> updatedLeads = AW_DAL_Lead.findByOwnerId(new List<User> {adviser});
		List<AW_AdviserPerformance__c> updatedPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});
		System.assertEquals(INT_ZERO, updatedLeads.size());
		System.assertEquals(INT_ONE, updatedPerformances.size());
		System.assertEquals(existingPerformances[0].AW_NumberOfNewLeads__c - INT_THREE, updatedPerformances[0].AW_NumberOfNewLeads__c);
		System.assertEquals(existingPerformances[0].AW_NumberOfOpenLeads__c - INT_THREE, updatedPerformances[0].AW_NumberOfOpenLeads__c);
	}

	@IsTest
	private static void validateLeadRestore()
	{
		adviser = findAdviser();
		String compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(adviser);

		List<Lead> existingLeads = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, INT_THREE, adviser.Id);
		List<AW_AdviserPerformance__c> existingPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});
		System.assertEquals(INT_THREE, existingLeads.size());
		System.assertEquals(INT_ONE, existingPerformances.size());

		Test.startTest();
		delete existingLeads;
		Test.stopTest();

		List<Lead> updatedLeads = AW_DAL_Lead.findByOwnerId(new List<User> {adviser});
		List<AW_AdviserPerformance__c> updatedPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});

		System.assertEquals(INT_ZERO, updatedLeads.size());
		System.assertEquals(INT_ONE, updatedPerformances.size());
		System.assertEquals(existingPerformances[0].AW_NumberOfNewLeads__c - INT_THREE, updatedPerformances[0].AW_NumberOfNewLeads__c);
		System.assertEquals(existingPerformances[0].AW_NumberOfOpenLeads__c - INT_THREE, updatedPerformances[0].AW_NumberOfOpenLeads__c);

		undelete existingLeads;

		List<Lead> unDeletedLeads = AW_DAL_Lead.findByOwnerId(new List<User> {adviser});
		List<AW_AdviserPerformance__c> latestPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});

		System.assertEquals(INT_THREE, unDeletedLeads.size());
		System.assertEquals(INT_ONE, updatedPerformances.size());
		System.assertEquals(existingPerformances[0].AW_NumberOfNewLeads__c, latestPerformances[0].AW_NumberOfNewLeads__c);
		System.assertEquals(existingPerformances[0].AW_NumberOfOpenLeads__c, latestPerformances[0].AW_NumberOfOpenLeads__c);

	}

	/**
	 * @description Test method to test the update gender on change of identity type
	 */
	@IsTest
	private static void checkGenderBirthDateExtractionFromIdentityNumber()
	{
		adviser = findAdviser();

		Test.startTest();

		Lead foundLead = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, INT_ONE, adviser.Id).iterator().next();

		Test.stopTest();

		foundLead = AW_DAL_Lead.findById(foundLead.Id);

		System.assert(String.isNotBlank(foundLead.AW_Gender__c), 'Gender not Set');
		System.assertNotEquals(null, foundLead.AW_DateOfBirth__c, 'Birthdate not Set');

	}

	/**
	 * @description Test method to test the update gender on change of identification number
	 */
	@IsTest
	private static void checkGenderBirthDateExtractionFromIdentityNumberUpdate()
	{
		adviser = findAdviser();

		Lead newLead = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, INT_ONE, adviser.Id).iterator().next();
		Lead originalLead = AW_DAL_Lead.findById(newLead.Id);

		String newIdentificationNumber = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();

		originalLead.AW_IdentificationNumber__c = newIdentificationNumber;
		originalLead.AW_DateOfBirth__c = null;
		originalLead.AW_Gender__c = null;

		Test.startTest();

		update originalLead;

		Test.stopTest();

		Lead foundLead = AW_DAL_Lead.findById(newLead.Id);

		System.assert(String.isNotBlank(foundLead.AW_Gender__c), 'Gender not Set');
		System.assertNotEquals(null, foundLead.AW_DateOfBirth__c, 'Birthdate not Set');
	}

	/**
	 * @description Test method to test the update gender on change of identity type
	 */
	@IsTest
	private static void checkGenderBirthdateOnIdentityTypeChange()
	{
		adviser = findAdviser();

		List<Lead> newLeads = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, INT_ONE, adviser.Id, AW_DAL_Lead.IDENTIFICATION_TYPE_PASSPORT);
		Lead originalLead = AW_DAL_Lead.findById(newLeads.iterator().next().Id);

		originalLead.AW_IdentificationType__c = AW_DAL_Lead.IDENTIFICATION_TYPE_SA_ID;

		Test.startTest();

		update originalLead;

		Test.stopTest();

		Lead foundLead = AW_DAL_Lead.findById(originalLead.Id);

		System.assert(String.isNotBlank(foundLead.AW_Gender__c), 'Gender not Set');
		System.assertNotEquals(null, foundLead.AW_DateOfBirth__c, 'Birthdate not Set');

	}

	/**
	 * @description Test method to test the update gender on change of identification number
	 */
	@IsTest
	private static void checkGenderBirthdateOnIdentificationNumberChange()
	{
		adviser = findAdviser();

		List<Lead> newLeads = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, INT_ONE, adviser.Id, null);
		Lead originalLead = AW_DAL_Lead.findById(newLeads.iterator().next().Id);

		originalLead.AW_IdentificationType__c = AW_DAL_Lead.IDENTIFICATION_TYPE_SA_ID;
		originalLead.AW_IdentificationNumber__c = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();

		Test.startTest();

		update originalLead;

		Test.stopTest();

		Lead foundLead = AW_DAL_Lead.findById(originalLead.Id);

		System.assert(String.isNotBlank(foundLead.AW_Gender__c), 'Gender not Set');
		System.assertNotEquals(null, foundLead.AW_DateOfBirth__c, 'Birthdate not Set');

	}

	private static User selectNewAdviser()
	{
		//Fetch two advisers
		List<User> advisers = AW_DAL_User.findRandomActiveAdvisers(INT_TWO);
		User newAdviser = advisers[INT_ZERO];

		//If adviser with different Id is found, then return it otherwise return the other one
		if(newAdviser.Id != adviser.Id)
		{
			return newAdviser;
		}
		else
		{
			return advisers.get(INT_ONE);
		}
	}
}