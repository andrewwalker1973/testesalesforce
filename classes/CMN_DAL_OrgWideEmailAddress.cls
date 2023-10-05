/**
 * @description Provides Query methods related to OrgWideEmailAddress object
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date March 2021, June 2022
 */
public inherited sharing class CMN_DAL_OrgWideEmailAddress
{
	private static final String FIELD_IS_ALLOW_ALL_PROFILES = OrgWideEmailAddress.IsAllowAllProfiles.getDescribe().getLocalName();
	private static final String OBJECT_NAME = OrgWideEmailAddress.SObjectType.getDescribe().getLocalName();

	/**
	 * @description The API name of the Address Field
	 */
	public static final String FIELD_ADDRESS = OrgWideEmailAddress.Address.getDescribe().getLocalName();

	/**
	 * @description Returns the default fields to return when querying the OrgWideEmailAddress Object
	 *
	 * @return A list of field names
	 */
	@TestVisible
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_ADDRESS,
				FIELD_IS_ALLOW_ALL_PROFILES,
				OrgWideEmailAddress.DisplayName.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will retrieve on or more OrgWideEmailAddresses
	 *
	 * @param addresses A list of Email Addresses
	 *
	 * @return A list of OrgWideEmailAddress
	 */
	public static List<OrgWideEmailAddress> findByName(Set<String> addresses)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_ADDRESS, addresses, getDefaultFields());
	}

	/**
	 * @description Will retrieve a random Org wide email address that is available to all profiles
	 *
	 * @return Either an email address object or null
	 */
	@TestVisible
	private static OrgWideEmailAddress getRandomItem()
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());
		searchParameters.searchConditions.equalsX(FIELD_IS_ALLOW_ALL_PROFILES, true);
		return (OrgWideEmailAddress)CMN_DAL_Search.getRandomItem(searchParameters);
	}

}