/**
 * @description Public class to return the records of FNA
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_DAL_FNA
{
	private static final String FIELD_ACCOUNT_ID = AW_FNA__c.AW_Account__c.getDescribe().getLocalName();
	private static final String FIELD_FNA_ID = AW_FNA__c.AW_FNAID__c.getDescribe().getLocalName();
	private static final String FIELD_OPPORTUNITY_STAGE_NAME = 'AW_Opportunity__r.StageName';
	private static final String OBJECT_NAME = AW_FNA__c.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_OPPORTUNITY = AW_FNA__c.AW_Opportunity__c.getDescribe().getLocalName();
	public static final String URL_NAME = 'Avalon';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				AW_FNA__c.AW_FNADate__c.getDescribe().getLocalName(),
				AW_FNA__c.AW_FNADescription__c.getDescribe().getLocalName(),
				AW_FNA__c.AW_MasterAccount__c.getDescribe().getLocalName(),
				AW_FNA__c.Id.getDescribe().getLocalName(),
				AW_FNA__c.OwnerId.getDescribe().getLocalName(),
				FIELD_ACCOUNT_ID,
				FIELD_FNA_ID,
				FIELD_OPPORTUNITY,
				FIELD_OPPORTUNITY_STAGE_NAME
		};
	}

	/**
	 * @description This method is use to get an FNA by FNA Id
	 *
	 * @param fnaId
	 *
	 * @return Either Null or Item
	 */
	public static AW_FNA__c findByFnaId(String fnaId)
	{
		return (AW_FNA__c)CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_FNA_ID, fnaId, getDefaultFields(), false);
	}

	/**
	 * @description This method is use to get the list of FNA with account
	 *
	 * @param accountIds Id to strore the accounts
	 *
	 * @return List of FNA
	 */
	public static List<AW_FNA__c> findByAccountIds(Set<Id> accountIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_ACCOUNT_ID, accountIds, getDefaultFields());
	}

	/**
	 * @description Finds Fna's based on Id
	 *
	 * @param fnaId Id of the fna
	 *
	 * @return Null or FNA
	 */
	@TestVisible
	private static AW_FNA__c findById(Id fnaId)
	{
		return (AW_FNA__c)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, fnaId, getDefaultFields());
	}

	/**
	 * @description Finds Fna's based on Id
	 *
	 * @param fnaIds FNA Ds
	 *
	 * @return List of FNA's
	 */
	public static List<AW_FNA__c> findById(Set<Id> fnaIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, fnaIds, getDefaultFields());
	}

	/**
	 * @description This method will fetch Opportunity on FNA and return map of Goal Ids and Opportunity Ids
	 *
	 * @param fnaToGoalMap Map<Id,Id>
	 *
	 * @return Map of Goal and OpportunityId
	 **/
	public static Map<Id, Id> fetchOpportunityOnFNA(Map<Id, List<FinServ__FinancialGoal__c>> fnaToGoalMap)
	{
		Map<Id, Id> mapGoalAndOppId = new Map<Id, Id>();

		for(AW_FNA__c foundFNA : findById(fnaToGoalMap.keySet()))
		{
			for(FinServ__FinancialGoal__c goal : fnaToGoalMap.get(foundFNA.Id))
			{
				mapGoalAndOppId.put(goal.Id, foundFNA.AW_Opportunity__c);
			}
		}

		return mapGoalAndOppId;
	}

}