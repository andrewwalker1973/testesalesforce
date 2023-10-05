/**
 * @description Utility controller to store all the shared codes for contract sync and get contracts
 *
 * @author jayanth.kumar.s@accenture.com, jason.van.beukering@accenture.com
 *
 * @date February 2023, May 2023
 */
public inherited sharing class SC_UTIL_Contracts
{
	private static final Integer MAXIMUM_NUMBER_OF_CACHE_KEYS = 10;

	/**
	 * @description Constant to store error message for out of force products
	 */
	public static final String ERROR_OUT_OF_FORCE = 'Unable to process change for this policy, as the policy is Out of Force.';
	/**
	 * @description message to log when the roles are not processed
	 */
	public static final String ERROR_ROLE_NOT_PROCESSED = 'Role: {0} not added because First Name or Last name not found.';
	/**
	 * @description stores the Payee role for the contract
	 */
	public static final String ROLE_PAYEE = 'Payee';
	/**
	 * @description stores the In Force status of the contract
	 */
	public static final String STATUS_IN_FORCE = 'IN FORCE';
	/**
	 * @description stores the Out Of Force status of the contract
	 */
	public static final String STATUS_OUT_OF_FORCE = 'Out of Force';
	/**
	 * @description Constant used to identify the consultant role of the Financial Account
	 */
	public static final String ROLE_LIFE_ASSURED = 'Life Assured';

	/**
	 * @description method used to delete all inactive roles for financial account and insurance policies
	 *
	 * @param financialAccountIds set of financialAccount Ids
	 * @param insurancePolicyIds set of Insurance policy Ids
	 */
	public static void deleteInactiveRoles(Set<Id> financialAccountIds, Set<Id> insurancePolicyIds)
	{
		Boolean mustDeletePolicies = !insurancePolicyIds.isEmpty();
		Boolean mustDeleteFinancialAccounts = !financialAccountIds.isEmpty();

		if(mustDeletePolicies)
		{
			CMN_DAL_SObjectDomain.deleteDBObjects(SC_DAL_InsurancePolicyParticipant.findInactiveByParentIds(insurancePolicyIds));
		}

		if(mustDeleteFinancialAccounts)
		{
			CMN_DAL_SObjectDomain.deleteDBObjects(SC_DAL_FinancialAccountRole.findInactiveByParentIds(financialAccountIds));
		}
	}

	/**
	 * @description This method is used to get Map of Contract Number and Existing Financial Account record or Insurance Policy among the request DTO
	 *
	 * @param contractNumbers The set of all contract numbers received with the request DTO
	 *
	 * @return Map of the Contract Number to the Existing Financial Account or Insurance Policy record
	 */
	public static Map<String, SObject> findAllContractsByNumber(Set<String> contractNumbers)
	{
		List<FinServ__FinancialAccount__c> existingFinancialAccounts = SC_DAL_FinancialAccount.findByAccountNumber(contractNumbers);
		List<InsurancePolicy> existingInsurancePolicies = SC_DAL_InsurancePolicy.findByName(contractNumbers);

		Map<String, SObject> contractNumberToPolicyMap =
				CMN_UTIL_System.convertListToSingleStringMap
						(
								existingFinancialAccounts,
								AW_DAL_FinancialAccount.FIELD_FINANCIAL_ACCOUNT_NUMBER
						);

		contractNumberToPolicyMap.putAll(CMN_UTIL_System.convertListToSingleStringMap(existingInsurancePolicies, AW_DAL_InsurancePolicy.FIELD_NAME));

		return contractNumberToPolicyMap;
	}

	/**
	 * @description Will query cache to see if any cases exist for the current account that have cases with missing
	 * associated contracts; i.e. when Case's where synchronised into Salesforce, the system was unable to find the policy
	 * in Salesforce. This information was then cached and a callout was made to get the latest policy information for
	 * the client.
	 *
	 * This method will add the missing policies to the case
	 *
	 * @param accountIds The accounts to check for cases with missing contracts
	 */
	public static void addMissingAssociatedContracts(Set<Id> accountIds)
	{
		SC_UTIL_Contracts.MissingContractsCacheHandler cacheHandler = new SC_UTIL_Contracts.MissingContractsCacheHandler();
		Map<Id, Map<Id, Set<String>>> missingContractsMap = cacheHandler.retrieveFromCache(accountIds);

		if(!missingContractsMap.isEmpty())
		{
			Set<String> allContractNumbers = new Set<String>();
			Set<Id> allCaseIds = new Set<Id>();

			for(Id accountId : missingContractsMap.keySet())
			{
				Map<Id, Set<String>> contractsByCaseMap = missingContractsMap.get(accountId);
				allCaseIds.addAll(contractsByCaseMap.keySet());

				for(Set<String> contractNumbers : contractsByCaseMap.values())
				{
					allContractNumbers.addAll(contractNumbers);
				}
			}

			Map<String, SObject> foundContractsMap = SC_UTIL_Contracts.findAllContractsByNumber(CMN_UTIL_System.trimSet(allContractNumbers));

			if(!foundContractsMap.isEmpty())
			{
				insertMissingAssociatedContracts(missingContractsMap, foundContractsMap, SC_DAL_AssociatedContract.findByCaseId(allCaseIds));
			}
		}
	}

	/**
	 * @description Will insert missing associated contract records on cases if method able to find policy
	 *
	 * @param missingContractsMap Map containing all the cases for accounts with missing contracts
	 * @param foundContractsMap All contracts found by number (for missing numbers)
	 * @param foundAssociatedContracts All existing associated contracts for the cases found, to be used to avoid creating duplicates
	 */
	@SuppressWarnings('PMD.CognitiveComplexity')
	private static void insertMissingAssociatedContracts
			(Map<Id, Map<Id, Set<String>>> missingContractsMap, Map<String, SObject> foundContractsMap, List<SC_AssociatedContract__c> foundAssociatedContracts)
	{
		Map<Id, Set<String>> existingContractsPerCaseMap = new Map<Id, Set<String>>();

		for(SC_AssociatedContract__c foundAssociatedContract : foundAssociatedContracts)
		{
			Set<String> existingContractNumbers = existingContractsPerCaseMap.get(foundAssociatedContract.SC_Case__c);

			if(existingContractNumbers == null)
			{
				existingContractNumbers = new Set<String>();
				existingContractsPerCaseMap.put(foundAssociatedContract.SC_Case__c, existingContractNumbers);
			}

			existingContractNumbers.add(foundAssociatedContract.SC_PolicyNumber__c);
		}

		List<SC_AssociatedContract__c> newAssociatedContracts = new List<SC_AssociatedContract__c>();

		for(Map<Id, Set<String>> contractsByCaseMap : missingContractsMap.values())
		{
			for(Id caseId : contractsByCaseMap.keySet())
			{
				Set<String> existingContractNumbers = existingContractsPerCaseMap.get(caseId);
				Set<String> missingContractNumbers = contractsByCaseMap.get(caseId);

				//Remove any items that already exist for the case as we don't want to create duplicates
				if(existingContractNumbers != null)
				{
					missingContractNumbers.removeAll(existingContractNumbers);
				}

				for(String contractNumber : missingContractNumbers)
				{
					SObject foundContract = foundContractsMap.get(contractNumber);

					if(foundContract != null)
					{
						SC_AssociatedContract__c newAssociatedContract = new SC_AssociatedContract__c();

						newAssociatedContract.SC_Case__c = caseId;

						if(foundContract.getSObjectType() == FinServ__FinancialAccount__c.SObjectType)
						{
							newAssociatedContract.SC_FinancialAccount__c = foundContract.Id;
						}
						else
						{
							newAssociatedContract.SC_InsurancePolicy__c = foundContract.Id;
						}

						newAssociatedContracts.add(newAssociatedContract);
					}
				}
			}
		}

		CMN_DAL_SObjectDomain.insertDBObjects(newAssociatedContracts);
	}

	/**
	 * @description Use this class to persist missing policy numbers to a cache to be used later to link the policies to a case
	 */
	public class MissingContractsCacheHandler
	{
		//The time the cache should persist for in seconds
		private final Integer cacheExpirySeconds = 600; //10 minutes
		private final String cacheName = 'MissingPolicyCache';
		/**
		 * @description A Map of <AccountId, Map<CaseId, Set<ContractNumber>>
		 */
		private final Map<Id, Map<Id, Set<String>>> missingContractsMap = new Map<Id, Map<Id, Set<String>>>();

		/**
		 * @description Will add the missing contract numbers to inner map
		 *
		 * @param accountId The account id to which the case belongs
		 * @param caseId The Id of the case
		 * @param contractNumbers The missing policy numbers
		 */
		public void addMissingContracts(Id accountId, Id caseId, Set<String> contractNumbers)
		{
			Map<Id, Set<String>> contractsByCaseMap = missingContractsMap.get(accountId);

			if(contractsByCaseMap == null)
			{
				contractsByCaseMap = new Map<Id, Set<String>>();
				missingContractsMap.put(accountId, contractsByCaseMap);
			}

			Set<String> missingContracts = contractsByCaseMap.get(caseId);

			if(missingContracts == null)
			{
				missingContracts = new Set<String>();
				contractsByCaseMap.put(caseId, missingContracts);
			}

			missingContracts.addAll(contractNumbers);
		}

		/**
		 * @description Will persist the missing contracts map to the Org cache
		 */
		public void persistToCache()
		{
			for(Id accountId : missingContractsMap.keySet())
			{
				Map<Id, Set<String>> contractsByCaseMap = missingContractsMap.get(accountId);
				Cache.Org.put(cacheName + accountId, contractsByCaseMap, cacheExpirySeconds);
			}
		}

		/**
		 * @description Will retrieve the missing contracts map for a given account ids from the cache
		 *
		 * @param accountIds The accounts for which to retrieve the cache
		 *
		 * @return A Map of <AccountId, Map<CaseId, Set<ContractNumber>>
		 */
		public Map<Id, Map<Id, Set<String>>> retrieveFromCache(Set<Id> accountIds)
		{
			missingContractsMap.clear();

			//NB: Due to limitations listed here, we need to split keys into batches of 10; https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_cache_exceptions.htm
			List<List<Object>> splitAccountIdLists = CMN_UTIL_System.splitObjects(CMN_UTIL_System.setToList(CMN_UTIL_System.trimSet(accountIds)), MAXIMUM_NUMBER_OF_CACHE_KEYS);

			for(List<Object> splitAccountIds : splitAccountIdLists)
			{
				Set<String> keys = new Set<String>();

				for(Object accountId : splitAccountIds)
				{
					keys.add(cacheName + (Id)accountId);
				}

				Map<String, Object> foundItemsMap = Cache.Org.get(keys);

				if(foundItemsMap != null)
				{
					for(String key : foundItemsMap.keySet())
					{
						Map<Id, Set<String>> contractsByCaseMap = (Map<Id, Set<String>>)foundItemsMap.get(key);

						if(contractsByCaseMap != null)
						{
							Id accountId = key.remove(cacheName);
							missingContractsMap.put(accountId, contractsByCaseMap);
						}
					}
				}
			}

			return missingContractsMap;
		}
	}
}