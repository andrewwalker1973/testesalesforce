/**
 * @description An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CommunitiesSelfRegConfirmControllerTest
{
	@IsTest
	private static void testCommunitiesSelfRegConfirmController()
	{
		// Instantiate a new controller with all parameters in the page
		new CommunitiesSelfRegConfirmController();
	}
}