/**
 * @description This class is used to handle Contracts linking to a case
 *
 * @see RSC_CTRL_LinkContractsToCase_TEST @story ST-168884
 *
 * @author rajpal.singh@accenture.com jayanth.kumar.s@accenture.com m.sudhakar.rokde@accenture.com jason.van.beukering@accenture.co
 *
 * @date August 2021, August 2022
 */
@SuppressWarnings('PMD.CognitiveComplexity')
public inherited sharing class RSC_CTRL_LinkContractsToCase
{
	/**
	 * @description This method is use to get the List of Associated Contracts with the particular ParenRecordId
	 *
	 * @param parentRecordId The record to which Contracts to be linked
	 * @param clientId This is Account ID
	 *
	 * @return A list of ContractsWrapperClass
	 */
	@AuraEnabled
	@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
	public static DTO_AssociatedContracts getContractsFromAccount(Id parentRecordId, Id clientId)
	{
		List<SC_AssociatedContract__c> associatedContracts = SC_DAL_AssociatedContract.findByParent(parentRecordId);
		Set<Id> associatedFinanceAccountIdSet = CMN_UTIL_System.extractListIds(associatedContracts, SC_DAL_AssociatedContract.FIELD_FINANCIAL_ACCOUNT);
		Set<Id> associatedInsurancePolicyIdSet = CMN_UTIL_System.extractListIds(associatedContracts, SC_DAL_AssociatedContract.FIELD_INSURANCE_POLICY);

		List<FinServ__FinancialAccount__c> foundFinancialAccounts = new List<FinServ__FinancialAccount__c>();
		List<InsurancePolicy> foundInsurancePolicies = new List<InsurancePolicy>();

		if(String.isBlank(clientId))
		{
			Case caseRecord = SC_DAL_Case.findById(parentRecordId);
			clientId = caseRecord.AccountId;
		}

		foundFinancialAccounts = SC_DAL_FinancialAccount.findByMasterAccountId(clientId);
		foundInsurancePolicies = SC_DAL_InsurancePolicy.findByMasterAccountId(clientId);

		Set<Id> foundFinancialAccountIds = CMN_UTIL_System.extractListIds(foundFinancialAccounts);
		// Retain only those Ids found from found financial accounts
		associatedFinanceAccountIdSet.retainAll(foundFinancialAccountIds);

		List<DTO_Contracts> dtoContracts = new List<DTO_Contracts>();
		for(FinServ__FinancialAccount__c foundFinancialAccount : foundFinancialAccounts)
		{
			DTO_Contracts dtoContract = new DTO_Contracts();
			dtoContract.commencementDate = foundFinancialAccount.FinServ__OpenDate__c;
			dtoContract.id = foundFinancialAccount.Id;
			dtoContract.policyNumber = foundFinancialAccount.FinServ__FinancialAccountNumber__c;
			dtoContract.productType = foundFinancialAccount.FinServ__FinancialAccountType__c;
			dtoContract.status = foundFinancialAccount.FinServ__Status__c;
			dtoContract.type = Label.RSC_InvestmentProduct;
			dtoContract.policyName = foundFinancialAccount.Name;
			dtoContract.premium = foundFinancialAccount.FinServ__Premium__c != null ? foundFinancialAccount.FinServ__Premium__c : 0.00;
			dtoContracts.add(dtoContract);
		}

		Set<Id> foundInsurancePolicyIds = CMN_UTIL_System.extractListIds(foundInsurancePolicies);
		// Retain only those Ids found from found financial accounts
		associatedInsurancePolicyIdSet.retainAll(foundInsurancePolicyIds);

		for(InsurancePolicy foundInsurancePolicy : foundInsurancePolicies)
		{
			DTO_Contracts dtoContract = new DTO_Contracts();

			dtoContract.commencementDate = foundInsurancePolicy.AW_CommencementDate__c;
			dtoContract.id = foundInsurancePolicy.Id;
			dtoContract.policyNumber = foundInsurancePolicy.Name;
			dtoContract.productType = foundInsurancePolicy.PolicyType;
			dtoContract.status = foundInsurancePolicy.Status;
			dtoContract.type = Label.RSC_RiskProduct;
			dtoContract.premium = foundInsurancePolicy.PremiumAmount != null ? foundInsurancePolicy.PremiumAmount : 0.00;
			dtoContract.policyName = foundInsurancePolicy.PolicyName;
			dtoContract.cessionaryName = foundInsurancePolicy.CMN_CessionaryName__c;
			dtoContract.cessionaryType = foundInsurancePolicy.CMN_CessionaryType__c;

			dtoContracts.add(dtoContract);
		}

		DTO_AssociatedContracts dtoAssociatedContracts = new DTO_AssociatedContracts();
		dtoAssociatedContracts.dtoContracts = dtoContracts;

		List<Id> selectedPolicyIds = new List<Id>(associatedFinanceAccountIdSet);
		selectedPolicyIds.addAll(associatedInsurancePolicyIdSet);
		dtoAssociatedContracts.selectedPolicyIds = selectedPolicyIds;

		return dtoAssociatedContracts;
	}

	/**
	 * @description Will retrieve all Associated Contracts of the case record
	 *
	 * @param parentRecordId The Id of the record to which the Associated Contracts are linked
	 *
	 * @return A list of associated contracts
	 */
	@AuraEnabled(Cacheable=true)
	public static List<SC_AssociatedContract__c> getContractFromCase(Id parentRecordId)
	{
		List<SC_AssociatedContract__c> associatedContracts = SC_DAL_AssociatedContract.findByParent(parentRecordId);
		return associatedContracts;
	}

	/**
	 * @description This will update all the Contracts of the case record
	 *
	 * @param parentId The Id of the record to which the Associated Contracts are linked
	 * @param selectedPolicyIds The Id of selected Associated Contracts
	 */
	@AuraEnabled
	public static void updateContracts(String parentId, List<Id> selectedPolicyIds)
	{
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType> {SC_AssociatedContract__c.SObjectType});

		List<SC_AssociatedContract__c> associatedContracts = SC_DAL_AssociatedContract.findByParent(parentId);
		Set<Id> associatedFinanceAccountIdSet = CMN_UTIL_System.extractListIds(associatedContracts, SC_DAL_AssociatedContract.FIELD_FINANCIAL_ACCOUNT, true);
		Set<Id> associatedInsurancePolicyIdSet = CMN_UTIL_System.extractListIds(associatedContracts, SC_DAL_AssociatedContract.FIELD_INSURANCE_POLICY, true);

		Set<Id> allExistingPolicies = new Set<Id>(associatedFinanceAccountIdSet);
		allExistingPolicies.addAll(associatedInsurancePolicyIdSet);

		Set<Id> policiesToBeDeleted = new Set<Id>();
		Set<Id> policiesToBeAdded = new Set<Id>();

		if(selectedPolicyIds.isEmpty())
		{
			unitOfWork.registerDeleted(associatedContracts);
		}
		else
		{
			for(Id selectedPolicyId : selectedPolicyIds)
			{
				if(!allExistingPolicies.contains(selectedPolicyId))
				{
					policiesToBeAdded.add(selectedPolicyId);
				}
			}

			for(Id existingPolicy : allExistingPolicies)
			{
				if(!selectedPolicyIds.contains(existingPolicy))
				{
					policiesToBeDeleted.add(existingPolicy);
				}
			}

			if(!policiesToBeDeleted.isEmpty())
			{
				List<SC_AssociatedContract__c> contractsToBeDeleted = new List<SC_AssociatedContract__c>();
				for(Id policyToBeDeleted : policiesToBeDeleted)
				{
					contractsToBeDeleted.addAll((List<SC_AssociatedContract__c>)CMN_UTIL_System.findWhereIn(
							associatedContracts, SC_DAL_AssociatedContract.FIELD_FINANCIAL_ACCOUNT, new List<Id>(policiesToBeDeleted)));
					contractsToBeDeleted.addAll((List<SC_AssociatedContract__c>)CMN_UTIL_System.findWhereIn(
							associatedContracts, SC_DAL_AssociatedContract.FIELD_INSURANCE_POLICY, new List<Id>(policiesToBeDeleted)));
				}
				unitOfWork.registerDeleted(contractsToBeDeleted);
			}

			if(!policiesToBeAdded.isEmpty())
			{
				unitOfWork.registerNew(RSC_DAL_TestDataFactory.createNewContractsForCase(parentId, new List<Id>(policiesToBeAdded)));
			}
		}

		unitOfWork.commitWork();
	}

	/**
	 * @description This wrapper class is used to store the Contract details
	 */
	public class DTO_Contracts
	{
		/**
		 * @description stores the id of Insurance Policy or Financial Account Record
		 */
		@AuraEnabled
		public String id;
		/**
		 * @description stores policy number of Insurance Policy or account number of  Financial Account Record
		 */
		@AuraEnabled
		public String policyNumber;
		/**
		 * @description stores policy type of Insurance Policy or  Account type of Financial Account Record
		 */
		@AuraEnabled
		public String productType;
		/**
		 * @description stores the label of Insurance Policy or account number of  Financial Account Record
		 */
		@AuraEnabled
		public String type;
		/**
		 * @description stores  the  commencement Date Of Insurance Policy or Open Date of  Financial Account Record
		 */
		@AuraEnabled
		public Date commencementDate;
		/**
		 * @description stores  the status of Insurance Policy and  Financial Account Record
		 */
		@AuraEnabled
		public String status;
		/**
		 * @description stores  the premium of Insurance Policy or  Financial Account Record
		 */
		@AuraEnabled
		public Decimal premium;
		/**
		 * @description stores  the policy Name of Insurance Policy or  Financial Account Record
		 */
		@AuraEnabled
		public String policyName;
		/**
		 * @description stores the cessionary Name  of Insurance Policy
		 */
		@AuraEnabled
		public String cessionaryName;
		/**
		 * @description stores the cessionary Type  of Insurance Policy
		 */
		@AuraEnabled
		public String cessionaryType;
	}
	/**
	 * @description This wrapper class is used to store the list of Contract list details
	 */
	public class DTO_AssociatedContracts
	{
		/**
		 * @description stores the dto of Contracts
		 */
		@AuraEnabled
		public List<DTO_Contracts> dtoContracts;
		/**
		 * @description stores the selected policy record Ids
		 */
		@AuraEnabled
		public List<Id> selectedPolicyIds;
	}
}