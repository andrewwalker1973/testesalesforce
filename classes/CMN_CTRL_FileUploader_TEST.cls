/**
 * @description Test class related to the CMN_CTRL_FileUploadCustomFileSize
 *
 * @see CMN_CTRL_FileUploader
 *
 * @author bhanumurty.rayala@liberty.co.za
 *
 * @date January 2023
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_CTRL_FileUploader_TEST
{
	/**
	 * @description test method for the getSessionId
	 *
	 * @see CMN_CTRL_FileUploader.getSessionId
	 */
	@IsTest
	private static void getSessionId()
	{
		System.runAs(AW_DAL_User.findRandomActiveAdviser())
		{
			Test.startTest();

			String sessionId = CMN_CTRL_FileUploader.getSessionId();

			Test.stopTest();

			Assert.isTrue(String.isNotBlank(sessionId), 'Session Id should not be blank');
		}
	}

	/**
	 * @description test method for the getBaseUrl
	 *
	 * @see CMN_CTRL_FileUploader.getBaseURL
	 */
	@IsTest
	private static void getBaseURL()
	{
		System.runAs(AW_DAL_User.findRandomActiveAdviser())
		{
			Test.startTest();

			String baseUrl = CMN_CTRL_FileUploader.getBaseURL();

			Test.stopTest();

			Assert.isTrue(String.isNotBlank(baseUrl), 'Base Url should not be blank');
		}
	}
}