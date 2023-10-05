/**
 * @description Test Class for AW_CTR_CommunitiesLanding
 * @ Func Area An apex page controller that takes the user to the right start page based on credentials or lack thereof
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_CTR_CommunitiesLanding
{

	/*
	* @description: Test method to test the community landing
	*/
	@IsTest
	private static void testCommunitiesLandingController()
	{
		// Instantiate a new controller with all parameters in the page
		AW_CTR_CommunitiesLanding controller = new AW_CTR_CommunitiesLanding();
		PageReference pageRef = controller.forwardToStartPage();

		//PageRef is either null or an empty object in test context
		if(pageRef != null)
		{
			String url = pageRef.getUrl();

			if(url != null)
			{
				System.assertEquals(true, String.isEmpty(url));
			}
		}
	}
}