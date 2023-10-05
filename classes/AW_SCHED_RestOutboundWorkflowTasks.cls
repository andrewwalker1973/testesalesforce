/**
 * @description Scheduler class to initiate Outbound call for retrieving Workflow Tasks.
 *
 * @see AW_TEST_SCHED_WorkflowTasks ST -2338
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date July 2023
 */
public inherited sharing class AW_SCHED_RestOutboundWorkflowTasks extends CMN_SCHED_BaseScheduleAPICalls
{
	private static final String COUNT_FIELD = 'countId';

	/**
	 * @description Returns the name of the scheduled class and is used to retrieve custom metadata settings
	 *
	 * @return the schedule name
	 */
	protected override String getScheduleName()
	{
		return AW_SCHED_RestOutboundWorkflowTasks.class.getName();
	}

	/**
	 * @description Returns the name of the web service class that will be executed by this schedule
	 *
	 * @return the webservice name
	 */
	protected override String getWebServiceName()
	{
		return AW_API_RestOutboundWorkflowTasks.SERVICE_NAME;
	}

	/**
	 * @description Counts the number  of users that are active and with a consultant code
	 *
	 * @return number of rows to process
	 */
	protected override Integer getNumberOfRowsToProcess()
	{
		Integer numberOfRowsToProcess = super.getNumberOfRowsToProcess();

		//Figure out how many items we need to retrieve and then use this to calculate how many jobs to do
		List<AggregateResult> countResults =
		[
				SELECT COUNT(Id) countId
				FROM User
				WHERE AW_ConsultantCode__c != NULL
				AND IsActive = TRUE
		];

		numberOfRowsToProcess = Integer.valueOf(countResults[0].get(COUNT_FIELD));

		return numberOfRowsToProcess;
	}

	/**
	 * @description Constructs a query to retrieve the number of users that are active with a consultant code
	 *
	 * @return the query to execute
	 */
	protected override String getObjectQuery()
	{
		String objectQuery = super.getObjectQuery();

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(AW_DAL_User.FIELD_CONSULTANT_CODE, CMN_SOQL_Query.Operator.NOT_EQUALS, null));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(AW_DAL_User.FIELD_IS_ACTIVE, CMN_SOQL_Query.Operator.EQUALS, true));

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(new List<String> {CMN_DAL_SObjectDomain.FIELD_ID, AW_DAL_User.FIELD_CONSULTANT_CODE})
						.fromX(CMN_DAL_User.OBJECT_NAME)
						.whereX(andCondition);

		objectQuery = builder.toSoql();

		return objectQuery;
	}

	/**
	 * @description Creates a queueItem based on Id and Consultant Code
	 *
	 * @param obj the object with which to populate the webservice queue object from
	 *
	 * @return an initialised queue item
	 */
	protected override CMN_WebserviceCallQueue__c createQueueItem(SObject obj)
	{
		CMN_WebserviceCallQueue__c queueItem = super.createQueueItem(obj);
		queueItem.CMN_PartnerCode__c = ((User)obj).AW_ConsultantCode__c;
		return queueItem;
	}
}