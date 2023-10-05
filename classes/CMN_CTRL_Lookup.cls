/**
 * @description Common object lookup controller used to perform searches on the LWC Lookup component. See cmnLwcLookup.
 *
 * @see CMN_CTRL_Lookup_TEST
 *
 * @author aakriti.a.goyal@accenture.com, jason.van.beukering@accenture.com
 *
 * @date February 2022, June 2023
 */
public inherited sharing class CMN_CTRL_Lookup
{
	/**
	 * @description Returns a list of SObjects based on a search term and which SObject it is searching
	 *
	 * @param objectName SObject API name to search through
	 * @param searchTerm Search term to match the Name fields of the SObject
	 * @param selectFields Comma seperated list of field API names to retrieve from the query
	 * @param maximumNumberOfResults Maximum number of records to return
	 *
	 * @return List of SObjects whose Name fields is contain the search term (uses SOSL search)
	 */
	@AuraEnabled(Cacheable=true)
	public static List<SObject> findSObjectBySearchTerm(String objectName, String searchTerm, String selectFields, Integer maximumNumberOfResults)
	{
		CMN_DAL_Search.SOSLSearchParameters searchParameters = new CMN_DAL_Search.SOSLSearchParameters
				(
						CMN_UTIL_System.getSObjectTypeByName(objectName),
						CMN_DAL_Search.SOSLSearchGroup.ALL_FIELDS,
						searchTerm
				);

		searchParameters.selectFields.addAll(CMN_UTIL_System.convertStringToSet(selectFields, CMN_UTIL_String.COMMA));
		searchParameters.pageSize = maximumNumberOfResults;
		searchParameters.paged = true;

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Returns an SObject by its Id
	 *
	 * @param objectName API Name of SObject
	 * @param recordId Record Id of SObject
	 * @param selectFields Comma seperated list of field API names to retrieve from the query
	 *
	 * @return SObject whose Id field matches recordId
	 */
	@AuraEnabled(Cacheable=true)
	public static SObject findById(String objectName, Id recordId, String selectFields)
	{
		return CMN_DAL_SObjectSelector.findById(objectName, recordId, CMN_UTIL_System.convertStringToSet(selectFields, CMN_UTIL_String.COMMA));
	}
}