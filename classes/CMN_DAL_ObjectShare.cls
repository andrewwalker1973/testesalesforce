/**
 * @description Selector class for Query SObject Share records (generically across all SObject)
 *
 * @see CMN_DAL_ObjectShare_TEST
 *
 * @author prashant.k.jain@accenture.com jason.van.beukering@accenture.com
 *
 * @date July 2022
 */
public inherited sharing class CMN_DAL_ObjectShare
{
	/**
	 * @description Represents the approximate Heap size for a standard Share SObject,
	 * this is based on test code that measured the memory usage when creating shares.
	 *
	 * @see CMN_Foobar__Share
	 */
	private static final Integer HEAP_SIZE_STANDARD_SHARE = 110;
	/**
	 * @description Represents the approximate Heap size for a special Share SObject,
	 * this is based on test code that measured the memory usage when creating shares.
	 *
	 * @see AccountShare
	 */
	private static final Integer HEAP_SIZE_SPECIAL_SHARE = 125;
	/**
	 * @description Field API name of AccessLevel
	 */
	private static final String FIELD_ACCESS_LEVEL = 'AccessLevel';
	/**
	 * @description Reference field name for associated parent object
	 */
	private static final String REFERENCE_PARENT = 'Parent';
	/**
	 * @description Store the Share label
	 */
	private static final String FIELD_SHARE = 'Share';
	/**
	 * @description Any object in this list needs to be treated differently when calculating Share object name and fields
	 */
	private static final Set<String> OBJECTS_WITH_SPECIAL_SHARES = new Set<String>
	{
			'Asset',
			'Campaign',
			'Case',
			'Contact',
			'Individual',
			'Lead',
			'Opportunity',
			CMN_DAL_Account.OBJECT_NAME,
			CMN_DAL_User.OBJECT_NAME
	};

	/**
	 * @description Provides no access to an object via object share
	 */
	public static final String ACCESS_LEVEL_NONE = 'None';
	/**
	 * @description Field API name of OpportunityAccessLevel
	 */
	public static final String FIELD_OPPORTUNITY_ACCESS_LEVEL = AccountShare.OpportunityAccessLevel.getDescribe().getLocalName();
	/**
	 * @description Field API name of RowCause
	 */
	public static final String FIELD_ROW_CAUSE = 'RowCause';
	/**
	 * @description Field API name of UserOrGroupId
	 */
	public static final String FIELD_USER_OR_GROUP_ID = 'UserOrGroupId';
	/**
	 * @description Object API name of AccountShare
	 */
	public static final String OBJECT_ACCOUNT_SHARE = AccountShare.SObjectType.getDescribe().getLocalName();
	/**
	 * @description RowCause setting that will be used to create ShareObject records
	 */
	public static final String ROW_CAUSE_MANUAL = 'Manual';

	/**
	 * @description Will dynamically retrieve Object shares
	 *
	 * @param objectName The API name of the object for which shares should be retrieved
	 * @param ownerToUserIdMap A map of Owner Id and User Ids with which to query existing share records
	 *
	 * @return A list of share records
	 */
	public static List<SObject> findByParentIdAndUserOrGroupId(String objectName, Map<Id, Set<Id>> ownerToUserIdMap)
	{
		return CMN_DAL_Search.getObjects(getByParentIdAndUserOrGroupId(objectName, ownerToUserIdMap));
	}

	/**
	 * @description Will dynamically retrieve a count of Object shares
	 *
	 * @param objectName The API name of the object for which shares should be retrieved
	 * @param ownerToUserIdMap A map of Owner Id and User Ids with which to query existing share records
	 *
	 * @return Count of records
	 */
	public static Integer getCountByParentIdAndUserOrGroupId(String objectName, Map<Id, Set<Id>> ownerToUserIdMap)
	{
		return CMN_DAL_Search.getObjectCount(getByParentIdAndUserOrGroupId(objectName, ownerToUserIdMap));
	}

	/**
	 * @description Will initialise search parameters for performing a query to return objet shares
	 *
	 * @param objectName The API name of the object for which shares should be retrieved
	 * @param ownerToUserIdMap A map of Owner Id and User Ids with which to query existing share records
	 *
	 * @return initialised search parameters
	 */
	public static CMN_DAL_Search.SOQLSearchParameters getByParentIdAndUserOrGroupId(String objectName, Map<Id, Set<Id>> ownerToUserIdMap)
	{
		DTO_ObjectShareDescribe dtoShareDescribe = new DTO_ObjectShareDescribe(CMN_UTIL_System.getSObjectTypeByName(objectName));
		Set<String> selectFields = new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID};

		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(dtoShareDescribe.shareObjectName, selectFields);
		searchParameters.searchConditions.equalsX(FIELD_ROW_CAUSE, ROW_CAUSE_MANUAL);

		CMN_SOQL_Query.OrCondition orCondition = CMN_SOQL_Query.orX();

		for(Id ownerId : ownerToUserIdMap.keySet())
		{
			CMN_SOQL_Query.AndCondition andCondition = CMN_SOQL_Query.andX();

			andCondition.inX(FIELD_USER_OR_GROUP_ID, CMN_UTIL_System.setToList(ownerToUserIdMap.get(ownerId)));
			andCondition.equalsX(dtoShareDescribe.parentObjectFieldName + CMN_UTIL_String.DOT + CMN_DAL_SObjectDomain.FIELD_OWNER_ID, ownerId);

			orCondition.add(andCondition);
		}

		searchParameters.searchConditions.add(orCondition);

		return searchParameters;
	}

	/**
	 * @description Will retrieve Object shares based on the Related Object Id (parentId) as well as the reason for the Share record Existing
	 *
	 * @param parentId Refers to the related Object Id
	 * @param rowCause The reason the share record was created
	 *
	 * @return A list of share records
	 */
	@TestVisible
	private static List<SObject> findByParentIdAndRowCause(Id parentId, String rowCause)
	{
		DTO_ObjectShareDescribe dtoShareDescribe = getShareDescribe(parentId);

		Set<String> fields = new Set<String> {dtoShareDescribe.parentIdFieldName, dtoShareDescribe.accessLevel, FIELD_USER_OR_GROUP_ID};

		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(dtoShareDescribe.shareObjectName, fields);
		searchParameters.searchConditions.equalsX(dtoShareDescribe.parentIdFieldName, parentId);
		searchParameters.searchConditions.equalsX(FIELD_ROW_CAUSE, rowCause);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Will return all the relevant share field describes for an Object based on their Id
	 *
	 * @param parentId Refers to the related Object Id
	 *
	 * @return DTO containing all the relevant information
	 */
	public static DTO_ObjectShareDescribe getShareDescribe(Id parentId)
	{
		return new DTO_ObjectShareDescribe(CMN_UTIL_System.getSObjectTypeById(parentId));
	}

	/**
	 * @description DTO that can be used to retrieve share object describe information
	 */
	public class DTO_ObjectShareDescribe
	{
		/**
		 * @description Contains the accessLevel Field Api name
		 */
		public String accessLevel;
		/**
		 * @description Contains the related record id Field Api name
		 */
		public String parentIdFieldName;
		/**
		 * @description Contains the related record Object Field name
		 */
		public String parentObjectFieldName;
		/**
		 * @description Contains the Api name of the Share object
		 */
		public String shareObjectName;
		/**
		 * @description Contains the anticipated heap size for a newly created Object Share,
		 * used for bulk processing scenarios where we need to ensure we don't breach memory limits
		 */
		public Integer estimatedHeapSize;
		/**
		 * @description Will initialise all the relevant information for the Share object related to the given object api name
		 *
		 * @link https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_associated_objects_share.htm
		 *
		 * @param objectType Type of an SObject that has a related share object
		 */
		public DTO_ObjectShareDescribe(SObjectType objectType)
		{
			if(objectType != null)
			{
				String objectApiName = objectType.getDescribe().getLocalName();

				Boolean isObjectWithSpecialShare = OBJECTS_WITH_SPECIAL_SHARES.contains(objectApiName);

				accessLevel = isObjectWithSpecialShare ? objectApiName + FIELD_ACCESS_LEVEL : FIELD_ACCESS_LEVEL;
				estimatedHeapSize = isObjectWithSpecialShare ? HEAP_SIZE_SPECIAL_SHARE : HEAP_SIZE_STANDARD_SHARE;
				parentObjectFieldName = isObjectWithSpecialShare ? objectApiName : REFERENCE_PARENT;
				parentIdFieldName = parentObjectFieldName + CMN_DAL_SObjectDomain.FIELD_ID;
				shareObjectName = objectType.getDescribe().isCustom() ?
						CMN_UTIL_String.replace(objectApiName, CMN_UTIL_System.CUSTOM_FIELD_SUFFIX, CMN_UTIL_System.CUSTOM_OBJECT_SHARE_SUFFIX) :
						objectApiName + FIELD_SHARE;
			}
		}

		/**
		 * @description Will create a new instance of a Share Object
		 *
		 * @return Newly created item
		 */
		public SObject newShareObject()
		{
			SObject shareObject;

			if(String.isNotBlank(shareObjectName))
			{
				shareObject = CMN_UTIL_System.getSObjectTypeByName(shareObjectName).newSObject();
			}

			return shareObject;
		}
	}

	/**
	 * @description Will add shares to be inserted into the provided list
	 *
	 * @param sharesToInsert A list of shares to be inserted, shares will be added to this list
	 * @param insertInstructions A list of platform events having Insert/Update operation
	 * @param ownerToRecordIdMap Map which has record ids per owner
	 * @param dtoShareDescribe Has the Apex share object describe information
	 */
	public static void addSharesToInsert(List<SObject> sharesToInsert, List<CMN_ObjectShareInstruction__e> insertInstructions,
			Map<Id, Set<Id>> ownerToRecordIdMap, CMN_DAL_ObjectShare.DTO_ObjectShareDescribe dtoShareDescribe)
	{
		for(CMN_ObjectShareInstruction__e instruction : insertInstructions)
		{
			Set<Id> objectIds = ownerToRecordIdMap.get(instruction.CMN_ShareFrom__c);

			if(objectIds != null)
			{
				for(Id objectId : objectIds)
				{
					//create share records for each of the record owned by ShareFrom
					SObject shareObject = CMN_DAL_DataFactory.newSObjectShare
							(dtoShareDescribe, objectId, instruction.CMN_AccessLevel__c, instruction.CMN_ShareWith__c);
					sharesToInsert.add(shareObject);
				}
			}
		}
	}
}