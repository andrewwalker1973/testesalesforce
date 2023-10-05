/**
 * @description Trigger handler for the FNA Object
 *
 * @see AW_TH_FNA_TEST @story ST-45112
 *
 * @author Deloitte
 *
 * @date 2020
 */
public inherited sharing class AW_TH_FNA extends AW_TH_BaseLinkToMaster
{
	private User currentUser = new User();
	private List<AW_FNA__c> listNewFNAs = Trigger.new;
	private List<Opportunity> listOppToCreate = new List<Opportunity>();

	/**
	 * @description After trigger code processes parent records (i.e. link or unlink child records)
	 */
	public override void bulkBefore()
	{
		super.bulkBefore();
		currentUser = AW_DAL_User.getCurrentUser();
		linkOpportunityToFNA();
	}

	/**
	 * @description Context method overrides will be called before insertion of Object.
	 *
	 * @param so To store the FNA
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);
		setFNAOwner((AW_FNA__c)so);
	}

	/**
	 * @description After trigger code processes parent records (i.e. link or unlink child records)
	 */
	public override void bulkAfter()
	{
		super.bulkAfter();
		updateOpportunityStatus();
	}

	/**
	 * @description Whenever MuleSoft inserts/updates FNA record,this method will update the stage of
	 * 					Opportunity related to that FNA to Perform FNA.
	 **/
	private void updateOpportunityStatus()
	{
		Set<Id> opportunityIds = CMN_UTIL_System.extractListIds(listNewFNAs, AW_DAL_FNA.FIELD_OPPORTUNITY);

		if(!opportunityIds.isEmpty())
		{
			CMN_DAL_SObjectDomain.updateDBObjects(AW_DAL_Opportunity.updateOpportunityToPerformFnaStage(opportunityIds), false);
		}
	}

	/**
	 * @description Whenever MuleSoft inserts/updates FNA record,this method will link the FNA to
	 * 					relevant Opportunity
	 *
	 * @author Pooja Chordia (Deloitte)
	 *
	 * @date 02 November 2020
	 **/
	private void linkOpportunityToFNA()
	{
		Map<Id, AW_FNA__c> mapAccIdsobjFNA = new Map<Id, AW_FNA__c>();
		Map<Id, Integer> results = new Map<Id, Integer>();
		List<AW_FNA__c> listFNAWithoutOpp = new List<AW_FNA__c>();

		if(listNewFNAs != null)
		{

			for(AW_FNA__c objFNA : listNewFNAs)
			{
				if(objFNA.AW_Opportunity__c == null)
				{
					mapAccIdsobjFNA.put(objFNA.AW_Account__c, objFNA);
				}
			}
			if(!mapAccIdsobjFNA.isEmpty())
			{
				results = AW_DAL_Opportunity.findCountOfOpportunitiesForAccounts(mapAccIdsobjFNA.keySet());
				for(Id accountID : mapAccIdsobjFNA.keySet())
				{
					if(!results.containsKey(accountID))
					{
						listFNAWithoutOpp.add(mapAccIdsobjFNA.get(accountID));
					}
				}
				if(!listFNAWithoutOpp.isEmpty())
				{
					listOppToCreate.addAll(AW_DAL_Opportunity.createOppInPerformFNAStage(listFNAWithoutOpp));
					CMN_DAL_SObjectDomain.insertDBObjects(listOppToCreate, true);
				}
				AW_DAL_Opportunity.linkOpportunityToFNA(mapAccIdsobjFNA);
			}
		}
	}

	/**
	 * @description Will update the owner of the object to Parent Account Owner
	 *
	 * @param newFNA A FNA that's needs to be assigned to Parent Account Owner
	 */
	private void setFNAOwner(AW_FNA__c newFNA)
	{
		if(AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT.equalsIgnoreCase(currentUser.Profile.Name))
		{
			newFNA.OwnerId = newFNA.AW_ParentAccountOwnerId__c;
		}
	}
}