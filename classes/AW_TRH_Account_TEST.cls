/**
 * @description Test class for AW_TRH_Account
 *
 * @see AW_TRH_Account
 *
 * @author prashant.k.jain@accenture.com a.shrikrishna.pethe@accenture.com
 *
 * @date 2019, June 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class AW_TRH_Account_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE_ONE = 1;
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE_TWO = 2;
	private static final String INVALID_IDENTITY_NUMBER = '6809305236082'; //Check digit is incorrect

	/**
	 * @description Checks that lead conversion expects an Identification Number
	 */
	@IsTest
	private static void checkConversionFailsIfIdentityNumberIsNotSet()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		System.runAs(adviser)
		{

			Lead newLead = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, NUMBER_OF_ITEMS_TO_CREATE_ONE, adviser.Id).iterator().next();
			newLead.AW_IdentificationNumber__c = null;
			update newLead;

			Database.LeadConvert leadConverter = new Database.LeadConvert();

			leadConverter.setLeadId(newLead.Id);
			leadConverter.setConvertedStatus(AW_DAL_Lead.STATUS_CONVERTED);
			leadConverter.setOwnerId(adviser.Id);

			Test.startTest();

			try
			{
				Database.convertLead(leadConverter);
				System.assert(false, 'Exception not thrown as expected');
			}
			catch(Exception error)
			{
				System.assert(true, 'Exception was thrown as expected');
			}

			Test.stopTest();

		}

	}

	/**
	 * @description This method test the Gender, Birthdate extraction from Identification Number
	 */
	@IsTest
	private static void checkGenderBirthDateExtractionFromIdentityNumber()
	{
		Test.startTest();

		List<Account> newAccounts = AW_DAL_TestDataFactory.createClientAccount();

		Test.stopTest();

		Account foundAccount = AW_DAL_Account.findById(newAccounts[0].Id);

		System.assert(String.isNotBlank(foundAccount.FinServ__Gender__pc), 'Gender not Set');
		System.assertNotEquals(null, foundAccount.PersonBirthdate, 'Birthdate not Set');

	}

	/**
	 * @description This method test the Gender, Birth Date extraction from Identification Number
	 */
	@IsTest
	private static void checkGenderBirthDateIdentityNumberUpdate()
	{
		List<Account> newAccounts = AW_DAL_TestDataFactory.createClientAccount();
		Account originalAccount = AW_DAL_Account.findById(newAccounts[0].Id);

		String newIdentificationNumber = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();

		originalAccount.AW_IdentificationNumber__pc = newIdentificationNumber;
		originalAccount.PersonBirthdate = null;
		originalAccount.FinServ__Gender__pc = null;

		Test.startTest();

		update originalAccount;

		Test.stopTest();

		Account foundAccount = AW_DAL_Account.findById(newAccounts[0].Id);

		System.assert(String.isNotBlank(foundAccount.FinServ__Gender__pc), 'Gender not Set');
		System.assertNotEquals(null, foundAccount.PersonBirthdate, 'Birthdate not Set');
	}

	/**
	 * @description Confirms that the Review Month  is set to the Date of Birth  Month  if review month is blank.
	 */
	@IsTest
	private static void checkReviewMonthIsSetFromDateOfBirth()
	{
		Test.startTest();

		List<Account> newAccounts = AW_DAL_TestDataFactory.createClientAccount();

		Test.stopTest();

		Account newAccount = AW_DAL_Account.findById(newAccounts[0].Id);

		System.assert(String.isNotBlank(newAccount.AW_ReviewMonth__pc), 'Review  Month is not Set');
		System.assertEquals(CMN_UTIL_Date.monthNameFromDate(newAccount.PersonBirthdate), newAccount.AW_ReviewMonth__pc, 'Review Month Incorrect');
	}

	/**
	 * @description Confirms that trigger is validating Identity Numbers and resulting in a DML exception.
	 */
	@IsTest
	private static void checkValidationErrorThrown()
	{
		Test.startTest();

		try
		{
			AW_DAL_TestDataFactory.createClientAccount(INVALID_IDENTITY_NUMBER);
			System.assert(false, 'Error not thrown as expected.');
		}
		catch(DmlException error)
		{
			System.assert(true, 'Validation Exception thrown as expected');
		}

		Test.stopTest();
	}

	/**
	 * @description Checks that if we switch of account validations that the trigger doesn't validate Identity Number and throw DML exception
	 */
	@IsTest
	private static void checkValidationErrorNotThrownDueToSetting()
	{
		AW_FeatureSwitches__c switches = AW_DAL_FeatureSwitches.getFeatureSwitch(UserInfo.getUserId());
		switches.AW_DisableAccountValidationRules__c = true;
		upsert switches;

		Test.startTest();
		try
		{
			AW_DAL_TestDataFactory.createClientAccount(INVALID_IDENTITY_NUMBER);
			System.assert(true, 'Validation Error was not throw');
		}
		catch(DmlException error)
		{
			System.assert(false, 'Validation Error was thrown');
		}

		Test.stopTest();
	}

	/**
	 * @description This method will test the scenario when any field in the fieldset is modified for a
	 *                   Prospect Person account, a web service callout will be initiated for Adviser
	 */
	@IsTest
	private static void triggerApiOnInsertAdviser()
	{
		triggerApiOnInsertOrUpdate(AW_DAL_Profile.PROFILE_ADVISER, false);
	}

	/**
	 * @description This method will test the scenario when any field in the fieldset is modified for a
	 *                   Prospect Person account, a web service callout will be initiated for Adviser
	 */
	@IsTest
	private static void triggerApiOnUpdateAdviser()
	{
		triggerApiOnInsertOrUpdate(AW_DAL_Profile.PROFILE_ADVISER, true);
	}

	/**
	 * @description This method will test the scenario when any field in the fieldset is modified for a
	 *                   Prospect Person account, a web service callout will be initiated for SalesLeader
	 */
	@IsTest
	private static void triggerApiOnInsertSalesLeader()
	{
		triggerApiOnInsertOrUpdate(AW_DAL_Profile.PROFILE_SALES_LEADER, false);
	}

	/**
	 * @description This method will test the scenario when any field in the fieldset is modified for a
	 *                   Prospect Person account, a web service callout will be initiated for SalesLeader
	 */
	@IsTest
	private static void triggerApiOnUpdateSalesLeader()
	{
		triggerApiOnInsertOrUpdate(AW_DAL_Profile.PROFILE_SALES_LEADER, true);
	}

	/**
	 * @description This method will test the scenario when any field in the fieldset is modified for a
	 *                   Prospect Person account, a web service callout will be initiated for Personal Assistant
	 */
	@IsTest
	private static void triggerApiOnInsertPersonalAssistant()
	{
		triggerApiOnInsertOrUpdate(AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT, false);
	}

	/**
	 * @description Base Method to test the scenario when any field in the fieldset is modified for a
	 *                   Prospect Person account, a web service callout will be initiated
	 *
	 * @param profileName The profile for which to run the test
	 * @param isUpdate Flag indicating where to test insert or update
	 */
	private static void triggerApiOnInsertOrUpdate(String profileName, Boolean isUpdate)
	{
		User foundUser = AW_DAL_User.findActiveUser(profileName);

		//Make sure that user's UACF Id and Consultant Code is not blank
		if(String.isBlank(foundUser.AW_UACFID__c) || String.isBlank(foundUser.AW_ConsultantCode__c))
		{
			foundUser.AW_UACFID__c = String.isBlank(foundUser.AW_UACFID__c) ? AW_DAL_User.generateRandomUACFId() : foundUser.AW_UACFID__c;
			foundUser.AW_ConsultantCode__c =
					String.isBlank(foundUser.AW_ConsultantCode__c) ? AW_DAL_User.generateRandomConsultantCode() : foundUser.AW_ConsultantCode__c;
			update foundUser;
		}

		Account newAccount;

		Test.startTest();

		System.runAs(foundUser)
		{
			newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

			if(isUpdate)
			{
				newAccount.AW_Income__pc = CMN_DAL_SObjectDomain.generateRandomInteger();
				update newAccount;
			}
		}

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_RestOutboundClientUpdated.SERVICE_NAME);
	}

	/**
	 * @description This method will test the scenario when an account is reassigned,
	 *                  the correct child task are closed.
	 *
	 * @author Jonathan Maes (Deloitte)
	 *
	 * @date 23 October 2020
	 */
	@IsTest
	private static void closeRelatedTasksOnAccountOwnerChange()
	{
		Account newAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();

		User user1 = AW_DAL_TestDataFactory.createTestUser(AW_DAL_Profile.PROFILE_ADVISER, true);
		User user2 = AW_DAL_TestDataFactory.createTestUser(AW_DAL_Profile.PROFILE_ADVISER, true);

		Task taskOpenAndOrphan =
				AW_DAL_TestDataFactory.createTasks(AW_DAL_Task.RT_ORPHAN_TASK, newAccount.Id, user1.Id, NUMBER_OF_ITEMS_TO_CREATE_ONE).iterator().next();

		Task taskOther = AW_DAL_TestDataFactory.createTasks(AW_DAL_Task.RT_ADVISER_TASK, newAccount.Id, user1.Id, NUMBER_OF_ITEMS_TO_CREATE_ONE).iterator().next();

		Test.startTest();

		newAccount.OwnerId = user2.Id;
		update newAccount;

		Test.stopTest();

		taskOther = AW_DAL_Task.findByWhatIdAndRecordType(newAccount.Id, AW_DAL_Task.RT_ADVISER_TASK);
		System.assertEquals(taskOther.Status, AW_DAL_Task.STATUS_IN_PROGRESS);

		taskOpenAndOrphan = AW_DAL_Task.findByWhatIdAndRecordType(newAccount.Id, AW_DAL_Task.RT_ORPHAN_TASK);
		System.assertEquals(taskOpenAndOrphan.Status, AW_DAL_Task.STATUS_COMPLETED);
	}

	/**
	 * @description This method will test if all an account gets linked to master if the account becomes active and a master exists
	 */
	@IsTest
	private static void insertAndLinkChildPersonAccounts()
	{
		Account masterAccount = AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next(); // Insert Master account

		User adviser = AW_DAL_User.findRandomActiveAdviser();

		Account clientAccount;

		System.runAs(adviser)
		{
			clientAccount = AW_DAL_TestDataFactory.createClientAccount(masterAccount.AW_IdentificationNumber__pc).iterator().next();
			clientAccount.AW_SKF_Id__c = masterAccount.AW_SKF_Id__c;
			update clientAccount;
		}

		Test.startTest();

		System.runAs(adviser)
		{
			clientAccount.FinServ__Status__c = AW_DAL_Account.STATUS_ACTIVE;
			update clientAccount;
		}

		Test.stopTest();

		masterAccount = AW_DAL_Account.findById(masterAccount.Id);
		AW_AccountOwnerConfig__mdt ownerConfig = AW_DAL_AccountOwnerConfig.findMasterAccountOwnerInfo();
		System.assertEquals(ownerConfig?.AW_UserId__c, masterAccount.OwnerId, 'Owner Id for master not set correctly');

		clientAccount = AW_DAL_Account.findById(clientAccount.Id);
		System.assertEquals(masterAccount.Id, clientAccount.AW_ParentAccount__c, 'Active account was not linked to master account');
		System.assertNotEquals(ownerConfig?.AW_UserId__c, clientAccount.OwnerId, 'Owner Id for client not set correctly');
	}
    
	/**
	 * @description Method will link a newly created child object to relevant business master account (if it exists)
	 */
	@IsTest
	private static void linkBusinessAccountToRelatedObjects()
	{
		Account masterAccount = AW_DAL_TestDataFactory.newBusinessAccount(AW_DAL_Account.RT_BUSINESS_MASTER_ACCOUNT);
		Account childAccount = AW_DAL_TestDataFactory.newBusinessAccount(AW_DAL_Account.RT_BUSINESS_ACCOUNT);
		childAccount.AW_BypassValidationRules__c = true;

		CMN_DAL_SObjectDomain.insertDBObjects(new List<SObject> {masterAccount, childAccount});
		Contact newContact = AW_DAL_TestDataFactory.createContact(childAccount.Id);

		linkAccountToRelatedObjects(childAccount, masterAccount.Id, newContact.Id);

		//Ensure master account owner is set correctly
		masterAccount = AW_DAL_Account.findById(masterAccount.Id);
		AW_AccountOwnerConfig__mdt ownerConfig = AW_DAL_AccountOwnerConfig.findMasterAccountOwnerInfo();
		System.assertEquals(ownerConfig?.AW_UserId__c, masterAccount.OwnerId, 'Owner Id for master not set correctly');
	}

	/**
	 * @description Method will link a newly created child object to relevant person master account (if it exists)
	 */
	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	private static void linkPersonAccountToRelatedObjects()
	{
		String identificationNumber = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();

		Account masterAccount = AW_DAL_TestDataFactory.newPersonAccount(AW_DAL_Account.RT_PERSON_MASTER_ACCOUNT, identificationNumber);
		Account childAccount = AW_DAL_TestDataFactory.newPersonAccount(AW_DAL_Account.RT_PERSON_ACCOUNT, identificationNumber);
		childAccount.AW_BypassValidationRules__c = true;

		CMN_DAL_SObjectDomain.insertDBObjects(new List<SObject> {masterAccount, childAccount});
		Account personAccount = AW_DAL_Account.findById(new Set<Id> {childAccount.Id}).iterator().next();

		linkAccountToRelatedObjects(childAccount, masterAccount.Id, personAccount.PersonContactId);
	}

	/**
	 * @description Method will link a newly created child object to relevant master account (if it exists)
	 *
	 * @param childAccount Child Account Record
	 * @param masterAccountId Master Account Id
	 * @param contactId Contact Id
	 */
	private static void linkAccountToRelatedObjects(Account childAccount, Id masterAccountId, Id contactId)
	{
		// Create related records
		FinServ__FinancialGoal__c financialGoal = AW_DAL_TestDataFactory.createFinancialGoals(childAccount, NUMBER_OF_ITEMS_TO_CREATE_TWO).iterator().next();
		AW_DAL_TestDataFactory.createPersonLifeEvents(contactId, NUMBER_OF_ITEMS_TO_CREATE_TWO, true);
		AW_DAL_TestDataFactory.createEmailMessage(childAccount.Id);
		AW_DAL_TestDataFactory.createFinancialAccounts(childAccount, NUMBER_OF_ITEMS_TO_CREATE_TWO);
		AW_DAL_TestDataFactory.createInsurancePolicies(childAccount, financialGoal, NUMBER_OF_ITEMS_TO_CREATE_TWO);
		AW_DAL_TestDataFactory.createAssetsAndLiabilities(childAccount, NUMBER_OF_ITEMS_TO_CREATE_TWO);
		AW_DAL_TestDataFactory.createFNA(childAccount.Id, NUMBER_OF_ITEMS_TO_CREATE_TWO);
		AW_DAL_TestDataFactory.createWorkflowTask(childAccount);
		AW_DAL_TestDataFactory.createDefaultOpportunities(childAccount, NUMBER_OF_ITEMS_TO_CREATE_TWO);
		AW_DAL_TestDataFactory.createCase(contactId);
		AW_DAL_TestDataFactory.insertEnvelopeWithActiveAccount(childAccount.Id);
		AW_DAL_TestDataFactory.createBusinessMilestone(childAccount.Id, NUMBER_OF_ITEMS_TO_CREATE_TWO);

		childAccount.AW_ParentAccount__c = masterAccountId;
		childAccount.FinServ__Status__c = AW_DAL_Account.STATUS_ACTIVE;

		Test.startTest();

		CMN_DAL_SObjectDomain.updateDBObject(childAccount);

		Test.stopTest();

		childAccount = AW_DAL_Account.findByIdWithRelatedObjects(new Set<Id> {childAccount.Id}).iterator().next();

		for(String objectType : AW_TRH_Account.SUPPORTED_CHILD_RELATIONSHIPS)
		{
			for(SObject so : childAccount.getSObjects(objectType))
			{
				System.assertEquals(masterAccountId, so.get(AW_DAL_Account.FIELD_MASTER_ACCOUNT_LOOKUP), 'Child object was not linked successfully');
			}
		}
	}

	/**
	 * @description This method will test the scenario when prospect accounts created/updated & related
	 * 					leads gets converted into opportunities
	 *
	 * @author Ankit Gupta (Deloitte)
	 *
	 * @date 22 Feb 2021
	 */
	@IsTest
	private static void convertRelatedLeadsToOpportunity()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		System.runAs(adviser)
		{
			Account listAccounts = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
			Lead newLeads = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, 1, adviser.Id).iterator().next();
			newLeads.AW_IdentificationNumber__c = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
			newLeads.AW_IdentificationType__c = AW_DAL_Lead.IDENTIFICATION_TYPE_SA_ID;
			Test.startTest();

			update newLeads;

			listAccounts.OwnerId = adviser.Id;
			listAccounts.AW_IdentificationNumber__pc = newLeads.AW_IdentificationNumber__c;
			listAccounts.AW_IdentificationType__pc = newLeads.AW_IdentificationType__c;
			listAccounts.FinServ__Status__c = AW_DAL_Lead.STATUS_PROSPECT;

			update listAccounts;

			Test.stopTest();

			Lead listLead = AW_DAL_Lead.findById(newLeads.Id);
			List<Opportunity> listOpportunity = AW_DAL_Opportunity.findByAccountId(listAccounts.Id);

			System.assertEquals(AW_DAL_Lead.STATUS_CONVERTED, listLead.Status);
			System.assertEquals(1, listOpportunity.size());
		}
	}

	/**
	 * @description Checks that the SourceSystemId is set.
	 */
	@IsTest
	private static void checkSetSourceSystemId()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		System.runAs(adviser)
		{
			Test.startTest();
			// Person Account with SA ID Number
			Account clientAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
			AW_Country__c countryRecord = AW_DAL_Country.findByName(AW_DAL_Country.INDIA); // This line has to be executed after the Account has been created
			String sourceSystemId;

			clientAccount = AW_DAL_Account.findById(clientAccount.Id); // Re-query Account to fetch updated value of Source System Id
			sourceSystemId = clientAccount.AW_IdentificationNumber__pc + adviser.AW_UACFID__c;
			System.assertEquals(AW_DAL_Account.PICK_SA_ID_TYPE, clientAccount.AW_IdentificationType__pc, 'ID Type not set to SA ID');
			System.assertEquals(sourceSystemId, clientAccount.FinServ__SourceSystemId__c, 'Source System Id not set correctly on Client Account with SA ID');

			//Changing the Identification Type to Passport and Populating Passport Country of Issue
			clientAccount.AW_IdentificationType__pc = AW_DAL_Account.PICK_PASSPORT_TYPE;
			clientAccount.AW_PassportCountryOfIssue__pc = countryRecord.Id;
			update clientAccount;

			clientAccount = AW_DAL_Account.findById(clientAccount.Id);
			String countryCode = String.valueOf(countryRecord.AW_CountryCode__c);
			sourceSystemId = clientAccount.AW_IdentificationNumber__pc + countryCode + adviser.AW_UACFID__c;
			System.assertEquals(sourceSystemId, clientAccount.FinServ__SourceSystemId__c, 'Source System Id not set correctly on Client Account with Passport');

			//Business account with Company Registration Number
			Account businessAccount = AW_DAL_TestDataFactory.createBusinessAccounts().iterator().next();

			Account businessAccount2 = AW_DAL_Account.findById(businessAccount.Id); // Using different variable to not affect original variable
			sourceSystemId = businessAccount2.AW_CompanyRegistrationTrustNumber__c + adviser.AW_UACFID__c;
			System.assertEquals
					(sourceSystemId, businessAccount2.FinServ__SourceSystemId__c, 'Source System Id not set correctly on Business Account with Company Registration Number');

			//Changing the Company Registration Number to blank
			businessAccount.AW_CompanyRegistrationTrustNumber__c = CMN_UTIL_String.EMPTY;
			update businessAccount;

			businessAccount2 = AW_DAL_Account.findById(businessAccount.Id);
			sourceSystemId = null;

			Test.stopTest();

			System.assertEquals
					(
							sourceSystemId,
							businessAccount2.FinServ__SourceSystemId__c,
							'Source System Id not reset correctly on Business Account without Company Registration Number'
					);
		}
	}
}