/**
 * @description Public class to return the records of contact
 *
 * @author m.sudharkar.rokde@accenture.com
 *
 * @date 2021, February 2022
 */
public inherited sharing class SC_DAL_Contact
{
	private static final String OBJECT_NAME = Contact.SObjectType.getDescribe().getLocalName();
	private static final String RT_CONSULTANT_CODES = 'ConsultantCodes__r';
	/**
	 * @description Used in the SRS integration to populate the Party ID for the Adviser
	 */
	public static final String FIELD_PARTY_ID = Contact.CMN_SRSPartyID__c.getDescribe().getLocalName();
	/**
	 * @description stores the DeveloperName of Liberty Practice Member RecordType
	 */
	public static final String RT_ADVISER = 'AW_PracticeMember';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_DAL_SObjectDomain.FIELD_CREATED_DATE,
				CMN_DAL_SObjectDomain.FIELD_ID,
				CMN_DAL_SObjectDomain.FIELD_LAST_MODIFIED_DATE,
				CMN_DAL_SObjectDomain.FIELD_RECORD_TYPE_ID,
				Contact.AW_IdentificationNumber__c.getDescribe().getLocalName(),
				Contact.AccountId.getDescribe().getLocalName(),
				Contact.CMN_AQCCode__c.getDescribe().getLocalName(),
				Contact.CMN_SRSPartyID__c.getDescribe().getLocalName(),
				Contact.FirstName.getDescribe().getLocalName(),
				Contact.LastName.getDescribe().getLocalName(),
				FIELD_PARTY_ID

		};
	}

	/**
	 * @description Will return all Contacts created by unit tests
	 *
	 * @return A list of contact
	 */
	@TestVisible
	private static List<Contact> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description This method is use to get Contacts with the given set of Id
	 *
	 * @param contactIds The Set of contact Ids to retrieve
	 *
	 * @return List of found Cases
	 */
	public static List<Contact> findById(Set<Id> contactIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, contactIds, getDefaultFields());
	}

	/**
	 * @description Will find a list of contact by party Id
	 *
	 * @param partyIds The Set of party Id  to retrieve
	 *
	 * @return List of Contact
	 */
	public static List<Contact> findByPartyId(Set<String> partyIds)
	{
		CMN_SOQL_Builder consultantRecords =
				new CMN_SOQL_Builder()
						.selectX(SC_DAL_ConsultantCodes.getDefaultFields())
						.fromX(RT_CONSULTANT_CODES);

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();
		andCondition.inX(FIELD_PARTY_ID, CMN_UTIL_Set.setToList(partyIds));

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(getDefaultFields())
						.selectX(consultantRecords)
						.fromX(OBJECT_NAME)
						.whereX(andCondition);

		return Database.query(builder.toSoql());
	}
}