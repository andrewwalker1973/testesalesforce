/**
 * @description Schedule Handler class for LeadBranchAllocationBatch
 *
 * @see AW_BATCH_LeadBranchAllocation
 *
 * @author Accenture
 *
 * @date 14th May'19
 */
public inherited sharing class AW_DAL_LeadBranchAllocation
{

	/**
	 * @description Will combine all the objects in all the list into a single object list
	 *
	 * @param leads
	 */
	public static void allocateBranch(List<Lead> leads)
	{
		List<Lead> leadsToUpdate = new List<Lead>();

		// Get list of business accounts
		List<Account> accounts = CMN_DAL_Account.findBusinessAccountsWithCoordinates();

		// match the lead with nearest account based on Geo location
		leadsToUpdate = matchLeadsWithAccounts(leads, accounts);

		// TODO: Allow partial update until exception handling framework is in place
		CMN_DAL_SObjectDomain.updateDBObjects(leadsToUpdate, false);
	}

	/**
	 * @description Private method to match the leads with accounts.
	 *
	 * @param leads
	 * @param accounts
	 *
	 * @return leadsToUpdate
	 */
	private static List<Lead> matchLeadsWithAccounts(List<Lead> leads, List<Account> accounts)
	{
		Account nearestBranch;
		Double accDistance;
		List<Lead> leadsToUpdate = new List<Lead>();
		Id distributionQueueId = AW_DAL_Group.getDistributionQueue().Id;
		Id unallocatedQueueId = AW_DAL_Group.getUnallocatedQueue().Id;

		for(Lead unallocatedLead : leads)
		{
			Double minDistance;

			Location leadLocation = Location.newInstance(unallocatedLead.Latitude, unallocatedLead.Longitude);

			if(leadLocation.getLatitude() == null && leadLocation.getLongitude() == null)
			{
				unallocatedLead.OwnerId = unallocatedQueueId;
				leadsToUpdate.add(unallocatedLead);
			}
			else
			{

				// TODO: Optimise processing here
				for(Account acc : accounts)
				{
					Location accLocation = Location.newInstance(acc.ShippingLatitude, acc.ShippingLongitude);
					if(accLocation.getLatitude() != null && accLocation.getLongitude() != null)
					{
						accDistance = Location.getDistance(leadLocation, accLocation, 'mi');

						if((minDistance == null) || (accDistance < minDistance))
						{
							minDistance = accDistance;
							nearestBranch = acc;
						}
					}
				}

				unallocatedLead.AW_LeadBranch__c = nearestBranch.Id;
				unallocatedLead.OwnerId = distributionQueueId;
				leadsToUpdate.add(unallocatedLead);
			}
		}

		return leadsToUpdate;

	}
}