/**
 * @description - Test class for  AW_SORT_AccountOwnerPerformance
 *
 * @see AW_SORT_AccountOwnerPerformance
 *
 * @author Kiran
 *
 * @date March 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_SORT_AccountOwnerPerformance_TEST
{
	private static final Integer NUMBER_ACCOUNTS_TO_CREATE = 5;

	//TODO: add comment that this method does
	@IsTest
	private static void accountsSortedOnPerformance()
	{
		List<Account> newAccounts = new List<Account>();

		for(Integer i = 0; i < NUMBER_ACCOUNTS_TO_CREATE; i++)
		{
			newAccounts.add(new Account());
		}

		List<AW_SORT_AccountOwnerPerformance> accountPerformance = new List<AW_SORT_AccountOwnerPerformance> ();

		accountPerformance.add (new AW_SORT_AccountOwnerPerformance(15, newAccounts[0]));
		accountPerformance.add (new AW_SORT_AccountOwnerPerformance(30, newAccounts[1]));
		accountPerformance.add (new AW_SORT_AccountOwnerPerformance(20, newAccounts[2]));
		accountPerformance.add (new AW_SORT_AccountOwnerPerformance(25, newAccounts[3]));
		accountPerformance.add (new AW_SORT_AccountOwnerPerformance(40, newAccounts[4]));

		Test.startTest();

		accountPerformance.sort();

		Test.stopTest();

		System.assertEquals(accountPerformance[0].performanceRating > accountPerformance[1].performanceRating, true);
		System.assertEquals(accountPerformance[2].performanceRating < accountPerformance[1].performanceRating, true);
		System.assertEquals(accountPerformance[2].performanceRating > accountPerformance[3].performanceRating, true);

	}

}