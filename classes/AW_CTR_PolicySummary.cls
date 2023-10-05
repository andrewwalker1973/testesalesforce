/**
 * @description Used for Quick action to retrieve the policy summary from Mulesoft
 *
 * @see AW_CTR_PolicySummary_TEST
 * @see AW_API_RestOutboundPolicySummary
 *
 * @author Thiru
 *
 * @date June 2021
 */
public inherited sharing class AW_CTR_PolicySummary
{
	/**
	 * @description Retrieves response from callqueue
	 *
	 * @param recordId The id of a contract, either a Financial Account or Insurance policy
	 *
	 * @return A string containing the policy document
	 */
	@AuraEnabled
	public static Map<String,Object> getPolicySummary(Id recordId)
	{
        String contractNumber;
        Map<String,Object> returnValues = new Map<String,Object>();
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RestOutboundPolicySummary.SERVICE_NAME, recordId);
		List<CMN_API_HttpBase> handlers = CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem});
		AW_API_RestOutboundPolicySummary policySummaryHandler = (AW_API_RestOutboundPolicySummary)handlers.iterator().next();

		if(!policySummaryHandler.callResult.completed)
		{
			List<String> errors = policySummaryHandler.callResult.errors;
			String errorMessage = String.join(errors, CMN_UTIL_String.LF);
			throw new CMN_API_HttpBaseOutbound.HttpOutboundRequestException(errorMessage);

		}
        SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(queueItem.CMN_TriggeringObjectId__c);
        
        if(objectType == FinServ__FinancialAccount__c.SObjectType)
        {
            FinServ__FinancialAccount__c financialAccount = AW_DAL_FinancialAccount.findById(queueItem.CMN_TriggeringObjectId__c);
            contractNumber = financialAccount?.FinServ__FinancialAccountNumber__c;
        }
        else if(objectType == InsurancePolicy.SObjectType)
        {
            InsurancePolicy policy = AW_DAL_InsurancePolicy.findByInsurancePolicyId(queueItem.CMN_TriggeringObjectId__c);
            contractNumber = policy?.Name;
        }
        
		returnValues.put('fileByteStream',((AW_API_RestOutboundPolicySummary.DTO_Response)policySummaryHandler.baseResponseDTO).fileByteStream);
        returnValues.put('contractNumbers',contractNumber);
        
		return returnValues;
	}
}