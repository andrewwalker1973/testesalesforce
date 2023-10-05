/**
 * @description - Test class for  AW_SORT_LeadOwnerPerformance
 *
 * @see AW_SORT_LeadOwnerPerformance
 *
 * @author Ashwini Gulbhile
 *
 * @date October 2020
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_SORT_LeadOwnerPerformance_TEST
{
	private static final Integer NUMBER_LEADS_TO_CREATE = 5;

	@IsTest
	private static void leadSortedOnPerformance()
	{
		List<Lead> newLeads = new List<Lead>();

		for(Integer i = 1; i <= NUMBER_LEADS_TO_CREATE; i++)
		{
			newLeads.add(new Lead());
		}

		List<AW_SORT_LeadOwnerPerformance> leadPerformances = new List<AW_SORT_LeadOwnerPerformance> ();

		leadPerformances.add (new AW_SORT_LeadOwnerPerformance(15, newLeads[0]));
		leadPerformances.add (new AW_SORT_LeadOwnerPerformance(30, newLeads[1]));
		leadPerformances.add (new AW_SORT_LeadOwnerPerformance(20, newLeads[2]));
		leadPerformances.add (new AW_SORT_LeadOwnerPerformance(25, newLeads[3]));
		leadPerformances.add (new AW_SORT_LeadOwnerPerformance(40, newLeads[4]));

		Test.startTest();

		leadPerformances.sort();

		Test.stopTest();

		System.assertEquals(true, leadPerformances[0].performanceRating > leadPerformances[1].performanceRating);
		System.assertEquals(true, leadPerformances[2].performanceRating < leadPerformances[1].performanceRating);
		System.assertEquals(true, leadPerformances[2].performanceRating > leadPerformances[3].performanceRating);

	}

}