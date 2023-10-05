/**
 * @description An apex page controller that exposes the site login functionality
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CommunitiesLoginControllerTest
{
	@IsTest
	private static void testCommunitiesLoginController()
	{
		CommunitiesLoginController controller = new CommunitiesLoginController();
		System.assertEquals(null, controller.forwardToAuthPage());
	}
}