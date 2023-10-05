/**
 * @description Public class to return the records of Document Checklist Items
 *
 * @author Futureform
 *
 * @date January 2023
 */

public inherited sharing class SLC_DAL_DocumentChecklistItem {

    private static final String FIELD_DOCUMENT_TYPE_LABEL = 'DocumentChecklistItem.DocumentType.MasterLabel';
    private static final String FIELD_DOCUMENT_TYPE_CODE = 'DocumentChecklistItem.DocumentType.Description';
    private static final String EXTERNAL_DOCUMENT_TYPE = 'External';

    public static List<DocumentChecklistItem> findByParentAndDocType(Id parentRecordId, List<String> documentTypes) {
        return findByParentsAndDocType(new Set<String> {parentRecordId}, documentTypes);
    }

    public static List<DocumentChecklistItem> findByParentsAndDocType(Set<String> parentRecordIds, List<String> documentTypes)
    {
        if(parentRecordIds.isEmpty() || documentTypes.isEmpty())
        {
            return new List<SObject>();
        }

        CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(
                SC_DAL_DocumentChecklistItem.OBJECT_NAME,
                SC_DAL_DocumentChecklistItem.FIELD_PARENT_ID,
                parentRecordIds,
                getDefaultFields()
        );
        CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

        andCondition.add(new CMN_SOQL_Query.SetCondition(FIELD_DOCUMENT_TYPE_CODE, CMN_SOQL_Query.Operator.INX, documentTypes));
        searchParameters.searchConditions.add(andCondition);

        return CMN_DAL_Search.getObjects(searchParameters);
    }

	public static List<DocumentChecklistItem> getExternalOnboardingDocs(Id accountId) {
		List<Opportunity> opportunities = SLC_DAL_Opportunity.findByParentAccounts(accountId);

		Map<String, SLC_Document_Type_Mapping__mdt> onboardingDocumentTypes = getOnboardingDocumentTypes();

		List<DocumentChecklistItem> documentChecklistItems = SLC_DAL_DocumentChecklistItem.findByParentsAndDocType(
				CMN_UTIL_System.extractSetValues(opportunities, SLC_DAL_Opportunity.OPPORTUNITY_ID),
				(List<String>) CMN_UTIL_Set.setToList(onboardingDocumentTypes.keySet())
		);
		List<DocumentChecklistItem> filteredDocumentChecklistItems = new List<DocumentChecklistItem>();

		for (DocumentChecklistItem documentChecklistItem: documentChecklistItems) {
			if (!onboardingDocumentTypes.get(documentChecklistItem.DocumentType.Description).Internal_Only__c
					&& (onboardingDocumentTypes.get(documentChecklistItem.DocumentType.Description).Onboarding_Accessibility__c == EXTERNAL_DOCUMENT_TYPE
						|| documentChecklistItem.AW_Vaulted__c)) {
				filteredDocumentChecklistItems.add(documentChecklistItem);
			}
		}

		return filteredDocumentChecklistItems;
	}
    
    @AuraEnabled(Cacheable=true)
    public static Map<String, SLC_Document_Type_Mapping__mdt> getOnboardingDocumentTypes()
    {
		List<SLC_Document_Type_Mapping__mdt> onboardingCodes = [
                SELECT
                        Id, Document_Code__c, Onboarding_Accessibility__c, Internal_Only__c
                FROM SLC_Document_Type_Mapping__mdt
                WHERE Onboarding_Accessibility__c != NULL
        ];

		Map<String, SLC_Document_Type_Mapping__mdt> codeToType = new Map<String, SLC_Document_Type_Mapping__mdt>();

		for (SLC_Document_Type_Mapping__mdt onboardingCode: onboardingCodes) {
			codeToType.put(onboardingCode.Document_Code__c, onboardingCode);
		}

		return codeToType;
    }

    public static Set<String> getDefaultFields()
    {
        Set<String> defaultFields = new Set<String>
        {
                FIELD_DOCUMENT_TYPE_CODE
        };

        defaultFields.addAll(SC_DAL_DocumentChecklistItem.getDefaultFields());

        return defaultFields;
    }
}