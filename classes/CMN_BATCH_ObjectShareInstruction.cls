/**
 * @description Batch class to allow Object Share Instruction Platform Event to be processed asynchronously
 *
 * @see CMN_TRA_ObjectShareInstruction_TEST
 * @see CMN_TRA_ObjectShareInstruction.addToObjectIdsByOwnerAndObjectNameMap
 *
 * @author prashant.k.jain@accenture.com jason.van.beukering@accenture.com
 *
 * @date July 2022
 */
public inherited sharing class CMN_BATCH_ObjectShareInstruction implements Database.Batchable<SObject>
{
	private CMN_DAL_ObjectShare.DTO_ObjectShareDescribe dtoShareDescribe;
	private List<CMN_ObjectShareInstruction__e> insertInstructions;
	private Map<Id, Set<Id>> deleteByOwnerToUserIdMap;
	private Set<Id> allOwnerIds;
	private String objectName;

	/**
	 * @description Constructor that will populate the object
	 *
	 * @param objectName The API name of the object for which Apex Shares will be inserted or deleted
	 * @param allOwnerIds All the owner Ids for insert share instructions
	 * @param insertInstructions platform events having Insert/Update operation, this may be null
	 * @param deleteByOwnerToUserIdMap map used to query and delete Apex share records
	 */
	public CMN_BATCH_ObjectShareInstruction(String objectName, Set<Id> allOwnerIds,
			List<CMN_ObjectShareInstruction__e> insertInstructions, Map<Id, Set<Id>> deleteByOwnerToUserIdMap)
	{
		this.objectName = objectName;
		this.allOwnerIds = allOwnerIds;
		this.insertInstructions = insertInstructions;
		this.deleteByOwnerToUserIdMap = deleteByOwnerToUserIdMap;
		dtoShareDescribe = new CMN_DAL_ObjectShare.DTO_ObjectShareDescribe(CMN_UTIL_System.getSObjectTypeByName(objectName));
	}

	/**
	 * @description Gets invoked when the batch job starts. Returns the record set as an iterable that will be batched for execution
	 *
	 * @param context Job context
	 *
	 * @return Locator for the query to return objects which we need to process sharing
	 */
	public Database.QueryLocator start(Database.BatchableContext context)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters;

		//We'll only ever be doing share creation in a batch of share deletion, so set up query locator accordingly
		if(deleteByOwnerToUserIdMap == null)
		{
			final Set<String> fields = new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_OWNER_ID};
			searchParameters = new CMN_DAL_Search.SOQLSearchParameters(objectName, fields);
			searchParameters.searchConditions.inX(CMN_DAL_SObjectDomain.FIELD_OWNER_ID, CMN_UTIL_System.setToList(allOwnerIds));
		}
		else
		{
			searchParameters = CMN_DAL_ObjectShare.getByParentIdAndUserOrGroupId(objectName, deleteByOwnerToUserIdMap);
		}

		return CMN_DAL_Search.getQueryLocator(searchParameters);
	}

	/**
	 * @description Will publish the events provided
	 *
	 * @param context Job Context
	 * @param objectToProcess The items to process; either to create or delete apex shares
	 */
	public void execute(Database.BatchableContext context, List<SObject> objectToProcess)
	{
		if(deleteByOwnerToUserIdMap == null)
		{
			Map<Id, Set<Id>> ownerToRecordIdMap =
					CMN_UTIL_System.convertListToMapSet(objectToProcess, CMN_DAL_SObjectDomain.FIELD_OWNER_ID, CMN_DAL_SObjectDomain.FIELD_ID);

			insertShares(ownerToRecordIdMap);
		}
		else
		{
			CMN_DAL_SObjectDomain.deleteDBObjects(objectToProcess, false);
		}
	}

	/**
	 * @description Constructs share records and commits them (if appropriate)
	 *
	 * @param ownerToRecordIdMap A map containing record ids by owner
	 */
	private void insertShares(Map<Id, Set<Id>> ownerToRecordIdMap)
	{
		if(insertInstructions != null)
		{
			List<SObject> sharesToInsert = new List<SObject>();
			CMN_DAL_ObjectShare.addSharesToInsert(sharesToInsert, insertInstructions, ownerToRecordIdMap, dtoShareDescribe);
			CMN_DAL_SObjectDomain.insertDBObjects(sharesToInsert, false);
		}
	}

	/**
	 * @description Any cleanup activities required
	 *
	 * @param context Job Context
	 */
	public void finish(Database.BatchableContext context)
	{
	}
}