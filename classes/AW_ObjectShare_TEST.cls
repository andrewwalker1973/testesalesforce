/**
 * @description Unit test to check that all relevant objects will be shared if a configuration row exists
 * Makes sure that the triggers are enabled and actions have been correctly configured
 *
 * @author jason.van.beukering@accenture.com vishakha.saini@accenture.com
 *
 * @date August 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class AW_ObjectShare_TEST
{
	private static final Integer NUMBER_OF_USERS = 2;
	private static final String SURVEY_SETTING_DEVELOPER_NAME = 'AW_SurveySetting';

	/**
	 * @description Will run a test with the object provided and check that shares are created
	 *
	 * @param objectToShare The object for which an ApexShare should be created
	 *
	 * @see CMN_TRA_ObjectShareInstruction.afterInsert
	 */
	private static void assertShareIsCreated(SObject objectToShare)
	{
		assertShareIsCreated(objectToShare, AW_DAL_User.findRandomActiveAdvisers(NUMBER_OF_USERS));
	}

	/**
	 * @description Will run a test with the object provided and check that shares are created
	 *
	 * @param objectToShare The object for which an ApexShare should be created
	 * @param foundUsers The users to use for setting up configuration object as well as setting the object owner
	 *
	 * @see CMN_TRA_ObjectShareInstruction.afterInsert
	 */
	private static void assertShareIsCreated(SObject objectToShare, List<User> foundUsers)
	{
		String objectName = objectToShare.getSObjectType().getDescribe().getLocalName();

		User owningUser = foundUsers.iterator().next();

		insert CMN_DAL_DataFactory.newObjectShareConfiguration
				(
						objectName,
						CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_READ,
						owningUser.Id,
						foundUsers[1].Id
				);

		Test.getEventBus().deliver();

		Test.startTest();

		objectToShare.put(CMN_DAL_SObjectDomain.FIELD_OWNER_ID, owningUser.Id);
		insert objectToShare;

		Test.stopTest();

		List<SObject> shares = CMN_DAL_ObjectShare.findByParentIdAndRowCause(objectToShare.Id, CMN_DAL_ObjectShare.ROW_CAUSE_MANUAL);
		System.assertEquals(false, shares.isEmpty(), 'An ApexShare was not created for the "' + objectName + '" as expected');
	}

	/**
	 * @description Checks that the account share is created as expected
	 *
	 * @see AccountShare
	 */
	@IsTest
	private static void account()
	{
		assertShareIsCreated(AW_DAL_TestDataFactory.newPersonAccount(AW_DAL_Account.RT_PERSON_ACCOUNT, AW_UTIL_IdentityNumber.generateRandomIdentityNumber()));
	}

	/**
	 * @description Checks that the FinServ__AssetsAndLiabilities__c share is created as expected
	 */
	@IsTest
	private static void assetsAndLiabilities()
	{
		List<User> foundUsers = AW_DAL_User.findRandomActiveAdvisers(NUMBER_OF_USERS);
		Account newAccount = newPersonAccount(foundUsers.iterator().next());

		FinServ__AssetsAndLiabilities__c newAsset = AW_DAL_TestDataFactory.newAssetAndLiability(newAccount);
		newAsset.AW_ShareWithMyAdviser__c = false; //Do not change the owner of the Liabilities, related to old code which shares asset created by client with adviser

		assertShareIsCreated(newAsset, foundUsers);
	}

	/**
	 * @description Will create a person account and ensure that it's owned by the provided user
	 *
	 * @param owningUser user that should own the account
	 *
	 * @return The newly created account
	 */
	private static Account newPersonAccount(User owningUser)
	{
		Account newAccount = AW_DAL_TestDataFactory.newPersonAccount(AW_DAL_Account.RT_PERSON_ACCOUNT, AW_UTIL_IdentityNumber.generateRandomIdentityNumber());
		newAccount.OwnerId = owningUser.Id;
		insert newAccount;
		return newAccount;
	}

	/**
	 * @description Checks that the campaign share is created as expected
	 *
	 * @see CampaignShare
	 */
	@IsTest
	private static void campaign()
	{
		assertShareIsCreated(AW_DAL_TestDataFactory.newCampaign());
	}

	/**
	 * @description Checks that the Case share is created as expected
	 *
	 * @see CaseShare
	 */
	@IsTest
	private static void case()
	{
		assertShareIsCreated(AW_DAL_TestDataFactory.newCase());
	}

	/**
	 * @description Checks that the DocumentChecklistItem share is created as expected
	 *
	 * @see DocumentChecklistItemShare
	 */
	@IsTest
	private static void documentChecklistItem()
	{
		List<User> foundUsers = AW_DAL_User.findRandomActiveAdvisers(NUMBER_OF_USERS);
		Account newAccount = newPersonAccount(foundUsers.iterator().next());

		assertShareIsCreated(AW_DAL_TestDataFactory.newDocumentCheckListItem(newAccount.Id));
	}

	/**
	 * @description Checks that the Envelope share is created as expected
	 *
	 * @see AW_Envelope__Share
	 */
	@IsTest
	private static void envelope()
	{
		assertShareIsCreated(AW_DAL_TestDataFactory.newEnvelope());
	}

	/**
	 * @description Checks that the expense share is created as expected
	 *
	 * @see AW_Expense__Share
	 */
	@IsTest
	private static void expense()
	{
		assertShareIsCreated(AW_DAL_TestDataFactory.newExpense());
	}

	/**
	 * @description Checks that the FinServ__FinancialAccount__c share is created as expected
	 */
	@IsTest
	private static void financialAccount()
	{
		List<User> foundUsers = AW_DAL_User.findRandomActiveAdvisers(NUMBER_OF_USERS);
		Account newAccount = newPersonAccount(foundUsers.iterator().next());

		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(FinServ__FinancialAccount__c.SObjectType, AW_DAL_FinancialAccount.RT_INVESTMENT_ACCOUNT);
		FinServ__FinancialAccount__c newFinancialAccount = AW_DAL_TestDataFactory.newFinancialAccount(newAccount, recordTypeId);

		assertShareIsCreated(newFinancialAccount, foundUsers);
	}

	/**
	 * @description Checks that the FinServ__FinancialGoal__c share is created as expected
	 */
	@IsTest
	private static void financialGoal()
	{
		List<User> foundUsers = AW_DAL_User.findRandomActiveAdvisers(NUMBER_OF_USERS);
		Account newAccount = newPersonAccount(foundUsers.iterator().next());

		assertShareIsCreated(AW_DAL_TestDataFactory.newFinancialGoal(newAccount), foundUsers);
	}

	/**
	 * @description Checks that the income share is created as expected
	 *
	 * @see AW_Income__Share
	 */
	@IsTest
	private static void income()
	{
		assertShareIsCreated(AW_DAL_TestDataFactory.newIncome());
	}

	/**
	 * @description Checks that the InsurancePolicy share is created as expected
	 *
	 * @see InsurancePolicyShare
	 */
	@IsTest
	private static void insurancePolicy()
	{
		List<User> foundUsers = AW_DAL_User.findRandomActiveAdvisers(NUMBER_OF_USERS);
		Account newAccount = newPersonAccount(foundUsers.iterator().next());

		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(InsurancePolicy.SObjectType, AW_DAL_InsurancePolicy.RT_INSURANCE_POLICY);
		assertShareIsCreated(AW_DAL_TestDataFactory.newInsurancePolicy(newAccount.Id, recordTypeId));
	}

	/**
	 * @description Checks that the lead share is created as expected
	 *
	 * @see LeadShare
	 */
	@IsTest
	private static void lead()
	{
		assertShareIsCreated(AW_DAL_TestDataFactory.newLead());
	}

	/**
	 * @description Checks that the Opportunity share is created as expected
	 *
	 * @see OpportunityShare
	 */
	@IsTest
	private static void opportunity()
	{
		List<User> foundUsers = AW_DAL_User.findRandomActiveAdvisers(NUMBER_OF_USERS);
		User owningUser = foundUsers.iterator().next();

		Account newAccount = newPersonAccount(owningUser);

		List<Opportunity> newOpportunities =
				AW_DAL_TestDataFactory.newOpportunities(newAccount, owningUser, 1, AW_DAL_Opportunity.RT_DEFAULT_OPPORTUNITY);
		assertShareIsCreated(newOpportunities.iterator().next());
	}

	/**
	 * @description Checks that the OutstandingRequirement share is created as expected
	 *
	 * @see AW_Outstanding_Requirement__Share
	 */
	@IsTest
	private static void outstandingRequirement()
	{
		assertShareIsCreated(AW_DAL_TestDataFactory.newOutstandingRequirement());
	}

	/**
	 * @description Checks that the SurveyInvitation share is created as expected
	 *
	 * @see SurveyInvitationShare
	 */
	@IsTest
	private static void surveyInvitation()
	{
		Account clientAccount = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
		clientAccount = AW_DAL_Account.findById(clientAccount.Id);

		Contact personContact = new Contact();
		personContact.Id = clientAccount.PersonContactId;
		personContact.Email = CMN_DAL_SObjectDomain.generateRandomEmail();
		update personContact;

		AW_SurveySetting__mdt surveySetting = AW_SurveySetting__mdt.getInstance(SURVEY_SETTING_DEVELOPER_NAME);

		SurveyInvitation surveyInvitationToInsert =
				AW_DAL_TestDataFactory.newSurveyInvitation(clientAccount.PersonContactId, surveySetting.AW_SurveyID__c, surveySetting.AW_CommunityNetworkID__c);

		assertShareIsCreated(surveyInvitationToInsert);
	}
}