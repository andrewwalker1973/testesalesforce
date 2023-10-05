/**
 * @description Class to  construct and  execute SOQL or SOSL queries generically.
 * Supports paging  on SOQL queries if  required
 *
 * @see CMN_DAL_Search_TEST
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date November 2021, March 2023
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.ExcessiveClassLength,PMD.ExcessivePublicCount')
public inherited sharing class CMN_DAL_Search
{
	private static final Integer MAX_OFFSET = 2000;
	private static final Integer MINIMUM_LIMIT = 1;
	@TestVisible
	private static final Set<String> DEFAULT_SEARCH_FIELDS = new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME};
	private static final String LIKE_WILD_CARD_CHAR = '%';
	private static final String SOQL_IN = ' IN ';
	private static final String SOQL_NOT_IN = ' NOT IN ';
	private static final String SOQL_SEARCH_TERM_FMT = '{0}{1}{0}';
	private static final String SOSL_LIMIT_FMT = 'LIMIT {0} OFFSET {1}';
	private static final String SOSL_ORDER_BY = 'ORDER BY ';
	private static final String SOSL_WHERE = 'WHERE ';
	private static final String SOSL_WILD_CARD = '*';

	private static final String SOSL_QUERY_FMT =
			'FIND :searchTerm IN {0} ' + //search term required
			'RETURNING ' +
			'{1} ' + //object to be retrieved required
			'(' +
			'{2} ' + //fields to return required
			'{3} ' + //where clause optional
			'{4} ' + //order by clause optional
			'{5}' + //offset clause required
			')';

	/**
	 * @description Maximum number of records that can be queried
	 */
	public static final Integer LIMIT_NUMBER_OF_RECORDS = 50000;

	/**
	 * @description If using an offset and paging results the maximum page size can only be 2000
	 */
	public static final Integer MAX_PAGE_SIZE = 2000;

	/**
	 * @description An enum to specific which fields to search for a SOSL Query
	 */
	@SuppressWarnings('ApexDocValidation')
	public enum SOSLSearchGroup
	{
		ALL_FIELDS, NAME_FIELDS, EMAIL_FIELDS, PHONE_FIELDS, SIDEBAR_FIELDS
	}

	/**
	 * @description Map used when composing a SOSL Query to set the Search Group
	 */
	private static final Map<SOSLSearchGroup, String> SOSL_SEARCH_GROUP_VALUES = new Map<SOSLSearchGroup, String>
	{
			SOSLSearchGroup.ALL_FIELDS => 'ALL FIELDS',
			SOSLSearchGroup.EMAIL_FIELDS => 'EMAIL FIELDS',
			SOSLSearchGroup.NAME_FIELDS => 'NAME FIELDS',
			SOSLSearchGroup.PHONE_FIELDS => 'PHONE FIELDS',
			SOSLSearchGroup.SIDEBAR_FIELDS => 'SIDEBAR FIELDS'
	};

	/**
	 * @description Class use for store variables
	 */
	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public virtual class SearchParameters
	{
		public SObjectType objectType;

		/**
		 * @description Setting enforceSecurity to true will enforce Field Level and Object Security
		 */
		public Boolean enforceSecurity;
		public Boolean enforceSharing;
		public CMN_SOQL_Query.NestableCondition searchConditions;
		public List<CMN_SOQL_Query.OrderBy> orderByFields;
		public Set<String> selectFields;
		public String searchTerm;
		/**
		 * @description Will ensure that random set of results are returned, set page size to return more than 1 row
		 */
		public Boolean randomResults = false;
		public Boolean paged = false;

		public Integer pageSize
		{
			get
			{
				Integer maxPageSize = paged ? MAX_PAGE_SIZE : LIMIT_NUMBER_OF_RECORDS;

				return pageSize > maxPageSize || pageSize < 0 ? maxPageSize : pageSize;
			}
			set;
		}

		public Integer pageNumber
		{
			get
			{
				return pageNumber > 0 ? pageNumber - 1 : 0;
			}
			set;
		}

		public String objectName
		{
			get
			{
				return objectType == null ? CMN_UTIL_String.EMPTY : objectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
			}
		}

		public Integer offset
		{
			get
			{
				return Math.max(Math.min(pageSize * pageNumber, MAX_OFFSET), 0);
			}
		}

		/**
		 * @description set query security
		 *
		 * @param enforceSecurity sets query crud and fls security
		 */
		public void setSecurityEnforced(Boolean enforceSecurity)
		{
			this.enforceSecurity = enforceSecurity;
		}

		/**
		 * @description clears search fields populated with defaults
		 */
		public void clearSelectFields()
		{
			this.selectFields.clear();
		}

		/**
		 * @description Constructor
		 */
		public SearchParameters()
		{
			enforceSecurity = false;
			searchConditions = new CMN_SOQL_Query.AndCondition();
			selectFields = new Set<String>(DEFAULT_SEARCH_FIELDS);
			orderByFields = new List<CMN_SOQL_Query.OrderBy>();
			pageSize = 0;
			pageNumber = 0;
		}

		/**
		 * @description Constructor
		 *
		 * @param objectType as input
		 * @param searchTerm as input
		 */
		public SearchParameters(SObjectType objectType, String searchTerm)
		{
			this();
			this.objectType = objectType;
			this.searchTerm = String.escapeSingleQuotes(searchTerm);
		}

		/**
		 * @description wrapper for searchConditions
		 *
		 * @param nestableCondition as input
		 */
		public void addSearchCondition(CMN_SOQL_Query.NestableCondition nestableCondition)
		{
			this.searchConditions.add(nestableCondition);
		}

		/**
		 * @description Will add an order by field to orderByFields list
		 *
		 * @param fieldName The name of the field to order results by
		 * @param sortDescending Set to true if you want to sort by field in descending order
		 *
		 * @return newly added order by field
		 */
		public CMN_SOQL_Query.OrderBy addOrderByField(String fieldName, Boolean sortDescending)
		{
			CMN_SOQL_Query.OrderBy orderByField = new CMN_SOQL_Query.OrderBy(fieldName);
			orderByField = sortDescending ? orderByField.descending() : orderByField.ascending();
			orderByFields.add(orderByField);
			return orderByField;
		}

		/**
		 * @description Will add an order by field to orderByFields list
		 *
		 * @param fieldName he name of the field to order results by; not this will ensure ordering is ascending
		 *
		 * @return newly added order by field
		 */
		public CMN_SOQL_Query.OrderBy addOrderByField(String fieldName)
		{
			return addOrderByField(fieldName, false);
		}

		/**
		 * @description add to select field list
		 *
		 * @param selectField as input
		 */
		public void addSelectField(String selectField)
		{
			selectFields.add(selectField);
		}
	}

	/**
	 * @description Class use for parameters get in SOQL
	 */
	public virtual class SOQLSearchParameters extends SearchParameters
	{
		/**
		 * @description The API names of the fields you would like to query
		 */
		public Set<String> searchFields;

		/**
		 * @description Comma delimited list of fields on which to group query
		 */
		public String groupBy;

		/**
		 * @description Set this if you intend querying child object via relationship fields
		 */
		public List<SOQLSearchParameters> childSearchParameters;
		/**
		 * @description Indicates if the
		 */
		@SuppressWarnings('ApexControlFlowAnalysis')
		private Boolean innerSelect;
		@SuppressWarnings('ApexControlFlowAnalysis')
		private String childPluralName;

		/**
		 * @description Constructor
		 *
		 * @param objectType as input
		 * @param searchTerm as input
		 */
		public SOQLSearchParameters(SObjectType objectType, String searchTerm)
		{
			super(objectType, searchTerm);

			searchFields = new Set<String>();

			if(String.isNotBlank(searchTerm))
			{
				this.searchTerm = String.format(SOQL_SEARCH_TERM_FMT, new List<String> {LIKE_WILD_CARD_CHAR, searchTerm});
				searchFields.add(CMN_DAL_SObjectDomain.FIELD_NAME);
			}

			childSearchParameters = new List<SOQLSearchParameters>();
			innerSelect = false;
			childPluralName = null;
		}

		/**
		 * @description Constructor
		 *
		 * @param objectName as input
		 * @param searchTerm as input
		 */
		public SOQLSearchParameters(String objectName, String searchTerm)
		{
			this(CMN_UTIL_System.getSObjectTypeByName(objectName), searchTerm);
		}

		/**
		 * @description Constructor
		 *
		 * @param objectName as input
		 */
		public SOQLSearchParameters(String objectName)
		{
			this(CMN_UTIL_System.getSObjectTypeByName(objectName), CMN_UTIL_String.EMPTY);
		}

		/**
		 * @description Constructor
		 *
		 * @param objectName as input
		 * @param selectFields as input
		 */
		public SOQLSearchParameters(String objectName, Set<String> selectFields)
		{
			this(CMN_UTIL_System.getSObjectTypeByName(objectName), CMN_UTIL_String.EMPTY);
			this.selectFields = selectFields;
		}

		/**
		 * @description Constructor for child inner SQL query
		 *
		 * @param objectName of the inner from object (not actually used)
		 * @param selectFields of the inner object
		 * @param childPluralName the from inner sobjectPlural_r e.g. OpportunityLineItems
		 */
		public SOQLSearchParameters(String objectName, Set<String> selectFields, String childPluralName)
		{
			this(objectName, selectFields);
			this.innerSelect = true;
			this.childPluralName = childPluralName;
		}

		/**
		 * @description Will get the object name from the search parameters
		 *
		 * @return object name or child plural name
		 */
		public String getObjectName()
		{
			return innerSelect ? childPluralName : this.objectName;
		}

		/**
		 * @description clears search fields populated with defaults
		 */
		public void clearSearchFields()
		{
			this.searchFields.clear();
		}
	}

	/**
	 * @description Class use for parameters search in SOQL
	 */
	public class SOSLSearchParameters extends SearchParameters
	{
		SOSLSearchGroup searchGroup = SOSLSearchGroup.ALL_FIELDS;
		/**
		 * @description Constructor
		 *
		 * @param objectType as input
		 * @param searchGroup as input
		 * @param searchTerm as input
		 */
		public SOSLSearchParameters(SObjectType objectType, SOSLSearchGroup searchGroup, String searchTerm)
		{
			super(objectType, searchTerm);

			this.searchTerm = searchTerm + SOSL_WILD_CARD;
			this.searchGroup = searchGroup;
		}
	}

	/**
	 * @description Class use search the response
	 */
	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	public class SearchResponse
	{
		public String queryString; /* query used to generate the search response */
		public Integer totalItems;
		public List<SObject> results = new List<SObject>();

		/**
		 * @description Constructor
		 */
		@SuppressWarnings('PMD.EmptyStatementBlock')
		public SearchResponse()
		{
		}
	}

	/**
	 * @description This method will generate a paged SOQL Query up to maximum of 50,000 rows will be returned
	 *
	 * @param parameters relevant search parameters for setting up a SOQL Query
	 *
	 * @return Results of the query, transformed from SObject and includes other details like number of records returned
	 */
	public static SearchResponse soqlSearch(SOQLSearchParameters parameters)
	{
		SearchResponse response = soqlQuery(parameters);

		//Use a SOQL For Loop to avoid heap size limit
		for(List<SObject> items : Database.query(response.queryString))
		{
			response.results.addAll(items);
		}

		if(!parameters.paged)
		{
			response.totalItems = response.results.size();
		}

		return response;
	}

	/**
	 * @description prepares the select fields as inner child queries
	 *
	 * @param parameters prepares the select fields as inner child queries
	 */
	private static void soqlChildQueries(SOQLSearchParameters parameters)
	{
		for(SOQLSearchParameters childSearch : parameters.childSearchParameters)
		{
			String childQuery = '(' + soqlQuery(childSearch).queryString + ')';
			parameters.selectFields.add(childQuery);
		}
	}

	/**
	 * @description Will create a search response object (with required SOQL query)
	 *
	 * @param parameters as input
	 *
	 * @return new object
	 *
	 * @see CMN_DAL_Search.SearchResponse
	 */
	@SuppressWarnings('PMD.CyclomaticComplexity')
	public static SearchResponse soqlQuery(SOQLSearchParameters parameters)
	{
		SearchResponse searchResponse = new SearchResponse();

		if(!parameters.searchFields.isEmpty())
		{
			CMN_SOQL_Query.OrCondition orFilter = new CMN_SOQL_Query.OrCondition();

			for(String searchField : parameters.searchFields)
			{
				orFilter.likeX(searchField, parameters.searchTerm);
			}

			parameters.searchConditions.add(orFilter);
		}

		Boolean isPaged = parameters.paged || parameters.randomResults;

		if(!parameters.innerSelect && isPaged)
		{
			// Will only run if above conditions are specified for paging
			// check how many rows we have, if there are no rows, we do not need to run a second query
			searchResponse.totalItems = getObjectCount(parameters);
		}

		soqlChildQueries(parameters);

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(parameters.selectFields)
						.fromX(parameters.getObjectName())
						.whereX(parameters.searchConditions)
						.groupByX(parameters.groupBy)
						.orderByX(parameters.orderByFields)
						.withSecurityEnforced(parameters.enforceSecurity);

		if(!parameters.innerSelect && (isPaged || parameters.pageSize > 0))
		{
			//Set the limit to be largest number provided
			builder.limitX(Math.max(MINIMUM_LIMIT, parameters.pageSize));
		}

		if(isPaged)
		{
			Integer offset;

			if(parameters.randomResults)
			{
				//When retrieving random results, the offset is calculated randomly from the total number of available rows
				offset = Math.min(CMN_UTIL_Random.getRandomInteger(Math.max(searchResponse.totalItems - parameters.pageSize - 1, 0)), MAX_OFFSET);
			}
			else
			{
				offset = parameters.offset;
			}

			builder.offsetX(offset);
		}

		searchResponse.queryString = builder.toSoql();

		return searchResponse;
	}

	/**
	 * @description This method will generate a paged SOQL Query up to maximum of 50,000 rows will be returned
	 *
	 * @param parameters as input
	 *
	 * @return results
	 */
	public static List<SObject> getObjects(SOSLSearchParameters parameters)
	{
		return soslSearch(parameters).results;
	}

	/**
	 * @description Base class containing the method to execute query and collect results
	 */
	@SuppressWarnings('PMD.ApexSharingViolations')
	private virtual class SharingProxy
	{
		protected virtual void getObjects(SearchResponse response)
		{
			//Use a SOQL For Loop to avoid heap size limit
			for(List<SObject> items : Database.query(response.queryString))
			{
				response.results.addAll(items);
			}
		}
	}

	/**
	 * @description Class will execute query and enforce sharing
	 */
	private with sharing class WithSharingProxy extends SharingProxy
	{
		protected override void getObjects(SearchResponse response)
		{
			super.getObjects(response);
		}
	}

	/**
	 * @description Class will execute query and bypass sharing
	 */
	private without sharing class NoSharingProxy extends SharingProxy
	{
		protected override void getObjects(SearchResponse response)
		{
			super.getObjects(response);
		}
	}

	/**
	 * @description This method will generate a paged SOQL Query based on the passed parameters
	 *
	 * @param parameters search parameters used to generate query
	 *
	 * @return results of the executed query
	 */
	public static List<SObject> getObjects(SOQLSearchParameters parameters)
	{
		SearchResponse response = soqlQuery(parameters);

		SharingProxy sharingProxy;

		if(parameters.enforceSharing == null)
		{
			sharingProxy = new SharingProxy();
		}
		else if(parameters.enforceSharing == false)
		{
			sharingProxy = new NoSharingProxy();
		}
		else
		{
			sharingProxy = new WithSharingProxy();
		}

		sharingProxy.getObjects(response);

		if(!parameters.paged)
		{
			response.totalItems = response.results.size();
		}

		return response.results;
	}

	/**
	 * @description Will return the count of objects based on the search parameters provided
	 *
	 * @param parameters search parameters used to generate query
	 *
	 * @return the number of items found
	 */
	public static Integer getObjectCount(SOQLSearchParameters parameters)
	{
		CMN_SOQL_Builder soqlCount =
				new CMN_SOQL_Builder()
						.selectCount()
						.fromX(parameters.objectName)
						.whereX(parameters.searchConditions);

		return Database.countQuery(soqlCount.toSoql());
	}

	/**
	 * @description Will return a random item using the select conditions provided
	 *
	 * @param parameters search parameters used to generate the query
	 *
	 * @return null or a random item
	 */
	public static SObject getRandomItem(SOQLSearchParameters parameters)
	{
		parameters.randomResults = true;
		List<SObject> foundItems = getObjects(parameters);

		return foundItems.isEmpty() ? null : foundItems.iterator().next();
	}

	/**
	 * @description Will return a random list of items that will be equal to or less than number of items
	 *
	 * @param parameters search parameters used to generate the query
	 * @param numberOfItems number of items to return
	 *
	 * @return A List containing random items found up to the number of items specified
	 */
	public static List<SObject> getRandomItems(SOQLSearchParameters parameters, Integer numberOfItems)
	{
		parameters.randomResults = true;
		parameters.pageSize = numberOfItems;

		return getObjects(parameters);
	}

	/**
	 * @description This method will generate a paged SOQL Query based on the passed parameters
	 * This method is generally discourages over the paging and offset method provided in getObjects
	 *
	 * @param parameters as input
	 *
	 * @return results
	 */
	public static Database.QueryLocator getQueryLocator(SOQLSearchParameters parameters)
	{
		return Database.getQueryLocator(soqlQuery(parameters).queryString);
	}

	/**
	 * @description This method will generate a paged SOQL Query based on the passed parameters
	 * This method returned grouped by aggregate query (important must include group by string)
	 *
	 * @param parameters as input
	 *
	 * @return results
	 */
	public static List<AggregateResult> getQueryAggregate(SOQLSearchParameters parameters)
	{
		return Database.query(soqlQuery(parameters).queryString);
	}

	/**
	 * @description This method will get the list of all SObject
	 *
	 * @param objectType as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> getAll(SObjectType objectType)
	{
		return getAll(objectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName());
	}

	/**
	 * @description This method will get the list of all SObjects
	 *
	 * @param objectName The API name of the object
	 * @param selectFields The list of fields to query
	 * @param limitNumberOfRows the number of records to limit the result too
	 *
	 * @return List of found items
	 */
	public static List<SObject> getAll(String objectName, Set<String> selectFields, Integer limitNumberOfRows)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(objectName, selectFields);
		searchParameters.pageSize = limitNumberOfRows;

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method will get the list of all SObjects
	 *
	 * @param objectName The API name of the object
	 * @param selectFields The list of fields to query
	 *
	 * @return List of found items
	 */
	public static List<SObject> getAll(String objectName, Set<String> selectFields)
	{
		return getAll(objectName, selectFields, MAX_PAGE_SIZE);
	}

	/**
	 * @description This method will get the list of all SObjects
	 *
	 * @param objectType The ObjectType of the object
	 * @param selectFields The list of fields to query
	 *
	 * @return List of found items
	 */
	public static List<SObject> getAll(SObjectType objectType, Set<String> selectFields)
	{
		return getAll(objectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName(), selectFields);
	}

	/**
	 * @description This method will get the list of all SObjects
	 *
	 * @param objectName TThe API name of the object
	 *
	 * @return List of found items
	 */
	public static List<SObject> getAll(String objectName)
	{
		return getAll(objectName, CMN_UTIL_String.EMPTY);
	}

	/**
	 * @description This method will get the list of all SObject
	 *
	 * @param objectName The API name of the object
	 * @param searchTerm as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> getAll(String objectName, String searchTerm)
	{
		Set<String> selectFields = CMN_UTIL_System.getAllFieldNames(objectName);

		CMN_DAL_Search.SOQLSearchParameters parameters = String.isBlank(searchTerm) ?
				new CMN_DAL_Search.SOQLSearchParameters(objectName) :
				new CMN_DAL_Search.SOQLSearchParameters(objectName, searchTerm);

		parameters.searchFields.clear();
		parameters.selectFields = selectFields;
		parameters.pageSize = MAX_PAGE_SIZE;

		return getObjects(parameters);

	}

	/**
	 * @description This method is use to provide the parameters and store the result using in SOSL
	 *
	 * @param parameters as input
	 *
	 * @return search response
	 */
	@SuppressWarnings('ApexUnusedDeclaration, PMD.UnusedLocalVariable')
	public static SearchResponse soslSearch(SOSLSearchParameters parameters)
	{
		SearchResponse searchResponse = new SearchResponse();

		//Compose individual SOSL Clauses to be joined into final Query
		String selectClause = CMN_UTIL_String.joinSet(parameters.selectFields, CMN_UTIL_String.COMMA);

		String whereClause = parameters.searchConditions.toSoql();

		if(String.isNotBlank(whereClause))
		{
			whereClause = SOSL_WHERE + whereClause;
		}

		String orderByClause = CMN_UTIL_String.EMPTY;

		List<String> orderByFields = new List<String>();

		for(CMN_SOQL_Query.OrderBy orderByField : parameters.orderByFields)
		{
			orderByFields.add(orderByField.toSoql());
		}

		orderByClause = orderByFields.isEmpty() ? orderByClause : SOSL_ORDER_BY + CMN_UTIL_String.joinArray(orderByFields, CMN_UTIL_String.COMMA);

		String offsetClause = CMN_UTIL_String.EMPTY;

		if(parameters.paged)
		{
			offsetClause = String.format(SOSL_LIMIT_FMT, new List<String> {String.valueOf(parameters.pageSize), String.valueOf(parameters.offset)});
		}

		//Put together the final SOSL Statement
		String query = String.format(SOSL_QUERY_FMT, new List<String>
		{
				SOSL_SEARCH_GROUP_VALUES.get(parameters.searchGroup),
				parameters.objectName,
				selectClause == null ? CMN_DAL_SObjectDomain.FIELD_ID : selectClause,
				whereClause == null ? CMN_UTIL_String.EMPTY : whereClause,
				orderByClause,
				offsetClause
		});

		//Create a simple variable so that we can bind the search term directly into the query
		String searchTerm = parameters.searchTerm;

		// searchResponse
		List<List<SObject>> searchResults = Search.query(query);

		if(!searchResults.isEmpty())
		{
			searchResponse.results.addAll(searchResults.iterator().next());
			//Since we cannot do a Count query with SOSL the total items is arbitrary unless we the results returned are less than that requested
			searchResponse.totalItems = searchResponse.results.size() < parameters.pageSize ? searchResponse.results.size() : MAX_PAGE_SIZE;
		}

		return searchResponse;
	}

	/**
	 * @description This method will generate a paged SOSL Query based on the passed parameters
	 *
	 * @param objectType The type of object that should be queried
	 * @param searchGroup The SOSL Search group https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_in.htm
	 * @param searchTerm The piece of text that should be search for
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> soslSearch(SObjectType objectType, SOSLSearchGroup searchGroup, String searchTerm)
	{
		return getObjects(new CMN_DAL_Search.SOSLSearchParameters(objectType, searchGroup, searchTerm));
	}

	/**
	 * @description Method will query all fields for given object, filtering list by Id
	 *
	 * @param objectName as input
	 * @param filterFieldName as input
	 * @param filterValue as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> findAllByAnyValue(String objectName, String filterFieldName, Object filterValue)
	{
		return findAllByAnyValues(objectName, filterFieldName, new Set<Object>
		{
				filterValue
		});
	}

	/**
	 * @description Method will query all fields for given object, filtering list set of values
	 *
	 * @param objectName as input
	 * @param filterFieldName as input
	 * @param filterValues as input
	 * @param getRelatedObject as input
	 *
	 * @return findResults
	 */
	public static List<SObject> findAllByAnyValues(String objectName, String filterFieldName, Set<Object> filterValues, Boolean getRelatedObject)
	{
		List<SObject> findResults = new List<SObject>();

		//if the current user has no access to object then return empty results
		if(CMN_UTIL_System.objectQueryable(objectName))
		{
			//Loop through all fields and put them in set if user has access to the field
			Set<String> selectFields = getRelatedObject ? CMN_UTIL_System.getNestableFieldNames(objectName) : CMN_UTIL_System.getAllFieldNames(objectName);

			//Now compose query and filter
			CMN_DAL_Search.SOQLSearchParameters parameters = new CMN_DAL_Search.SOQLSearchParameters(objectName, selectFields);

			if(String.isNotBlank(filterFieldName) && !filterValues.isEmpty())
			{
				List<Object> inFilterValues = new List<Object>(filterValues);
				parameters.searchConditions.inX(filterFieldName, inFilterValues);
			}

			findResults = getObjects(parameters);
		}

		return findResults;
	}

	/**
	 * @description Method will query all fields for given object, filtering list set of values
	 *
	 * @param objectName as input
	 * @param filterFieldName as input
	 * @param filterValues as input
	 *
	 * @return findResults
	 */
	private static List<SObject> findAllByAnyValues(String objectName, String filterFieldName, Set<Object> filterValues)
	{
		return findAllByAnyValues(objectName, filterFieldName, filterValues, false);
	}

	/**
	 * @description Method will query all fields for given object by Id
	 *
	 * @param objectName as input
	 * @param filterFieldName as input
	 * @param filterValues as input
	 * @param getRelatedObject as input
	 *
	 * @return findAllByAnyValues
	 */
	public static List<SObject> findAllById(String objectName, String filterFieldName, Set<Id> filterValues, Boolean getRelatedObject)
	{
		Set<Object> objectValues = new Set<Object>();

		for(Id filterValue : filterValues)
		{
			if(filterValue != null)
			{
				objectValues.add(filterValue);
			}
		}

		return findAllByAnyValues(objectName, filterFieldName, objectValues, getRelatedObject);
	}

	/**
	 * @description Method will query all fields for given object by Id
	 *
	 * @param objectName as input
	 * @param filterFieldName as input
	 * @param filterValue as input
	 * @param getRelatedObject as input
	 *
	 * @return findAllByAnyValues
	 */
	public static List<SObject> findAllById(String objectName, String filterFieldName, Id filterValue, Boolean getRelatedObject)
	{
		return findAllById(objectName, filterFieldName, new Set<Id> {filterValue}, getRelatedObject);
	}

	/**
	 * @description used for inner select conditional queries (wrapper method)
	 *
	 * @param whereInField as input
	 * @param selectParameters as input
	 *
	 * @return new SelectWhereInCondition
	 */
	public static SelectWhereInCondition selectWhereIn(String whereInField, SOQLSearchParameters selectParameters)
	{
		return new SelectWhereInCondition(whereInField, selectParameters);
	}

	/**
	 * @description support SELECT where conditions to a lookup
	 *
	 * @example
	 * WHERE <whereInField> IN (SELECT Id FROM XYZ WHERE Active__c = TRUE)
	 */
	public class SelectWhereInCondition implements CMN_SOQL_Query.Condition
	{
		private final String whereInField;
		private final SOQLSearchParameters selectParameters;

		@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
		public SelectWhereInCondition(String whereInField, SOQLSearchParameters selectParameters)
		{
			this.whereInField = whereInField;
			this.selectParameters = selectParameters;
		}

		@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
		public String toSoql()
		{
			return whereInField + SOQL_IN + '(' + soqlQuery(selectParameters).queryString + ')';
		}

		@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
		public String toSoql(CMN_SOQL_Query.SoqlOptions param)
		{
			return toSoql();
		}
	}

	/**
	 * @description used for inner select conditional queries (wrapper method)
	 *
	 * @param whereNotInField as input
	 * @param selectParameters as input
	 *
	 * @return a newly created condition
	 */
	public static SelectWhereNotInCondition selectWhereNotIn(String whereNotInField, SOQLSearchParameters selectParameters)
	{
		return new SelectWhereNotInCondition(whereNotInField, selectParameters);
	}

	/**
	 * @description support SELECT where conditions to a lookup
	 *
	 * @example
	 * WHERE <whereNotInField> NOT IN (SELECT Id FROM XYZ WHERE Active__c = TRUE)
	 */
	@SuppressWarnings('ApexControlFlowAnalysis')
	public class SelectWhereNotInCondition implements CMN_SOQL_Query.Condition
	{
		private final String whereNotInField;
		private final SOQLSearchParameters selectParameters;

		@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
		public SelectWhereNotInCondition(String whereNotInField, SOQLSearchParameters selectParameters)
		{
			this.whereNotInField = whereNotInField;
			this.selectParameters = selectParameters;
		}

		@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
		public String toSoql()
		{
			return whereNotInField + SOQL_NOT_IN + '(' + soqlQuery(selectParameters).queryString + ')';
		}

		@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
		public String toSoql(CMN_SOQL_Query.SoqlOptions param)
		{
			return toSoql();
		}
	}
}