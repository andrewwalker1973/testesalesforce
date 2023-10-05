/**
 * @description Base class for All Object Share Objects that implement the trigger action framework
 * and are monitoring objects are responsible for publishing instruction events
 *
 * @see CMN_TRA_ObjectShareConfiguration_TEST
 * @see CMN_TRA_ObjectShareOwnerChanged_TEST
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date July 2022
 */
public inherited sharing virtual class CMN_TRA_ObjectShareEventPublisher extends CMN_TRA_BaseObject
{
	/**
	 * @description Set this value to true in an unit test to ensure we simulate DML Limits being about to be exceeded and that operation must be async
	 */
	@TestVisible
	private static Boolean simulateDMLimitsBreach = false;
	/**
	 * @description Set this value to true to prevent asynchronous publishing so we can simulate situation where we are hitting limits
	 */
	@TestVisible
	private static Boolean simulateQueueableLimitsBreach = false;
	@TestVisible
	private static final String CLASS_METHOD = 'CMN_TRA_ObjectShareEventPublisher/extractValidConfigurations';
	private static final String LIMIT_ERROR = 'Unable to publish sharing events as the both DML and Queueable Limits have been reached';
	@TestVisible
	private static final String INVALID_CONFIGURATION_ERROR_FORMAT = 'Configuration "{0}" ignored as it is invalid.';

	/**
	 * @description List of valid share configurations
	 *
	 * @see CMN_TRA_ObjectShareEventPublisher.extractValidConfigurations
	 */
	protected List<CMN_ObjectShareConfiguration__c> validShareConfigurations;

	/**
	 * @description This method will filter shareConfigurations list based on Object's Org-wide default sharing settings and specified Access Level
	 *
	 * @param shareConfigurations The updated or inserted configuration items
	 * @param operation DML operation being performed
	 */
	protected void extractValidConfigurations(List<CMN_ObjectShareConfiguration__c> shareConfigurations, String operation)
	{
		//Not necessary to validate share configuration as this is just going to result in instruction to remove shares (if they exist)
		if(CMN_DAL_ObjectShareInstruction.OPERATION_DELETE.equals(operation) || shareConfigurations.isEmpty())
		{
			validShareConfigurations = shareConfigurations;
			return;
		}

		if(validShareConfigurations == null)
		{
			validShareConfigurations = new List<CMN_ObjectShareConfiguration__c>();

			List<EntityDefinition> entityDefinitions = CMN_DAL_EntityDefinition.getByQualifiedApiNames
					(CMN_UTIL_System.extractSetValues(shareConfigurations, CMN_DAL_ObjectShareConfiguration.FIELD_OBJECT_API_NAME));

			Map<String, SObject> definitionByObjectApiNameMap =
					CMN_UTIL_System.convertListToSingleStringMap(entityDefinitions, CMN_DAL_EntityDefinition.FIELD_QUALIFIED_API_NAME);

			List<String> invalidShareMessages = new List<String>();

			for(CMN_ObjectShareConfiguration__c shareConfiguration : shareConfigurations)
			{
				if(canCreateApexShares(definitionByObjectApiNameMap, shareConfiguration))
				{
					validShareConfigurations.add(shareConfiguration);
				}
				else
				{
					invalidShareMessages.add(String.format(INVALID_CONFIGURATION_ERROR_FORMAT, new List<String> {shareConfiguration.Id}));
				}
			}

			if(!invalidShareMessages.isEmpty())
			{
				CMN_UTIL_Logger.warn(invalidShareMessages, CLASS_METHOD);
			}
		}
	}

	/**
	 * @description Check to see if the current configuration provided if it's valid; i.e. its possible to create shares for it
	 *
	 * @param definitionByObjectApiNameMap A map containing entity definitions per object API name
	 * @param shareConfiguration The configuration we're checking
	 *
	 * @return True if the configuration can have apex shares created for it
	 */
	private static Boolean canCreateApexShares(Map<String, SObject> definitionByObjectApiNameMap, CMN_ObjectShareConfiguration__c shareConfiguration)
	{
		EntityDefinition definition = (EntityDefinition)definitionByObjectApiNameMap.get(shareConfiguration.CMN_ObjectAPIName__c);

		//We cannot create share instruction if the Org default sharing already gives access to the record
		return definition != null //This checks for scenario where the configuration contains an invalid object API Name
				&&
				(//This is most restrictive OWD so all configurations increasing access are valid
						(definition.InternalSharingModel == CMN_DAL_EntityDefinition.SHARING_MODEL_PRIVATE
								// It is not a valid configuration if Sharing Model is Private for Contact in an org with Person Account Enabled
								&& !(definition.QualifiedApiName == CMN_DAL_Contact.OBJECT_NAME && CMN_UTIL_SObjectDescribe.isPersonAccountEnabled())
						)
								||
								(//If we have default read, then the only valid configuration record is providing edit access
										definition.InternalSharingModel == CMN_DAL_EntityDefinition.SHARING_MODEL_READ &&
												shareConfiguration.CMN_AccessLevel__c == CMN_DAL_ObjectShareConfiguration.ACCESS_LEVEL_EDIT
								)
				);
	}

	/**
	 * @description Method will publish the events provided either synchronously (if dml limits not going to be breach) or asynchronously
	 *
	 * @param events List of items to publish
	 * @param classMethod The method name <class>/<method> which initiated the event publish
	 */
	protected void publish(List<SObject> events, String classMethod)
	{
		if(canPublish(events))
		{
			CMN_UTIL_Logger.errorDMLOperationResults(EventBus.publish(events), classMethod);
		}
		else if(!simulateQueueableLimitsBreach && Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() > 0)
		{
			System.enqueueJob(new AsynchronousEventPublisher(events));
		}
		else
		{
			//Ensure we record that we were unable to publish events due to governor limits
			CMN_UTIL_Logger.debug(LIMIT_ERROR, classMethod);
		}
	}

	/**
	 * @description Method will check current governor limits and determine if the events provided can be published immediately
	 *
	 * @param events List of items to publish
	 *
	 * @return True if publishing the event immediately won't breach governor limits
	 */
	private static Boolean canPublish(List<SObject> events)
	{
		//Don't publish immediately if:
		//1. The the number of DML operations we intend to perform is going to breach the DML rows limit OR
		//2. We are at the limit of allowed DML statements, so performing another one will fail OR
		//3. We are running a unit test and we are testing publishing to batch
		if(simulateDMLimitsBreach)
		{
			return false;
		}

		Boolean canPublish = Limits.getDmlStatements() < Limits.getLimitDmlStatements();
		canPublish = canPublish && events.size() <= Limits.getLimitDmlRows() - Limits.getDmlRows();

		return canPublish;
	}

	/**
	 * @description Will be used to publish events asynchronously
	 */
	public class AsynchronousEventPublisher implements Queueable
	{
		private List<SObject> events = new List<SObject>();

		/**
		 * @description Constructor that will get the SObjects to insert
		 *
		 * @param events A list of events to be published
		 */
		public AsynchronousEventPublisher(List<SObject> events)
		{
			this.events = events;
		}

		/**
		 * @description Executes the Queueable job
		 *
		 * @param context the Context for Queueable job, contains the jobId
		 *
		 * @see Queueable
		 */
		public void execute(QueueableContext context)
		{
			CMN_UTIL_Logger.errorDMLOperationResults(EventBus.publish(events), 'CMN_TRA_ObjectShareEventPublisher.PublishEvents/execute');
		}
	}
}