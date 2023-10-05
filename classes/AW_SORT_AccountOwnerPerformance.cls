/**
 * @description - Class implements comparable inteface to sort the accounts in descending order of account owner's Performance
 *
 * @see AW_SORT_AccountOwnerPerformance_TEST
 *
 * @author Kiran Y
 *
 * @date March 2021
 */
public class AW_SORT_AccountOwnerPerformance implements Comparable
{
	public Account anAccount;
	public Decimal performanceRating;

	public AW_SORT_AccountOwnerPerformance(Decimal rating, Account anAccount)
	{
		performanceRating = rating;
		this.anAccount = anAccount;
	}

	public Integer compareTo(Object compareTo)
	{
		AW_SORT_AccountOwnerPerformance accountPerformance = (AW_SORT_AccountOwnerPerformance)compareTo;

		Integer compareValue = -1;

		if(performanceRating == accountPerformance.performanceRating)
		{
			compareValue = 0;
		}
		else if(performanceRating < accountPerformance.performanceRating)
		{
			compareValue = 1;
		}

		return compareValue;
	}
}