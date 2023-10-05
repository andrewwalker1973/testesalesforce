/**
 * @description Trigger handler for the trigger AW_TRG_ContentVersion
 *
 * @see AW_TEST_TH_ContentDocumentLink
 *
 * @author Accenture
 */
public inherited sharing class AW_TH_ContentVersion extends CMN_TRH_BaseObject
{
	private Id communityId;

	private static final Set<String> WORKBENCH_PROFILE_NAMES = new Set<String>
	{
			AW_DAL_Profile.PROFILE_ADVISER,
			AW_DAL_Profile.PROFILE_SALES_LEADER,
			AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT

	};

	/**
	 * @description Context method overrides will be called on bulk of Object.
	 */
	public override void bulkBefore()
	{
		super.bulkBefore();

		//Only set the community Id on the contentversion if relevant profile
		if(WORKBENCH_PROFILE_NAMES.contains(AW_DAL_User.getCurrentUser().Profile.Name))
		{
			NetworkMember communityMember = CMN_DAL_Community.findCurrentUserMember(AW_DAL_Community.CLIENT_PORTAL_NAME);
			communityId = communityMember?.NetworkId;
		}
	}

	/**
	 * @description Context method overrides will be called before insertion of Object.
	 *
	 * @param so A SObject that is about to be inserted
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);

		ContentVersion version = (ContentVersion)so;

		/*
		Only set the community/networkid of the content version when
		1). The user creating content is correct profile see: WORKBENCH_PROFILE_NAMES
		2). The user is part of the workbench client portal
		3). The Content was first associated with an Account Object
		4). The content doesn't already linked to a community
		 */
		if(communityId != null && version.ContentDocumentId == null && version.NetworkId == null)
		{
			if(CMN_UTIL_System.getSObjectTypeById(version.FirstPublishLocationId) == Account.SObjectType)
			{
				version.NetworkId = communityId;
			}
		}
	}
}