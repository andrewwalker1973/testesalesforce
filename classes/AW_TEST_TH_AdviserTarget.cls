/**
 * @description Test class for AW_TH_AdviserTarget
 *
 * @see AW_TH_AdviserTarget
 *
 * @author prashant.k.jain@accenture.com
 *
 * @date 2019, May 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_TH_AdviserTarget
{
	private static final Integer NUMBER_OF_USERS = 1;

	/**
	 * @description To setup the test data
	 */
	@TestSetup
	private static void setUpData()
	{
		AW_DAL_TestDataFactory.createFeatureSwitch();
	}

	/**
	 * @description To test the Adviser target
	 */
	@IsTest
	private static void validateCompositeKey()
	{
		List<User> advisers = AW_DAL_User.findRandomActiveAdvisers(NUMBER_OF_USERS);
		String year = String.valueOf(Date.today().year());
		String month = String.valueOf(Date.today().month());

		AW_DAL_TestDataFactory.createAdviserTargets(advisers, month, year);

		List<AW_AdviserTarget__c> targets = AW_DAL_AdviserTarget.findByOwnerIds(advisers);

		for(AW_AdviserTarget__c target : targets)
		{
			for(User adviser : advisers)
			{
				if(target.OwnerId == adviser.Id)
				{
					System.assertEquals(month + year + CMN_UTIL_String.upperCase(adviser.AW_UACFID__c), target.AW_AT_CompositeID__c);
				}
			}
		}
	}

	/**
	 * @description To test the exception which inserting the data
	 */
	@IsTest
	private static void validateInsertFail()
	{
		List<User> advisers = AW_DAL_User.findRandomActiveAdvisers(NUMBER_OF_USERS);
		String year = String.valueOf(Date.today().year());
		String month = null;

		try
		{
			AW_DAL_TestDataFactory.createAdviserTargets(advisers, month, year);
		}
		catch(Exception e)
		{
			Boolean expectedExceptionThrown = e.getMessage().contains(AW_TH_AdviserTarget.ERROR_MESSAGE) ? true : false;
			System.assertEquals(true, expectedExceptionThrown);
		}

	}

}