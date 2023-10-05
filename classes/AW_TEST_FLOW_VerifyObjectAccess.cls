/**
 * @description Test class for AW_FLOW_VerifyObjectAccess
 * @story ST-3396
 * @ Func Area Adviser Workbench
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_FLOW_VerifyObjectAccess
{

	/**
	 * @description Method to validate Object level access for different objects for Liberty Support profile
	 */
	@IsTest
	private static void validateAccessForLibertySupportUsers()
	{
		User libertySupportUser = AW_DAL_User.findActiveLibertySupportUser();

		List<AW_FLOW_VerifyObjectAccess.DTO_Object> dtoObjects = AW_DAL_TestDataFactory.createObjectAccessCheckDTO(new List<String> {CMN_DAL_Lead.OBJECT_NAME});

		System.runAs(libertySupportUser)
		{
			validateAccessDTO(dtoObjects);
		}
	}

	/**
	 * @description Method to validate Object level access for different objects for Adviser profile
	 */
	@IsTest
	private static void validateAccessForAdvisers()
	{
		User delegatedAdmin = AW_DAL_User.findRandomActiveAdviser();

		List<AW_FLOW_VerifyObjectAccess.DTO_Object> dtoObjects = AW_DAL_TestDataFactory.createObjectAccessCheckDTO(new List<String> {CMN_DAL_Lead.OBJECT_NAME});

		System.runAs(delegatedAdmin)
		{
			validateAccessDTO(dtoObjects);
		}
	}

	/**
	 * @description Method to validate Object level access for different objects for System admin profile
	 */
	@IsTest
	private static void validateAccessForAdmins()
	{
		User delegatedAdmin = AW_DAL_User.findActiveAdministrator();

		List<AW_FLOW_VerifyObjectAccess.DTO_Object> dtoObjects = AW_DAL_TestDataFactory.createObjectAccessCheckDTO(new List<String> {CMN_DAL_Lead.OBJECT_NAME});

		System.runAs(delegatedAdmin)
		{
			validateAccessDTO(dtoObjects);
		}
	}

	/**
	 * @description Method to validate Object level access with Incorrect Object API name
	 */
	@IsTest
	private static void validateAccessWithIncorrectObjectName()
	{
		AW_DAL_User.findActiveLibertySupportUser();

		List<AW_FLOW_VerifyObjectAccess.DTO_Object> dtoObjects = AW_DAL_TestDataFactory.createObjectAccessCheckDTO(new List<String> {CMN_DAL_SObjectDomain.generateRandomName()});

		List<AW_FLOW_VerifyObjectAccess.DTO_ObjectAccess> objectAccesses = new List<AW_FLOW_VerifyObjectAccess.DTO_ObjectAccess>();

		Test.startTest();

		objectAccesses = AW_FLOW_VerifyObjectAccess.getObjectAccess(dtoObjects);

		Test.stopTest();

		Map<String, AW_FLOW_VerifyObjectAccess.DTO_ObjectAccess> objectAccessesMap = convertObjectAccessListToMap(objectAccesses);

		for(AW_FLOW_VerifyObjectAccess.DTO_Object dtoObject : dtoObjects)
		{
			System.assertEquals(false, objectAccessesMap.get(dtoObject.objectApiName).hasReadAccess);
			System.assertEquals(false, objectAccessesMap.get(dtoObject.objectApiName).hasCreateAccess);
			System.assertEquals(false, objectAccessesMap.get(dtoObject.objectApiName).hasEditAccess);
			System.assertEquals(false, objectAccessesMap.get(dtoObject.objectApiName).hasDeleteAccess);
		}
	}

	/**
	 * @description Generic method which takes List of DTO objects as parameter and validate access for given objects
	 *
	 * @param dtoObjects List of DTO_Objects for which access needs to be checked
	 */
	private static void validateAccessDTO(List<AW_FLOW_VerifyObjectAccess.DTO_Object> dtoObjects)
	{
		List<AW_FLOW_VerifyObjectAccess.DTO_ObjectAccess> objectAccesses = new List<AW_FLOW_VerifyObjectAccess.DTO_ObjectAccess>();

		Test.startTest();

		objectAccesses = AW_FLOW_VerifyObjectAccess.getObjectAccess(dtoObjects);

		Test.stopTest();

		Map<String, AW_FLOW_VerifyObjectAccess.DTO_ObjectAccess> objectAccessesMap = convertObjectAccessListToMap(objectAccesses);

		for(AW_FLOW_VerifyObjectAccess.DTO_Object dtoObject : dtoObjects)
		{
			System.assertEquals(Schema.getGlobalDescribe().get(dtoObject.objectApiName).getDescribe().isAccessible(),
					objectAccessesMap.get(dtoObject.objectApiName).hasReadAccess);

			System.assertEquals(Schema.getGlobalDescribe().get(dtoObject.objectApiName).getDescribe().isCreateable(),
					objectAccessesMap.get(dtoObject.objectApiName).hasCreateAccess);

			System.assertEquals(Schema.getGlobalDescribe().get(dtoObject.objectApiName).getDescribe().isUpdateable(),
					objectAccessesMap.get(dtoObject.objectApiName).hasEditAccess);

			System.assertEquals(Schema.getGlobalDescribe().get(dtoObject.objectApiName).getDescribe().isDeletable(),
					objectAccessesMap.get(dtoObject.objectApiName).hasDeleteAccess);
		}
	}

	/**
	 * @description Method to convert list of DTO_ObjectAccess to Map
	 *
	 * @param objectAccesses List of DTO_ObjectAccess which needs to be convereted to Map
	 *
	 * @return Map with Object API name as key and DTO_ObjectAccess as value
	 */
	private static Map<String, AW_FLOW_VerifyObjectAccess.DTO_ObjectAccess> convertObjectAccessListToMap(List<AW_FLOW_VerifyObjectAccess.DTO_ObjectAccess> objectAccesses)
	{
		Map<String, AW_FLOW_VerifyObjectAccess.DTO_ObjectAccess> objectAccessMap = new Map<String, AW_FLOW_VerifyObjectAccess.DTO_ObjectAccess>();

		for(AW_FLOW_VerifyObjectAccess.DTO_ObjectAccess objectAccess : objectAccesses)
		{
			objectAccessMap.put(objectAccess.objectApiName, objectAccess);
		}

		return objectAccessMap;
	}
}