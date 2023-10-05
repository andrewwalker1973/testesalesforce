/**
 * @description Public class to return the record of Country
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date 2019, March 2022
 */
public inherited sharing class AW_DAL_Country
{
	private static final String FIELD_CODE = AW_Country__c.AW_CountryCode__c.getDescribe().getLocalName();

	/**
	 * @description field stores the length of country code
	 */
	public static final Integer COUNTRY_CODE_LENGTH = 5;
	/**
	 * @description field stores the value of a country India
	 */
	public static final String INDIA = 'India';
	/**
	 * @description field stores the value of a country South Africa
	 */
	public static final String SOUTH_AFRICA = 'South Africa';
	/**
	 * @description field stores the value of a country USA
	 */
	public static final String UNITED_STATES = 'United States';

	/**
	 * @description Returns the common fields for most queries
	 *
	 * @return A list of fields
	 */
	@TestVisible
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				AW_Country__c.Id.getDescribe().getLocalName(),
				AW_Country__c.Name.getDescribe().getLocalName(),
				FIELD_CODE
		};
	}

	/**
	 * @description Methos is to return all the record of Country object
	 *
	 * @return A list of items
	 */
	public static List<AW_Country__c> getAll()
	{
		return CMN_DAL_Search.getAll(AW_Country__c.SObjectType, getDefaultFields());
	}

	/**
	 * @description Method is to return all the country by name
	 *
	 * @param countryName The name of the country
	 *
	 * @return either null or the country
	 */
	public static AW_Country__c findByName(String countryName)
	{
		return (AW_Country__c)CMN_DAL_SObjectSelector.findByName(AW_Country__c.SObjectType, countryName, getDefaultFields());
	}

	/**
	 * @description Method is to return all the country by Id
	 *
	 * @param countryId The Id of the country
	 *
	 * @return either null or item
	 */
	public static AW_Country__c findById(Id countryId)
	{
		return (AW_Country__c)CMN_DAL_SObjectSelector.findById(AW_Country__c.SObjectType, countryId, getDefaultFields());
	}

	/**
	 * @description Method is to return a list of countries by Ids
	 *
	 * @param countryIds set of Country Ids
	 *
	 * @return List of Countries
	 */
	public static List<AW_Country__c> findById(Set<Id> countryIds)
	{
		return CMN_DAL_SObjectSelector.findById(AW_Country__c.SObjectType, countryIds, getDefaultFields());
	}

	/**
	 * @description Will return countries in a map based on the field name provided
	 *
	 * @param fieldName SObject API field Name
	 *
	 * @return A map with one or more items
	 */
	private static Map<String, SObject> getFieldMap(String fieldName)
	{
		return CMN_UTIL_System.convertListToSingleStringMap(getAll(), fieldName);
	}

	/**
	 * @description Will query all configured countries and return a map with country code as the key
	 *
	 * @return A map of countries
	 */
	public static Map<String, SObject> getCodeMap()
	{
		return getFieldMap(FIELD_CODE);
	}

	/**
	 * @description Will query all configured countries and return a map with country name as the key
	 *
	 * @return A map of countries
	 */
	public static Map<String, SObject> getNameMap()
	{
		return getFieldMap(CMN_DAL_SObjectDomain.FIELD_NAME);
	}
}