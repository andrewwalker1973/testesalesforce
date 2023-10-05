/**
 * @description Trigger handler for the trigger AW_TRG_AdviserPerformance
 *
 * @see AW_TEST_TH_AdviserPerformance @story ST-2228
 *
 * @author Accenture
 *
 * @date 09 July 2019
 */
public class AW_TH_AdviserPerformance extends CMN_TRH_BaseObject
{
	private Map<String, Decimal> uacfidToAverageSatisfactionRating = new Map<String, Decimal>();
	private Map<String, SObject> targetCompositeKey2Target = new Map<String, SObject>();
	private Map<String, SObject> uacfId2User = new Map<String, SObject>();
	private Set<String> adviserTargetCompositeKeys = new Set<String>();
	private Set<String> uacfIds = new Set<String>();

	@TestVisible
	private static final String REQUIRED_FIELD_ERROR_MESSAGE = 'Please provide week number, year and UACFID';
	private static final String CLIENT_SATISFACTION_SURVEY_NAME = 'AW_ClientSatisfaction';

	/**
	 * @description 
	 */
	public override void bulkBefore()
	{
		getAverageSatisfactionScoresForAdvisers();
	}

	/**
	 * @description Context method overrides will be called before insertion of Object.
	 *
	 * @param so
	 */
	public override void beforeInsert(SObject so)
	{
		AW_AdviserPerformance__c ap = (AW_AdviserPerformance__c)so;
		if(uacfidToAverageSatisfactionRating.containsKey(ap.AW_UACFID__c))
		{
			ap.AW_ClientSatisfactionScore__c = uacfidToAverageSatisfactionRating.get(ap.AW_UACFID__c);
		}
		if(AW_DAL_FeatureSwitches.adviserTargetsEnabled)
		{
			AW_AdviserPerformance__c adp = (AW_AdviserPerformance__c)so;
			uacfIds.add(adp.AW_UACFID__c);

			String key = getCompositeKeyFromPerformance(adp);
			adviserTargetCompositeKeys.add(key);
		}
	}

	/**
	 * @description Context method overrides will be called after the end of trigger executions .
	 */
	public override void andFinally()
	{
		if(AW_DAL_FeatureSwitches.adviserTargetsEnabled)
		{
			uacfId2User = getUACFIDToUser(uacfIds);

			Set<Id> ownerIds = new Set<Id>();
			List<AW_AdviserTarget__c> existingAdviserTargets = AW_DAL_AdviserTarget.findByCompositeKeys(adviserTargetCompositeKeys);
			targetCompositeKey2Target = CMN_UTIL_System.convertListToSingleStringMap(existingAdviserTargets, AW_DAL_AdviserTarget.FIELD_COMPOSITE_KEY);

			// create new target records for the performances with no target
			List<AW_AdviserTarget__c> newAdviserTargets = insertAdviserTarget(Trigger.new, targetCompositeKey2Target);
			Map<String, SObject> targetCompositeKey2NewTarget = CMN_UTIL_System.convertListToSingleStringMap(newAdviserTargets, AW_DAL_AdviserTarget.FIELD_COMPOSITE_KEY);
			targetCompositeKey2Target.putAll(targetCompositeKey2NewTarget);

			for(SObject sobj : Trigger.new)
			{
				AW_AdviserPerformance__c adp = (AW_AdviserPerformance__c)sobj;
				User usr;

				if(String.isNotEmpty(adp.AW_UACFID__c) && adp.AW_WeekNumber__c != null && adp.AW_Year__c != null)
				{
					if(adp.AW_AP_CompositeID__c == null)
					{
						adp.AW_AP_CompositeID__c = AW_DAL_AdviserPerformance.constructPerformanceCompositeKey(Integer.valueOf(adp.AW_WeekNumber__c), adp.AW_Year__c, adp.AW_UACFID__c) ;
					}

					usr = (User)uacfId2User.get(CMN_UTIL_String.upperCase(adp.AW_UACFID__c));

					if(usr != null)
					{
						adp.OwnerId = usr.Id;
					}
					else
					{
						adp.addError('User for uacfId ' + adp.AW_UACFID__c + ' does not exist.');
					}

					String month = getPerformanceMonth(adp);
					String targetCompositeKey = AW_DAL_AdviserTarget.constructTargetCompositeKey(month, adp.AW_Year__c, adp.AW_UACFID__c);
					AW_AdviserTarget__c targetRecord = (AW_AdviserTarget__c)targetCompositeKey2Target.get(targetCompositeKey);

					if(targetRecord != null)
					{
						adp.AW_AdviserTarget__c = targetRecord.Id;
					}

					ownerIds.add(adp.OwnerId);
				}
				else
				{
					adp.addError(REQUIRED_FIELD_ERROR_MESSAGE);
				}

			}
		}
	}

	/**
	 * @description The method is to get the consultant code of the user
	 *
	 * @param uacfIds To store the value of uacf id
	 *
	 * @return Map
	 */
	private Map<String, SObject> getUACFIDToUser(Set<String> uacfIds)
	{
		List<User> users = AW_DAL_User.findByUACFIds(uacfIds);
		Map<String, SObject> uacfId2User = CMN_UTIL_System.convertListToSingleUpperStringMap(users, AW_DAL_AdviserPerformance.FIELD_UACF_ID);
		return uacfId2User;
	}

