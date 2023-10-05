/**
 * @description Contains test methods for CMN_CTRL_Lookup
 *
 * @see CMN_CTRL_Lookup
 *
 * @author darrion.james.singh@accenture.com, jason.van.beukering@accenture.com
 *
 * @date February 2022, June 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_CTRL_Lookup_TEST
{
	private static final Integer LIMIT_TO_ONE_RESULT = 1;

	/**
	 * @description Tests findSObjectBySearchTerm by giving it a search term and checking if a list of objects is returned
	 *
	 * @see CMN_CTRL_Lookup.findSObjectBySearchTerm
	 */
	@IsTest
	private static void findSObjectBySearchTermWithLimit()
	{
		CMN_Foobar__c newFoobar1 = CMN_DAL_DataFactory.insertFoobar();

		CMN_Foobar__c newFoobar2 = newFoobar1.clone();
		newFoobar2.Name = newFoobar1.Name + CMN_DAL_SObjectDomain.generateRandomNumber();
		insert newFoobar2;

		Test.setFixedSearchResults(new List<String> {newFoobar1.Id, newFoobar2.Id});

		Test.startTest();

		List<SObject> foundObjects =
				CMN_CTRL_Lookup.findSObjectBySearchTerm(CMN_DAL_Foobar.OBJECT_NAME, newFoobar1.Name, getFoobarFields(), LIMIT_TO_ONE_RESULT);

		Test.stopTest();

		Assert.areEqual(LIMIT_TO_ONE_RESULT, foundObjects.size(), 'Incorrect number of objects found');
		CMN_Foobar__c foundFoobar = (CMN_Foobar__c)foundObjects.iterator().next();
		Assert.isTrue(String.isNotBlank(foundFoobar.CMN_Text__c), 'Field was not retrieved');
	}

	/**
	 * @description Will return the default foobar fields as a comma separated string
	 *
	 * @return The separated list of fields
	 */
	private static String getFoobarFields()
	{
		return CMN_UTIL_String.joinSet(CMN_DAL_Foobar.getDefaultFields(), CMN_UTIL_String.COMMA);
	}

	/**
	 * @description Tests that findById returns a record for a valid Id and a list of fields
	 *
	 * @see CMN_CTRL_Lookup.findById
	 */
	@IsTest
	private static void findById()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.insertFoobar();

		Test.startTest();

		SObject foundObject =
				CMN_CTRL_Lookup.findById(CMN_DAL_Foobar.OBJECT_NAME, newFoobar.Id, getFoobarFields());

		Test.stopTest();

		Assert.isNotNull(foundObject, 'Object not found');

		CMN_Foobar__c foundFoobar = (CMN_Foobar__c)foundObject;

		Assert.areEqual(newFoobar.Id, foundFoobar.Id, 'Incorrect object Id');
		Assert.isTrue(String.isNotBlank(foundFoobar.CMN_Text__c), 'Field was not retrieved');
	}
}