/**
 * @description A scheduled class that will retrieve compose service calls to retrieve all Activity Measures for Active Users
 *
 * @see AW_TEST_SCHED_RestAdviserPerformance @story ST-3495
 *
 * @author Accenture
 *
 * @date 2019, July 2023
 */
public inherited sharing class AW_SCHED_RestOutboundAdviserPerformance extends CMN_SCHED_BaseScheduleAPICalls
{
	private static final String COUNT_FIELD = 'countId';

	/**
	 * @description Returns the name of the scheduled class and is used to retrieve custom metadata settings
	 *
	 * @return the name of the scheduled class
	 */
	protected override String getScheduleName()
	{
		String serviceName = super.getScheduleName();//execute parent class code for code coverage
		serviceName = AW_SCHED_RestOutboundAdviserPerformance.class.getName();
		return serviceName;
	}

	/**
	 * @description Returns the name of the web service class that will be executed by this schedule
	 *
	 * @return the name of the webservice
	 */
	protected override String getWebServiceName()
	{
		String serviceName = super.getWebServiceName();//execute parent class code for code coverage
		serviceName = AW_API_RestOutboundAdviserPerformance.SERVICE_NAME;
		return serviceName;
	}

	/**
	 * @description Counts the number of users that are active and with an uacfId
	 *
	 * @return the number of rows to process
	 */
	protected override Integer getNumberOfRowsToProcess()
	{
		Integer numberOfRowsToProcess = super.getNumberOfRowsToProcess();

		//Figure out how many items we need to retrieve and then use this to calculate how many jobs to do
		List<AggregateResult> countResults =
		[
				SELECT COUNT(Id) countId
				FROM User
				WHERE AW_UACFID__c != NULL
				AND IsActive = TRUE
				AND UserType = :CMN_DAL_User.PICK_USER_TYPE_STANDARD
		];

		numberOfRowsToProcess = Integer.valueOf(countResults[0].get(COUNT_FIELD));

		return numberOfRowsToProcess;
	}

	/**
	 * @description Constructs a query to retrieve the number of users that are active with a uacfId
	 *
	 * @return the query to execute
	 */
	protected override String getObjectQuery()
	{
		String objectQuery = super.getObjectQuery();

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(AW_DAL_User.FIELD_UACF_ID, CMN_SOQL_Query.Operator.NOT_EQUALS, null));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(AW_DAL_User.FIELD_IS_ACTIVE, CMN_SOQL_Query.Operator.EQUALS, true));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(CMN_DAL_User.FIELD_USER_TYPE, CMN_SOQL_Query.Operator.EQUALS, CMN_DAL_User.PICK_USER_TYPE_STANDARD));

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(CMN_DAL_SObjectDomain.FIELD_ID)
						.fromX(CMN_DAL_User.OBJECT_NAME)
						.whereX(andCondition);

		objectQuery = builder.toSoql();

		return objectQuery;
	}
}