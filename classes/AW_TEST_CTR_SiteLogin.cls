/**
 * @description Test class for AW_CTR_SiteLogin
 * @Func area An apex page controller that exposes the site login functionality
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_CTR_SiteLogin
{
	/**
	 * @description test method to test the login controller of community site
	 */
	@IsTest
	private static void testSiteLoginController()
	{
		// Instantiate a new controller with all parameters in the page
		AW_CTR_SiteLogin controller = new AW_CTR_SiteLogin ();

		controller.username = 'test@salesforce.com';
		controller.password = '123456';

		System.assertEquals(controller.login(), null);
	}
}