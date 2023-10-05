public with sharing class SLSC_UTIL_MulesoftFieldMapping {

    public static List<SLSC_Mulesoft_Field_Mapping__mdt> getMulesoftFieldMapping(String endpointTitle) {
        return [SELECT Label, Mulesoft_ApiName__c, Order__c FROM SLSC_Mulesoft_Field_Mapping__mdt WHERE Endpoint_Title__c = :endpointTitle ORDER BY Order__c];
    }
}