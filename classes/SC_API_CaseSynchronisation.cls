/**
 * @description Base API class for the case synchronisation APIs
 *
 * @author jason.van.beukering@accenture.com vijay.jayswal@accenture.com
 *
 * @date December 2022
 */
public virtual inherited sharing class SC_API_CaseSynchronisation extends CMN_API_RestBaseInbound
{
	private CMN_UTIL_SObjectIndex contractNumberToAssocContractExtMap;
	/**
	 * @description Contract Number to Policy (Financial Account or Insurance Policy) Map
	 */
	protected Map<String, SObject> contractNumberToPolicyMap = new Map<String, SObject>();
	/**
	 * @description Client Id Number to Master Account Map
	 */
	protected Map<String, Account> identityNumberToAccountMap = new Map<String, Account>();

	/**
	 * @description Service type code to Service Type record Map
	 */
	protected CMN_UTIL_SObjectIndex serviceTypeToServiceTypeMap;
	/**
	 * @description Consultant code to consultant record map
	 */
	protected CMN_UTIL_SObjectIndex consultantCodeToConsultantMap;
	/**
	 * @description Service type code set
	 */
	protected Set<Integer> serviceTypeCodes = new Set<Integer>();
	/**
	 * @description Consultant code set
	 */
	protected Set<String> consultantCodes = new Set<String>();
	/**
	 * @description policy contract number set
	 */
	protected Set<String> contractNumbers = new Set<String>();
	/**
	 * @description Client Id Number set
	 */
	protected Set<String> identificationNumbers = new Set<String>();
	/**
	 * @description Assignable Case queue record Id
	 */
	protected Id assignableCaseQueueId;
	/**
	 * @description Non assignable Case queue record Id
	 */
	protected Id nonAssignableCaseQueueId;

	/**
	 * @description register all the object types we want to update
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType>
		{
				SC_CaseExtension__c.SObjectType,
				Case.SObjectType,
				SC_AssociatedContractExtension__c.SObjectType,
				SC_AssociatedContract__c.SObjectType,
				Task.SObjectType,
				WorkOrder.SObjectType,
				WorkOrderLineItem.SObjectType
		});
	}

	/**
	 * @description Method which is used to get case queue Ids
	 */
	protected void getCaseQueueId()
	{
		assignableCaseQueueId = SC_DAL_Group.getAssignableCasesQueue()?.Id;
		nonAssignableCaseQueueId = SC_DAL_Group.getNonAssignableCasesQueue()?.Id;
	}

	/**
	 * @description Method which is used to generate a service type To Service Map
	 */
	protected void createServiceTypeMap()
	{
		if(!serviceTypeCodes.isEmpty())
		{
			serviceTypeToServiceTypeMap =
					new CMN_UTIL_SObjectIndex(SC_DAL_ServiceType.FIELD_SERVICE_TYPE_CODE).putAll
							(
									SC_DAL_ServiceType.findByServiceTypeCodes(serviceTypeCodes)
							);
		}
	}

	/**
	 * @description This method is used to generate a Map of existing master account records mapped by Identity Number
	 *
	 * @param identificationNumbers The set of client Identity numbers extracted from the request
	 */
	protected void createMasterAccountMapByIdNumber(Set<String> identificationNumbers)
	{
		identityNumberToAccountMap = SC_DAL_Account.getMasterAccountMapByIdNumber(identificationNumbers);
	}

	/**
	 * @description This method is used to generate a Map of existing master account records mapped by Identity Number
	 *
	 * @param contractNumbers The set of contract numbers extracted from the request
	 */
	protected void createContractNumberToPolicyMap(Set<String> contractNumbers)
	{
		if(!contractNumbers.isEmpty())
		{

			contractNumberToPolicyMap = CMN_UTIL_System.convertListToSingleStringMap
					(
							SC_DAL_FinancialAccount.findByAccountNumber(contractNumbers),
							AW_DAL_FinancialAccount.FIELD_FINANCIAL_ACCOUNT_NUMBER
					);

			contractNumberToPolicyMap.putAll
					(
							CMN_UTIL_System.convertListToSingleStringMap
									(
											SC_DAL_InsurancePolicy.findByName(contractNumbers),
											AW_DAL_InsurancePolicy.FIELD_NAME
									)
					);
		}
	}

	/**
	 * @description This method is used to generate a Map of consultant code records
	 * 					mapped by consultant code
	 *
	 * @param consultantCodes The set of contract numbers extracted from the request
	 */
	protected void createConsultantCodeToConsultantMap(Set<String> consultantCodes)
	{

		consultantCodeToConsultantMap = new CMN_UTIL_SObjectIndex(CMN_DAL_SObjectDomain.FIELD_NAME).putAll(SC_DAL_ConsultantCodes.findByConsultantCode(consultantCodes));
	}

	/**
	 * @description This method is to populate the Associated Contract Extension Map
	 *
	 * @param caseExtensionIds Case Extension Ids
	 */
	protected void createContractNumberToAssocContractExtMap(Set<String> caseExtensionIds)
	{
		contractNumberToAssocContractExtMap =
				new CMN_UTIL_SObjectIndex(SC_DAL_AssociatedContractExtension.FIELD_CONTRACT_NUMBER).putAll(SC_DAL_AssociatedContractExtension.findByCaseExtension(caseExtensionIds));
	}

	/**
	 * @description The method is used to generate unique IDs to identify existing
	 * 				Associated Contract Extensions and Associated Contracts
	 *
	 * @param caseId Associated Contracts parent case Id
	 *
	 * @return a set of unique associated contract extension Ids
	 */
	protected Set<String> generateContractUniqueIds(String caseId)
	{
		Set<String> uniqueIdentifiers = new Set<String>();

		if(!contractNumberToAssocContractExtMap.values().isEmpty())
		{
			for(SC_AssociatedContractExtension__c contract : (List<SC_AssociatedContractExtension__c>)contractNumberToAssocContractExtMap.values())
			{
				uniqueIdentifiers.add(caseId + contract.RSC_PolicyNumber__c);
			}
		}
		return uniqueIdentifiers;
	}

	/**
	 * @description This method populates the associated contract details
	 * 				related to the case and associated contract extension records
	 *
	 * @param contractNumber The contract number extracted from the request
	 *
	 * @return Associated Contract Record
	 */
	protected SC_AssociatedContract__c populateAssociatedContractRecord(String contractNumber)
	{
		SObject policy = contractNumberToPolicyMap != null ? contractNumberToPolicyMap?.get(contractNumber) : null;
		SC_AssociatedContract__c associatedContract = new SC_AssociatedContract__c();
		if(policy != null && policy.getSObjectType() == FinServ__FinancialAccount__c.SObjectType)
		{
			associatedContract.SC_FinancialAccount__c = ((FinServ__FinancialAccount__c)policy)?.Id;
		}
		else if(policy != null && policy.getSObjectType() == InsurancePolicy.SObjectType)
		{
			associatedContract.SC_InsurancePolicy__c = ((InsurancePolicy)policy)?.Id;
		}
		return associatedContract;
	}

}