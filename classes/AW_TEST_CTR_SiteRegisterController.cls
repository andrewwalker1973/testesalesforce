/**
 * @description Test Class containing tests for AW_CTR_SiteRegister
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_CTR_SiteRegisterController
{
	/**
	 * @description Test method to test the login of registered user
	 */
	@IsTest
	private static void testRegistration()
	{
		AW_CTR_SiteRegister controller = new AW_CTR_SiteRegister();
		controller.username = 'test@force.com';
		controller.email = 'test@force.com';
		controller.communityNickname = 'test';
		// registerUser will always return null when the page isn't accessed as a guest user
		System.assert(controller.registerUser() == null);

		controller.password = 'abcd1234';
		controller.confirmPassword = 'abcd123';
		System.assert(controller.registerUser() == null);
	}
}