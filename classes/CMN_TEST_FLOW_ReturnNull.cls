/**
 * @description Used to test CMN_FLOW_ReturnNull.
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
public class CMN_TEST_FLOW_ReturnNull
{
	@IsTest
	private static void returnNullTest()
	{
		System.assertEquals(null, CMN_FLOW_ReturnNull.returnNull(), 'Method did not return null as expected.');
	}
}