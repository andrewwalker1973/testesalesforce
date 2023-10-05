/**
 * Created by darrion.james.singh on 2022/01/25.
 */

@IsTest
private class CMN_CTRL_SObjectInformation_TEST
{
	@IsTest
	static void getSObjectFieldInformation()
	{
		Test.startTest();
		Map<String, CMN_CTRL_SObjectInformation.CMN_DTO_FieldInformation> sobjectInfo = CMN_CTRL_SObjectInformation.getSObjectFieldInformation(CMN_DAL_Foobar.OBJECT_NAME);
		Test.stopTest();
		System.assertEquals(CMN_Foobar__c.SObjectType.getDescribe().fields.getMap().keySet().size(),
				sobjectInfo.keySet().size(),
				'Number of fields returned by controller does not equal number of fields on the object.');
	}

	@IsTest
	static void getRecordTypes()
	{
		Test.startTest();
		List<CMN_CTRL_SObjectInformation.CMN_DTO_RecordTypeInformation> recordTypeInformationList = CMN_CTRL_SObjectInformation.getRecordTypes(CMN_DAL_Foobar.OBJECT_NAME);
		Test.stopTest();
		System.assertEquals(CMN_Foobar__c.SObjectType.getDescribe().getRecordTypeInfos().size(),
				recordTypeInformationList.size(),
				'Number of record types returned by controller does not equal number of record types on the object.');
	}
}