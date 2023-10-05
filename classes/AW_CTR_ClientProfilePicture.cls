/**
 * @description An apex page to fetch the user details for the community user.
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_CTR_ClientProfilePicture
{
	/**
	 * @description Fetch the user details for the community user
	 *
	 * @param accountId The account Id of the community user you want to retrieve
	 *
	 * @return The user record of the of the community user
	 */
	@AuraEnabled(Cacheable=true)
	public static User getCommunityUserDetails(Id accountId)
	{
		return AW_DAL_User.findByAccountId(accountId);
	}

}