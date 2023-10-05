/**
 * @description Selector class for querying EntityDefinition records
 *
 * @see EntityDefinition
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date July 2022
 */
public inherited sharing class CMN_DAL_EntityDefinition
{
	/**
	 * @description Used to cache entities in org to reduce number of queries in a transaction
	 */
	private static Map<String, SObject> apiNameToDefinitionMap;
	private static final String FIELD_IS_ID_ENABLED = EntityDefinition.IsIdEnabled.getDescribe().getLocalName();
	private static final String FIELD_IS_SEARCHABLE = EntityDefinition.IsSearchable.getDescribe().getLocalName();
	private static final String FIELD_IS_TRIGGERABLE = EntityDefinition.IsTriggerable.getDescribe().getLocalName();
	private static final String OBJECT_NAME = EntityDefinition.SObjectType.getDescribe().getLocalName();

	/**
	 * @description API name for the field that describes the Fully Qualified API Name of the Standard or Custom Object
	 */
	public static final String FIELD_QUALIFIED_API_NAME = EntityDefinition.QualifiedApiName.getDescribe().getLocalName();
	/**
	 * @description Picklist value of Private for Sharing Model
	 */
	public static final String SHARING_MODEL_PRIVATE = 'Private';
	/**
	 * @description Picklist value of Read for Sharing Model
	 */
	public static final String SHARING_MODEL_READ = 'Read';
	/**
	 * @description Picklist value of ReadWrite for Sharing Model
	 */
	public static final String SHARING_MODEL_READ_WRITE = 'ReadWrite';
	/**
	 * @description A list of the common fields to query
	 *
	 * @return A set of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				EntityDefinition.InternalSharingModel.getDescribe().getLocalName(),
				FIELD_QUALIFIED_API_NAME
		};
	}

	/**
	 * @description Will find Entity Definition records for the provided set of Qualified API Names
	 *
	 * @param qualifiedApiNames Set of Qualified API Names
	 *
	 * @return A list of found items
	 */
	public static List<EntityDefinition> getByQualifiedApiNames(Set<String> qualifiedApiNames)
	{
		if(apiNameToDefinitionMap == null)
		{
			CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());
			CMN_DAL_Search.SearchResponse response = CMN_DAL_Search.soqlQuery(searchParameters);
			apiNameToDefinitionMap = CMN_UTIL_System.convertListToSingleStringMap(Database.query(response.queryString), FIELD_QUALIFIED_API_NAME);
		}

		List<SObject> foundDefinitions = new List<SObject>();

		for(String qualifiedApiName : qualifiedApiNames)
		{
			SObject definition = apiNameToDefinitionMap.get(qualifiedApiName);

			if(definition != null)
			{
				foundDefinitions.add(definition);
			}
		}

		return foundDefinitions;
	}

	/**
	 * @description Will get all Items that are valid for Apex Sharing (excluding their org-wide setting which we cannot filter against)
	 *
	 * @return A list of found items
	 */
	@TestVisible
	private static List<EntityDefinition> getAllApexShareable()
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());
		searchParameters.pageSize = CMN_DAL_Search.MAX_PAGE_SIZE;
		searchParameters.paged = true; //Note this is important, without setting an Offset this query fails
		searchParameters.searchConditions.equalsX(FIELD_IS_ID_ENABLED, true);
		searchParameters.searchConditions.equalsX(FIELD_IS_SEARCHABLE, true);
		searchParameters.searchConditions.equalsX(FIELD_IS_TRIGGERABLE, true);
		return CMN_DAL_Search.getObjects(searchParameters);
	}
}