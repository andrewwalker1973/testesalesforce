/**
 * @description Public class to return the record of Person Life Event
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing class AW_DAL_PersonLifeEvent
{
	private static final String FIELD_EVENT_DATE = PersonLifeEvent.EventDate.getDescribe().getLocalName();
	private static final String FIELD_PRIMARY_PERSON_ID = PersonLifeEvent.PrimaryPersonId.getDescribe().getLocalName();
	private static final String FIELD_VISIBLE_TO_CLIENT = PersonLifeEvent.AW_VisibleToClient__c.getDescribe().getLocalName();
	private static final String OBJECT_NAME = PersonLifeEvent.SObjectType.getDescribe().getLocalName();
	public static final String MARRIAGE_EVENT_TYPE = 'Marriage';

	/**
	 * @description Method to define the fields to retrieve for most queries
	 *
	 * @return A list of fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_EVENT_DATE,
				PersonLifeEvent.AW_ClientCommunityIcon__c.getDescribe().getLocalName(),
				PersonLifeEvent.AW_ImpactOnOutcomeGoals__c.getDescribe().getLocalName(),
				PersonLifeEvent.AW_Impact__c.getDescribe().getLocalName(),
				PersonLifeEvent.AW_MasterAccount__c.getDescribe().getLocalName(),
				PersonLifeEvent.AW_PriorityLevel__c.getDescribe().getLocalName(),
				PersonLifeEvent.AW_SortingDate__c.getDescribe().getLocalName(),
				PersonLifeEvent.EventDate.getDescribe().getLocalName(),
				PersonLifeEvent.EventDescription.getDescribe().getLocalName(),
				PersonLifeEvent.Id.getDescribe().getLocalName(),
				PersonLifeEvent.OwnerId.getDescribe().getLocalName(),
				PersonLifeEvent.Name.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Method to get the list of Person Life Event of Contact
	 *
	 * @param contactId
	 *
	 * @return List of PersonLifeEvent
	 */
	public static List<PersonLifeEvent> findByPrimaryPerson(Id contactId)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_PRIMARY_PERSON_ID, new Set<String> {String.valueOf(contactId)}, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_VISIBLE_TO_CLIENT, CMN_SOQL_Query.Operator.EQUALS, true));
		searchParameters.searchConditions.add(andCondition);

		CMN_SOQL_Query.OrderBy orderBy = searchParameters.addOrderByField(FIELD_EVENT_DATE);
		orderBy.nullsFirst = true;

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Method to get the a Person Life Event
	 *
	 * @param eventId Id of the event
	 *
	 * @return Null of the item
	 */
	@TestVisible
	private static PersonLifeEvent findById(Id eventId)
	{
		return (PersonLifeEvent)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, eventId, getDefaultFields());
	}
}