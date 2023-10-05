/**
 * @description Test class to test the OutboundGetCodeCoverage API class
 *
 * @see CMN_API_OutboundGetCodeCoverage
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date 2020, July 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_API_OutboundGetCodeCoverage_TEST
{
	private static final String SERVICE_NAME = CMN_API_OutboundGetCodeCoverage.class.getName();

	/**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void successfulCall()
	{
		CMN_API_OutboundGetCodeCoverage handler = (CMN_API_OutboundGetCodeCoverage)CMN_API_RestBaseOutboundTestHelper.successfulCall(SERVICE_NAME, null);
		List<CMN_API_OutboundGetCodeCoverage.DTO_CoverageComparable> dtoCoverages = handler.codeCoverages;

		Assert.isFalse(dtoCoverages.isEmpty(), 'No code coverages returned');
		Assert.isTrue(dtoCoverages.iterator().next().percentCovered < dtoCoverages[dtoCoverages.size() - 1].percentCovered, 'List not sorted correctly');
		Assert.isFalse(CMN_DAL_ContentVersion.getAll().isEmpty(), 'CSV file not written');
	}
}