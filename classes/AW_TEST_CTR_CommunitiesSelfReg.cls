/**
 * @description Test class for AW_CTR_CommunitiesSelfReg
 * @story ST-3455
 * @Func area An apex page controller that supports self registration of users in communities that allow self registration
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_CTR_CommunitiesSelfReg
{
	/*
	Description: Test Method to test the class the varriable
	*/
	@IsTest
	private static void testCommunitiesSelfRegController()
	{
		AW_CTR_CommunitiesSelfReg controller = new AW_CTR_CommunitiesSelfReg();

		controller.firstName = 'FirstName';
		controller.lastName = 'LastName';
		controller.email = 'test@force.com';
		controller.communityNickname = 'test';

		// registerUser will always return null when the page isn't accessed as a guest user
		System.assert(controller.registerUser() == null);

		controller.password = 'abcd1234';
		controller.confirmPassword = 'abcd123';
		System.assert(controller.registerUser() == null);
	}
}