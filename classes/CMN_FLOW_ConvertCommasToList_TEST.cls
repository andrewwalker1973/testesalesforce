@isTest
private class CMN_FLOW_ConvertCommasToList_TEST {
    
    static testmethod void testConvertToList(){
        List<String> csvString = new List<String>();
        csvString.add('String1__c, String2__c, String3__c');
        
        test.startTest();
        List<List<String>> convertedList = CMN_FLOW_ConvertCommasToList.convertToList(csvString);
        test.stopTest();
        
        system.assertEquals(3, convertedList[0].size());
        
	}
}