/**
 * @description Scenario 1
 * Scenario 1
 * If the object in the LinkedEntityId is a user, check if the user is a community user
 * If so make sure that we insert a link to the ContentDocument to relevant User's Account
 * Scenario 2
 * If the object in the LinkedEntityId is an Account; check if this account is a community user account
 * If so make sure the that the ContentDocument is also shared with the user on the account so it appears on community for them
 *
 * @see AW_TEST_TH_ContentDocumentLink
 *
 * @author Accenture
 *
 * @date 2019
 */
public class AW_TH_ContentDocumentLink extends CMN_TRH_BaseObject
{
	private Boolean canProcess = false;
	private static User currentUser = AW_DAL_User.getCurrentUser();
	private Map<Id, List<ContentDocumentLink>> accountLinkMap = new Map<Id, List<ContentDocumentLink>>();

	private static final Set<String> WORKBENCH_PROFILE_NAMES = new Set<String>
	{
			AW_DAL_Profile.PROFILE_ADVISER,
			AW_DAL_Profile.PROFILE_SALES_LEADER,
			AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT

	};

	/**
	 * @description Bulk actions to execute on an Before trigger
	 */
	public override void bulkBefore()
	{
		super.bulkBefore();
		canProcess = WORKBENCH_PROFILE_NAMES.contains(currentUser.Profile.Name);
	}

	/**
	 * @description Bulk actions to execute on an After trigger
	 */
	public override void bulkAfter()
	{
		super.bulkAfter();
		canProcess = AW_DAL_Profile.PROFILE_CLIENT.equalsIgnoreCase(currentUser.Profile.Name);
	}

	/**
	 * @description Context method overrides will be called before insertion of Object.
	 *
	 * @param so
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);

		ContentDocumentLink link = (ContentDocumentLink)so;

		if(canProcess)
		{
			if(CMN_UTIL_System.getSObjectTypeById(link.LinkedEntityId) == Account.SObjectType)
			{
				List<ContentDocumentLink> accountLinks = accountLinkMap.get(link.LinkedEntityId);

				if(accountLinks == null)
				{
					accountLinks = new List<ContentDocumentLink>();
					accountLinkMap.put(link.LinkedEntityId, accountLinks);
				}

				accountLinks.add(link);
			}
		}
	}

	/**
	 * @description Context method overrides will be called after the end of trigger executions .
	 */
	public override void andFinally()
	{
		super.andFinally();

		if(canProcess)
		{
			if(Trigger.isBefore && !accountLinkMap.isEmpty())
			{
				shareContentWithCommunityUser();
			}
			else if(Trigger.isAfter)
			{
				shareContentWithCommunityAccount();
			}
		}
	}

	//Since this trigger is creating new links, don't want to process the newly created links
	public override Boolean allowRecursion()
	{
		return super.allowRecursion() && false;
	}

	/**
	 * @description Ensure  that the Content is shared with anyone who gains access to the feed of the Client account
	 */
	private void shareContentWithCommunityAccount()
	{
		//find  all links related to the current community user
		List<ContentDocumentLink> existingLinks = CMN_DAL_ContentDocumentLink.findByLinkedEntitiesIds(new Set<Id> {currentUser.Id});

		//find all links associated to the account of the current community user
		List<ContentDocumentLink> existingAccountLinks = CMN_DAL_ContentDocumentLink.findByLinkedEntitiesIds(new Set<Id> {currentUser.AccountId});

		//Extract all content documents already linked to the Community Account Object
		Set<Id> existingLinkedToAccountContentIds = CMN_UTIL_System.extractListIds(existingAccountLinks, CMN_DAL_ContentDocumentLink.FIELD_CONTENT_DOCUMENT_ID);

		//Ensure we insure content links for content documents on the account that don't already have a links
		List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();

		for(ContentDocumentLink existingLink : existingLinks)
		{
			if(!existingLinkedToAccountContentIds.contains(existingLink.ContentDocumentId))
			{
				ContentDocumentLink newLink = CMN_DAL_ContentDocumentLink.newItem(existingLink.ContentDocumentId, currentUser.AccountId, CMN_DAL_ContentDocumentLink.SHARE_TYPE_INFERRED);
				newLinks.add(newLink);
			}
		}

		//TODO: Figure out why we may try and insert same link twice
		CMN_DAL_SObjectDomain.insertDBObjects(newLinks, false);
	}

	/**
	 * @description This will retrieve all community users for the relevant account ids and ensure document is shared with them
	 */
	private void shareContentWithCommunityUser()
	{
		Set<Id> accountIds = accountLinkMap.keySet();

		//Using the accountIds for links shared to an account, find (potential) community users
		List<User> communityUsers = CMN_DAL_User.findByAccountId(accountIds);

		for(User communityUser : communityUsers)
		{
			List<ContentDocumentLink> insertedLinks = accountLinkMap.get(communityUser.AccountId);

			List<ContentDocumentLink> communityUserLinks = new List<ContentDocumentLink>();

			for(ContentDocumentLink insertedLink : insertedLinks)
			{

				ContentDocumentLink communityUserLink = insertedLink.clone();

				communityUserLink.LinkedEntityId = communityUser.Id;
				communityUserLink.Visibility = CMN_DAL_ContentDocumentLink.VISIBILITY_ALL_USERS;

				communityUserLinks.add(communityUserLink);
			}

			CMN_DAL_SObjectDomain.insertDBObjects(communityUserLinks, false);
		}

	}
}