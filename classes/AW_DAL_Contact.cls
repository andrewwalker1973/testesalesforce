/**
 * @description Public class to return the record of Contact
 *
 * @author prashant.k.jain@accenture.com pavan.t@lntinfotech.com
 *
 * @date May 2021, March 2023
 */
public inherited sharing class AW_DAL_Contact
{
	private static final String FIELD_ACCOUNT_OWNER_ID = 'Account.OwnerId';
	private static final String FIELD_ACCOUNT_PARENT_ACCOUNT = 'Account.AW_ParentAccount__c';
	private static final String FIELD_ACCOUNT_RECORD_TYPE_NAME = 'Account.RecordType.DeveloperName';
	private static final String FIELD_ACCOUNT_STATUS = 'Account.FinServ__Status__c';
	private static final String FIELD_BIRTHDATE = Contact.Birthdate.getDescribe().getLocalName();
	private static final String OBJECT_NAME = CMN_DAL_Contact.OBJECT_NAME;
	private static final String OBJECT_CHILD_LIFE_EVENTS = 'PersonLifeEvents';

	/**
	 * @description The default record types for contacts in the workbench application
	 */
	public static final String AW_INDIVIDUAL = 'AW_Individual';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				Contact.AW_Age__c.getDescribe().getLocalName(),
				Contact.AccountId.getDescribe().getLocalName(),
				Contact.Birthdate.getDescribe().getLocalName(),
				Contact.Email.getDescribe().getLocalName(),
				Contact.FirstName.getDescribe().getLocalName(),
				Contact.LastName.getDescribe().getLocalName(),
				Contact.Name.getDescribe().getLocalName(),
				Contact.Phone.getDescribe().getLocalName(),
				FIELD_ACCOUNT_OWNER_ID,
				FIELD_ACCOUNT_PARENT_ACCOUNT
		};
	}

	/**
	 * @description This method is use to get the record of Contact with related child objects
	 *
	 * @param contactIds A set of contact Ids
	 *
	 * @return a List of items
	 */
	public static List<Contact> findByIdWithChildDetails(Set<Id> contactIds)
	{
		CMN_SOQL_Builder lifeEventsSubQuery =
				new CMN_SOQL_Builder()
						.selectX(AW_DAL_PersonLifeEvent.getDefaultFields())
						.fromX(OBJECT_CHILD_LIFE_EVENTS);

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(getDefaultFields())
						.selectX(lifeEventsSubQuery)
						.fromX(OBJECT_NAME)
						.whereX(CMN_SOQL_Query.inX(CMN_DAL_SObjectDomain.FIELD_ID, CMN_UTIL_System.setToList(contactIds)));

		return Database.query(builder.toSoql());
	}

	/**
	 * @description This method is use to get the List of Contacts
	 *
	 * @param contactIds A List of Contact Ids
	 *
	 * @return List of items
	 */
	public static List<Contact> findById(Set<Id> contactIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, contactIds, getDefaultFields());
	}

	/**
	 * @description This method is use to get a single contact
	 *
	 * @param contactId The Id to find contact against
	 *
	 * @return Null or the found Item
	 */
	public static Contact findById(Id contactId)
	{
		return (Contact)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, contactId, getDefaultFields());
	}

	/**
	 * @description This method is use to get the List of Contacts of advisor between given birthdate ranges based on account recordtype
	 *
	 * @param ownerId Record Owner Id
	 * @param fromDate From Date or Date Variable
	 * @param toDate To Date or Date variable
	 * @param maxNumber The maximum number of records to retrieve
	 *
	 * @return List of found Items
	 */
	public static List<Contact> findByBirthdateRange(Id ownerId, Object fromDate, Object toDate, Integer maxNumber)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_OWNER_ID, new Set<String> {ownerId}, getDefaultFields());

		searchParameters.searchConditions.greaterThanOrEqualTo(FIELD_BIRTHDATE, fromDate);
		searchParameters.searchConditions.inX(FIELD_ACCOUNT_RECORD_TYPE_NAME, new List<String> {AW_DAL_Account.RT_BUSINESS_ACCOUNT, AW_DAL_Account.RT_PERSON_ACCOUNT});
		searchParameters.searchConditions.inX(FIELD_ACCOUNT_STATUS, new List<String> {AW_DAL_Account.STATUS_ACTIVE, AW_DAL_Account.STATUS_PROSPECT});
		searchParameters.searchConditions.lessThanOrEqualTo(FIELD_BIRTHDATE, toDate);
		searchParameters.addOrderByField(FIELD_BIRTHDATE, true);
		searchParameters.pageSize = maxNumber;

		return CMN_DAL_Search.getObjects(searchParameters);
	}
}