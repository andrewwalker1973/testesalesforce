/**
 * @description A selector class for retrieving data for templates that send communications to clients for Client Policy Print (requirements)
 *
 * @see SC_DAL_ClientPolicyPrintSelector_TEST @story ST-146321
 *
 * @author darrion.james.singh@accenture.com
 *
 * @date October 2021, March 2022
 */
public inherited sharing class SC_DAL_ClientPolicyPrintSelector extends CMN_DAL_BaseTemplateSelector
{
	@TestVisible
	private static final String SELECTOR_CLASS_NAME = SC_DAL_ClientPolicyPrintSelector.class.getName();

	/**
	 * @description Method must be implemented in child classes; it will query data and transform it into relevant structure
	 *
	 * @return A generic structure containing the document data for the template
	 */
	protected override List<CMN_DTO_SendCommunicationRequest.DTO_Document> getTemplateData()
	{
		CMN_DTO_SendCommunicationRequest.DTO_Document singleDocument = super.getTemplateData().iterator().next();

		List<CMN_DTO_SendCommunicationRequest.DTO_Document> dtoDocuments = new List<CMN_DTO_SendCommunicationRequest.DTO_Document>();

		List<InsurancePolicy> insurancePolicies = SC_DAL_InsurancePolicy.findById(new Set<Id>(this.parameterIds));
		CMN_CommunicationTemplateObjectDef__c insurancePolicyObjectDefinition = mapObjectNameToDefinition.get(SC_DAL_InsurancePolicy.OBJECT_NAME);

		for(InsurancePolicy insurancePolicy : insurancePolicies)
		{
			CMN_DTO_SendCommunicationRequest.DTO_Document document = singleDocument.clone();
			CMN_DTO_SendCommunicationRequest.DTO_Element element = createElement
					(
							insurancePolicyObjectDefinition.CMN_GroupingName__c,
							SC_DAL_InsurancePolicy.OBJECT_NAME, insurancePolicy
					);

			document.element = new List<CMN_DTO_SendCommunicationRequest.DTO_Element> {element};
			dtoDocuments.add(document);
		}

		List<FinServ__FinancialAccount__c> financialAccounts = SC_DAL_FinancialAccount.findById(new Set<Id>(this.parameterIds));
		CMN_CommunicationTemplateObjectDef__c financialAccountObjectDefinition = mapObjectNameToDefinition.get(SC_DAL_FinancialAccount.OBJECT_NAME);

		for(FinServ__FinancialAccount__c financialAccount : financialAccounts)
		{
			CMN_DTO_SendCommunicationRequest.DTO_Document document = singleDocument.clone();
			CMN_DTO_SendCommunicationRequest.DTO_Element element = createElement
					(
							financialAccountObjectDefinition.CMN_GroupingName__c,
							SC_DAL_FinancialAccount.OBJECT_NAME, financialAccount
					);

			document.element = new List<CMN_DTO_SendCommunicationRequest.DTO_Element> {element};
			dtoDocuments.add(document);
		}

		return dtoDocuments;
	}
}