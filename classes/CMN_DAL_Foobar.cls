/**
 * @description Provides Query methods related to Foo object
 *
 * @see CMN_Foobar__c
 *
 * @author prashant.k.jain@accenture.com jason.van.beukering@accenture.com
 *
 * @date 2020, June 2023
 */
public inherited sharing class CMN_DAL_Foobar
{
	@TestVisible
	private static final String FIELDSET_DEFAULT = 'CMN_Default';
	@TestVisible
	private static final String FIELDSET_FOOBAR = 'CMN_FoobarSet';
	@TestVisible
	private static final String FIELD_EMAIL = CMN_Foobar__c.CMN_Email__c.getDescribe().getName();
	@TestVisible
	private static final String FIELD_LOOKUP = CMN_Foobar__c.CMN_Lookup__c.getDescribe().getName();
	@TestVisible
	private static final String FIELD_MULTIPICKLIST = CMN_Foobar__c.CMN_PicklistMultiSelect__c.getDescribe().getLocalName();
	@TestVisible
	private static final String FIELD_NAME = CMN_DAL_SObjectDomain.FIELD_NAME;
	@TestVisible
	private static final String FIELD_PHONE = CMN_Foobar__c.CMN_Phone__c.getDescribe().getName();
	@TestVisible
	private static final String RELATIONSHIP_FOOBARS = 'CMN_Foobars__r';

	/**
	 * @description API Name for the picklist field
	 */
	public static final String FIELD_PICKLIST = CMN_Foobar__c.CMN_Picklist__c.getDescribe().getName();

	/**
	 * @description Default record type to be used when creating FooBar objects
	 */
	public static final String RT_DEFAULT = 'CMN_DefaultFoobar';

	/**
	 * @description API name for the object
	 */
	@TestVisible
	private static final String OBJECT_NAME = CMN_Foobar__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();

	/**
	 * @description The default fields to query from the Account Object
	 *
	 * @return A list of Account fields
	 */
	@TestVisible
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				'CMN_Lookup__r.Name',
				CMN_Foobar__c.CMN_Checkbox__c.getDescribe().getName(),
				CMN_Foobar__c.CMN_Datetime__c.getDescribe().getName(),
				CMN_Foobar__c.CMN_NumberInteger__c.getDescribe().getName(),
				CMN_Foobar__c.CMN_Text__c.getDescribe().getName(),
				CMN_Foobar__c.CreatedById.getDescribe().getName(),
				CMN_Foobar__c.CreatedDate.getDescribe().getName(),
				CMN_Foobar__c.IsDeleted.getDescribe().getName(),
				CMN_Foobar__c.LastModifiedById.getDescribe().getName(),
				CMN_Foobar__c.LastModifiedDate.getDescribe().getName(),
				CMN_Foobar__c.LastViewedDate.getDescribe().getName(),
				CMN_Foobar__c.OwnerId.getDescribe().getName(),
				CMN_Foobar__c.RecordTypeId.getDescribe().getName(),
				FIELD_EMAIL,
				FIELD_LOOKUP,
				FIELD_MULTIPICKLIST,
				FIELD_NAME,
				FIELD_PHONE,
				FIELD_PICKLIST
		};
	}

	/**
	 * @description Will return all the Foobar objects in the system
	 *
	 * @return A list of Foobar objects
	 */
	@TestVisible
	private static List<CMN_Foobar__c> getAll()
	{
		return getAll(getDefaultFields());
	}

	/**
	 * @description Will return all the Foobar objects in the system
	 *
	 * @param selectFields The list of fields to query
	 *
	 * @return A list of Foobar objects
	 */
	@TestVisible
	private static List<CMN_Foobar__c> getAll(Set<String> selectFields)
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, selectFields);
	}

	/**
	 * @description Will return all the Foobar objects with their related children
	 *
	 * @return A list of Foobar objects with their related child objects
	 */
	@TestVisible
	private static List<CMN_Foobar__c> getAllWithChildren()
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());
		searchParameters.childSearchParameters.add(new CMN_DAL_Search.SOQLSearchParameters
				(
						OBJECT_NAME,
						getDefaultFields(),
						RELATIONSHIP_FOOBARS
				));

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description returns query aggregated for grouped by records
	 *
	 * @return list of aggregate result data
	 */
	@TestVisible
	private static List<AggregateResult> countNameById()
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME);
		searchParameters.setSecurityEnforced(false);
		searchParameters.clearSelectFields();
		searchParameters.clearSearchFields();
		searchParameters.selectFields.add('COUNT(Name)');
		searchParameters.groupBy = CMN_DAL_SObjectDomain.FIELD_ID;
		return CMN_DAL_Search.getQueryAggregate(searchParameters);
	}

	/**
	 * @description Get a Foobar record
	 *
	 * @param foobarId Id of the foobar record
	 *
	 * @return Null or the item found
	 */
	@TestVisible
	private static CMN_Foobar__c findById(Id foobarId)
	{
		return (CMN_Foobar__c)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, foobarId, getDefaultFields());
	}

	/**
	 * @description demonstrates select where in
	 *
	 * @param ids as input
	 *
	 * @return list of product components where the family lookup is active
	 *
	 * @example
	 * SELECT Id, Name, ...
	 * FROM CMN_Foobar__c WHERE
	 * (Id IN (SELECT Id FROM User WHERE (Active__c = true))
	 *  AND Id IN ('a084K000000ZMXyQAO')) WITH SECURITY_ENFORCED
	 */
	@TestVisible
	private static List<CMN_Foobar__c> selectWithChildBasedOnLookupWhereIn(Set <Id> ids)
	{
		CMN_DAL_Search.SOQLSearchParameters childParameters =
				new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_User.OBJECT_NAME, new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID});
		childParameters.addSearchCondition(CMN_SOQL_Query.andX().equalsX(CMN_DAL_User.FIELD_IS_ACTIVE, true));

		CMN_DAL_Search.SOQLSearchParameters parentParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());
		parentParameters.addSelectField(CMN_Foobar__c.LastModifiedDate.getDescribe().getName());
		parentParameters.searchConditions.add(CMN_DAL_Search.selectWhereIn(CMN_DAL_SObjectDomain.FIELD_OWNER_ID, childParameters));
		parentParameters.searchConditions.add(CMN_SOQL_Query.inX(CMN_DAL_SObjectDomain.FIELD_ID, new List <Id>(ids)));

		return CMN_DAL_Search.getObjects(parentParameters);
	}

	/**
	 * @description demonstrates select where not in (select) e.g.
	 *
	 * @param ids as input
	 *
	 * @return list of product components where the family lookup is active
	 *
	 * @example
	 * SELECT Id, Name, ...
	 * FROM CMN_Foobar__c WHERE
	 * (Id NOT IN (SELECT Id FROM User WHERE (Active__c = true))
	 *  AND Id IN ('a084K000000ZMXyQAO')) WITH SECURITY_ENFORCED
	 */
	@TestVisible
	private static List<CMN_Foobar__c> selectWithChildBasedOnLookupWhereNotIn(Set <Id> ids)
	{
		CMN_DAL_Search.SOQLSearchParameters childParameters =
				new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_User.OBJECT_NAME, new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID});
		childParameters.addSearchCondition(CMN_SOQL_Query.andX().equalsX(CMN_DAL_User.FIELD_IS_ACTIVE, false));

		CMN_DAL_Search.SOQLSearchParameters parentParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());
		parentParameters.searchConditions.add(CMN_DAL_Search.selectWhereNotIn(CMN_DAL_SObjectDomain.FIELD_OWNER_ID, childParameters));
		parentParameters.searchConditions.add(CMN_SOQL_Query.inX(CMN_DAL_SObjectDomain.FIELD_ID, new List <Id>(ids)));

		return CMN_DAL_Search.getObjects(parentParameters);
	}
}