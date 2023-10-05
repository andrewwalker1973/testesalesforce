/**
 * @description Test Class for AW_TH_AdviserPerformance
 *
 * @see AW_TH_AdviserPerformance
 *
 * @author prashant.k.jain@accenture.com
 *
 * @date 2019, May 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class AW_TEST_TH_AdviserPerformance
{
	private static final Decimal AVERAGE_SATISFACTION_SCORE = 3.33;
	private static final Integer NUM_OF_ADVISER_TO_RETRIEVE = 3;
	private static final Integer UACFID_LEN = 7;
	private static final String ASSERT_ERROR_MESSAGE_SATISFACTION_SCORE_NOT_POPULATED_CORRECTLY = 'Client satisfaction score in not populated correctly';

	/**
	 * @description To setup the test data
	 */
	@TestSetup
	private static void setUpData()
	{
		AW_DAL_TestDataFactory.createFeatureSwitch();
	}

	/**
	 * @description Test method to test the previous owner of the performance
	 */
	@IsTest
	private static void validateOwnerAndPreviousPerformance()
	{
		List<User> advisers = AW_DAL_User.findRandomActiveAdvisers(NUM_OF_ADVISER_TO_RETRIEVE);
		Set<String> uacfIds = CMN_UTIL_System.extractSetValues(advisers, AW_DAL_AdviserPerformance.FIELD_UACF_ID);

		// Insert adviser performance record
		AW_DAL_TestDataFactory.createAdviserPerformances(uacfIds);

		List<AW_AdviserPerformance__c> performances = AW_DAL_AdviserPerformance.findByUACFIDs(uacfIds);

		for(AW_AdviserPerformance__c adp : performances)
		{
			for(User usr : advisers)
			{
				if(adp.AW_UACFID__c == usr.AW_UACFID__c)
				{
					System.assertEquals(usr.Id, adp.OwnerId);
				}
			}
		} // check owner of the records*/
	}

	@IsTest
	private static void validateTargetAssociation()
	{
		List<User> advisers = AW_DAL_User.findRandomActiveAdvisers(NUM_OF_ADVISER_TO_RETRIEVE);
		Set<String> uacfIds = CMN_UTIL_System.extractSetValues(advisers, AW_DAL_AdviserPerformance.FIELD_UACF_ID);

		// Insert adviser performance record
		List<AW_AdviserPerformance__c> performances = AW_DAL_TestDataFactory.createAdviserPerformances(uacfIds);
		Set<Id> performanceIds = CMN_UTIL_System.extractListIds(performances);
		performances = AW_DAL_AdviserPerformance.findById(performanceIds);

		Set<String> targetCompositeKeys = getAdviserTargetCompositeKey(performances);

		List<AW_AdviserTarget__c> adviserTargets = AW_DAL_AdviserTarget.findByCompositeKeys(targetCompositeKeys);

		for(AW_AdviserPerformance__c performance : performances)
		{
			String month = AW_TH_AdviserPerformance.getPerformanceMonth(performance);
			String targetCompositeKey = AW_DAL_AdviserTarget.constructTargetCompositeKey(month, performance.AW_Year__c, performance.AW_UACFID__c);

			for(AW_AdviserTarget__c target : adviserTargets)
			{
				if(targetCompositeKey == target.AW_AT_CompositeID__c)
				{
					System.assertEquals(target.Id, performance.AW_AdviserTarget__c);
				}
			}
		}

	}
	@IsTest
	private static void adviserNotFoundValidation()
	{
		String uacfId = String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger(UACFID_LEN));

		try
		{
			AW_DAL_TestDataFactory.createAdviserPerformances(new Set<String> {uacfId});
		}
		catch(Exception e)
		{
			Boolean expectedExceptionThrown = e.getMessage().contains('User for uacfId ' + uacfId + ' does not exist.') ? true : false;
			System.assertEquals(true, expectedExceptionThrown);
		}

	}

	/**
	 * @description Test method to test field validation of performance
	 */
	@IsTest
	private static void requiredFieldValidation()
	{
		AW_AdviserPerformance__c adp = new AW_AdviserPerformance__c();

		try
		{
			insert adp;
		}
		catch(Exception e)
		{
			Boolean expectedExceptionThrown = e.getMessage().contains(AW_TH_AdviserPerformance.REQUIRED_FIELD_ERROR_MESSAGE) ? true : false;
			System.assertEquals(true, expectedExceptionThrown);
		}

	}

	/**
	 * @description This method to use to get the Adviser target composite key
	 *
	 * @param performances List of Adviser performance
	 *
	 * @return Set<String>
	 */
	private static Set<String> getAdviserTargetCompositeKey(List<AW_AdviserPerformance__c> performances)
	{

		Set<String> targetCompositeKeys = new Set<String>();

		for(AW_AdviserPerformance__c performance : performances)
		{
			String compositeKey = AW_TH_AdviserPerformance.getCompositeKeyFromPerformance(performance);
			targetCompositeKeys.add(compositeKey);
		}

		return targetCompositeKeys;
	}

	/**
	 * @description Test method to test average satisfaction score calculation
	 */
	@IsTest
	static void validateSatisfactionScore()
	{
		List<User> advisers = AW_DAL_User.findRandomActiveAdvisers(NUM_OF_ADVISER_TO_RETRIEVE);
		Set<String> uacfIds = CMN_UTIL_System.extractSetValues(advisers, AW_DAL_AdviserPerformance.FIELD_UACF_ID);
		SurveyQuestionResponsesAggregateMock fakeData = new SurveyQuestionResponsesAggregateMock();
		//TODO Priority 1: literals being referenced below should be in the DAL Class doing query
		for(String uacfid : uacfIds)
		{
			fakeData.add(new AW_DAL_AggregateResult()
					.put('uacfid', uacfid)
					.put('avgSatisfactionScore', AVERAGE_SATISFACTION_SCORE));
		}
		AW_DAL_AggregateResult.setMock(fakeData);

		Test.startTest();
		// Insert adviser performance record
		AW_DAL_TestDataFactory.createAdviserPerformances(uacfIds);
		Test.stopTest();

		List<AW_AdviserPerformance__c> performances = AW_DAL_AdviserPerformance.findByUACFIDs(uacfIds);

		for(AW_AdviserPerformance__c adp : performances)
		{
			System.assertEquals(adp.AW_ClientSatisfactionScore__c, AVERAGE_SATISFACTION_SCORE, ASSERT_ERROR_MESSAGE_SATISFACTION_SCORE_NOT_POPULATED_CORRECTLY);
		}
	}

	/**
	 * @description Test scenario when there is no Survey Responses data for Advisers
	 */
	@IsTest
	static void validateSatisfactionScoreWithNoSurveyResponsesData()
	{
		List<User> advisers = AW_DAL_User.findRandomActiveAdvisers(NUM_OF_ADVISER_TO_RETRIEVE);
		Set<String> uacfIds = CMN_UTIL_System.extractSetValues(advisers, AW_DAL_AdviserPerformance.FIELD_UACF_ID);
		SurveyQuestionResponsesAggregateMock fakeData = new SurveyQuestionResponsesAggregateMock();
		AW_DAL_AggregateResult.setMock(fakeData);

		Test.startTest();
		// Insert adviser performance record
		AW_DAL_TestDataFactory.createAdviserPerformances(uacfIds);
		Test.stopTest();

		List<AW_AdviserPerformance__c> performances = AW_DAL_AdviserPerformance.findByUACFIDs(uacfIds);

		for(AW_AdviserPerformance__c adp : performances)
		{
			System.assertEquals(adp.AW_ClientSatisfactionScore__c, null, ASSERT_ERROR_MESSAGE_SATISFACTION_SCORE_NOT_POPULATED_CORRECTLY);
		}
	}

	/**
	 * @description Class used to mock AggregateResult for SurveyQuestionResponse query
	 */
	class SurveyQuestionResponsesAggregateMock extends AW_DAL_AggregateResult.Service
	{
		final List<AW_DAL_AggregateResult> aggregates = new List<AW_DAL_AggregateResult>();
		/**
		 * @description Method to add an aggregate result to the list
		 *
		 * @param aggregate Aggregate result to add to the list
		 *
		 * @return Current object i.e. this
		 */
		public SurveyQuestionResponsesAggregateMock add(AW_DAL_AggregateResult aggregate)
		{
			aggregates.add(aggregate);
			return this;
		}
		public override List<AW_DAL_AggregateResult> convert(List<AggregateResult> results)
		{
			return aggregates;
		}
	}
}