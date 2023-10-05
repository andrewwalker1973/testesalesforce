/**
 * @description - Class implements comparable inteface and sort the User based on Performance
 *
 * @see AW_SORT_UserPerformance_TEST
 *
 * @author Ashwini Gulbhile
 *
 * @date October 2020
 */
public class AW_SORT_UserPerformance implements Comparable
{
	public User anUser;
	public Decimal performanceRating;

	public AW_SORT_UserPerformance(Decimal rating, User anUser)
	{
		performanceRating = rating;
		this.anUser = anUser;
	}

	public Integer compareTo(Object compareTo)
	{
		AW_SORT_UserPerformance userPerformanceRating = (AW_SORT_UserPerformance)compareTo;

		Integer compareValue = -1;

		if(performanceRating == userPerformanceRating.performanceRating)
		{
			compareValue = 0;
		}
		else if(performanceRating < userPerformanceRating.performanceRating)
		{
			compareValue = 1;
		}

		return compareValue;
	}

}