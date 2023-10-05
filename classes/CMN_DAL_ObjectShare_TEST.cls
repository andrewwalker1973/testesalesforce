/**
 * @description Tests the behaviour of the generic Object Share DAL (which allows query of shares dynamically)
 *
 * @see CMN_DAL_ObjectShare
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date June 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_DAL_ObjectShare_TEST
{
	/**
	 * @description Will confirm that query on the Share object for a Custom Object is executed without errors
	 *
	 * @see CMN_DAL_ObjectShare.findByParentIdAndRowCause
	 */
	@IsTest
	private static void findByParentIdAndRowCauseForCustomObject()
	{
		try
		{
			CMN_DAL_ObjectShare.findByParentIdAndRowCause(CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType), CMN_DAL_ObjectShare.ROW_CAUSE_MANUAL);
		}
		catch(Exception error)
		{
			System.assert(false, 'Query did not execute successfully. Error message: ' + error.getMessage());
		}
	}

	/**
	 * @description Will confirm that query on the Share object for an object with Special Share is executed without errors
	 *
	 * @see CMN_DAL_ObjectShare.findByParentIdAndRowCause
	 */
	@IsTest
	private static void findByParentIdAndRowCauseForObjectWithSpecialShare()
	{
		try
		{
			CMN_DAL_ObjectShare.findByParentIdAndRowCause(CMN_UTIL_Random.randomSObjectId(Account.SObjectType), CMN_DAL_ObjectShare.ROW_CAUSE_MANUAL);
		}
		catch(Exception error)
		{
			System.assert(false, 'Query did not execute successfully. Error message: ' + error.getMessage());
		}
	}

	/**
	 * @description Will confirm that query on the Share object for an object with Special Share is executed without errors
	 *
	 * @see CMN_DAL_ObjectShare.findByParentIdAndRowCause
	 */
	@IsTest
	private static void newShareObject()
	{
		CMN_DAL_ObjectShare.DTO_ObjectShareDescribe dtoShareDescribe =
				CMN_DAL_ObjectShare.getShareDescribe(CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType));

		Test.startTest();

		SObject shareObject = dtoShareDescribe.newShareObject();

		Test.stopTest();

		System.assertEquals
				(
						CMN_UTIL_String.replace(CMN_DAL_Foobar.OBJECT_NAME, CMN_UTIL_System.CUSTOM_FIELD_SUFFIX, CMN_UTIL_System.CUSTOM_OBJECT_SHARE_SUFFIX),
						CMN_UTIL_System.getTypeName(shareObject),
						'Incorrect Share Object'
				);
	}
}