/**
 * @description Unit test for AW_BATCH_AccountReallocation
 *
 * @see AW_BATCH_AccountReallocation
 * @see AW_BATCH_Reallocation
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date July 2021, May 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
@TestVisible
private class AW_BATCH_AccountReallocation_TEST
{
	@TestVisible
	private static final Integer NUM_ACCOUNTS_TO_CREATE = 2;
	private static final Integer NUM_ACCOUNTS_TO_CREATE_FOR_EACH_IDENTITY_NUMBER = 1;
	private static final Integer NUM_OF_ADVISER_TO_RETRIEVE = 3;
	@TestVisible
	private static final String ERROR_INVALID_NUMBER_OF_ACCOUNTS = 'Incorrect number of accounts found';

	/**
	 * @description Setup test data
	 */
	@TestSetup
	private static void setup()
	{
		setup(AW_DAL_Account.OBJECT_NAME);
	}

	/**
	 * @description Setup test data
	 *
	 * @param objectName Name of the object e.g. Account, Lead
	 */
	@TestVisible
	private static void setup(String objectName)
	{
		verifyCustomMetadata(objectName);

		//Make sure Active Lead Managers are available
		List<User> leadManagers = AW_DAL_User.findActiveByProfileName(AW_DAL_Profile.PROFILE_LIBERTY_LEAD_MANAGER);
		System.assert(leadManagers?.size() > 0, 'Active Lead Managers not found');

		List<SObject> sObjectsToUpdate = new List<SObject>();
		User adviser = AW_DAL_User.findRandomActiveAdviser();
		List<User> advisers = new List<User> {adviser};
		AW_ReallocationSetting__mdt reallocationSetting = AW_DAL_ReallocationSetting.getInstance(AW_DAL_ReallocationSetting.DEVELOPER_NAME_ACCOUNT_REALLOCATION);

		adviser.AW_Opt_in_out__c = true; //Make sure advisers opted in for Orphan Assignment
		sObjectsToUpdate.add(adviser);

		Long slaDurationInMilliseconds = -reallocationSetting.AW_SLADurationInMilliseconds__c.longValue();
		Datetime outOfSLAOwnerChangedDate = BusinessHours.add(CMN_DAL_BusinessHours.getDefaultBusinessHours()?.Id, Datetime.now(), slaDurationInMilliseconds);

		System.runAs(adviser)
		{
			for(Integer i = 0; i < NUM_ACCOUNTS_TO_CREATE; i++)
			{
				Account account = AW_DAL_TestDataFactory.createClientAccount().iterator().next();
				if(objectName.equalsIgnoreCase(AW_DAL_Account.OBJECT_NAME))
				{
					account.put(AW_DAL_Account.FIELD_IS_REALLOCATED, false);
					account.put(AW_DAL_Account.FIELD_ACCOUNT_OWNERSHIP, AW_DAL_Account.ACCOUNT_OWNERSHIP_ORPHAN);
					account.put(AW_DAL_Account.FIELD_OWNER_CHANGED_DATE, outOfSLAOwnerChangedDate);
					sObjectsToUpdate.add(account);
				}
				AW_DAL_TestDataFactory.createAccountTeamMembers(account, advisers, AW_DAL_AccountTeamMember.ROLE_ADVISER);
			}
			CMN_DAL_SObjectDomain.updateDBObjects(sObjectsToUpdate);
			setupTargetAndPerformance(objectName, advisers);
		}
	}

	/**
	 * @description - Test method to check the reallocation of an orphan account to an Adviser
	 */
	@IsTest
	private static void reallocationToAdviser()
	{
		AW_ReallocationSetting__mdt reallocationSetting = AW_DAL_ReallocationSetting.getInstance(AW_DAL_ReallocationSetting.DEVELOPER_NAME_ACCOUNT_REALLOCATION);
		List<Account> accountsBeforeReallocation = AW_DAL_Account.getAll();
		Map<String, Decimal> adviserPerformanceByUACFId = new Map<String, Decimal>();
		Set<String> uacfIds;

		System.assertEquals(NUM_ACCOUNTS_TO_CREATE, accountsBeforeReallocation.size(), ERROR_INVALID_NUMBER_OF_ACCOUNTS);

		for(Account accountRecord : accountsBeforeReallocation)
		{
			setupAccountTeam(AW_DAL_Account.OBJECT_NAME, accountRecord);
		}

		Test.startTest();
		Database.executeBatch(new AW_BATCH_AccountReallocation());
		Test.stopTest();

		List<Account> accountsAfterReallocation = AW_DAL_Account.getAll();
		System.assertEquals(NUM_ACCOUNTS_TO_CREATE, accountsAfterReallocation.size(), ERROR_INVALID_NUMBER_OF_ACCOUNTS);

		uacfIds = CMN_UTIL_System.extractSetValues(accountsAfterReallocation, reallocationSetting.AW_OwnerUACFIdFieldAPIName__c);
		AW_BATCH_Reallocation.populateAdviserPerformance
				(
						uacfIds,
						adviserPerformanceByUACFId,
						reallocationSetting.AW_WeightForLeadConversionRate__c,
						reallocationSetting.AW_WeightForOpportunityWinRate__c
				); //Populate adviser Performance map using UACFId as key

		for(Integer i = 0; i < accountsAfterReallocation.size(); i++)
		{
			Account accountBeforeReallocation = accountsBeforeReallocation.get(i);
			Account accountAfterReallocation = accountsAfterReallocation.get(i);
			String ownerUACFId = (String)accountAfterReallocation.get(reallocationSetting.AW_OwnerUACFIdFieldAPIName__c);

			System.assertEquals(false, accountBeforeReallocation.get(AW_DAL_Account.FIELD_IS_REALLOCATED), 'Account # ' + i + ' already reallocated');
			System.assertEquals(true, accountAfterReallocation.get(AW_DAL_Account.FIELD_IS_REALLOCATED), 'Account # ' + i + ' not reallocated');
			System.assertNotEquals
					(
							accountBeforeReallocation.get(AW_DAL_Account.FIELD_OWNER_CHANGED_DATE),
							accountAfterReallocation.get(AW_DAL_Account.FIELD_OWNER_CHANGED_DATE),
							'Owner Changed Date not updated for Account # ' + i
					);
			System.assertNotEquals(accountBeforeReallocation.OwnerId, accountAfterReallocation.OwnerId, 'Owner not changed for Account # ' + i);
			System.assertEquals
					(
							AW_DAL_Profile.PROFILE_ADVISER,
							accountBeforeReallocation.Owner.Profile?.Name,
							'Account # ' + i + ' not assigned to Liberty Adviser Profile before reallocation'
					);
			System.assertEquals
					(
							AW_DAL_Profile.PROFILE_ADVISER,
							accountAfterReallocation.Owner.Profile?.Name,
							'Account # ' + i + ' not reallocated to Liberty Adviser Profile'
					);
			System.assert
					(
							adviserPerformanceByUACFId.get(ownerUACFId.toUpperCase()) >= reallocationSetting.AW_AveragePerformanceThreshold__c,
							'Account # ' + i + ' not reallocated to a high performing adviser. Adviser Performance: '
							+ adviserPerformanceByUACFId.get(ownerUACFId)
							+ ' Average Performance Threshold: '
							+ reallocationSetting.AW_AveragePerformanceThreshold__c
					);
		}
	}

	/**
	 * @description - Test method to check the reallocation of an orphan account to an Adviser
	 */
	@IsTest
	private static void reallocationToLeadManager()
	{
		List<Account> accountsBeforeReallocation = AW_DAL_Account.getAll();

		System.assertEquals(NUM_ACCOUNTS_TO_CREATE, accountsBeforeReallocation.size(), ERROR_INVALID_NUMBER_OF_ACCOUNTS);

		Test.startTest();
		Database.executeBatch(new AW_BATCH_AccountReallocation());
		Test.stopTest();

		List<Account> accountsAfterReallocation = AW_DAL_Account.getAll();
		System.assertEquals(NUM_ACCOUNTS_TO_CREATE, accountsAfterReallocation.size(), ERROR_INVALID_NUMBER_OF_ACCOUNTS);

		for(Integer i = 0; i < accountsAfterReallocation.size(); i++)
		{
			Account accountBeforeReallocation = accountsBeforeReallocation.get(i);
			Account accountAfterReallocation = accountsAfterReallocation.get(i);

			System.assertEquals(false, accountBeforeReallocation.get(AW_DAL_Account.FIELD_IS_REALLOCATED), 'Account # ' + i + ' already reallocated');
			System.assertEquals(true, accountAfterReallocation.get(AW_DAL_Account.FIELD_IS_REALLOCATED), 'Account # ' + i + ' not reallocated');
			System.assertNotEquals
					(
							accountBeforeReallocation.get(AW_DAL_Account.FIELD_OWNER_CHANGED_DATE),
							accountAfterReallocation.get(AW_DAL_Account.FIELD_OWNER_CHANGED_DATE),
							'Owner Changed Date not updated for Account # ' + i
					);
			System.assertNotEquals(accountBeforeReallocation.OwnerId, accountAfterReallocation.OwnerId, 'Owner not changed for Account # ' + i);
			System.assertEquals
					(
							AW_DAL_Profile.PROFILE_ADVISER,
							accountBeforeReallocation.Owner.Profile?.Name,
							'Account # ' + i + ' not assigned to Liberty Adviser Profile before reallocation'
					);
			System.assertEquals
					(
							AW_DAL_Profile.PROFILE_LIBERTY_LEAD_MANAGER,
							accountAfterReallocation.Owner.Profile?.Name,
							'Account # ' + i + ' not reallocated to Liberty Lead Profile'
					);
		}
	}

	/**
	 * @description - Test method to check the reallocation of an orphan account to a Lead Manager when the account
	 *                is already reallocated to an Adviser
	 */
	@IsTest
	private static void reallocationToLeadManagerWhenAlreadyReallocated()
	{
		List<Account> accountsBeforeReallocation = AW_DAL_Account.getAll();
		System.assertEquals(NUM_ACCOUNTS_TO_CREATE, accountsBeforeReallocation.size(), ERROR_INVALID_NUMBER_OF_ACCOUNTS);

		for(Account accountRecord : accountsBeforeReallocation)
		{
			accountRecord.put(AW_DAL_Account.FIELD_IS_REALLOCATED, true);
		}
		update accountsBeforeReallocation;

		Test.startTest();
		Database.executeBatch(new AW_BATCH_AccountReallocation());
		Test.stopTest();

		List<Account> accountsAfterReallocation = AW_DAL_Account.getAll();
		System.assertEquals(NUM_ACCOUNTS_TO_CREATE, accountsAfterReallocation.size(), ERROR_INVALID_NUMBER_OF_ACCOUNTS);

		for(Integer i = 0; i < accountsAfterReallocation.size(); i++)
		{
			Account accountBeforeReallocation = accountsBeforeReallocation.get(i);
			Account accountAfterReallocation = accountsAfterReallocation.get(i);

			System.assertEquals(true, accountBeforeReallocation.get(AW_DAL_Account.FIELD_IS_REALLOCATED), 'Account # ' + i + ' not already reallocated');
			System.assertEquals(true, accountAfterReallocation.get(AW_DAL_Account.FIELD_IS_REALLOCATED), 'Account # ' + i + ' not reallocated');
			System.assertNotEquals
					(
							accountBeforeReallocation.get(AW_DAL_Account.FIELD_OWNER_CHANGED_DATE),
							accountAfterReallocation.get(AW_DAL_Account.FIELD_OWNER_CHANGED_DATE),
							'Owner Changed Date not updated for Account # ' + i
					);
			System.assertNotEquals(accountBeforeReallocation.OwnerId, accountAfterReallocation.OwnerId, 'Owner not changed for Account # ' + i);
			System.assertEquals
					(
							AW_DAL_Profile.PROFILE_ADVISER,
							accountBeforeReallocation.Owner.Profile?.Name,
							'Account # ' + i + ' not assigned to Liberty Adviser Profile before reallocation'
					);
			System.assertEquals
					(
							AW_DAL_Profile.PROFILE_LIBERTY_LEAD_MANAGER,
							accountAfterReallocation.Owner.Profile?.Name,
							'Account # ' + i + ' not reallocated to Liberty Lead Profile'
					);
		}
	}

	/**
	 * @description - Test method to check the reallocation failure when the orphan account has an open activity
	 *                associated to it
	 */
	@IsTest
	private static void doNotReallocate()
	{
		List<Account> accountsBeforeReallocation = AW_DAL_Account.getAll();
		System.assertEquals(NUM_ACCOUNTS_TO_CREATE, accountsBeforeReallocation.size(), ERROR_INVALID_NUMBER_OF_ACCOUNTS);
		Account accountWithOpenActivities = accountsBeforeReallocation.get(0);
		Account accountWithinTimeframe = accountsBeforeReallocation.get(1);

		AW_DAL_TestDataFactory.createTasks
				(
						AW_DAL_Task.RT_ORPHAN_TASK,
						accountWithOpenActivities.Id,
						accountWithOpenActivities.OwnerId,
						NUM_ACCOUNTS_TO_CREATE_FOR_EACH_IDENTITY_NUMBER
				).iterator().next();
		accountWithinTimeframe.put
				(
						AW_DAL_Account.FIELD_OWNER_CHANGED_DATE,
						System.now()
				); //Set Owner Changed Date to current time so that it comes within SLA and not get reallocated
		update accountWithinTimeframe;

		Test.startTest();
		Database.executeBatch(new AW_BATCH_AccountReallocation());
		Test.stopTest();

		List<Account> accountsAfterReallocation = AW_DAL_Account.getAll();
		System.assertEquals(NUM_ACCOUNTS_TO_CREATE, accountsAfterReallocation.size(), ERROR_INVALID_NUMBER_OF_ACCOUNTS);

		for(Integer i = 0; i < accountsAfterReallocation.size(); i++)
		{
			Account accountBeforeReallocation = accountsBeforeReallocation.get(i);
			Account accountAfterReallocation = accountsAfterReallocation.get(i);

			System.assertEquals(false, accountBeforeReallocation.get(AW_DAL_Account.FIELD_IS_REALLOCATED), 'Account # ' + i + ' already reallocated');
			System.assertEquals(false, accountAfterReallocation.get(AW_DAL_Account.FIELD_IS_REALLOCATED), 'Account # ' + i + ' should not be reallocated');
			System.assertEquals
					(
							accountBeforeReallocation.get(AW_DAL_Account.FIELD_OWNER_CHANGED_DATE),
							accountAfterReallocation.get(AW_DAL_Account.FIELD_OWNER_CHANGED_DATE),
							'Owner Changed Date should not be updated for Account # ' + i
					);
			System.assertEquals
					(
							accountBeforeReallocation.OwnerId,
							accountAfterReallocation.OwnerId,
							'Owner should not be changed for Account # ' + i
					);
		}
	}

	/**
	 * @description Method to make sure the ReallocationSetting Custom metadata record is properly configured
	 *
	 * @param objectName Name of the object e.g. Account, Lead
	 */
	private static void verifyCustomMetadata(String objectName)
	{
		String customMetadataName = (objectName == AW_DAL_Account.OBJECT_NAME) ?
				AW_DAL_ReallocationSetting.DEVELOPER_NAME_ACCOUNT_REALLOCATION : AW_DAL_ReallocationSetting.DEVELOPER_NAME_LEAD_REALLOCATION;
		AW_ReallocationSetting__mdt reallocationSetting = AW_DAL_ReallocationSetting.getInstance(customMetadataName);

		System.assertNotEquals
				(
						null,
						reallocationSetting,
						'ReallocationSetting Custom metadata record with DeveloperName: '
						+ AW_DAL_ReallocationSetting.DEVELOPER_NAME_ACCOUNT_REALLOCATION
						+ ' not found'
				);
		System.assert
				(
						reallocationSetting.AW_AveragePerformanceThreshold__c > 0,
						'Average Performance Threshold should be greater than zero. Current Value: ' + reallocationSetting.AW_AveragePerformanceThreshold__c
				);
		System.assert
				(
						reallocationSetting.AW_SLADurationInMilliseconds__c > 0,
						'SLA Duration in Milliseconds should be greater than zero. Current Value: ' + reallocationSetting.AW_SLADurationInMilliseconds__c
				);
		System.assert
				(
						reallocationSetting.AW_WeightForLeadConversionRate__c > 0,
						'Weight For Lead Conversion Rate should be greater than zero. Current Value: ' + reallocationSetting.AW_WeightForLeadConversionRate__c
				);
		System.assert
				(
						reallocationSetting.AW_WeightForOpportunityWinRate__c > 0,
						'Weight For Opportunity Win Rate should be greater than zero. Current Value: ' + reallocationSetting.AW_WeightForOpportunityWinRate__c
				);
	}

	/**
	 * @description Create
	 *
	 * @param objectName Name of the object e.g. Account, Lead
	 * @param accountRecord Account record to link Team Members to
	 */
	@TestVisible
	private static void setupAccountTeam(String objectName, Account accountRecord)
	{
		List<User> advisers = AW_DAL_User.findRandomActiveAdvisers(NUM_OF_ADVISER_TO_RETRIEVE);

		if(objectName.equalsIgnoreCase(AW_DAL_Account.OBJECT_NAME))
		{
			for(User adviser : advisers)
			{
				adviser.AW_Opt_in_out__c = true;
			}
			update advisers;
		}

		setupTargetAndPerformance(objectName, advisers);

		//add team member to each account and mark the role of team member as Adviser
		AW_DAL_TestDataFactory.createAccountTeamMembers(accountRecord, advisers, AW_DAL_AccountTeamMember.ROLE_ADVISER);
	}

	/**
	 * @description Method that generates Target and Performance records for the given list of users.
	 *
	 * @param objectName Name of the object e.g. Account, Lead
	 * @param users List of users for which Target and Performance records would be created.
	 */
	private static void setupTargetAndPerformance(String objectName, List<User> users)
	{
		String customMetadataName = (objectName == AW_DAL_Account.OBJECT_NAME) ?
				AW_DAL_ReallocationSetting.DEVELOPER_NAME_ACCOUNT_REALLOCATION : AW_DAL_ReallocationSetting.DEVELOPER_NAME_LEAD_REALLOCATION;
		AW_ReallocationSetting__mdt reallocationSetting = AW_DAL_ReallocationSetting.getInstance(customMetadataName);
		Datetime randomDate = CMN_DAL_SObjectDomain.generateRandomDate();
		List<AW_AdviserTarget__c> adviserTargets = AW_DAL_TestDataFactory.createAdviserTargets(users, randomDate.format('M'), randomDate.format('yyyy'));
		List<AW_AdviserPerformance__c> adviserPerformances =
				AW_DAL_TestDataFactory.createAdviserPerformances(CMN_UTIL_System.extractSetValues(users, AW_DAL_User.FIELD_UACF_ID));
		Integer minAveragePerformanceThreshold = Integer.valueOf(Math.floor(reallocationSetting.AW_AveragePerformanceThreshold__c));
		Integer maxAveragePerformanceThreshold = Integer.valueOf((100 * reallocationSetting.AW_WeightForLeadConversionRate__c)
				+ (100 * reallocationSetting.AW_WeightForOpportunityWinRate__c)) / 2;

		System.assert
				(
						minAveragePerformanceThreshold <= maxAveragePerformanceThreshold,
						'Average Performance Threshold of '
						+ reallocationSetting.AW_AveragePerformanceThreshold__c
						+ ' cannot be achieved with WeightForLeadConversionRate of '
						+ reallocationSetting.AW_WeightForLeadConversionRate__c
						+ ' and WeightForOpportunityWinRate of '
						+ reallocationSetting.AW_WeightForOpportunityWinRate__c
				);

		for(Integer i = 0; i < adviserPerformances.size(); i++)
		{
			Integer randomAveragePerformanceThreshold = CMN_UTIL_Random.nextInteger(minAveragePerformanceThreshold, maxAveragePerformanceThreshold, false);

			//Randomly generating number of converted and open leads based on WeightForLeadConversionRate and randomAveragePerformanceThreshold
			Integer numberOfConvertedLeads = CMN_DAL_SObjectDomain.generateRandomInteger(3);
			Integer numberOfOpenLeads = Integer.valueOf(Math.floor
					(numberOfConvertedLeads * reallocationSetting.AW_WeightForLeadConversionRate__c * 100 / randomAveragePerformanceThreshold)
					- numberOfConvertedLeads);
			System.assert
					(
							numberOfOpenLeads >= 0,
							'Cannot calculate Number of Open Leads for given WeightForLeadConversionRate of '
							+ reallocationSetting.AW_WeightForLeadConversionRate__c
							+ ' and AveragePerformanceThreshold of '
							+ randomAveragePerformanceThreshold
					);

			//Randomly generating number of won and open opportunities based on WeightForOpportunityWinRate and randomAveragePerformanceThreshold
			Integer numberOfOpportunitiesWon = CMN_DAL_SObjectDomain.generateRandomInteger(3);
			Integer numberOfOpenOpportunities = Integer.valueOf(Math.floor
					(numberOfOpportunitiesWon * reallocationSetting.AW_WeightForOpportunityWinRate__c * 100 / randomAveragePerformanceThreshold)
					- numberOfOpportunitiesWon);
			System.assert
					(
							numberOfOpenOpportunities >= 0,
							'Cannot calculate Number of Open Opportunities for given WeightForOpportunityWinRate of '
							+ reallocationSetting.AW_WeightForOpportunityWinRate__c
							+ ' and AveragePerformanceThreshold of '
							+ randomAveragePerformanceThreshold
					);

			adviserPerformances.get(i).AW_AdviserTarget__c = adviserTargets.get(i).Id;
			adviserPerformances.get(i).AW_NumberOfOpenLeads__c = numberOfOpenLeads;
			adviserPerformances.get(i).AW_NumberOfLeadConverted__c = numberOfConvertedLeads;
			adviserPerformances.get(i).AW_NumberOfOpportunitiesOpen__c = numberOfOpenOpportunities;
			adviserPerformances.get(i).AW_NumberOfOpportunitiesWon__c = numberOfOpportunitiesWon;
		}

		update adviserPerformances;
	}
}