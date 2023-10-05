/**
 * @description Provides Query methods related to ContentVersion object
 *
 * @author Accenture
 *
 * @date 2020
 */
public inherited sharing class CMN_DAL_ContentVersion
{
	private static final String ERROR_FOLDER_NAME_NOT_UNIQUE = 'Multiple folders with the same name requested from the same library.\nThe use of this function assumes that the folder is a direct child of the library or that the folder name is unique to other folders in the same request.';
	private static final String FIELD_CONTENT_DOCUMENT_ID = ContentVersion.ContentDocumentId.getDescribe().getLocalName();
	private static final String FIELD_FIRST_PUBLISHED_LOCATION_ID = ContentVersion.FirstPublishLocationId.getDescribe().getLocalName();
	private static final String FIELD_IS_DELETED = ContentVersion.IsDeleted.getDescribe().getLocalName();
	private static final String FIELD_IS_LATEST = ContentVersion.IsLatest.getDescribe().getLocalName();
	private static final String FIELD_LATEST_PUBLISHED_VERSION_ID = 'ContentDocument.LatestPublishedVersionId';
	private static final String FORMAT_OBJECT_IMAGE_TITLE = 'ObjectImage-{0}';
	private static final String OBJECT_NAME = ContentVersion.SObjectType.getDescribe().getLocalName();
	public static final String FILE_TYPE_PDF = 'PDF';

	/**
	 * @description Will return the new version of Content version object
	 *
	 * @param objectId
	 * @param title
	 * @param pathOnClient
	 * @param versionData
	 * @param networkId
	 * @param contentDocumentId
	 *
	 * @return
	 */
	public static ContentVersion newItem(Id objectId, String title, String pathOnClient, Blob versionData, Id networkId, Id contentDocumentId)
	{
		ContentVersion newContentVersion = CMN_DAL_DataFactory.newContentVersion(objectId, title, versionData);

		newContentVersion.PathOnClient = pathOnClient;

		//Note when you set FirstPublishLocationId it will automatically create a link.
		newContentVersion.NetworkId = networkId;
		newContentVersion.ContentDocumentId = contentDocumentId;

		return newContentVersion;
	}

	/**
	 * @description Will return the new version of Content version object
	 *
	 * @param objectId
	 * @param title
	 * @param pathOnClient
	 * @param versionData
	 * @param networkId
	 *
	 * @return
	 */
	public static ContentVersion newItem(Id objectId, String title, String pathOnClient, Blob versionData, Id networkId)
	{
		return newItem(objectId, title, pathOnClient, versionData, networkId, null);
	}

	/**
	 * @description The default fields to query from the ContentVersion Object
	 *
	 * @return A list of ContentVersion¬ fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				ContentVersion.Checksum.getDescribe().getLocalName(),
				ContentVersion.ContentBodyId.getDescribe().getLocalName(),
				ContentVersion.ContentDocumentId.getDescribe().getLocalName(),
				ContentVersion.ContentLocation.getDescribe().getLocalName(),
				ContentVersion.ContentSize.getDescribe().getLocalName(),
				ContentVersion.ContentUrl.getDescribe().getLocalName(),
				ContentVersion.Description.getDescribe().getLocalName(),
				ContentVersion.ExternalDataSourceId.getDescribe().getLocalName(),
				ContentVersion.ExternalDocumentInfo1.getDescribe().getLocalName(),
				ContentVersion.ExternalDocumentInfo2.getDescribe().getLocalName(),
				ContentVersion.FeaturedContentBoost.getDescribe().getLocalName(),
				ContentVersion.FeaturedContentDate.getDescribe().getLocalName(),
				ContentVersion.FileExtension.getDescribe().getLocalName(),
				ContentVersion.FileType.getDescribe().getLocalName(),
				ContentVersion.FirstPublishLocationId.getDescribe().getLocalName(),
				ContentVersion.Id.getDescribe().getLocalName(),
				ContentVersion.Id.getDescribe().getLocalName(),
				ContentVersion.IsAssetEnabled.getDescribe().getLocalName(),
				ContentVersion.IsLatest.getDescribe().getLocalName(),
				ContentVersion.IsMajorVersion.getDescribe().getLocalName(),
				ContentVersion.NegativeRatingCount.getDescribe().getLocalName(),
				ContentVersion.Origin.getDescribe().getLocalName(),
				ContentVersion.Origin.getDescribe().getLocalName(),
				ContentVersion.OwnerId.getDescribe().getLocalName(),
				ContentVersion.PathOnClient.getDescribe().getLocalName(),
				ContentVersion.PositiveRatingCount.getDescribe().getLocalName(),
				ContentVersion.PublishStatus.getDescribe().getLocalName(),
				ContentVersion.RatingCount.getDescribe().getLocalName(),
				ContentVersion.ReasonForChange.getDescribe().getLocalName(),
				ContentVersion.SharingOption.getDescribe().getLocalName(),
				ContentVersion.SharingPrivacy.getDescribe().getLocalName(),
				ContentVersion.SystemModstamp.getDescribe().getLocalName(),
				ContentVersion.TagCsv.getDescribe().getLocalName(),
				ContentVersion.TextPreview.getDescribe().getLocalName(),
				ContentVersion.Title.getDescribe().getLocalName(),
				ContentVersion.VersionData.getDescribe().getLocalName(),
				ContentVersion.VersionNumber.getDescribe().getLocalName(),
				FIELD_CONTENT_DOCUMENT_ID,
				FIELD_IS_DELETED,
				FIELD_IS_LATEST,
				FIELD_LATEST_PUBLISHED_VERSION_ID
		};
	}
	/**
	 * @description Queries ContentVersion for all the times linked to the given firstPublishLocationId
	 *
	 * @param firstPublishLocationId ID of the location where the version was first published.
	 *
	 * @return List of Content Version; note this only queries for latest version
	 */

	public static List<ContentVersion> findByFirstPublishLocationId(Id firstPublishLocationId)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_FIRST_PUBLISHED_LOCATION_ID, new Set<String> {firstPublishLocationId}, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_IS_LATEST, CMN_SOQL_Query.Operator.EQUALS, true));

		searchParameters.addSearchCondition(andCondition);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Will attrieve the Latest Content Version for given Content Documents
	 *
	 * @param contentDocumentIds Content Document Ids
	 *
	 * @return A list of Content Versions
	 */
	public static List<ContentVersion> findLatestByContentDocumentId(Set<Id> contentDocumentIds)
	{
		//No point in running query with empty search values; also a set condition is invalid if empty.
		if(contentDocumentIds.isEmpty())
		{
			return new List<ContentVersion>();
		}

		Set<String> contentDocumentIdStrings = new Set<String>();

		for(Id contentDocumentId : contentDocumentIds)
		{
			contentDocumentIdStrings.add(String.valueOf(contentDocumentId));
		}

		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_CONTENT_DOCUMENT_ID, contentDocumentIdStrings, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_IS_LATEST, CMN_SOQL_Query.Operator.EQUALS, true));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_IS_DELETED, CMN_SOQL_Query.Operator.EQUALS, false));

		searchParameters.addSearchCondition(andCondition);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Returns ContentVersion documents in a specified library (ContentWorkspace)
	 * that are in a specified folder name
	 *
	 * @param libraryFolders Map of library and folder names. The key is the name of the library,
	 * and the value is a list of folder names in that library.
	 *
	 * @return Map of library-folder maps. The first key level will be the library name, and the values
	 * are folder-contentversion maps. The second key level will be the folder name, and the values are
	 * a list of all content versions contained in that folder.
	 */
	public static Map<String, Map<String, List<ContentVersion>>> findContentVersionsByWorkspaceFolders(Map<String, List<String>> libraryFolders)
	{
		Set<String> folders = new Set<String>();
		for(String libraryName : libraryFolders.keySet())
		{
			folders.addAll(libraryFolders.get(libraryName));
		}
		List<ContentFolder> folderObjects = CMN_DAL_ContentFolder.findContentFoldersByName(folders);
		List<ContentWorkspace> libraryObjects = CMN_DAL_ContentWorkspace.findWorkspacesByName(libraryFolders.keySet());

		Set<Id> folderIds = CMN_UTIL_System.extractListIds(folderObjects);
		Set<Id> libraryIds = CMN_UTIL_System.extractListIds(libraryObjects);

		List<ContentFolderMember> files = CMN_DAL_ContentFolderMember.findMembersByFoldersInWorkspaces(libraryIds, folderIds);
		List<ContentDocument> contentDocuments = CMN_DAL_ContentDocument.getContentDocumentsById(new Set<Id>(CMN_DAL_ContentDocument.getContentDocumentIdsByContentFolderMember(files)));
		List<ContentVersion> contentVersions = findLatestByContentDocumentId(CMN_UTIL_System.extractListIds(contentDocuments));

		Map<String, Map<String, List<ContentVersion>>> documentList = new Map<String, Map<String, List<ContentVersion>>>();

		for(String libraryName : libraryFolders.keySet())
		{
			for(String folderName : libraryFolders.get(libraryName))
			{
				// Find the docs belonging to the library
				List<ContentWorkspace> lib = (List<ContentWorkspace>)CMN_UTIL_System.findWhere(libraryObjects, ContentWorkspace.Name.getDescribe().getLocalName(), libraryName);
				ContentWorkspace library = lib.isEmpty() ? new ContentWorkspace() : lib.iterator().next();
				List<ContentDocument> retrievedDocs = (List<ContentDocument>)CMN_UTIL_System.findWhere(contentDocuments, ContentDocument.ParentId.getDescribe().getLocalName(), library.Id);

				// Find the contentfolder members (link to docs) belonging to the folder
				List<ContentFolder> folderList = (List<ContentFolder>)CMN_UTIL_System.findWhere(folderObjects, ContentFolder.Name.getDescribe().getLocalName(), folderName);
				List<ContentFolderMember> folderMembers = (List<ContentFolderMember>)CMN_UTIL_System.findWhereIn(files, ContentFolderMember.ParentContentFolderId.getDescribe().getLocalName(), new List<Id>(CMN_UTIL_System.extractListIds(folderList)));
				Set<String> folderMemberDocIds = CMN_UTIL_System.extractSetValues(folderMembers, ContentFolderMember.ChildRecordId.getDescribe().getLocalName());

				// Find all the docs in folder belonging to the library
				retrievedDocs = CMN_UTIL_System.findWhereIn(retrievedDocs, ContentDocument.Id.getDescribe().getLocalName(), new List<String>(folderMemberDocIds));
				List<ContentVersion> retrievedContentVersions = CMN_UTIL_System.findWhereIn(contentVersions, ContentVersion.ContentDocumentId.getDescribe().getLocalName(), new List<Id>(CMN_UTIL_System.extractListIds(retrievedDocs)));

				if(documentList.containsKey(libraryName))
				{
					if(!documentList.get(libraryName).containsKey(folderName))
					{
						documentList.get(libraryName).put(folderName, retrievedContentVersions);
					}
					else
					{
						throw new IllegalArgumentException(ERROR_FOLDER_NAME_NOT_UNIQUE);
					}
				}
				else
				{
					Map<String, List<ContentVersion>> folderMap = new Map<String, List<ContentVersion>>();
					folderMap.put(folderName, retrievedContentVersions);
					documentList.put(libraryName, folderMap);
				}
			}
		}

		return documentList;
	}

	/**
	 * @description Will retrieve all content versions
	 *
	 * @return A list of Content Versions
	 */
	@TestVisible
	private static List<ContentVersion> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description Will insert a new content version against an object; if a single content document is matched then it will add version to content document
	 *
	 * @param objectId
	 * @param title
	 * @param pathOnClient
	 * @param versionData
	 * @param networkId
	 *
	 * @return
	 */
	public static ContentVersion insertNewObjectImageVersion(Id objectId, String title, String pathOnClient, Blob versionData, Id networkId)
	{
		ContentVersion existingVersion = findLatestImageVersionByTitle(objectId);

		//Network Id can only be set on Original Version and may not change afterwards
		networkId = existingVersion == null ? networkId : existingVersion.NetworkId;

		String newTitle = generateObjectImageTitle(objectId);

		//FirstPublishedLocation can only be set for first version
		Id newObjectId = existingVersion == null ? objectId : null;

		ContentVersion newVersion;

		if(existingVersion == null)
		{
			newVersion = newItem(newObjectId, newTitle, pathOnClient, versionData, networkId);
		}
		else
		{
			newVersion = newItem(newObjectId, newTitle, pathOnClient, versionData, networkId, existingVersion.ContentDocumentId);
		}

		newVersion.Description = title;

		CMN_DAL_SObjectDomain.insertDBObject(newVersion);

		return newVersion;
	}

	private static String generateObjectImageTitle(Id objectId)
	{
		return String.format(FORMAT_OBJECT_IMAGE_TITLE, new List<String> {objectId});
	}

	/**
	 * @description Will return the latest content version (being used to store an object image) against an object
	 *
	 * @param objectId
	 *
	 * @return
	 */
	public static ContentVersion findLatestImageVersionByTitle(Id objectId)
	{
		List<ContentVersion> versions =
		[
				SELECT
						ContentBodyId,
						ContentDocumentId,
						ContentLocation,
						ContentSize,
						ContentUrl,
						Description,
						FileExtension,
						FileType,
						FirstPublishLocationId,
						Id,
						IsLatest,
						IsMajorVersion,
						NetworkId,
						Origin,
						OwnerId,
						PathOnClient,
						TagCsv,
						TextPreview,
						Title
				FROM ContentVersion
				WHERE IsLatest = TRUE
				AND Title = :generateObjectImageTitle(objectId)
		];

		return versions.isEmpty() ? null : versions[0];
	}

	/**
	 * @description Will return the latest content version (being used to store an object image) against an object
	 *
	 * @param contentDocumentIds
	 *
	 * @return
	 */
	public static List<ContentVersion> findLatestImageVersionByContentDocuments(List<String> contentDocumentIds)
	{
		List<ContentVersion> versions =
		[
				SELECT
						Id
				FROM ContentVersion
				WHERE ContentDocumentId IN :contentDocumentIds
				AND IsLatest = TRUE
		];

		return versions.isEmpty() ? null : versions;
	}
}