	/**
	 * @description The method is to get the composite key so that we can use this method in test class
	 *
	 * @param performance
	 *
	 * @return String
	 */
	@TestVisible
	private static String getCompositeKeyFromPerformance(AW_AdviserPerformance__c performance)
	{
		String targetCompositeKey;
		if(String.isNotEmpty(performance.AW_UACFID__c)
				&& performance.AW_WeekNumber__c != null && performance.AW_Year__c != null)
		{
			String month = getPerformanceMonth(performance);
			targetCompositeKey = AW_DAL_AdviserTarget.constructTargetCompositeKey(month, performance.AW_Year__c, performance.AW_UACFID__c);
		}
		return targetCompositeKey;
	}

	/**
	 * @description The method is to get the perforance so that we can use this method in test class
	 *
	 * @param performance
	 *
	 * @return String
	 */
	@TestVisible
	private static String getPerformanceMonth(AW_AdviserPerformance__c performance)
	{
		Date theWeekStart;
		Integer weekNumber = Integer.valueOf(performance.AW_WeekNumber__c);
		Integer year = Integer.valueOf(performance.AW_Year__c);

		Datetime startOfTheYear = Datetime.newInstance(year, 1, 1); // This will get start of the year
		Integer yearStartOffset = Integer.valueOf(startOfTheYear.format('u')) + 1; // This will give the weekday Monday - 1, Tuesday - 2...

		// This will calculate the last week end date
		Date lastWeekEndDate = startOfTheYear.date() - yearStartOffset + (weekNumber - 1) * 7 + 1;

		if(startOfTheYear > lastWeekEndDate)
		{
			theWeekStart = startOfTheYear.date();
		} // If last week end date is of previous year
		else
		{
			theWeekStart = lastWeekEndDate + 1;
		} // Current week start date

		String month = String.valueOf(theWeekStart.month()); // Month from Date

		return month;

	}

	/**
	 * @description The method is use to insert the Adviser target with owner consultant code
	 *
	 * @param performances List to store the SObject
	 * @param targetCompositeKey2Target Map to store the Sobject
	 *
	 * @return List
	 */
	private List<AW_AdviserTarget__c> insertAdviserTarget(List<SObject> performances, Map<String, SObject> targetCompositeKey2Target)
	{
		List<AW_AdviserTarget__c> targetToInsert = new List<AW_AdviserTarget__c>();

		for(SObject obj : performances)
		{
			AW_AdviserPerformance__c performance = (AW_AdviserPerformance__c)obj;
			if(String.isNotEmpty(performance.AW_UACFID__c)
					&& performance.AW_WeekNumber__c != null && performance.AW_Year__c != null)
			{
				String month = getPerformanceMonth(performance);
				String targetCompositeKey = AW_DAL_AdviserTarget.constructTargetCompositeKey(month, performance.AW_Year__c, performance.AW_UACFID__c);

				AW_AdviserTarget__c targetRecord = (AW_AdviserTarget__c)targetCompositeKey2Target.get(targetCompositeKey);

				if(targetRecord == null)
				{
					User owner = (User)uacfId2User.get(performance.AW_UACFID__c);
					if(owner != null)
					{
						AW_AdviserTarget__c target = new AW_AdviserTarget__c();
						target.OwnerId = owner.Id;
						target.AW_Month__c = month;
						target.AW_Year__c = performance.AW_Year__c;
						target.AW_AT_CompositeID__c = targetCompositeKey;
						targetToInsert.add(target);

						// if same month performance in transaction. Avoid inserting duplicate.
						// This record in map will be overriden by the inserted record in andFinally method
						// once records are inserted
						targetCompositeKey2Target.put(target.AW_AT_CompositeID__c, target);
					}
				}
			}
		}

		insert targetToInsert;

		return targetToInsert;
	}

	public override Boolean allowRecursion()
	{
		return false;
	}

	/**
	 * @description The method is use to retrieve average satisfaction score for advisers which are related to
	 * processed Adviser Performances before insertion.
	 * Satisfaction score is calculated from Survey responses related to Survey Invitations created
	 * by Advisers in current calendar year
	 */
	private void getAverageSatisfactionScoresForAdvisers()
	{
		if(Trigger.isBefore && Trigger.isInsert)
		{
			//Get uacfids related to adviser performances to query Survey Responses based on them
			for(SObject mObj : Trigger.new)
			{
				AW_AdviserPerformance__c ap = (AW_AdviserPerformance__c)mObj;
				if(String.isNotBlank(ap.AW_UACFID__c))
				{
					uacfIds.add(ap.AW_UACFID__c);
				}
			}

			// start date and end date to filter query on current calendar year
			Date startDate = Date.newInstance(Date.today().year(), 1, 1);
			Date endDate = Date.newInstance(Date.today().year() + 1, 1, 1);
			// Get question responses grouped by advisers uacfids to have the average score for each adviser
			List<AW_DAL_AggregateResult> aggregates = AW_DAL_SurveyQuestionResponse.getAverageSatisfactionScoresGroupedByUacfid(
					uacfIds,
					CLIENT_SATISFACTION_SURVEY_NAME,
					startDate,
					endDate);

			//Populate map uacfid to satisfaction score based on query results
			for(AW_DAL_AggregateResult aggregate : aggregates)
			{
				//TODO: literals being referenced below should be in the DAL Class doing query
				if(aggregate.get('avgSatisfactionScore') != null && aggregate.get('uacfid') != null)
				{
					String uacfid = (String)aggregate.get('uacfid');
					Decimal avgSatisfactionScoreRounded = ((Decimal)aggregate.get('avgSatisfactionScore')).setScale(2);
					uacfidToAverageSatisfactionRating.put(uacfid, avgSatisfactionScoreRounded);
				}
			}

		}
	}
}