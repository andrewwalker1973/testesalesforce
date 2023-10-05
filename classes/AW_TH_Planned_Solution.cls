/**
 * @description Trigger handler for the Planned Solution object
 *
 * @see AW_TEST_TH_Planned_Solution @story ST-49024
 *
 * @author Deloitte
 *
 * @date 2020
 */
public inherited sharing class AW_TH_Planned_Solution extends CMN_TRH_BaseObject
{
	private List<AW_Planned_Solution__c> listNewSolutions = Trigger.new;

	/**
	 * @description After trigger code processes parent records (i.e. link or unlink child records)
	 */
	public override void bulkBefore()
	{
		super.bulkBefore();
		populateOpportunityOnSolutions();
	}

	/**
	 * @description This method will fetch Opportunity from FNA and populate it on Planned Solution.
	 * 					(Solution -> Financial Goal -> FNA -> Opportunity)
	 *
	 * @author Pooja Chordia (Deloitte)
	 *
	 * @date 05 November 2020
	 **/
	private void populateOpportunityOnSolutions()
	{
		//TODO: Relook at this method it seems overly complicated
		Map<Id, List<AW_Planned_Solution__c>> mapGoalIdAndSolution = new Map<Id, List<AW_Planned_Solution__c>>();
		Map<Id, List<FinServ__FinancialGoal__c>> fnaToGoalMap = new Map<Id, List<FinServ__FinancialGoal__c>>();
		Map<Id, Id> mapGoalAndOppID = new Map<Id, Id>();
		List<AW_Planned_Solution__c> listPlannedSolution;

		for(AW_Planned_Solution__c objSolution : listNewSolutions)
		{
			listPlannedSolution = new List<AW_Planned_Solution__c>();
			if(mapGoalIdAndSolution.containsKey(objSolution.AW_Financial_Goal__c))
			{
				listPlannedSolution = mapGoalIdAndSolution.get(objSolution.AW_Financial_Goal__c);
			}
			listPlannedSolution.add(objSolution);
			mapGoalIdAndSolution.put(objSolution.AW_Financial_Goal__c, listPlannedSolution);
		}

		fnaToGoalMap = AW_DAL_FinancialGoal.getFnaToGoalMap(mapGoalIdAndSolution.keySet());

		mapGoalAndOppID = AW_DAL_FNA.fetchOpportunityOnFNA(fnaToGoalMap);

		for(Id goalID : mapGoalIdAndSolution.keySet())
		{
			for(AW_Planned_Solution__c objSol : mapGoalIdAndSolution.get(goalID))
			{
				objSol.AW_Opportunity_Name__c = mapGoalAndOppID.containsKey(goalID) ? mapGoalAndOppID.get(goalID) : null;
			}
		}
	}
}