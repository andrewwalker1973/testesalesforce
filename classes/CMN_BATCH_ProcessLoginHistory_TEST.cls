/**
 * @description Test Class for CMN_BATCH_ProcessLoginHistory
 *
 * @see CMN_BATCH_ProcessLoginHistory
 *
 * @author latika.kharbanda@accenture.com
 *
 * @date November 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_BATCH_ProcessLoginHistory_TEST
{
	private static final Integer NUMBER_OF_LOGIN_FREQUENCIES_TO_CREATE = 2;

	@TestSetup
	private static void setup()
	{
		CMN_ScheduleSetting__c settings = new CMN_ScheduleSetting__c();
		settings.Name = CMN_SCHED_LoginFrequency.class.getName();
		settings.CMN_LastSuccessfulRunTime__c = CMN_DAL_SObjectDomain.generateRandomDateTime();
		insert settings;
	}

	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	@IsTest
	private static void batchClassRun()
	{
		Test.startTest();
		Id batchJobId = Database.executeBatch(new CMN_BATCH_ProcessLoginHistory());
		Test.stopTest();

		Assert.isNotNull(batchJobId, 'CMN_BATCH_ProcessLoginHistory was not started');
	}

	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
	@IsTest
	private static void upsertLoginFrequencyRecords()
	{
		List<CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory> dtoLoginHistories = CMN_DAL_DataFactory.getDtoLoginHistories();
		Set<String> concatenatedStrings = getConcatenatedStrings(dtoLoginHistories);

		List<CMN_LoginFrequency__c> createdLoginFrequencyRecords =
				CMN_DAL_DataFactory.createLoginFrequencyRecords(NUMBER_OF_LOGIN_FREQUENCIES_TO_CREATE, concatenatedStrings);

		Test.startTest();
		CMN_BATCH_ProcessLoginHistory.generateAndStoreLoginFrequencies(dtoLoginHistories);
		Test.stopTest();

		List<CMN_LoginFrequency__c> updatedLoginFrequencies = CMN_DAL_LoginFrequency.getAll();

		Map<String, Integer> uniqueCountsMap = new Map<String, Integer>
		{
				dtoLoginHistories[0].userId + '_2022-05' => 1,
				dtoLoginHistories[3].userId + '_2022-05' => 2,
				dtoLoginHistories[4].userId + '_2022-05' => 1,
				dtoLoginHistories[5].userId + '_2022-06' => 1
		};

		Map<String, Integer> totalCountsMap = new Map<String, Integer>
		{
				dtoLoginHistories[0].userId + '_2022-05' => 2,
				dtoLoginHistories[3].userId + '_2022-05' => 2,
				dtoLoginHistories[4].userId + '_2022-05' => 1,
				dtoLoginHistories[5].userId + '_2022-06' => 1
		};

		Assert.areEqual(concatenatedStrings.size(), updatedLoginFrequencies.size(), 'Incorrect number of login frequencies created');

		for(Integer i = 0; i < NUMBER_OF_LOGIN_FREQUENCIES_TO_CREATE; i++)
		{
			CMN_LoginFrequency__c loginFrequencyBeforeUpdate = createdLoginFrequencyRecords.get(i);
			CMN_LoginFrequency__c loginFrequencyAfterUpdate = updatedLoginFrequencies.get(i);
			Integer toBeUniqueLoginCount = (Integer)loginFrequencyBeforeUpdate.CMN_UniqueLoginCount__c
					+ uniqueCountsMap.get(loginFrequencyBeforeUpdate.CMN_UserIdWithLoginYearAndMonth__c);
			Integer toBeTotalLoginCount = (Integer)loginFrequencyBeforeUpdate.CMN_TotalLoginCount__c
					+ totalCountsMap.get(loginFrequencyBeforeUpdate.CMN_UserIdWithLoginYearAndMonth__c);
			Assert.areEqual(toBeUniqueLoginCount, loginFrequencyAfterUpdate.CMN_UniqueLoginCount__c, 'Unique count is not updated correctly.');
			Assert.areEqual(toBeTotalLoginCount, loginFrequencyAfterUpdate.CMN_TotalLoginCount__c, 'Total login count is not updated correctly.');
		}

		for(Integer i = NUMBER_OF_LOGIN_FREQUENCIES_TO_CREATE; i < updatedLoginFrequencies.size(); i++)
		{
			CMN_LoginFrequency__c loginFrequency = updatedLoginFrequencies.get(i);
			Integer toBeUniqueLoginCount = uniqueCountsMap.get(loginFrequency.CMN_UserIdWithLoginYearAndMonth__c);
			Integer toBeTotalLoginCount = totalCountsMap.get(loginFrequency.CMN_UserIdWithLoginYearAndMonth__c);
			Assert.areEqual(toBeUniqueLoginCount, loginFrequency.CMN_UniqueLoginCount__c, 'Unique login count is not updated correctly.');
			Assert.areEqual(toBeTotalLoginCount, loginFrequency.CMN_TotalLoginCount__c, 'Total login count is not updated correctly.');
		}

		Assert.areEqual(concatenatedStrings.size(), updatedLoginFrequencies.size(), 'Login Frequency Records created incorrectly');
	}

	private static Set<String> getConcatenatedStrings(List<CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory> loginHistories)
	{
		Set<String> concatenatedStrings = new Set<String>();

		for(CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory loginHistory : loginHistories)
		{
			String concatenatedUserIdAndLoginMonth = loginHistory.userId + CMN_BATCH_ProcessLoginHistory.UNDERSCORE + loginHistory.loginTime.format('yyyy-MM');
			concatenatedStrings.add(concatenatedUserIdAndLoginMonth);
		}
		return concatenatedStrings;
	}
}