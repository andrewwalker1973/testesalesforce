@IsTest(SeeAllData=false IsParallel=true)
public with sharing class SLSC_UTIL_InvestorsMulesoftData_TEST {

    private static final String VALID_LABEL = 'Test label';
    private static final String VALID_API_NAME = 'Test apiname';
    private static final String INVALID_LABEL = 'Invalid label';
    private static final String INVALID_APINAME = 'Invalid apiname';
    private static String JSON_STRING = '{ "' + VALID_API_NAME + '":"' + VALID_LABEL + '", "' + INVALID_APINAME + '":"' + INVALID_LABEL + '"}';
    private static final Integer VALID_MAPPINGS_SIZE = 1;

    /**
     * @description Test method to test valid converting json response into list of fields according to custom metadata
     */
    @IsTest
    static void getFieldForTableWithLabelsTest() {
        Map<String, Object> jsonDeserialized = (Map<String, Object>) JSON.deserializeUntyped(JSON_STRING);

        List<SLSC_Mulesoft_Field_Mapping__mdt> mappings = getTestMdt();

        Map<String, String> result = SLSC_UTIL_InvestorsMulesoftData.getFieldForTableWithLabels(jsonDeserialized, mappings);

        System.assertEquals(true, result.containsKey(VALID_LABEL));
        System.assertEquals(false, result.containsKey(INVALID_LABEL));
    }

    /**
     * @description Test method to test valid converting json response into list of FieldDetails according to custom metadata
     */
    @IsTest
    static void getFieldDetailsWithLabelsTest() {
        Map<String, Object> jsonDeserialized = (Map<String, Object>) JSON.deserializeUntyped(JSON_STRING);

        List<SLSC_Mulesoft_Field_Mapping__mdt> mappings = getTestMdt();

        List<Object> result = SLSC_UTIL_InvestorsMulesoftData.getFieldDetailsWithLabels(jsonDeserialized, mappings);

        System.assertEquals(VALID_MAPPINGS_SIZE, result.size());
    }

    /**
     * @description Test Method to test valid converting nested objects into plain one-dimensional Map
     */
    @IsTest
    static void flatMapTest() {
        Map<String, Object> actualMap = SLSC_UTIL_InvestorsMulesoftData.flatMap(getTestMapForFlatMap());

        System.assertEquals(true, actualMap.containsKey('accountGroupId'));
        System.assertEquals(true, actualMap.containsKey('fund.fundId'));
        System.assertEquals(true, actualMap.containsKey('fund.jseCode'));
    }

    private static Map<String, Object> getTestMapForFlatMap() {
        return new Map<String, Object>
        {
                'accountGroupId' => 'SUTTFSA',
                'fund' => new Map<String, Object>{ 'fundId' => 'INF', 'jseCode' => 'STBI'}
        };
    }

    private static List<SLSC_Mulesoft_Field_Mapping__mdt> getTestMdt() {
        return new List<SLSC_Mulesoft_Field_Mapping__mdt>{
                new SLSC_Mulesoft_Field_Mapping__mdt(Label = VALID_LABEL, Mulesoft_ApiName__c = VALID_API_NAME)
        };
    }
}