/**
 * @description Unit tests for AW_BATCH_LeadReallocation
 *
 * @see AW_BATCH_LeadReallocation
 * @see AW_BATCH_Reallocation
 *
 * @author prashant.k.jain@accenture.com
 *
 * @date July 2021
 */
@IsTest(SeeAllData=false IsParallel=false)
public inherited sharing class AW_BATCH_LeadReallocation_TEST
{
	private static final Integer NUM_LEADS_TO_CREATE = 4;
	private static final String ERROR_INVALID_NUMBER_OF_LEADS = 'Incorrect number of leads found';

	/**
	 * @description Setup a test data
	 */
	@TestSetup
	private static void setup()
	{
		AW_BATCH_AccountReallocation_TEST.setup(AW_DAL_Lead.OBJECT_NAME);

		AW_ReallocationSetting__mdt reallocationSetting = AW_DAL_ReallocationSetting.getInstance(AW_DAL_ReallocationSetting.DEVELOPER_NAME_LEAD_REALLOCATION);
		Integer counter = 0;
		List<Account> accounts = AW_DAL_Account.getAll();
		List<Lead> leads;
		User adviser;
		List<String> hotLeadSources = new List<String>
		{
				AW_DAL_Lead.LEAD_SOURCE_WEBSITE,
				AW_DAL_Lead.LEAD_SOURCE_CONTACT_CENTRE
		};

		System.assertEquals(AW_BATCH_AccountReallocation_TEST.NUM_ACCOUNTS_TO_CREATE, accounts.size(), AW_BATCH_AccountReallocation_TEST.ERROR_INVALID_NUMBER_OF_ACCOUNTS);

		//Make sure that Owner for Leads and Accounts are different
		Account firstAccount = accounts.iterator().next();
		do
		{
			adviser = AW_DAL_User.findRandomActiveAdviser();
		}
		while(adviser.Id.equals(firstAccount.OwnerId));

		Long slaDurationInMilliseconds = -reallocationSetting.AW_SLADurationInMilliseconds__c.longValue();
		Datetime outOfSLAOwnerChangedDate = BusinessHours.add(CMN_DAL_BusinessHours.getDefaultBusinessHours()?.Id, Datetime.now(), slaDurationInMilliseconds);

		System.runAs(adviser)
		{
			leads = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, NUM_LEADS_TO_CREATE, adviser.Id);
			for(Lead lead : leads)
			{
				Integer index = Integer.valueOf(counter++ / 2);

				lead.put(AW_DAL_Lead.FIELD_IS_REALLOCATED, false);
				lead.put(AW_DAL_Lead.FIELD_DATE_RECEIVED, outOfSLAOwnerChangedDate);
				lead.put(reallocationSetting.AW_BranchIdFieldAPIName__c, accounts.get(index).Id); //Assign two Leads per Account
				lead.put(AW_DAL_Lead.FIELD_LEAD_SOURCE, hotLeadSources.get(index)); //Assign two Leads per Hot Lead Source
			}
		}
		CMN_DAL_SObjectDomain.updateDBObjects(leads);
	}

	/**
	 * @description - Test method to check the reallocation of an hot leads to an Adviser
	 */
	@IsTest
	private static void reallocationToAdviser()
	{
		AW_ReallocationSetting__mdt reallocationSetting = AW_DAL_ReallocationSetting.getInstance(AW_DAL_ReallocationSetting.DEVELOPER_NAME_LEAD_REALLOCATION);
		List<Lead> leadsBeforeReallocation = CMN_DAL_Lead.getAll();
		Map<String, Decimal> adviserPerformanceByUACFId = new Map<String, Decimal>();
		Set<String> uacfIds;

		System.assertEquals(NUM_LEADS_TO_CREATE, leadsBeforeReallocation.size(), ERROR_INVALID_NUMBER_OF_LEADS);

		//Add team members for all accounts
		for(Account accountRecord : AW_DAL_Account.getAll())
		{
			AW_BATCH_AccountReallocation_TEST.setupAccountTeam(AW_DAL_Lead.OBJECT_NAME, accountRecord);
		}

		Test.startTest();
		Database.executeBatch(new AW_BATCH_LeadReallocation());
		Test.stopTest();

		List<Lead> leadsAfterReallocation = CMN_DAL_Lead.getAll();
		System.assertEquals(NUM_LEADS_TO_CREATE, leadsAfterReallocation.size(), ERROR_INVALID_NUMBER_OF_LEADS);

		//Populate adviserPerformanceByUACFId which will be used to confirm if the lead was reallocated to a high performing adviser or not
		uacfIds = CMN_UTIL_System.extractSetValues(leadsAfterReallocation, reallocationSetting.AW_OwnerUACFIdFieldAPIName__c);
		AW_BATCH_Reallocation.populateAdviserPerformance(uacfIds, adviserPerformanceByUACFId, reallocationSetting.AW_WeightForLeadConversionRate__c, reallocationSetting.AW_WeightForOpportunityWinRate__c); //Populate adviser Performance map using UACFId as key

		for(Integer i = 0; i < leadsAfterReallocation.size(); i++)
		{
			Lead leadBeforeReallocation = leadsBeforeReallocation.get(i);
			Lead leadAfterReallocation = leadsAfterReallocation.get(i);
			User leadOwnerBeforeReallocation = AW_DAL_User.findById(leadBeforeReallocation.OwnerId);
			User leadOwnerAfterReallocation = AW_DAL_User.findById(leadAfterReallocation.OwnerId);
			String ownerUACFId = (String)leadAfterReallocation.get(reallocationSetting.AW_OwnerUACFIdFieldAPIName__c);

			System.assertEquals(false, leadBeforeReallocation.get(AW_DAL_Lead.FIELD_IS_REALLOCATED), 'Lead # ' + i + ' already reallocated');
			System.assertEquals(true, leadAfterReallocation.get(AW_DAL_Lead.FIELD_IS_REALLOCATED), 'Lead # ' + i + ' not reallocated');
			System.assertNotEquals(leadBeforeReallocation.get(AW_DAL_Lead.FIELD_DATE_RECEIVED), leadAfterReallocation.get(AW_DAL_Lead.FIELD_DATE_RECEIVED), 'Date Received not updated for Lead # ' + i);
			System.assertNotEquals(leadBeforeReallocation.OwnerId, leadAfterReallocation.OwnerId, 'Owner not changed for Lead # ' + i);
			System.assertEquals(AW_DAL_Profile.PROFILE_ADVISER, leadOwnerBeforeReallocation?.Profile?.Name, 'Lead # ' + i + ' not assigned to Liberty Adviser Profile before reallocation');
			System.assertEquals(AW_DAL_Profile.PROFILE_ADVISER, leadOwnerAfterReallocation?.Profile?.Name, 'Lead # ' + i + ' not reallocated to Liberty Adviser Profile');
			System.assert(adviserPerformanceByUACFId.get(ownerUACFId.toUpperCase()) >= reallocationSetting.AW_AveragePerformanceThreshold__c, 'Lead # ' + i + ' not reallocated to a high performing adviser. Adviser Performance: ' + adviserPerformanceByUACFId.get(ownerUACFId) + ' Average Performance Threshold: ' + reallocationSetting.AW_AveragePerformanceThreshold__c);
		}
	}

	/**
	 * @description - Test method to check the reallocation of an hot leads to an Adviser
	 */
	@IsTest
	private static void reallocationToLeadManager()
	{
		AW_ReallocationSetting__mdt reallocationSetting = AW_DAL_ReallocationSetting.getInstance(AW_DAL_ReallocationSetting.DEVELOPER_NAME_LEAD_REALLOCATION);
		List<Lead> leadsBeforeReallocation = CMN_DAL_Lead.getAll();

		System.assertEquals(NUM_LEADS_TO_CREATE, leadsBeforeReallocation.size(), ERROR_INVALID_NUMBER_OF_LEADS);
		Map<Id, Account> accountsById = new Map<Id, Account>(AW_DAL_Account.getAll());

		//Setting the Lead owner same as the Account Owner
		for(Lead leadRecord : leadsBeforeReallocation)
		{
			Id leadBranchId = (Id)leadRecord.get(reallocationSetting.AW_BranchIdFieldAPIName__c);
			Account leadBranch = accountsById.get(leadBranchId);
			leadRecord.put(CMN_DAL_SObjectDomain.FIELD_OWNER_ID, leadBranch.OwnerId);
		}
		update leadsBeforeReallocation;

		Long slaDurationInMilliseconds = -reallocationSetting.AW_SLADurationInMilliseconds__c.longValue();
		Datetime outOfSLAOwnerChangedDate = BusinessHours.add(CMN_DAL_BusinessHours.getDefaultBusinessHours()?.Id, Datetime.now(), slaDurationInMilliseconds);

		//Set the Reallocation Date, as setting Owner in the previous update would reset the date
		for(Lead leadRecord : leadsBeforeReallocation)
		{
			leadRecord.put(AW_DAL_Lead.FIELD_DATE_RECEIVED, outOfSLAOwnerChangedDate);
		}
		update leadsBeforeReallocation;

		Test.startTest();
		Database.executeBatch(new AW_BATCH_LeadReallocation());
		Test.stopTest();

		List<Lead> leadsAfterReallocation = CMN_DAL_Lead.getAll();
		System.assertEquals(NUM_LEADS_TO_CREATE, leadsAfterReallocation.size(), ERROR_INVALID_NUMBER_OF_LEADS);

		for(Integer i = 0; i < leadsAfterReallocation.size(); i++)
		{
			Lead leadBeforeReallocation = leadsBeforeReallocation.get(i);
			Lead leadAfterReallocation = leadsAfterReallocation.get(i);
			User leadOwnerBeforeReallocation = AW_DAL_User.findById(leadBeforeReallocation.OwnerId);
			User leadOwnerAfterReallocation = AW_DAL_User.findById(leadAfterReallocation.OwnerId);

			System.assertEquals(false, leadBeforeReallocation.get(AW_DAL_Lead.FIELD_IS_REALLOCATED), 'Lead # ' + i + ' already reallocated');
			System.assertEquals(true, leadAfterReallocation.get(AW_DAL_Lead.FIELD_IS_REALLOCATED), 'Lead # ' + i + ' not reallocated');
			System.assertNotEquals(leadBeforeReallocation.get(AW_DAL_Lead.FIELD_DATE_RECEIVED), leadAfterReallocation.get(AW_DAL_Lead.FIELD_DATE_RECEIVED), 'Date Received not updated for Lead # ' + i);
			System.assertNotEquals(leadBeforeReallocation.OwnerId, leadAfterReallocation.OwnerId, 'Owner not changed for Lead # ' + i);
			System.assertEquals(AW_DAL_Profile.PROFILE_ADVISER, leadOwnerBeforeReallocation?.Profile?.Name, 'Lead # ' + i + ' not assigned to Liberty Adviser Profile before reallocation');
			System.assertEquals(AW_DAL_Profile.PROFILE_LIBERTY_LEAD_MANAGER, leadOwnerAfterReallocation?.Profile?.Name, 'Lead # ' + i + ' not reallocated to Liberty Lead Profile');
		}
	}

	/**
	 * @description - Test method to check the reallocation of an leads to a Lead Manager when the lead
	 *                is already reallocated to an Adviser
	 */
	@IsTest
	private static void reallocationToLeadManagerWhenAlreadyReallocated()
	{
		AW_ReallocationSetting__mdt reallocationSetting = AW_DAL_ReallocationSetting.getInstance(AW_DAL_ReallocationSetting.DEVELOPER_NAME_LEAD_REALLOCATION);
		List<Lead> leadsBeforeReallocation = CMN_DAL_Lead.getAll();
		System.assertEquals(NUM_LEADS_TO_CREATE, leadsBeforeReallocation.size(), ERROR_INVALID_NUMBER_OF_LEADS);

		for(Lead leadRecord : leadsBeforeReallocation)
		{
			leadRecord.put(AW_DAL_Lead.FIELD_IS_REALLOCATED, true);
		}
		update leadsBeforeReallocation;

		Test.startTest();
		Database.executeBatch(new AW_BATCH_LeadReallocation());
		Test.stopTest();

		List<Lead> leadsAfterReallocation = CMN_DAL_Lead.getAll();
		System.assertEquals(NUM_LEADS_TO_CREATE, leadsAfterReallocation.size(), ERROR_INVALID_NUMBER_OF_LEADS);

		for(Integer i = 0; i < leadsAfterReallocation.size(); i++)
		{
			Lead leadBeforeReallocation = leadsBeforeReallocation.get(i);
			Lead leadAfterReallocation = leadsAfterReallocation.get(i);
			User leadOwnerBeforeReallocation = AW_DAL_User.findById(leadBeforeReallocation.OwnerId);
			User leadOwnerAfterReallocation = AW_DAL_User.findById(leadAfterReallocation.OwnerId);

			System.assertEquals(true, leadBeforeReallocation.get(AW_DAL_Lead.FIELD_IS_REALLOCATED), 'Lead # ' + i + ' not already reallocated');
			System.assertEquals(true, leadAfterReallocation.get(AW_DAL_Lead.FIELD_IS_REALLOCATED), 'Lead # ' + i + ' not reallocated');
			System.assertNotEquals(leadBeforeReallocation.get(AW_DAL_Lead.FIELD_DATE_RECEIVED), leadAfterReallocation.get(AW_DAL_Lead.FIELD_DATE_RECEIVED), 'Date Received not updated for Lead # ' + i);
			System.assertNotEquals(leadBeforeReallocation.OwnerId, leadAfterReallocation.OwnerId, 'Owner not changed for Lead # ' + i);
			System.assertEquals(AW_DAL_Profile.PROFILE_ADVISER, leadOwnerBeforeReallocation?.Profile?.Name, 'Lead # ' + i + ' not assigned to Liberty Adviser Profile before reallocation');
			System.assertEquals(AW_DAL_Profile.PROFILE_LIBERTY_LEAD_MANAGER, leadOwnerAfterReallocation?.Profile?.Name, 'Lead # ' + i + ' not reallocated to Liberty Lead Profile');
		}
	}

	/**
	 * @description - Test method to check the reallocation failure when the lead has an open activity
	 *                associated to it
	 */
	@IsTest
	private static void doNotReallocate()
	{
		AW_ReallocationSetting__mdt reallocationSetting = AW_DAL_ReallocationSetting.getInstance(AW_DAL_ReallocationSetting.DEVELOPER_NAME_LEAD_REALLOCATION);
		List<Lead> leadsBeforeReallocation = CMN_DAL_Lead.getAll();
		System.assertEquals(NUM_LEADS_TO_CREATE, leadsBeforeReallocation.size(), ERROR_INVALID_NUMBER_OF_LEADS);

		//In this loop, create open activities for some leads and bring others within SLA
		AW_DAL_TestDataFactory.createTasksWithWhoId(AW_DAL_Task.RT_ORPHAN_TASK, leadsBeforeReallocation.get(0).Id, leadsBeforeReallocation.get(0).OwnerId, 1).iterator().next();
		leadsBeforeReallocation.get(1).put(AW_DAL_Lead.FIELD_DATE_RECEIVED, Datetime.now()); //Set Date Received to current time so that it comes within SLA and not get reallocated
		leadsBeforeReallocation.get(2).put(AW_DAL_Lead.FIELD_LEAD_SOURCE, AW_DAL_Lead.LEAD_SOURCE_CLIENT_REQUEST); //Set Lead Source to a non-Hot Lead Source
		leadsBeforeReallocation.get(3).put(AW_DAL_Lead.FIELD_LEAD_SOURCE, null); //Set Lead Source to null
		update leadsBeforeReallocation;

		Test.startTest();
		Database.executeBatch(new AW_BATCH_LeadReallocation());
		Test.stopTest();

		List<Lead> leadsAfterReallocation = CMN_DAL_Lead.getAll();
		System.assertEquals(NUM_LEADS_TO_CREATE, leadsAfterReallocation.size(), ERROR_INVALID_NUMBER_OF_LEADS);

		for(Integer i = 0; i < leadsAfterReallocation.size(); i++)
		{
			Lead leadBeforeReallocation = leadsBeforeReallocation.get(i);
			Lead leadAfterReallocation = leadsAfterReallocation.get(i);

			System.assertEquals(false, leadBeforeReallocation.get(AW_DAL_Lead.FIELD_IS_REALLOCATED), 'Lead # ' + i + ' already reallocated');
			System.assertEquals(false, leadAfterReallocation.get(AW_DAL_Lead.FIELD_IS_REALLOCATED), 'Lead # ' + i + ' should not be reallocated');
			System.assertEquals(leadBeforeReallocation.get(AW_DAL_Lead.FIELD_DATE_RECEIVED), leadAfterReallocation.get(AW_DAL_Lead.FIELD_DATE_RECEIVED), 'Date Received should not be updated for Lead # ' + i);
			System.assertEquals(leadBeforeReallocation.OwnerId, leadAfterReallocation.OwnerId, 'Owner should not be changed for Lead # ' + i);
		}
	}
}