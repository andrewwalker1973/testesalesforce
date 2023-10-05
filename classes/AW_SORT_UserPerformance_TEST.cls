/**
 * @description - Test class for  AW_SORT_LeadOwnerPerformance
 *
 * @see AW_SORT_UserPerformance
 *
 * @author Ashwini Gulbhile
 *
 * @date October 2020
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_SORT_UserPerformance_TEST
{
	private static final Integer NUMBER_USERS_TO_CREATE = 5;

	@IsTest
	private static void userSortedOnPerformance()
	{
		List<User> newUsers = new List<User>();

		for(Integer i = 1; i <= NUMBER_USERS_TO_CREATE; i++)
		{
			newUsers.add(new User());
		}

		List<AW_SORT_UserPerformance> userPerformances = new List<AW_SORT_UserPerformance> ();

		userPerformances.add (new AW_SORT_UserPerformance(15, newUsers[0]));
		userPerformances.add (new AW_SORT_UserPerformance(30, newUsers[1]));
		userPerformances.add (new AW_SORT_UserPerformance(20, newUsers[2]));
		userPerformances.add (new AW_SORT_UserPerformance(25, newUsers[3]));
		userPerformances.add (new AW_SORT_UserPerformance(40, newUsers[4]));

		Test.startTest();

		userPerformances.sort();

		Test.stopTest();

		System.assertEquals(true, userPerformances[0].performanceRating > userPerformances[1].performanceRating);
		System.assertEquals(true, userPerformances[2].performanceRating < userPerformances[1].performanceRating);
		System.assertEquals(true, userPerformances[2].performanceRating > userPerformances[3].performanceRating);

	}
}