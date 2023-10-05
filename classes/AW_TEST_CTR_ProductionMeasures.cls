/**
 * @description Test class for AW_CTR_ProductionMeasures
 *
 * @see AW_CTR_ProductionMeasures
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_CTR_ProductionMeasures
{
	/**
	 * @description Method use to setup the test data .
	 */
	@TestSetup
	private static void insertTestData()
	{
		AW_DAL_TestDataFactory.createFeatureSwitch();
	}

	@IsTest
	private static void findLatestAdviserPerformance()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		AW_AdviserPerformance__c newPerformance = AW_DAL_TestDataFactory.createAdviserPerformances(new Set<String> {adviser.AW_UACFID__c}).iterator().next();

		AW_CTR_ProductionMeasures.DTO_ProductionMeasure dtoPerformance = new AW_CTR_ProductionMeasures.DTO_ProductionMeasure();

		System.runAs(adviser)
		{
			Test.startTest();

			dtoPerformance = AW_CTR_ProductionMeasures.getLatestAdviserPerformance();

			Test.stopTest();
		}

		System.assertEquals(newPerformance.Id, dtoPerformance.productionMeasureId, 'Incorrect adviser performance record retrieved');
		//TODO: We should check that values on performance is actually what we expect
	}

}