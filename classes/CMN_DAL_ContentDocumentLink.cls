/**
 * @description CMN_DAL_ContentDocumentLink class provides base methods and example of how to use
 * the CMN_DAL_ContentDocumentLink methods.
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_ContentDocumentLink
{
	public static final String VISIBILITY_ALL_USERS = 'AllUsers';
	public static final String FIELD_CONTENT_DOCUMENT_ID = ContentDocumentLink.ContentDocumentId.getDescribe().getLocalName();
	public static final String SHARE_TYPE_INFERRED = 'I';

	/**
	 * @description This method is use for ContentDocumentLink
	 *
	 * @param contentDocumentId
	 * @param linkToId
	 * @param shareType
	 *
	 * @return newLink
	 */
	public static ContentDocumentLink newItem(Id contentDocumentId, Id linkToId, String shareType)
	{
		ContentDocumentLink newLink;

		if(contentDocumentId != null && linkToId != null && String.isNotBlank(shareType))
		{
			newLink = new ContentDocumentLink();

			newLink.ContentDocumentId = contentDocumentId;
			newLink.LinkedEntityId = linkToId;
			newLink.ShareType = shareType;
			newLink.Visibility = VISIBILITY_ALL_USERS;
		}

		return newLink;
	}

	/**
	 * @description This method is use to return Content Document link bases on Linked Enitity.
	 *
	 * @param linkedEntitiesIds
	 *
	 * @return
	 */
	public static List<ContentDocumentLink> findByLinkedEntitiesIds(Set<Id> linkedEntitiesIds)
	{
		return
		[

				SELECT
						ContentDocumentId,
						Id,
						LinkedEntityId,
						ShareType,
						ContentDocument.LatestPublishedVersionId,
						ContentDocument.Title,
						ContentDocument.FileExtension,
						ContentDocument.FileType
				FROM
						ContentDocumentLink
				WHERE
						LinkedEntityId IN :linkedEntitiesIds
		];
	}
}