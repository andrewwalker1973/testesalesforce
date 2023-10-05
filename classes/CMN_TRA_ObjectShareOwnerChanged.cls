/**
 * @description Action to process changes to objects that affect the owner and could require addition, removal or updates of Apex Shares
 *
 * @see CMN_TRA_ObjectShareOwnerChanged_TEST
 * @see CMN_TRA_ObjectShareConfiguration
 *
 * @author prashant.k.jain@accenture.com jason.van.beukering@accenture.com
 *
 * @date July 2022
 */
public inherited sharing class CMN_TRA_ObjectShareOwnerChanged extends CMN_TRA_ObjectShareEventPublisher
		implements CMN_TRA_Interfaces.CMN_INT_AfterInsert, CMN_TRA_Interfaces.CMN_INT_AfterUpdate
{
	/**
	 * @description Acts as a map of configuration objects based on ShareFrom and ObjectApiName
	 *
	 * @see CMN_ObjectShareConfiguration__c.CMN_ShareFrom__c
	 * @see CMN_ObjectShareConfiguration__c.CMN_ObjectAPIName__c
	 */
	private static CMN_UTIL_SObjectIndex configurationIndex = new CMN_UTIL_SObjectIndex
			(
					new List<String> {CMN_DAL_ObjectShareConfiguration.FIELD_SHARE_FROM, CMN_DAL_ObjectShareConfiguration.FIELD_OBJECT_API_NAME}
			);

	/**
	 * @description Map used to optimise checks for determining whether a particular object type can be processed or not
	 */
	private static Map<SObjectType, Boolean> canProcessMap = new Map<SObjectType, Boolean>();
	/**
	 * @description Used to indicate class and method when logging problems
	 */
	private static final String CLASS_METHOD = 'CMN_TRA_ObjectShareConfiguration/createAndPublishInstructions';

	/**
	 * @description Static variable to expose the instructions being generated so that we can check processing in a Unit Test
	 */
	@TestVisible
	private static List<CMN_ObjectShareChangeInstruction__e> instructions = new List<CMN_ObjectShareChangeInstruction__e>();

	/**
	 * @description Will process a list of newly inserted items
	 *
	 * @param newList inserted items
	 */
	public void afterInsert(List<SObject> newList)
	{
		if(canProcess(newList))
		{
			createAndPublishInstructions(newList);
		}
	}

	/**
	 * @description Will process updates to existing items
	 *
	 * @param newList A list of items with their changes
	 * @param oldList A list of items with their prior values
	 */
	public void afterUpdate(List<SObject> newList, List<SObject> oldList)
	{
		if(canProcess(newList))
		{
			List<SObject> itemsWithOwnerChanged = new List<SObject>();

			for(Integer i = 0; i < newList.size(); i++)
			{
				Object newOwnerId = newList[i].get(CMN_DAL_SObjectDomain.FIELD_OWNER_ID);
				Object oldOwnerId = oldList[i].get(CMN_DAL_SObjectDomain.FIELD_OWNER_ID);

				//Process records only if Owner has been updated
				if(newOwnerId != oldOwnerId)
				{
					itemsWithOwnerChanged.add(newList[i]);
				}
			}

			if(!itemsWithOwnerChanged.isEmpty())
			{
				createAndPublishInstructions(itemsWithOwnerChanged);
			}
		}
	}

	/**
	 * @description Will determine if trigger should process records, will only process the records if:
	 * 1. If an object in the list provided has the OwnerId field
	 * 2. There are valid share configurations
	 *
	 * @param newList list of records
	 *
	 * @return True to continue processing records
	 *
	 * @see CMN_DAL_SObjectDomain.FIELD_OWNER_ID
	 */
	private Boolean canProcess(List<SObject> newList)
	{
		SObject newObject = newList.iterator().next();

		Boolean canProcess = canProcessMap.get(newObject.getSObjectType());

		//If null it means that the object hasn't been checked before, so we must check to see if we can process it
		if(canProcess == null)
		{
			canProcess = false;

			if(CMN_UTIL_SObjectDescribe.getDescribe(newObject).getField(CMN_DAL_SObjectDomain.FIELD_OWNER_ID) != null)
			{
				//Only process valid configuration records
				extractValidConfigurations(CMN_DAL_ObjectShareConfiguration.getAllFromCache(), CMN_DAL_ObjectShareInstruction.OPERATION_INSERT);

				if(!validShareConfigurations.isEmpty())
				{
					canProcess = true;
					configurationIndex.putAll(validShareConfigurations);
				}
			}

			canProcessMap.put(newObject.getSObjectType(), canProcess);
		}

		return canProcess;
	}

	/**
	 * @description Method will evaluate if the object that's changing needs to be shared to one or more users
	 *
	 * @param changedObjects A list of items whose Owner has changed
	 */
	private void createAndPublishInstructions(List<SObject> changedObjects)
	{
		instructions.clear();

		//SObjectIndex takes composite keys using either a map or SObject
		CMN_ObjectShareConfiguration__c indexKey = new CMN_ObjectShareConfiguration__c();
		indexKey.CMN_ObjectAPIName__c = CMN_UTIL_System.getObjectNameFromId(changedObjects.iterator().next().Id);

		//Process one owners record at a time, will reduce the map lookup in createShares
		Map<Id, List<SObject>> objectByOwnerMap = CMN_UTIL_System.convertListToMap(changedObjects, CMN_DAL_SObjectDomain.FIELD_OWNER_ID);

		for(Id ownerId : objectByOwnerMap.keySet())
		{
			indexKey.CMN_ShareFrom__c = ownerId;
			createShares(indexKey, objectByOwnerMap.get(ownerId));
		}

		publish(instructions, CLASS_METHOD);
	}

	/**
	 * @description Will add a new share instruction platform event to the provided item
	 *
	 * @param indexKey Key to find if there are any configuration objects based on the index
	 * @param changedObjects List of SObjects that were changed for a specific Owner (as part of the trigger firing)
	 */
	private static void createShares(CMN_ObjectShareConfiguration__c indexKey, List<SObject> changedObjects)
	{
		List<CMN_ObjectShareConfiguration__c> foundConfigurations = configurationIndex.getAll(indexKey);

		for(CMN_ObjectShareConfiguration__c foundConfiguration : foundConfigurations)
		{
			for(SObject changedObject : changedObjects)
			{
				CMN_ObjectShareChangeInstruction__e changeInstruction = new CMN_ObjectShareChangeInstruction__e();

				changeInstruction.CMN_AccessLevel__c = foundConfiguration.CMN_AccessLevel__c;
				changeInstruction.CMN_ObjectId__c = changedObject.Id;
				changeInstruction.CMN_ShareWith__c = foundConfiguration.CMN_ShareWith__c;

				instructions.add(changeInstruction);
			}
		}
	}
}