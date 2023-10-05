/**
 * @description Test class for AW_CTR_CommunitiesSelfRegConfirm
 * @Func area An apex page controller that takes the user to the right start page based on credentials or lack thereof
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_CTR_CommunitiesSelfRegConfirm
{
	@IsTest
	private static void testCommunitiesSelfRegConfirmController()
	{
		// Instantiate a new controller with all parameters in the page
		new AW_CTR_CommunitiesSelfRegConfirm();
	}
}