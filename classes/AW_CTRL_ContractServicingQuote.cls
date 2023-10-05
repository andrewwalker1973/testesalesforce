/**
 * @description This class is the apex controller for Lightning Component AW_CMP_ContractServicingQuote
 *
 * @see AW_CTRL_ContractServicingQuote_TEST
 *
 * @author jason.van.beukering@accenture.com pavan.thammali@liberty.co.za
 *
 * @date August 2021, June 2022
 */
public inherited sharing class AW_CTRL_ContractServicingQuote
{
	private static final String FINANCIAL_ACCOUNT = 'Financial Account';
	private static final String INSURANCE_POLICY = 'Insurance Policy';

	/**
	 * @description This aura enabled method will fetch accountId using the opportunity ID
	 *
	 * @param opportunityID is used to initiate the process
	 *
	 * @return String
	 */
	@AuraEnabled(Cacheable=true)
	public static Id fetchAccountId(Id opportunityID)
	{
		return AW_DAL_Opportunity.findByIdAndActiveAccount(opportunityID).AccountId;
	}
	/**
	 * @description This aura enabled method will fetch field labels
	 *
	 * @return A map of field name and field label
	 */
	@AuraEnabled(Cacheable=true)
	public static Map<String, String> getLabels()
	{
		// Get the type and the Schema of the sObject passed in the parameter
		Map<String, Schema.SObjectField> fieldMap = CMN_UTIL_SObjectDescribe.getDescribe(Quote.SObjectType).getFieldsMap();
		//Map the API Name and the Label for each field
		Map<String, String> labelMap = new Map<String, String>();
		for(String fieldName : fieldMap.keySet())
		{
			//fieldName is the API Name and fieldLabel is the Label of the field
			String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
			labelMap.put(fieldName, fieldLabel);
		}
		return labelMap;
	}
	/**
	 * @description This aura enabled method will fetch financial accounts and insurance policy records using the account ID
	 *
	 * @param accountId is used to filter Insurance policies and financial accounts
	 *
	 * @return List of items wrapped in a DTO
	 */
	@AuraEnabled(Cacheable=true)
	public static DTO_ServicingQuoteList getServicingContractWrapper(String accountId)
	{
		DTO_ServicingQuoteList contractList = new DTO_ServicingQuoteList();
		List<DTO_ServicingQuote> servicingQuote = new List<DTO_ServicingQuote>();
		DTO_ConsultantCode consultantCode;
		List<FinServ__FinancialAccount__c> financialAccountList = AW_DAL_FinancialAccount.findInForceByAccountId(accountId);
		List<InsurancePolicy> insurancePolicyList = AW_DAL_InsurancePolicy.findInForceByAccountId(accountId);
		for(FinServ__FinancialAccount__c f : financialAccountList)
		{
			consultantCode = new DTO_ConsultantCode (f.FinServ__PrimaryOwner__r.Owner.AW_ConsultantCode__c, f.FinServ__PrimaryOwner__r.Owner.Id);
			servicingQuote.add(new DTO_ServicingQuote(f.AW_ProductCategory__c, f.Name, f.FinServ__FinancialAccountNumber__c, f.FinServ__Premium__c, FINANCIAL_ACCOUNT));
		}

		for(InsurancePolicy i : insurancePolicyList)
		{
			consultantCode = new DTO_ConsultantCode (i.NameInsured.Owner.AW_ConsultantCode__c, i.NameInsured.Owner.Id);
			servicingQuote.add(new DTO_ServicingQuote(i.AW_PolicyCategory__c, i.PolicyName, i.Name, i.PremiumAmount, INSURANCE_POLICY));
		}
		contractList.code = consultantCode;
		contractList.quoteList = servicingQuote;
		return contractList;
	}
	/**
	 * @description This is the wrapper class to declare list of financial account and insurance policy data
	 */
	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public class DTO_ServicingQuoteList
	{
		@AuraEnabled
		public List<DTO_ServicingQuote> quoteList;
		@AuraEnabled
		public DTO_ConsultantCode code;
	}
	/**
	 * @description This is the wrapper class to declare financial account and insurance policy data
	 */
	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public class DTO_ServicingQuote
	{
		@AuraEnabled
		public String productCategory;
		@AuraEnabled
		public String financialAccountNumber;
		@AuraEnabled
		public String name;
		@AuraEnabled
		public Decimal premiumAmount;
		@AuraEnabled
		public String financialEntity;
		/**
		 * @description This is the constructor class to declare Servicing quote details
		 *
		 * @param productCategory of the insurance policy/Financial account that need to showcase in UI
		 * @param financialAccountNumber of the insurance policy/Financial account that need to showcase in UI
		 * @param name of the insurance policy/Financial account that need to showcase in UI
		 * @param premiumAmount of the insurance policy/Financial account that need to showcase in UI
		 * @param financialEntity
		 */
		public DTO_ServicingQuote(String productCategory, String financialAccountNumber, String name, Decimal premiumAmount, String financialEntity)
		{
			this.productCategory = productCategory;
			this.financialAccountNumber = financialAccountNumber;
			this.name = name;
			this.premiumAmount = premiumAmount;
			this.financialEntity = financialEntity;
		}
	}
	/**
	 * @description This is the wrapper class to declare consultant code and user details
	 */
	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public class DTO_ConsultantCode
	{
		@AuraEnabled
		public String consultantCode;
		@AuraEnabled
		public String userId;

		/**
		 * @description This is the constructor class to declare consultant code and user details
		 *
		 * @param consultantCode is used in BPO Canvas Component to get quote details
		 * @param userId is used in BPO Canvas Component to get quote details
		 */
		public DTO_ConsultantCode(String consultantCode, String userId)
		{
			this.consultantCode = consultantCode;
			this.userId = userId;
		}
	}
}