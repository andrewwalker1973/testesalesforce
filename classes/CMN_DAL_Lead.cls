/**
 * @description Provides query operations for retrieving Leads
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date 2019, August 2023
 */
public inherited sharing class CMN_DAL_Lead
{
	public static final String FIELD_STATUS = Lead.Status.getDescribe().getLocalName();
	public static final String OBJECT_NAME = Lead.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Will generate a query that finds all leads by ownerId
	 *
	 * @param ownerId Owner of the Lead
	 *
	 * @return a SOQL query
	 */
	private static String findAllByOwnerIdQueryString(Id ownerId)
	{
		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(CMN_UTIL_System.getAllFieldNames(OBJECT_NAME))
						.fromX(OBJECT_NAME)
						.whereX(new CMN_SOQL_Query.FieldCondition(CMN_DAL_SObjectDomain.FIELD_OWNER_ID, CMN_SOQL_Query.Operator.EQUALS, ownerId));

		return builder.toSoql();
	}

	/**
	 * @description Will generate a query locator that finds all leads by ownerId
	 *
	 * @param ownerId Owner of the Lead
	 *
	 * @return query locator generated
	 */
	public static Database.QueryLocator findAllByOwnerIdQuery(Id ownerId)
	{
		return Database.getQueryLocator(findAllByOwnerIdQueryString(ownerId));
	}

	/**
	 * @description This method is use to return the list of Lead by owner Id
	 *
	 * @param ownerId wner of the Lead
	 *
	 * @return list of items
	 */
	@TestVisible
	private static List<Lead> findAllByOwnerId(Id ownerId)
	{
		return Database.query(findAllByOwnerIdQueryString(ownerId));
	}

	/**
	 * @description Will return all leads in the system
	 *
	 * @return A list of leads
	 */
	@TestVisible
	private static List<Lead> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME);
	}
}