/**
 * @description Test class for AW_BATCH_LeadBranchAllocation,AW_DAL_LeadBranchAllocation
 *
 * @see AW_BATCH_LeadBranchAllocation
 * @see AW_DAL_LeadBranchAllocation
 *
 * @author vishakha.saini@accenture.com, jason.van.beukering@accenture.com
 *
 * @date May 2019, August 2023
 *
 * @since ST-170, ST-158
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class AW_BATCH_LeadBranchAllocation_TEST
{
	private static final Integer NUMBER_ACCOUNTS_TO_CREATE = 3;
	private static final Integer NUMBER_LEADS_TO_CREATE = 1;

	/**
	 * @description Setup a test data
	 */
	@TestSetup
	private static void setup()
	{
		AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, NUMBER_LEADS_TO_CREATE, AW_DAL_Group.getAllocationQueue().Id);
		AW_DAL_TestDataFactory.createBusinessAccounts(NUMBER_ACCOUNTS_TO_CREATE);
	}

	/**
	 * @description Test method is to test the allocated lead with location
	 */
	@IsTest
	private static void leadAllocationWithLocation()
	{
		Test.startTest();

		Database.executeBatch(new AW_BATCH_LeadBranchAllocation());

		Test.stopTest();

		Lead foundLead = CMN_DAL_Lead.getAll().iterator().next();

		Account closestAccount = CMN_DAL_Account.getNearestAccountByShippingAddress(foundLead.Latitude, foundLead.Longitude);

		Assert.areEqual(foundLead.AW_LeadBranch__c, closestAccount.Id, 'Lead not allocated correctly');
		Assert.areEqual(foundLead.OwnerId, AW_DAL_Group.getDistributionQueue().Id, 'Lead owner is incorrect');

	}

	/**
	 * @description Test method is to test the allocated lead without location
	 */
	@IsTest
	private static void leadAllocationWithoutLocation()
	{
		Lead foundLead = CMN_DAL_Lead.getAll().iterator().next();

		foundLead.Latitude = null;
		foundLead.Longitude = null;

		update foundLead;

		Test.startTest();

		Database.executeBatch(new AW_BATCH_LeadBranchAllocation());

		Test.stopTest();

		List<Lead> updatedLeads = CMN_DAL_Lead.findAllByOwnerId(AW_DAL_Group.getUnallocatedQueue().Id);

		Assert.isFalse(updatedLeads.isEmpty(), 'No leads in the unallocated queue');
		Assert.isNull(updatedLeads.iterator().next().AW_LeadBranch__c, 'Branch should not be set.');
	}

}