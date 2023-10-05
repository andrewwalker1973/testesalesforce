public with sharing class SLSC_UTIL_InvestorsMulesoftData {

    public static final String INVESTOR_ACCOUNT_TITLE_METADATA = 'Investor Account';
    public static final String INVESTOR_BANK_DETAILS_TITLE_METADATA = 'Investor BankDetails';
    public static final String INVESTOR_ONLINE_DETAILS_TITLE_METADATA = 'Investor OnlineDetails';
    public static final String INVESTOR_SSO_TITLE_METADATA = 'Investor SSO';
    public static final String RESPONSE_ONLINE_KEY = 'Online';
    public static final String RESPONSE_SSO_KEY = 'SSO';

    /**
    * @description Generate fields details according to metadata mapping for Financial Holding
    *
    * @param jsonBody received from REST Outbound API Call
    *
    * @return List of FieldDetails
    */
    public static List<Object> parseHoldingJson(String jsonBody) {
        Map<String, Object> jsonDeserialized = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
        Map<String, Object> objectMap = flatMap(jsonDeserialized);
        List<SLSC_Mulesoft_Field_Mapping__mdt> mappings = SLSC_UTIL_MulesoftFieldMapping.getMulesoftFieldMapping(INVESTOR_ACCOUNT_TITLE_METADATA);

        return getFieldDetailsWithLabels(objectMap, mappings);
    }

    /**
    * @description Generate fields details according to metadata mapping for Financial Holding
    *
    * @param jsonBody received from REST Outbound API Call
    *
    * @return List of holdings with fields
    */
    public static List<Object> parseHoldingsJson(String jsonBody) {
        List<Object> jsonDeserialized = (List<Object>) JSON.deserializeUntyped(jsonBody);
        List<SLSC_Mulesoft_Field_Mapping__mdt> mappings = SLSC_UTIL_MulesoftFieldMapping.getMulesoftFieldMapping(INVESTOR_ACCOUNT_TITLE_METADATA);

        List<Object> result = new List<Object>();
        for (Object obj : jsonDeserialized) {
            Map<String, Object> objectMap = (Map<String, Object>) obj;
            Map<String, Object> flattedMap = flatMap(objectMap);
            result.add(getFieldForTableWithLabels(flattedMap, mappings));
        }
        return result;
    }

    /**
    * @description Generate fields details according to metadata mapping for bank details
    *
    * @param jsonBody received from REST Outbound API Call
    *
    * @return List of bank details with fields
    */
    public static List<Object> parseBankDetailsJson(String jsonBody) {
        List<Object> jsonDeserialized = (List<Object>) JSON.deserializeUntyped(jsonBody);
        List<SLSC_Mulesoft_Field_Mapping__mdt> mappings = SLSC_UTIL_MulesoftFieldMapping.getMulesoftFieldMapping(INVESTOR_BANK_DETAILS_TITLE_METADATA);

        List<Object> result = new List<Object>();
        for (Object obj : jsonDeserialized) {
            Map<String, Object> objectMap = (Map<String, Object>) obj;
            result.add(getFieldForTableWithLabels(objectMap, mappings));
        }
        return result;
    }

    /**
    * @description Generate fields details according to metadata mapping for online details
    *
    * @param jsonBody received from REST Outbound API Call
    *
    * @return List of FieldDetails
    */
    public static List<Object> parseOnlineDetailsJson(String jsonBody) {
        Map<String, Object> jsonDeserialized = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
        Map<String, Object> onlineMap = (Map<String, Object>) jsonDeserialized.get(RESPONSE_ONLINE_KEY);
        List<SLSC_Mulesoft_Field_Mapping__mdt> mappings = SLSC_UTIL_MulesoftFieldMapping.getMulesoftFieldMapping(INVESTOR_ONLINE_DETAILS_TITLE_METADATA);

        return getFieldDetailsWithLabels(onlineMap, mappings);
    }

    /**
    * @description Generate fields details according to metadata mapping for sso details
    *
    * @param jsonBody received from REST Outbound API Call
    *
    * @return List of FieldDetails
    */
    public static List<Object> parseSsoJson(String jsonBody) {
        Map<String, Object> jsonDeserialized = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
        Map<String, Object> ssoMap = (Map<String, Object>) jsonDeserialized.get(RESPONSE_SSO_KEY);
        List<SLSC_Mulesoft_Field_Mapping__mdt> mappings = SLSC_UTIL_MulesoftFieldMapping.getMulesoftFieldMapping(INVESTOR_SSO_TITLE_METADATA);
        return getFieldDetailsWithLabels(ssoMap, mappings);
    }

    /**
    * @description This method returns a new Map formed by applying a given function to each element of the array, and then flattening the result by one level
    * Converts nested object into one dimensional Map with keys of nested objects transformed into {parentKey.childKey} view
    *
    * @param inputMap Map that can have nested objects
    *
    * @return Returns plain Map
    */
    public static Map<String, Object> flatMap(Map<String, Object> inputMap) {
        Map<String, Object> resultMap = new Map<String, Object>();
        for (String parentKey : inputMap.keySet()) {
            if (inputMap.get(parentKey) instanceof Map<String, Object>) {
                Map<String, Object> childMap = (Map<String, Object>)inputMap.get(parentKey);
                for (String childKey : childMap.keySet()) {
                    resultMap.put(parentKey + '.' + childKey, childMap.get(childKey));
                }
            } else {
                resultMap.put(parentKey, inputMap.get(parentKey));
            }
        }
        return resultMap;
    }

    /**
    * @description Converts json response into List of FieldDetails according to custom metadata
    *
    * @param deserializedJson deserialized JSON
    * @param mappings list of custom metadata records
    *
    * @return List of FieldDetails
    */
    @TestVisible
    private static List<Object> getFieldDetailsWithLabels(Map<String, Object> deserializedJson, List<SLSC_Mulesoft_Field_Mapping__mdt> mappings) {
        List<FieldDetails> result = new List<SLSC_UTIL_InvestorsMulesoftData.FieldDetails>();

        for (SLSC_Mulesoft_Field_Mapping__mdt mapping : mappings) {
            if (deserializedJson.containsKey(mapping.Mulesoft_ApiName__c)) {
                result.add(new FieldDetails(mapping.Label, String.valueOf(deserializedJson.get(mapping.Mulesoft_ApiName__c))));
            }
        }
        return result;
    }

    /**
    * @description Converts json into list of objects with fields details according to metadata mapping
    *
    * @param deserializedJson deserialized JSON
    * @param mappings list of custom metadata records
    *
    * @return List of objects with fields
    */
    @TestVisible
    private static Map<String, String> getFieldForTableWithLabels(Map<String, Object> deserializedJson, List<SLSC_Mulesoft_Field_Mapping__mdt> mappings) {
        Map<String, String> result = new Map<String, String>();
        for (SLSC_Mulesoft_Field_Mapping__mdt mapping : mappings) {
            if (deserializedJson.containsKey(mapping.Mulesoft_ApiName__c)) {
                result.put(mapping.Label, String.valueOf(deserializedJson.get(mapping.Mulesoft_ApiName__c)));
            }
        }
        return result;
    }

    public class FieldDetails {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public FieldDetails(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}