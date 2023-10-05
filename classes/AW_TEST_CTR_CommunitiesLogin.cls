/**
 * @description Test class for AW_CTR_CommunitiesLogin
 * @Func area :  An apex page controller that exposes the site login functionality
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_CTR_CommunitiesLogin
{
	/**
	 * @description Method to Test the AW_CTR_CommunitiesLogin class.
	 */
	@IsTest
	private static void testCommunitiesLoginController()
	{
		AW_CTR_CommunitiesLogin controller = new AW_CTR_CommunitiesLogin();

		System.assertEquals(null, controller.forwardToAuthPage());
	}
}