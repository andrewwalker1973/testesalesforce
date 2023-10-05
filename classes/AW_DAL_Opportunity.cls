/**
 * @description Public class to return the records of Opportunity
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_DAL_Opportunity
{
	private static final String FIELD_ACCOUNT_ID = Opportunity.AccountId.getDescribe().getLocalName();
	private static final String FIELD_STATUS = 'Account.FinServ__Status__c';
	private static final String OPPORTUNITY_ID = Opportunity.Id.getDescribe().getLocalName();
	private static final String FIELD_ACCOUNT_SKF_ID = 'Account.AW_SKF_Id__c';
	private static final String FIELD_OWNER_UACFID = 'Account.AW_Owner_UACFID__c';
	private static final String FIELD_STAGE_NAME = Opportunity.StageName.getDescribe().getLocalName();
	private static final String OBJECT_NAME = Opportunity.SObjectType.getDescribe().getLocalName();
	public static final String COUNT_OF_NEW_OPPORTUNITIES = 'countOfNewOpportunities';
	public static final String COUNT_OF_OPEN_OPPORTUNITIES = 'countOfOpenOpportunities';
	public static final String COUNT_OF_WON_OPPORTUNITIES = 'countOfWonOpportunities';
	public static final String FIELD_ADVISER_UACFID = Opportunity.AW_AdviserUACFID__c.getDescribe().getLocalName();
	public static final String OPPORTUNITY_PRODUCT_INTEREST_INVESTMENT = 'Investment';
	public static final String OPPORTUNITY_PRODUCT_INTEREST_RISK = 'Risk';
	public static final String OPPORTUNITY_STAGE_BUSINESS_ACCEPTED = 'Business Accepted';
	public static final String OPPORTUNITY_STAGE_CASE_SUBMITTED = 'Submit Business';
	public static final String OPPORTUNITY_STAGE_CLOSED_LOST = 'Closed Lost';
	public static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
	public static final String OPPORTUNITY_STAGE_PERFORM_FNA = 'Perform FNA';
	public static final String OPPORTUNITY_STAGE_QUALIFIED = 'Qualify';
	public static final String OPPORTUNITY_STAGE_QUOTE_PROPOSED = 'Propose Solution';
	public static final String OPPORTUNITY_STAGE_SOLUTION_ACCEPTED = 'Solution Accepted';
	public static final String RT_DEFAULT_OPPORTUNITY = 'AW_DefaultOpportunity';

	public static final Set<String> OPEN_OPPORTUNITY_STAGES = new Set<String>
	{
			OPPORTUNITY_STAGE_QUALIFIED,
			OPPORTUNITY_STAGE_PERFORM_FNA,
			OPPORTUNITY_STAGE_QUOTE_PROPOSED
	};

	private static final Set<String> CLOSED_OPPORTUNITY_STAGES = new Set<String>
	{
			OPPORTUNITY_STAGE_CLOSED_WON,
			OPPORTUNITY_STAGE_CLOSED_LOST
	};

	/**
	 * @description Method to define the fields to retrieve for most queries
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_ACCOUNT_ID,
				FIELD_ACCOUNT_SKF_ID,
				FIELD_OWNER_UACFID,
				FIELD_ADVISER_UACFID,
				FIELD_STAGE_NAME,
				FIELD_STATUS,
				Opportunity.AW_MasterAccount__c.getDescribe().getLocalName(),
				Opportunity.AW_ProductInterest__c.getDescribe().getLocalName(),
				Opportunity.CreatedDate.getDescribe().getLocalName(),
				Opportunity.Id.getDescribe().getLocalName(),
				Opportunity.LastModifiedDate.getDescribe().getLocalName(),
				Opportunity.OwnerId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description This method is use to get the list of of OPen Opportunities for an Account
	 *
	 * @param accountId Id of the account
	 *
	 * @return list of items
	 */
	public static List<Opportunity> findOpenByAccountId(Id accountId)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_ACCOUNT_ID, new Set<String> {String.valueOf(accountId)}, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.SetCondition(FIELD_STAGE_NAME, CMN_SOQL_Query.Operator.INX, CMN_UTIL_System.setToList(OPEN_OPPORTUNITY_STAGES)));
		searchParameters.searchConditions.add(andCondition);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method is use to get the list of Opportunities with a closed status for a given account
	 *
	 * @param accountIds
	 *
	 * @return list of items
	 */
	private static List<Opportunity> findNotClosedByAccountId(Set<Id> accountIds)
	{
		Set<String> accountIdStrings = new Set<String>();

		for(Id accountId : accountIds)
		{
			accountIdStrings.add(String.valueOf(accountId));
		}

		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_ACCOUNT_ID, accountIdStrings, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.SetCondition(FIELD_STAGE_NAME, CMN_SOQL_Query.Operator.NOT_IN, CMN_UTIL_System.setToList(CLOSED_OPPORTUNITY_STAGES)));
		searchParameters.searchConditions.add(andCondition);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method is use to get the Map which contain the count of Opportunity of the Owner
	 *
	 * @param ownerIds 
	 *
	 * @return Map
	 */
	public static Map<Id, AggregateResult> findCountOpenOpportunitiesByOwnerIds(Set<Id> ownerIds)
	{
		Map<Id, AggregateResult> results = new Map<Id, AggregateResult>();
		for(AggregateResult result :
		[
				SELECT OwnerId,
						COUNT(Id) countOfOpenOpportunities
				FROM Opportunity
				WHERE OwnerId IN :ownerIds
				AND IsWon != TRUE
				GROUP BY OwnerId
		])
		{
			results.put((Id)result.get(CMN_DAL_SObjectDomain.FIELD_OWNER_ID), result);
		}
		return results;
	}

	/**
	 * @description This method is use to get the Map which contain the count of Opportunity of the Owner created weekly
	 *
	 * @param performanceCompositeKeys a set of composite keys
	 *
	 * @return A map of aggregates by ownerId
	 */
	public static Map<Id, AggregateResult> findCountWeeklyNewOpportunitiesByOwnerIds(Set<String> performanceCompositeKeys)
	{
		Map<Id, AggregateResult> results = new Map<Id, AggregateResult>();
		for(AggregateResult result :
		[
				SELECT OwnerId,
						COUNT(Id) countOfNewOpportunities
				FROM Opportunity
				WHERE AW_OpportunityCreatedKey__c IN :performanceCompositeKeys
				GROUP BY OwnerId
		])
		{
			results.put((Id)result.get(CMN_DAL_SObjectDomain.FIELD_OWNER_ID), result);
		}
		return results;
	}
	/**
	 * @description This method is use to get the Map which contain in count of Opportunity of the Owner created weekly
	 *
	 * @param performanceCompositeKeys 
	 *
	 * @return 
	 */
	public static Map<Id, AggregateResult> findCountWeeklyWonOpportunitiesByOwnerId(Set<String> performanceCompositeKeys)
	{
		Map<Id, AggregateResult> results = new Map<Id, AggregateResult>();

		for(AggregateResult result :
		[
				SELECT OwnerId,
						COUNT(Id) countOfWonOpportunities
				FROM Opportunity
				WHERE AW_OpportunityWonKey__c IN :performanceCompositeKeys
				GROUP BY OwnerId
		])
		{
			results.put((Id)result.get(CMN_DAL_SObjectDomain.FIELD_OWNER_ID), result);
		}
		return results;
	}

	/**
	 * @description This method will count the number of Opportunities related to each account
	 *
	 * @param accountIds 
	 *
	 * @return Map<Id, Integer>
	 *
	 * @author Pooja Chordia (Deloitte)
	 *
	 * @date 13 October 2020
	 */
	public static Map<Id, Integer> findCountOfOpportunitiesForAccounts(Set<Id> accountIds)
	{
		Map<Id, Integer> results = new Map<Id, Integer>();
		for(AggregateResult result :
		[
				SELECT AccountId,
						COUNT(Id) countOfOpportunities
				FROM Opportunity
				WHERE AccountId IN:accountIds
				AND StageName NOT IN:CLOSED_OPPORTUNITY_STAGES
				GROUP BY AccountId
		])
		{
			results.put((Id)result.get('AccountId'), (Integer)result.get('countOfOpportunities'));
		}
		return results;
	}

	/**
	 * @description This method will create a new Opportunity in stage "Perform FNA" with
	 * 					name similar to FNA Name
	 *
	 * @param listFNA 
	 *
	 * @return List<Opportunity>
	 *
	 * @author Pooja Chordia (Deloitte)
	 *
	 * @date 13 October 2020
	 */
	public static List<Opportunity> createOppInPerformFNAStage(List<AW_FNA__c> listFNA)
	{
		List<Opportunity> listOppToCreate = new List<Opportunity>();
		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Opportunity.SObjectType, RT_DEFAULT_OPPORTUNITY);

		for(AW_FNA__c fnaRecord : listFNA)
		{
			listOppToCreate.add(new Opportunity(Name = fnaRecord.AW_FNADescription__c,
					CloseDate = System.today().addMonths(2),
					StageName = OPPORTUNITY_STAGE_PERFORM_FNA,
					AccountId = fnaRecord.AW_Account__c,
					OwnerId = fnaRecord.OwnerId,
					RecordTypeId = recordTypeId));
		}
		return listOppToCreate;
	}

	/**
	 * @description This method is use to get the list of Opportunities with a qualified status
	 *
	 * @param opportunityIds
	 *
	 * @return list of items
	 */
	private static List<Opportunity> findByIdAndQualifiedStage(Set<Id> opportunityIds)
	{
		Set<String> opportunityIdStrings = new Set<String>();

		for(Id opportunityId : opportunityIds)
		{
			opportunityIdStrings.add(String.valueOf(opportunityId));
		}

		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_ID, opportunityIdStrings, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_STAGE_NAME, CMN_SOQL_Query.Operator.EQUALS, OPPORTUNITY_STAGE_QUALIFIED));
		searchParameters.searchConditions.add(andCondition);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method is use to get the list of Opportunities for an account  with a qualified status
	 *
	 * @param accountId
	 *
	 * @return list of items
	 */
	@TestVisible
	private static List<Opportunity> findByAccountIdAndPerformFnaStage(Id accountId)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_ACCOUNT_ID, new Set<String> {String.valueOf(accountId)}, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_STAGE_NAME, CMN_SOQL_Query.Operator.EQUALS, OPPORTUNITY_STAGE_PERFORM_FNA));
		searchParameters.searchConditions.add(andCondition);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method will update Opportunity's stage to "Perform FNA" if it is in "Qualify" stage
	 *
	 * @param opportunityIds
	 *
	 * @return list of items
	 */
	public static List<Opportunity> updateOpportunityToPerformFnaStage(Set<Id> opportunityIds)
	{
		List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

		//Update Opportunity status if they are in Qualify stage
		for(Opportunity foundOpportunity : findByIdAndQualifiedStage(opportunityIds))
		{
			foundOpportunity.StageName = OPPORTUNITY_STAGE_PERFORM_FNA;
			opportunitiesToUpdate.add(foundOpportunity);
		}

		return opportunitiesToUpdate;
	}

	/**
	 * @description This method will link relevant Opportunity to each FNA
	 *
	 * @param opportunityIdToFnaMap
	 */
	public static void linkOpportunityToFNA(Map<Id, AW_FNA__c> opportunityIdToFnaMap)
	{
		Map<Id, List<Opportunity>> accountIdToOpportunityMap = new Map<Id, List<Opportunity>>();

		//Create a map of Account Id and it's related Opportunities
		for(Opportunity foundOpportunity : findNotClosedByAccountId(opportunityIdToFnaMap.keySet()))
		{
			List<Opportunity> opportunities = accountIdToOpportunityMap.get(foundOpportunity.AccountId);

			if(opportunities == null)
			{
				opportunities = new List<Opportunity>();
				accountIdToOpportunityMap.put(foundOpportunity.AccountId, opportunities);
			}

			opportunities.add(foundOpportunity);
		}

		/*Iterate over the Opportunities for each account to find the
		latest Opportunity to be linked to FNA*/

		for(Id accountId : accountIdToOpportunityMap.keySet())
		{
			List<Opportunity> listQualifyOpp = new List<Opportunity>();
			List<Opportunity> listPerformFNAOpp = new List<Opportunity>();
			List<Opportunity> listHigherStageOpp = new List<Opportunity>();
			Opportunity objOppTolink = new Opportunity();
			for(Opportunity objOpp : accountIdToOpportunityMap.get(accountId))
			{
				if(objOpp.StageName == OPPORTUNITY_STAGE_QUALIFIED)
				{
					listQualifyOpp.add(objOpp);
				}
				else if(objOpp.StageName == OPPORTUNITY_STAGE_PERFORM_FNA)
				{
					listPerformFNAOpp.add(objOpp);
				}
				else
				{
					listHigherStageOpp.add(objOpp);
				}
			}

			if(!listQualifyOpp.isEmpty())
			{
				objOppTolink = fetchLatestOpportunity(listQualifyOpp);
			}
			else if(!listPerformFNAOpp.isEmpty())
			{
				objOppTolink = fetchLatestOpportunity(listPerformFNAOpp);
			}
			else
			{
				objOppTolink = fetchLatestOpportunity(listHigherStageOpp);
			}

			opportunityIdToFnaMap.get(accountId).AW_Opportunity__c = objOppTolink.Id;
		}
	}

	/**
	 * @description This method will fetch the latest Opportunity from list of Opportunities
	 *
	 * @param opportunities
	 *
	 * @return the latest opportunity
	 */
	private static Opportunity fetchLatestOpportunity(List<Opportunity> opportunities)
	{
		Opportunity objLatestOpp = new Opportunity();

		for(Opportunity objOpp : opportunities)
		{
			if(objLatestOpp.Id == null)
			{
				objLatestOpp = objOpp;
			}
			else if(objLatestOpp.Id != null && objOpp.LastModifiedDate > objLatestOpp.LastModifiedDate)
			{
				objLatestOpp = objOpp;
			}
		}
		return objLatestOpp;
	}

	/**
	 * @description Retrieves the opportunities having the given ids.
	 *
	 * @param opportunityIds item ids
	 *
	 * @return list of items
	 */
	public static List<Opportunity> findById(Set<Id> opportunityIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, opportunityIds, getDefaultFields());
	}

	/**
	 * @description Will find an opportunity based on Id
	 *
	 * @param opportunityId The opportunity id to use when performing the search
	 *
	 * @return either null or opportunity
	 */
	public static Opportunity findById(Id opportunityId)
	{
		return (Opportunity)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, opportunityId, getDefaultFields());
	}

	/**
	 * @description retrieves all Opportunities in the system
	 *
	 * @return A list of test creatd opportunities
	 */
	@TestVisible
	private static List<Opportunity> getAll()
	{
		return CMN_DAL_Search.getAll(Opportunity.SObjectType, getDefaultFields());
	}

	/**
	 * @description retrieves all Opportunities based on the AccountId
	 *
	 * @param accountId
	 *
	 * @return A list of opportunities
	 */
	@TestVisible
	private static List<Opportunity> findByAccountId(Id accountId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_ACCOUNT_ID, new Set<Id> {accountId}, getDefaultFields());
	}

	
	/**
	 * @description retrieves only one active Opportunity based on the opportunityId
	 *
	 * @param opportunityId The opportunity Id against which to query
	 *
	 * @return opportunity record
	 */
	public static Opportunity findByIdAndActiveAccount(Id opportunityId)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, OPPORTUNITY_ID, new Set<String> {String.ValueOf(opportunityId)}, getDefaultFields());
		searchParameters.searchConditions.equalsX(FIELD_STATUS, AW_DAL_Account.STATUS_ACTIVE);
		List<Opportunity> foundOpportunities = CMN_DAL_Search.getObjects(searchParameters);
		return foundOpportunities.isEmpty() ? null : foundOpportunities.iterator().next();
	}
}