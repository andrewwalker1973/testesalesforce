/**
 * @description Trigger handler on the Object Share Instruction Platform Event
 *
 * @see CMN_BATCH_ObjectShareInstruction
 * @see CMN_BATCH_PerformDML
 * @see CMN_ObjectShareInstruction__e
 * @see CMN_TRA_ObjectShareInstruction_TEST
 *
 * @author prashant.k.jain@accenture.com jason.van.beukering@accenture.com
 *
 * @date July 2022
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class CMN_TRA_ObjectShareInstruction extends CMN_TRA_BaseObject implements CMN_TRA_Interfaces.CMN_INT_AfterInsert
{
	/**
	 * @description Set this value to true in an unit test to ensure we test that shares can be committed via batch
	 * to simulate scenarios where DML operation governor limits will be breached
	 */
	@TestVisible
	private static Boolean commitViaBatch = false;
	/**
	 * @description Set this value to true in an unit test to ensure we test that delete instruction queries are processed via batch
	 * to simulate scenarios where query governor limits will be breached
	 */
	@TestVisible
	private static Boolean processDeleteViaBatch = false;
	/**
	 * @description Set this value to true in an unit test to ensure we test that events are processed via batch
	 * to simulate scenarios where query governor limits will be breached
	 */
	@TestVisible
	private static Boolean processViaBatch = false;
	/**
	 * @description Set this value to true to simulate that we don't have enough heap memory to process the request
	 */
	@TestVisible
	private static Boolean simulateNotEnoughHeapMemory = false;
	/**
	 * @description Contains the list of fields to query from an SObject to determine which records are owned by user
	 * Will be used to either insert or delete apex shares based on the instruction given
	 */
	private static final Set<String> QUERY_FIELDS = new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_OWNER_ID};
	/**
	 * @description Cumulative estimate of the heap size which would be used by all shares to be inserted in this execution.
	 * This will be used to determine if batch execution is needed
	 */
	private Integer estimatedTotalHeapSizeOfSharesToInsert = 0;
	/**
	 * @description List of platform events having Insert/Update operation
	 */
	private Map<String, List<CMN_ObjectShareInstruction__e>> objectNameToInsertInstructionsMap = new Map<String, List<CMN_ObjectShareInstruction__e>>();
	/**
	 * @description Map of ObjectName to Map of ShareFromId to Set of all the objectRecordIds owned by ShareFrom which will
	 * used to insert or delete share records
	 * Map<objectName, Map<OwnerId, Set<ObjectId>>>
	 */
	private Map<String, Map<Id, Set<Id>>> objectIdsByOwnerAndObjectNameMap = new Map<String, Map<Id, Set<Id>>>();
	/**
	 * @description Map of ObjectName to Set of ShareFromIds which will be used to get the object records owned by ShareFrom
	 * Map<objectName, Set<OwnerId>>
	 */
	private Map<String, Set<Id>> ownerIdsByObjectNameMap = new Map<String, Set<Id>>();

	/**
	 * @description Will process the sharing instructions and ensure relevant apex shares are created or deleted
	 *
	 * @param insertedEvents inserted items
	 */
	public void afterInsert(List<CMN_ObjectShareInstruction__e> insertedEvents)
	{
		Boolean performShareDelete = performShareDelete(insertedEvents);

		setupMaps(performShareDelete, insertedEvents);

		if(performShareDelete)
		{
			processSharesToDelete();
		}
		else
		{
			processSharesToInsert();
		}
	}

	/**
	 * @description Determines if this action will be deleting or inserting shares
	 *
	 * @param insertedEvents events inserted for the trigger
	 *
	 * @return True if the operation to perform is a delete
	 */
	private static Boolean performShareDelete(List<CMN_ObjectShareInstruction__e> insertedEvents)
	{
		return CMN_DAL_ObjectShareInstruction.OPERATION_DELETE.equalsIgnoreCase(insertedEvents.iterator().next().CMN_Operation__c);
	}

	/**
	 * @description Will iterate though items and setup the maps required for determining if apex shares should be created or deleted
	 *
	 * @param performShareDelete Indicates if we are deleting shares
	 * @param insertedEvents inserted items
	 */
	private void setupMaps(Boolean performShareDelete, List<CMN_ObjectShareInstruction__e> insertedEvents)
	{
		for(CMN_ObjectShareInstruction__e instruction : insertedEvents)
		{
			if(performShareDelete)
			{
				addItemToMap(instruction);
			}
			else
			{
				addToUserIdsByObjectNameMap(ownerIdsByObjectNameMap, instruction.CMN_ObjectAPIName__c, instruction.CMN_ShareFrom__c);
				addToInstructionByObjectNameMap(objectNameToInsertInstructionsMap, instruction);
			}
		}
	}

	/**
	 * @description Will add instruction into relevant map to be used later to retrieve apex shares for deletion
	 *
	 * @param instruction the share instruction being processed
	 */
	private void addItemToMap(CMN_ObjectShareInstruction__e instruction)
	{
		Map<Id, Set<Id>> ownerToUserIdMap = objectIdsByOwnerAndObjectNameMap.get(instruction.CMN_ObjectAPIName__c);

		if(ownerToUserIdMap == null)
		{
			ownerToUserIdMap = new Map<Id, Set<Id>>();
			objectIdsByOwnerAndObjectNameMap.put(instruction.CMN_ObjectAPIName__c, ownerToUserIdMap);
		}

		Set<Id> userIds = ownerToUserIdMap.get(instruction.CMN_ShareFrom__c);

		if(userIds == null)
		{
			userIds = new Set<Id>();
			ownerToUserIdMap.put(instruction.CMN_ShareFrom__c, userIds);
		}

		userIds.add(instruction.CMN_ShareWith__c);
	}

	/**
	 * @description Will add User Id provided into map (based on objectName)
	 *
	 * @param userIdsMap The map to which User Id should be added
	 * @param objectName Object API Name
	 * @param userId Id of the User to be added
	 */
	private static void addToUserIdsByObjectNameMap(Map<String, Set<Id>> userIdsMap, String objectName, Id userId)
	{
		Set<Id> userIds = userIdsMap.get(objectName);

		if(userIds == null)
		{
			userIds = new Set<Id>();
			userIdsMap.put(objectName, userIds);
		}

		userIds.add(userId);
	}

	/**
	 * @description Will add instruction provided into map (based on objectName)
	 *
	 * @param instructionByObjectNameMap The map to which instruction should be added
	 * @param instruction The share instruction being mapped
	 */
	private static void addToInstructionByObjectNameMap
			(Map<String, List<CMN_ObjectShareInstruction__e>> instructionByObjectNameMap, CMN_ObjectShareInstruction__e instruction)
	{
		List<CMN_ObjectShareInstruction__e> instructions = instructionByObjectNameMap.get(instruction.CMN_ObjectAPIName__c);

		if(instructions == null)
		{
			instructions = new List<CMN_ObjectShareInstruction__e>();
			instructionByObjectNameMap.put(instruction.CMN_ObjectAPIName__c, instructions);
		}

		instructions.add(instruction);
	}

	/**
	 * @description Finds all records to be deleted and adds them to the unit of work
	 */
	private void processSharesToDelete()
	{
		List<SObject> sharesToDelete = new List<SObject>();

		for(String objectName : objectIdsByOwnerAndObjectNameMap.keySet())
		{
			Map<Id, Set<Id>> ownerToUserIdMap = objectIdsByOwnerAndObjectNameMap.get(objectName);

			List<SObject> existingShareRecords = new List<SObject>();

			Boolean canProcess = canRetrieveShares(objectName, ownerToUserIdMap, existingShareRecords);

			//No point in adding to the map if no records are returned (this may be due to no records being found or Query limits)
			if(!existingShareRecords.isEmpty())
			{
				sharesToDelete.addAll(existingShareRecords);
			}
			//Kick of batch process if we couldn't process due to DML limits
			else if(!canProcess)
			{
				executeBatch(objectName, null, null, ownerToUserIdMap);
			}
		}

		performDMLOperation(sharesToDelete, CMN_DAL_SObjectDomain.DatabaseOperation.DBO_DELETE);
	}

	/**
	 * @description Will determine if we can continue processing the delete query synchronously (if not it will be deferred to a batch class)
	 * Will check Query limits
	 *
	 * @param objectName The object name for which shares should be retrieved
	 * @param ownerToUserIdMap A map of Owner Id and User Ids with which to query existing share records
	 * @param foundObjects If able to process this will contain all the share records found
	 *
	 * @return If true, then processing can continue for this object (Query limits won't be breached)
	 */
	private static Boolean canRetrieveShares(String objectName, Map<Id, Set<Id>> ownerToUserIdMap, List<SObject> foundObjects)
	{
		//we need to at least need to be able to run the count query
		Boolean canProcess = !processDeleteViaBatch && canExecuteCountQuery();

		//We need to be-able to get at least one row (for the count query result)
		if(canProcess)
		{
			Integer recordCount = CMN_DAL_ObjectShare.getCountByParentIdAndUserOrGroupId(objectName, ownerToUserIdMap);

			if(recordCount > 0)
			{
				//We need to check that we have still got query rows left to retrieve, if not the query will fail
				canProcess = canExecuteQuery(recordCount);

				if(canProcess)
				{
					foundObjects.addAll(CMN_DAL_ObjectShare.findByParentIdAndUserOrGroupId(objectName, ownerToUserIdMap));
				}
			}
		}

		return canProcess;
	}

	/**
	 * @description Will kick of a batch job to insert/delete shares
	 *
	 * @param objectName The API name of the object for which Apex Shares will be inserted or deleted
	 * @param allOwnerIds All the owner Ids for insert share instructions, this may be null
	 * @param insertInstructions platform events having Insert/Update operation, this may be null
	 * @param deleteByOwnerToUserIdMap map used to query and delete Apex share records, this may be null
	 */
	private static void executeBatch
			(
					String objectName,
					Set<Id> allOwnerIds,
					List<CMN_ObjectShareInstruction__e> insertInstructions,
					Map<Id, Set<Id>> deleteByOwnerToUserIdMap
			)
	{

		Integer batchSize = CMN_DAL_BatchSetting.getBatchSize(CMN_BATCH_ObjectShareInstruction.class.getName());

		if(insertInstructions != null)
		{
			//When executing via batch, the number of DML records will be determined by the number of Share Configuration records.
			//So the batch size is adjusted to ensure we don't breach DML limits
			batchSize = Math.min(batchSize, Limits.getLimitDmlRows() / insertInstructions.size());
		}

		Database.executeBatch(new CMN_BATCH_ObjectShareInstruction(objectName, allOwnerIds, insertInstructions, deleteByOwnerToUserIdMap), batchSize);
	}

	/**
	 * @description Will execute relevant DML operation, either Synchronously or Asynchronously based DML limits (or commitViaBatch setting)
	 *
	 * @param objects The objects for which the DML operations should be performed
	 * @param operation The database operation to perform
	 *
	 * @see CMN_TRA_ObjectShareInstruction.commitViaBatch
	 * @see CMN_BATCH_PerformDML
	 * @see CMN_DAL_SObjectDomain.updateDatabase
	 */
	private static void performDMLOperation(List<SObject> objects, CMN_DAL_SObjectDomain.DatabaseOperation operation)
	{
		if(!objects.isEmpty() && (objects.size() > (Limits.getLimitDmlRows() - Limits.getDmlRows())) || commitViaBatch)
		{
			Database.executeBatch(new CMN_BATCH_PerformDML(objects, operation), Limits.getLimitDmlRows());
		}
		else
		{
			CMN_DAL_SObjectDomain.updateDatabase(objects, operation, true);
		}
	}

	/**
	 * @description Finds all objects that must be shared and adds the relevant object shares to the unit of work
	 */
	private void processSharesToInsert()
	{
		addToObjectIdsByOwnerAndObjectNameMap(ownerIdsByObjectNameMap);

		List<SObject> sharesToInsert = new List<SObject>();

		for(String objectName : objectNameToInsertInstructionsMap.keySet())
		{
			Map<Id, Set<Id>> ownerToRecordIdMap = objectIdsByOwnerAndObjectNameMap.get(objectName);

			//If we haven't found any records for the object provided we do need to process further
			if(ownerToRecordIdMap != null && !ownerToRecordIdMap.isEmpty())
			{
				SObjectType objectType = CMN_UTIL_System.getSObjectTypeByName(objectName);
				CMN_DAL_ObjectShare.DTO_ObjectShareDescribe dtoShareDescribe = new CMN_DAL_ObjectShare.DTO_ObjectShareDescribe(objectType);

				CMN_DAL_ObjectShare.addSharesToInsert(sharesToInsert, objectNameToInsertInstructionsMap.get(objectName), ownerToRecordIdMap, dtoShareDescribe);
			}
		}

		performDMLOperation(sharesToInsert, CMN_DAL_SObjectDomain.DatabaseOperation.DBO_INSERT);
	}

	/**
	 * @description This method is used to get all the records from list of SObject owned by ShareFrom user for Insert operations
	 *
	 * @param objectToShareFromIdsMap Map of Object To Share from user ids
	 */
	private void addToObjectIdsByOwnerAndObjectNameMap(Map<String, Set<Id>> objectToShareFromIdsMap)
	{
		for(String objectName : objectToShareFromIdsMap.keySet())
		{
			List<SObject> foundObjects = new List<SObject>();
			Set<Id> ownerIds = objectToShareFromIdsMap.get(objectName);
			Boolean canProcess = canRetrieveObjects(objectName, ownerIds, foundObjects);

			//No point in adding to the map if no records are returned (this may be due to no records being found or DML limits)
			if(!foundObjects.isEmpty())
			{
				Map<Id, Set<Id>> ownerToObjectIdMap =
						CMN_UTIL_System.convertListToMapSet(foundObjects, CMN_DAL_SObjectDomain.FIELD_OWNER_ID, CMN_DAL_SObjectDomain.FIELD_ID);

				objectIdsByOwnerAndObjectNameMap.put(objectName, ownerToObjectIdMap);
			}
			//Kick of batch process if we couldn't process due to DML limits
			else if(!canProcess)
			{
				executeBatch(objectName, ownerIds, objectNameToInsertInstructionsMap.get(objectName), null);
			}
		}
	}

	/**
	 * @description Will determine if we can continue processing the object synchronously (if not it will be deferred to a batch class)
	 * Will check Query limits
	 *
	 * @param objectName Object API Name
	 * @param ownerIds Ids of the record owner
	 * @param foundObjects If able to process this will contain all the records found
	 *
	 * @return If true, then processing can continue for this object (DML limits won't be breached)
	 */
	private Boolean canRetrieveObjects(String objectName, Set<Id> ownerIds, List<SObject> foundObjects)
	{
		//we need to at least need to be able to run the count query
		Boolean canProcess = !processViaBatch && canExecuteCountQuery();

		//We need to be-able to get at least one row (for the count query result)
		if(canProcess)
		{
			Integer recordCount = CMN_DAL_SObjectSelector.countById(objectName, CMN_DAL_SObjectDomain.FIELD_OWNER_ID, ownerIds);

			if(recordCount > 0)
			{
				//We need to check that we have still got query rows left to retrieve, if not the query will fail
				//Also check that we have enough heap memory to construct all the shares we need to create
				canProcess = canExecuteQuery(recordCount) && hasEnoughMemory(objectName, recordCount, objectNameToInsertInstructionsMap.get(objectName).size());

				if(canProcess)
				{
					foundObjects.addAll(CMN_DAL_SObjectSelector.findById(objectName, CMN_DAL_SObjectDomain.FIELD_OWNER_ID, ownerIds, QUERY_FIELDS));
				}
			}
		}

		return canProcess;
	}

	/**
	 * @description Will return whether a query can be run to count query based on DML limits
	 *
	 * @return True if the query can be executed
	 */
	private static Boolean canExecuteCountQuery()
	{
		return canExecuteQuery(1);
	}

	/**
	 * @description Will return whether a query can be run to return the expected number of rows looking at DML limits
	 *
	 * @param numberOfRows The number of rows required
	 *
	 * @return True if the query can be executed
	 */
	private static Boolean canExecuteQuery(Integer numberOfRows)
	{
		return (Limits.getLimitQueries() - Limits.getQueries()) > 0 && numberOfRows <= (Limits.getLimitQueryRows() - Limits.getQueryRows());
	}

	/**
	 * @description Checks to see if the current processing loop will have enough heap memory to process
	 *
	 * @param objectName The API name of the object for which we intend to create
	 * @param recordCount The number of records for which we need to create shares
	 * @param shareInstructionCount The number of share instructions that will be processed for the records given
	 *
	 * @return True if there will be enough memory to continue processing
	 */
	private Boolean hasEnoughMemory(String objectName, Integer recordCount, Integer shareInstructionCount)
	{
		Boolean hasEnoughMemory = true;

		Integer numberOfSharesToCreate = recordCount * shareInstructionCount;

		if(numberOfSharesToCreate > 0)
		{
			CMN_DAL_ObjectShare.DTO_ObjectShareDescribe dtoShareDescribe =
					new CMN_DAL_ObjectShare.DTO_ObjectShareDescribe(CMN_UTIL_System.getSObjectTypeByName(objectName));
			Integer estimatedHeapSizeIncrement = numberOfSharesToCreate * dtoShareDescribe.estimatedHeapSize;

			hasEnoughMemory = (estimatedTotalHeapSizeOfSharesToInsert + estimatedHeapSizeIncrement <= Limits.getLimitHeapSize() - Limits.getHeapSize())
					&& !simulateNotEnoughHeapMemory;

			//Increment the estimated total, which may be used in future loops, if any
			estimatedTotalHeapSizeOfSharesToInsert =
					hasEnoughMemory ? estimatedTotalHeapSizeOfSharesToInsert + estimatedHeapSizeIncrement : estimatedTotalHeapSizeOfSharesToInsert;
		}

		return hasEnoughMemory;
	}
}