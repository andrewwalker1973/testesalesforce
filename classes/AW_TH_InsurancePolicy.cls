/**
 * @description Trigger handler responsible for rolling up goal based totals and setting master account recordtype
 *
 * @see AW_TEST_TH_InsurancePolicy
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date 2019, December 2022
 */
public inherited sharing class AW_TH_InsurancePolicy extends AW_TH_BaseLinkToMaster
{
	private static Map<Id, Account> masterAccountToIdMap = new Map<Id, Account>();
	private static Set<Id> parentGoalIds = new Set<Id>();
	private static final User CURRENT_USER = AW_DAL_User.getCurrentUser();

	/**
	 * @description Before trigger will get the current user information
	 */

	public override void bulkBefore()
	{
		super.bulkBefore();
		masterAccountToIdMap = getMasterAccountDetails(Trigger.new);
	}

	/**
	 * @description Context method overrides will be called before insertion of Object.
	 *
	 * @param so To store the InsurancePolicy
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);

		InsurancePolicy newPolicy = (InsurancePolicy)so;
		setInsurancePolicyOwner(newPolicy);
		setMasterAccountRecordTypeName(newPolicy);
	}

	public override void beforeUpdate(SObject oldSo, SObject so)
	{
		super.beforeUpdate(oldSo, so);
		InsurancePolicy newPolicy = (InsurancePolicy)so;
		setMasterAccountRecordTypeName(newPolicy);
	}

	/**
	 * @description Will update the owner of the object to Parent Account Owner
	 *
	 * @param newPolicy A Insurance policy that's needs to be assigned to Parent Account Owner
	 */
	private static void setInsurancePolicyOwner(InsurancePolicy newPolicy)
	{
		if(AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT.equalsIgnoreCase(CURRENT_USER.Profile.Name))
		{
			newPolicy.OwnerId = newPolicy.AW_ParentAccountOwnerId__c;
		}
	}

	/**
	 * @description Will check if the record needs the master record type name set (this is used for sharing rules)
	 *
	 * @param newPolicy The current version of the policy
	 */
	private static void setMasterAccountRecordTypeName(InsurancePolicy newPolicy)
	{
		newPolicy.CMN_MasterAccountRecordTypeName__c = masterAccountToIdMap.get(newPolicy.AW_MasterAccount__c)?.RecordType.DeveloperName;
	}

	public override void afterInsert(SObject so)
	{
		super.afterInsert(so);

		addGoalToRecalculate(null, (InsurancePolicy)so);
	}

	public override void afterUpdate(SObject oldSo, SObject so)
	{
		super.afterUpdate(oldSo, so);

		InsurancePolicy oldPolicy = (InsurancePolicy)oldSo;
		InsurancePolicy newPolicy = (InsurancePolicy)so;

		addGoalToRecalculate(oldPolicy, newPolicy);
	}

	public override void afterDelete(SObject so)
	{
		super.afterDelete(so);

		addGoalToRecalculate((InsurancePolicy)so, null);
	}

	public override void afterUndelete(SObject so)
	{
		super.afterDelete(so);

		addGoalToRecalculate(null, (InsurancePolicy)so);
	}

	/**
	 * @description Context method overrides will be called after the end of trigger executions .
	 */
	public override void andFinally()
	{
		super.andFinally();

		if(!parentGoalIds.isEmpty())
		{
			List<AggregateResult> aggregateResults = AW_DAL_InsurancePolicy.totalCurrentValuePerGoal(parentGoalIds);

			List<FinServ__FinancialGoal__c> goalsToUpdate = new List<FinServ__FinancialGoal__c>();

			for(AggregateResult result : aggregateResults)
			{
				FinServ__FinancialGoal__c updateGoal = new FinServ__FinancialGoal__c();

				updateGoal.Id = (Id)result.get(AW_DAL_InsurancePolicy.FIELD_FINANCIAL_GOAL);
				updateGoal.AW_TotalInsuranceAmount__c = (Decimal)result.get(AW_DAL_InsurancePolicy.FIELD_CURRENT_VALUE);

				goalsToUpdate.add(updateGoal);

				//Remove Goals from original list; if any items remain in the original set, then for these we need to set  the value blank
				parentGoalIds.remove(updateGoal.Id);
			}

			//Make sure for any  unprocessed goals, we null the total insurance as they won't have related insurance policies
			for(Id goalId : parentGoalIds)
			{
				FinServ__FinancialGoal__c updateGoal = new FinServ__FinancialGoal__c();

				updateGoal.Id = goalId;
				updateGoal.AW_TotalInsuranceAmount__c = null;

				goalsToUpdate.add(updateGoal);
			}

			CMN_DAL_SObjectDomain.updateDBObjects(goalsToUpdate);
		}
	}

	/**
	 * @description This method is use to calculate the policy after the trigger execution
	 *
	 * @param oldInsurancePolicy Old version of the record
	 * @param newInsurancePolicy Updated version of the record
	 */
	private static void addGoalToRecalculate(InsurancePolicy oldInsurancePolicy, InsurancePolicy newInsurancePolicy)
	{
		if(Trigger.isInsert || Trigger.isUndelete)
		{
			parentGoalIds.add(newInsurancePolicy.AW_FinancialGoal__c);
		}
		else if(Trigger.isDelete)
		{
			parentGoalIds.add(oldInsurancePolicy.AW_FinancialGoal__c);
		}
		else if(Trigger.isUpdate)
		{
			if(oldInsurancePolicy.AW_FinancialGoal__c != newInsurancePolicy.AW_FinancialGoal__c)
			{
				//We may have  to re-calculate different goals
				parentGoalIds.add(newInsurancePolicy.AW_FinancialGoal__c);
				parentGoalIds.add(oldInsurancePolicy.AW_FinancialGoal__c);
			}
			else if(oldInsurancePolicy.AW_CurrentValue__c != newInsurancePolicy.AW_CurrentValue__c)
			{
				parentGoalIds.add(newInsurancePolicy.AW_FinancialGoal__c);
			}
		}

		parentGoalIds = CMN_UTIL_System.trimSet(parentGoalIds);
	}

	public override Boolean allowRecursion()
	{
		return false;
	}

}