/**
 * @description Selector class for querying CMN_ObjectShareConfiguration__c records
 *
 * @see CMN_ObjectShareConfiguration__c
 *
 * @author vishakha.saini@accenture.com jason.van.beukering@accenture.com
 *
 * @date August 2022
 */
public inherited sharing class CMN_DAL_ObjectShareConfiguration implements Cache.CacheBuilder
{
	/**
	 * @description Fixed key name for the cache
	 */
	private static final String CACHE_KEY_NAME = 'ObjectShareConfigurations';
	/**
	 * @description API name for the field that describes the owner name of a record whose records should be shared
	 */
	private static final String FIELD_SHARE_FROM_NAME = 'CMN_ShareFrom__r.Name';
	/**
	 * @description API name for the field that describes the the name of the user to which the records should be shared
	 */
	private static final String FIELD_SHARE_WITH_NAME = 'CMN_ShareWith__r.Name';
	/**
	 * @description Access level setting that will ensure an object is shared with "Edit" access
	 */
	public static final String ACCESS_LEVEL_EDIT = 'Edit';
	/**
	 * @description Access level setting that will ensure an object is shared with "Read" access
	 */
	public static final String ACCESS_LEVEL_READ = 'Read';
	/**
	 * @description API name for field describing the API name of the object for which this configuration should be applied
	 */
	public static final String FIELD_OBJECT_API_NAME = CMN_ObjectShareConfiguration__c.CMN_ObjectAPIName__c.getDescribe().getLocalName();
	/**
	 * @description API name for the field that describes the owner of a record whose records should be shared
	 */
	public static final String FIELD_SHARE_FROM = CMN_ObjectShareConfiguration__c.CMN_ShareFrom__c.getDescribe().getLocalName();
	/**
	 * @description API name for the object
	 */
	public static final String OBJECT_NAME = CMN_ObjectShareConfiguration__c.SObjectType.getDescribe().getLocalName();

	/**
	 * @description A list of the common fields to query
	 *
	 * @return A set of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_ObjectShareConfiguration__c.CMN_AccessLevel__c.getDescribe().getLocalName(),
				CMN_ObjectShareConfiguration__c.CMN_ShareWith__c.getDescribe().getLocalName(),
				FIELD_OBJECT_API_NAME,
				FIELD_SHARE_FROM,
				FIELD_SHARE_FROM_NAME,
				FIELD_SHARE_WITH_NAME
		};
	}

	/**
	 * @description Contains the logic that builds a cached value.
	 * You don’t call this method directly.
	 * Instead, it’s called indirectly when you reference the class that implements the CacheBuilder interface.
	 *
	 * @param param1 A case-sensitive string value used to build a cached value, isn't used as we get all items
	 *
	 * @return A list of Share configuration
	 */
	public Object doLoad(String param1)
	{
		return getAll();
	}

	/**
	 * @description Will retrieve all share configurations from the platform cache
	 *
	 * @return List of items
	 */
	public static List<CMN_ObjectShareConfiguration__c> getAllFromCache()
	{
		return (List<CMN_ObjectShareConfiguration__c>)Cache.Org.get(CMN_DAL_ObjectShareConfiguration.class, CACHE_KEY_NAME); //key isn't used as we get all items
	}

	/**
	 * @description Will clear the cache so that configuration objects are retrieved again
	 */
	public static void clearCache()
	{
		Cache.Org.remove(CMN_DAL_ObjectShareConfiguration.class, CACHE_KEY_NAME);
	}

	/**
	 * @description Will get all configuration rows
	 *
	 * @return A list of items
	 */
	private static List<CMN_ObjectShareConfiguration__c> getAll()
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());
		searchParameters.pageSize = CMN_DAL_Search.LIMIT_NUMBER_OF_RECORDS;
		searchParameters.enforceSharing = false;

		return CMN_DAL_Search.getObjects(searchParameters);
	}
}