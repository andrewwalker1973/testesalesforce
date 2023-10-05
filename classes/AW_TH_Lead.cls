/**
 * @description Trigger handler for the trigger AW_TRG_Lead.
 *
 * @author Accenture
 *
 * @date 23 July 2019
@story ST-2226
 */
public inherited sharing class AW_TH_Lead extends CMN_TRH_BaseObject
{
	private Set<Id> ownerIds = new Set<Id>();
	private List<Lead> newLeads = new List<Lead>();
	private List<Lead> updatedLeads = new List<Lead>();
	private Map<Id, AggregateResult> userId2ConvertedLead = new Map<Id, AggregateResult>();
	private Map<Id, AggregateResult> userId2NewLead = new Map<Id, AggregateResult>();
	private Map<Id, AggregateResult> userId2OpenLead = new Map<Id, AggregateResult>();
	private Map<String, AW_AdviserPerformance__c> compositeKey2NewPerformance = new Map<String, AW_AdviserPerformance__c>();
	private Map<String, SObject> compositeKey2Performance = new Map<String, SObject>();
	private Set<String> performanceCompositeKeys = new Set<String>();
	private static final String ERROR_INVALID_ID = 'The identification number is incorrect.';

	/**
	 * @description Context method overrides will be called after insertion of Object.
	 *
	 * @param so To store the SObject
	 */
	public override void afterInsert(SObject so)
	{
		if(AW_DAL_FeatureSwitches.adviserTargetsEnabled)
		{
			Lead newLead = (Lead)so;

			// run only for user type
			if(newLead.OwnerId.getSobjectType() == User.SObjectType)
			{
				String compositeKey = AW_DAL_AdviserPerformance.getCompositeKey(newLead, CMN_DAL_SObjectDomain.FIELD_CREATED_DATE, AW_DAL_Lead.FIELD_ADVISER_UACFID);

				if(!String.isEmpty(compositeKey))
				{
					performanceCompositeKeys.add(compositeKey);
				} // composite keys to find weekly Leads, Opportunities

				ownerIds.add(newLead.OwnerId); // ownerIds to find Lead, Opportunities open so far
				newLeads.add(newLead); // Leads to process
			}
		}
	}

	/**
	 * @description Context method overrides will be called after updation of Object.
	 *
	 * @param oldSo To store the SObject
	 * @param so To store the SObject
	 */
	public override void afterUpdate(SObject oldSo, SObject so)
	{
		if(AW_DAL_FeatureSwitches.adviserTargetsEnabled)
		{

			Lead newLead = (Lead)so;
			Lead oldLead = (Lead)oldSo;

			// run only for user type
			if(newLead.Status != oldLead.Status && newLead.Status == AW_DAL_Lead.STATUS_CONVERTED
					&& newLead.OwnerId.getSobjectType() == User.SObjectType)
			{
				String compositeKeyNew = AW_DAL_AdviserPerformance.getCompositeKey(newLead, CMN_DAL_SObjectDomain.FIELD_LAST_MODIFIED_DATE, AW_DAL_Lead.FIELD_ADVISER_UACFID);

				if(!String.isEmpty(compositeKeyNew))
				{
					performanceCompositeKeys.add(compositeKeyNew);
				} // composite keys to find weekly Leads, Opportunities

				updatedLeads.add(newLead); // Leads to process
				ownerIds.add(newLead.OwnerId); // ownerIds to find Lead, Opportunities open so far
			}
			if(newLead.OwnerId != oldLead.OwnerId)
			{
				if(newLead.OwnerId.getSobjectType() == User.SObjectType)
				{
					String compositeKeyNew = AW_DAL_AdviserPerformance.getCompositeKey(newLead, CMN_DAL_SObjectDomain.FIELD_LAST_MODIFIED_DATE, AW_DAL_Lead.FIELD_ADVISER_UACFID);

					if(!String.isEmpty(compositeKeyNew))
					{
						performanceCompositeKeys.add(compositeKeyNew);
					}

					ownerIds.add(newLead.OwnerId);
					updatedLeads.add(newLead);
				}

				//There is a situation where a lead created via Web to Lead fires a  PB to set the load Owner
				//In this scenario, the oldLead.OwnerId is NULL, hence the check in the code
				if(oldLead.OwnerId != null && oldLead.OwnerId.getSobjectType() == User.SObjectType)
				{
					String compositeKeyOld = AW_DAL_AdviserPerformance.getCompositeKey(oldLead, CMN_DAL_SObjectDomain.FIELD_LAST_MODIFIED_DATE, AW_DAL_Lead.FIELD_ADVISER_UACFID);

					if(!String.isEmpty(compositeKeyOld))
					{
						performanceCompositeKeys.add(compositeKeyOld);
					}

					ownerIds.add(oldLead.OwnerId);
					// update old owner performance record
					updatedLeads.add(oldLead);
				}
			}
		}
	}

	/**
	 * @description Context method overrides will be called after deletion of Object.
	 *
	 * @param so To store the SObject
	 */
	public override void afterDelete(SObject so)
	{
		if(AW_DAL_FeatureSwitches.adviserTargetsEnabled)
		{
			Lead deletedLead = (Lead)so;
			// run only for user type
			if(deletedLead.OwnerId.getSobjectType() == User.SObjectType)
			{
				String compositeKey = AW_DAL_AdviserPerformance.getCompositeKey(deletedLead, CMN_DAL_SObjectDomain.FIELD_LAST_MODIFIED_DATE, AW_DAL_Lead.FIELD_ADVISER_UACFID);

				if(!String.isEmpty(compositeKey))
				{
					performanceCompositeKeys.add(compositeKey);
				}

				ownerIds.add(deletedLead.OwnerId);

				updatedLeads.add(deletedLead);
			}
		}
	}

	/**
	 * @description Context method overrides will be called after undelete of Object.
	 *
	 * @param so To store the SObject
	 */
	public override void afterUndelete(SObject so)
	{
		if(AW_DAL_FeatureSwitches.adviserTargetsEnabled)
		{
			Lead unDeletedLead = (Lead)so;

			if(unDeletedLead.OwnerId.getSobjectType() == User.SObjectType)
			{
				String compositeKey = AW_DAL_AdviserPerformance.getCompositeKey(unDeletedLead, CMN_DAL_SObjectDomain.FIELD_LAST_MODIFIED_DATE, AW_DAL_Lead.FIELD_ADVISER_UACFID);

				if(!String.isEmpty(compositeKey))
				{
					performanceCompositeKeys.add(compositeKey);
				}

				ownerIds.add(unDeletedLead.OwnerId);
				updatedLeads.add(unDeletedLead);
			}
		}
	}

	/**
	 * @description Context method overrides will be called before insertion of Object.
	 *
	 * @param so To store the SObject
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);

		Lead newLead = (Lead)so;

		extractAndSetSouthAfricanIdentityNumberDetails(newLead);
	}

	/**
	 * @description Context method overrides will be called before updation of Object.
	 *
	 * @param oldSo
	 * @param so
	 */
	public override void beforeUpdate(SObject oldSo, SObject so)
	{
		super.beforeUpdate(oldSo, so);

		Lead oldLead = (Lead)oldSo;
		Lead newLead = (Lead)so;

		if(
				newLead.AW_IdentificationNumber__c != oldLead.AW_IdentificationNumber__c ||
						(newLead.AW_IdentificationType__c != oldLead.AW_IdentificationType__c &&
								AW_DAL_Lead.IDENTIFICATION_TYPE_SA_ID.equalsIgnoreCase(newLead.AW_IdentificationType__c))
				)
		{
			extractAndSetSouthAfricanIdentityNumberDetails(newLead);
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
				List<AW_AdviserPerformance__c> performances = AW_DAL_AdviserPerformance.findByCompositeId(performanceCompositeKeys);
				//composite key to existing performance
				compositeKey2Performance = CMN_UTIL_System.convertListToSingleStringMap(performances, AW_DAL_AdviserPerformance.FIELD_COMPOSITE_KEY);

				userId2OpenLead = AW_DAL_Lead.findCountOpenLeadsByOwnerIds(ownerIds);
				userId2NewLead = AW_DAL_Lead.findCountWeeklyNewLeadsByOwnerIds(performanceCompositeKeys);
				userId2ConvertedLead = AW_DAL_Lead.findCountWeeklyConvertedLeadsByOwnerId(performanceCompositeKeys);
			}

			if(!newLeads.isEmpty())
			{
				setPerformanceRecord(newLeads, CMN_DAL_SObjectDomain.FIELD_CREATED_DATE);
			} // use created date for new leads as it can be populated manually in data load

			if(!updatedLeads.isEmpty())
			{
				setPerformanceRecord(updatedLeads, CMN_DAL_SObjectDomain.FIELD_LAST_MODIFIED_DATE);
			} // use last modified date for updated records

			upsert compositeKey2NewPerformance.values() AW_AP_CompositeID__c;
		}
	}

	/**
	 * @description This method is use to set the performance records of related leads.
	 *
	 * @param affectedLeads
	 * @param fieldName
	 */
	private void setPerformanceRecord(List<Lead> affectedLeads, String fieldName)
	{
		for(Lead affectedLead : affectedLeads)
		{
			AW_AdviserPerformance__c upsertPerformance;

			String compositeKey = AW_DAL_AdviserPerformance.getCompositeKey(affectedLead, fieldName, AW_DAL_Lead.FIELD_ADVISER_UACFID);

			if(!String.isEmpty(compositeKey))
			{
				// check if record exist in current transaction
				upsertPerformance = (AW_AdviserPerformance__c)compositeKey2Performance.get(compositeKey);

				// check if performance record already exist
				if(upsertPerformance == null)
				{
					upsertPerformance = compositeKey2NewPerformance.get(compositeKey);
				}

				// create new performance record
				if(upsertPerformance == null)
				{
					upsertPerformance = AW_DAL_AdviserPerformance.newAdviserPerformance(affectedLead, compositeKey, fieldName, AW_DAL_Lead.FIELD_ADVISER_UACFID);
				}
			}

			// set the sales metrics
			if(upsertPerformance != null)
			{
				AggregateResult openLeads = userId2OpenLead.get(affectedLead.OwnerId);
				AggregateResult newLeads = userId2NewLead.get(affectedLead.OwnerId);
				AggregateResult convertedLeads = userId2ConvertedLead.get(affectedLead.OwnerId);

				upsertPerformance.AW_NumberOfNewLeads__c = (newLeads != null) ? (Decimal)newLeads.get(AW_DAL_Lead.COUNT_OF_NEW_LEADS) : 0;

				upsertPerformance.AW_NumberOfLeadConverted__c = (convertedLeads != null) ? (Decimal)convertedLeads.get(AW_DAL_Lead.COUNT_OF_CONVERTED_LEADS) : 0;

				upsertPerformance.AW_NumberOfOpenLeads__c = (openLeads != null) ? (Decimal)openLeads.get(AW_DAL_Lead.COUNT_OF_OPEN_LEADS) : 0;

				compositeKey2NewPerformance.put(compositeKey, upsertPerformance);
			}
		}
	}

	/**
	 * @description Will extract Date of Birth and Gender from Identification Number and update the relevant on the Lead object
	 *
	 * @param newLead
	 */
	private void extractAndSetSouthAfricanIdentityNumberDetails(Lead newLead)
	{
		if(AW_DAL_Lead.IDENTIFICATION_TYPE_SA_ID.equalsIgnoreCase(newLead.AW_IdentificationType__c))
		{
			if(String.isBlank(newLead.AW_IdentificationNumber__c))
			{
				newLead.AW_DateOfBirth__c = null;
				newLead.AW_Gender__c = null;
			}
			else if(AW_UTIL_IdentityNumber.isValidIdentityNumber(newLead.AW_IdentificationNumber__c))
		{
			newLead.AW_DateOfBirth__c = AW_UTIL_IdentityNumber.extractDateOfBirthFromIdentityNumber(newLead.AW_IdentificationNumber__c);
			newLead.AW_Gender__c = AW_UTIL_IdentityNumber.getGenderFromIdentityNumber(newLead.AW_IdentificationNumber__c);
		}
			else
			{
				newLead.AW_IdentificationNumber__c.addError(ERROR_INVALID_ID);//157390 - added as part of Lead enhancements
			}
		}
	}
}