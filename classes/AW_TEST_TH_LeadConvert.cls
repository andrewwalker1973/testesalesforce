/**
 * @description Test class for AW_TH_Lead, please note the this class is seeing all data due to the following problem
 *
 * @see AW_TH_Lead https://success.salesforce.com/issues_view?id=a1p30000000sXzfAAE
 *
 * @author Accenture vishakha.saini@accenture.com
 *
 * @date 2019, Sep 2022
 */
@SuppressWarnings('PMD.ApexUnitTestShouldNotUseSeeAllDataTrue')
@IsTest(SeeAllData=true)
private class AW_TEST_TH_LeadConvert
{
	private static final Integer INT_ONE = 1;
	private static final String BYPASS_TRIGGER_EXECUTION_APEX_CLASS = 'CMN_TRA_ObjectShareOwnerChanged';

	/**
	 * @description This method is use to test the lead conversion
	 */
	@IsTest
	private static void validateLeadConversion()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();

		String compositeKey;
		List<AW_AdviserPerformance__c> existingPerformances;
		Database.LeadConvertResult leadConvertResult;
		List<Lead> leads;

		AW_DAL_TestDataFactory.createFeatureSwitch();

		//Bypass TriggerExecution to bypass Apex Sharing code execution for new Lead due to below issue
		//cache.Org.OrgCacheException: Failed Cache.Org.get() for key 'ObjectShareConfigurations': Org cache is only supported in Data Silo tests (System Code)
		CMN_FACTORY_TriggerAction.bypass(BYPASS_TRIGGER_EXECUTION_APEX_CLASS);

		leads = AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, INT_ONE, adviser.Id);

		compositeKey = AW_DAL_AdviserPerformance.generateCompositeKey(adviser);

		existingPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});

		System.assertEquals(INT_ONE, existingPerformances.size(), 'No Performance rows created.');

		Database.LeadConvert leadConverter = new Database.LeadConvert();

		leadConverter.setLeadId(leads[0].Id);
		leadConverter.setConvertedStatus(AW_DAL_Lead.STATUS_CONVERTED);
		leadConverter.setDoNotCreateOpportunity(true);
		leadConverter.setOwnerId(adviser.Id);

		Test.startTest();

		leadConvertResult = Database.convertLead(leadConverter);

		Test.stopTest();

		List<AW_AdviserPerformance__c> updatedPerformances = AW_DAL_AdviserPerformance.findByCompositeId(new Set<String> {compositeKey});

		System.assert(leadConvertResult.isSuccess(), 'Lead was not converted successfully.');

		System.assertEquals(existingPerformances.size(), updatedPerformances.size(), 'Number of performance rows do not match');

		System.assertEquals(existingPerformances[0].AW_NumberOfNewLeads__c, updatedPerformances[0].AW_NumberOfNewLeads__c, 'New Lead count does not match.');
		System.assertEquals(INT_ONE, updatedPerformances[0].AW_NumberOfLeadConverted__c, 'Lead converted count incorrect');
		System.assertEquals(existingPerformances[0].AW_NumberOfOpenLeads__c - INT_ONE, updatedPerformances[0].AW_NumberOfOpenLeads__c,
				'Number of open leads did not change');
	}
}