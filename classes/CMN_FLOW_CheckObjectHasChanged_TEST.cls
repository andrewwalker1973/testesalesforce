/**
 * @description Test class for CMN_FLOW_CheckIsFieldUpdated
 *
 * @see CMN_FLOW_CheckObjectHasChanged
 *
 * @author Accenture
 *
 * @date July 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_FLOW_CheckObjectHasChanged_TEST
{
	/**
	 * @description Method to create DTO request
	 *
	 * @param isUpdate Indicate if want to test situation where an object has been updated
	 *
	 * @return A request item
	 */
	private static CMN_FLOW_CheckObjectHasChanged.DTO_Request createDtoRequest(Boolean isUpdate)
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		CMN_Foobar__c oldFoobar;

		if(isUpdate)
		{
			oldFoobar = CMN_DAL_DataFactory.newFoobar();
		}

		CMN_FLOW_CheckObjectHasChanged.DTO_Request dtoRequest = new CMN_FLOW_CheckObjectHasChanged.DTO_Request();

		dtoRequest.fieldSetName = CMN_DAL_Foobar.FIELDSET_DEFAULT;
		dtoRequest.newSObject = newFoobar;
		dtoRequest.oldSObject = oldFoobar;

		return dtoRequest;
	}

	/**
	 * @description Will check to see if it detects whether object differs based on fieldset when edited
	 */
	@IsTest
	private static void objectEdited()
	{
		CMN_FLOW_CheckObjectHasChanged.DTO_Request dtoRequest = createDtoRequest(true);

		Test.startTest();

		Boolean isChanged = CMN_FLOW_CheckObjectHasChanged.checkIsFieldsUpdated(new List<CMN_FLOW_CheckObjectHasChanged.DTO_Request> {dtoRequest}).iterator().next();

		Test.stopTest();

		System.assertEquals(true, isChanged, 'Object should be detected as changed');
	}

	/**
	 * @description Will check to see if it detects whether object differs based on fieldset when inserted
	 */
	@IsTest
	private static void objectInserted()
	{
		CMN_FLOW_CheckObjectHasChanged.DTO_Request dtoRequest = createDtoRequest(false);

		Test.startTest();

		Boolean isChanged = CMN_FLOW_CheckObjectHasChanged.checkIsFieldsUpdated(new List<CMN_FLOW_CheckObjectHasChanged.DTO_Request> {dtoRequest}).iterator().next();

		Test.stopTest();

		System.assertEquals(true, isChanged, 'Object should be considered changed');
	}

	/**
	 * @description Will check to see if it detects whether object is not changed based on fieldset
	 */
	@IsTest
	private static void objectUnchanged()
	{
		CMN_FLOW_CheckObjectHasChanged.DTO_Request dtoRequest = createDtoRequest(true);
		dtoRequest.oldSObject = dtoRequest.newSObject;

		Test.startTest();

		Boolean isChanged = CMN_FLOW_CheckObjectHasChanged.checkIsFieldsUpdated(new List<CMN_FLOW_CheckObjectHasChanged.DTO_Request> {dtoRequest}).iterator().next();

		Test.stopTest();

		System.assertEquals(false, isChanged, 'Object should be NOT be considered changed');
	}

	/**
	 * @description Check behaviour when fieldset is not found
	 */
	@IsTest
	private static void invalidFieldSet()
	{
		CMN_FLOW_CheckObjectHasChanged.DTO_Request dtoRequest = createDtoRequest(true);
		dtoRequest.fieldSetName = CMN_DAL_SObjectDomain.generateRandomName();

		Test.startTest();

		Boolean isChanged = CMN_FLOW_CheckObjectHasChanged.checkIsFieldsUpdated(new List<CMN_FLOW_CheckObjectHasChanged.DTO_Request> {dtoRequest}).iterator().next();

		Test.stopTest();

		System.assertEquals(false, isChanged, 'Object should be NOT be considered changed');
	}

}