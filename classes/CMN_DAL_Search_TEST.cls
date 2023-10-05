/**
 * @description Class has base methods that can be used to test the account search result
 *
 * @see CMN_DAL_Search
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date November 2021, August 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_DAL_Search_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_CREATE = 100;

	/**
	 * @description To test the search result from Object
	 */
	@IsTest
	private static void soslSearch()
	{
		String commonName = CMN_DAL_SObjectDomain.generateRandomName();

		CMN_Foobar__c foobar1 = CMN_DAL_DataFactory.newFoobar();
		foobar1.Name = commonName;
		CMN_Foobar__c foobar2 = CMN_DAL_DataFactory.newFoobar();
		foobar2.Name = commonName;
		CMN_Foobar__c foobar3 = CMN_DAL_DataFactory.newFoobar();
		foobar3.Name = commonName;

		CMN_DAL_SObjectDomain.insertDBObjects(new List<SObject>
		{
				foobar1,
				foobar2,
				foobar3
		});

		Test.setFixedSearchResults(new List<String>
		{
				foobar1.Id,
				foobar2.Id,
				foobar3.Id
		});

		String term = '{' + commonName + '}';

		CMN_DAL_Search.SOSLSearchParameters parameters = new CMN_DAL_Search.SOSLSearchParameters
				(
						CMN_Foobar__c.SObjectType,
						CMN_DAL_Search.SOSLSearchGroup.ALL_FIELDS,
						term
				);

		parameters.paged = true;
		parameters.pageSize = 2;
		parameters.searchConditions.inX(CMN_DAL_SObjectDomain.FIELD_NAME, new List<String> {commonName});
		parameters.addOrderByField(CMN_DAL_SObjectDomain.FIELD_NAME);

		Test.startTest();

		CMN_DAL_Search.SearchResponse response = CMN_DAL_Search.soslSearch(parameters);
		List<SObject> objects = CMN_DAL_Search.soslSearch(CMN_Foobar__c.SObjectType, CMN_DAL_Search.SOSLSearchGroup.ALL_FIELDS, term);

		Test.stopTest();

		System.assertNotEquals(null, response);
		System.assertEquals(parameters.pageSize, response.results.size());
		System.assertEquals(parameters.pageSize + 1, objects.size());
	}

	/**
	 * @description : To test the search result from foobar by name
	 */
	@IsTest
	private static void getAllByName()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar;

		Test.startTest();

		List<CMN_Foobar__c> foobars = CMN_DAL_Search.getAll(CMN_DAL_Foobar.OBJECT_NAME, newFoobar.Name);

		Test.stopTest();

		System.assert(!foobars.isEmpty(), 'No Foobars retrieved by Name.');
	}

	/**
	 * @description To test the search result from Foo Object
	 */
	@IsTest
	private static void getAll()
	{
		insert CMN_DAL_DataFactory.newFoobar();

		Test.startTest();

		List<CMN_Foobar__c> foobars = CMN_DAL_Search.getAll(CMN_Foobar__c.SObjectType);

		Test.stopTest();

		System.assert(!foobars.isEmpty(), 'No Foobars retrieved.');
	}

	/**
	 * @description Checks that sharing can be bypassed when executing a query
	 *
	 * @see CMN_DAL_Search.SearchParameters.enforceSharing
	 */
	@IsTest
	private static void getAllNoSharing()
	{
		insert CMN_DAL_DataFactory.newFoobar();

		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_Foobar.OBJECT_NAME, CMN_DAL_Foobar.getDefaultFields());
		searchParameters.enforceSharing = false;

		Test.startTest();

		List<CMN_Foobar__c> foobars;

		System.runAs(CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_STANDARD_USER))
		{
			foobars = CMN_DAL_Search.getObjects(searchParameters);
		}

		Test.stopTest();

		System.assertEquals(false, foobars.isEmpty(), 'No Foobars retrieved.');
	}

	/**
	 * @description Checks that sharing can be enforced when executing a query
	 *
	 * @see CMN_DAL_Search.SearchParameters.enforceSharing
	 */
	@IsTest
	private static void getAllWithSharing()
	{
		insert CMN_DAL_DataFactory.newFoobar();

		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_Foobar.OBJECT_NAME, CMN_DAL_Foobar.getDefaultFields());
		searchParameters.enforceSharing = true;

		Test.startTest();

		List<CMN_Foobar__c> foobars;

		System.runAs(CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_STANDARD_USER))
		{
			foobars = CMN_DAL_Search.getObjects(searchParameters);
		}

		Test.stopTest();

		System.assertEquals(true, foobars.isEmpty(), 'No Foobars should be retrieved.');
	}

	/**
	 * @description To test the search result from Foo Object
	 */
	@IsTest
	private static void getAllWithFields()
	{
		insert CMN_DAL_DataFactory.newFoobar();

		Test.startTest();

		List<CMN_Foobar__c> foobars = CMN_DAL_Search.getAll(CMN_Foobar__c.SObjectType, CMN_DAL_Foobar.getDefaultFields());

		Test.stopTest();

		System.assertEquals(false, foobars.isEmpty(), 'No Foobars retrieved.');
	}

	/**
	 * @description To test the search result from Foo by Id
	 */
	@IsTest
	private static void getAllById()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar;

		Test.startTest();

		List<CMN_Foobar__c> foobars = CMN_DAL_Search.findAllByAnyValue(CMN_DAL_Foobar.OBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_ID, newFoobar.Id);

		Test.stopTest();

		System.assert(!foobars.isEmpty(), 'No Foobars retrieved by Id.');
	}

	/**
	 * @description Test query that's paged
	 */
	@IsTest
	private static void findPaged()
	{
		//Insert 2 items; but by setting page size to 1, we expect only to retrieve one of them
		CMN_Foobar__c newFoobar1 = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar1;

		CMN_Foobar__c newFoobar2 = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar2;

		Test.startTest();

		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_Foobar.OBJECT_NAME);

		//Setting page to true will ensure that we do paging
		searchParameters.paged = true;
		searchParameters.pageSize = 1;
		searchParameters.searchFields.clear();
		searchParameters.addOrderByField(CMN_DAL_SObjectDomain.FIELD_NAME);

		//We're expecting the fields to be separated by a comma
		searchParameters.selectFields = CMN_DAL_Search.DEFAULT_SEARCH_FIELDS;

		searchParameters.searchConditions.inX(CMN_DAL_SObjectDomain.FIELD_NAME, new List<String> {newFoobar1.Name, newFoobar2.Name});

		CMN_DAL_Search.SearchResponse searchResponse = CMN_DAL_Search.soqlSearch(searchParameters);

		Test.stopTest();

		System.assertEquals(false, searchResponse.results.isEmpty(), 'No Foobars retrieved by Name.');
		System.assertEquals(1, searchResponse.results.size(), 'Invalid number of Foobars retrieved.');
		System.assertEquals(2, searchResponse.totalItems, 'Total Number of Foobars available incorrect.');
	}

	/**
	 * @description Test query that's not paged
	 */
	@IsTest
	private static void findNotPaged()
	{
		//Insert 2 items; but by setting page size to 1, we expect only to retrieve one of them
		CMN_Foobar__c newFoobar1 = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar1;

		CMN_Foobar__c newFoobar2 = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar2;

		Test.startTest();

		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_Foobar.OBJECT_NAME);

		//Setting page to true will ensure that we do paging
		searchParameters.paged = false;
		searchParameters.searchFields.clear();
		searchParameters.addOrderByField(CMN_DAL_SObjectDomain.FIELD_NAME);

		//We're expecting the fields to be separated by a comma
		searchParameters.selectFields = CMN_DAL_Search.DEFAULT_SEARCH_FIELDS;

		searchParameters.searchConditions.inX(CMN_DAL_SObjectDomain.FIELD_NAME, new List<String> {newFoobar1.Name, newFoobar2.Name});

		CMN_DAL_Search.SearchResponse searchResponse = CMN_DAL_Search.soqlSearch(searchParameters);

		Test.stopTest();

		System.assertEquals(2, searchResponse.results.size(), 'Invalid number of Foobars retrieved.');
		System.assertEquals(2, searchResponse.totalItems, 'Total Number of Foobars available incorrect.');
	}

	/**
	 * @description tests finding an object using search term
	 */
	@IsTest
	private static void searchTerm()
	{
		//Insert 2 items; but by setting page size to 1, we expect only to retrieve one of them
		CMN_Foobar__c newFoobar1 = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar1;

		CMN_Foobar__c newFoobar2 = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar2;

		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_Foobar.OBJECT_NAME, newFoobar1.Name);

		Test.startTest();

		List<CMN_Foobar__c> foobars = CMN_DAL_Search.getObjects(searchParameters);

		Test.stopTest();

		System.assertEquals(false, foobars.isEmpty(), 'No Foobars retrieved by Name.');
		System.assertEquals(1, foobars.size(), 'Invalid number of Foobars retrieved.');
	}

	/**
	 * @description Will insert a large list of foobars for testing purposes and then create search parameters to find them
	 *
	 * @return configured search parameters
	 */
	private static CMN_DAL_Search.SOQLSearchParameters setupSearchParameters()
	{
		List<CMN_Foobar__c> newFoobars = new List<CMN_Foobar__c>();

		//Ensure that we create enough items so that finding them randomly returns different items and not the same one
		for(Integer i = 0; i < NUMBER_OF_ITEMS_TO_CREATE; i++)
		{
			newFoobars.add(CMN_DAL_DataFactory.newFoobar());
		}

		insert newFoobars;

		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_Foobar.OBJECT_NAME, CMN_DAL_Search.DEFAULT_SEARCH_FIELDS);

		searchParameters.searchConditions.equalsX(CMN_DAL_SObjectDomain.FIELD_RECORD_TYPE_ID, newFoobars.iterator().next().RecordTypeId);
		searchParameters.addOrderByField(CMN_DAL_SObjectDomain.FIELD_NAME);

		return searchParameters;
	}

	/**
	 * @description Will test that objects can be randomly retrieved
	 *
	 * @see CMN_DAL_Search.getRandomItem
	 */
	@IsTest
	private static void getRandomItem()
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = setupSearchParameters();

		Test.startTest();

		CMN_Foobar__c randomFoo1 = (CMN_Foobar__c)CMN_DAL_Search.getRandomItem(searchParameters);

		System.assertNotEquals(null, randomFoo1, 'No items found.');

		Test.stopTest();

		CMN_Foobar__c randomFoo2 = (CMN_Foobar__c)CMN_DAL_Search.getRandomItem(searchParameters);

		System.assertNotEquals(randomFoo1.Id, randomFoo2.Id, 'The same item retrieved, expecting random retrieval');
	}

	/**
	 * @description Checks that if the entire list is requested (using random item function) that all rows are returned
	 *
	 * @see CMN_DAL_Search.getRandomItems
	 */
	@IsTest
	private static void getAllRandomItems()
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = setupSearchParameters();

		Test.startTest();

		List<CMN_Foobar__c> foundFoobars = CMN_DAL_Search.getRandomItems(searchParameters, NUMBER_OF_ITEMS_TO_CREATE);

		Test.stopTest();

		System.assertEquals(NUMBER_OF_ITEMS_TO_CREATE, foundFoobars.size(), 'Not all items were returned');
	}

	/**
	 * @description Checks that required number of random items are returned
	 *
	 * @see CMN_DAL_Search.getRandomItems
	 */
	@IsTest
	private static void getRandomItems()
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = setupSearchParameters();

		Test.startTest();

		final Integer numberOfRequiredItems = 30;

		List<CMN_Foobar__c> foundFoobars = CMN_DAL_Search.getRandomItems(searchParameters, numberOfRequiredItems);

		Test.stopTest();

		System.assertEquals(numberOfRequiredItems, foundFoobars.size(), 'Not all items were returned');
	}

	/**
	 * @description Checks that required number of random items are returned
	 *
	 * @see CMN_DAL_Search.getRandomItems
	 */
	@IsTest
	private static void getRandomItemsNotAllExist()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar;

		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_Foobar.OBJECT_NAME, CMN_DAL_Search.DEFAULT_SEARCH_FIELDS);

		searchParameters.searchConditions.equalsX(CMN_DAL_SObjectDomain.FIELD_RECORD_TYPE_ID, newFoobar.RecordTypeId);

		Test.startTest();

		final Integer numberOfRequiredItems = 10;

		List<CMN_Foobar__c> foundFoobars = CMN_DAL_Search.getRandomItems(searchParameters, numberOfRequiredItems);

		Test.stopTest();

		System.assertEquals(1, foundFoobars.size(), 'Correct Number of items returned');
	}

	/**
	 * @description Will check that related object information is queries as well
	 */
	@IsTest
	private static void getAllIncludingRelatedObject()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar;

		Test.startTest();

		List<CMN_Foobar__c> foobars = CMN_DAL_Search.findAllById(CMN_DAL_Foobar.OBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_ID, newFoobar.Id, true);

		Test.stopTest();

		System.assertNotEquals(true, foobars.isEmpty(), 'No Foobars retrieved by Id.');
		System.assertNotEquals(null, foobars.iterator().next().RecordType?.DeveloperName, 'Related object Information not retrieved.');
	}

	/**
	 * @description Checks that querying aggregates works as expected
	 *
	 * @see CMN_DAL_Search.getQueryAggregate
	 */
	@IsTest
	private static void getQueryAggregate()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar;

		Test.startTest();

		/* group by id will always return single record for this foobar test */
		List<AggregateResult> aggregateResults = CMN_DAL_Foobar.countNameById();

		Test.stopTest();

		System.assertEquals(false, aggregateResults.isEmpty(), 'No results returned');

		AggregateResult result = aggregateResults.iterator().next();
		System.assertEquals(1, result.get('expr0'), 'Aggregate is incorrect');
	}

	/**
	 * @description Tests using the IN clause in a query
	 *
	 * @see CMN_DAL_Search.selectWhereIn
	 */
	@IsTest
	private static void selectWhereIn()
	{
		CMN_Foobar__c parentFoobar = CMN_DAL_DataFactory.newFoobar();
		insert parentFoobar;

		CMN_Foobar__c childFoobar = CMN_DAL_DataFactory.newFoobar();
		childFoobar.CMN_Lookup__c = parentFoobar.Id;
		insert childFoobar;

		Test.startTest();

		List<CMN_Foobar__c> results = CMN_DAL_Foobar.selectWithChildBasedOnLookupWhereIn(new Set<Id> {parentFoobar.Id});

		Test.stopTest();

		System.assertEquals(false, results.isEmpty(), 'No results returned.');
		System.assertEquals(childFoobar.CMN_Lookup__c, results.iterator().next().Id);
	}

	/**
	 * @description Tests using the NOT IN clause in a query
	 *
	 * @see CMN_DAL_Search.selectWhereNotIn
	 */
	@IsTest
	private static void selectWhereNotIn()
	{
		CMN_Foobar__c parentFoobar = CMN_DAL_DataFactory.newFoobar();
		insert parentFoobar;

		CMN_Foobar__c childFoobar = CMN_DAL_DataFactory.newFoobar();
		childFoobar.CMN_Lookup__c = parentFoobar.Id;
		insert childFoobar;

		Test.startTest();

		List<CMN_Foobar__c> results = CMN_DAL_Foobar.selectWithChildBasedOnLookupWhereNotIn(new Set<Id> {parentFoobar.Id});

		Test.stopTest();

		System.assertEquals(false, results.isEmpty(), 'No results returned.');
		System.assertEquals(childFoobar.CMN_Lookup__c, results.iterator().next().Id);
	}
}