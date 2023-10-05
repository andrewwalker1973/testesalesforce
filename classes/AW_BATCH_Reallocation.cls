/**
 * @description - This class has common code for Account and Lead Reallocation
 *
 * @see AW_BATCH_AccountReallocation
 * @see AW_BATCH_AccountReallocation_TEST
 * @see AW_BATCH_LeadReallocation
 * @see AW_BATCH_LeadReallocation_TEST
 *
 * @author prashant.k.jain@accenture.com
 *
 * @date July 2021
 */
public inherited sharing class AW_BATCH_Reallocation
{
	/**
	 * @description Method to find the high performance advisers and assign them to Lead / Account owner with in the same branch / sub branch
	 *
	 * @param records Lead / Account records as parameters
	 */
	//TODO: Extremely complicate method. Can look to simplify. Possibly Q-ASSIGN can be used.
	public static void process(List<SObject> records)
	{
		String objectName = records instanceof List<Account> ? AW_DAL_Account.OBJECT_NAME : AW_DAL_Lead.OBJECT_NAME;

		//Initializing variables based on Custom metadata settings
		String customMetadataName = (objectName == AW_DAL_Account.OBJECT_NAME) ? AW_DAL_ReallocationSetting.DEVELOPER_NAME_ACCOUNT_REALLOCATION : AW_DAL_ReallocationSetting.DEVELOPER_NAME_LEAD_REALLOCATION;
		AW_ReallocationSetting__mdt reallocationSetting = AW_DAL_ReallocationSetting.getInstance(customMetadataName);
		Decimal averagePerformanceThreshold = reallocationSetting.AW_AveragePerformanceThreshold__c;
		Decimal weightForLeadConversionRate = reallocationSetting.AW_WeightForLeadConversionRate__c;
		Decimal weightForOpportunityWinRate = reallocationSetting.AW_WeightForOpportunityWinRate__c;
		String branchIdFieldAPIName = reallocationSetting.AW_BranchIdFieldAPIName__c;
		String isReallocatedFieldAPIName = AW_DAL_ReallocationSetting.FIELD_IS_REALLOCATED;
		String ownerUACFIdFieldAPIName = reallocationSetting.AW_OwnerUACFIdFieldAPIName__c;

		Integer indexAvailableAdviser = 0;
		Integer indexLeadManager = 0;
		List<SObject> recordsToBeReallocated = new List<SObject>();
		List<SObject> recordsToUpdate = new List<SObject>();
		Map<Id, List<SObject>> recordsToBeReallocatedByBranchId;
		Map<Id, List<User>> advisersByBranchId; //map of record Id and List of related advisers
		Map<Id, User> advisersToUpdate = new Map<Id, User>();
		Map<String, Decimal> adviserPerformanceByUACFId = new Map<String, Decimal>();
		Set<Id> recordIds = new Set<Id>();
		Set<String> uacfIds = new Set<String>(); //Store the uacfIds number of Owners and all advisers from related records

		List<User> shuffledLeadManagers = AW_DAL_User.findActiveByProfileName(AW_DAL_Profile.PROFILE_LIBERTY_LEAD_MANAGER);
		CMN_UTIL_System.shuffleList(shuffledLeadManagers); //Shuffle list of Lead managers to randomize assignment

		for(SObject currentRecord : records)
		{
			Boolean isReallocated = (Boolean)currentRecord.get(isReallocatedFieldAPIName);

			Integer numberOfOpenActivities = currentRecord.getSObjects(CMN_DAL_SObjectDomain.RELATED_OPEN_ACTIVITIES)?.size();

			if(numberOfOpenActivities == null || numberOfOpenActivities == 0)
				{
					//If previously reallocated, then assign to Lead Manager
					if(isReallocated == true)
					{
						if(shuffledLeadManagers.size() > 0)
						{
							//Reallocate record to Lead Manager if it was reallocated previously to an adviser and still has not been actioned
							currentRecord.put(CMN_DAL_SObjectDomain.FIELD_OWNER_ID, shuffledLeadManagers.get(indexLeadManager).Id);
							recordsToUpdate.add(currentRecord);

							indexLeadManager = shuffledLeadManagers.size() == indexLeadManager + 1 ? 0 : indexLeadManager + 1;
						}
					}
					else //If previously not reallocated, then reallocate
					{
						String recordOwnerUACFId = (String)currentRecord.get(ownerUACFIdFieldAPIName);
						if(String.isNotBlank(recordOwnerUACFId))
						{
							recordIds.add(currentRecord.Id);
							uacfIds.add(recordOwnerUACFId.toUpperCase());
							recordsToBeReallocated.add(currentRecord);
						}
					}
				}
			}

		if(recordsToBeReallocated.size() > 0)
		{
			advisersByBranchId = (objectName == AW_DAL_Account.OBJECT_NAME) ? AW_DAL_Adviser.getAdvisersByBranchId(recordIds) : AW_DAL_LeadAssignment.prepareData(recordsToBeReallocated); //Map of Advisers using Branch Id as key
			recordsToBeReallocatedByBranchId = CMN_UTIL_System.convertListToMap(recordsToBeReallocated, branchIdFieldAPIName); //Map of records to be reallocated using Branch Id as key

			if(advisersByBranchId?.size() > 0)
			{
				//Add all adviser UACFID in uacfIds set
				List<User> listAdvisers = CMN_UTIL_System.extractListFromMap(advisersByBranchId);
				for(User user : listAdvisers)
				{
					uacfIds.add(user.AW_UACFID__c.toUpperCase());
				}

				populateAdviserPerformance(uacfIds, adviserPerformanceByUACFId, weightForLeadConversionRate, weightForOpportunityWinRate); //Populate adviser Performance map using UACFId as key

				for(Id branchId : advisersByBranchId.keySet()) //Loop through branches
				{
					//Get advisers sorted by performance rating for the current branch
					List<AW_SORT_UserPerformance> adviserSortedBasedOnPerformance = getAdviserSortedBasedOnPerformance(advisersByBranchId.get(branchId), adviserPerformanceByUACFId, averagePerformanceThreshold);
					indexAvailableAdviser = 0;

					//Loop through the records to be reallocated for the current branch
					for(SObject currentRecord : recordsToBeReallocatedByBranchId.get(branchId))
					{
						User newOwner;
						if(adviserSortedBasedOnPerformance?.size() > 0)
						{
							Integer loopCounter = 0; //Counter to make sure the adviserSortedBasedOnPerformance List is not traversed more than once
							Id oldOwnerId = (Id)currentRecord.get(CMN_DAL_SObjectDomain.FIELD_OWNER_ID);

							//Loop until a new owner is not found or adviserSortedBasedOnPerformance list is traversed fully
							while(true)
							{
								AW_SORT_UserPerformance sortedAdviserRecord = adviserSortedBasedOnPerformance.get(indexAvailableAdviser);
								indexAvailableAdviser = adviserSortedBasedOnPerformance.size() == indexAvailableAdviser + 1 ? 0 : indexAvailableAdviser + 1;
								newOwner = sortedAdviserRecord.anUser;

								//If the old owner is same as the new owner then go to next otherwise proceed
								if(oldOwnerId == newOwner.Id)
								{
									loopCounter++;
								}
								else
								{
									break;
								}

								//If loopCounter is equal to List size and a new owner is not found then nullify newOwnerId and break loop
								if(loopCounter == adviserSortedBasedOnPerformance.size())
								{
									newOwner = null;
									break;
								}
							}
						}

						//If new agent was not found, then reallocate to a lead manager instead
						if(newOwner == null && shuffledLeadManagers.size() > 0)
						{
							newOwner = shuffledLeadManagers.get(indexLeadManager);
							indexLeadManager = shuffledLeadManagers.size() == indexLeadManager + 1 ? 0 : indexLeadManager + 1;
						}

						//If new owner was found, then reallocate the record
						if(newOwner != null)
						{
							currentRecord.put(CMN_DAL_SObjectDomain.FIELD_OWNER_ID, newOwner.Id);
							currentRecord.put(isReallocatedFieldAPIName, true);

							recordsToUpdate.add(currentRecord);

							//For Leads, update fields on the user record
							if(objectName == AW_DAL_Lead.OBJECT_NAME)
							{
								User previouslyUpdatedAdviser = advisersToUpdate.get(newOwner.Id);
								if(previouslyUpdatedAdviser == null)
								{
									//If not there, add to the map to keep a unique list of advisers being updated
									advisersToUpdate.put(newOwner.Id, newOwner);
								}
								else
								{
									//If already present in map, get it with fields updated in previous loops.
									newOwner = previouslyUpdatedAdviser;
								}
								newOwner.AW_NumberOfLeadAllocation__c = newOwner.AW_NumberOfLeadAllocation__c == null ? 1 : newOwner.AW_NumberOfLeadAllocation__c + 1;
								newOwner.AW_LastLeadAllocationDate__c = System.now();
							}
						}
					}
				}
			}
		}

		recordsToUpdate.addAll(advisersToUpdate.values());
		CMN_DAL_SObjectDomain.updateDBObjects(recordsToUpdate);
	}

	/**
	 * @description Populate current Owner's and all adviser's performance records in maps
	 *
	 * @param uacfIds Set of UACF Ids
	 * @param adviserPerformanceByUACFId Adviser Performance by UACF Id map to be populated
	 * @param weightForLeadConversionRate Weight for Lead Conversion Rate
	 * @param weightForOpportunityWinRate Weight for Opportunity Win Rate
	 */
	@TestVisible
	private static void populateAdviserPerformance(Set<String> uacfIds, Map<String, Decimal> adviserPerformanceByUACFId, Decimal weightForLeadConversionRate, Decimal weightForOpportunityWinRate)
	{
		Decimal leadPerformance;
		Decimal opportunityPerformance;

		if(uacfIds.size() > 0)
		{
			for(AW_AdviserPerformance__c objAdviserPerformance : AW_DAL_AdviserPerformance.findByUACFIDs(uacfIds))
			{
				Decimal userAveragePerformance = 0;

				if(objAdviserPerformance.AW_AdviserTarget__c != null)
				{
					leadPerformance = objAdviserPerformance.AW_AdviserTarget__r.AW_ActualLeadConversionRate__c != null ? objAdviserPerformance.AW_AdviserTarget__r.AW_ActualLeadConversionRate__c : 0;
					opportunityPerformance = objAdviserPerformance.AW_AdviserTarget__r.AW_ActualOpportunityWinRate__c != null ? objAdviserPerformance.AW_AdviserTarget__r.AW_ActualOpportunityWinRate__c : 0;
					userAveragePerformance = ((leadPerformance * weightForLeadConversionRate) + (opportunityPerformance * weightForOpportunityWinRate)) / 2;
				}

				adviserPerformanceByUACFId.put(objAdviserPerformance.AW_UACFID__c.toUpperCase(), userAveragePerformance);
			}
		}
	}

	/**
	 * @description adviserSortedBasedOnPerformance-comparable class to get the sorted advisers based on performance in descending order
	 *
	 * @param usersForCurrentAccount Users in current Branch
	 * @param adviserPerformanceByUACFId Lead Conversion Rate by UACF Id map
	 * @param averagePerformanceThreshold Average Performance Threshold
	 *
	 * @return adviserSortedBasedOnPerformance
	 */
	private static List<AW_SORT_UserPerformance> getAdviserSortedBasedOnPerformance(List<User> usersForCurrentAccount, Map<String, Decimal> adviserPerformanceByUACFId, Decimal averagePerformanceThreshold)
	{
		List<AW_SORT_UserPerformance> adviserSortedBasedOnPerformance = new List<AW_SORT_UserPerformance>();
		for(User userRecord : usersForCurrentAccount)
		{
			Decimal userAveragePerformance = adviserPerformanceByUACFId.get(userRecord.AW_UACFID__c.toUpperCase());
			if(userAveragePerformance >= averagePerformanceThreshold)
			{
				adviserSortedBasedOnPerformance.add (new AW_SORT_UserPerformance(userAveragePerformance, userRecord));
			}
		}
		adviserSortedBasedOnPerformance.sort();
		return adviserSortedBasedOnPerformance;
	}
}