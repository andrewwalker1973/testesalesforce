/**
 * @description Test class for AW_CTR_ForgotPasswordController
 * @Func area :  An apex page controller that exposes the site forgot password functionality
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_CTR_ForgotPasswordController
{
	/**
	 * @description Test method to test the orgotPasswordController
	 */
	@IsTest
	private static void testForgotPasswordController()
	{
		// Instantiate a new controller with all parameters in the page
		AW_CTR_ForgotPasswordController controller = new AW_CTR_ForgotPasswordController();
		controller.username = 'test@salesforce.com';

		System.assertEquals(controller.forgotPassword(), null);
	}
}