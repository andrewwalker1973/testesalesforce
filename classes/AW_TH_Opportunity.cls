/**
 * @description Trigger handler for the Opportunity Trigger
 *
 * @see AW_TEST_TH_Opportunity @story ST-2226
 * @see AW_TRG_Opportunity
 *
 * @author Accenture
 *
 * @date July 2019
 */
public inherited sharing class AW_TH_Opportunity extends AW_TH_BaseLinkToMaster
{
	private List<Opportunity> newOpportunities = new List<Opportunity>();
	private List<Opportunity> updatedOpportunities = new List<Opportunity>();
	private Map<Id, AggregateResult> countOfNewOpportuntiesByOwnerMap = new Map<Id, AggregateResult>();
	private Map<Id, AggregateResult> countOfOpenOpportunitiesByOwnerMap = new Map<Id, AggregateResult>();
	private Map<Id, AggregateResult> countOfWonOpportuntiesByOwnerMap = new Map<Id, AggregateResult>();
	private Map<String, AW_AdviserPerformance__c> upsertPerformancesMap = new Map<String, AW_AdviserPerformance__c>();
	private Map<String, SObject> foundPerformancesMap = new Map<String, SObject>();
	private Set<Id> lostOpportunties = new Set<Id>();
	private Set<Id> ownerIds = new Set<Id>();
	private Set<Id> wonOpportunities = new Set<Id>();
	private Set<String> performanceCompositeKeys = new Set<String>();
	private User currentUser = new User();

	public override void bulkBefore()
	{
		super.bulkBefore();
		if(Trigger.isInsert)
		{
			currentUser = AW_DAL_User.getCurrentUser();
		}
	}

	/**
	 * @description Context method overrides will be called before insertion of Object.
	 *
	 * @param so To store the Opporunity
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);
		setOpportunityOwner((Opportunity)so);
	}

	/**
	 * @description Context method overrides will be called after insertion of Object.
	 *
	 * @param so To store the Opporunity
	 */
	public override void afterInsert(SObject so)
	{
		if(AW_DAL_FeatureSwitches.adviserTargetsEnabled)
		{
			Opportunity newOpportunity = (Opportunity)so;

			// use created date for new opportunity as it can be populated manually in data load
			String compositeKey = AW_DAL_AdviserPerformance.getCompositeKey(newOpportunity, CMN_DAL_SObjectDomain.FIELD_CREATED_DATE, AW_DAL_Opportunity.FIELD_ADVISER_UACFID);

			if(String.isNotBlank(compositeKey))
			{
				performanceCompositeKeys.add(compositeKey);
			}

			ownerIds.add(newOpportunity.OwnerId);
			newOpportunities.add(newOpportunity);

			// If opportunity inserted is already closed won
			if(AW_DAL_Opportunity.OPPORTUNITY_STAGE_CLOSED_WON.equalsIgnoreCase(newOpportunity.StageName))
			{
				wonOpportunities.add(newOpportunity.Id);
			}
		}

	}

	/**
	 * @description Context method overrides will be called after updation of Object.
	 *
	 * @param oldSo To store the old opportunity
	 * @param so To store the new opportunity
	 */
	public override void afterUpdate(SObject oldSo, SObject so)
	{
		if(AW_DAL_FeatureSwitches.adviserTargetsEnabled)
		{

			Opportunity newOpportunity = (Opportunity)so;
			Opportunity oldOpportunity = (Opportunity)oldSo;

			// check for stage changed to Won or from won to other
			if(newOpportunity.StageName != oldOpportunity.StageName
					&& (newOpportunity.StageName == AW_DAL_Opportunity.OPPORTUNITY_STAGE_CLOSED_WON
					|| oldOpportunity.StageName == AW_DAL_Opportunity.OPPORTUNITY_STAGE_CLOSED_WON))
			{
				updatedOpportunities.add(newOpportunity);

				String compositeKey = AW_DAL_AdviserPerformance.getCompositeKey(newOpportunity, CMN_DAL_SObjectDomain.FIELD_LAST_MODIFIED_DATE, AW_DAL_Opportunity.FIELD_ADVISER_UACFID);

				if(String.isNotBlank(compositeKey))
				{
					performanceCompositeKeys.add(compositeKey);
				}

				ownerIds.add(newOpportunity.OwnerId);

				// This is the scenario where opportunity is moved to won stage
				if(AW_DAL_Opportunity.OPPORTUNITY_STAGE_CLOSED_WON.equalsIgnoreCase(newOpportunity.StageName))
				{
					wonOpportunities.add(newOpportunity.Id);
				}
				// This is the scenario where opportunity is moved from Won to other stage
				else if(AW_DAL_Opportunity.OPPORTUNITY_STAGE_CLOSED_WON.equalsIgnoreCase(oldOpportunity.StageName))
				{
					lostOpportunties.add(newOpportunity.Id);
				}
			}

			if(newOpportunity.OwnerId != oldOpportunity.OwnerId)
			{
				String compositeKeyNew = AW_DAL_AdviserPerformance.getCompositeKey(newOpportunity, CMN_DAL_SObjectDomain.FIELD_LAST_MODIFIED_DATE, AW_DAL_Opportunity.FIELD_ADVISER_UACFID);

				if(String.isNotBlank(compositeKeyNew))
				{
					performanceCompositeKeys.add(compositeKeyNew);
				}

				String compositeKeyOld = AW_DAL_AdviserPerformance.getCompositeKey(oldOpportunity, CMN_DAL_SObjectDomain.FIELD_LAST_MODIFIED_DATE, AW_DAL_Opportunity.FIELD_ADVISER_UACFID);

				if(String.isNotBlank(compositeKeyOld))
				{
					performanceCompositeKeys.add(compositeKeyOld);
				}

				// update new owner performance record
				updatedOpportunities.add(newOpportunity);

				// update old owner performance record
				updatedOpportunities.add(oldOpportunity);

				ownerIds.add(newOpportunity.OwnerId);
				ownerIds.add(oldOpportunity.OwnerId);
			}
		}
	}

	/**
	 * @description Context method overrides will be called after deletion of Object.
	 *
	 * @param so To store the deleted opportunity
	 */
	public override void afterDelete(SObject so)
	{
		if(AW_DAL_FeatureSwitches.adviserTargetsEnabled)
		{
			Opportunity deletedOpportunity = (Opportunity)so;

			String compositeKey = AW_DAL_AdviserPerformance.getCompositeKey(deletedOpportunity, CMN_DAL_SObjectDomain.FIELD_LAST_MODIFIED_DATE, AW_DAL_Opportunity.FIELD_ADVISER_UACFID);

			if(String.isNotBlank(compositeKey))
			{
				performanceCompositeKeys.add(compositeKey);
			}

			ownerIds.add(deletedOpportunity.OwnerId);
			updatedOpportunities.add(deletedOpportunity);
		}
	}
	/**
	 * @description Context method overrides will be called after undelete of Object.
	 *
	 * @param so To store the undeleted opportunity
	 */
	public override void afterUndelete(SObject so)
	{
		if(AW_DAL_FeatureSwitches.adviserTargetsEnabled)
		{
			Opportunity unDeletedOpportunity = (Opportunity)so;

			String compositeKey = AW_DAL_AdviserPerformance.getCompositeKey(unDeletedOpportunity, CMN_DAL_SObjectDomain.FIELD_LAST_MODIFIED_DATE, AW_DAL_Opportunity.FIELD_ADVISER_UACFID);

			if(String.isNotBlank(compositeKey))
			{
				performanceCompositeKeys.add(compositeKey);
			}

			ownerIds.add(unDeletedOpportunity.OwnerId);
			updatedOpportunities.add(unDeletedOpportunity);
		}
	}

	/**
	 * @description Context method overrides will be called after the end of trigger executions .
	 */
	public override void andFinally()
	{
		if(AW_DAL_FeatureSwitches.adviserTargetsEnabled)
		{
			if(!performanceCompositeKeys.isEmpty() || !ownerIds.isEmpty())
			{
				foundPerformancesMap = CMN_UTIL_System.convertListToSingleStringMap(AW_DAL_AdviserPerformance.findByCompositeId(performanceCompositeKeys), AW_DAL_AdviserPerformance.FIELD_COMPOSITE_KEY);
				countOfOpenOpportunitiesByOwnerMap = AW_DAL_Opportunity.findCountOpenOpportunitiesByOwnerIds(ownerIds);
				countOfNewOpportuntiesByOwnerMap = AW_DAL_Opportunity.findCountWeeklyNewOpportunitiesByOwnerIds(performanceCompositeKeys);
				countOfWonOpportuntiesByOwnerMap = AW_DAL_Opportunity.findCountWeeklyWonOpportunitiesByOwnerId(performanceCompositeKeys);
			}

			if(!newOpportunities.isEmpty())
			{
				setPerformanceRecord(newOpportunities, CMN_DAL_SObjectDomain.FIELD_CREATED_DATE);
			}

			if(!updatedOpportunities.isEmpty())
			{
				setPerformanceRecord(updatedOpportunities, CMN_DAL_SObjectDomain.FIELD_LAST_MODIFIED_DATE);
			}

			upsert upsertPerformancesMap.values() AW_AP_CompositeID__c;
		}
	}
	/**
	 * @description Method toset the performace record of Opporunity
	 *
	 * @param opportunities
	 * @param fieldName
	 */
	private void setPerformanceRecord(List<Opportunity> opportunities, String fieldName)
	{
		for(Opportunity newOpportunity : opportunities)
		{
			AW_AdviserPerformance__c upsertPerformance;
			String compositeKey = AW_DAL_AdviserPerformance.getCompositeKey(newOpportunity, fieldName, AW_DAL_Opportunity.FIELD_ADVISER_UACFID);

			if(String.isNotEmpty(compositeKey))
			{
				// check if record exist in current transaction
				upsertPerformance = upsertPerformancesMap.get(compositeKey);

				if(upsertPerformance == null)
				{
					// check if performance record already exist
					upsertPerformance = (AW_AdviserPerformance__c)foundPerformancesMap.get(compositeKey);

					// create new performance record
					if(upsertPerformance == null)
					{
						upsertPerformance = AW_DAL_AdviserPerformance.newAdviserPerformance(newOpportunity, compositeKey, fieldName, AW_DAL_Opportunity.FIELD_ADVISER_UACFID);
					}

					AggregateResult openOpportunities = countOfOpenOpportunitiesByOwnerMap.get(newOpportunity.OwnerId);
					AggregateResult newOpportunities = countOfNewOpportuntiesByOwnerMap.get(newOpportunity.OwnerId);
					AggregateResult wonOpportunities = countOfWonOpportuntiesByOwnerMap.get(newOpportunity.OwnerId);

					upsertPerformance.AW_NumberOfNewOpportunities__c = (newOpportunities != null) ? (Decimal)newOpportunities.get(AW_DAL_Opportunity.COUNT_OF_NEW_OPPORTUNITIES) : 0;

					upsertPerformance.AW_NumberOfOpportunitiesOpen__c = (openOpportunities != null) ? (Decimal)openOpportunities.get(AW_DAL_Opportunity.COUNT_OF_OPEN_OPPORTUNITIES) : 0;

					upsertPerformance.AW_NumberOfOpportunitiesWon__c = (wonOpportunities != null) ? (Decimal)wonOpportunities.get(AW_DAL_Opportunity.COUNT_OF_WON_OPPORTUNITIES) : 0;

				}

				// The opportunity won query is based on composite key which consider AW_ClosedDate__c(populated by process builder)
				// AW_ClosedDate__c would not be populated in the after trigger as process builder would run after it
				// So adding 1 in case opportunity is won in this transaction	
				if(wonOpportunities.contains(newOpportunity.Id))
				{
					upsertPerformance.AW_NumberOfOpportunitiesWon__c = upsertPerformance.AW_NumberOfOpportunitiesWon__c + 1;
				}
				// This is for the scenario where opportunity is moved from Won to any other stage
				// The AW_ClosedDate__c is populated to BLANK in process builder but after trigger will run before it
				// so we need to populate the count correctly by decreasing the count by 1
				else if(lostOpportunties.contains(newOpportunity.Id))
				{
					upsertPerformance.AW_NumberOfOpportunitiesWon__c = upsertPerformance.AW_NumberOfOpportunitiesWon__c - 1;
				}

				upsertPerformancesMap.put(compositeKey, upsertPerformance);
			}
		}
	}

	/**
	 * @description Will update the owner of the object to MasterAccount Owner
	 *
	 * @param newOpportunity A opportunity that's needs to be assigned to MasterAccount Owner
	 */
	private void setOpportunityOwner(Opportunity newOpportunity)
	{
		if(AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT.equalsIgnoreCase(currentUser.Profile.Name))
		{
			newOpportunity.OwnerId = newOpportunity.AW_ParentAccountOwnerId__c;
		}
	}

}