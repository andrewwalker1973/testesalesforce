/**
 * @description Test class related to the CMN_CTRL_FieldSet
 *
 * @see CMN_CTRL_FieldSet
 *
 * @author jason.van.beukering@accenture.com, pavan.t@lntinfotech.com
 *
 * @date June 2022, July 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_CTRL_FieldSet_TEST
{
	private static final List<String> FOOBAR_FIELD_SETS = new List<String>
	{
			CMN_DAL_Foobar.FIELDSET_DEFAULT,
			CMN_DAL_Foobar.FIELDSET_FOOBAR,
			CMN_DAL_SObjectDomain.generateRandomName() //This invalid fieldset names is added to check that it's ignored
	};

	private static final String ERROR_NO_FIELDSET_MEMBERS_RETURNED = 'Dto members are not returned';
	private static final String ERROR_MEMBER_INCORRECT = 'Dto member information is incorrect';
	private static final String ERROR_NO_FIELDS_FOUND_AS_EXPECTED = 'No field was found in the Foobar fieldSet.';
	private static final String ERROR_NO_RECORDS_FOUND_AS_EXPECTED = 'Custom Metadata record not found as expected';
	private static final String ERROR_RECORD_UPDATE = 'record is not updated as expected';

	/**
	 * @description Create data required for unit tests
	 */
	@TestSetup
	private static void setup()
	{
		insert CMN_DAL_DataFactory.newFoobars(FOOBAR_FIELD_SETS.size());
	}

	/**
	 * @description Will check if all of the fields are retrieved from the field set for FooBar object Id
	 *
	 * @see CMN_CTRL_FieldSet.getFieldSetsForRecord
	 */
	@IsTest
	private static void getFieldSetsForRecord()
	{
		Map<String, FieldSet> fieldSetMap = CMN_UTIL_SObjectDescribe.getDescribe(CMN_DAL_Foobar.OBJECT_NAME).getFieldSetsMap();
		List<CMN_Foobar__c> foundFoobars = getAll(fieldSetMap);

		Map<Id, List<String>> requestMap = new Map<Id, List<String>>();
		for(Integer i = 0; i < foundFoobars.size(); i++)
		{
			requestMap.put(foundFoobars[i].Id, new List<String> {FOOBAR_FIELD_SETS[i]});
		}

		//This will check that this record is ignored as not fieldset names were provided
		requestMap.put(CMN_UTIL_Random.getRandomId(CMN_Foobar__c.SObjectType), null);
		//This will check that this record is ignored as the object doesn't have any fieldset
		requestMap.put(CMN_UTIL_Random.getRandomId(EmailTemplate.SObjectType), FOOBAR_FIELD_SETS);

		fieldSetMap = CMN_UTIL_SObjectDescribe.getDescribe(CMN_DAL_User.OBJECT_NAME).getFieldSetsMap();
		FieldSet foundFieldSet = fieldSetMap.get(CMN_DAL_User.FIELD_SET_PERSONAL_INFO); //Fieldset should be in all orgs as added by SF

		Assert.isNotNull(foundFieldSet, 'Fieldset for User missing');

		SObject foundUser = CMN_DAL_SObjectSelector.findById(CMN_DAL_User.OBJECT_NAME, UserInfo.getUserId(), CMN_CTRL_FieldSet.getFieldNamesFromFieldSetMember(foundFieldSet.fields));

		//This will check a separate query will be run for different object
		requestMap.put(foundUser.Id, new List<String> {CMN_DAL_User.FIELD_SET_PERSONAL_INFO});

		Test.startTest();

		Map<Id, Map<String, List<CMN_CTRL_FieldSet.DTO_FieldSetMember>>> fieldSetsByRecordId = CMN_CTRL_FieldSet.getFieldSetsForRecord(requestMap);
		Assert.areEqual(2, Limits.getQueries(), 'Only expected a query to be generated for each object type');

		Test.stopTest();

		assertFieldSetInformationCorrect(foundFoobars, fieldSetsByRecordId);
	}

	/**
	 * @description Will query all foobars using the fields from the field sets
	 *
	 * @param fieldSetMap A map of fieldset by name
	 *
	 * @return A list of found items
	 */
	private static List<CMN_Foobar__c> getAll(Map<String, FieldSet> fieldSetMap)
	{
		Set<String> allFoobarFields = new Set<String>();

		for(String fieldsetName : FOOBAR_FIELD_SETS)
		{
			FieldSet foundFieldSet = fieldSetMap.get(fieldsetName);
			if(foundFieldSet != null)
			{
				//Ensures we query all the foobar fields need based on the field sets provided
				allFoobarFields.addAll(CMN_CTRL_FieldSet.getFieldNamesFromFieldSetMember(foundFieldSet.fields));
			}
		}

		return CMN_DAL_Foobar.getAll(allFoobarFields);
	}

	/**
	 * @description Will check that the field set information returned is correct
	 *
	 * @param foundFoobars The foobars for which field values were requested
	 * @param fieldSetsByRecordId The field set and field values
	 */
	private static void assertFieldSetInformationCorrect(List<CMN_Foobar__c> foundFoobars, Map<Id, Map<String, List<CMN_CTRL_FieldSet.DTO_FieldSetMember>>> fieldSetsByRecordId)
	{
		Assert.isFalse(fieldSetsByRecordId.isEmpty(), ERROR_NO_FIELDS_FOUND_AS_EXPECTED);

		//Since once of the field set names is invalid, one of the requests won't have results returned but results set includes fields for user record
		Assert.areEqual(foundFoobars.size() - 1, fieldSetsByRecordId.size() - 1, 'Incorrect number of records returned');

		for(Integer i = 0; i < fieldSetsByRecordId.size(); i++)
		{
			SObject foundObject = foundFoobars[i];

			Map<String, List<CMN_CTRL_FieldSet.DTO_FieldSetMember>> fieldSetMemberMap = fieldSetsByRecordId.get(foundObject.Id);

			//For one of the foobars created there will be no results returned as the fieldset name provided is invalid
			if(fieldSetMemberMap == null)
			{
				continue;
			}

			assertDtoMemberCorrect
					(
							foundObject,
							foundObject.getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED).getName(),
							FOOBAR_FIELD_SETS[i],
							fieldSetMemberMap.get(FOOBAR_FIELD_SETS[i])
					);
		}
	}

	/**
	 * @description Checks that the members are correct for the given fieldset
	 *
	 * @param anObject The SObject for which the fieldset was requested
	 * @param objectName The name of the object to check
	 * @param fieldsetName The name of the fieldset to check
	 * @param fieldSetMembers The Dto members that were returned
	 */
	private static void assertDtoMemberCorrect(SObject anObject, String objectName, String fieldsetName, List<CMN_CTRL_FieldSet.DTO_FieldSetMember> fieldSetMembers)
	{
		Assert.isNotNull(fieldSetMembers, 'No fieldset members returned');

		FieldSet foundFieldSet = CMN_UTIL_SObjectDescribe.getDescribe(objectName).getFieldSetsMap().get(fieldsetName);

		Assert.areEqual(foundFieldSet.fields.size(), fieldSetMembers.size(), 'Incorrect number of members');

		for(Integer j = 0; j < foundFieldSet.fields.size(); j++)
		{
			FieldSetMember member = foundFieldSet.fields[j];

			CMN_CTRL_FieldSet.DTO_FieldSetMember dtoMember = fieldSetMembers[j];

			Assert.areEqual(CMN_DAL_Foobar.OBJECT_NAME, dtoMember.objectName, ERROR_MEMBER_INCORRECT);
			Assert.areEqual(CMN_UTIL_System.getFieldValue(anObject, member.fieldPath), dtoMember.fieldValue, ERROR_MEMBER_INCORRECT);
			Assert.areEqual(foundFieldSet.label, dtoMember.fieldSetName, ERROR_MEMBER_INCORRECT);
			Assert.areEqual(foundFieldSet.name, dtoMember.fieldSetAPIName, ERROR_MEMBER_INCORRECT);
			Assert.areEqual(member.dbRequired || member.required, dtoMember.isRequired, ERROR_MEMBER_INCORRECT);
			Assert.areEqual(member.fieldPath, dtoMember.fieldAPIName, ERROR_MEMBER_INCORRECT);
			Assert.areEqual(member.label, dtoMember.fieldLabel, ERROR_MEMBER_INCORRECT);
			Assert.areEqual(member.type.name(), dtoMember.fieldType, ERROR_MEMBER_INCORRECT);
			Assert.areEqual(dtoMember.fieldValue != null, dtoMember.valueIsSet, ERROR_MEMBER_INCORRECT);
		}
	}

	/**
	 * @description Will check if all of the fields are retrieved from the field set for FooBar object Name
	 *
	 * @see CMN_CTRL_FieldSet.getFieldSetsForObject
	 */
	@IsTest
	private static void getFieldSetsForObject()
	{
		Map<String, List<String>> requestMap = new Map<String, List<String>>();

		requestMap.put(CMN_DAL_Foobar.OBJECT_NAME, FOOBAR_FIELD_SETS);

		Test.startTest();

		Map<String, Map<String, List<CMN_CTRL_FieldSet.DTO_FieldSetMember>>> fieldDetailsByObjectName = CMN_CTRL_FieldSet.getFieldSetsForObject(requestMap);

		Test.stopTest();

		Assert.isFalse(fieldDetailsByObjectName.isEmpty(), ERROR_NO_FIELDS_FOUND_AS_EXPECTED);
		Assert.areEqual(1, fieldDetailsByObjectName.size(), 'Only expected entry for single object');

		for(String objectName : fieldDetailsByObjectName.keySet())
		{
			Map<String, List<CMN_CTRL_FieldSet.DTO_FieldSetMember>> fieldSetMemberMap = fieldDetailsByObjectName.get(objectName);

			for(String fieldSetName : fieldSetMemberMap.keySet())
			{
				assertDtoMemberCorrect(null, objectName, fieldSetName, fieldSetMemberMap.get(fieldSetName));
			}
		}
	}

	/**
	 * @description Will check if CMN_LightningWebComponentsFieldSet__mdt custom metadata records are retrieved as expected
	 *
	 * @see CMN_CTRL_FieldSet.findByDeveloperName
	 */
	@IsTest
	private static void findByDeveloperName()
	{
		CMN_LightningWebComponentsFieldSet__mdt foundComponentFieldSet1 = CMN_DAL_LightningWebComponentsFieldSets.getAll().iterator().next();

		Test.startTest();

		CMN_LightningWebComponentsFieldSet__mdt foundComponentFieldSet2 = CMN_CTRL_FieldSet.findByDeveloperName(foundComponentFieldSet1.DeveloperName);

		Test.stopTest();

		Assert.areEqual(foundComponentFieldSet1, foundComponentFieldSet2, ERROR_NO_RECORDS_FOUND_AS_EXPECTED);
	}

	/**
	 * @description Checks if getObjectNameFromRecordId returns the correct Object API name.
	 */
	@IsTest
	private static void getObjectNameFromRecordId()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_Foobar.getAll().iterator().next();

		Test.startTest();

		String objectAPIName = CMN_CTRL_FieldSet.getObjectNameFromRecordId(newFoobar.Id);

		Test.stopTest();

		Assert.areEqual(CMN_DAL_Foobar.OBJECT_NAME, objectAPIName, objectAPIName);
	}
}