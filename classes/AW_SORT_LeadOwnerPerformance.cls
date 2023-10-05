/**
 * @description - Class implements comparable inteface to sort the leads in descending order of lead owner's Performance
 *
 * @see AW_SORT_LeadOwnerPerformance_TEST
 *
 * @author Ashwini Gulbhile
 *
 * @date October 2020
 */
public class AW_SORT_LeadOwnerPerformance implements Comparable
{
	public Decimal performanceRating;
	public Lead aLead;

	public AW_SORT_LeadOwnerPerformance(Decimal rating, Lead aLead)
	{
		performanceRating = rating;
		this.aLead = aLead;
	}

	public Integer compareTo(Object compareTo)
	{
		AW_SORT_LeadOwnerPerformance leadPerformance = (AW_SORT_LeadOwnerPerformance)compareTo;

		Integer compareValue = -1;

		if(performanceRating == leadPerformance.performanceRating)
		{
			compareValue = 0;
		}
		else if(performanceRating < leadPerformance.performanceRating)
		{
			compareValue = 1;
		}

		return compareValue;
	}
}