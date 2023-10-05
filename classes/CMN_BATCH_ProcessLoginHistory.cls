/**
 * @description Batch class to process Login History and store login information on Login Frequency records
 *
 * @see CMN_BATCH_ProcessLoginHistory_TEST @story ST-327625
 *
 * @author latika.kharbanda@accenture.com jason.van.beukering@accenture.com
 *
 * @date December 2022
 */
public inherited sharing class CMN_BATCH_ProcessLoginHistory implements Database.Batchable<SObject>
{
	private static final String HYPHEN = '-';
	@TestVisible
	private static final String UNDERSCORE = '_';

	/**
	 * @description Fetches login histories greater than or equal to the last successful run time of the schedule and less than System.today()
	 *
	 * @param bc The batchable context
	 *
	 * @return Database.QueryLocator
	 */
	public Database.QueryLocator start(Database.BatchableContext bc)
	{
		CMN_ScheduleSetting__c setting = CMN_DAL_ScheduleSetting.getScheduleSetting(CMN_SCHED_LoginFrequency.class.getName());

		Database.QueryLocator queryLocator = CMN_DAL_LoginHistory.findByLoginTime(setting?.CMN_LastSuccessfulRunTime__c, Test.isRunningTest());

		return queryLocator;
	}

	/**
	 * @description Execute method of batch class
	 *
	 * @param bc The batchable context
	 * @param loginHistories List of login histories to be processed
	 */
	public void execute(Database.BatchableContext bc, List<LoginHistory> loginHistories)
	{
		generateAndStoreLoginFrequencies(convertToDto(loginHistories));
	}

	/**
	 * @description Finish method of batch class
	 *
	 * @param bc The batchable context
	 */
	@SuppressWarnings('PMD.EmptyStatementBlock')
	public void finish(Database.BatchableContext bc)
	{
	}

	/**
	 * @description Will process provided Items and aggregate them into Login Frequency objects; these will be committed
	 *
	 * @param dtoLoginHistories A list of items to process
	 */
	@TestVisible
	private static void generateAndStoreLoginFrequencies(List<DTO_LoginHistory> dtoLoginHistories)
	{
		CMN_ScheduleSetting__c setting = CMN_DAL_ScheduleSetting.getScheduleSetting(CMN_SCHED_LoginFrequency.class.getName());
		setting = setting == null ? new CMN_ScheduleSetting__c(Name = CMN_SCHED_LoginFrequency.class.getName()) : setting;
		Datetime today = System.today();
		Datetime lastSuccessfulRunTime = Datetime.newInstance(today.year(), today.month(), today.day());

		Integer uniqueCount;
		Integer totalCount;
		Set<String> concatenatedStrings = new Set<String>();
		Map<String, Integer> uniqueCountsMap = new Map<String, Integer>();
		Map<String, Integer> totalCountsMap = new Map<String, Integer>();
		List<CMN_LoginFrequency__c> recordsToCreate = new List<CMN_LoginFrequency__c>();
		List<CMN_LoginFrequency__c> recordsToUpdate = new List<CMN_LoginFrequency__c>();
		String previousConcatenatedString;
		Date previousLoginDate;

		for(DTO_LoginHistory currentLoginHistory : dtoLoginHistories)
		{
			String currentConcatenatedString = currentLoginHistory.userId + UNDERSCORE + currentLoginHistory.loginTime.format('yyyy-MM');
			concatenatedStrings.add(currentConcatenatedString);
			if(!CMN_UTIL_String.equals(previousConcatenatedString, currentConcatenatedString))
			{
				if(String.isNotBlank(previousConcatenatedString))
				{
					uniqueCountsMap.put(previousConcatenatedString, uniqueCount);
					totalCountsMap.put(previousConcatenatedString, totalCount);
				}

				previousConcatenatedString = currentConcatenatedString;
				previousLoginDate = null;
				uniqueCount = 0;
				totalCount = 0;
			}

			totalCount++;

			Date currentLoginDate = currentLoginHistory.loginTime.date();

			if(previousLoginDate != currentLoginDate)
			{
				previousLoginDate = currentLoginDate;
				uniqueCount++;
			}
		}

		uniqueCountsMap.put(previousConcatenatedString, uniqueCount);
		totalCountsMap.put(previousConcatenatedString, totalCount);

		//Will fetch all the existing Login Frequency records matched on the concatenated strings in the set
		List<CMN_LoginFrequency__c> relatedLoginFrequencyRecords = CMN_DAL_LoginFrequency.findByUserIdAndLoginMonth(concatenatedStrings);
		Map<String, List<CMN_LoginFrequency__c>> userIdWithLoginMonthToRecordMap =
				CMN_UTIL_System.convertListToStringMap(relatedLoginFrequencyRecords, CMN_DAL_LoginFrequency.FIELD_USERID_WITH_LOGIN_YEAR_AND_MONTH);

		for(String userIdAndLoginMonth : concatenatedStrings)
		{
			//If a Login Frequency record exists for the current concatenated string, we will update the counts on that record
			if(userIdWithLoginMonthToRecordMap.get(userIdAndLoginMonth) != null)
			{
				CMN_LoginFrequency__c recordToUpdate = (CMN_LoginFrequency__c)userIdWithLoginMonthToRecordMap.get(userIdAndLoginMonth)[0];
				recordToUpdate.CMN_TotalLoginCount__c = recordToUpdate.CMN_TotalLoginCount__c + totalCountsMap.get(userIdAndLoginMonth);
				recordToUpdate.CMN_UniqueLoginCount__c = recordToUpdate.CMN_UniqueLoginCount__c + uniqueCountsMap.get(userIdAndLoginMonth);
				recordsToUpdate.add(recordToUpdate);
			}
			else
			//If a Login Frequency record does not exists for the current concatenated string, we will create a new record
			{
				CMN_LoginFrequency__c recordToCreate = new CMN_LoginFrequency__c();
				recordToCreate.CMN_User__c = userIdAndLoginMonth.substringBefore(UNDERSCORE);
				recordToCreate.CMN_LoginYear__c = Integer.valueOf(userIdAndLoginMonth.substringBetween(UNDERSCORE, HYPHEN));
				recordToCreate.CMN_LoginMonth__c = Integer.valueOf(userIdAndLoginMonth.substringAfter(HYPHEN));
				recordToCreate.CMN_UniqueLoginCount__c = uniqueCountsMap.get(userIdAndLoginMonth);
				recordToCreate.CMN_TotalLoginCount__c = totalCountsMap.get(userIdAndLoginMonth);
				recordToCreate.CMN_UserIdWithLoginYearAndMonth__c = userIdAndLoginMonth;
				recordsToCreate.add(recordToCreate);
			}
		}

		setting.CMN_LastSuccessfulRunTime__c = lastSuccessfulRunTime;

		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork();
		unitOfWork.addSObjectTypes(new List<Schema.SObjectType> {CMN_LoginFrequency__c.SObjectType, CMN_ScheduleSetting__c.SObjectType});

		unitOfWork.registerNew(recordsToCreate);
		unitOfWork.registerDirty(recordsToUpdate);
		unitOfWork.registerChange(setting);

		unitOfWork.commitWork();
	}

	/**
	 * @description Converts List<LoginHistory> to List<DTO_LoginHistory>
	 *
	 * @param loginHistories List of login histories to be converted
	 *
	 * @return List of converted Items
	 */
	public static List<DTO_LoginHistory> convertToDto(List<LoginHistory> loginHistories)
	{
		//We cannot create Login History records in test class, so we are converting each LoginHistory to DTO_LoginHistory
		List<DTO_LoginHistory> dtoLoginHistories = new List<DTO_LoginHistory>();

		for(LoginHistory loginHistory : loginHistories)
		{
			DTO_LoginHistory dtoLoginHistory = new DTO_LoginHistory();
			dtoLoginHistory.userId = loginHistory.UserId;
			dtoLoginHistory.loginTime = loginHistory.LoginTime;
			dtoLoginHistories.add(dtoLoginHistory);
		}
		return dtoLoginHistories;
	}

	/**
	 * @description DTO class definition
	 */
	public class DTO_LoginHistory
	{
		/**
		 * @description Stores the value of userId
		 */
		public Id userId;
		/**
		 * @description Stores the value of loginTime
		 */
		public Datetime loginTime;
	}
}